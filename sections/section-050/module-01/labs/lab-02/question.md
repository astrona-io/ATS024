---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Tolerate A Dedicated Worker Taint

Make a workload eligible for a deliberately tainted worker without removing the taint.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-01-02" || exit 1
node_name="astro-ats-024-lab-050-01-02-control-plane"
worker_name="astro-ats-024-lab-050-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Keep the worker taint training.astrona.io/dedicated=report:NoSchedule. Create Pod taint-reader with the matching Equal toleration and node selector naming that worker. It must become Ready on the worker. Do not remove the taint or assign spec.nodeName to bypass scheduling.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
