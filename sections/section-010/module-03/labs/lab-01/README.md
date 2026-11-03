---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Stage A StatefulSet Update With A Partition

Update two of four StatefulSet Pods to a new image and keep the other two on the old image.

UNTESTED: not yet run against a live environment. Static checks only: `astrona validate -c`, `bash -n` and a Python compile check. The task uses its own pinned kind cluster. To test it, start the lab and run `testing/smoke.sh` with its private kubeconfig. Runtime verification is pending.
