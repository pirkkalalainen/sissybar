# Makefile for Sissybar Magazine Production
#
# Usage:
#   make issue=4_2025              # Build specific issue (full build)
#   make issue=4_2025 draft        # Quick draft build
#   make issue=4_2025 clean        # Clean build artifacts
#   make create issue=5_2025       # Create new issue structure
#   make help                      # Show help

.PHONY: help build draft printer clean create convert process compile

# Default target
help:
	@echo "Sissybar Magazine Build System"
	@echo "=============================="
	@echo ""
	@echo "Usage:"
	@echo "  make issue=<name> [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build          Full build (convert + process + compile) [default]"
	@echo "  draft          Quick draft build (RGB images, no marks)"
	@echo "  printer        Printer-ready build (CMYK + all marks)"
	@echo "  convert        Convert DOCX to LaTeX only"
	@echo "  process        Process images to CMYK only"
	@echo "  compile        Compile LaTeX to PDF only"
	@echo "  clean          Clean build artifacts"
	@echo "  create         Create new issue structure"
	@echo "  help           Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make issue=4_2025              # Full build of issue 4_2025"
	@echo "  make issue=4_2025 draft        # Quick draft preview"
	@echo "  make issue=4_2025 printer      # Final print-ready PDF"
	@echo "  make issue=4_2025 clean        # Clean temporary files"
	@echo "  make create issue=5_2025       # Create structure for new issue"
	@echo ""
	@echo "Variables:"
	@echo "  issue=<name>   Required: magazine issue name (e.g., 4_2025)"
	@echo ""

# Check if issue is specified (except for help and create)
ifndef issue
build draft printer convert process compile clean:
	@echo "Error: issue name required"
	@echo "Usage: make issue=<name> [target]"
	@echo "Example: make issue=4_2025"
	@exit 1
endif

# Default build target
build: check-issue
	@echo "Building issue: $(issue)"
	./scripts/build_magazine.sh $(issue)

# Draft build
draft: check-issue
	@echo "Building draft for issue: $(issue)"
	./scripts/build_magazine.sh $(issue) --draft

# Printer-ready build
printer: check-issue
	@echo "Building printer-ready version for issue: $(issue)"
	./scripts/build_magazine.sh $(issue) --printer-ready

# Convert articles only
convert: check-issue
	@echo "Converting articles for issue: $(issue)"
	./scripts/convert_articles.sh $(issue)

# Process images only
process: check-issue
	@echo "Processing images for issue: $(issue)"
	./scripts/process_images.sh $(issue)

# Compile LaTeX only
compile: check-issue
	@echo "Compiling magazine for issue: $(issue)"
	./scripts/build_magazine.sh $(issue) --no-convert --no-process

# Clean build artifacts
clean: check-issue
	@echo "Cleaning build artifacts for issue: $(issue)"
	@find $(issue) -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" \
		-o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" | xargs rm -f 2>/dev/null || true
	@echo "Cleaned!"

# Clean everything including PDFs
distclean: check-issue
	@echo "Deep cleaning for issue: $(issue)"
	@$(MAKE) clean issue=$(issue)
	@rm -rf $(issue)/processed/articles/*.tex 2>/dev/null || true
	@rm -rf $(issue)/processed/images/*.pdf 2>/dev/null || true
	@rm -rf $(issue)/output/*.pdf 2>/dev/null || true
	@echo "Deep cleaned!"

# Create new issue
create:
ifndef issue
	@echo "Error: issue name required"
	@echo "Usage: make create issue=<name>"
	@echo "Example: make create issue=5_2025"
	@exit 1
endif
	@echo "Creating new issue: $(issue)"
	./scripts/create_issue.sh $(issue)

# Internal target to check if issue directory exists
check-issue:
ifndef issue
	@echo "Error: issue variable not set"
	@exit 1
endif
	@if [ ! -d "$(issue)" ]; then \
		echo "Error: Issue directory '$(issue)' does not exist"; \
		echo "Create it first with: make create issue=$(issue)"; \
		exit 1; \
	fi

# List all issues
list:
	@echo "Available magazine issues:"
	@find . -maxdepth 1 -type d -name "*_20*" | sed 's|./||' | sort

# Show issue status
status: check-issue
	@echo "Status for issue: $(issue)"
	@echo "===================="
	@echo ""
	@echo "Source articles:"
	@find $(issue)/source/articles -name "*.docx" -not -name "~$$*" 2>/dev/null | wc -l | xargs echo "  DOCX files:"
	@echo ""
	@echo "Source images:"
	@find $(issue)/source/images -type f \( -iname "*.jpg" -o -iname "*.tif" -o -iname "*.png" \) 2>/dev/null | wc -l | xargs echo "  Image files:"
	@echo ""
	@echo "Processed:"
	@find $(issue)/processed/articles -name "*.tex" 2>/dev/null | wc -l | xargs echo "  LaTeX files:"
	@find $(issue)/processed/images -name "*.pdf" 2>/dev/null | wc -l | xargs echo "  Processed images:"
	@echo ""
	@echo "Output:"
	@if [ -f "$(issue)/output/sissybar_$(issue).pdf" ]; then \
		stat -f "  PDF: %z bytes (%Sm)" $(issue)/output/sissybar_$(issue).pdf; \
	else \
		echo "  PDF: Not built yet"; \
	fi

# Install dependencies (macOS)
install-deps:
	@echo "Installing dependencies..."
	@echo "This will install: pandoc, imagemagick, mactex-no-gui"
	@echo ""
	@read -p "Continue? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		brew install pandoc imagemagick; \
		brew install --cask mactex-no-gui; \
		echo ""; \
		echo "Installation complete!"; \
		echo "Restart your terminal or run: eval \"\$$(/usr/libexec/path_helper)\""; \
	else \
		echo "Aborted."; \
	fi
