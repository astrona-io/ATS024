---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Roll Back To A Specific Revision

Return a faulty Deployment to the revision that served version v2.

UNTESTED: not yet run against a live environment. Static checks only: `astrona validate -c`, `bash -n` and a Python compile check. The task uses its own pinned kind cluster. To test it, start the lab and run `testing/smoke.sh` with its private kubeconfig. Runtime verification is pending.
