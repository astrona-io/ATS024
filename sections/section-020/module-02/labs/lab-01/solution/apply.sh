#!/usr/bin/env bash
# Applies the reference solution. Run only by astrona test.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$directory/deployment-scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
