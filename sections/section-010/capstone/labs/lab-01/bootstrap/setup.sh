#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet annotate deployment/probe kubernetes.io/change-cause="Switch image to an unpublished tag" --overwrite
kubectl -n starfleet set image deployment/probe probe=docker.io/library/python:ckad-missing-image
