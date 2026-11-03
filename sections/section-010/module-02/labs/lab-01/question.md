---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Roll Back To A Specific Revision

UNTESTED: not yet run against a live environment.

Return a faulty Deployment to the revision that served version v2.

## Starting state

The `probe` Deployment in `starfleet` has four revisions. Revision 1 serves `v1`. Revision 2 serves `v2` and was the last release that users verified. Revision 3 serves `v3` and returns wrong data although it passes readiness. Revision 4 also points at an image tag that does not exist, so its new Pods cannot start. The `shuttle` Pod is a client in the same namespace.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-02-01" || exit 1
```

Keep this connection selected for every command.

## Required result

Roll `probe` back to the revision that serves `v2`. Do not delete or recreate the Deployment. The current template must have container `probe` with image `docker.io/library/python:3.13-alpine` and the environment variable `VERSION=v2`. The rollout must finish with two updated, ready and available replicas. The Deployment must not be paused, and it must keep its revision history. The `shuttle` client must receive `version=v2` through the `probe` Service on port 80.

## Verify the result

The grader checks the object fields and the running behavior. Wait for controller convergence before you submit.
