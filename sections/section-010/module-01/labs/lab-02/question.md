---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Recover A Failed Deployment Update

The `starfleet` application needs this task completed in its isolated lab environment.

## Objective

Restore two available replicas by correcting a failed Deployment image update.

## Starting state

The application first becomes healthy. Bootstrap then changes its image to a nonexistent tag. Existing replicas may still serve requests while the new template cannot start. A working response alone does not prove that the update completed.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-01-02" || exit 1
```

Keep this connection selected for every command below.

## Required result

Keep the `probe` Deployment in `starfleet`, its two replicas, labels, command, configuration and Service. Restore container `probe` to image `docker.io/library/python:3.13-alpine`. The current generation must finish rolling out with exactly two updated, ready and available replicas. The `shuttle` client must receive `version=v1` through the `probe` Service on port 80.

## Verify the result

Inspect the required fields and observe the actual result. The grader checks both the resource contract and the running behavior. Wait for controller convergence before submitting.
