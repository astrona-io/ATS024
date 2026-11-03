#!/usr/bin/env bash
# Check: the quota keeps its compute limits and caps Deployments at 3.
set -uo pipefail
fail=0
h() { kubectl -n outpost get resourcequota compute -o jsonpath="{.spec.hard['$1']}" 2>/dev/null; }
[ "$(h count/deployments.apps)" = "3" ] || { echo "FAIL: count/deployments.apps is not 3"; fail=1; }
[ "$(h requests.cpu)" = "1" ] || { echo "FAIL: requests.cpu was changed"; fail=1; }
[ "$(h limits.cpu)" = "2" ] || { echo "FAIL: limits.cpu was changed"; fail=1; }
[ "$(h requests.memory)" = "1Gi" ] || { echo "FAIL: requests.memory was changed"; fail=1; }
[ "$(h limits.memory)" = "2Gi" ] || { echo "FAIL: limits.memory was changed"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the quota is intact and caps Deployments at 3"
exit "$fail"
