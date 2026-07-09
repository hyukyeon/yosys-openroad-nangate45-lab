#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run-stage.sh <target> <project_name> [extra make args...]

Examples:
  ./scripts/run-stage.sh synth riscv
  ./scripts/run-stage.sh floorplan riscv
  ./scripts/run-stage.sh all riscv
  ./scripts/run-stage.sh clean_route riscv
  ./scripts/run-stage.sh open_place riscv

Project config path:
  projects/<project_name>/configs/nangate45/<project_name>.mk
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$#" -lt 2 ]; then
  usage >&2
  exit 1
fi

TARGET="$1"
PROJECT_NAME="$2"
shift 2

FLOW_DIR="${FLOW_DIR:-$REPO_ROOT/submodules/openroad-flow-scripts/flow}"
WORK_HOME="${WORK_HOME:-$REPO_ROOT/work/openroad-flow-scripts}"
PREFIX="${PREFIX:-$REPO_ROOT/.toolchain}"
OPENROAD_BIN="${OPENROAD_BIN:-$PREFIX/bin/openroad}"
YOSYS_BIN="${YOSYS_BIN:-$PREFIX/bin/yosys}"
KLAYOUT_BIN="${KLAYOUT_BIN:-$(command -v klayout || true)}"
DESIGN_CONFIG="${DESIGN_CONFIG:-$REPO_ROOT/projects/$PROJECT_NAME/configs/nangate45/$PROJECT_NAME.mk}"

if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "Invalid project name: $PROJECT_NAME" >&2
  exit 1
fi

if [ ! -f "$DESIGN_CONFIG" ]; then
  echo "Project config not found: $DESIGN_CONFIG" >&2
  exit 1
fi

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

make "$TARGET" \
  DESIGN_CONFIG="$DESIGN_CONFIG" \
  WORK_HOME="$WORK_HOME" \
  OPENROAD_EXE="$OPENROAD_BIN" \
  YOSYS_EXE="$YOSYS_BIN" \
  KLAYOUT_CMD="$KLAYOUT_BIN" \
  "$@"
