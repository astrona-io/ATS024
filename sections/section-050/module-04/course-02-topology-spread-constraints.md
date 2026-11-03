---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Topology Spread Constraints

Four replicas of `probe` should be spread over two zones, with the same count in each zone, and a fifth replica should still start when the zones cannot be perfectly even. Anti-affinity cannot say this, because it allows only one Pod per domain. A topology spread constraint states the allowed difference between domains instead.

This chapter defines skew, explains each field of `topologySpreadConstraints`, and works through the arithmetic that decides whether the scheduler accepts the next Pod.

## The fields

`spec.topologySpreadConstraints` is a list in the Pod spec. Each constraint has these fields:

- `topologyKey`: the node label that defines a domain, such as `topology.kubernetes.io/zone`.
- `labelSelector`: selects the Pods that are counted in each domain.
- `maxSkew`: the largest allowed difference, described below. It must be greater than zero.
- `whenUnsatisfiable`: `DoNotSchedule` makes the constraint a hard filter, and `ScheduleAnyway` makes it a soft preference that only lowers the score of nodes that increase the skew.
- `minDomains`: optional, only with `DoNotSchedule`. It treats the minimum count as zero until that many domains exist.

Skew is calculated per domain. It is the number of matching Pods in that domain minus the smallest number of matching Pods in any eligible domain. The scheduler places the Pod only where the resulting skew stays at or below `maxSkew`.

## Arithmetic example

Take two zones, `zone-a` and `zone-b`, with `maxSkew: 1` and `DoNotSchedule`. The first Pod can go to either zone: the counts become 1 and 0, and the skew of the chosen zone is 1 minus 0, which is 1. The second Pod must go to the empty zone, because placing it in the zone that already has one gives 2 minus 0, which is 2. After that the counts are 1 and 1. The third Pod can go anywhere, and the fourth goes to the zone with fewer.

With three replicas the result is a 2 and 1 split, which satisfies `maxSkew: 1`. Anti-affinity on the zone key would have left the third Pod Pending.

<!-- astrona:playground:renew -->

## A worked example

Save this as `deployment-probe-spread.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 4
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: probe
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it:

```sh
kubectl apply -f deployment-probe-spread.yaml
```

Then count the Pods per node:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
```

The playground workers are in zones `zone-a` and `zone-b`, so the four Pods split two and two. The control plane node has no zone label, so it is not a domain, and it cannot distort the minimum. Describe the Deployment's Pods to see that the constraint was copied into each Pod:

```sh
kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].spec.topologySpreadConstraints}'
```

## DoNotSchedule compared with ScheduleAnyway

With `DoNotSchedule` the scheduler refuses a node that breaks `maxSkew`, and the Pod can stay Pending. That is right when an uneven placement is a defect. With `ScheduleAnyway` the Pod is always schedulable, and the constraint only adds a score penalty to the nodes that would increase the skew. Other scoring can outweigh it, so the result is not guaranteed to be even.

Consider one worker taken out with a cordon in the two-zone example. Only one domain can take Pods, but the other zone still exists as a domain with a count of zero while its node is only unschedulable. With `DoNotSchedule` and `maxSkew: 1`, the second Pod cannot be placed in the first zone, and it stays Pending. With `ScheduleAnyway` it runs, uneven. The behaviour depends on which nodes count as domains, which the next chapter covers.

## Defaults and several constraints

A Pod can list several constraints, and a node must satisfy all hard ones. A common pair is one constraint on zone and one on hostname. Without any constraint in the Pod, the scheduler applies cluster-level defaults when it is configured with them. In a default Kubernetes installation the kube-scheduler spreads Pods of one Service or controller across nodes and zones with `ScheduleAnyway` semantics.

You can now compute skew and choose between a hard and a soft constraint. A rolling update raises a new question: the old and new Pods share the same labels, so what is being counted?

## Common pitfalls

> [!WARNING]
> `maxSkew` is a difference, not a count per domain. `DoNotSchedule` can leave Pods Pending, and `ScheduleAnyway` never guarantees an even spread. The `labelSelector` must match the Pods you want to count. Nodes without the `topologyKey` label are not domains, so label every worker the rule should use.
