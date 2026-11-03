# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl`.
- You know what a ValidatingAdmissionPolicy and a binding are and how a CEL expression reads `object`.

The lab starts a Kubernetes 1.35 kind cluster with one control plane node and one worker node.
