#!/usr/bin/env bash
# Check: a Container LimitRange in outpost has the required defaults and maximum.
set -uo pipefail
fail=0
q() { kubectl -n outpost get limitrange -o jsonpath="{range .items[*].spec.limits[?(@.type=='Container')]}{$1}{'\n'}{end}" 2>/dev/null | head -n1; }
[ "$(q .defaultRequest.cpu)" = "100m" ] || { echo "FAIL: defaultRequest.cpu is not 100m"; fail=1; }
[ "$(q .defaultRequest.memory)" = "64Mi" ] || { echo "FAIL: defaultRequest.memory is not 64Mi"; fail=1; }
[ "$(q .default.cpu)" = "200m" ] || { echo "FAIL: default.cpu is not 200m"; fail=1; }
[ "$(q .default.memory)" = "128Mi" ] || { echo "FAIL: default.memory is not 128Mi"; fail=1; }
[ "$(q .max.cpu)" = "500m" ] || { echo "FAIL: max.cpu is not 500m"; fail=1; }
[ "$(q .max.memory)" = "256Mi" ] || { echo "FAIL: max.memory is not 256Mi"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the LimitRange has the required defaults and maximum"
exit "$fail"
