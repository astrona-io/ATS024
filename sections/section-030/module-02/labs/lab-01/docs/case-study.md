---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Starting Environment

The `starfleet` namespace has the Deployment `scout` with two replicas and an HPA named `scout` with a minimum of 2, a maximum of 4 and a CPU target of 60 percent. The HPA reports no measurements. The metrics server is running. The namespace `outpost` has an unrelated client Pod.
