---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Configure A Metrics-Backed Autoscaler Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-01-01" || exit 1
node_name="astro-ats-024-lab-030-01-01-control-plane"
worker_name="astro-ats-024-lab-030-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Create autoscaling/v2 HPA `probe` targeting Deployment probe, with minimum two replicas, maximum four and a 70 percent CPU utilization target. Preserve declared CPU requests. The autoscaler must report a current metric and ScalingActive True. Grade its measured state without assuming a precise instantaneous replica count.

Save this as `horizontalpodautoscaler-probe.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: probe
  namespace: starfleet
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: probe
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply the scoped correction:

```sh
kubectl apply -f horizontalpodautoscaler-probe.yaml
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet wait --for=condition=ScalingActive hpa/probe --timeout=240s
```

Declare a resource-utilization target and verify that the controller reads measurements. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-024-lab-030-01-01`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
