# Overview: Projected Volumes, The Downward API And Configuration Patterns (Playground)

This is a playground, not a lab. It starts a fresh single-node `kind` cluster with Kubernetes 1.35 and then waits. There is no task, no `astrona submit` and no pass or fail. Create Pods, break them, destroy the playground and start again.

## What is running

`kubectl` already points at the cluster as the cluster administrator. The cluster has two namespaces and two Deployments that run a `busybox` container which sleeps.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `probe` | Has the labels `app=probe` and `tier=scout`, a CPU limit of `500m` and a memory limit of `128Mi` |
| `outpost` | Deployment `drifter` | A client that belongs to another team, with no resource limits |

No ConfigMap or Secret of your own exists yet.

## What to try

- Merge a ConfigMap, a Secret and a downward API item into one projected volume and list the files with `kubectl exec`.
- Add a `serviceAccountToken` source with `expirationSeconds: 600` and read the token file twice, some minutes apart.
- Read the projected volume that every Pod already has, with `kubectl get pod -o yaml`, and find its three sources.
- Expose `status.podIP` as a variable and try the same field in a volume. Read the error from the API server.
- Change a label of the `probe` Pod and compare a variable with a file.
- Use `$(VAR)` in `args` and look at the log of a Pod with `restartPolicy: Never`.
- Create an `immutable: true` ConfigMap and try to edit one key.
