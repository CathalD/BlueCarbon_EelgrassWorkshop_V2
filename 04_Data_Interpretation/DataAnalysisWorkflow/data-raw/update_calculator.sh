#!/bin/sh
# Maintainer tool: apply data-raw/update_calculator.py to the Part 2 calculator, starting from the
# pre-2026.2 version in git history (so it can be re-run), and recalculate both outputs in LibreOffice.
# Usage (from DataAnalysisWorkflow/): PYTHON=<python with openpyxl> sh data-raw/update_calculator.sh
set -e
tmp=$(mktemp -d)
SOFFICE=$(command -v soffice || echo /Applications/LibreOffice.app/Contents/MacOS/soffice)
git show b832544:02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx > "$tmp/calc.xlsx"
"$SOFFICE" --headless --calc --convert-to xlsx --outdir "$tmp/lo" "$tmp/calc.xlsx" >/dev/null 2>&1
"${PYTHON:-python3}" data-raw/update_calculator.py "$tmp/lo/calc.xlsx"
for f in ../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx \
         ../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2_Tsawwassen_Example.xlsx; do
  "$SOFFICE" --headless --calc --convert-to xlsx --outdir "$tmp/out" "$f" >/dev/null 2>&1
  cp "$tmp/out/$(basename "$f")" "$f"
done
rm -rf "$tmp"
echo "calculator updated and recalculated"
