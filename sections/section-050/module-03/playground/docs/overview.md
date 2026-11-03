---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Node Affinity Playground

This ungraded environment is a kind cluster with one control plane node and one worker node. The namespaces `starfleet` and `outpost` exist and are empty. There is no task and nothing to submit.

The worker node carries the labels `disk=ssd`, `tier=compute` and `gpu-count=2`. The control plane node is tainted, so ordinary Pods run on the worker.

## What to try

- List the node labels with `kubectl get nodes --show-labels` and note which labels the kubelet set and which the playground added.
- Run a Pod with a `nodeSelector` for a label no node has. Read the `FailedScheduling` event, then add the label to the worker and watch the Pod start.
- Write required node affinity that uses each operator: `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt` and `Lt`. Predict whether the Pod runs before you apply it.
- Put two expressions in one term, then in two terms, and compare the result.
- Add a preferred rule with a weight for a label the worker does not have and confirm that the Pod still runs.
- Remove a label from the worker while a Pod that required it is running, and confirm that the Pod keeps running.

Delete your test objects freely. Use `astrona destroy ats-024-playground-050-03` when you are done.
