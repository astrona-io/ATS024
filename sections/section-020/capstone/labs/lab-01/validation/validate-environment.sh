#!/usr/bin/env bash
# Check: envFrom with prefix BEACON_, DB_PASSWORD from beacon-db, no literal env values.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
kubectl -n outpost rollout status deployment/beacon --timeout=90s >/dev/null 2>&1 || { echo "FAIL: beacon rollout is not complete"; exit 1; }
pods="$(kubectl -n outpost get pods -l app=beacon -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
if [ -z "$pods" ]; then
  echo "FAIL: no running beacon pod"
  exit 1
fi
cm="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].envFrom[?(@.configMapRef.name=="beacon-settings")].prefix}')"
[ "$cm" = "BEACON_" ] || { echo "FAIL: beacon-settings is not imported with envFrom and prefix BEACON_"; fail=1; }
key="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}')"
[ "$key" = "beacon-db" ] || { echo "FAIL: DB_PASSWORD is not a secretKeyRef to beacon-db"; fail=1; }
literals="$(kubectl -n outpost get deployment beacon -o jsonpath='{range .spec.template.spec.containers[0].env[*]}{.value}{"\n"}{end}' | grep -c .)"
[ "$literals" = "0" ] || { echo "FAIL: $literals env entries still have a literal value"; fail=1; }
region="$(kubectl -n outpost get configmap beacon-settings -o jsonpath='{.data.REGION}')"
password="$(kubectl -n outpost get secret beacon-db -o jsonpath='{.data.password}' | base64 -d)"
for pod in $pods; do
  [ "$(kubectl -n outpost exec "$pod" -- printenv BEACON_REGION 2>/dev/null || true)" = "$region" ] || { echo "FAIL: $pod has no BEACON_REGION from the ConfigMap"; fail=1; }
  [ "$(kubectl -n outpost exec "$pod" -- printenv DB_PASSWORD 2>/dev/null || true)" = "$password" ] || { echo "FAIL: $pod has no DB_PASSWORD from the Secret"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: environment comes from the ConfigMap and the Secret"
exit "$fail"
