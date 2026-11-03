---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Summary

A projected volume merges several sources into one directory. ConfigMaps, Secrets, downward API items and ServiceAccount tokens can sit side by side, each with its own path and file mode, and all sources must be in the namespace of the Pod. The kubelet builds the directory and swaps it atomically when a source changes, so a reader sees one consistent state. Environment variables and `subPath` mounts never update.

The downward API passes facts about the Pod to the container without an API call. `fieldRef` supplies fields such as the name, the namespace, the node name and the labels, and `resourceFieldRef` supplies requests and limits with a `divisor`. Some fields work only as variables, and the whole label and annotation maps work only as files. Files update when labels change, variables do not, and a volume needs `containerName` for a resource value.

Command arguments can use `$(NAME)` for variables of the container, an unknown name stays unchanged, and `$$(NAME)` is an escape. The delivery method follows how often the value changes and how the program reads it. A Deployment does not restart when a ConfigMap changes, so a rollout needs a restart, a hash annotation or a versioned immutable object.

<!-- astrona:playground:destroy -->
