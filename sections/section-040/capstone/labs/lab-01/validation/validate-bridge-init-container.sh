#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: bridge is fixed with an init container and keeps its own startup check.
if [ "$(kubectl -n "$NS" get deployment bridge -o jsonpath='{.metadata.uid}' 2>/dev/null)" != "$(uid_of bridge)" ]; then
  echo "FAIL: the bridge Deployment was deleted and recreated"; fail=1
fi
init="$(kubectl -n "$NS" get deployment bridge -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)"
[ -n "$init" ] || { echo "FAIL: bridge has no init container"; fail=1; }
cmd="$(kubectl -n "$NS" get deployment bridge -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)"
case "$cmd" in *config.ready*) ;; *) echo "FAIL: the bridge container no longer checks for config.ready"; fail=1 ;; esac
ready="$(kubectl -n "$NS" get deployment bridge -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
[ "${ready:-0}" = "1" ] || { echo "FAIL: bridge has ${ready:-0} ready replicas, expected 1"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: bridge starts after an init container prepares its work directory"
exit "$fail"
