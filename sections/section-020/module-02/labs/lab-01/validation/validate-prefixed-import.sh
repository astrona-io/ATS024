#!/usr/bin/env bash
# Check: scout imports scout-settings with prefix SCOUT_ and the running pods have the variables.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-02-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1 || { echo "FAIL: scout rollout is not complete"; exit 1; }
fail=0
pods="$(kubectl -n starfleet get pods -l app=scout -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
[ -n "$pods" ] || { echo "FAIL: no running scout pod"; exit 1; }
names="$(kubectl -n starfleet get deployment scout -o jsonpath='{range .spec.template.spec.containers[0].envFrom[*]}{.configMapRef.name}={.prefix}{"\n"}{end}')"
if ! echo "$names" | grep -qx 'scout-settings=SCOUT_'; then
  echo "FAIL: envFrom does not import scout-settings with prefix SCOUT_"
  fail=1
fi
for pod in $pods; do
  level="$(kubectl -n starfleet exec "$pod" -- printenv SCOUT_LOG_LEVEL 2>/dev/null || true)"
  region="$(kubectl -n starfleet exec "$pod" -- printenv SCOUT_REGION 2>/dev/null || true)"
  if [ "$level" != "info" ] || [ "$region" != "alpha" ]; then
    echo "FAIL: $pod has no SCOUT_LOG_LEVEL=info and SCOUT_REGION=alpha"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: scout imports scout-settings with prefix SCOUT_"
exit "$fail"
