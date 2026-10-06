#!/bin/sh
# Maintainer tool: regenerate the workshop's generated figures (spreadsheet crops, report
# screenshots, result cards, Part 4 figures). Participants never need this.
# Needs: LibreOffice, Google Chrome, a Python with openpyxl (PYTHON=...), R with ggplot2 + magick,
# pandoc (RSTUDIO_PANDOC=...). Run from DataAnalysisWorkflow/:
#   PYTHON=~/venv/bin/python RSTUDIO_PANDOC=... sh data-raw/render_screenshots.sh
set -e
PY="${PYTHON:-python3}"
RS="${RSCRIPT:-Rscript}"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
SOFFICE=$(command -v soffice || echo /Applications/LibreOffice.app/Contents/MacOS/soffice)
T=$(mktemp -d)
R="data-raw/render_sheet_range.py"
EX=../files/Eelgrass_Carbon_DigitalData_Example.xlsx
LAB=../files/Example_Lab_Results.xlsx
CALC=../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx
CALCX=../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2_Tsawwassen_Example.xlsx

# 1. Fresh analysis outputs (figures and reports the cards and screenshots are made from)
"$RS" -e 'source("run_option_A.R")' >/dev/null
"$RS" -e 'source("run_option_B.R")' >/dev/null
"$RS" -e 'SETTINGS_FILE <- "settings_synthetic.R"; source("run_option_B.R")' >/dev/null

# 2. A copy of the Example with one deliberate typo (COW-S5 slice 3 top typed as 1.5, not 2.0)
"$PY" - "$EX" "$T/typo.xlsx" <<'EOF'
import sys, openpyxl
wb = openpyxl.load_workbook(sys.argv[1]); smp = wb["3. Sample Data"]
smp["C8"] = 1.5
wb.save(sys.argv[2])
EOF
"$SOFFICE" --headless --calc --convert-to xlsx --outdir "$T/typo" "$T/typo.xlsx" >/dev/null 2>&1

# 3. Spreadsheet ranges -> HTML
"$PY" $R "$LAB" Results A10:O13 "$T/lab.html" '{"callouts": {"B12": 1, "D12": 2, "H12": 3, "M12": 4}}'
"$PY" $R "$EX" "3. Sample Data" A3:O7 "$T/wb.html" '{"callouts": {"A6": 1, "C6": 2, "M6": 3, "N6": 4, "O6": 5}}'
"$PY" $R "$EX" "3. Sample Data" A5:AA8 "$T/check_ok.html" \
  '{"hide_cols": ["E","F","G","H","I","J","K","L","P","S","T","U","W","X","Y","Z"], "highlight": ["AA6","AA7","AA8"]}'
"$PY" $R "$T/typo/typo.xlsx" "3. Sample Data" A5:AA8 "$T/check_bad.html" \
  '{"hide_cols": ["E","F","G","H","I","J","K","L","P","S","T","U","W","X","Y","Z"], "highlight": ["C8","AA7","AA8"]}'
"$PY" $R "$CALCX" "2 Stratified" B5:H33 "$T/calc_strat.html" '{"highlight": ["C32","C33","G14","G15"], "callouts": {"C14": 1, "D14": 2, "C32": 3, "G14": 4}}'
"$PY" $R "$CALC" "4 Precision Check" B5:D16 "$T/calc_check.html" '{"highlight": ["C15","C16"]}'

# 4. HTML -> PNG (wide canvas; trimmed in R)
for f in lab wb check_ok check_bad calc_strat calc_check; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1900,1200 --screenshot="$T/$f.png" "file://$T/$f.html" 2>/dev/null
done
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1000,2400 --screenshot="$T/report_A.png" "file://$PWD/outputs/option_A/report_option_A.html" 2>/dev/null
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1000,2600 --screenshot="$T/report_B.png" "file://$PWD/outputs/option_B/report_option_B.html" 2>/dev/null

# 5. Compose figures and cards
"$RS" data-raw/make_workshop_figures.R "$T"

# 6. Example reports kept with the repository
mkdir -p example_reports
cp outputs/option_A/report_option_A.html example_reports/cowichan_report_option_A.html
cp outputs/option_B/report_option_B.html example_reports/cowichan_report_option_B.html
cp outputs/option_B_synthetic/report_option_B.html example_reports/SYNTHETIC_report_option_B_stratified.html
rm -rf "$T"
echo "figures regenerated"
