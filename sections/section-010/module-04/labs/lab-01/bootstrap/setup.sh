#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-04-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl get namespace outpost
