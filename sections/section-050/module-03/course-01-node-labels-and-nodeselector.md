---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Node Labels And nodeSelector

A Pod named `scout` must run on a node that has fast local disks. The Pod itself cannot know which node has them. Kubernetes solves this with labels on nodes and a field in the Pod that names the labels the node must have.

This chapter shows where node labels come from, how the `nodeSelector` field uses them, what you see when no node matches, and why Kubernetes also offers the more expressive node affinity.

## Where node labels come from

A label is a key and value pair stored in the `metadata.labels` of an object. A node is a machine that runs Pods, and it is an object in the Kubernetes API like any other. Two sources put labels on nodes. The kubelet (the agent that runs on each node) sets well-known labels when it registers the node. An administrator or a cloud controller adds all other labels.

The well-known labels include `kubernetes.io/hostname`, `kubernetes.io/os`, `kubernetes.io/arch` and, on cloud clusters, `topology.kubernetes.io/zone` and `topology.kubernetes.io/region`. Labels with the prefix `kubernetes.io` and `k8s.io` are reserved for Kubernetes components. Your own labels should use a prefix you own or no prefix, such as `disk` or `tier`.

<!-- astrona:playground:renew -->

In the playground, list the nodes with all their labels:

```sh
kubectl get nodes --show-labels
```

The output has one row per node. The worker row contains `disk=ssd`, `tier=compute` and `gpu-count=2` next to the well-known labels. The control plane node row has the label `node-role.kubernetes.io/control-plane`. The label value for that role key is empty, which is why a selector such as `!node-role.kubernetes.io/control-plane` selects only the workers.

## The nodeSelector field

`spec.nodeSelector` in a Pod is a map of label keys to values. The scheduler, which is the control plane component that chooses a node for every new Pod, keeps only the nodes whose labels contain every pair in the map. All pairs must match, so the rules are joined with AND. The match is exact: the field supports equality only.

Save this as `pod-scout.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: scout
  namespace: starfleet
spec:
  nodeSelector:
    disk: ssd
  containers:
  - name: scout
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-scout.yaml
```

Then check which node the scheduler chose:

```sh
kubectl -n starfleet get pod scout -o wide
```

The column `NODE` names the worker. The scheduler wrote that value into the Pod when it bound the Pod to the node. The control plane node is not a candidate for another reason: it carries a taint, which repels Pods that do not tolerate it.

## When no node matches

A selector that no node satisfies does not produce an error. The API server accepts the Pod, because the Pod is valid, and the scheduler cannot find a node. The Pod stays in the phase `Pending`, and the scheduler records a `FailedScheduling` event that says how many nodes failed which check.

Save this as `pod-scout-gpu.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: scout-gpu
  namespace: starfleet
spec:
  nodeSelector:
    accelerator: "true"
  containers:
  - name: scout
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it and read the events:

```sh
kubectl apply -f pod-scout-gpu.yaml
kubectl -n starfleet describe pod scout-gpu
```

The `Events` section shows a `FailedScheduling` warning from `default-scheduler`. The message has the form "0/2 nodes are available" followed by a count of nodes that "didn't match Pod's node affinity/selector" and a count of nodes with an untolerated taint. The exact counts depend on your cluster. The message is the first thing to read when a Pod is stuck, because it names the failed filter.

The fix is a node that carries the label. Add it to the worker and watch the Pod move on:

```sh
kubectl label nodes -l '!node-role.kubernetes.io/control-plane' accelerator=true
kubectl -n starfleet get pod scout-gpu -o wide --watch
```

The scheduler watches nodes as well as Pods. A label change is an event that makes it try the Pending Pod again, so no restart is needed. Press `Ctrl+C` when the Pod shows `Running`.

## nodeSelector compared with node affinity

`nodeSelector` is short and easy to read, but it can only say "label key equals value" and every pair is required. Node affinity, which the next chapters cover, uses the field `spec.affinity.nodeAffinity`. It adds the operators `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt` and `Lt`, several alternative terms joined with OR, and preferred rules that influence scoring without being mandatory.

Both fields can appear in the same Pod. Then the node must satisfy the `nodeSelector` and the node affinity together. Use `nodeSelector` for a simple hard requirement. Use node affinity when you need a set of allowed values, a negative match or a soft preference.

Two more facts matter in practice. First, a node label is data on the node object, so anyone who can edit nodes can change which Pods match. The `NodeRestriction` admission plugin stops a kubelet from setting labels under the prefix `node-restriction.kubernetes.io/`, so use that prefix for labels that isolate workloads. Second, the scheduler reads labels only when it places the Pod. Removing a label later does not evict a running Pod.

The `scout` Pod now runs where the `disk` label says it should, and `scout-gpu` runs after the node gained the `accelerator` label. What you do not yet know is how to express "any of these values" or "anything except this value". That is the job of required node affinity.

## Common pitfalls

> [!WARNING]
> A `nodeSelector` is exact and every pair is required. A typo in a key or a value leaves the Pod `Pending` without an error from the API server. Compare the Pod's selector with `kubectl get nodes --show-labels`, and read the `FailedScheduling` event before you change anything else. Do not remove a node label to fix a Pod unless you know which other Pods use it.
