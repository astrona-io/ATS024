# Question

Solve this question on: `terminal`

Scenario: the worker node must be drained for maintenance, but the `starfleet` namespace blocks it. Fix the disruption settings so that the drain can proceed one Pod at a time and a lost node is handled quickly. Repair the existing objects. Do not delete and recreate them, and do not change the replica counts.

Use the lab kubeconfig first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-04-01)"
```

1. The PodDisruptionBudget `scout-pdb` protects the 3-replica Deployment `scout`. Today it allows no voluntary disruption at all. Change it so that exactly one `scout` Pod can be evicted at a time and at least 2 stay available.

2. The PodDisruptionBudget `probe-pdb` must protect the 2 Pods of the Deployment `probe` and allow one disruption. Today it selects no Pod. Correct it. Keep it requiring at least 1 available Pod.

3. The `scout` Pods must leave a node that is not ready or unreachable after 30 seconds instead of the default of 300 seconds. Add the matching tolerations to the Pod template of `scout`.

4. The `scout` Pods must prefer different nodes. Add a topology spread constraint to the Pod template of `scout` on the node name label with a maximum skew of 1. It must not stop a Pod from being scheduled when it cannot be satisfied.

All 3 `scout` Pods and both `probe` Pods must be ready when you finish.
