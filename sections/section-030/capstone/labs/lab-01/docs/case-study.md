---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Starting Environment

The `starfleet` namespace has the Deployment `scout` with two replicas, an HPA named `scout` with a minimum of 2, a maximum of 4 and a CPU target of 60 percent, and a PodDisruptionBudget named `scout` that requires two available Pods. It also has the Pod `bridge` with a CPU request and limit of 100m and a memory request and limit of 64Mi. The HPA does not report measurements.
