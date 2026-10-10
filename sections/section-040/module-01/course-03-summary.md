---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Summary

Reconciliation restores declared resource relationships, while health checks connect observed conditions to specific eligibility or restart actions. Neither mechanism universally proves application correctness.

Self-healing depends on suitable desired state, usable capacity and meaningful checks. Repeated replacement cannot repair every invalid configuration or shared dependency, so failure evidence must guide the correction.
