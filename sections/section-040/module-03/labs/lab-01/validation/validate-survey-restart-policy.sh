#!/usr/bin/env bash
# Check: drifter-survey exists, keeps its task command and no longer restarts
# a container that exits with code 0.
set -uo pipefail

fail=0
policy="$(kubectl -n outpost get pod drifter-survey -o jsonpath='{.spec.restartPolicy}' 2>/dev/null || true)"
if [ -z "$policy" ]; then
  echo "FAIL: the Pod drifter-survey does not exist in outpost"
  exit 1
fi
if [ "$policy" != "OnFailure" ] && [ "$policy" != "Never" ]; then
  echo "FAIL: restartPolicy is $policy; it must be OnFailure or Never"
  fail=1
fi

command_text="$(kubectl -n outpost get pod drifter-survey -o jsonpath='{.spec.containers[?(@.name=="survey")].command}' 2>/dev/null || true)"
if ! echo "$command_text" | grep -q "survey-complete"; then
  echo "FAIL: the survey container no longer runs the survey task"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-survey has restartPolicy $policy and keeps its task"
fi
exit "$fail"
