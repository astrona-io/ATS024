---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Make The Budget And The Autoscaler Agree Solution

> UNTESTED: not yet run against a live environment. The steps describe what to expect, not recorded output.

Solve this lab in a host shell. Each step ends with `astrona submit`. The flag `--keep` keeps the lab running, so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-04/labs/lab-01
```

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-04-01" || exit 1
```

## Step 1: Read the budget

Read the allowed disruptions of the budget and the bounds of the HPA:

```sh
kubectl -n starfleet get pdb scout
kubectl -n starfleet get hpa scout
```

The column for allowed disruptions shows 0. With two ready Pods and `minAvailable: 2`, no Pod can be evicted.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-04/labs/lab-01 --keep
```

The checks for the minimum, for three ready replicas and for the allowed disruptions fail.

## Step 2: Raise the HPA minimum

Change the minimum of the existing HPA. A merge patch edits one field and keeps the rest:

```sh
kubectl -n starfleet patch hpa scout --type=merge -p '{"spec":{"minReplicas":3}}'
kubectl -n starfleet wait --for=jsonpath='{.status.readyReplicas}'=3 deployment/scout --timeout=240s
```

The HPA raises the Deployment to three replicas, and the budget then allows one disruption. Check it:

```sh
kubectl -n starfleet get pdb scout
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-04/labs/lab-01 --keep
```

All checks pass.

After you record your result, remove the lab:

```sh
astrona destroy ats-024-lab-030-04-01
```

## Common pitfalls

> [!WARNING]
> Check the context name before every change. Edit the existing objects instead of deleting and recreating them, because the grader compares object identifiers with the starting state.
