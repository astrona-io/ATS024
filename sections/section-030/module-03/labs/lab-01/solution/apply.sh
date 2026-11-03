#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl -n starfleet patch pod bridge --subresource resize --patch \
  '{"spec":{"containers":[{"name":"bridge","resources":{"requests":{"cpu":"300m"},"limits":{"cpu":"300m"}}}]}}'
kubectl -n starfleet scale deployment scout --replicas=3
kubectl -n starfleet rollout status deployment/scout --timeout=180s
