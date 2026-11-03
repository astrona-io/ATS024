---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Summary

A Secret has a type, and the type fixes the required keys. `Opaque` accepts anything, while `kubernetes.io/basic-auth`, `kubernetes.io/tls` and `kubernetes.io/dockerconfigjson` are checked by the API server when the object is written. The type of an existing Secret cannot change, so a wrong type means delete and create again. Cluster-owned types include the ServiceAccount token Secret, which is a long-lived credential, and the bootstrap token Secret that lets a node join.

`kubectl create secret tls` builds a TLS Secret from a certificate file and a key file, and `kubectl create secret docker-registry` builds the registry login. The kubelet pulls images, so it needs registry credentials from `imagePullSecrets`. A Pod can list the Secret itself, or its ServiceAccount can carry the list, and the ServiceAccount admission controller copies it into new Pods only.

Protection has several layers. RBAC limits who reads Secrets, `resourceNames` narrows a rule to named objects, and rights to create Pods or run commands inside them give indirect access. Encryption at rest, set by an `EncryptionConfiguration` on the API server, protects the data in etcd and in backups, but it does not hide a Secret from a user who is allowed to read it through the API.

<!-- astrona:playground:destroy -->
