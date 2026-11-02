---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Summary

Autoscaling links meaningful metrics to desired replica count within configured bounds. Metric availability, requests and stabilization affect the actual controller decision.

Desired replicas still need placement, preparation and readiness. Additional frontends do not universally repair a shared dependency bottleneck, and workload scaling is separate from infrastructure capacity scaling.

Availability depends on useful replicas and resilient dependencies, not on desired replica count alone.
