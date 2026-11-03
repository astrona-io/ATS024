---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Scheduling Gates, Cordon And Uncordon

Two different reasons keep a Pod from starting even though the cluster has capacity. The Pod itself may be held back until something else is ready, for example a quota decision from another system. Or the node may be closed to new Pods because an administrator is about to maintain it. Kubernetes has one mechanism for each: scheduling gates and cordon.

This chapter shows both, what each looks like in `kubectl`, and how to release them without removing safety.

## Scheduling gates

A scheduling gate is an entry in `spec.schedulingGates`, a list of objects with a `name`. While the list is not empty, the scheduler does not consider the Pod at all. The Pod is `Pending`, its condition `PodScheduled` is `False` with the reason `SchedulingGated`, and `kubectl get pods` shows the status `SchedulingGated`.

Gates are set when the Pod is created, usually by a mutating admission webhook or by the person who creates the Pod. A controller that owns the gate decides when to release it and removes its entry from the list. The rules of the API are strict. You can add gates only at creation, you can only remove gates afterwards, and the Pod is scheduled normally once the list is empty.

Gates solve a real problem: a Pod that is unschedulable and waiting generates repeated scheduling attempts and `FailedScheduling` events. A gated Pod costs the scheduler nothing and makes no noise.

<!-- astrona:playground:renew -->

Save this as `pod-shuttle.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shuttle
  namespace: starfleet
spec:
  schedulingGates:
  - name: example.com/hold
  containers:
  - name: shuttle
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-shuttle.yaml
kubectl -n starfleet get pod shuttle
```

The status column shows `SchedulingGated`, and the Pod has no events from the scheduler. Release the gate by removing the list with a JSON patch:

```sh
kubectl -n starfleet patch pod shuttle --type=json -p '[{"op":"remove","path":"/spec/schedulingGates"}]'
kubectl -n starfleet get pod shuttle -o wide
```

The Pod now passes through the scheduler and runs on the worker. To remove one of several gates, patch the list to contain the gates that remain.

## Cordon and uncordon

`kubectl cordon <node>` marks the node unschedulable. It sets `spec.unschedulable: true` on the Node object, and the node lifecycle controller adds the taint `node.kubernetes.io/unschedulable` with the effect `NoSchedule`. New Pods without a toleration for that taint cannot use the node. Pods that already run stay where they are. `kubectl uncordon <node>` reverses both.

`kubectl drain <node>` is cordon plus eviction. It first cordons the node and then evicts the Pods, honouring PodDisruptionBudgets, so use it for maintenance. DaemonSet Pods are skipped with `--ignore-daemonsets`. Plain cordon is the right tool when you only want to stop new placement.

Get the worker's name and cordon it:

```sh
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
kubectl cordon "$worker"
kubectl get nodes
```

The status of the worker shows `Ready,SchedulingDisabled`. A new Pod will not start now. Save this as `pod-drifter.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: drifter
  namespace: outpost
spec:
  containers:
  - name: drifter
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it and read the event:

```sh
kubectl apply -f pod-drifter.yaml
kubectl -n outpost describe pod drifter
```

The `FailedScheduling` event says that a node "had untolerated taint" with the key `node.kubernetes.io/unschedulable`, next to the same message for the control plane node. Uncordon the worker and the Pod starts without any change to the Pod:

```sh
kubectl uncordon "$worker"
kubectl -n outpost get pod drifter -o wide
```

## Cordon in the wild

A cordoned node is often forgotten after maintenance. The symptom is a Pending Pod whose event names the `unschedulable` taint, and the fix is `kubectl uncordon`, not a toleration on the Pod. Nodes that fail health checks get other taints, such as `node.kubernetes.io/not-ready`, which the control plane adds and removes itself. Do not remove those by hand.

You can now hold a Pod back, release it, and close or open a node for new Pods. What remains is a method for finding out which of these applies when a Pod is stuck.

## Common pitfalls

> [!WARNING]
> Scheduling gates can only be removed after creation, never added. A gated Pod has no scheduler events, so empty events are not a sign of a healthy scheduler. Cordon does not move running Pods; drain does. Never add a toleration for `node.kubernetes.io/unschedulable` to a Pod to bypass a forgotten cordon: uncordon the node.
