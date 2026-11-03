#!/usr/bin/env bash
# Check: shuttle is the original Deployment, has 2 available replicas and no literal env value.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-04-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
current="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
baseline="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.shuttle-uid}' 2>/dev/null || true)"
if [ -z "$current" ] || [ -z "$baseline" ] || [ "$current" != "$baseline" ]; then
  echo "FAIL: Deployment shuttle was deleted and created again"
  exit 1
fi
available="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.status.availableReplicas}')"
[ "$available" = "2" ] || { echo "FAIL: expected 2 available replicas, found '${available:-0}'"; fail=1; }
literals="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{range .spec.template.spec.containers[0].env[*]}{.value}{"\n"}{end}' | grep -c .)"
[ "$literals" = "0" ] || { echo "FAIL: $literals env entries still have a literal value"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the original Deployment is healthy and has no literal variables"
exit "$fail"
