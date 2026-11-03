---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Build A Kustomize Production Overlay

UNTESTED: not yet run against a live environment.

Deploy an application from a Kustomize base with a production overlay.

## Starting state

The `outpost` namespace exists and is empty. The task gives you a base Deployment named `beacon` that you must create as files in your shell. It has one replica, the label `app: beacon`, one container named `beacon` with the image `docker.io/library/busybox:1.36.1` and the command `sh -c "sleep 3600"`. It names no namespace.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-04-01" || exit 1
```

Keep this connection selected for every command.

## Required result

Create a Kustomize base in `kustomize/base` with the Deployment and its `kustomization.yaml`. Create an overlay in `kustomize/overlays/prod` that uses the base and sets the namespace `outpost`, the name prefix `prod-`, the label `env: prod` on the Deployment and on its Pod template (not on its selector), the image tag `1.37.0` with the `images` transformer, and three replicas with the `replicas` transformer. Apply the overlay with `kubectl apply -k`. The Deployment `prod-beacon` in `outpost` must have three updated, ready and available replicas running `docker.io/library/busybox:1.37.0`. A Deployment named `beacon` must not exist.

## Verify the result

The grader checks the object fields and the running behavior. Wait for controller convergence before you submit.
