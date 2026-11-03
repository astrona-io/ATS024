---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Limit Ranges And Resource Quotas At Admission

The `outpost` namespace belongs to another team. The platform team wants every container there to have sensible resource settings, and wants the whole namespace to stay inside a fixed budget. Kubernetes does this with two namespaced objects, a LimitRange and a ResourceQuota. Both are enforced by admission plugins in the API server, which means they act when an object is created or updated and before it is stored.

## What admission means here

**Admission** is the step where the API server checks and may change a request after authentication and authorization and before it saves the object. The `LimitRanger` plugin handles LimitRange objects. It first adds default values to the pod, and later checks the minimum, maximum and ratio rules. The `ResourceQuota` plugin handles ResourceQuota objects. It checks that the request fits the remaining quota and records the new usage.

A pod that fails either check is never stored, so the scheduler never sees it. When a Deployment creates the pod, the ReplicaSet controller makes the request and reports the failure as an event on the ReplicaSet. The Deployment then shows fewer pods than wanted and no pod in `Pending`.

## A LimitRange sets per-container rules

A **LimitRange** is a namespaced object with a list of limits. Each item has a `type` (`Container`, `Pod` or `PersistentVolumeClaim`) and these fields for the resources it covers:

- `default`: the limit given to a container that sets none.
- `defaultRequest`: the request given to a container that sets none.
- `min` and `max`: the smallest and largest value a container may request or limit.
- `maxLimitRequestRatio`: the largest allowed ratio of limit to request.

Save this as `limitrange-outpost.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-rules
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
      min:
        cpu: 50m
        memory: 32Mi
      max:
        cpu: 500m
        memory: 256Mi
      maxLimitRequestRatio:
        cpu: "4"
```

<!-- astrona:playground:renew -->

Apply it and read it back:

```sh
kubectl apply -f limitrange-outpost.yaml
kubectl -n outpost describe limitrange container-rules
```

The description lists each rule as a row for the `Container` type. Defaults are applied only when a pod is created, so the existing `drifter` pods do not change. Delete one `drifter` pod, let the Deployment replace it, and read the new pod:

```sh
kubectl -n outpost delete pod -l app=drifter --wait=false
kubectl -n outpost get pod -l app=drifter -o jsonpath='{.items[0].spec.containers[0].resources}{"\n"}'
```

The replacement pod now shows the request and limit that came from the LimitRange. Run the second command again if the old pod is still listed. The `LimitRanger` plugin wrote these values into the pod before it was stored, so the Deployment's own template is unchanged.

A pod that breaks a rule is rejected. A container with a CPU limit of `1` is above `max`. The error contains the text `maximum cpu usage per Container is 500m, but limit is 1`. A container with request `50m` and limit `500m` is above the ratio of 4, and the error says the max limit to request ratio per Container is 4. Defaults are not checked against each other, so a default limit below a request that the user sets makes the pod invalid.

## A ResourceQuota sets a budget for the namespace

A **ResourceQuota** limits the total resource use of a namespace. Its `spec.hard` field lists names and maximum values. Compute names are `requests.cpu`, `requests.memory`, `limits.cpu` and `limits.memory`. Object count names use the form `count/<resource>.<group>` for example `count/deployments.apps`, or a plain name such as `pods`, `services` or `configmaps`.

Save this as `quota-outpost.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute
  namespace: outpost
spec:
  hard:
    requests.cpu: 500m
    requests.memory: 512Mi
    limits.cpu: "1"
    limits.memory: 1Gi
    pods: "4"
    count/deployments.apps: "3"
```

Apply it and see the usage:

```sh
kubectl apply -f quota-outpost.yaml
kubectl -n outpost describe resourcequota compute
```

The output has a `Used` and a `Hard` column for each name. The quota controller recalculates `Used` shortly after each change.

When a quota covers `requests.cpu` or `limits.cpu`, every new pod must set that value, and the same holds for memory. A pod without it is rejected with an error that says it must specify the resource. The LimitRange defaults above make this work, because the `LimitRanger` plugin fills in the values before the `ResourceQuota` plugin checks them. A request that would go over the quota returns `403 Forbidden` with the text `exceeded quota: compute`, followed by the amounts requested, used and limited.

## Scopes narrow a quota

A quota can have `scopes` so that it counts only some pods. `Terminating` and `NotTerminating` select pods by whether `activeDeadlineSeconds` is set. `BestEffort` and `NotBestEffort` select pods by quality of service class. A `scopeSelector` with the key `PriorityClass` selects pods by priority class name. A scoped quota may only use names that make sense for the scope: a `BestEffort` quota can count `pods` but cannot limit CPU, because best-effort pods set none.

You now know how a LimitRange fills in and checks container values, and how a ResourceQuota caps a namespace. Existing pods are never changed by either object. The open question is how to find which rule rejected a request, and the answer is in the events and the error text.

## Common pitfalls

> [!WARNING]
> - **Expecting a LimitRange to change running pods.** It acts at creation only. Replace the pods to get the defaults.
> - **Adding a compute quota without defaults.** Every Deployment that sets no resources then creates no pods, and the only sign is an event on the ReplicaSet.
> - **Looking for a Pending pod.** An admission rejection stops the pod before it is stored, so `kubectl get pods` shows nothing for it.
> - **Forgetting that `pods` counts finished pods too.** Completed pods that are not deleted still count against an object quota.
