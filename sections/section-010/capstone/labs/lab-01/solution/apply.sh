#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl -n starfleet rollout undo deployment/probe --to-revision=1
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet patch deployment probe --patch-file "$solution_directory/deployment-probe-safety.yaml"
kubectl -n starfleet annotate deployment/probe kubernetes.io/change-cause="Ship version v2 with a rolling update" --overwrite
kubectl -n starfleet set env deployment/probe VERSION=v2
kubectl -n starfleet rollout status deployment/probe --timeout=180s
