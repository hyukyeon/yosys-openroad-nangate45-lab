#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PREFIX="${PREFIX:-$REPO_ROOT/.toolchain}"
BUILD_ROOT="${BUILD_ROOT:-$REPO_ROOT/build}"
YOSYS_SRC="$REPO_ROOT/submodules/yosys"
OPENROAD_SRC="$REPO_ROOT/submodules/openroad"
ORFS_SRC="$REPO_ROOT/submodules/openroad-flow-scripts"
NPROCS="${NPROCS:-$(nproc)}"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

for cmd in git cmake ninja python3 bison flex gcc g++ pkg-config; do
  require_cmd "$cmd"
done

git -C "$REPO_ROOT" submodule update --init --recursive

mkdir -p "$PREFIX" "$BUILD_ROOT"

cmake -S "$YOSYS_SRC" -B "$BUILD_ROOT/yosys" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$BUILD_ROOT/yosys" --parallel "$NPROCS"
cmake --install "$BUILD_ROOT/yosys"

cmake -S "$OPENROAD_SRC" -B "$BUILD_ROOT/openroad" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$BUILD_ROOT/openroad" --parallel "$NPROCS"
cmake --install "$BUILD_ROOT/openroad"

if [ ! -d "$ORFS_SRC/flow" ]; then
  echo "OpenROAD-flow-scripts submodule is missing or incomplete." >&2
  exit 1
fi

echo
echo "Build complete."
echo "Install prefix: $PREFIX"
echo "Yosys: $PREFIX/bin/yosys"
echo "OpenROAD: $PREFIX/bin/openroad"
echo "Next: $REPO_ROOT/scripts/run-nangate45-gcd.sh"
