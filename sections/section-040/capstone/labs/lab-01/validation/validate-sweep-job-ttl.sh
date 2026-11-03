#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: finished sweep Jobs clean themselves up after 120 seconds, and the schedule is unchanged.
get() { kubectl -n "$NS" get cronjob sweep -o jsonpath="$1" 2>/dev/null; }
[ "$(get '{.spec.jobTemplate.spec.ttlSecondsAfterFinished}')" = "120" ] || { echo "FAIL: ttlSecondsAfterFinished is not 120 in the Job template"; fail=1; }
[ "$(get '{.spec.schedule}')" = "*/5 * * * *" ] || { echo "FAIL: the schedule was changed"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the Job template removes finished Jobs after 120 seconds"
exit "$fail"
