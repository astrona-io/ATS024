# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl`.
- You can repair a readiness probe, write a PodDisruptionBudget, add an init container, add a topology spread constraint, and set the concurrency and clean-up fields of a CronJob.

The lab starts a kind cluster (Kubernetes 1.35) with one control-plane node and one worker node. The commands for the lab are in the README of this folder.
