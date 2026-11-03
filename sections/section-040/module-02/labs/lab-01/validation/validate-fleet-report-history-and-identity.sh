#!/usr/bin/env bash
# Check: the CronJob keeps a short history and is the original object, not a recreated one.
set -uo pipefail


success="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.spec.successfulJobsHistoryLimit}" 2>/dev/null || true)"
failed="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.spec.failedJobsHistoryLimit}" 2>/dev/null || true)"
uid="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.metadata.uid}" 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap lab-baseline -o jsonpath="{.data.cronjob-uid}" 2>/dev/null || true)"
fail=0
if [ -z "$success" ] || [ "$success" -gt 3 ]; then
  echo "FAIL: successfulJobsHistoryLimit is \"$success\", expected 0 to 3"
  fail=1
fi
if [ -z "$failed" ] || [ "$failed" -gt 3 ]; then
  echo "FAIL: failedJobsHistoryLimit is \"$failed\", expected 0 to 3"
  fail=1
fi
if [ -z "$uid" ] || [ "$uid" != "$recorded" ]; then
  echo "FAIL: fleet-report was deleted and created again; edit the original"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: fleet-report keeps $success and $failed finished Jobs and is the original object"
exit "$fail"
