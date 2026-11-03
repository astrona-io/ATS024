---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Managing Deployments With Kustomize And Helm

Real applications run in several environments with the same structure and different details: the number of replicas, the image tag, the namespace. Copying and editing YAML for each environment leads to drift. Kustomize and Helm both generate the final manifests from shared sources, and both change how updates and rollbacks are done.

## Learning Goals

- Build a Kustomize base and an overlay and apply it with `kubectl apply -k`.
- Use the `images`, `replicas`, `namePrefix`, `labels` and `patches` fields.
- Preview and compare the result before applying.
- Read a Helm release: upgrade, history, rollback and values.
- Explain how a Kustomize update differs from a Helm release rollback.

## Before You Start

You need to write Kubernetes YAML for a Deployment. The module playground has a `starfleet` namespace with a running `probe` Deployment and an empty `outpost` namespace. Helm is not installed in the playground, so the Helm chapter is reading and command reference.

## Reading Order

1. Kustomize Bases, Overlays And Patches
2. Helm Releases: Upgrade, History And Rollback
3. Summary

<!-- astrona:playground -->
