#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: the scout pod template spreads pods over nodes without blocking scheduling.
spread="$(kubectl -n "$NS" get deployment scout -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}|{.spec.template.spec.topologySpreadConstraints[0].maxSkew}|{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}|{.spec.template.spec.topologySpreadConstraints[0].labelSelector.matchLabels.app}' 2>/dev/null)"
if [ "$spread" != "kubernetes.io/hostname|1|ScheduleAnyway|scout" ]; then
  echo "FAIL: expected a spread constraint kubernetes.io/hostname, maxSkew 1, ScheduleAnyway, selector app=scout; found: $spread"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: scout declares a topology spread constraint by node"
exit "$fail"
