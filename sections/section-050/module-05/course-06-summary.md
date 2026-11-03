---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Normally the kube-scheduler picks a node and writes it into the Pod through a binding. Setting `spec.nodeName` by hand skips the scheduler, its filters and its events, while the kubelet still checks resources and node selectors. A node name that does not exist leaves the Pod Pending without any event.

Static Pods are Pods that the kubelet creates from files in its `staticPodPath`, which is `/etc/kubernetes/manifests` on kubeadm and kind nodes. The API server shows a read-only mirror Pod. Deleting the mirror does nothing, and removing the file stops the Pod. The control plane components run this way.

`spec.schedulerName` selects which scheduler handles a Pod. One scheduler process can serve several names through profiles in a `KubeSchedulerConfiguration`, and a separate process needs its own configuration, leader election lock and permissions. A Pod that names a scheduler that does not run stays Pending with no events.

A scheduling gate holds a Pod out of scheduling until its entries are removed, and gates can only be removed after creation. Cordon marks a node unschedulable with a taint and leaves running Pods alone, and uncordon reverses it.

To debug a Pending Pod, read the status, the events, the node data and the dependent objects. The source and wording of the event separate a scheduler failure from a Pod that nobody is scheduling.

<!-- astrona:playground:destroy -->
