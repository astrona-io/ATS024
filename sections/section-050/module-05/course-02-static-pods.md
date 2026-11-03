---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Static Pods

The kube-apiserver, etcd, kube-scheduler and kube-controller-manager of a kubeadm cluster are Pods, yet they must run before the API server exists. They are static Pods: Pods that the kubelet on one node creates from files, with no scheduler and no controller.

This chapter shows where the kubelet looks for those files, what a mirror Pod is, and how to start and stop a static Pod.

## How the kubelet finds static Pods

The kubelet is the agent on each node that starts containers. Its configuration file has a field `staticPodPath`. The kubelet watches that directory and creates a Pod for each manifest file in it. In kubeadm clusters, and in kind, the path is `/etc/kubernetes/manifests`. The kubelet can also take manifests from a URL with `staticPodURL`, which is rarely used.

The kubelet restarts a static Pod if its container fails, and it recreates the Pod when the file changes. It does this alone, so static Pods run even when the API server is down. A Pod from a file belongs to one node: no scheduler picks the node, and no ReplicaSet scales it.

## The mirror Pod

The API server cannot own a static Pod, but users still want to see it. For each static Pod the kubelet creates a mirror Pod in the API server. The mirror Pod name is the file's Pod name followed by a dash and the node name, for example `static-probe-<node>`. The Pod has an annotation `kubernetes.io/config.mirror` and an owner reference to the Node.

The mirror Pod is read-only in effect. `kubectl delete pod` removes the mirror Pod from the API, but the kubelet sees that the file still exists and creates it again. The only way to stop a static Pod is to remove or move its file from the directory. Static Pods cannot use ConfigMaps, Secrets or ServiceAccounts, because those objects need the API server's control path, and they cannot be part of a controller.

<!-- astrona:playground:renew -->

## A worked example

The kind node is a container. Set the engine name and the worker container name once. The container name is `astro-` plus the playground name and `-worker`:

```sh
engine=podman
worker=astro-ats-024-playground-050-05-worker
$engine exec "$worker" grep staticPodPath /var/lib/kubelet/config.yaml
```

The line shows `staticPodPath: /etc/kubernetes/manifests`. On the control plane node the same directory holds the manifests of the cluster components:

```sh
$engine exec astro-ats-024-playground-050-05-control-plane ls /etc/kubernetes/manifests
```

The listing contains the files for the API server, etcd, the controller manager and the scheduler. Use `docker` instead of `podman` if that is your engine.

Save this as `static-probe.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-probe
  namespace: starfleet
spec:
  containers:
  - name: probe
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Copy it into the worker's manifest directory:

```sh
$engine cp static-probe.yaml "$worker":/etc/kubernetes/manifests/static-probe.yaml
```

Then check the mirror Pod:

```sh
kubectl -n starfleet get pods -o wide
```

A Pod named `static-probe-` followed by the worker's name appears. Try `kubectl -n starfleet delete pod` on it, and run the listing again: the Pod returns, because the file is still in place. Remove the file to stop it:

```sh
$engine exec "$worker" rm /etc/kubernetes/manifests/static-probe.yaml
```

The mirror Pod disappears after a short time.

## Static Pods and the control plane

Because the control plane components are static Pods, a change to a file in `/etc/kubernetes/manifests` on a control plane node changes the component. Editing `kube-apiserver.yaml` makes the kubelet restart the API server with new flags, and a syntax error in the file leaves the component down. For that reason, copy a file before editing it and check the Pod after the change.

The kubelet also reports the state of a static Pod through its mirror Pod, so `kubectl describe` on the mirror Pod shows the container state, restarts and events of a Pod that no controller manages. A static Pod can name a namespace in its metadata, and the mirror Pod appears in that namespace.

When a control plane Pod is missing, the first debugging step is on the node: check the file, then the kubelet's view of it. A static Pod with a wrong image shows `ImagePullBackOff` in its mirror Pod just like any other Pod.

You now know how a Pod can come from a file and why deleting its mirror does nothing. Next, who decides the node for Pods that do come from the API: the scheduler, and how to choose a different one.

## Common pitfalls

> [!WARNING]
> Deleting a mirror Pod does not stop a static Pod. Remove the file from the node. The directory is the kubelet's `staticPodPath`, so check the kubelet configuration before you assume the path. Editing a control plane manifest restarts that component, so keep a copy and verify the Pod after each change.
