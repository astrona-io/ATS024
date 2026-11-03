#!/usr/bin/env bash
# Check: scout pods run and carry the priority of critical-service.
set -uo pipefail
fail=0
cls="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)"
[ "$cls" = "critical-service" ] || { echo "FAIL: the scout pod template uses priorityClassName '${cls:-none}'"; fail=1; }
kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1 || { echo "FAIL: scout is not rolled out and available"; fail=1; }
prio="$(kubectl -n starfleet get pods -l app=scout --field-selector=status.phase=Running -o jsonpath='{.items[0].spec.priority}' 2>/dev/null)"
[ "$prio" = "100000" ] || { echo "FAIL: no running scout pod has priority 100000 (found '${prio:-none}')"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout runs with priority 100000"
exit "$fail"
