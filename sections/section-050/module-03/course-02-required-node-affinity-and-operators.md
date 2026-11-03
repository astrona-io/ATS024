---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Required Node Affinity And Operators

The `scout` Pod may run on any node whose `disk` label is `ssd` or `nvme`, but never on a node labelled `tier=spot`. A `nodeSelector` cannot say that. Required node affinity can, because it supports sets of values, negative matches and alternatives.

This chapter explains the field layout, the six operators, how terms and expressions combine, and what the name `IgnoredDuringExecution` means for a Pod that is already running.

## The field layout

Required node affinity lives at `spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`. The name reads as two halves. `requiredDuringScheduling` means the rule is a hard filter: a node that fails it is removed from the candidate list, and if no node is left the Pod stays `Pending`. `IgnoredDuringExecution` means the rule is checked only while the scheduler places the Pod. If a node label changes later, the kubelet does not evict the Pod.

Inside the field there is one key, `nodeSelectorTerms`, which is a list. Each item is a term, and each term has a list `matchExpressions` (and a `matchFields` list for node fields such as `metadata.name`). Each expression has a `key`, an `operator` and, for most operators, a list of `values`.

The combination rules are the part to memorise. The terms in `nodeSelectorTerms` are joined with OR: a node that satisfies any one term is accepted. The expressions inside one term are joined with AND: a node must satisfy all of them. If the Pod also sets a `nodeSelector`, the node must satisfy that as well.

## The six operators

- `In`: the node has the key and its value is one of the listed values.
- `NotIn`: the node does not have the key, or its value is not in the list.
- `Exists`: the node has the key, with any value. `values` must be empty.
- `DoesNotExist`: the node does not have the key. `values` must be empty.
- `Gt`: the label value, read as an integer, is greater than the single listed value.
- `Lt`: the label value, read as an integer, is less than the single listed value.

`Gt` and `Lt` need exactly one value and compare numbers, so the label value must be an integer written as a string, such as `gpu-count: "2"`. A node whose label is not an integer never matches. `NotIn` and `DoesNotExist` also accept nodes that lack the key, which surprises people who expect "must have a label that differs".

<!-- astrona:playground:renew -->

## A worked example

Save this as `deployment-scout.yaml`. It asks for a worker whose `disk` label is `ssd` or `nvme`, that is not a spot node, and that has at least two accelerators:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disk
                operator: In
                values: ["ssd", "nvme"]
              - key: tier
                operator: NotIn
                values: ["spot"]
              - key: gpu-count
                operator: Gt
                values: ["1"]
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

Then check the placement:

```sh
kubectl -n starfleet get pods -l app=scout -o wide
```

The playground worker has `disk=ssd`, `tier=compute` and `gpu-count=2`. It satisfies all three expressions, so the `scout` Pod runs there. The Deployment controller created a ReplicaSet, the ReplicaSet created the Pod, and the scheduler applied the affinity from the Pod template.

## Terms are alternatives, expressions are all required

Now change the rule so that a second node type is acceptable. Two terms mean "either". Save this as `deployment-scout-terms.yaml`, which keeps the same Deployment and replaces the affinity:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disk
                operator: In
                values: ["nvme"]
            - matchExpressions:
              - key: tier
                operator: Exists
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
```

Apply it and read the result:

```sh
kubectl apply -f deployment-scout-terms.yaml
kubectl -n starfleet rollout status deployment/scout --timeout=60s
```

The first term needs `disk=nvme`, which the worker does not have. The second term needs only that the key `tier` exists, which it does. Because the terms are joined with OR, the worker is accepted and the rollout finishes. If you moved both expressions into one term, they would be joined with AND, and the Pod would stay `Pending`.

## Failure cases to recognise

If every term fails on every node, the Pod is `Pending`, and the `FailedScheduling` event says that nodes "didn't match Pod's node affinity/selector". A value list written without quotes can also fail validation or change meaning: `values: [1]` is rejected because values are strings. A `matchFields` term can only use the field `metadata.name`.

Changing the affinity of a running Pod is not allowed, because the Pod spec is immutable for these fields. Change the template of the Deployment instead. The Deployment controller then creates a new ReplicaSet, and the new Pods are scheduled with the new rule. The rollout waits on the new Pods, so a rule that matches no node leaves the old Pods running and the rollout stuck.

You can now write a hard rule and predict how terms and expressions combine. The remaining question is how to state a preference that the scheduler tries to honour without making the Pod unschedulable.

## Common pitfalls

> [!WARNING]
> Terms are joined with OR and expressions inside a term are joined with AND. Putting two requirements in two terms by mistake makes the rule far weaker than intended. `NotIn` and `DoesNotExist` match nodes that lack the key. `Gt` and `Lt` compare integers only. Never fix a `Pending` Pod by deleting the affinity unless the requirement itself is wrong.
