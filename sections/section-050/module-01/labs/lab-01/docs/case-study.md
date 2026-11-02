---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Starting Environment

The Deployment template selects a node label that no node has. Replacement Pods cannot schedule, while older replicas may still respond.

Replace the impossible node selector on `probe` with `kubernetes.io/os: linux`. Keep two replicas, the application command, image, resources and readiness probe. The current generation must fully roll out and the original client must receive version one. Do not label a node to satisfy the intentional missing selector.
