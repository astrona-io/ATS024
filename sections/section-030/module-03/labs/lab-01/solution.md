---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Resize A Running Pod And Scale A Deployment Solution

> UNTESTED: not yet run against a live environment. The steps describe what to expect, not recorded output.

Solve this lab in a host shell. Each step ends with `astrona submit`. The flag `--keep` keeps the lab running, so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01
```

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-03-01" || exit 1
```

## Step 1: Read the current values

Read what the container runs with now. The values in `status.containerStatuses` show what the kubelet applied:

```sh
kubectl -n starfleet get pod bridge -o jsonpath='{.status.containerStatuses[0].resources}'
kubectl -n starfleet get pod bridge -o jsonpath='{.status.qosClass}'
```

The first command prints a JSON object with the requests and limits. The second prints `Guaranteed`.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01 --keep
```

The resize checks fail, and the checks that compare the identifier, the restart count and the memory values already pass.

## Step 2: Resize the CPU through the resize subresource

Change the request and the limit in one patch. A patch on the normal Pod endpoint is refused for these fields, so the command names the subresource:

```sh
kubectl -n starfleet patch pod bridge --subresource resize --patch '{"spec":{"containers":[{"name":"bridge","resources":{"requests":{"cpu":"300m"},"limits":{"cpu":"300m"}}}]}}'
```

Then check the applied values and the restart count. The status should show 300m after a short time, and the restart count stays 0:

```sh
kubectl -n starfleet get pod bridge -o jsonpath='{.status.containerStatuses[0].resources}{"\n"}{.status.containerStatuses[0].restartCount}{"\n"}'
kubectl -n starfleet get pod bridge -o jsonpath='{.status.conditions[?(@.type=="PodResizePending")].status}'
```

The last command prints nothing when no resize is pending.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01 --keep
```

The checks for the CPU values, the pending condition, the identifier and the restart count pass. The check for three `scout` replicas still fails.

## Step 3: Scale the Deployment

Scale through the scale subresource and wait for the new Pod:

```sh
kubectl -n starfleet scale deployment scout --replicas=3
kubectl -n starfleet rollout status deployment/scout
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01 --keep
```

All checks pass.

After you record your result, remove the lab:

```sh
astrona destroy ats-024-lab-030-03-01
```

## Common pitfalls

> [!WARNING]
> Check the context name before every change. Edit the existing objects instead of deleting and recreating them, because the grader compares object identifiers with the starting state.
