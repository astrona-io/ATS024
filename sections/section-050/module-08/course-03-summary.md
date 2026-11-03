---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

A PriorityClass maps a name to an integer. Pods that name the class get that number in `spec.priority`, which the `Priority` admission plugin sets. Higher numbers go first in the scheduling queue. User classes may use values up to one billion, and the built-in `system-cluster-critical` and `system-node-critical` classes use higher values. Only one class may have `globalDefault: true`, and it applies only to pods created after the class exists.

When a pod cannot be scheduled, the scheduler looks for a node where removing pods of lower priority would make room. It deletes those victims, records `nominatedNodeName` on the waiting pod and schedules the pod when the space is free. A class with `preemptionPolicy: Never` keeps its place in the queue but never removes other pods. Preemption respects graceful termination, and it tries to respect PodDisruptionBudgets but may break them when no other choice exists.

The quality of service (QoS) class is set by the API server from the requests and limits of the pod and is shown in `status.qosClass`. A pod is `Guaranteed` when every container has equal, non-zero CPU and memory requests and limits. It is `BestEffort` when no container sets any request or limit. Every other pod is `Burstable`. Priority and QoS class are independent settings.

Under node pressure the kubelet, not the scheduler, evicts pods. It ranks pods by whether their usage exceeds their requests, then by priority, then by how far usage is above the request. The kernel out-of-memory killer works separately and uses `oom_score_adj`, which the kubelet sets from the QoS class: `-997` for `Guaranteed`, `1000` for `BestEffort` and a value in between for `Burstable`.

Pod overhead adds a fixed amount of CPU and memory to a pod that uses a RuntimeClass with an `overhead` section. The scheduler and the ResourceQuota count the overhead together with the container requests.

<!-- astrona:playground:destroy -->
