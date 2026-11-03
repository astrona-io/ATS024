#!/usr/bin/env bash
# Author check: the starting state must fail grading, the reference solution must pass every script.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
run_all() {
  local status=0
  for script in "$lab_directory"/validation/*.sh; do
    bash "$script" || status=1
  done
  return "$status"
}
if run_all; then
  printf 'Starting state unexpectedly passes grading\n' >&2
  exit 1
fi
bash "$lab_directory/solution/apply.sh"
for attempt in $(seq 1 20); do
  if run_all; then exit 0; fi
  sleep 3
done
printf 'Reference result did not pass within the bounded retry period\n' >&2
exit 1
