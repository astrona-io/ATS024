---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Recover A Failed Deployment Update

Restore two available replicas by correcting a failed Deployment image update. This independent graded environment is separate from the module playground.

Author checks: run `astrona validate -c ATS001/sections/section-020/module-04/labs/lab-01` from the workspace. In a fresh lab, run `testing/smoke.sh` with its private kubeconfig to confirm that the initial state fails, the reference solution passes and convergence completes. The grader requires Python 3 on the host.

Runtime verification is pending. Static checks and offline grader tests do not prove cluster execution.
