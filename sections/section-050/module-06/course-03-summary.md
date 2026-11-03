---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

A resource request is the amount of CPU or memory that the scheduler reserves for a container on a node. A resource limit is the maximum that the kubelet and the container runtime allow the container to use. The two have different jobs: requests decide placement, and limits decide what happens at run time.

CPU is a compressible resource. A container that reaches its CPU limit is throttled by the kernel and keeps running more slowly. Memory is not compressible. A container that tries to use more memory than its limit is killed by the kernel out-of-memory killer, and the kubelet records the reason `OOMKilled` and restarts the container according to the restart policy.

A LimitRange works inside one namespace and acts when a pod is created. It fills in a default request and a default limit for containers that set none, and it rejects containers whose values are below the minimum, above the maximum or beyond the allowed ratio of limit to request. It does not change pods that already exist.

A ResourceQuota also works inside one namespace. It caps the sum of requests and limits of all pods, and it caps the number of objects of a kind. When a quota covers CPU or memory, every new pod must state that resource, and a LimitRange default is the usual way to make that true. A request that would take the namespace over a quota is rejected with a `403 Forbidden` error that names the quota, the amount requested, the amount used and the limit. Scopes narrow a quota to a class of pods, for example pods that are not best effort or pods that use a given priority class.

Both objects are enforced by admission plugins in the API server. When a workload creates no pods, the events of the controller that owns the pods show the rejection text, and that text names the rule to change.

<!-- astrona:playground:destroy -->
