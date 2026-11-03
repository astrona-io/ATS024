---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Workload Controllers For Self-Healing

A Pod that runs alone is never replaced. If its node fails or someone deletes it, it is gone. A workload controller is a Kubernetes control-plane component that watches a group of Pods and creates or removes Pods until the group matches the declared specification. Each controller kind encodes a different promise about identity, placement and completion.

This module covers the controller kinds that the exam expects you to choose between. You will follow the ownership chain from a Deployment to its Pods, run one Pod on every node, keep a stable name and storage for a stateful Pod, and run work that has to finish instead of run forever.

## Learning goals

- Explain how a ReplicaSet owns its Pods through `ownerReferences` and a label selector, and what the garbage collector does when an owner is deleted.
- Choose between a Deployment, a DaemonSet and a StatefulSet for a given placement and identity requirement.
- Explain why a StatefulSet needs a headless Service and how ordered startup works.
- Configure a Job with completions, parallelism, a retry limit and automatic cleanup.
- Configure a CronJob with a schedule, a concurrency policy, a start deadline and history limits.

## Before you start

You need to know what a Pod, a namespace, a label and a Service are, and the commands `kubectl get`, `kubectl apply` and `kubectl delete`. The playground is a kind cluster with Kubernetes 1.35, one control-plane node and one worker node. In the `starfleet` namespace it already runs the Deployment `scout`, the DaemonSet `shuttle`, the StatefulSet `probe` with its headless Service, the Job `bridge-report` and the CronJob `drifter-sweep`.

## Reading order

The first part follows the ownership chain from a Deployment to a ReplicaSet to its Pods, and shows how deletion and adoption work. The second part covers the DaemonSet, which runs one Pod per node, and the StatefulSet, which gives each Pod a fixed name, a fixed claim and an order. The third part covers the Job and the CronJob, which run work to completion and on a schedule, and explains retries, concurrency and cleanup. A graded task after the third part asks you to repair a Job and a CronJob. The summary closes the module.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
