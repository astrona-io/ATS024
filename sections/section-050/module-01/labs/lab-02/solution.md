---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Tolerate A Dedicated Worker Taint Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-01-02" || exit 1
node_name="astro-ats-024-lab-050-01-02-control-plane"
worker_name="astro-ats-024-lab-050-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Keep the worker taint training.astrona.io/dedicated=report:NoSchedule. Create Pod taint-reader with the matching Equal toleration and node selector naming that worker. It must become Ready on the worker. Do not remove the taint or assign spec.nodeName to bypass scheduling.

Save this as `pod-taint-reader.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: taint-reader
  namespace: starfleet
spec:
  restartPolicy: Never
  containers:
  - name: reader
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
  nodeSelector:
    kubernetes.io/hostname: astro-ats-024-lab-050-01-02-worker
  tolerations:
  - key: training.astrona.io/dedicated
    operator: Equal
    value: report
    effect: NoSchedule
```

Apply the scoped correction:

```sh
kubectl apply -f pod-taint-reader.yaml
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet wait --for=condition=Ready pod/taint-reader --timeout=180s
```

Make a workload eligible for a deliberately tainted worker without removing the taint. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-024-lab-050-01-02`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
