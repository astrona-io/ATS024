---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Repair Readiness Without Removing It

Restore endpoint eligibility by repairing a readiness probe port. Use the isolated `starfleet` environment to verify the result.

## Objective

Restore endpoint eligibility by repairing a readiness probe port.

## Starting state

The application starts with an intentional readiness port error in its probe. Inspect the Pod events and the configured listener before changing the probe.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-040-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Repair the readiness probe on `probe` to HTTP path `/ready` and named port `http`. Keep the application command, image, two replicas and original Service. Both replicas must become ready and available. The original client must receive version one. Do not remove the readiness check.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
