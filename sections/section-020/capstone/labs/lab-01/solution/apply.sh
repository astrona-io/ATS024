#!/usr/bin/env bash
# Applies the reference solution. Run only by astrona test.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
directory="$(cd "$(dirname "$0")" && pwd)"
kubectl -n outpost delete secret registry-creds
kubectl -n outpost create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=beacon \
  --docker-password=disposable-pass
kubectl -n outpost patch serviceaccount beacon -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'
kubectl -n outpost patch configmap beacon-settings --type merge -p '{"immutable":true}'
kubectl apply -f "$directory/deployment-beacon.yaml"
kubectl -n outpost rollout status deployment/beacon --timeout=180s
