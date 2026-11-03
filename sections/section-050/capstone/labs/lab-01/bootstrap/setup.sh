#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl create namespace starfleet
kubectl apply -f "$(cd "$(dirname "$0")" && pwd)/start.yaml"
index=0
for worker in $(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].metadata.name}'); do
  index=$((index + 1))
  zone="zone-a"
  if [ "$index" -gt 1 ]; then zone="zone-b"; fi
  kubectl label node "$worker" pool=dedicated "topology.kubernetes.io/zone=$zone" --overwrite
  kubectl taint node "$worker" dedicated=scout:NoSchedule --overwrite
  if [ "$index" -gt 1 ]; then kubectl cordon "$worker"; fi
done
