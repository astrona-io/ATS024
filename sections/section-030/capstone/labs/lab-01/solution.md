---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Capstone: Autoscale, Resize And Protect A Workload Solution

> UNTESTED: not yet run against a live environment. The steps describe what to expect, not recorded output.

Solve this lab in a host shell. Each step ends with `astrona submit`. The flag `--keep` keeps the lab running, so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01
```

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-cap" || exit 1
```

## Step 1: Find why the HPA reports nothing

Describe the HPA and read the condition message. A utilization target needs a request on the container, so set one and wait for the rollout:

```sh
kubectl -n starfleet describe hpa scout
kubectl -n starfleet set resources deployment scout --requests=cpu=50m,memory=32Mi
kubectl -n starfleet rollout status deployment/scout
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01 --keep
```

The request check passes. The bound, behavior and budget checks still fail.

## Step 2: Set the bounds and the behavior

Save this as `horizontalpodautoscaler-scout.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scout
  namespace: starfleet
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scout
  minReplicas: 3
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 120
```

Apply it. The minimum of 3 lets the budget allow one disruption:

```sh
kubectl apply -f horizontalpodautoscaler-scout.yaml
kubectl -n starfleet wait --for=condition=ScalingActive hpa/scout --timeout=240s
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01 --keep
```

The checks for `ScalingActive`, the bounds and the behavior pass once the controller has read the new Pods.

## Step 3: Resize the bridge Pod and wait for the replicas

Resize CPU through the resize subresource, with request and limit together:

```sh
kubectl -n starfleet patch pod bridge --subresource resize --patch '{"spec":{"containers":[{"name":"bridge","resources":{"requests":{"cpu":"400m"},"limits":{"cpu":"400m"}}}]}}'
kubectl -n starfleet wait --for=jsonpath='{.status.readyReplicas}'=3 deployment/scout --timeout=240s
```

Then check the budget and the applied values:

```sh
kubectl -n starfleet get pdb scout
kubectl -n starfleet get pod bridge -o jsonpath='{.status.containerStatuses[0].resources}'
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01 --keep
```

All checks pass.

After you record your result, remove the lab:

```sh
astrona destroy ats-024-lab-030-cap
```

## Common pitfalls

> [!WARNING]
> Check the context name before every change. Edit the existing objects instead of deleting and recreating them, because the grader compares object identifiers with the starting state.
