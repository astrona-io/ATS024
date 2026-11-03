#!/usr/bin/env bash
# Check: the CronJob fleet-report is active and tolerates a late start for a bounded time.
set -uo pipefail


suspend="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.spec.suspend}" 2>/dev/null || true)"
deadline="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.spec.startingDeadlineSeconds}" 2>/dev/null || true)"
fail=0
if [ "$suspend" = "true" ]; then
  echo "FAIL: fleet-report is still suspended"
  fail=1
fi
if [ -z "$deadline" ]; then
  echo "FAIL: startingDeadlineSeconds is not set"
  fail=1
elif [ "$deadline" -lt 30 ] || [ "$deadline" -gt 300 ]; then
  echo "FAIL: startingDeadlineSeconds is $deadline, expected 30 to 300"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: fleet-report is active with startingDeadlineSeconds $deadline"
exit "$fail"
