#!/usr/bin/env bash
# Check: the scout Pod template tolerates the not-ready and unreachable
# NoExecute taints for exactly 30 seconds.
set -uo pipefail

fail=0
for key in node.kubernetes.io/not-ready node.kubernetes.io/unreachable; do
  seconds="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null \
    | jq -r --arg key "$key" '[.spec.template.spec.tolerations[]? | select(.key == $key and .effect == "NoExecute") | .tolerationSeconds] | first // "none"')"
  if [ "$seconds" != "30" ]; then
    echo "FAIL: scout template has tolerationSeconds $seconds for $key, expected 30"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout tolerates not-ready and unreachable nodes for 30 seconds"
fi
exit "$fail"
