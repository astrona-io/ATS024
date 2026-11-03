# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The `scout` Deployment in `starfleet` is a critical service, but its pod stays `Pending` because the `drifter` Deployment in `outpost` uses most of the CPU of the worker node. The `drifter` workload is less important, but it must not be deleted, scaled down or changed.

1. Create the PriorityClass `critical-service` with the value `100000`. It must not be the global default.
2. Make `scout` use that class so that the scheduler makes room for it. The pod must run.
3. Make the `scout` pod `Guaranteed`: set limits equal to requests for CPU and memory. Keep the existing CPU request value (`64Mi` is the memory request).

The original CPU values of both Deployments are stored in the ConfigMap `seed` in `outpost`. `kubectl` already points at the cluster as the cluster administrator.
