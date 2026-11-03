---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Replace Anti-Affinity With A Spread Constraint Solution

UNTESTED: not yet run against a live environment.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-04-01" || exit 1
```

## Step 1: Read the failure

Check which Pods run and why one does not:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
kubectl -n starfleet describe pods -l app=probe
```

Two Pods run, one in each zone. The third Pod has a `FailedScheduling` event about Pod anti-affinity rules. The rule allows one Pod per zone, so three replicas cannot fit. Run `astrona submit` to see which checks fail.

## Step 2: Replace the rule

Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 3
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: probe
        matchLabelKeys:
        - pod-template-hash
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it:

```sh
kubectl apply -f deployment-probe.yaml
```

## Step 3: Check the result

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet get pods -l app=probe -o wide
```

Three Pods run, two on one worker and one on the other. Run `astrona submit`: every check passes. Remove the environment with `astrona destroy ats-024-lab-050-04-01`.

## Common pitfalls

> [!WARNING]
> Reducing the replicas to two would also make the Pods Running, but the task requires three. Keeping the anti-affinity rule and removing a zone label hides the fault. The skew arithmetic decides the outcome: two and one has a skew of one.
