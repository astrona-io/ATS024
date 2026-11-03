#!/usr/bin/env bash
# Check: drifter was not deleted, scaled down or shrunk to make room.
set -uo pipefail
fail=0
seed="$(kubectl -n outpost get configmap seed -o jsonpath='{.data.drifter_cpu}' 2>/dev/null)"
replicas="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.replicas}' 2>/dev/null)"
[ "$replicas" = "2" ] || { echo "FAIL: drifter has '${replicas:-no}' replicas, expected 2"; fail=1; }
cpu="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)"
[ -n "$seed" ] && [ "$cpu" = "$seed" ] || { echo "FAIL: the drifter cpu request was changed (now '${cpu:-none}', expected $seed)"; fail=1; }
dprio="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)"
[ -z "$dprio" ] || { echo "FAIL: drifter must keep no priority class"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: drifter was not changed"
exit "$fail"
