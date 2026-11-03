---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Repair And Tune A Broken Autoscaler Solution

> UNTESTED: not yet run against a live environment. The steps describe what to expect, not recorded output.

Solve this lab in a host shell. Each step ends with `astrona submit`. The flag `--keep` keeps the lab running, so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01
```

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-02-01" || exit 1
```

## Step 1: Read the HPA status

Describe the HPA and read the `ScalingActive` condition and its message:

```sh
kubectl -n starfleet describe hpa scout
```

The message names the cause. A CPU utilization target is a percentage of the request, so the container needs a request.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01 --keep
```

The checks for the CPU request and for `ScalingActive` still fail. The object checks for kept objects pass.

## Step 2: Give the Deployment a CPU request

Set the requests on the container. This starts a rollout, so wait for it:

```sh
kubectl -n starfleet set resources deployment scout --requests=cpu=50m,memory=32Mi
kubectl -n starfleet rollout status deployment/scout
```

The HPA needs a minute or two to read the new Pods. Check the condition again with `kubectl -n starfleet describe hpa scout`.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01 --keep
```

The checks `scout container requests CPU` and `HPA scout reports ScalingActive` now pass. The behavior checks still fail.

## Step 3: Add the behavior and the new maximum

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
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  behavior:
    scaleUp:
      policies:
      - type: Pods
        value: 2
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 600
      policies:
      - type: Pods
        value: 1
        periodSeconds: 120
```

Apply it. This edits the existing HPA, so its identifier does not change:

```sh
kubectl apply -f horizontalpodautoscaler-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet get hpa scout -o yaml
```

The `spec.behavior` block lists both directions.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01 --keep
```

All checks pass when the HPA still reports a current utilization.

After you record your result, remove the lab:

```sh
astrona destroy ats-024-lab-030-02-01
```

## Common pitfalls

> [!WARNING]
> Check the context name before every change. Edit the existing objects instead of deleting and recreating them, because the grader compares object identifiers with the starting state.
