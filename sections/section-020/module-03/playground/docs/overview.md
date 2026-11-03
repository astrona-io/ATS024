# Overview: Secret Types And Special Uses (Playground)

This is a playground, not a lab. It starts a fresh single-node `kind` cluster with Kubernetes 1.35 and then waits. There is no task, no `astrona submit` and no pass or fail. Create Secrets, break them, destroy the playground and start again.

## What is running

`kubectl` already points at the cluster as the cluster administrator. The cluster has two namespaces and two Deployments that run a `busybox` container which sleeps.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `probe` | A container you can use with `kubectl exec` and as a Secret consumer |
| `outpost` | Deployment `drifter` | A client that belongs to another team |

You need `openssl` on your machine for the TLS exercises. No Secret of your own exists yet.

## What to try

- Create a `kubernetes.io/basic-auth` Secret without the `password` key and read the error from the API server.
- Make a self-signed certificate with `openssl req -x509`, create a TLS Secret with `kubectl create secret tls` and mount it in a Pod with `defaultMode: 0400`.
- Create a registry Secret with `kubectl create secret docker-registry` and decode `.dockerconfigjson` to see the structure.
- Create a ServiceAccount with `imagePullSecrets` and prove with `--dry-run=server -o yaml` that a new Pod receives the list.
- Create a Role with `resourceNames` for one Secret and check it with `kubectl auth can-i --as=system:serviceaccount:starfleet:<name>`.
- Create a ServiceAccount token Secret with the annotation `kubernetes.io/service-account.name` and see which keys the control plane adds.
