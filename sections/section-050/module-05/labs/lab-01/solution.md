---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Release Pending Pods Solution

UNTESTED: not yet run against a live environment.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-05-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-05-01" || exit 1
```

## Step 1: Read the status and the events

List the Pods and the nodes:

```sh
kubectl -n starfleet get pods
kubectl get nodes
kubectl -n starfleet describe pod shuttle
kubectl -n starfleet describe pods -l app=probe
```

The `shuttle` Pod shows the status `SchedulingGated`. The `probe` Pods are Pending and have no events at all, which means that no scheduler acted. The worker shows `Ready,SchedulingDisabled`. There are three causes: a gate, a scheduler name nobody serves, and a cordoned node. Run `astrona submit` to see the failed checks.

## Step 2: Uncordon the worker and release the gate

Get the worker name, uncordon it and remove the gate:

```sh
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
kubectl uncordon "$worker"
kubectl -n starfleet patch pod shuttle --type=json -p '[{"op":"remove","path":"/spec/schedulingGates"}]'
```

The `shuttle` Pod is scheduled to the worker and becomes Running. The `probe` Pods stay Pending, because their scheduler name is still wrong.

## Step 3: Fix the scheduler name

The field cannot change on a running Pod, so change the Deployment template. Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      schedulerName: default-scheduler
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it and wait for the rollout:

```sh
kubectl apply -f deployment-probe.yaml
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

Run `astrona submit`: every check passes. Remove the environment with `astrona destroy ats-024-lab-050-05-01`.

## Common pitfalls

> [!WARNING]
> A toleration for the `unschedulable` taint, or `nodeName` on the template, would start the Pods but hide the real causes, and the grader rejects both. Empty events on a Pending Pod mean that no scheduler acted. Check the gate, the scheduler name and the node before anything else.
