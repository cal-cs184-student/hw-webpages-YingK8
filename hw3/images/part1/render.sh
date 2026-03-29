#!/bin/bash
# Part 1: Ray Generation and Scene Intersection rendering script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(cd "$SCRIPT_DIR/../../build" && pwd)"
PROJECT_DIR="$(cd "$BUILD_DIR/.." && pwd)"
PATHTRACER_BIN="$BUILD_DIR/pathtracer"

echo "============================================================"
echo "  Part 1: Ray Generation and Scene Intersection"
echo "============================================================"
echo ""

# User-selected scene set and report-quality defaults
SCENE_1="$PROJECT_DIR/dae/sky/CBspheres_lambertian.dae"
SCENE_2="$PROJECT_DIR/dae/keenan/banana.dae"

THREADS=8
WIDTH=800
HEIGHT=600
SPP=16
LIGHTS=1
DEPTH=2

BUILD_OUTDIR="$BUILD_DIR/part1/outputs"
DOCS_OUTDIR="$PROJECT_DIR/docs/images/part1"

mkdir -p "$BUILD_OUTDIR"
mkdir -p "$DOCS_OUTDIR"

render() {
  local name="$1"
  local scene="$2"

  echo "Rendering: $name"
  "$PATHTRACER_BIN" -s "$SPP" -l "$LIGHTS" -m "$DEPTH" -t "$THREADS" -r "$WIDTH" "$HEIGHT" -f "$BUILD_OUTDIR/$name" "$scene"
  echo "  -> $BUILD_OUTDIR/$name"
}

echo "[1/2] Rendering selected Part 1 scenes"
echo ""

render "p1_CBspheres_lambertian.png" "$SCENE_1"
render "p1_banana.png" "$SCENE_2"

echo ""
echo "[2/2] Copying outputs to docs"
cp -f "$BUILD_OUTDIR"/*.png "$DOCS_OUTDIR"/

echo ""
echo "Done. Generated Part 1 images:"
ls -1 "$BUILD_OUTDIR"/*.png
echo ""
echo "Copied images to: $DOCS_OUTDIR"
