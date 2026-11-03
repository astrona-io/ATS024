#!/usr/bin/env bash
# Check: POD_NAME and CPU_MILLI come from the downward API and are right in running Pods.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-04-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
kubectl -n starfleet rollout status deployment/shuttle --timeout=90s >/dev/null 2>&1 || { echo "FAIL: shuttle rollout is not complete"; exit 1; }
pods="$(kubectl -n starfleet get pods -l app=shuttle -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
if [ -z "$pods" ]; then
  echo "FAIL: no running shuttle pod"
  exit 1
fi
field="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="POD_NAME")].valueFrom.fieldRef.fieldPath}')"
[ "$field" = "metadata.name" ] || { echo "FAIL: POD_NAME is not a fieldRef to metadata.name"; fail=1; }
resource="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="CPU_MILLI")].valueFrom.resourceFieldRef.resource}')"
divisor="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="CPU_MILLI")].valueFrom.resourceFieldRef.divisor}')"
[ "$resource" = "limits.cpu" ] || { echo "FAIL: CPU_MILLI is not a resourceFieldRef to limits.cpu"; fail=1; }
[ "$divisor" = "1m" ] || { echo "FAIL: CPU_MILLI has divisor '$divisor', expected 1m"; fail=1; }
for pod in $pods; do
  name="$(kubectl -n starfleet exec "$pod" -- printenv POD_NAME 2>/dev/null || true)"
  [ "$name" = "$pod" ] || { echo "FAIL: $pod has POD_NAME '$name'"; fail=1; }
  cpu="$(kubectl -n starfleet exec "$pod" -- printenv CPU_MILLI 2>/dev/null || true)"
  [ "$cpu" = "500" ] || { echo "FAIL: $pod has CPU_MILLI '$cpu', expected 500"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: downward API variables are correct in every running Pod"
exit "$fail"
