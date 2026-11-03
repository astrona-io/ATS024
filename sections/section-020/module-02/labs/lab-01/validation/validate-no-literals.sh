#!/usr/bin/env bash
# Check: no env entry has a literal value, and Deployment scout is the original object.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1 || { echo "FAIL: scout rollout is not complete"; exit 1; }
fail=0
pods="$(kubectl -n starfleet get pods -l app=scout -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
[ -n "$pods" ] || { echo "FAIL: no running scout pod"; exit 1; }
literals="$(kubectl -n starfleet get deployment scout -o jsonpath='{range .spec.template.spec.containers[0].env[*]}{.name}{"="}{.value}{"\n"}{end}' | grep -v '=$' || true)"
if [ -n "$literals" ]; then
  echo "FAIL: env entries with a literal value remain"
  fail=1
fi
current="$(kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.uid}')"
baseline="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.scout-uid}' 2>/dev/null || true)"
if [ -z "$baseline" ] || [ "$current" != "$baseline" ]; then
  echo "FAIL: Deployment scout was deleted and created again"
  fail=1
fi
replicas="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}')"
if [ "$replicas" != "2" ]; then
  echo "FAIL: scout does not have 2 available replicas"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: no literal setting remains and scout is the original Deployment"
exit "$fail"
