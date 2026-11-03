# Overview: Create ConfigMaps And Secrets And Inject Environment Variables (Playground)

This is a playground, not a lab. It starts a fresh single-node `kind` cluster with Kubernetes 1.35 and then waits. There is no task, no `astrona submit` and no pass or fail. Create objects, break them, destroy the playground and start again.

## What is running

`kubectl` already points at the cluster as the cluster administrator. The cluster has two namespaces and two client Deployments that run a `busybox` container which sleeps.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `shuttle` | A client container you can use with `kubectl exec` |
| `outpost` | Deployment `drifter` | A client that belongs to another team |

No ConfigMap or Secret of your own exists yet.

## What to try

- Create ConfigMaps with `--from-literal`, `--from-file` and `--from-env-file`, and compare the keys with `kubectl get configmap <name> -o yaml`.
- Generate a Secret manifest with `--dry-run=client -o yaml`, add `immutable: true`, apply it and try to change a value.
- Run a Pod that imports a ConfigMap with `envFrom` and `prefix`, and print the environment with `kubectl exec <pod> -- printenv`.
- Reference a key that does not exist and read the status `CreateContainerConfigError` in `kubectl describe pod`.
- Mount one key with `items` and `subPath`, change the ConfigMap, and see which path follows the change.
- Try to read a ConfigMap of `starfleet` from a Pod in `outpost` and note why the reference fails.
