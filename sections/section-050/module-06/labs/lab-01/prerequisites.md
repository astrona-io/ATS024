# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl`.
- You know what a LimitRange and a ResourceQuota are and how a pod gets its requests and limits.

The lab starts a Kubernetes 1.35 kind cluster with one control plane node and one worker node.
