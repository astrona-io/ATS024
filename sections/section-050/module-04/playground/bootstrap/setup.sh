#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-playground-050-04" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl create namespace starfleet
kubectl create namespace outpost
workers="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].metadata.name}')"
index=0
for worker in $workers; do
  index=$((index + 1))
  zone="zone-a"
  if [ "$index" -gt 1 ]; then zone="zone-b"; fi
  kubectl label node "$worker" "topology.kubernetes.io/zone=$zone" --overwrite
done
