# ICC Color Profiles

This directory contains ICC color profiles used for CMYK color management in magazine production.

## ISOcoated_v2_eci.icc (Fogra27L)

- **Name:** ISO Coated v2 (ECI)
- **Also known as:** Fogra27L, CMYK Coated Press
- **Source:** European Color Initiative (ECI)
- **Usage:** Standard CMYK profile for coated paper printing in Europe
- **Application:** Matches your current Scribus "Fogra27L CMYK Coated Press" setting

### About This Profile

ISO Coated v2 is one of the most widely used CMYK color profiles for European print production:
- Designed for coated paper (glossy/semi-glossy magazines)
- Based on ISO 12647-2:2004 standard
- Suitable for sheet-fed and heat-set web offset printing
- Free to use and redistribute

### When to Use

Use this profile when:
- Converting RGB images to CMYK
- Embedding color space in PDF/X files
- Your printer specifies "Fogra27", "ISO Coated", or similar

### Alternative Profiles

If your printer specifies a different profile, download it and place it here:
- **Fogra39** (PSO Coated v2): Newer version, more common now
- **Fogra51** (PSO Coated v3): Latest version for modern printing
- **SWOP**: For US printing (Americas standard)

Download from: https://www.eci.org/downloads

## Usage in Scripts

The automation scripts will automatically use profiles from this directory:

```bash
# Example: Converting image to CMYK with this profile
magick input.jpg -profile sRGB.icc -profile ISOcoated_v2_eci.icc output_cmyk.pdf
```

## Verification

To verify your printer's requirements:
1. Contact your print shop
2. Ask for their preferred ICC profile
3. Replace or add profiles here as needed
