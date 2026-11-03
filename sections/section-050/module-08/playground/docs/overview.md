# Overview: Priority, Preemption And Quality Of Service (Playground)

This is a playground, not a lab. It starts a cluster and waits. There is no task, no `astrona submit` and no pass or fail.

## What is running

- A Kubernetes 1.35 `kind` cluster with one control plane node and one worker node. Only the worker node runs the example workloads. `kubectl` points at it as the cluster administrator.
- In `starfleet`: the Deployments `scout` (two replicas), `probe` and `shuttle`. In `outpost`: the Deployment `drifter`. Their containers set no requests or limits, so their pods are `BestEffort`.
- No PriorityClass of your own and no RuntimeClass exist yet.

## Things to try

- Create PriorityClasses with different values and set one on `scout`. Read `spec.priority` on its pods.
- Create three pods with different requests and limits and read `status.qosClass`.
- Read `/proc/1/oom_score_adj` in a `Guaranteed` pod and in a `BestEffort` pod.
- Make a RuntimeClass with overhead and read `spec.overhead` on a pod that uses it.
- Fill the worker node with a Deployment that requests most of its CPU, start a pod with a higher priority and watch which pod is deleted. The command `kubectl describe node` shows the allocated requests of the worker node.
