---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Quality Of Service, Eviction And Pod Overhead

Two pods run on one node, and the node runs out of memory. One pod is killed and the other keeps running. The difference is not luck. It comes from the quality of service (QoS) class of each pod, which the API server assigns from the requests and limits. This part explains the three classes, how the kubelet evicts pods under node pressure, how the kernel picks a process to kill and how pod overhead changes the numbers.

## Three classes, assigned from requests and limits

The API server sets `status.qosClass` when it creates the pod. You cannot set it directly. The rules are:

- **Guaranteed**: every container has a CPU request and limit and a memory request and limit, the request equals the limit for each, and the values are above zero.
- **BestEffort**: no container sets any CPU or memory request or limit.
- **Burstable**: every other pod. At least one container sets something, but the pod does not meet the Guaranteed rule.

Save this as `pods-qos.yaml`. It creates one pod of each class in `starfleet`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: qos-guaranteed
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: docker.io/library/busybox:1.37.0
      command: ["sleep", "3600"]
      resources:
        requests: {cpu: 50m, memory: 32Mi}
        limits: {cpu: 50m, memory: 32Mi}
---
apiVersion: v1
kind: Pod
metadata:
  name: qos-burstable
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: docker.io/library/busybox:1.37.0
      command: ["sleep", "3600"]
      resources:
        requests: {cpu: 50m, memory: 32Mi}
---
apiVersion: v1
kind: Pod
metadata:
  name: qos-besteffort
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: docker.io/library/busybox:1.37.0
      command: ["sleep", "3600"]
```

<!-- astrona:playground:renew -->

Apply it and read the class of each pod:

```sh
kubectl apply -f pods-qos.yaml
kubectl -n starfleet get pod qos-guaranteed qos-burstable qos-besteffort -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

The table shows `Guaranteed`, `Burstable` and `BestEffort` for the three pods. A pod that sets a CPU limit and a memory request but only a CPU request is still `Burstable`. One missing value in one container is enough to lose the Guaranteed class.

## Node-pressure eviction is done by the kubelet

The kubelet watches memory, disk space, inodes and process IDs on its node. When a signal passes a threshold, for example `memory.available` falling below a hard limit, the kubelet sets a node condition such as `MemoryPressure` and starts **eviction**. It marks chosen pods as `Failed` and stops them. This is different from preemption, which the scheduler does, and different from an API-initiated eviction. The kubelet ignores PodDisruptionBudgets in this case.

For memory the kubelet ranks the pods in this order:

1. Pods whose usage is above their requests come before pods whose usage is below.
2. Among those, lower priority comes first.
3. Then the pod with the largest usage above its request comes first.

A `BestEffort` pod has a request of zero, so any usage is above it, and it goes first. A `Guaranteed` pod has requests equal to its limits, so it is evicted only when it is the only pod left above its request, or when system processes need the memory. This is why the QoS class and the priority both matter: the QoS class shapes the usage compared to the request, and the priority breaks ties.

## The kernel OOM killer uses oom_score_adj

Eviction needs the kubelet to notice pressure in time. When memory runs out faster, the Linux kernel out-of-memory (OOM) killer ends a process. It picks the process with the highest OOM score, and the kubelet changes that choice with the setting `oom_score_adj` for each container process. A higher value makes the process more likely to be killed.

The kubelet sets `-997` for `Guaranteed` pods, `1000` for `BestEffort` pods and, for `Burstable` pods, a value that shrinks as the memory request grows, kept between 2 and 999. Read the value from inside each container:

```sh
kubectl -n starfleet exec qos-guaranteed -- cat /proc/1/oom_score_adj
kubectl -n starfleet exec qos-besteffort -- cat /proc/1/oom_score_adj
```

The first command prints `-997` and the second prints `1000`. These numbers explain why a `BestEffort` container is the first to die at the kernel level, and why a `Guaranteed` container is the last.

## Pod overhead and RuntimeClass

A pod needs more than its containers: the runtime shim and, for sandboxed runtimes, a virtual machine. A **RuntimeClass** names a container runtime handler and may declare `overhead.podFixed`, a fixed amount of CPU and memory for each pod that uses it. The `RuntimeClass` admission plugin copies the overhead into `spec.overhead` of the pod. The scheduler adds the overhead to the container requests when it places the pod. The ResourceQuota counts it, and the kubelet includes it when it sizes the pod's cgroup. The overhead does not change the QoS class.

Save this as `runtimeclass-overhead.yaml`. The handler `runc` is the default runtime of the `kind` node:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: runc-overhead
handler: runc
overhead:
  podFixed:
    cpu: 100m
    memory: 32Mi
```

Apply it. A pod that sets `runtimeClassName: runc-overhead` then shows `spec.overhead` after creation:

```sh
kubectl apply -f runtimeclass-overhead.yaml
```

You now know how the three QoS classes are assigned, how the kubelet picks pods to evict, how `oom_score_adj` guides the kernel and how overhead adds to a pod's size. Priority, QoS class and requests together decide what stays on a busy node.

## Common pitfalls

> [!WARNING]
> - **Thinking Guaranteed pods can never be evicted.** They are last in line, not exempt. A node that is short of memory for system processes can still evict them.
> - **Looking for the class in the pod spec.** `qosClass` is in `status` only. Change the requests and limits to change it.
> - **Setting limits equal to requests for memory only.** CPU must match too, or the pod is `Burstable`.
> - **Confusing OOM kill and eviction.** An OOM kill is done by the kernel and shows `OOMKilled`. An eviction is done by the kubelet and the pod shows a `Failed` phase with the reason `Evicted`.
