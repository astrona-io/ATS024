# Question

Solve this question on: `terminal`

Use the lab's private kubeconfig. A kubeconfig tells `kubectl` which cluster and credentials to use.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-040-02-01" || exit 1
```

The nightly scan of the fleet in `starfleet` did not run. The Job `scan-report` failed on its first attempt and gave up, and the CronJob `fleet-report` has not started anything. Repair both. Keep the container image and the command of both workloads.

1. The Job `scan-report` must finish successfully. A failed attempt must be retried inside the same Pod (`backoffLimit` of at least 1). The finished Job must remove itself automatically after a delay between 900 and 86400 seconds.

2. The CronJob `fleet-report` must never start a run while the previous run is still active. It must not be suspended. A run that cannot start within 30 to 300 seconds after its scheduled time must be skipped, so set `startingDeadlineSeconds` in that range. It must keep at most 3 finished successful Jobs and at most 3 finished failed Jobs.

Do not delete and recreate the CronJob. A Job pod template cannot be edited, so the Job has to be deleted and created again.
