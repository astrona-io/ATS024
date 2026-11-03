---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Preferred Node Affinity And Weights

The `probe` Deployment would like to run on nodes with fast disks, but it must still run when none is free. A required rule would block it. A preferred rule only changes the order in which the scheduler ranks nodes that already pass every hard filter.

This chapter shows the field, the meaning of `weight`, how the scheduler adds weights to a node score, and how required and preferred rules work together.

## The field layout

Preferred node affinity lives at `spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`. It is a list. Each item has a `weight`, an integer from 1 to 100, and a `preference`, which has the same `matchExpressions` as a required term. As with the required field, `IgnoredDuringExecution` means a later label change does not move a running Pod.

The scheduler works in two phases. In the filter phase it removes every node that fails a hard requirement: resource requests, taints, `nodeSelector`, required affinity and more. In the score phase it gives each remaining node a number from several plugins. The node affinity plugin adds the weight of every preferred item whose expressions the node matches. The scheduler then chooses the node with the highest total.

Two consequences follow. A preference never makes a node eligible, so it cannot override a filter. And the weight is only relative to other scoring: other plugins, such as the one that favours nodes with free resources, add to the same total. A weight of 100 does not guarantee the choice, it only adds the most.

## A worked example

The playground has one worker, so the node choice is fixed. That is still enough to prove the point that matters: a preference that no node can meet does not block the Pod.

<!-- astrona:playground:renew -->

Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 80
            preference:
              matchExpressions:
              - key: disk
                operator: In
                values: ["nvme"]
          - weight: 20
            preference:
              matchExpressions:
              - key: disk
                operator: In
                values: ["ssd"]
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
kubectl apply -f deployment-probe.yaml
```

Then check where both replicas run:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
```

The worker has `disk=ssd`, so it matches the second item and gains 20 points. It does not match the first item, which asks for `nvme`, and that is not an error. Both Pods run on the worker. If the preference had been required, the Pods would be `Pending`.

## Reading weights across several nodes

Imagine three workers. Node A has `disk=nvme`, node B has `disk=ssd`, node C has no `disk` label. For the `probe` rule above, node A gains 80, node B gains 20 and node C gains 0 from node affinity. If the nodes are otherwise equal, `probe` Pods land on node A. If node A is nearly full, the resource scoring lowers its total, and a Pod can land on node B even though A has the higher preference. If node A cannot fit the Pod at all, the filter removes it and the preferences of the other nodes decide.

This is why a preference suits "where possible" intent, such as cheaper nodes or a warm cache. Use required affinity when running on the wrong node is a defect.

## Combining required and preferred rules

A Pod can carry both fields. The required field decides which nodes are candidates. The preferred field orders them. Save this as `deployment-probe-combined.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: tier
                operator: In
                values: ["compute"]
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 50
            preference:
              matchExpressions:
              - key: disk
                operator: In
                values: ["ssd"]
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
```

Apply it and wait for the rollout:

```sh
kubectl apply -f deployment-probe-combined.yaml
kubectl -n starfleet rollout status deployment/probe --timeout=90s
```

Only nodes with `tier=compute` are candidates, and among them the nodes with `disk=ssd` score higher. Weights inside one list are added, so two matching items give the sum of both weights.

## Failure cases and limits

A preference is evaluated only when a Pod is scheduled. Adding a better node later does not move running Pods. The scheduler does not rebalance, so a new Deployment rollout or a separate descheduler is needed to change existing placement. A weight outside 1 to 100 is rejected by the API server. A preferred rule with a typo in the key silently matches nothing, because a non-matching preference is not an error, so check the result with `kubectl get pods -o wide` instead of trusting the field.

You can now choose between a hard rule and a preference and explain how the scheduler adds weights. A rule that relates a Pod to other Pods, instead of to node labels, needs a different mechanism.

## Common pitfalls

> [!WARNING]
> A preferred rule never blocks scheduling, so a typo in it goes unnoticed. Weights are added to other scoring and only rank nodes that already passed every filter. A new node or a new label does not move running Pods. Use required affinity when the Pod must not run on the wrong node.
