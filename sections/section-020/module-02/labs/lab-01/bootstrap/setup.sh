#!/usr/bin/env bash
# Starting state for the environment variable lab.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$lab_directory/bootstrap/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
uid="$(kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.uid}')"
kubectl -n kube-system create configmap lab-baseline --from-literal=scout-uid="$uid"
