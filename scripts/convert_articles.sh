#!/bin/bash
#
# convert_articles.sh - Convert DOCX articles to LaTeX format
#
# Usage: ./convert_articles.sh <issue_name>
# Example: ./convert_articles.sh 4_2025
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: pandoc is not installed${NC}"
    echo "Install with: brew install pandoc"
    exit 1
fi

# Check if issue name is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Issue name required${NC}"
    echo "Usage: $0 <issue_name>"
    exit 1
fi

ISSUE_NAME="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
ISSUE_DIR="$PROJECT_ROOT/$ISSUE_NAME"

SOURCE_DIR="$ISSUE_DIR/source/articles"
OUTPUT_DIR="$ISSUE_DIR/processed/articles"
IMAGE_EXTRACT_DIR="$ISSUE_DIR/source/images/from_docx"

# Check if issue directory exists
if [ ! -d "$ISSUE_DIR" ]; then
    echo -e "${RED}Error: Issue directory '$ISSUE_NAME' does not exist${NC}"
    echo "Create it first with: ./scripts/create_issue.sh $ISSUE_NAME"
    exit 1
fi

# Check if source directory has any DOCX files
DOCX_COUNT=$(find "$SOURCE_DIR" -name "*.docx" -not -name "~\$*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$DOCX_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Warning: No DOCX files found in $SOURCE_DIR${NC}"
    echo "Place your article files there and run this script again."
    exit 0
fi

echo -e "${GREEN}Converting DOCX articles to LaTeX${NC}"
echo "================================================"
echo "Issue: $ISSUE_NAME"
echo "Source: $SOURCE_DIR"
echo "Output: $OUTPUT_DIR"
echo "Found $DOCX_COUNT DOCX file(s)"
echo ""

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$IMAGE_EXTRACT_DIR"

# Counter for statistics
SUCCESS_COUNT=0
FAIL_COUNT=0

# Convert each DOCX file
find "$SOURCE_DIR" -name "*.docx" -not -name "~\$*" | sort | while read -r docx_file; do
    # Get base filename without extension
    basename_no_ext=$(basename "$docx_file" .docx)
    output_file="$OUTPUT_DIR/${basename_no_ext}.tex"

    echo -e "${BLUE}Converting: $basename_no_ext${NC}"

    # Convert with Pandoc
    if pandoc "$docx_file" \
        --from=docx \
        --to=latex \
        --extract-media="$IMAGE_EXTRACT_DIR" \
        --output="$output_file" \
        --wrap=preserve \
        --standalone=false \
        2>/dev/null; then

        echo -e "${GREEN}  ✓ Converted successfully${NC}"
        ((SUCCESS_COUNT++)) || true

        # Post-process the LaTeX file to clean up
        # Remove \tightlist commands that pandoc adds
        sed -i '' 's/\\tightlist//g' "$output_file" 2>/dev/null || true

        # Show word count
        WORD_COUNT=$(wc -w < "$output_file" | tr -d ' ')
        echo "  Words: $WORD_COUNT"

    else
        echo -e "${RED}  ✗ Conversion failed${NC}"
        ((FAIL_COUNT++)) || true
    fi
    echo ""
done

# Summary
echo "================================================"
echo -e "${GREEN}Conversion Summary${NC}"
echo "Successfully converted: $SUCCESS_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}Failed: $FAIL_COUNT${NC}"
fi
echo ""

# Check if images were extracted
if [ -d "$IMAGE_EXTRACT_DIR" ]; then
    IMAGE_COUNT=$(find "$IMAGE_EXTRACT_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$IMAGE_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}Note: Extracted $IMAGE_COUNT images from DOCX files${NC}"
        echo "Location: $IMAGE_EXTRACT_DIR"
        echo "These images will be processed to CMYK in the next step."
        echo ""
    fi
fi

echo -e "${GREEN}✓ Article conversion complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review converted LaTeX files in: $OUTPUT_DIR"
echo "2. Process images: ./scripts/process_images.sh $ISSUE_NAME"
echo "3. Or run full build: ./scripts/build_magazine.sh $ISSUE_NAME"
