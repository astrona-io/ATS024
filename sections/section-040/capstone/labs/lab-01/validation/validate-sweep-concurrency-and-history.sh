#!/usr/bin/env bash
set -uo pipefail
fail=0
NS=starfleet
uid_of() { kubectl -n "$NS" get configmap capstone-uids -o jsonpath="{.data.$1}" 2>/dev/null; }
# Check: the sweep CronJob forbids overlapping runs and keeps one finished Job of each kind.
if [ "$(kubectl -n "$NS" get cronjob sweep -o jsonpath='{.metadata.uid}' 2>/dev/null)" != "$(uid_of sweep)" ]; then
  echo "FAIL: the sweep CronJob was deleted and recreated"; fail=1
fi
get() { kubectl -n "$NS" get cronjob sweep -o jsonpath="$1" 2>/dev/null; }
[ "$(get '{.spec.concurrencyPolicy}')" = "Forbid" ] || { echo "FAIL: concurrencyPolicy is not Forbid"; fail=1; }
[ "$(get '{.spec.successfulJobsHistoryLimit}')" = "1" ] || { echo "FAIL: successfulJobsHistoryLimit is not 1"; fail=1; }
[ "$(get '{.spec.failedJobsHistoryLimit}')" = "1" ] || { echo "FAIL: failedJobsHistoryLimit is not 1"; fail=1; }
[ "$(get '{.spec.suspend}')" != "true" ] || { echo "FAIL: the CronJob is suspended"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: sweep forbids overlap and keeps one successful and one failed Job"
exit "$fail"
