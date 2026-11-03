---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Starting Environment

The `starfleet` namespace has the Pod `bridge` with one container that has a CPU request and limit of 100m and a memory request and limit of 64Mi. Its resize policy lets CPU change without a restart. It also has the Deployment `scout` with two replicas. No autoscaler manages `scout`.
