---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Capstone: Recover From A Faulty Update And Ship A Safe Release Solution

UNTESTED: not yet run against a live environment.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-cap" || exit 1
```

Keep this connection selected for every command.

## Restore service

Read the history to confirm which revision worked, then roll back:

```sh
kubectl -n starfleet rollout history deployment/probe
kubectl -n starfleet rollout undo deployment/probe --to-revision=1
kubectl -n starfleet rollout status deployment/probe --timeout=180s
```

The Recreate strategy deletes the Pods that cannot start and creates Pods from the revision 1 template. The rollback itself creates revision 3. The history now has revisions 2 and 3.

## Make the strategy safe

The strategy, the deadline and the history limit are not part of the Pod template, so this change creates no revision. Save this as `deployment-probe-safety.yaml`:

```yaml
spec:
  minReadySeconds: 5
  progressDeadlineSeconds: 120
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Apply it:

```sh
kubectl -n starfleet patch deployment probe --patch-file deployment-probe-safety.yaml
```

The patch sets `type` and `rollingUpdate` together, which the API requires when it leaves Recreate.

## Ship v2 with a change cause

Annotate first, because a revision copies the annotation that exists when it is created. Then change the template:

```sh
kubectl -n starfleet annotate deployment/probe kubernetes.io/change-cause="Ship version v2 with a rolling update" --overwrite
kubectl -n starfleet set env deployment/probe VERSION=v2
kubectl -n starfleet rollout status deployment/probe --timeout=180s
```

The new Pods must stay ready for five seconds before the old Pods are removed, and one Pod at most is added at a time.

## Verify the result

```sh
kubectl -n starfleet rollout history deployment/probe
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

The history ends with the line that shows your change cause, and the response contains `version=v2`.

After you record your result, remove the lab with `astrona destroy ats-024-lab-010-cap`.

## Common pitfalls

> [!WARNING]
> Confirm the context before you change anything. A matching field alone does not prove the behavior, so always check the version that the Service returns. Keep every object that the task does not name.
