#!/bin/bash
# Part 4: Global Illumination Rendering Script

set -e

echo "════════════════════════════════════════════════════════════"
echo "  Part 4: Global Illumination Rendering Pipeline"
echo "════════════════════════════════════════════════════════════"
echo ""

mkdir -p part4

# Helper function  
render() {
    local name=$1
    local scene=$2
    local samples=$3
    local lights=$4
    local depth=$5
    
    echo "  Rendering: $name"
    ./pathtracer -s $samples -l $lights -m $depth -t 8 -r 480 360 -f "part4/$name" "$scene"
    echo "    ✓ Done"
}

# ═════════════════════════════════════════════════════════════
# SECTION 1: Global Illumination (1024 samples)
# ═════════════════════════════════════════════════════════════

echo "[Section 1] Global Illumination Renders"
echo ""

render "p4_global_cbbunny.png" "../dae/sky/CBbunny.dae" 1024 4 5
render "p4_global_cbspheres.png" "../dae/sky/CBspheres_lambertian.dae" 1024 4 5

echo ""

# ═════════════════════════════════════════════════════════════
# SECTION 2: Direct vs Indirect (MANUAL - requires code edits)
# ═════════════════════════════════════════════════════════════

echo "[Section 2] Direct vs Indirect Comparison"
echo "  (Skipping - requires manual code edits)"
echo ""

# ═════════════════════════════════════════════════════════════
# SECTION 3: Ray Depth Series (0, 1, 2, 3, 100)
# ═════════════════════════════════════════════════════════════

echo "[Section 3] Ray Depth Series"
echo ""

for depth in 0 1 2 3 100; do
    render "p4_cbbunny_depth_${depth}.png" "../dae/sky/CBbunny.dae" 1024 4 $depth
done

echo ""

# ═════════════════════════════════════════════════════════════
# SECTION 4: Sample Rate Series (1, 2, 4, 8, 16, 64, 1024)
# ═════════════════════════════════════════════════════════════

echo "[Section 4] Sample Rate Series"
echo ""

for samples in 1 2 4 8 16 64 1024; do
    render "p4_cbbunny_samples_${samples}.png" "../dae/sky/CBbunny.dae" $samples 4 5
done

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✅ Rendering Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Copying to docs/images/..."
cp -v part4/*.png ../docs/images/

echo ""
echo "Total images: $(ls part4/*.png | wc -l)"
