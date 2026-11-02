---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Recover A Failed Deployment Update Solution

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-01-02" || exit 1
```

Keep this connection selected for every command below.

## Diagnose The Starting State

The application first becomes healthy. Bootstrap then changes its image to a nonexistent tag. Existing replicas may still serve requests while the new template cannot start. A working response alone does not prove that the update completed.

Inspect the relevant objects:

```sh
kubectl -n starfleet get deployment probe -o yaml
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
```

Compare the desired image in the Deployment template with Pod status and events. Correcting the image creates a new template revision. The Deployment controller replaces the failed revision and reports progress for the new generation. Keeping two replicas does not mean two replicas already run the current template.

Correct the image:

```sh
kubectl -n starfleet set image deployment/probe probe=docker.io/library/python:3.13-alpine
```

## Verify The Result

Observe the actual result with these bounded checks. No example transcript is provided as evidence of a completed run.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Keep the `probe` Deployment in `starfleet`, its two replicas, labels, command, configuration and Service. Restore container `probe` to image `docker.io/library/python:3.13-alpine`. The current generation must finish rolling out with exactly two updated, ready and available replicas. The `shuttle` client must receive `version=v1` through the `probe` Service on port 80.

After recording your result, remove this lab with `astrona destroy ats-024-lab-010-01-02`.

## Common pitfalls

> [!WARNING]
> Verify the lab context before making changes. A matching field alone does not prove the required behavior. Preserve the objects and access limits named in the task.
