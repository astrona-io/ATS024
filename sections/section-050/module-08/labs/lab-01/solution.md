# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`.

Start the lab and point `kubectl` at it:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-08-01)"
```

## Step 1: Find why scout is Pending

```sh
kubectl -n starfleet describe pod -l app=scout
kubectl -n outpost get configmap seed -o jsonpath='{.data}{"\n"}'
```

The events show that no node has enough CPU. The second command shows the CPU requests of both Deployments.

## Step 2: Create the PriorityClass

Save this as `priorityclass-critical.yaml`:

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-service
value: 100000
globalDefault: false
description: "Services that must keep running when the cluster is full."
```

Apply it and run `astrona submit`. The check `priorityclass-critical-service` passes.

```sh
kubectl apply -f priorityclass-critical.yaml
```

## Step 3: Use the class and set Guaranteed resources

Edit the Deployment. In the pod template, add `priorityClassName: critical-service` next to `containers`, and under the container set `limits` for `cpu` and `memory` to the same values as the requests (the cpu value that is already there and `64Mi`):

```sh
kubectl -n starfleet edit deployment scout
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

The scheduler now preempts one `drifter` pod for the new `scout` pod. Check the result:

```sh
kubectl -n starfleet get pod -l app=scout -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority,QOS:.status.qosClass
kubectl -n outpost get pods
```

One `drifter` pod is `Pending`, because it has the lowest priority and no longer fits. Run `astrona submit`. All checks pass.
