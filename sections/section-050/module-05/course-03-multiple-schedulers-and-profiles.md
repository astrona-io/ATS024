---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Multiple Schedulers And Scheduler Profiles

Most Pods use the default scheduling behaviour, but a batch workload might need a scheduler that packs nodes tightly, or one that skips scoring to start Pods faster. Kubernetes allows more than one scheduling policy in a cluster, and a Pod chooses with one field: `spec.schedulerName`.

This chapter shows the field, the difference between a profile and a separate scheduler process, and the failure you see when a Pod names a scheduler that is not running.

## The schedulerName field

Every Pod has `spec.schedulerName`, which defaults to `default-scheduler`. Each kube-scheduler instance handles only the Pods whose `schedulerName` equals one of its own profile names. A Pod that names another scheduler is ignored by the default scheduler, however the cluster is configured.

There are two ways to offer another name. The first is a scheduler profile: one kube-scheduler process serves several names, each with its own plugin settings. The second is a separate scheduler process, with its own configuration and its own leader election, deployed as another Pod.

## Profiles

A profile is an entry in the `profiles` list of the file that the kube-scheduler reads with its `--config` flag. The file has the kind `KubeSchedulerConfiguration` in the API group `kubescheduler.config.k8s.io/v1`. In a kubeadm cluster the scheduler runs as a static Pod, so the flag appears in `/etc/kubernetes/manifests/kube-scheduler.yaml` only when someone added a configuration file. The file below is an example of the content. It is read by the scheduler binary and is not applied with `kubectl`:

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: default-scheduler
  - schedulerName: no-scoring-scheduler
    plugins:
      preScore:
        disabled:
        - name: '*'
      score:
        disabled:
        - name: '*'
```

The first profile keeps the defaults. The second disables every scoring plugin, so the scheduler takes the first feasible node. A single scheduler process now accepts both names. All profiles in one process must use the same `queueSort` plugin, because the process keeps one queue of Pods.

## A separate scheduler process

A second scheduler is a second copy of the kube-scheduler binary, normally run as a Deployment in the `kube-system` namespace with its own configuration. Its profile has a different `schedulerName`. When two copies run, leader election must use different lock names, or the instances compete for one lock. The second scheduler also needs RBAC permissions equal to the default scheduler's, because it reads nodes and Pods and creates bindings.

A separate process isolates scheduling policy and failures. A profile is cheaper because it shares the queue, the cache and the process. Use a profile for a different plugin set and a separate process for a different binary or release.

<!-- astrona:playground:renew -->

## What a missing scheduler looks like

Save this as `pod-probe.yaml`. It names a scheduler that does not exist:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe
  namespace: starfleet
spec:
  schedulerName: no-such-scheduler
  containers:
  - name: probe
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-probe.yaml
```

Then check the Pod:

```sh
kubectl -n starfleet get pod probe
kubectl -n starfleet describe pod probe
```

The Pod is `Pending`. The `Events` section is empty, and the Pod has no `nodeName`. This is different from a scheduling failure, which always writes a `FailedScheduling` event. Here no scheduler considered the Pod, so nobody wrote an event. An empty event list on a Pending Pod therefore points at `schedulerName`, a scheduling gate or a scheduler that is down.

Read the field directly to confirm:

```sh
kubectl -n starfleet get pod probe -o jsonpath='{.spec.schedulerName}{"\n"}'
```

The fix is to recreate the Pod with `schedulerName: default-scheduler` or a name that a running scheduler serves. `schedulerName` cannot be edited on an existing Pod, so delete and create the Pod, or change the Deployment template so that the controller replaces the Pods.

You can now route a Pod to a scheduler and recognise a Pod nobody schedules. Two more controls decide whether a Pod is considered at all: a gate on the Pod and the state of the node.

## Common pitfalls

> [!WARNING]
> A Pod that names a scheduler nobody runs stays Pending with no events. Profile names must be unique in one scheduler. A second scheduler process needs its own leader election lock name and the same RBAC permissions as the default one. `schedulerName` cannot be changed on a running Pod.
