---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Secret Types And Special Uses

Not every Secret is a password in an `Opaque` object. Kubernetes gives Secrets a `type`, and the type decides which keys must exist and which component reads the object. A TLS certificate for a Service, the credentials that let a node pull an image from a private registry, and the token of a ServiceAccount are all Secrets, and each has its own rules. This module teaches the types, how to create them and who uses them. It also covers how to restrict access to Secrets and how to encrypt them at rest.

The module has four parts. The first part lists the built-in types and the keys each requires, and shows that the API server rejects an object with a missing key. The second part creates a TLS Secret with `openssl` and a registry Secret with `kubectl create secret docker-registry`. The third part attaches registry credentials to a Pod and to a ServiceAccount through `imagePullSecrets`. The fourth part protects Secrets with RBAC, and explains encryption at rest with an `EncryptionConfiguration`.

## Learning goals

After this module you can:

- Name the built-in Secret types and the required keys of each.
- Create a `kubernetes.io/tls` Secret and a `kubernetes.io/dockerconfigjson` Secret with `kubectl`.
- Attach registry credentials to a Pod and to a ServiceAccount with `imagePullSecrets`.
- Explain why base64 is not protection, and limit reads with RBAC and `resourceNames`.
- Describe what an `EncryptionConfiguration` does and how to check that a Secret is encrypted in etcd.
- Explain why a ServiceAccount token Secret is a long-lived credential and why the type needs a manual step.

## Before you start

You need to know the difference between a ConfigMap and a Secret, and how to create an object from the command line. You also need the `openssl` command on your machine for the TLS part. The playground is a single-node `kind` cluster with Kubernetes 1.35, with the namespaces `starfleet` and `outpost` and the `probe` Deployment in `starfleet`. Start it now and keep it running while you read.

<!-- astrona:playground -->
