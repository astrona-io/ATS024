---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Place A Restricted Workload On A Dedicated Pool — Solution

UNTESTED: not yet run against a live environment.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-cap" || exit 1
```

## Step 1: Read the state

List the nodes, the Pods and the events:

```sh
kubectl get nodes --show-labels
kubectl -n starfleet get pods
kubectl -n starfleet describe pods -l app=scout
```

One worker shows `SchedulingDisabled`. The events of the Pods name the taint, and one more cause: the request of 16 CPUs is larger than any node offers. Run `astrona submit` to see which checks fail.

## Step 2: Enforce the restricted level and uncordon the worker

Label the namespace. Existing Pods are not changed by an enforce label, and new Pods are checked from now on:

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=restricted --overwrite
kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | xargs -n1 kubectl uncordon
```

## Step 3: Rewrite the Deployment

The toleration makes the nodes eligible. The required node affinity keeps the Pods on the pool. The spread constraint balances the zones, and `matchLabelKeys` with `pod-template-hash` keeps a rolling update from counting old Pods. The Pod needs `runAsNonRoot`, a numeric user, a seccomp profile, no privilege escalation and dropped capabilities to pass `restricted`. Save this as `deployment-scout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 4
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      tolerations:
      - key: dedicated
        operator: Equal
        value: scout
        effect: NoSchedule
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: pool
                operator: In
                values: ["dedicated"]
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: scout
        matchLabelKeys:
        - pod-template-hash
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
```

Apply it and wait for the rollout:

```sh
kubectl apply -f deployment-scout.yaml
kubectl -n starfleet rollout status deployment/scout --timeout=240s
```

Run `astrona submit`: every check passes. Remove the environment with `astrona destroy ats-024-lab-050-cap`.

## Common pitfalls

> [!WARNING]
> Fixing only one cause leaves the Pods Pending or rejected, because each rule filters separately. A toleration alone does not keep the Pods on the pool, and node affinity alone does not let them onto tainted nodes. Do not remove the taint, relabel the nodes or set `nodeName` to get past a filter, because the grader rejects each of them.
