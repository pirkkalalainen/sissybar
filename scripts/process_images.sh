#!/bin/bash
#
# process_images.sh - Convert images to CMYK PDF for print production
#
# Usage: ./process_images.sh <issue_name> [options]
# Example: ./process_images.sh 4_2025
# Example: ./process_images.sh 4_2025 --draft
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    if ! command -v convert &> /dev/null; then
        echo -e "${RED}Error: ImageMagick is not installed${NC}"
        echo "Install with: brew install imagemagick"
        exit 1
    fi
    # Use legacy convert command
    MAGICK_CMD="convert"
else
    # Use new magick command
    MAGICK_CMD="magick"
fi

# Default settings
DRAFT_MODE=false
DENSITY=300  # DPI for print
QUALITY=85   # JPEG quality (1-100)

# Parse arguments
ISSUE_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --draft)
            DRAFT_MODE=true
            shift
            ;;
        --density)
            DENSITY="$2"
            shift 2
            ;;
        --quality)
            QUALITY="$2"
            shift 2
            ;;
        *)
            if [ -z "$ISSUE_NAME" ]; then
                ISSUE_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Check if issue name is provided
if [ -z "$ISSUE_NAME" ]; then
    echo -e "${RED}Error: Issue name required${NC}"
    echo "Usage: $0 <issue_name> [options]"
    echo ""
    echo "Options:"
    echo "  --draft          Quick conversion (RGB, no color profile)"
    echo "  --density N      Set DPI (default: 300)"
    echo "  --quality N      Set JPEG quality 1-100 (default: 85)"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
ISSUE_DIR="$PROJECT_ROOT/$ISSUE_NAME"

SOURCE_DIR="$ISSUE_DIR/source/images"
OUTPUT_DIR="$ISSUE_DIR/processed/images"
ICC_PROFILE="$PROJECT_ROOT/assets/profiles/ISOcoated_v2_eci.icc"

# Check if issue directory exists
if [ ! -d "$ISSUE_DIR" ]; then
    echo -e "${RED}Error: Issue directory '$ISSUE_NAME' does not exist${NC}"
    echo "Create it first with: ./scripts/create_issue.sh $ISSUE_NAME"
    exit 1
fi

# Check if ICC profile exists (unless in draft mode)
if [ "$DRAFT_MODE" = false ] && [ ! -f "$ICC_PROFILE" ]; then
    echo -e "${RED}Error: ICC profile not found: $ICC_PROFILE${NC}"
    echo "The profile should be downloaded automatically."
    echo "Run in draft mode with --draft flag, or download manually."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Count source images
IMAGE_COUNT=$(find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.png" \) 2>/dev/null | wc -l | tr -d ' ')

if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Warning: No images found in $SOURCE_DIR${NC}"
    echo "Place your image files there and run this script again."
    exit 0
fi

echo -e "${GREEN}Processing images for magazine production${NC}"
echo "================================================"
echo "Issue: $ISSUE_NAME"
echo "Source: $SOURCE_DIR"
echo "Output: $OUTPUT_DIR"
echo "Found $IMAGE_COUNT image(s)"
if [ "$DRAFT_MODE" = true ]; then
    echo -e "${YELLOW}Mode: DRAFT (RGB, faster processing)${NC}"
else
    echo "Mode: PRINT (CMYK with color profile)"
    echo "ICC Profile: $(basename $ICC_PROFILE)"
fi
echo "Density: ${DENSITY} DPI"
echo "Quality: ${QUALITY}%"
echo ""

# Counter for statistics
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_SIZE_BEFORE=0
TOTAL_SIZE_AFTER=0

# Process each image
find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.png" \) | sort | while read -r image_file; do
    # Get base filename without extension
    basename_file=$(basename "$image_file")
    basename_no_ext="${basename_file%.*}"
    output_file="$OUTPUT_DIR/${basename_no_ext}.pdf"

    echo -e "${BLUE}Processing: $basename_file${NC}"

    # Get file size before
    SIZE_BEFORE=$(stat -f%z "$image_file" 2>/dev/null || echo "0")

    # Convert image
    if [ "$DRAFT_MODE" = true ]; then
        # Draft mode: quick RGB conversion
        if $MAGICK_CMD "$image_file" \
            -density $DENSITY \
            -quality $QUALITY \
            -compress jpeg \
            "$output_file" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Converted (RGB draft mode)${NC}"
            ((SUCCESS_COUNT++)) || true
        else
            echo -e "${RED}  ✗ Conversion failed${NC}"
            ((FAIL_COUNT++)) || true
        fi
    else
        # Production mode: CMYK with color profile
        if $MAGICK_CMD "$image_file" \
            -profile sRGB.icc \
            -profile "$ICC_PROFILE" \
            -density $DENSITY \
            -quality $QUALITY \
            -compress jpeg \
            "$output_file" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Converted (CMYK)${NC}"
            ((SUCCESS_COUNT++)) || true
        else
            # If conversion with profile fails, try without sRGB.icc
            if $MAGICK_CMD "$image_file" \
                -profile "$ICC_PROFILE" \
                -density $DENSITY \
                -quality $QUALITY \
                -compress jpeg \
                "$output_file" 2>/dev/null; then
                echo -e "${GREEN}  ✓ Converted (CMYK, no sRGB profile)${NC}"
                ((SUCCESS_COUNT++)) || true
            else
                echo -e "${RED}  ✗ Conversion failed${NC}"
                ((FAIL_COUNT++)) || true
            fi
        fi
    fi

    # Get file size after
    if [ -f "$output_file" ]; then
        SIZE_AFTER=$(stat -f%z "$output_file" 2>/dev/null || echo "0")
        SIZE_MB=$(echo "scale=2; $SIZE_AFTER / 1048576" | bc 2>/dev/null || echo "?")
        echo "  Size: ${SIZE_MB} MB"
    fi

    echo ""
done

# Summary
echo "================================================"
echo -e "${GREEN}Processing Summary${NC}"
echo "Successfully processed: $SUCCESS_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}Failed: $FAIL_COUNT${NC}"
fi
echo ""

if [ "$DRAFT_MODE" = true ]; then
    echo -e "${YELLOW}Note: Images processed in DRAFT mode (RGB)${NC}"
    echo "For final print production, run without --draft flag"
    echo ""
fi

echo -e "${GREEN}✓ Image processing complete!${NC}"
echo ""
echo "Processed images location: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Review processed images"
echo "2. Run full build: ./scripts/build_magazine.sh $ISSUE_NAME"
