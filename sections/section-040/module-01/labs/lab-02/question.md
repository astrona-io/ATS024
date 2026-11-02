---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Repair A Liveness Probe Port

Restore a valid health check while retaining restart protection and readiness. Use the isolated `starfleet` environment to verify the result.

## Objective

Restore a valid health check while retaining restart protection and readiness.

## Starting state

The application starts with an intentional liveness port error in its probe. Inspect the Pod events and the configured listener before changing the probe.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-040-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Repair the liveness probe on `probe` to HTTP path `/health`, named port `http`, period two seconds and failure threshold three. Keep the readiness probe on `/ready`, both replicas, the application and its Service. The healthy application must finish rolling out, then pass its health request. Do not remove the liveness probe to stop restarts.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
