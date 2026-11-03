---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Starting Environment

The `starfleet` namespace has a Deployment `scout` with two replicas. Its required node affinity names a disk type that no node has, so its Pods are Pending. The single worker node is labelled `disk=ssd`, `tier=compute` and `gpu-count=2`.
