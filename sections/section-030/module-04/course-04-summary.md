---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Summary

The built-in HPA scales from resource, pod, object and external metrics, and its replica minimum is one unless the alpha feature gate `HPAScaleToZero` is on. A workload that reacts to a queue or another event source needs a signal that CPU does not give. KEDA adds that signal. Its `ScaledObject` names a target and one or more scalers, KEDA creates and owns an HPA for the range from one to the maximum, and it activates the workload from zero itself. Its metrics adapter serves the external metrics API that the HPA reads. A queue that is empty keeps the workload at zero, and the first message wakes it.

A node autoscaler reacts to Pods whose `PodScheduled` condition is `False` with the reason `Unschedulable`, not to CPU use. Cluster Autoscaler grows and shrinks groups of identical nodes. Karpenter reads the requirements of pending Pods and creates fitting nodes directly through the provider, and it consolidates lightly used nodes. Both size the cluster from requests, so a Pod without a request never triggers them, and a Pod that fits no node stays `Pending`. Each step in the chain from load to a ready Pod has a delay, and the node step is the slowest.

A PodDisruptionBudget limits voluntary disruptions that use the eviction API, such as a node drain and a node scale-down. It does not slow a rolling update, which follows `maxSurge` and `maxUnavailable`, and it does not stop a node crash or a manual delete. The allowed disruptions are the healthy Pods minus the desired healthy Pods. An HPA minimum equal to `minAvailable` allows none, so the minimum must be larger, or the budget must use `maxUnavailable`.

- Scale to zero needs either KEDA or an alpha feature gate.
- A node autoscaler cannot help a Pod that fits no node.
- A budget and an HPA minimum must leave room for one eviction.

<!-- astrona:playground:destroy -->
