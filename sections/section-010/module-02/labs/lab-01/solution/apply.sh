#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl -n starfleet rollout undo deployment/probe --to-revision=2
kubectl -n starfleet rollout status deployment/probe --timeout=180s
