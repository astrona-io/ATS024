---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Debugging Pending Pods

A `Pending` Pod has been accepted by the API server but has no running container. The word covers several different situations: no node chosen, a node chosen but the image not pulled, or nobody scheduling the Pod at all. The fastest way to the cause is to read the same four places in the same order.

This chapter gives that order, explains how to read the `FailedScheduling` message, and shows the three situations side by side.

## Four places to read

First, `kubectl get pod -o wide` shows the status and the node. An empty node column means the Pod is not assigned. A status of `SchedulingGated` names a gate directly.

Second, `kubectl describe pod` shows the events. The events come from the component that acted, and the source column tells which: `default-scheduler` for placement, `kubelet` for image and container problems. A Pod with no events at all was not considered by any scheduler.

Third, the node data explains resource and taint messages. `kubectl describe node` lists the taints, the allocatable resources and the requests already allocated. `kubectl get nodes --show-labels` explains selector and affinity failures.

Fourth, the objects the Pod depends on: a PersistentVolumeClaim that is not bound, a ResourceQuota that blocks creation, or a scheduler Pod in `kube-system` that is not running.

## Reading FailedScheduling

The scheduler writes one event with a message of the form "0/N nodes are available:" followed by a count for each filter that removed nodes. The words are stable and map to causes:

- `Insufficient cpu` or `Insufficient memory`: the Pod's requests do not fit the free allocatable amount on any node.
- `didn't match Pod's node affinity/selector`: a `nodeSelector` or node affinity rule has no matching node.
- `had untolerated taint`: the node has a taint the Pod does not tolerate. The taint key follows in the message.
- `didn't match pod anti-affinity rules` and `didn't satisfy existing pods anti-affinity rules`: Pod anti-affinity blocks the node.
- `didn't match pod topology spread constraints`: a `DoNotSchedule` constraint would exceed `maxSkew`.
- `node(s) were unschedulable`: the node is cordoned.

The counts add up to the number of nodes, and a node is counted under the first filter it failed. The message ends with a preemption note that says whether evicting lower-priority Pods would help.

<!-- astrona:playground:renew -->

## Three Pending Pods side by side

Save this as `deployment-scout.yaml`. It asks for more CPU than any node has:

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
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: "64"
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

Then read the event:

```sh
kubectl -n starfleet describe pod -l app=scout
```

The event is `FailedScheduling` from `default-scheduler`, and the message lists `Insufficient cpu` for the worker and an untolerated taint for the control plane node. The scheduler did its work and found no node, so the fix is in the Pod's request or in the cluster's capacity. Lower the request in the Deployment and the controller replaces the Pod.

Compare this with two other Pending Pods: a Pod whose `schedulerName` names a scheduler that does not run, and a Pod with a scheduling gate. They are also Pending, but their events are empty and the gate shows in the status. In all three cases `kubectl get pod` shows `Pending`, and only the events and status separate them. That is the reason to read events before changing anything.

## Reading the node side

When the message says `Insufficient`, compare the request with what the node can still give. Run:

```sh
kubectl describe node <WORKER> | grep -A8 "Allocated resources"
```

Replace `<WORKER>` with the node name. The section lists the CPU and memory requests and limits already allocated to Pods on the node. The scheduler subtracts requests, not live usage, from the allocatable amount, so a node with low usage can still be full.

## A short checklist

Read the status, then the events. If the event is from the scheduler, decode the message with the list above and fix the rule, the request or the node. If there is no event, check `schedulerName`, `schedulingGates` and the scheduler Pod in `kube-system`. If the Pod has a node but is not Running, the problem is not scheduling: read the kubelet events for image pulls and volume mounts.

A fix must keep the requirement. Removing a node selector, lowering a request to a value the application cannot use, or adding a toleration for a taint that protects a node gets the Pod Running without solving the original need.

## Common pitfalls

> [!WARNING]
> `Pending` has several causes, and the events separate them. An empty event list means no scheduler acted. `Insufficient` counts requests, not usage. Do not weaken a selector, a taint or a spread rule just to make the Pod run: find the requirement behind the rule first.
