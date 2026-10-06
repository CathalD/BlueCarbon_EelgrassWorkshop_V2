#!/bin/sh
# Maintainer tool: rebuild both workbooks from the original template, then recalculate them
# in LibreOffice so the saved files carry calculated values (needed by previews and readers).
# Usage (from DataAnalysisWorkflow/): sh data-raw/rebuild_workbooks.sh <original_template.xlsx>
set -e
python3 data-raw/build_workbooks.py "$1"
tmp=$(mktemp -d)
for f in Eelgrass_Carbon_DigitalData_BlankSheet Eelgrass_Carbon_DigitalData_Example; do
  soffice --headless --calc --convert-to xlsx --outdir "$tmp" "../files/$f.xlsx" >/dev/null 2>&1
  cp "$tmp/$f.xlsx" "../files/$f.xlsx"
done
rm -rf "$tmp"
echo "rebuilt and recalculated"
