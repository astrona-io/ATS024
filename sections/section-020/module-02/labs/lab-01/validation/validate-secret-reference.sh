#!/usr/bin/env bash
# Check: DB_PASSWORD is a secretKeyRef to scout-db and the value matches without being printed.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1 || { echo "FAIL: scout rollout is not complete"; exit 1; }
fail=0
pods="$(kubectl -n starfleet get pods -l app=scout -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
[ -n "$pods" ] || { echo "FAIL: no running scout pod"; exit 1; }
ref="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}')"
if [ "$ref" != "scout-db/password" ]; then
  echo "FAIL: DB_PASSWORD does not reference key password of scout-db"
  fail=1
fi
expected="$(kubectl -n starfleet get secret scout-db -o jsonpath='{.data.password}' | base64 -d)"
for pod in $pods; do
  actual="$(kubectl -n starfleet exec "$pod" -- printenv DB_PASSWORD 2>/dev/null || true)"
  if [ -z "$actual" ] || [ "$actual" != "$expected" ]; then
    echo "FAIL: $pod does not have the password from scout-db"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: DB_PASSWORD comes from the Secret scout-db"
exit "$fail"
