---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Summary

`kubectl create configmap` and `kubectl create secret generic` build objects from literal values, files and environment files. A file gives one key that holds the whole file, and an environment file gives one key for each line. The option `--dry-run=client -o yaml` prints a manifest to edit and apply.

A container receives a single key through `configMapKeyRef` or `secretKeyRef`, and a whole object through `envFrom` with an optional `prefix`. Only a single `env` entry can rename a key. A missing object or key stops the container with `CreateContainerConfigError`, unless the reference is `optional`. A variable defined in `env` wins over the same name from `envFrom`, and the last `envFrom` source wins among several.

A volume can select keys with `items`, set permissions with `defaultMode` and place one file with `subPath`. Environment variables and `subPath` files never follow an update, while a whole volume follows it after the kubelet sync. An `immutable` object cannot change at all, so a new configuration needs a new object and a rollout.

<!-- astrona:playground:destroy -->
