---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Capstone: Recover From A Faulty Update And Ship A Safe Release

UNTESTED: not yet run against a live environment.

Roll back a faulty update, make the Deployment strategy safe and ship version v2 with a recorded change cause.

## Starting state

The `probe` Deployment in `starfleet` serves `v1` and was updated to an image tag that does not exist. Its strategy is `Recreate`, so the update removed every working Pod first, and the `probe` Service now has no backends. The `shuttle` Pod is a client in the same namespace. The Deployment is revision 2, and revision 1 is the last working template.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-cap" || exit 1
```

Keep this connection selected for every command.

## Required result

Restore service by rolling back to revision 1 with the rollout history. Then change the strategy to `RollingUpdate` with `maxSurge: 1` and `maxUnavailable: 0`, and set `minReadySeconds: 5`, `progressDeadlineSeconds: 120` and `revisionHistoryLimit: 5`. Finally ship version v2: set the annotation `kubernetes.io/change-cause` to a short text and then set `VERSION=v2` so that the new revision carries the cause. The image must be `docker.io/library/python:3.13-alpine`. The rollout must finish with two updated, ready and available replicas, the Deployment must not be paused, and `shuttle` must receive `version=v2` through the `probe` Service. Keep two replicas, the readiness probe and the Service.

## Verify the result

The grader checks the object fields and the running behavior. Wait for controller convergence before you submit.
