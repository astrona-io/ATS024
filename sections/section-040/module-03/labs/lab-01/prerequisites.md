# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a Pod `restartPolicy` and an init container work, and how to read Pod status with `kubectl get` and `kubectl describe`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with two faulty workloads, one in `starfleet` and one in `outpost`. The commands for the lab are in the README of this folder.
