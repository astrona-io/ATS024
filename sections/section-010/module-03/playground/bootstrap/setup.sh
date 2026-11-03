#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-playground-010-03" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s
kubectl -n starfleet rollout status statefulset/crew --timeout=180s
kubectl -n starfleet rollout status daemonset/scanner --timeout=180s
