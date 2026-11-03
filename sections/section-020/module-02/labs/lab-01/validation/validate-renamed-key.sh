#!/usr/bin/env bash
# Check: APP_MODE is a renamed key reference to mode of scout-settings.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1 || { echo "FAIL: scout rollout is not complete"; exit 1; }
fail=0
pods="$(kubectl -n starfleet get pods -l app=scout -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
[ -n "$pods" ] || { echo "FAIL: no running scout pod"; exit 1; }
ref="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="APP_MODE")].valueFrom.configMapKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name=="APP_MODE")].valueFrom.configMapKeyRef.key}')"
if [ "$ref" != "scout-settings/mode" ]; then
  echo "FAIL: APP_MODE does not reference key mode of scout-settings"
  fail=1
fi
for pod in $pods; do
  mode="$(kubectl -n starfleet exec "$pod" -- printenv APP_MODE 2>/dev/null || true)"
  if [ "$mode" != "standby" ]; then
    echo "FAIL: $pod has no APP_MODE=standby"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: APP_MODE comes from the key mode"
exit "$fail"
