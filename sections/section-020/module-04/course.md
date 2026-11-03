---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Projected Volumes, The Downward API And Configuration Patterns

An application often needs configuration from several places at once: a settings file from a ConfigMap, a token from a Secret, and facts about itself that only the cluster knows, such as its Pod name, its labels and its CPU limit. Mounting each source as its own volume gives the container many directories, and hard-coding the facts into the manifest makes them wrong as soon as the Pod is renamed or rescheduled. This module teaches how to build one directory from many sources, how to let the kubelet fill in facts about the Pod, and how to choose between the delivery methods.

The module has three parts. The first part builds a projected volume that merges a ConfigMap, a Secret and a ServiceAccount token into one directory. The second part uses the downward API to expose Pod fields and container resource values, as environment variables and as files. The third part covers `$(VAR)` expansion in commands and arguments, and the patterns that decide how configuration should reach a container and how a change should roll out.

## Learning goals

After this module you can:

- Build a `projected` volume from a ConfigMap, a Secret, the downward API and a ServiceAccount token.
- Set the path and the file mode of each projected item.
- Expose `fieldRef` values such as the Pod name, the namespace, the node name and the labels.
- Expose `resourceFieldRef` values such as a CPU limit, with a `divisor`.
- State which downward API fields work as environment variables, which work as files, and which of them update.
- Use `$(VAR)` in `command` and `args`, and choose between environment variables, files and command-line arguments.
- Make a Deployment restart when its configuration changes, and pin a configuration with an immutable object.

## Before you start

You need to know how to create a ConfigMap and a Secret, and how a Pod mounts them as volumes and as environment variables. The playground is a single-node `kind` cluster with Kubernetes 1.35. It has the namespaces `starfleet` and `outpost`. In `starfleet` the Deployment `probe` runs one container with CPU and memory requests and limits, and its Pod has two labels. Start it now and keep it running while you read.

<!-- astrona:playground -->
