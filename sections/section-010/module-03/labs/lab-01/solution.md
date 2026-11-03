---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Stage A StatefulSet Update With A Partition Solution

UNTESTED: not yet run against a live environment.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-03-01" || exit 1
```

Keep this connection selected for every command.

## Understand the order

A StatefulSet replaces Pods from the highest ordinal down and only for ordinals at or above `spec.updateStrategy.rollingUpdate.partition`. With `partition: 2` and four Pods, `crew-3` and `crew-2` are updated and `crew-1` and `crew-0` are not. If the template changed first and the partition second, the controller could update all four Pods in between, so both fields change in one request.

## Save the change

Save this as `statefulset-crew-patch.yaml`:

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2
  template:
    spec:
      containers:
      - name: crew
        image: docker.io/library/busybox:1.37.0
```

Apply it:

```sh
kubectl -n starfleet patch statefulset crew --patch-file statefulset-crew-patch.yaml
kubectl -n starfleet rollout status statefulset/crew --timeout=180s
```

For a partitioned update the status command reports when the Pods at or above the partition are updated and then ends.

## Verify the result

List the image of each Pod and the revision fields of the StatefulSet:

```sh
kubectl -n starfleet get pods -l app=crew -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.containers[0].image}{"\n"}{end}'
kubectl -n starfleet get statefulset crew -o jsonpath='{.status.currentRevision}{" "}{.status.updateRevision}{"\n"}'
```

`crew-2` and `crew-3` show the new image, and the two revision names differ because the old revision is still in use.

After you record your result, remove the lab with `astrona destroy ats-024-lab-010-03-01`.

## Common pitfalls

> [!WARNING]
> Confirm the context before you change anything. A matching field alone does not prove the behavior, so always check the version that the Service returns. Keep every object that the task does not name.
