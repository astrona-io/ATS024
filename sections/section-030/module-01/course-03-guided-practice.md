---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Guided Practice: Configure A Metrics-Backed Autoscaler

You now create the `probe` HPA yourself, prove that it reads measurements, and then watch it react to load. The practice uses the module playground, a private kind cluster (Kubernetes in containers) with the metrics server installed. Its `probe` Deployment has two replicas, each requesting 10 millicores of CPU, and the Pods `shuttle` in `starfleet` and `drifter` in `outpost` act as clients.

## Connect to the playground

A kubeconfig file tells `kubectl` which cluster and credentials to use. The first command points `kubectl` at the playground, and the second stops the commands if the context is wrong, so no later command can touch another cluster.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-playground-030-01" || exit 1
```

Inspect the starting state. The Deployment must show two ready replicas, and no HPA exists yet:

```sh
kubectl -n starfleet get deployment,pods,hpa
```

## Create the autoscaler

The target is the Deployment `probe`. The HPA must keep between two and four replicas and aim for an average CPU utilization of 70 percent of the request. Save this as `horizontalpodautoscaler-probe.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: probe
  namespace: starfleet
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: probe
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply it:

```sh
kubectl apply -f horizontalpodautoscaler-probe.yaml
```

Then check the result. The HPA controller needs one scrape of the new Pods before it reports a measurement, so wait for the `ScalingActive` condition instead of reading the status at once:

```sh
kubectl -n starfleet wait --for=condition=ScalingActive hpa/probe --timeout=240s
kubectl -n starfleet describe hpa probe
```

In the description, look at three places. The `Metrics` line shows the current value over the target, for example a small percentage over 70 percent. The conditions show `AbleToScale` and `ScalingActive` as `True`. The `Min replicas` and `Max replicas` lines show 2 and 4. The exact current percentage changes every scrape, so do not expect a fixed number.

## Add load and watch the decision

Idle `probe` Pods use far less than the 7 millicores that 70 percent of a 10 millicore request allows, so nothing scales. To create demand, start a request loop from `shuttle` in a second terminal that uses the same `KUBECONFIG`. The loop sends requests to the `probe` Service until you stop it with Control-C:

```sh
kubectl -n starfleet exec shuttle -- sh -c 'while true; do wget -q -O /dev/null http://probe.starfleet.svc.cluster.local/; done'
```

Back in the first terminal, watch the HPA. The `TARGETS` column should rise above 70 percent within a minute or two, and the replica count should grow toward the maximum of four. The controller syncs about every 15 seconds and the metrics server scrapes about every 15 seconds, so changes arrive in steps and not at once:

```sh
kubectl -n starfleet get hpa probe --watch
```

Stop the watch and the loop with Control-C. After the load stops, the replica count does not fall at once. The default scale-down stabilization window is 300 seconds, so the HPA keeps the higher count for five minutes of low readings before it removes replicas. That delay is correct behavior and not a fault.

## Try the failure on purpose

Remove the CPU request from the Deployment and watch the HPA lose its denominator. The `kubectl patch` below replaces the container resources with a version that has a memory request but no CPU request:

```sh
kubectl -n starfleet patch deployment probe --type=json -p='[{"op":"remove","path":"/spec/template/spec/containers/0/resources/requests/cpu"}]'
```

After the new Pods start, `kubectl describe hpa probe` reports `ScalingActive` as `False` with a failure to get the resource metric, and the message names the missing request. Put the request back with `kubectl -n starfleet set resources deployment probe --requests=cpu=10m,memory=32Mi` and the condition returns to `True` after the next metric scrape.

## What you now know

You created an `autoscaling/v2` HPA, proved that it read measurements with its conditions, saw the replica count rise under load and fall slowly afterward, and saw that a missing CPU request stops the calculation. The HPA acts on replica counts only, so the remaining limit is always the room on the nodes and the readiness of the new Pods.

## Common pitfalls

> [!WARNING]
> Confirm the private context before every change. Do not read the status in the first seconds after the HPA is created: the first measurement needs a scrape. Do not expect a scale-down while the stabilization window is still running, and do not delete the HPA to hide a missing request.
