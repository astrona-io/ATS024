#!/usr/bin/env bash
# Check: PriorityClass critical-service exists with value 100000 and is not the global default.
set -uo pipefail
fail=0
value="$(kubectl get priorityclass critical-service -o jsonpath='{.value}' 2>/dev/null)"
[ "$value" = "100000" ] || { echo "FAIL: critical-service value is '${value:-missing}', expected 100000"; fail=1; }
default="$(kubectl get priorityclass critical-service -o jsonpath='{.globalDefault}' 2>/dev/null)"
[ "$default" != "true" ] || { echo "FAIL: critical-service must not be the global default"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: PriorityClass critical-service is correct"
exit "$fail"
