---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Question

Solve this question on: `terminal`

Use the lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-040-03-01" || exit 1
```

Two workloads in the cluster misbehave. Fix both. Do not delete the Deployment `bridge`, and keep the commands of the containers.

1. The Deployment `bridge` in `starfleet` has two replicas, and every Pod is in `CrashLoopBackOff`. The `bridge` container refuses to start unless the file `/work/config.txt` exists, and nothing creates that file. The `work` volume is an `emptyDir` that the container already mounts at `/work`. Make the Pods start by writing the file before the main container starts. The step that writes it must run once to completion and must not keep running. When you finish, both replicas must be ready.

2. The Pod `drifter-survey` in `outpost` runs a one-time task that exits with code 0. It restarts again and again because of its `restartPolicy`. Change the Pod so the kubelet does not restart the container after a successful exit, and so the task ends in the phase `Succeeded`. Keep the container name, image and command.

Scenario: the `bridge` service and the `drifter` survey task must both be healthy before the next patrol.
