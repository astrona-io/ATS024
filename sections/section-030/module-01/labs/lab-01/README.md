---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Configure A Metrics-Backed Autoscaler

Declare a resource-utilization target and verify that the controller reads measurements.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.
