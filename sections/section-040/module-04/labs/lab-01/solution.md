# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output below is described in words, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-04/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-04-01)"
```

`astrona submit` right after the start shows the workload check passing and the other checks failing.

## Step 1: Find why scout-pdb allows no disruption

```sh
kubectl -n starfleet get pdb
```

The column `ALLOWED DISRUPTIONS` is 0 for `scout-pdb`, because it has `minAvailable: 3` and the Deployment has 3 replicas. `EXPECTED PODS` for `probe-pdb` is 0, because its selector matches no Pod. Compare it with the Pod labels:

```sh
kubectl -n starfleet get pods --show-labels
```

The `probe` Pods carry the label `app=probe`, and `probe-pdb` selects `app=probe-old`.

## Step 2: Fix both budgets

A budget accepts `minAvailable` or `maxUnavailable`, never both. Save this as `pdb-fix.yaml`:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: scout-pdb
  namespace: starfleet
  annotations:
    lab.astrona.io/seeded: "true"
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: scout
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: probe-pdb
  namespace: starfleet
  annotations:
    lab.astrona.io/seeded: "true"
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: probe
```

Apply it:

```sh
kubectl apply -f pdb-fix.yaml
```

Then check the result:

```sh
kubectl -n starfleet get pdb
```

Both budgets now show `ALLOWED DISRUPTIONS` 1, and `probe-pdb` shows 2 expected Pods. Run `astrona submit --keep`. The two budget checks pass.

## Step 3: Add the tolerations and the spread constraint

Save this as `scout-patch.yaml`:

```yaml
spec:
  template:
    spec:
      tolerations:
      - key: node.kubernetes.io/not-ready
        operator: Exists
        effect: NoExecute
        tolerationSeconds: 30
      - key: node.kubernetes.io/unreachable
        operator: Exists
        effect: NoExecute
        tolerationSeconds: 30
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: scout
```

Apply it as a patch and wait for the rollout:

```sh
kubectl -n starfleet patch deployment scout --patch-file scout-patch.yaml
kubectl -n starfleet rollout status deployment/scout
```

The Pod template changed, so the Deployment starts a rolling update. When the command returns, all 3 new Pods are ready. Run `astrona submit`. All checks pass.

## Why this is the answer

`disruptionsAllowed` is the number of healthy Pods minus the number the budget requires, so `minAvailable: 3` with 3 Pods gives 0. The selector decides which Pods count, so a selector that matches nothing protects nothing. The tolerations replace the 300 seconds that the API server would otherwise add. `ScheduleAnyway` keeps the spread a preference, so a Pod still starts when only one worker node exists.
