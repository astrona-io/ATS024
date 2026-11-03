# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`.

Start the lab and point `kubectl` at it:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-06-01)"
```

## Step 1: Find why no pod exists

The ReplicaSet of `drifter` reports the rejection as an event:

```sh
kubectl -n outpost describe replicaset -l app=drifter
```

The events say that the pod must specify requests and limits because the quota covers them.

## Step 2: Add the LimitRange

Save this as `limitrange-outpost.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: outpost
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 64Mi
      default:
        cpu: 200m
        memory: 128Mi
      max:
        cpu: 500m
        memory: 256Mi
```

Apply it, then restart the rollout so that a new ReplicaSet creates the pods now:

```sh
kubectl apply -f limitrange-outpost.yaml
kubectl -n outpost rollout restart deployment/drifter
kubectl -n outpost rollout status deployment/drifter --timeout=120s
```

Run `astrona submit`. The checks for the Deployment, the LimitRange and the maximum pass.

## Step 3: Cap the number of Deployments

Edit the quota and add the line `count/deployments.apps: "3"` under `spec.hard`:

```sh
kubectl -n outpost edit resourcequota compute
```

Run `astrona submit`. All four checks pass.
