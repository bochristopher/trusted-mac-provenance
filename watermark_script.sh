#!/usr/bin/env bash
set -euo pipefail

# Function to add watermark to images
# Usage: ./add_watermark.sh <input_image> <status> [output_image]
# Status: "verified" or "tampered"

INPUT_IMAGE=$1
STATUS=${2:-"verified"}
OUTPUT_IMAGE=${3:-"${INPUT_IMAGE%.*}_${STATUS}.jpg"}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick not found. Installing...${NC}"
    brew install imagemagick
fi

if [[ ! -f "$INPUT_IMAGE" ]]; then
    echo -e "${RED}❌ Input image not found: $INPUT_IMAGE${NC}"
    exit 1
fi

# Get image dimensions
DIMENSIONS=$(identify -format "%wx%h" "$INPUT_IMAGE")
WIDTH=$(echo $DIMENSIONS | cut -d'x' -f1)
HEIGHT=$(echo $DIMENSIONS | cut -d'x' -f2)

# Calculate watermark size (20% of image width, but at least 100px)
WATERMARK_SIZE=$((WIDTH / 5))
if [[ $WATERMARK_SIZE -lt 100 ]]; then
    WATERMARK_SIZE=100
fi

# Calculate position (top-right corner with some padding)
POSITION_X=$((WIDTH - WATERMARK_SIZE - 20))
POSITION_Y=20

if [[ "$STATUS" == "verified" ]]; then
    echo -e "${GREEN}✅ Adding VERIFIED watermark...${NC}"
    
    # Create verified watermark with green checkmark
    convert "$INPUT_IMAGE" \
        \( -size ${WATERMARK_SIZE}x${WATERMARK_SIZE} xc:none \
           -fill "rgba(0,255,0,0.8)" \
           -draw "circle $((WATERMARK_SIZE/2)),$((WATERMARK_SIZE/2)) $((WATERMARK_SIZE/2)),10" \
           -fill "rgba(255,255,255,1)" \
           -stroke "rgba(255,255,255,1)" \
           -strokewidth 8 \
           -draw "polyline $((WATERMARK_SIZE/4)),$((WATERMARK_SIZE/2)) $((WATERMARK_SIZE*2/5)),$((WATERMARK_SIZE*3/4)) $((WATERMARK_SIZE*3/4)),$((WATERMARK_SIZE/3))" \
        \) \
        -geometry +${POSITION_X}+${POSITION_Y} \
        -composite \
        \( -pointsize $((WATERMARK_SIZE/4)) \
           -fill "rgba(0,180,0,0.9)" \
           -font "Arial-Bold" \
           -gravity northeast \
           -annotate +20+$((WATERMARK_SIZE + 30)) "✅ VERIFIED" \
        \) \
        "$OUTPUT_IMAGE"
        
elif [[ "$STATUS" == "tampered" ]]; then
    echo -e "${RED}❌ Adding TAMPERED watermark...${NC}"
    
    # Create tampered watermark with red X
    convert "$INPUT_IMAGE" \
        \( -size ${WATERMARK_SIZE}x${WATERMARK_SIZE} xc:none \
           -fill "rgba(255,0,0,0.8)" \
           -draw "circle $((WATERMARK_SIZE/2)),$((WATERMARK_SIZE/2)) $((WATERMARK_SIZE/2)),10" \
           -fill "rgba(255,255,255,1)" \
           -stroke "rgba(255,255,255,1)" \
           -strokewidth 8 \
           -draw "line $((WATERMARK_SIZE/4)),$((WATERMARK_SIZE/4)) $((WATERMARK_SIZE*3/4)),$((WATERMARK_SIZE*3/4))" \
           -draw "line $((WATERMARK_SIZE*3/4)),$((WATERMARK_SIZE/4)) $((WATERMARK_SIZE/4)),$((WATERMARK_SIZE*3/4))" \
        \) \
        -geometry +${POSITION_X}+${POSITION_Y} \
        -composite \
        \( -pointsize $((WATERMARK_SIZE/4)) \
           -fill "rgba(220,0,0,0.9)" \
           -font "Arial-Bold" \
           -gravity northeast \
           -annotate +20+$((WATERMARK_SIZE + 30)) "❌ TAMPERED" \
        \) \
        "$OUTPUT_IMAGE"

else
    echo -e "${RED}❌ Unknown status: $STATUS${NC}"
    echo "Usage: $0 <input_image> <verified|tampered> [output_image]"
    exit 1
fi

if [[ -f "$OUTPUT_IMAGE" ]]; then
    echo -e "${BLUE}📁 Watermarked image created: $OUTPUT_IMAGE${NC}"
    
    # Show file sizes
    ORIGINAL_SIZE=$(ls -lh "$INPUT_IMAGE" | awk '{print $5}')
    WATERMARKED_SIZE=$(ls -lh "$OUTPUT_IMAGE" | awk '{print $5}')
    echo -e "${BLUE}📊 Original: $ORIGINAL_SIZE → Watermarked: $WATERMARKED_SIZE${NC}"
else
    echo -e "${RED}❌ Failed to create watermarked image${NC}"
    exit 1
fi