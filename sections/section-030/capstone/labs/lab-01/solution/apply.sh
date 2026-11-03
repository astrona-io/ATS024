#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl -n starfleet set resources deployment scout --requests=cpu=50m,memory=32Mi
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl apply -f "$lab_directory/solution/horizontalpodautoscaler-scout.yaml"
kubectl -n starfleet patch pod bridge --subresource resize --patch \
  '{"spec":{"containers":[{"name":"bridge","resources":{"requests":{"cpu":"400m"},"limits":{"cpu":"400m"}}}]}}'
kubectl -n starfleet wait --for=condition=ScalingActive hpa/scout --timeout=240s
kubectl -n starfleet wait --for=jsonpath='{.status.readyReplicas}'=3 deployment/scout --timeout=240s
