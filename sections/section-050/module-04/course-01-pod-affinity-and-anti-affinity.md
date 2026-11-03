---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Pod Affinity And Anti-Affinity With topologyKey

The three replicas of the `probe` Deployment must not share a node, so that one node failure cannot take all of them down. The `shuttle` client should run in the same zone as `probe` to keep requests local. Both wishes describe where a Pod runs in relation to other Pods, not in relation to node labels.

This chapter shows the fields, the meaning of the `topologyKey`, and what happens when a hard rule asks for more domains than the cluster has.

## Fields and meaning

Pod affinity and anti-affinity live under `spec.affinity.podAffinity` and `spec.affinity.podAntiAffinity`. Each has a required list, `requiredDuringSchedulingIgnoredDuringExecution`, and a preferred list, `preferredDuringSchedulingIgnoredDuringExecution`. As with node affinity, the rules apply only while the scheduler places the Pod.

A required item has three fields that matter. `labelSelector` selects the existing Pods the rule talks about. `topologyKey` is the name of a node label, and it defines the topology domain: all nodes with the same value of that label form one domain. `namespaces` or `namespaceSelector` can widen the search; by default the rule counts only Pods in the namespace of the incoming Pod. A preferred item wraps the same fields in `podAffinityTerm` and adds a `weight` from 1 to 100.

The meaning follows from those fields. Pod affinity says: put this Pod in a domain that already holds at least one Pod matching the selector. Pod anti-affinity says: do not put this Pod in a domain that holds a Pod matching the selector. With `topologyKey: kubernetes.io/hostname` each node is its own domain. With `topology.kubernetes.io/zone` each zone is a domain.

A node that lacks the topology label belongs to no domain. For required Pod affinity, such a node does not qualify. For required anti-affinity, the rule cannot exclude it, because it has no domain to conflict with. Label every node the rule should reason about.

<!-- astrona:playground:renew -->

## A worked example: one replica per node

Save this as `deployment-probe.yaml`. It asks that no two `probe` Pods share a node:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 3
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: probe
            topologyKey: kubernetes.io/hostname
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

Then list the Pods with their nodes:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
```

The playground has two worker nodes and the control plane node, which is tainted. Two Pods run, one on each worker. The third Pod is `Pending`, because both workers already hold a Pod that matches the selector and the control plane node does not accept the Pod. The scheduler component that evaluates these rules is the inter-pod affinity plugin, and it filters the nodes before scoring.

## Reading the failure

Inspect the Pending Pod:

```sh
kubectl -n starfleet describe pod -l app=probe | grep -A3 FailedScheduling
```

The event says that nodes "didn't match pod anti-affinity rules", with a count, next to the node with an untolerated taint. The rule is correct and the cluster is too small for it. There are three ways out, and each changes a different contract. Add a node, lower the replica count, or relax the rule to a preferred rule or a topology spread constraint.

## A worked example: affinity to a zone

Pod affinity is the opposite rule. Save this as `pod-shuttle.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shuttle
  namespace: starfleet
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: probe
        topologyKey: topology.kubernetes.io/zone
  containers:
  - name: client
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-shuttle.yaml
```

The `shuttle` Pod runs in the zone of one of the running `probe` Pods. If no `probe` Pod existed yet, a required Pod affinity rule would leave `shuttle` Pending. The scheduler makes one exception: a Pod whose own labels match its affinity selector can start the first domain, which is how a group of replicas that attract each other can schedule at all.

## Costs and limits

Inter-pod rules are expensive: the scheduler compares each candidate node with the Pods in every domain. Kubernetes documentation advises against using them in clusters of several hundred nodes. Anti-affinity with the hostname key is the common way to say "one per node", and a preferred rule with weight is the soft version that never blocks. A rule is checked only at scheduling time, so Pods that already run are not moved when a new Pod violates a rule from another Pod's point of view. The existing Pod's required anti-affinity does apply to new Pods that match its selector.

You can now keep replicas apart or together and read the event when the cluster cannot satisfy the rule. A hard anti-affinity rule cannot express "spread evenly but allow more replicas than nodes", and that is the problem topology spread constraints solve.

## Common pitfalls

> [!WARNING]
> Required anti-affinity needs at least as many matching domains as replicas, or the extra Pods stay Pending. The `labelSelector` must match the labels of the Pods themselves, or the rule never applies. A node without the `topologyKey` label belongs to no domain. Do not remove a required rule to clear a Pending status before you know whether the one-per-node requirement is real.
