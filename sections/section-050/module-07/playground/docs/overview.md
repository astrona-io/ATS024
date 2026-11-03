# Overview: Admission Controllers And ValidatingAdmissionPolicy (Playground)

This is a playground, not a lab. It starts a cluster and waits. There is no task, no `astrona submit` and no pass or fail.

## What is running

- A Kubernetes 1.35 `kind` cluster with one control plane node and one worker node. `kubectl` points at it as the cluster administrator.
- In `starfleet`: the Deployments `scout` (two replicas), `probe` and `shuttle`. In `outpost`: the Deployment `drifter`. Every Deployment carries the label `team`.
- No ValidatingAdmissionPolicy, no binding and no webhook configuration exist yet.

## Things to try

- Read the admission flags of the API server pod in `kube-system`.
- Create a pod with a missing priority class and read the rejection.
- Write a policy that limits Deployment replicas, bind it to `starfleet` with `Deny`, and scale `scout` above the limit.
- Change the binding to `Warn` and `Audit` and watch `kubectl` print a warning instead of an error.
- Write a policy that requires the label `team` on Deployments and test it with `--dry-run=server`.
- Remove the binding and prove that the policy no longer has any effect.
