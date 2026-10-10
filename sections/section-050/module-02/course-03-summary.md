---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Admission can supply defaults or reject unsuitable declarations before ordinary placement. Resource and security policies have distinct contracts and modes.

The effective admitted workload determines later allocation and runtime behavior. Policy acceptance does not guarantee useful capacity, and scheduling failure cannot repair a request that was never admitted.
