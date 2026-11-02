---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Configure A Metrics-Backed Autoscaler

Declare a resource-utilization target and verify that the controller reads measurements.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-01-01" || exit 1
node_name="astro-ats-024-lab-030-01-01-control-plane"
worker_name="astro-ats-024-lab-030-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Create autoscaling/v2 HPA `probe` targeting Deployment probe, with minimum two replicas, maximum four and a 70 percent CPU utilization target. Preserve declared CPU requests. The autoscaler must report a current metric and ScalingActive True. Grade its measured state without assuming a precise instantaneous replica count.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
