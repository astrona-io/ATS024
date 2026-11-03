#!/usr/bin/env bash
# Check: beacon-settings is immutable and keeps all four keys.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
immutable="$(kubectl -n outpost get configmap beacon-settings -o jsonpath='{.immutable}' 2>/dev/null || true)"
[ "$immutable" = "true" ] || { echo "FAIL: beacon-settings is not immutable"; fail=1; }
for key in LOG_LEVEL REGION mode banner; do
  value="$(kubectl -n outpost get configmap beacon-settings -o jsonpath="{.data.$key}" 2>/dev/null || true)"
  [ -n "$value" ] || { echo "FAIL: key $key is missing from beacon-settings"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: beacon-settings is immutable with all keys"
exit "$fail"
