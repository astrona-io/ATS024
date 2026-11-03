#!/usr/bin/env bash
# Check: probe-pdb selects the two probe Pods and allows one disruption.
set -uo pipefail

fail=0
for _ in $(seq 1 30); do
  expected="$(kubectl -n starfleet get pdb probe-pdb -o jsonpath='{.status.expectedPods}' 2>/dev/null || true)"
  [ "$expected" = "2" ] && break
  sleep 2
done

expected="$(kubectl -n starfleet get pdb probe-pdb -o jsonpath='{.status.expectedPods}' 2>/dev/null || true)"
allowed="$(kubectl -n starfleet get pdb probe-pdb -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null || true)"
desired="$(kubectl -n starfleet get pdb probe-pdb -o jsonpath='{.status.desiredHealthy}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: PodDisruptionBudget probe-pdb does not exist in starfleet"
  exit 1
fi
if [ "$expected" != "2" ]; then
  echo "FAIL: probe-pdb selects $expected Pods, expected the 2 probe Pods"
  fail=1
fi
if [ "$desired" != "1" ] || [ "$allowed" != "1" ]; then
  echo "FAIL: probe-pdb requires $desired healthy and allows $allowed disruptions, expected 1 and 1"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe-pdb selects both probe Pods and allows one disruption"
fi
exit "$fail"
