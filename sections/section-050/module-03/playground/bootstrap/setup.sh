#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-playground-050-03" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl create namespace starfleet
kubectl create namespace outpost
kubectl label nodes -l '!node-role.kubernetes.io/control-plane' disk=ssd tier=compute gpu-count=2
