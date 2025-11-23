# Sissybar Magazine LaTeX Templates

This directory contains reusable LaTeX templates for producing the Sissybar magazine.

## Template Files

### Core Templates

#### `preamble.tex`
Shared configuration file containing:
- Font settings (Helvetica/Arial)
- Color definitions (CMYK for print)
- Page layout settings
- Header/footer styling with Sissybar logo
- Section formatting (red bold with drop shadow)
- Figure spacing and caption settings
- Helper commands for images

**Helper Commands Available:**
- `\leipis{text}` - Body text style (10pt, justified)
- `\kuvateksti{text}` - Image caption style (10pt, italic)
- `\onefig[width]{image.pdf}{caption}` - Single column figure
- `\twocolumnfig[width]{image.pdf}{caption}` - Full-width figure spanning both columns
- `\wrapfig[position]{width}{image.pdf}{caption}` - Wrapped figure with text flowing around it
  - Position: `[l]` for left, `[r]` for right (default)
  - Width: fraction of column width (e.g., 0.5 = 50%)

### Article Templates

#### `2_column_article.tex`
Standard two-column article layout.

**Features:**
- Two-column text layout
- Sissybar header with logo and underline
- Print marks (crop, bleed, registration)
- A4 final size with 5mm bleed

**Usage:**
```bash
cp templates/2_column_article.tex <issue_dir>/article_name.tex
# Edit article content between \begin{multicols}{2} and \end{multicols}
# Add images using \onefig or \wrapfig commands
pdflatex article_name.tex
```

#### `1_column_article.tex`
Single-column article layout for special content.

### Special Page Templates

#### `greetings_page.tex`
Template for President and Secretary greetings page.

**Structure:**
- Two sections on one page
- Red bold centered headings
- Uses separate content files for easy editing

**Usage:**
```bash
# Copy template to issue directory
cp templates/greetings_page.tex <issue_dir>/

# Create content files
cp templates/president_greeting_content.tex <issue_dir>/
cp templates/secretary_greeting_content.tex <issue_dir>/

# Edit the content files with actual greetings text
# Compile
cd <issue_dir>
pdflatex greetings_page.tex
```

**Content File Structure:**
```latex
% president_greeting_content.tex
\wrapfig[l]{0.35}{president_photo.pdf}{}
\leipis{Your greeting text here...}
\vspace{6pt}
\raggedright
\textit{pj. Name}
```

## Page Specifications

All templates use these print specifications:
- **Final trim size**: 210mm × 297mm (A4)
- **Bleed**: 5mm on all sides
- **Total paper size**: 244mm × 331mm (includes 12mm mark space)
- **Color space**: CMYK for print production
- **Margins**: 13mm left/right, 5mm top, 25mm bottom (inside trim)

## Image Preparation

### Converting Images to CMYK PDF

Images should be converted to CMYK PDF format for print:

```bash
magick input.tif -colorspace CMYK -compress JPEG -quality 85 output.pdf
```

### Image Placement Examples

**Single column image:**
```latex
\onefig[0.9]{image.pdf}{Caption text describing the image.}
```

**Full-width image (break columns):**
```latex
\end{multicols}
\twocolumnfig[0.8]{wide_image.pdf}{Caption for wide image.}
\begin{multicols}{2}
```

**Wrapped image (text flows around):**
```latex
\wrapfig[r]{0.5}{portrait.pdf}{Person's name}
\leipis{
Text will flow around the image on the left side...
}
```

## Styling Guidelines

### Section Headings
Automatically styled as:
- Centered
- Bold
- Pure red RGB(255,0,0)
- Black drop shadow (0.02, -0.02 offset)

### Body Text
- 10pt Helvetica (Arial substitute)
- Justified
- 1.2× line spacing
- 2pt paragraph spacing

### Captions
- 10pt italic
- Justified
- Minimal spacing above (2pt)

## Tips for Layout

1. **Tight spacing**: Current settings use minimal white space. Adjust in `preamble.tex` if needed:
   - `\setlength{\intextsep}{3pt}` - Space around figures
   - `\setlength{\parskip}{2pt}` - Paragraph spacing

2. **Text wrapping**: Use `\wrapfig` for magazine-style layouts with text flowing around images

3. **Image sizing**:
   - Column images: 0.85-0.95 of column width
   - Wrapped images: 0.35-0.5 of column width
   - Full-width: 0.7-0.9 of page width

4. **Manual adjustments**: Add `\vspace{6pt}` or `\columnbreak` to fine-tune layout

## Workflow

1. **Convert images**: Process TIFF/JPG to CMYK PDF
2. **Copy template**: Use appropriate template for article type
3. **Edit content**: Add text and image commands
4. **Compile**: `pdflatex article.tex`
5. **Review**: Check spacing, image placement, page breaks
6. **Iterate**: Adjust image sizes and spacing as needed

## Graphics Path Setup

When using templates in issue directories, add graphics path:
```latex
\graphicspath{{./}{../../assets/logos/}{../../assets/icons/}{./processed/images/}}
```

This ensures LaTeX can find:
- Sissybar logo
- Icons
- Processed images in your issue directory
