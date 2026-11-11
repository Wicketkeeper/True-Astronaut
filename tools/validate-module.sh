#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

test -s module.prop
grep -q '^id=true_astronaut$' module.prop
grep -q '^version=' module.prop
test -s customize.sh
test -s service.sh
test -s action.sh
test -s docs/SINGULARITY_PORT_MATRIX.md
test -s docs/FEATURE_PORT_PLAN.md
test -s tools/collect-device-audit.sh

for script in customize.sh service.sh action.sh tools/collect-device-audit.sh; do
  sh -n "$script"
done

echo "True Astronaut module structure and shell syntax: OK"
