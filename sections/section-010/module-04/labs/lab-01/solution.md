---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Build A Kustomize Production Overlay Solution

UNTESTED: not yet run against a live environment.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-04-01" || exit 1
```

Keep this connection selected for every command.

## Write the base

Create the directories:

```sh
mkdir -p kustomize/base kustomize/overlays/prod
```

Save this as `kustomize/base/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: beacon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: beacon
  template:
    metadata:
      labels:
        app: beacon
    spec:
      containers:
      - name: beacon
        image: docker.io/library/busybox:1.36.1
        command: ["sh", "-c", "sleep 3600"]
```

Save this as `kustomize/base/kustomization.yaml`:

```yaml
resources:
- deployment.yaml
```

## Write the overlay

The overlay sets every environment difference. The `images` transformer matches the image name without its tag, and the `replicas` transformer matches the base name `beacon`, not the prefixed name. Save this as `kustomize/overlays/prod/kustomization.yaml`:

```yaml
resources:
- ../../base
namespace: outpost
namePrefix: prod-
labels:
- pairs:
    env: prod
  includeTemplates: true
images:
- name: docker.io/library/busybox
  newTag: "1.37.0"
replicas:
- name: beacon
  count: 3
```

## Preview and apply

Render the result first. Check the name, namespace, replicas, image and labels:

```sh
kubectl kustomize kustomize/overlays/prod
```

Apply it:

```sh
kubectl apply -k kustomize/overlays/prod
kubectl -n outpost rollout status deployment/prod-beacon --timeout=180s
```

## Verify the result

```sh
kubectl -n outpost get deployment --show-labels
kubectl -n outpost get deployment prod-beacon -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Only `prod-beacon` is listed, and its image tag is `1.37.0`.

After you record your result, remove the lab with `astrona destroy ats-024-lab-010-04-01`.

## Common pitfalls

> [!WARNING]
> Confirm the context before you change anything. A matching field alone does not prove the behavior, so always check the version that the Service returns. Keep every object that the task does not name.
