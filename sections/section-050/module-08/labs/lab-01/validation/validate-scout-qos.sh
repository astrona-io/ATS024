#!/usr/bin/env bash
# Check: the running scout pod is Guaranteed and still requests the seeded CPU.
set -uo pipefail
fail=0
seed="$(kubectl -n outpost get configmap seed -o jsonpath='{.data.scout_cpu}' 2>/dev/null)"
qos="$(kubectl -n starfleet get pods -l app=scout --field-selector=status.phase=Running -o jsonpath='{.items[0].status.qosClass}' 2>/dev/null)"
[ "$qos" = "Guaranteed" ] || { echo "FAIL: the running scout pod has QoS class '${qos:-none}', expected Guaranteed"; fail=1; }
cpu="$(kubectl -n starfleet get pods -l app=scout --field-selector=status.phase=Running -o jsonpath='{.items[0].spec.containers[0].resources.requests.cpu}' 2>/dev/null)"
[ -n "$seed" ] && [ "$cpu" = "$seed" ] || { echo "FAIL: the scout cpu request is '${cpu:-none}', expected the original $seed"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout is Guaranteed with its original cpu request"
exit "$fail"
