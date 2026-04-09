#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  Manual trim with PDF-point margins:
    trim_pdf_page_to_png.sh INPUT.pdf OUTPUT.png PAGE DPI LEFT_PT BOTTOM_PT RIGHT_PT TOP_PT

  Automatic trim of the main rectangle on the page:
    trim_pdf_page_to_png.sh --auto-main INPUT.pdf OUTPUT.png PAGE DPI

What it does:
  1. Renders one PDF page to PNG with `pdftoppm`.
  2. Either:
     - crops with explicit margins in PDF points, or
     - detects the dominant non-white rectangle on the page and crops to it.

Why `--auto-main` exists:
  Some PDFs include crop marks, tiny headers, or printer metadata near the
  edges. A plain `-trim` often fails on those files. `--auto-main` instead looks
  for the largest region where most rows/columns are filled with non-white
  pixels, which works well for pages like the periodic table.

Dependencies:
  - pdfinfo
  - pdftoppm
  - convert   (ImageMagick)
  - python3   (only for --auto-main)

Examples:
  Manual trim in PDF points:
    ./trim_pdf_page_to_png.sh taula-periodica_2024-BLAU.pdf TaulaPeriodica.png 1 600 29 10 5 29

  Automatic crop of the main page rectangle:
    ./trim_pdf_page_to_png.sh --auto-main taula-periodica_2024-BLAU.pdf TaulaPeriodica.png 1 600

Tip:
  Start with a low DPI like 150 while tuning. When the crop is right, rerun at
  300 or 600 dpi for the final PNG.
EOF
}

require_cmd() {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Missing command: $cmd" >&2
      exit 1
    fi
  done
}

render_page() {
  pdftoppm -r "$dpi" -f "$page" -singlefile -png "$input_pdf" "$tmp_base"
}

crop_manual() {
  page_info=$(pdfinfo -f "$page" -l "$page" "$input_pdf")
  page_size_line=$(printf '%s\n' "$page_info" | awk -F': *' '/^Page size:/ {print $2; exit}')

  if [[ -z "$page_size_line" ]]; then
    echo "Could not read page size from: $input_pdf" >&2
    exit 1
  fi

  page_width_pt=$(printf '%s\n' "$page_size_line" | awk '{print $1}')
  page_height_pt=$(printf '%s\n' "$page_size_line" | awk '{print $3}')

  render_info=$(identify -format '%w %h' "$tmp_png")
  render_width_px=${render_info%% *}
  render_height_px=${render_info##* }

  left_px=$(awk -v trim="$left_pt" -v page="$page_width_pt" -v px="$render_width_px" 'BEGIN { printf "%.0f", trim * px / page }')
  right_px=$(awk -v trim="$right_pt" -v page="$page_width_pt" -v px="$render_width_px" 'BEGIN { printf "%.0f", trim * px / page }')
  bottom_px=$(awk -v trim="$bottom_pt" -v page="$page_height_pt" -v px="$render_height_px" 'BEGIN { printf "%.0f", trim * px / page }')
  top_px=$(awk -v trim="$top_pt" -v page="$page_height_pt" -v px="$render_height_px" 'BEGIN { printf "%.0f", trim * px / page }')

  crop_width_px=$(( render_width_px - left_px - right_px ))
  crop_height_px=$(( render_height_px - top_px - bottom_px ))

  if (( crop_width_px <= 0 || crop_height_px <= 0 )); then
    echo "Invalid crop: output size would be ${crop_width_px}x${crop_height_px}px" >&2
    exit 1
  fi

  convert "$tmp_png" \
    -crop "${crop_width_px}x${crop_height_px}+${left_px}+${top_px}" \
    +repage \
    "$output_png"

  cat <<EOF
Created: $output_png

Mode:
  manual trim in PDF points

Input page:
  $input_pdf (page $page)

Page size:
  ${page_width_pt}pt x ${page_height_pt}pt

Rendered size:
  ${render_width_px}px x ${render_height_px}px at ${dpi} dpi

Applied trim:
  left=${left_pt}pt (${left_px}px)
  bottom=${bottom_pt}pt (${bottom_px}px)
  right=${right_pt}pt (${right_px}px)
  top=${top_pt}pt (${top_px}px)

Final PNG size:
  ${crop_width_px}px x ${crop_height_px}px
EOF
}

crop_auto_main() {
  require_cmd python3

  auto_geometry=$(python3 - "$tmp_png" <<'PY'
from PIL import Image
import sys

path = sys.argv[1]
img = Image.open(path).convert("RGB")
full_w, full_h = img.size

# Keep the scan cheap but stable.
scale = max(1, max(full_w, full_h) // 1200)
small = img.resize((max(1, full_w // scale), max(1, full_h // scale)))
w, h = small.size
pix = small.load()

white_threshold = 245
fill_ratio = 0.60

rows = []
for y in range(h):
    non_white = 0
    for x in range(w):
        r, g, b = pix[x, y]
        if not (r > white_threshold and g > white_threshold and b > white_threshold):
            non_white += 1
    rows.append(non_white)

cols = []
for x in range(w):
    non_white = 0
    for y in range(h):
        r, g, b = pix[x, y]
        if not (r > white_threshold and g > white_threshold and b > white_threshold):
            non_white += 1
    cols.append(non_white)

row_idx = [i for i, c in enumerate(rows) if c > fill_ratio * w]
col_idx = [i for i, c in enumerate(cols) if c > fill_ratio * h]

if not row_idx or not col_idx:
    raise SystemExit("Could not detect a dominant page rectangle")

left = col_idx[0] * scale
top = row_idx[0] * scale
right = min(full_w, (col_idx[-1] + 1) * scale)
bottom = min(full_h, (row_idx[-1] + 1) * scale)

print(left, top, right - left, bottom - top)
PY
)

read -r left_px top_px crop_width_px crop_height_px <<<"$auto_geometry"

if (( crop_width_px <= 0 || crop_height_px <= 0 )); then
    echo "Invalid auto crop: ${crop_width_px}x${crop_height_px}px" >&2
    exit 1
  fi

  convert "$tmp_png" \
    -crop "${crop_width_px}x${crop_height_px}+${left_px}+${top_px}" \
    +repage \
    "$output_png"

  cat <<EOF
Created: $output_png

Mode:
  automatic dominant-rectangle crop

Input page:
  $input_pdf (page $page)

Rendered size:
  $(identify -format '%wpx x %hpx' "$tmp_png") at ${dpi} dpi

Detected crop:
  left=${left_px}px
  top=${top_px}px
  width=${crop_width_px}px
  height=${crop_height_px}px
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

mode="manual"
if [[ "${1:-}" == "--auto-main" ]]; then
  mode="auto-main"
  shift
fi

if [[ "$mode" == "manual" && $# -ne 8 ]]; then
  usage >&2
  exit 1
fi

if [[ "$mode" == "auto-main" && $# -ne 4 ]]; then
  usage >&2
  exit 1
fi

input_pdf=$1
output_png=$2
page=$3
dpi=$4

if [[ "$mode" == "manual" ]]; then
  left_pt=$5
  bottom_pt=$6
  right_pt=$7
  top_pt=$8
fi

require_cmd pdfinfo pdftoppm convert awk mktemp identify

if [[ ! -f "$input_pdf" ]]; then
  echo "Input PDF not found: $input_pdf" >&2
  exit 1
fi

tmp_base=$(mktemp -u /tmp/trim_pdf_page_to_png.XXXXXX)
tmp_png="${tmp_base}.png"
trap 'rm -f "$tmp_png"' EXIT

render_page

if [[ "$mode" == "manual" ]]; then
  crop_manual
else
  crop_auto_main
fi
