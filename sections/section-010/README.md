---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Understand application deployments and how to perform rolling update and rollbacks

A new `probe` version starts but cannot answer its readiness check. Kubernetes keeps the process running while the Deployment waits for usable replacement capacity. Reading this situation correctly prevents a failed rollout from being mistaken for a missing update, and knowing the rollback commands turns a failed release into a short repair.

This section follows a release from start to recovery. It explains how a Deployment replaces Pods, how it stores revisions and rolls back, which strategy fits which release, how StatefulSets and DaemonSets update, and how Kustomize and Helm manage the same objects across environments. Each module has a private playground for practice and a graded lab, and the section ends with a capstone lab and a knowledge check.

## Learning Outcomes

- Identify Deployment template changes and revisions.
- Calculate rolling-update limits.
- Explain health and capacity effects on progress.
- Evaluate rollback compatibility and external state.
- Read the rollout history and roll back to a chosen revision.
- Choose between RollingUpdate, Recreate, blue-green and canary releases and tune `minReadySeconds` and `progressDeadlineSeconds`.
- Stage a StatefulSet update with a partition and choose a DaemonSet update strategy.
- Build a Kustomize base and overlay and read a Helm release history.
