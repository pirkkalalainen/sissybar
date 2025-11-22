# Sissybar Magazine - Automated Production System

Automated LaTeX-based magazine production workflow for YCCF club magazine. This system replaces manual Scribus layout work with bash-scripted automation while maintaining professional print quality with CMYK color management and print marks.

## Overview

This system automates magazine production from DOCX articles and photos to print-ready PDFs:

```
DOCX files + Images → Scripts → LaTeX → Print-Ready PDF
                                        (CMYK + Crop Marks)
```

### Key Features

- **Automated conversion**: DOCX → LaTeX using Pandoc
- **CMYK color management**: Fogra27L profile for European coated paper printing
- **Print marks**: Crop marks, bleed marks, registration marks
- **Bash-controllable**: One command builds entire magazine
- **Modular structure**: Each issue in separate subfolder
- **Version control friendly**: Plain text source files
- **Manual fine-tuning**: Edit .tex files for layout adjustments

## Project Structure

```
sissybar/
├── README.md                  # This file
├── Makefile                   # Build automation (alternative interface)
├── .gitignore                 # Git ignore rules
│
├── templates/                 # Shared LaTeX templates
│   ├── magazine.tex           # Main document template
│   ├── preamble.tex          # Package configuration
│   ├── 1_column_article.tex  # Single column layout
│   └── 2_column_article.tex  # Two column layout
│
├── scripts/                   # Automation scripts
│   ├── create_issue.sh       # Create new issue structure
│   ├── convert_articles.sh   # DOCX → LaTeX conversion
│   ├── process_images.sh     # Image CMYK conversion
│   └── build_magazine.sh     # Master build script
│
├── assets/                    # Shared resources
│   ├── logos/                # YCCF logo, Sissybar nameplate
│   ├── icons/                # Reusable icons (hotel, sauna, etc.)
│   └── profiles/             # ICC color profiles (Fogra27L)
│
├── 3_2025/                   # Example: March 2025 issue
│   ├── source/               # Original content
│   │   ├── articles/        # DOCX files from contributors
│   │   └── images/          # Original JPG/TIFF photos
│   ├── processed/           # Generated files
│   │   ├── articles/        # Converted LaTeX files
│   │   └── images/          # CMYK PDF images
│   ├── magazine_3_2025.tex  # Issue-specific main file
│   └── output/              # Final PDFs
│       └── sissybar_3_2025.pdf
│
└── 4_2025/                   # Next issue
    └── ...
```

## Prerequisites

### Required Tools

1. **MacTeX** (LaTeX distribution)
   ```bash
   brew install --cask mactex-no-gui
   # Then restart terminal or run:
   eval "$(/usr/libexec/path_helper)"
   ```

2. **Pandoc** (Document converter)
   ```bash
   brew install pandoc
   ```

3. **ImageMagick** (Image processing)
   ```bash
   brew install imagemagick
   ```

### Quick Install All Dependencies

```bash
make install-deps
```

Or manually:
```bash
brew install pandoc imagemagick && brew install --cask mactex-no-gui
```

## Quick Start Guide

### 1. Create New Issue

```bash
# Using script
./scripts/create_issue.sh 4_2025

# Or using Makefile
make create issue=4_2025
```

This creates the directory structure:
- `4_2025/source/` for DOCX and images
- `4_2025/processed/` for generated files
- `4_2025/output/` for final PDFs

### 2. Add Content

Place contributor materials in the source directories:

```bash
# Copy article files
cp ~/Desktop/articles/*.docx 4_2025/source/articles/

# Copy images
cp ~/Desktop/photos/*.{jpg,tif} 4_2025/source/images/
```

Recommended naming convention for articles:
- `01_kansi.docx` - Cover
- `02_toimihenkilot.docx` - Staff list
- `03_paakirjoitus.docx` - Editorial
- `04-06_kuopion_messut.docx` - Multi-page article

### 3. Build Magazine

```bash
# Using script (full build)
./scripts/build_magazine.sh 4_2025

# Or using Makefile
make issue=4_2025
```

This will:
1. Convert all DOCX files to LaTeX
2. Process all images to CMYK
3. Compile LaTeX to print-ready PDF

Output: `4_2025/output/sissybar_4_2025.pdf`

## Build Options

### Full Build (Default)

```bash
./scripts/build_magazine.sh 4_2025
# Or: make issue=4_2025
```

Converts articles, processes images (CMYK), compiles with print marks.

### Draft Build (Fast Preview)

```bash
./scripts/build_magazine.sh 4_2025 --draft
# Or: make issue=4_2025 draft
```

Quick build with RGB images and no print marks. Use for quick reviews.

### Printer-Ready Build

```bash
./scripts/build_magazine.sh 4_2025 --printer-ready
# Or: make issue=4_2025 printer
```

Full CMYK conversion with crop marks, bleed marks, and registration marks.

### Rebuild Without Conversion

If you manually edited the LaTeX files:

```bash
./scripts/build_magazine.sh 4_2025 --no-convert
# Or: make issue=4_2025 compile
```

### Individual Steps

Run only specific parts of the workflow:

```bash
# Convert articles only
./scripts/convert_articles.sh 4_2025
# Or: make issue=4_2025 convert

# Process images only
./scripts/process_images.sh 4_2025
# Or: make issue=4_2025 process

# Compile LaTeX only
make issue=4_2025 compile
```

## Manual Fine-Tuning

The system allows manual adjustments when needed:

1. **Run initial build** to generate LaTeX files:
   ```bash
   ./scripts/build_magazine.sh 4_2025
   ```

2. **Edit LaTeX files** in `4_2025/processed/articles/`:
   - Adjust image sizes: `\includegraphics[width=0.5\textwidth]{image}`
   - Force image placement: `\begin{figure}[H]`
   - Add column breaks: `\columnbreak`
   - Fine-tune spacing: `\vspace{5mm}`

3. **Rebuild without converting**:
   ```bash
   ./scripts/build_magazine.sh 4_2025 --no-convert
   ```

## Workflow Examples

### Complete New Issue Workflow

```bash
# 1. Create issue structure
make create issue=4_2025

# 2. Add content
cp ~/contributors/articles/*.docx 4_2025/source/articles/
cp ~/contributors/photos/*.jpg 4_2025/source/images/

# 3. Quick draft preview
make issue=4_2025 draft

# 4. Review PDF
open 4_2025/output/sissybar_4_2025.pdf

# 5. If needed, edit LaTeX files for fine-tuning
nano 4_2025/processed/articles/01_kansi.tex

# 6. Build final printer-ready version
make issue=4_2025 printer

# 7. Send to printer
# 4_2025/output/sissybar_4_2025.pdf is ready!
```

### Iterative Editing Workflow

```bash
# Initial build
make issue=4_2025

# Make edits to LaTeX files
# ...edit files in 4_2025/processed/articles/...

# Rebuild (fast - skips conversion)
make issue=4_2025 compile

# Review changes
open 4_2025/output/sissybar_4_2025.pdf

# Repeat as needed
```

## Print Production Specifications

The system generates PDFs with professional print specifications:

### Page Setup

- **Format**: A4 (210 × 297 mm)
- **Bleed**: 5mm on all sides
- **Final trim size**: 210 × 297 mm
- **Output size**: 220 × 307 mm (with bleed)

### Color Management

- **Color space**: CMYK
- **ICC Profile**: ISO Coated v2 (ECI) / Fogra27L
- **Suitable for**: Coated paper, offset printing (Europe)
- **Image resolution**: 300 DPI

### Print Marks

- **Crop marks**: Corner marks showing trim lines
- **Bleed marks**: Indicating bleed extent
- **Registration marks**: Crosshairs for color plate alignment
- **PDF/X compliance**: PDF/X-4 standard (when LaTeX template is configured)

### Printer Requirements

Before sending to print shop, verify:
1. They accept PDF/X-4 files (or specify their required version)
2. Fogra27L profile is correct (or provide their preferred ICC profile)
3. Bleed amount is 5mm (or adjust to their specification)

Update ICC profile if needed:
```bash
# Download alternative profile
cd assets/profiles/
curl -O https://www.eci.org/_media/downloads/icc_profiles_from_eci/[profile-name].icc
```

## Maintenance Tasks

### Check Issue Status

```bash
make status issue=4_2025
```

Shows:
- Number of source DOCX files
- Number of source images
- Number of processed LaTeX files
- Number of processed images
- Final PDF size and date

### Clean Build Artifacts

```bash
# Clean LaTeX temporary files
make clean issue=4_2025

# Deep clean (also removes processed files)
make distclean issue=4_2025
```

### List All Issues

```bash
make list
```

## Troubleshooting

### "pandoc not found"

Install Pandoc:
```bash
brew install pandoc
```

### "convert not found" or "magick not found"

Install ImageMagick:
```bash
brew install imagemagick
```

### "latexmk not found"

Install MacTeX:
```bash
brew install --cask mactex-no-gui
```

Then restart terminal or:
```bash
eval "$(/usr/libexec/path_helper)"
```

### "LaTeX compilation failed"

Check the log file:
```bash
cat 4_2025/magazine_4_2025.log
```

Common issues:
- Missing images: Ensure images are in `processed/images/`
- Unicode characters: LaTeX template needs proper encoding
- Package errors: Template configuration issue

### "CMYK conversion failed"

Check ICC profile exists:
```bash
ls -la assets/profiles/ISOcoated_v2_eci.icc
```

If missing, download:
```bash
cd assets/profiles/
curl -L -o "ISOcoated_v2_eci.icc" \
  "https://www.eci.org/_media/downloads/icc_profiles_from_eci/isocoated_v2_eci.icc"
```

### Images Too Large

Reduce file size with quality setting:
```bash
./scripts/process_images.sh 4_2025 --quality 75
```

Default is 85. Lower = smaller files but lower quality.

## Customization

### Changing Bleed Amount

Edit the LaTeX template (when created):
```latex
% In templates/magazine.tex
\setstocksize{307mm}{220mm}    % A4 + bleed
\settrimmedsize{297mm}{210mm}  % A4 final size
\settrims{5mm}{5mm}            % Bleed amount - change this
```

### Adding New Article Styles

Create new template in `templates/`:
```bash
cp templates/2_column_article.tex templates/3_column_article.tex
# Edit to add third column
```

### Changing Color Profile

Replace or add profiles in `assets/profiles/`:
```bash
cd assets/profiles/
# Download new profile
curl -O https://example.com/your-profile.icc

# Update scripts to use it
# Edit scripts/process_images.sh
ICC_PROFILE="$PROJECT_ROOT/assets/profiles/your-profile.icc"
```

## Technical Notes

### DOCX to LaTeX Conversion

Pandoc converts:
- ✅ Paragraphs, headings
- ✅ Bold, italic, underline
- ✅ Lists (bulleted, numbered)
- ✅ Basic tables
- ✅ Embedded images (extracted to `source/images/from_docx/`)

Not converted automatically:
- ❌ Complex tables (require manual adjustment)
- ❌ Precise positioning
- ❌ Custom fonts (use LaTeX font commands instead)

### Image Format Support

Source formats accepted:
- JPG/JPEG
- TIFF/TIF
- PNG

Output format: PDF (one PDF per image)

Why PDF? LaTeX handles PDFs more efficiently than TIFF for large documents.

### LaTeX Build System

Uses `latexmk` with `lualatex`:
- Modern Unicode support
- Better font handling
- Native Finnish language support

Build process:
1. `latexmk` automatically runs LaTeX multiple times
2. Resolves cross-references
3. Generates table of contents
4. Includes all images
5. Creates final PDF

## Performance

### Build Times

Approximate times for 28-page magazine with 200+ images:

- **Draft build**: 30-60 seconds
- **Full build** (first time): 3-5 minutes
- **Rebuild** (no conversion): 1-2 minutes

### Optimization Tips

1. **Use draft mode** for quick previews
2. **Skip conversion** if LaTeX files haven't changed
3. **Process images separately** before final compile
4. **Reduce image quality** for drafts (--quality 70)

## Future Enhancements

Planned improvements:

- [ ] Web interface for non-technical contributors
- [ ] Automatic page layout optimization
- [ ] Template variations (different column layouts)
- [ ] Batch processing for multiple issues
- [ ] Integration with cloud storage (Dropbox, Google Drive)
- [ ] Email notification when build completes
- [ ] PDF comparison tool (current vs previous issue)

## Contributing

This is an internal YCCF project. For questions or improvements:

1. Test changes on a copy of an old issue first
2. Document any template modifications
3. Update this README if workflow changes

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review log files in issue directory
3. Check that all dependencies are installed
4. Verify file permissions on scripts (`chmod +x scripts/*.sh`)

## License

Internal YCCF project. Assets and content are property of YCCF club members.

## Acknowledgments

- **Previous editor**: Original Scribus templates and design
- **ECI**: Free ICC color profiles
- **LaTeX community**: Document preparation system
- **Pandoc**: Universal document converter

---

**Version**: 1.0
**Last Updated**: November 2025
**Maintainer**: YCCF Magazine Team
