---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Roll Back To A Specific Revision Solution

UNTESTED: not yet run against a live environment.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-02-01" || exit 1
```

Keep this connection selected for every command.

## Find the target revision

Show the history, then read the template of each candidate revision:

```sh
kubectl -n starfleet rollout history deployment/probe
kubectl -n starfleet rollout history deployment/probe --revision=2
```

Each history line shows a revision number and its change cause. The single-revision output shows the Pod template, including the `VERSION` environment variable. Revision 2 has `VERSION=v2` and the working image. Revision 4 shows the image tag that cannot be pulled, which is why its Pods stay in `ImagePullBackOff` while the older Pods keep serving.

## Roll back

The `rollout undo` command copies the template of the named revision into the Deployment. The Deployment controller then performs a rolling update back to it:

```sh
kubectl -n starfleet rollout undo deployment/probe --to-revision=2
kubectl -n starfleet rollout status deployment/probe --timeout=180s
```

The revision 2 ReplicaSet now holds the next revision number, so the history shows it as the newest line.

## Verify the result

Check the history and the version the Service returns:

```sh
kubectl -n starfleet rollout history deployment/probe
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

The response must contain `version=v2`. Plain `rollout undo` without `--to-revision` would have returned to revision 3, which serves `v3`.

After you record your result, remove the lab with `astrona destroy ats-024-lab-010-02-01`.

## Common pitfalls

> [!WARNING]
> Confirm the context before you change anything. A matching field alone does not prove the behavior, so always check the version that the Service returns. Keep every object that the task does not name.
