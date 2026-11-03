---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Stage A StatefulSet Update With A Partition

UNTESTED: not yet run against a live environment.

Update two of four StatefulSet Pods to a new image and keep the other two on the old image.

## Starting state

The StatefulSet `crew` in `starfleet` has four Pods, `crew-0` to `crew-3`, that all run `docker.io/library/busybox:1.36.1`. All four are Ready. The update strategy is the default `RollingUpdate` with no partition.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-03-01" || exit 1
```

Keep this connection selected for every command.

## Required result

Update `crew` to the image `docker.io/library/busybox:1.37.0` as a staged update. Only `crew-2` and `crew-3` must run the new image. `crew-0` and `crew-1` must stay on `docker.io/library/busybox:1.36.1` and stay Ready. Set `partition: 2` in the same change as the new image so that no lower ordinal is ever updated. Keep four replicas, the `RollingUpdate` type, the container name `crew` and the headless Service. All four Pods must be Ready, and the status must show two updated replicas.

## Verify the result

The grader checks the object fields and the running behavior. Wait for controller convergence before you submit.
