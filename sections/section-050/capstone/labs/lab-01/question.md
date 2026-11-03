---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Place A Restricted Workload On A Dedicated Pool — Task

UNTESTED: not yet run against a live environment.

The cluster has two worker nodes reserved for the `scout` workload. Both carry the label `pool=dedicated` and the taint `dedicated=scout:NoSchedule`, and each has a zone label `topology.kubernetes.io/zone` (`zone-a` and `zone-b`). The Deployment `scout` in `starfleet` has four replicas and no Pod is running. The team also requires the Pod Security `restricted` level in this namespace.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-cap" || exit 1
```

## Required result

1. The namespace `starfleet` enforces the Pod Security level `restricted`.
2. Both workers accept new Pods. Keep their labels and their taint.
3. The Deployment `scout` tolerates the taint `dedicated=scout:NoSchedule` and requires nodes with `pool` in `dedicated`, using required node affinity.
4. Every container has a CPU and a memory request. The CPU request is at most `250m`.
5. A topology spread constraint spreads the `scout` Pods over the zone label with `maxSkew` 1 and `whenUnsatisfiable: DoNotSchedule`.
6. Four `scout` Pods are Running, two on each worker, and none on the control plane node. Every Pod meets the `restricted` level, and the Pod template sets a numeric user id.
7. Do not use `nodeName`, do not remove the taint or the labels, and keep four replicas.

## Verify The Result

The grader reads the namespace, the nodes, the Deployment and the Pods. Wait for the rollout to finish before you submit.
