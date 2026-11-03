---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Repair Required Node Affinity Solution

UNTESTED: not yet run against a live environment.

Use the private kubeconfig for this environment:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-03-01" || exit 1
```

## Step 1: Find why the Pods are Pending

Compare the node labels with the Pod events:

```sh
kubectl get nodes --show-labels
kubectl -n starfleet describe pods -l app=scout
```

The `FailedScheduling` event says that nodes did not match the Pod's node affinity. The Deployment requires `disk=nvme`, but the worker has `disk=ssd`. Run `astrona submit` now: the affinity checks fail and the Pods check fails.

## Step 2: Replace the affinity

Save this as `deployment-scout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disk
                operator: In
                values: ["ssd", "nvme"]
              - key: tier
                operator: NotIn
                values: ["spot"]
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 50
            preference:
              matchExpressions:
              - key: gpu-count
                operator: Gt
                values: ["1"]
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

## Step 3: Check the rollout

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=120s
kubectl -n starfleet get pods -l app=scout -o wide
```

Both Pods run on the worker. Run `astrona submit`: every check passes.

Remove the environment with `astrona destroy ats-024-lab-050-03-01`.

## Common pitfalls

> [!WARNING]
> Do not label the worker `disk=nvme` to make the old rule match. That hides the fault and the grader checks the labels. Terms are joined with OR and expressions in one term with AND, so keep both requirements in one term.
