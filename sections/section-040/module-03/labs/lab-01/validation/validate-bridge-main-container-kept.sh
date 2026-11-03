#!/usr/bin/env bash
# Check: the fix did not take a shortcut. The main container is still named
# bridge, still uses busybox and still tests for /work/config.txt, and the
# work volume is still an emptyDir shared with it.
set -uo pipefail

fail=0
command_text="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.template.spec.containers[?(@.name=="bridge")].command}' 2>/dev/null || true)"
image="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.template.spec.containers[?(@.name=="bridge")].image}' 2>/dev/null || true)"

if [ -z "$command_text" ]; then
  echo "FAIL: the bridge Deployment has no container named bridge"
  exit 1
fi
if ! echo "$command_text" | grep -q "/work/config.txt"; then
  echo "FAIL: the bridge command no longer checks /work/config.txt"
  fail=1
fi
if [ "$image" != "docker.io/library/busybox:1.37.0" ]; then
  echo "FAIL: the bridge image changed to $image"
  fail=1
fi

source_kind="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.template.spec.volumes[?(@.name=="work")].emptyDir}' 2>/dev/null || true)"
if [ -z "$source_kind" ]; then
  echo "FAIL: the work volume is no longer an emptyDir"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the bridge main container and its emptyDir volume are unchanged"
fi
exit "$fail"
