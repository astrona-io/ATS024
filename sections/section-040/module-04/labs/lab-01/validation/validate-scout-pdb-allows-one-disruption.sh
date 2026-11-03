#!/usr/bin/env bash
# Check: scout-pdb lets exactly one scout Pod be evicted at a time and keeps at
# least two available. The values come from the PodDisruptionBudget status
# that the disruption controller computes.
set -uo pipefail

fail=0
for _ in $(seq 1 30); do
  allowed="$(kubectl -n starfleet get pdb scout-pdb -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null || true)"
  [ "$allowed" = "1" ] && break
  sleep 2
done

expected="$(kubectl -n starfleet get pdb scout-pdb -o jsonpath='{.status.expectedPods}' 2>/dev/null || true)"
desired="$(kubectl -n starfleet get pdb scout-pdb -o jsonpath='{.status.desiredHealthy}' 2>/dev/null || true)"
allowed="$(kubectl -n starfleet get pdb scout-pdb -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: PodDisruptionBudget scout-pdb does not exist in starfleet"
  exit 1
fi
if [ "$expected" != "3" ]; then
  echo "FAIL: scout-pdb selects $expected Pods, expected 3"
  fail=1
fi
if [ "$desired" != "2" ]; then
  echo "FAIL: scout-pdb requires $desired healthy Pods, expected 2"
  fail=1
fi
if [ "$allowed" != "1" ]; then
  echo "FAIL: scout-pdb allows $allowed disruptions, expected 1"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-pdb allows one disruption and keeps two Pods available"
fi
exit "$fail"
