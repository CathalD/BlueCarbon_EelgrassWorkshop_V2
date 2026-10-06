#!/bin/sh
# Maintainer tool: rebuild the workbooks from the original template, then recalculate them
# in LibreOffice so the saved files carry calculated values (needed by previews and readers).
# Usage (from DataAnalysisWorkflow/): sh data-raw/rebuild_workbooks.sh [original_template.xlsx]
#   With no argument the original 2026 template is taken from git history (commit 39383d1).
#   PYTHON can point at a Python with openpyxl, e.g. PYTHON=~/venv/bin/python sh data-raw/...
set -e
tmp=$(mktemp -d)
template="$1"
if [ -z "$template" ]; then
  template="$tmp/template.xlsx"
  git show 39383d1:04_Data_Interpretation/files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx > "$template"
fi
SOFFICE=$(command -v soffice || echo /Applications/LibreOffice.app/Contents/MacOS/soffice)
[ -x "$SOFFICE" ] || { echo "LibreOffice (soffice) not found"; exit 1; }

"${PYTHON:-python3}" data-raw/build_workbooks.py "$template"
for f in ../files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx \
         ../files/Eelgrass_Carbon_DigitalData_Example.xlsx \
         data/synthetic/Eelgrass_Carbon_DigitalData_SYNTHETIC.xlsx; do
  [ -f "$f" ] || continue
  "$SOFFICE" --headless --calc --convert-to xlsx --outdir "$tmp" "$f" >/dev/null 2>&1
  cp "$tmp/$(basename "$f")" "$f"
done
rm -rf "$tmp"
echo "rebuilt and recalculated"
