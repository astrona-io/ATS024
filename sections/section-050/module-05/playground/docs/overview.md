---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Manual Scheduling And Scheduler Controls Playground

This ungraded environment is a kind cluster with one control plane node and one worker node. The namespaces `starfleet` and `outpost` exist and are empty. There is no task and nothing to submit.

The kind nodes are containers named `astro-ats-024-playground-050-05-control-plane` and `astro-ats-024-playground-050-05-worker`. Use `podman exec` or `docker exec` with those names to look inside a node. These commands act only on this environment's node containers.

## What to try

- Start a Pod with `spec.nodeName` set to the worker and check that the events have no `Scheduled` line. Set a name that does not exist and watch the Pod stay Pending.
- Read `staticPodPath` in `/var/lib/kubelet/config.yaml` on the worker, list `/etc/kubernetes/manifests` on the control plane node, and run `kubectl -n kube-system get pods` to find the mirror Pods of the control plane components.
- Copy a static Pod file into the worker's manifest directory, delete its mirror Pod, and then remove the file.
- Start a Pod with a `schedulerName` that no scheduler serves and compare its events with a Pod that fails with `Insufficient cpu`.
- Create a Pod with a scheduling gate and remove the gate with a JSON patch.
- Cordon the worker, create a Pod, read the event, and uncordon.

Use `astrona destroy ats-024-playground-050-05` when you are done.
