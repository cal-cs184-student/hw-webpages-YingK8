#!/bin/bash
# Part 5 writeup render automation (adaptive sampling)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BUILD_DIR="$REPO_ROOT/build"
OUTPUT_DIR="$REPO_ROOT/docs/images/part5"
SCENE_DIR="$REPO_ROOT/dae/sky"
BIN="$BUILD_DIR/pathtracer"

SAMPLES_PER_PIXEL="${SAMPLES_PER_PIXEL:-2048}"
LIGHT_SAMPLES="${LIGHT_SAMPLES:-1}"
MAX_DEPTH="${MAX_DEPTH:-5}"
THREADS="${THREADS:-8}"
WIDTH="${WIDTH:-480}"
HEIGHT="${HEIGHT:-360}"
SAMPLES_PER_BATCH="${SAMPLES_PER_BATCH:-32}"
MAX_TOLERANCE="${MAX_TOLERANCE:-0.05}"

if [[ ! -x "$BIN" ]]; then
  echo "Error: pathtracer binary not found at $BIN"
  echo "Build first from repo root:"
  echo "  mkdir -p build && cd build && cmake .. && make -j"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

render_scene() {
  local scene_name="$1"
  local scene_path="$2"
  local output_png="$OUTPUT_DIR/p5_${scene_name}.png"

  echo "Rendering ${scene_name}..."
  "$BIN" \
    -s "$SAMPLES_PER_PIXEL" \
    -l "$LIGHT_SAMPLES" \
    -m "$MAX_DEPTH" \
    -t "$THREADS" \
    -r "$WIDTH" "$HEIGHT" \
    -a "$SAMPLES_PER_BATCH" "$MAX_TOLERANCE" \
    -f "$output_png" \
    "$scene_path"

  echo "  Wrote: $output_png"
  echo "  Wrote: ${output_png%.png}_rate.png"
}

# render_scene "cbbunny" "$SCENE_DIR/CBbunny.dae"
render_scene "cbspheres" "$SCENE_DIR/CBspheres_lambertian.dae"

echo "Done. Part 5 images are in: $OUTPUT_DIR"
