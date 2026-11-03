---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Configuration And Confidential Input Delivery

An application needs settings and credentials that change between environments. Baking them into the image forces a rebuild for every change, and writing them into a manifest makes the secret values visible to everyone who can read the manifest. ConfigMaps and Secrets keep this input in separate objects, and the kubelet delivers it to the container as files or as environment variables. This module explains how the two objects are stored, how the kubelet delivers them, and which parts of that delivery update while a Pod runs.

## Learning goals

After this module you can:

- Choose file or environment delivery for configuration.
- Explain namespace and key references.
- Distinguish input updates from application reload.
- Evaluate confidentiality, indirect access and rotation.

## Before you start

You need a basic understanding of Pods and Deployments. The playground is a single-node `kind` cluster with Kubernetes 1.35. Start it now and keep it running while you read. The graded labs of this module use independent environments.

## Reading order

The first part covers ConfigMaps, Secrets and how the kubelet delivers them. The second part covers how Secrets are stored and how a rotation reaches a running container. The third part is a guided practice that consumes a mounted ConfigMap, and the module ends with a summary.

<!-- astrona:playground -->
