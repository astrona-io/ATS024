---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Summary

Kustomize builds manifests from a base and overlays and is built into `kubectl`. The fields `namespace`, `namePrefix`, `labels`, `images` and `replicas` cover common differences, and patches cover the rest. `kubectl kustomize` previews the result, `kubectl diff -k` compares it with the cluster, and `kubectl apply -k` applies it.

Kustomize keeps no release history. A changed overlay starts an ordinary Deployment rollout, and a rollback uses `rollout undo` or the previous version of the files. A generated ConfigMap name carries a content hash, so a content change starts a rollout.

Helm installs charts as releases with numbered revisions stored as Secrets. The commands `upgrade`, `history`, `rollback` and `get values` manage them. A rollback creates a new revision with the content of an earlier one and restores all templated objects, but no data. A failed upgrade leaves the old Pods running until someone rolls back or uses the automatic rollback option.

<!-- astrona:playground:destroy -->
