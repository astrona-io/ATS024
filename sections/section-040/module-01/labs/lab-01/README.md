---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Repair Readiness Without Removing It

Restore endpoint eligibility by repairing a readiness probe port. The task and reference solution use a separate pinned kind cluster. The grader checks declared fields and bounded live evidence. Python 3 is required on the grading host.

Run `testing/smoke.sh` with the lab's private kubeconfig to prove that the starting state fails and the reference repair passes. Each wait and request is bounded. Live verification is pending until actual container-engine execution is recorded. Static checks are not runtime evidence.
