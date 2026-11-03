---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Capstone: Recover From A Faulty Update And Ship A Safe Release

Roll back a faulty update, make the Deployment strategy safe and ship version v2 with a recorded change cause.

UNTESTED: not yet run against a live environment. Static checks only: `astrona validate -c`, `bash -n` and a Python compile check. The task uses its own pinned kind cluster. To test it, start the lab and run `testing/smoke.sh` with its private kubeconfig. Runtime verification is pending.
