# Question

Solve this question on: `terminal`

Run `export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-cap)"` first. This is the capstone for the section: one integrated task, no step-by-step guidance. The `starfleet` crew is preparing the cluster for a node upgrade. Make the workloads in `starfleet` resilient. Repair every object in place. Do not delete and recreate any of them, and do not scale `scout` below three replicas.

1. The Deployment `scout` must have three available replicas, and it must keep a readiness probe.

2. The PodDisruptionBudget `scout` must still protect the application, but it must allow one `scout` pod to be evicted at a time, with at least two pods always available.

3. The `scout` pods must be spread over different nodes. Use a topology spread constraint with a maximum skew of 1 that never blocks scheduling.

4. The Deployment `bridge` crash-loops because the file `/work/config.ready` does not exist. Do not change the `bridge` container. Make the Pod start on its own.

5. The CronJob `sweep` must never start a new Job while the previous one is still running. It must keep exactly one successful and one failed Job in its history, and each finished Job must remove itself after 120 seconds. Keep its schedule.
