#!/usr/bin/env bash
# Check: the Job scan-report finished successfully (condition Complete).
set -uo pipefail


if ! kubectl -n starfleet get job scan-report >/dev/null 2>&1; then
  echo "FAIL: Job scan-report does not exist in starfleet"
  exit 1
fi
if kubectl -n starfleet wait --for=condition=complete job/scan-report --timeout=120s >/dev/null 2>&1; then
  echo "PASS: Job scan-report is Complete"
  exit 0
fi
echo "FAIL: Job scan-report has not completed"
exit 1
