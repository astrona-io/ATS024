#!/usr/bin/env bash
# Check: shuttle exists, has the team label and accepts an update.
set -uo pipefail
fail=0
if ! kubectl -n starfleet get deployment shuttle >/dev/null 2>&1; then echo "FAIL: deployment shuttle was deleted"; exit 1; fi
label="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.metadata.labels.team}' 2>/dev/null)"
[ -n "$label" ] || { echo "FAIL: shuttle has no team label"; fail=1; }
kubectl -n starfleet annotate deployment shuttle lab.astrona.io/checked=true --overwrite >/dev/null 2>&1 || { echo "FAIL: shuttle cannot be updated"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: shuttle has a team label and can be updated"
exit "$fail"
