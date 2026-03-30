#!/usr/bin/env bash
set -euo pipefail

# Render missing Part 4 deliverables:
# 1) Unaccumulated mth-bounce set: m = 0..5, -o 0
# 2) Accumulated-bounce set: m = 0..5, -o 1
# 3) Russian Roulette set: m = 0,1,2,3,4,100, -o 1
#
# Usage:
#   bash docs/images/part4/render_missing.sh            # execute renders
#   bash docs/images/part4/render_missing.sh --dry-run  # print commands only
#
# Optional env vars:
#   PT_THREADS=8
#   PT_WIDTH=480
#   PT_HEIGHT=360
#   PT_SPP=1024
#   PT_LIGHTS=4
#   PT_SCENE=dae/sky/CBbunny.dae

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BIN="$REPO_ROOT/build/pathtracer"

THREADS="${PT_THREADS:-8}"
WIDTH="${PT_WIDTH:-480}"
HEIGHT="${PT_HEIGHT:-360}"
SPP="${PT_SPP:-1024}"
LIGHTS="${PT_LIGHTS:-4}"
SCENE_REL="${PT_SCENE:-dae/sky/CBbunny.dae}"
SCENE="$REPO_ROOT/$SCENE_REL"

OUT_UNACCUM="$SCRIPT_DIR/cbbunny_depths_unaccum"
OUT_ACCUM="$SCRIPT_DIR/cbbunny_depths_accum"
OUT_RR="$SCRIPT_DIR/cbbunny_rr"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/render_missing_part4.log"

mkdir -p "$OUT_UNACCUM" "$OUT_ACCUM" "$OUT_RR" "$LOG_DIR"

if [[ ! -x "$BIN" ]]; then
  echo "[ERROR] Missing executable: $BIN"
  echo "Build first, then rerun this script."
  exit 1
fi

if [[ ! -f "$SCENE" ]]; then
  echo "[ERROR] Missing scene file: $SCENE"
  exit 1
fi

run_render() {
  local out_png="$1"
  local depth="$2"
  local accum="$3"

  local cmd=(
    "$BIN"
    -s "$SPP"
    -l "$LIGHTS"
    -m "$depth"
    -o "$accum"
    -t "$THREADS"
    -r "$WIDTH" "$HEIGHT"
    -f "$out_png"
    "$SCENE"
  )

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] ${cmd[*]}"
    return 0
  fi

  local start_ts end_ts elapsed
  start_ts="$(date +%s)"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] START depth=$depth accum=$accum out=$out_png" | tee -a "$LOG_FILE"
  "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE"
  end_ts="$(date +%s)"
  elapsed=$((end_ts - start_ts))
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] DONE  depth=$depth accum=$accum elapsed=${elapsed}s out=$out_png" | tee -a "$LOG_FILE"
}

echo "============================================================"
echo "Part 4 Missing Deliverables Renderer"
echo "repo:   $REPO_ROOT"
echo "bin:    $BIN"
echo "scene:  $SCENE"
echo "spp:    $SPP"
echo "lights: $LIGHTS"
echo "size:   ${WIDTH}x${HEIGHT}"
echo "dry:    $DRY_RUN"
echo "log:    $LOG_FILE"
echo "============================================================"

# Unaccumulated set: m = 0..5
for d in 0 1 2 3 4 5; do
  run_render "$OUT_UNACCUM/p4_cbbunny_unaccum_depth_${d}.png" "$d" 0
done

# Accumulated set: m = 0..5
# for d in 0 1 2 3 4 5; do
#   run_render "$OUT_ACCUM/p4_cbbunny_accum_depth_${d}.png" "$d" 1
# done 

# Russian Roulette set: m = 0,1,2,3,4,100
for d in 4; do
  run_render "$OUT_RR/p4_cbbunny_rr_depth_${d}.png" "$d" 1
done

echo "All requested Part 4 missing renders are complete."
