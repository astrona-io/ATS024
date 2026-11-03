#!/usr/bin/env bash
# Check: the scout Pod template has a soft topology spread constraint on the
# node name, with maxSkew 1 and a selector for app=scout.
set -uo pipefail

match="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null \
  | jq -r '[.spec.template.spec.topologySpreadConstraints[]?
      | select(.topologyKey == "kubernetes.io/hostname" and .maxSkew == 1
               and .whenUnsatisfiable == "ScheduleAnyway"
               and .labelSelector.matchLabels.app == "scout")] | length')"

if [ "$match" = "1" ]; then
  echo "PASS: scout has a ScheduleAnyway spread constraint on kubernetes.io/hostname"
  exit 0
fi
echo "FAIL: scout needs one topologySpreadConstraint with topologyKey kubernetes.io/hostname, maxSkew 1, whenUnsatisfiable ScheduleAnyway and labelSelector app=scout"
exit 1
