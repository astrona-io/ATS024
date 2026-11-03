#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: the PodDisruptionBudget scout still protects scout but allows at least one eviction.
if [ "$(kubectl -n "$NS" get pdb scout -o jsonpath='{.metadata.uid}' 2>/dev/null)" != "$(uid_of pdb)" ]; then
  echo "FAIL: the PodDisruptionBudget scout is missing or was deleted and recreated"; fail=1
fi
allowed="$(kubectl -n "$NS" get pdb scout -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null)"
desired="$(kubectl -n "$NS" get pdb scout -o jsonpath='{.status.desiredHealthy}' 2>/dev/null)"
expected="$(kubectl -n "$NS" get pdb scout -o jsonpath='{.status.expectedPods}' 2>/dev/null)"
[ "${allowed:-0}" -ge 1 ] 2>/dev/null || { echo "FAIL: disruptionsAllowed is ${allowed:-0}, expected at least 1"; fail=1; }
[ "${desired:-0}" -ge 2 ] 2>/dev/null || { echo "FAIL: desiredHealthy is ${desired:-0}; the budget must keep at least 2 pods available"; fail=1; }
[ "${expected:-0}" = "3" ] || { echo "FAIL: the budget selects ${expected:-0} pods, expected 3"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the budget allows one eviction and keeps at least two scout pods"
exit "$fail"
