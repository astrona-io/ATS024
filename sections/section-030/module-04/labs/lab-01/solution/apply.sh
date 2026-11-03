#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-04-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl -n starfleet patch hpa scout --type=merge -p '{"spec":{"minReplicas":3}}'
kubectl -n starfleet wait --for=jsonpath='{.status.readyReplicas}'=3 deployment/scout --timeout=240s
