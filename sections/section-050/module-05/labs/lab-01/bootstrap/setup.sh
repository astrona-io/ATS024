#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-05-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl create namespace starfleet
kubectl apply -f "$(cd "$(dirname "$0")" && pwd)/start.yaml"
shuttle_uid="$(kubectl -n starfleet get pod shuttle -o jsonpath='{.metadata.uid}')"
kubectl -n starfleet create configmap lab-seed --from-literal=shuttle-uid="$shuttle_uid"
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
kubectl cordon "$worker"
