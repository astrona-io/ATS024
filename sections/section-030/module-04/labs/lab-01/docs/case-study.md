---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Starting Environment

The `starfleet` namespace has the Deployment `scout` with two replicas, an HPA named `scout` with a minimum of 2 and a maximum of 4, and a PodDisruptionBudget named `scout` that requires at least two available Pods. The budget allows no disruption.
