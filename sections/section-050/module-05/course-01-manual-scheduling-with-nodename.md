---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Manual Scheduling With nodeName

The control plane has a problem and the kube-scheduler is not running. A new `scout` Pod must still start on a known node. The Pod spec has a field for this: `spec.nodeName`. If it is set, the Pod already has a node, so the scheduler has nothing to do.

This chapter explains what the field does, which checks it skips, how to bind a Pod that already exists, and what the kubelet still checks.

## What the scheduler does with a Pod

The normal path has four steps. A client creates a Pod without `spec.nodeName`. The kube-scheduler watches for Pods with an empty `nodeName`, runs its filters and scores, and picks a node. It then creates a `Binding` object through the API server, and the API server writes the chosen node into `spec.nodeName`. Finally the kubelet on that node sees a Pod assigned to it and starts the containers.

Setting `nodeName` yourself skips the middle two steps. The scheduler never sees the Pod, because its watch selects only unassigned Pods. No `Scheduled` event appears, because no scheduler made a decision.

<!-- astrona:playground:renew -->

## A worked example

Find the name of the worker node:

```sh
kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name
```

Save this as `pod-scout.yaml`, and replace `<WORKER>` with the node name without the `node/` prefix:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: scout
  namespace: starfleet
spec:
  nodeName: <WORKER>
  containers:
  - name: scout
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-scout.yaml
```

Then look at the Pod and its events:

```sh
kubectl -n starfleet get pod scout -o wide
kubectl -n starfleet describe pod scout
```

The Pod runs on the worker. The `Events` section starts with events from the kubelet, such as pulling and starting the container. It has no line from `default-scheduler`. That missing line is the proof that the scheduler was skipped.

## What the field skips and what it does not

Because the scheduler is skipped, its filters are skipped too. A `NoSchedule` taint on the node does not stop the Pod. The kubelet does run its own admission check when it accepts the Pod. It rejects a Pod that asks for more resources than the node has free, and the Pod ends in a failed state with a reason such as `OutOfcpu`. It also checks the Pod's node selector and node affinity against the node's labels, and a mismatch fails the Pod with the reason `NodeAffinity`. A `NoExecute` taint that the Pod does not tolerate makes the control plane evict the Pod.

Two failure cases are common. A `nodeName` that names a node that does not exist leaves the Pod `Pending` forever, with no scheduling event, because no kubelet owns it. A `nodeName` on a Deployment template pins every replica to one node and removes the scheduler's ability to spread or reschedule them.

## Reading the result

Two fields show who made the decision. `spec.nodeName` holds the node, whether the scheduler or a person set it. The events show the decision maker: a normal scheduling writes a `Scheduled` event from `default-scheduler` with the text "Successfully assigned", and a manual assignment writes none. Use this to tell whether a strange placement was a scheduler decision or a manifest with a hard-coded node. Search for the field in a workload with:

```sh
kubectl -n starfleet get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

A Deployment whose Pods all show the same node and whose template contains `nodeName` was pinned by hand.

The column `NOMINATED NODE` in `kubectl get pods -o wide` is a different thing. It shows `status.nominatedNodeName`, which the scheduler sets when it plans to place a Pod after preempting lower-priority Pods. It is a hint, not an assignment, and it is empty for a Pod that uses `nodeName`.

The events of the namespace give the same proof for all Pods at once. The reason `Scheduled` appears only for Pods that the scheduler placed, so a Pod missing from that list either was assigned by hand or is not yet placed.

```sh
kubectl -n starfleet get events --field-selector reason=Scheduled
```

Events expire after about an hour by default, so run the check soon after the Pod starts.

## Binding an existing Pod

Setting `nodeName` on an existing, unassigned Pod with `kubectl edit` is rejected, because the field cannot be changed once the Pod exists. The supported way is the `binding` subresource, which is what the scheduler itself calls. A client posts a `Binding` object that names the Pod and the target node to the path `/api/v1/namespaces/<namespace>/pods/<name>/binding`. This is how a custom scheduler or a tool outside Kubernetes commits a decision. Day-to-day work needs only `nodeName` at creation time.

The alternative to `nodeName` is to constrain the Pod and let the scheduler decide: a `nodeSelector` on `kubernetes.io/hostname` names one node and keeps the taint, resource and event machinery. Prefer it unless the scheduler itself is the problem.

You can now start a Pod on a chosen node without the scheduler and prove that no scheduling happened. The kubelet can also start Pods without the API server's involvement at all, which is the next topic.

## Common pitfalls

> [!WARNING]
> `nodeName` bypasses taints, node selectors and every other scheduler filter, and it removes the Pod from rescheduling. A misspelled node name leaves the Pod Pending with no event. Never put `nodeName` in a Deployment template to fix a scheduling problem. Find out why the scheduler rejected the Pod instead.
