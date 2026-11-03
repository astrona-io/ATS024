#!/usr/bin/env bash
# Check: the Job still runs the original scan task on the original image.
set -uo pipefail


image="$(kubectl -n starfleet get job scan-report -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null || true)"
command="$(kubectl -n starfleet get job scan-report -o jsonpath="{.spec.template.spec.containers[0].command}" 2>/dev/null || true)"
case "$image" in
  *busybox:1.37.0) ;;
  *) echo "FAIL: scan-report image is \"$image\", expected busybox:1.37.0"; exit 1 ;;
esac
case "$command" in
  */data/attempt*) echo "PASS: scan-report still runs the original task" ;;
  *) echo "FAIL: the scan command no longer uses /data/attempt"; exit 1 ;;
esac
