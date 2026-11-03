---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Replace Anti-Affinity With A Spread Constraint

UNTESTED: not yet run against a live environment.

The `probe` Deployment in `starfleet` has three replicas. Only two are Running, because a required Pod anti-affinity rule allows one Pod per zone and the cluster has two zones. The replicas must still be spread over the zones, but a split of two and one is acceptable.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-04-01" || exit 1
```

## Required result

- Keep the Deployment `probe` with three replicas and its container. Do not delete it.
- Remove the required Pod anti-affinity rule.
- Add a topology spread constraint on `topology.kubernetes.io/zone` with `maxSkew: 1` and `whenUnsatisfiable: DoNotSchedule`. Its selector must match the `probe` Pods, and it must list `pod-template-hash` in `matchLabelKeys`.
- All three replicas must be Running, on both workers, split two and one.
- Do not change the node labels and do not set `nodeName`.

## Verify The Result

The grader reads the Deployment, the Pods and their nodes. Wait for the rollout to finish before you submit.
