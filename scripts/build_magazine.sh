#!/bin/bash
#
# build_magazine.sh - Master script to build complete magazine
#
# Usage: ./build_magazine.sh <issue_name> [options]
# Example: ./build_magazine.sh 4_2025
# Example: ./build_magazine.sh 4_2025 --draft --no-convert
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default options
RUN_CONVERT=true
RUN_PROCESS=true
RUN_COMPILE=true
DRAFT_MODE=false
CLEAN_FIRST=false
PRINTER_READY=true

# Parse arguments
ISSUE_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-convert)
            RUN_CONVERT=false
            shift
            ;;
        --no-process)
            RUN_PROCESS=false
            shift
            ;;
        --no-compile)
            RUN_COMPILE=false
            shift
            ;;
        --draft)
            DRAFT_MODE=true
            PRINTER_READY=false
            shift
            ;;
        --no-marks)
            PRINTER_READY=false
            shift
            ;;
        --printer-ready)
            PRINTER_READY=true
            DRAFT_MODE=false
            shift
            ;;
        --clean)
            CLEAN_FIRST=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 <issue_name> [options]"
            echo ""
            echo "Options:"
            echo "  --no-convert      Skip DOCX to LaTeX conversion"
            echo "  --no-process      Skip image processing"
            echo "  --no-compile      Skip LaTeX compilation"
            echo "  --draft           Fast build: RGB images, no crop marks"
            echo "  --no-marks        Build without crop/bleed marks (preview)"
            echo "  --printer-ready   Full CMYK with all print marks (default)"
            echo "  --clean           Clean build artifacts before building"
            echo "  -h, --help        Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 4_2025                    # Full build"
            echo "  $0 4_2025 --draft            # Quick preview"
            echo "  $0 4_2025 --no-convert       # Skip conversion, rebuild only"
            echo "  $0 4_2025 --clean            # Clean then build"
            exit 0
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
    echo "Run with --help for more options"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
ISSUE_DIR="$PROJECT_ROOT/$ISSUE_NAME"

# Check if issue directory exists
if [ ! -d "$ISSUE_DIR" ]; then
    echo -e "${RED}Error: Issue directory '$ISSUE_NAME' does not exist${NC}"
    echo "Create it first with: ./scripts/create_issue.sh $ISSUE_NAME"
    exit 1
fi

# Start time
START_TIME=$(date +%s)

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         SISSYBAR MAGAZINE BUILD SYSTEM        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Issue: $ISSUE_NAME${NC}"
if [ "$DRAFT_MODE" = true ]; then
    echo -e "${YELLOW}Mode: DRAFT${NC}"
elif [ "$PRINTER_READY" = true ]; then
    echo -e "${GREEN}Mode: PRINTER-READY${NC}"
else
    echo -e "${BLUE}Mode: PREVIEW (no marks)${NC}"
fi
echo ""
echo "Build steps:"
echo "  1. Convert articles (DOCX → LaTeX): $([ "$RUN_CONVERT" = true ] && echo "✓" || echo "SKIP")"
echo "  2. Process images (RGB → CMYK):     $([ "$RUN_PROCESS" = true ] && echo "✓" || echo "SKIP")"
echo "  3. Compile magazine (LaTeX → PDF):  $([ "$RUN_COMPILE" = true ] && echo "✓" || echo "SKIP")"
echo ""
echo "================================================"
echo ""

# Function to print section header
print_section() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo "------------------------------------------------"
}

# Function to handle errors
handle_error() {
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    echo "Error in: $1"
    exit 1
}

# Clean if requested
if [ "$CLEAN_FIRST" = true ]; then
    print_section "Cleaning build artifacts"

    # Remove LaTeX auxiliary files
    find "$ISSUE_DIR" -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" | xargs rm -f 2>/dev/null || true

    echo -e "${GREEN}✓ Cleaned${NC}"
fi

# Step 1: Convert articles
if [ "$RUN_CONVERT" = true ]; then
    print_section "Step 1: Converting articles (DOCX → LaTeX)"

    if "$SCRIPT_DIR/convert_articles.sh" "$ISSUE_NAME"; then
        echo -e "${GREEN}✓ Article conversion complete${NC}"
    else
        handle_error "Article conversion"
    fi
fi

# Step 2: Process images
if [ "$RUN_PROCESS" = true ]; then
    print_section "Step 2: Processing images"

    if [ "$DRAFT_MODE" = true ]; then
        if "$SCRIPT_DIR/process_images.sh" "$ISSUE_NAME" --draft; then
            echo -e "${GREEN}✓ Image processing complete (draft mode)${NC}"
        else
            handle_error "Image processing"
        fi
    else
        if "$SCRIPT_DIR/process_images.sh" "$ISSUE_NAME"; then
            echo -e "${GREEN}✓ Image processing complete (CMYK)${NC}"
        else
            handle_error "Image processing"
        fi
    fi
fi

# Step 3: Compile magazine
if [ "$RUN_COMPILE" = true ]; then
    print_section "Step 3: Compiling magazine (LaTeX → PDF)"

    # Check if latexmk is installed
    if ! command -v latexmk &> /dev/null; then
        echo -e "${YELLOW}Warning: latexmk not found${NC}"
        echo "LaTeX is required for compilation."
        echo ""
        echo "Install MacTeX with: brew install --cask mactex-no-gui"
        echo "Then restart your terminal or run: eval \"\$(/usr/libexec/path_helper)\""
        echo ""
        echo "After installation, run this script again."
        exit 1
    fi

    # Check if main LaTeX file exists and has proper content
    MAIN_TEX="$ISSUE_DIR/magazine_${ISSUE_NAME}.tex"

    if [ ! -f "$MAIN_TEX" ] || grep -q "TODO: Add proper magazine template" "$MAIN_TEX" 2>/dev/null; then
        echo -e "${YELLOW}Warning: LaTeX template not yet configured${NC}"
        echo ""
        echo "The LaTeX magazine template needs to be created first."
        echo "This is a one-time setup task."
        echo ""
        echo "Once the template is ready, run this script again to compile."
        exit 0
    fi

    # Run latexmk to compile
    cd "$ISSUE_DIR"

    echo "Compiling with latexmk..."
    if latexmk -pdf -lualatex -interaction=nonstopmode "magazine_${ISSUE_NAME}.tex" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ LaTeX compilation complete${NC}"

        # Move PDF to output directory
        if [ -f "magazine_${ISSUE_NAME}.pdf" ]; then
            mkdir -p output
            mv "magazine_${ISSUE_NAME}.pdf" "output/sissybar_${ISSUE_NAME}.pdf"

            # Get file size
            PDF_SIZE=$(stat -f%z "output/sissybar_${ISSUE_NAME}.pdf" 2>/dev/null || echo "0")
            PDF_SIZE_MB=$(echo "scale=2; $PDF_SIZE / 1048576" | bc 2>/dev/null || echo "?")

            echo ""
            echo -e "${GREEN}✓ PDF created: output/sissybar_${ISSUE_NAME}.pdf${NC}"
            echo "  Size: ${PDF_SIZE_MB} MB"
        fi
    else
        echo -e "${RED}✗ LaTeX compilation failed${NC}"
        echo "Check the log file for errors: magazine_${ISSUE_NAME}.log"
        cd "$PROJECT_ROOT"
        handle_error "LaTeX compilation"
    fi

    cd "$PROJECT_ROOT"
fi

# End time and summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "================================================"
echo -e "${GREEN}✓ BUILD COMPLETE!${NC}"
echo ""
echo "Build time: ${DURATION} seconds"
echo ""

if [ -f "$ISSUE_DIR/output/sissybar_${ISSUE_NAME}.pdf" ]; then
    echo "Output PDF:"
    echo "  $ISSUE_DIR/output/sissybar_${ISSUE_NAME}.pdf"
    echo ""

    if [ "$DRAFT_MODE" = true ]; then
        echo -e "${YELLOW}Note: This is a DRAFT build (RGB images, no print marks)${NC}"
        echo "For final print production, run: $0 $ISSUE_NAME --printer-ready"
    elif [ "$PRINTER_READY" = true ]; then
        echo -e "${GREEN}✓ This PDF is printer-ready with CMYK and print marks${NC}"
    else
        echo "This is a preview build without print marks."
        echo "For final print production, run: $0 $ISSUE_NAME --printer-ready"
    fi
    echo ""
fi

echo "Done!"
echo ""
