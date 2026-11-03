#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: scout was repaired in place, keeps its readiness probe and has three available replicas.
if [ "$(kubectl -n "$NS" get deployment scout -o jsonpath='{.metadata.uid}' 2>/dev/null)" != "$(uid_of scout)" ]; then
  echo "FAIL: the scout Deployment was deleted and recreated"; fail=1
fi
replicas="$(kubectl -n "$NS" get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null)"
[ "$replicas" = "3" ] || { echo "FAIL: scout has $replicas replicas in its spec, expected 3"; fail=1; }
probe="$(kubectl -n "$NS" get deployment scout -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)"
[ -n "$probe" ] || { echo "FAIL: the readiness probe of scout was removed"; fail=1; }
available="$(kubectl -n "$NS" get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
[ "${available:-0}" = "3" ] || { echo "FAIL: scout has ${available:-0} available replicas, expected 3"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout has three available replicas and keeps its readiness probe"
exit "$fail"
