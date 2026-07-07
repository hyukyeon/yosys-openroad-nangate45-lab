#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PREFIX="${PREFIX:-$REPO_ROOT/.toolchain}"
FLOW_DIR="${FLOW_DIR:-$REPO_ROOT/submodules/openroad-flow-scripts/flow}"
WORK_HOME="${WORK_HOME:-$REPO_ROOT/work/openroad-flow-scripts}"
DESIGN_CONFIG="${DESIGN_CONFIG:-./designs/nangate45/gcd/config.mk}"
OPENROAD_BIN="${OPENROAD_BIN:-$PREFIX/bin/openroad}"
YOSYS_BIN="${YOSYS_BIN:-$PREFIX/bin/yosys}"
KLAYOUT_BIN="${KLAYOUT_BIN:-$(command -v klayout || true)}"

if [ ! -x "$OPENROAD_BIN" ]; then
  echo "OpenROAD binary not found: $OPENROAD_BIN" >&2
  exit 1
fi

if [ ! -x "$YOSYS_BIN" ]; then
  echo "Yosys binary not found: $YOSYS_BIN" >&2
  exit 1
fi

if [ -z "$KLAYOUT_BIN" ]; then
  echo "KLayout not found in PATH." >&2
  exit 1
fi

mkdir -p "$WORK_HOME"

cd "$FLOW_DIR"

make clean_all \
  DESIGN_CONFIG="$DESIGN_CONFIG" \
  WORK_HOME="$WORK_HOME" \
  OPENROAD_EXE="$OPENROAD_BIN" \
  YOSYS_EXE="$YOSYS_BIN" \
  KLAYOUT_CMD="$KLAYOUT_BIN" >/dev/null

make \
  DESIGN_CONFIG="$DESIGN_CONFIG" \
  WORK_HOME="$WORK_HOME" \
  OPENROAD_EXE="$OPENROAD_BIN" \
  YOSYS_EXE="$YOSYS_BIN" \
  KLAYOUT_CMD="$KLAYOUT_BIN" \
  -j1

RESULT_DIR="$WORK_HOME/results/nangate45/gcd/base"

echo
echo "Done."
echo "GDS: $RESULT_DIR/6_final.gds"
echo "DEF: $RESULT_DIR/6_final.def"
echo "Netlist: $RESULT_DIR/6_final.v"
