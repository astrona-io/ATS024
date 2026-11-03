# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl` and `python3` (the start script uses it to size the workloads).
- You know what a PriorityClass is, how preemption works and how the QoS class is assigned.

The lab starts a Kubernetes 1.35 kind cluster with one control plane node and one worker node.
