---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Release Pending Pods

UNTESTED: not yet run against a live environment.

In `starfleet`, the Deployment `probe` (two replicas) and the Pod `shuttle` are all Pending. More than one cause is involved. Find each cause from the status and the events and fix it.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-05-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-05-01" || exit 1
```

## Required result

- The worker node accepts new Pods again.
- The Deployment `probe` uses the default scheduler, keeps two replicas and has both available. Its Pod template must not set `nodeName`.
- The Pod `shuttle` is Running. Keep the original Pod: do not delete and recreate it, and do not set `nodeName`.
- Do not add tolerations to bypass a node taint, and do not scale the Deployment down.

## Verify The Result

The grader reads the node, the Deployment and the Pods. Wait for the rollout to finish before you submit.
