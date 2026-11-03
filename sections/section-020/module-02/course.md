---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Create ConfigMaps And Secrets And Inject Environment Variables

Most applications read configuration from environment variables, command-line flags and files. This module shows how to create ConfigMaps and Secrets quickly with `kubectl`, how to inject their keys into a container as environment variables, and how to pick, protect and freeze the files that a volume delivers. On the exam these are the tasks you do by hand under time pressure, so you practice the exact commands.

The module has three parts. The first part creates ConfigMaps and Secrets from literal values, files and environment files, and shows how `--dry-run=client -o yaml` generates a manifest. The second part injects keys with `valueFrom` and `envFrom`, covers `prefix` and `optional`, and explains what happens to keys that are not valid variable names. The third part selects files with `items`, sets `defaultMode`, uses `subPath` and `immutable`, and sums up which delivery paths follow an update.

## Learning goals

After this module you can:

- Create a ConfigMap or Secret with `--from-literal`, `--from-file` and `--from-env-file`.
- Generate a manifest with `--dry-run=client -o yaml` instead of writing YAML by hand.
- Inject a single key with `configMapKeyRef` or `secretKeyRef`, and a whole object with `envFrom`.
- Rename or prefix keys and explain what `optional` changes.
- Select keys with `items`, set `defaultMode` and explain the `subPath` limit.
- Mark an object `immutable` and state what that prevents.

## Before you start

You need to know what a Pod, a Deployment and a namespace are, and how to run `kubectl apply` and `kubectl get`. The playground is a single-node `kind` cluster with Kubernetes 1.35. It has the namespaces `starfleet` and `outpost`, and a `shuttle` Deployment in `starfleet` that runs a `busybox` container you can use as a client. Start it now and keep it running while you read.

<!-- astrona:playground -->
