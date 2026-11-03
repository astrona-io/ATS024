---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Repair Required Node Affinity

UNTESTED: not yet run against a live environment.

The `scout` Deployment in `starfleet` must run on nodes with fast disks, but its Pods are Pending. Fix the Deployment without changing any node label.

Use the private kubeconfig for this environment:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-03-01" || exit 1
```

## Required result

- Keep the Deployment `scout` with two replicas and its container. Do not delete the Deployment.
- Replace the required node affinity so that a node is eligible when its `disk` label is `ssd` or `nvme` (operator `In`) and its `tier` label is not `spot` (operator `NotIn`).
- Add one preferred node affinity rule with a weight of at least 1 that prefers nodes where the `gpu-count` label is greater than 1 (operator `Gt`, value `"1"`).
- Both replicas must be Running on a node.
- Use node affinity only: no `nodeSelector`, no `nodeName`, and no change to the labels of any node.

## Verify The Result

The grader reads the Deployment, the Pods and the node labels. Wait for the rollout to finish before you submit.
