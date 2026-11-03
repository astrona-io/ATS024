# Overview: Resource Quotas And Limit Ranges (Playground)

This is a playground, not a lab. It starts a cluster and waits. There is no task, no `astrona submit` and no pass or fail. Break things, run `astrona destroy` and start again.

## What is running

- A Kubernetes 1.35 `kind` cluster with one control plane node and one worker node. `kubectl` points at it as the cluster administrator.
- In `starfleet`: the Deployments `scout` (two replicas), `probe` and `shuttle`. In `outpost`: the Deployment `drifter`. Every container runs `sleep` and sets no resource requests or limits.
- No LimitRange and no ResourceQuota exist yet.

## Things to try

- Run a pod with a memory limit smaller than its use and read `OOMKilled` in its status.
- Add a LimitRange to `outpost`, delete the `drifter` pod and read the defaults on the new pod.
- Add a ResourceQuota with `requests.cpu` to `outpost` before you add a LimitRange, then scale `drifter` and read the events of its ReplicaSet.
- Add `count/deployments.apps` to a quota and create one Deployment too many.
- Create a pod with a CPU limit above the LimitRange `max` and read the error text.
