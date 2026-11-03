#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=restricted --overwrite
for worker in $(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].metadata.name}'); do
  kubectl uncordon "$worker"
done
kubectl apply -f "$solution_directory/deployment-scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=240s
