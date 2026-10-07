#!/bin/sh
# Maintainer tool: regenerate the workshop's generated figures (spreadsheet crops, report
# screenshots, result cards, Part 4 figures, field data sheet crops). Participants never need this.
# Needs: LibreOffice, Google Chrome, a Python with openpyxl (PYTHON=...), R with ggplot2 + magick,
# pandoc (RSTUDIO_PANDOC=...), pdftoppm (poppler). Run from DataAnalysisWorkflow/:
#   PYTHON=~/venv/bin/python RSTUDIO_PANDOC=... sh data-raw/render_screenshots.sh
set -e
PY="${PYTHON:-python3}"
RS="${RSCRIPT:-Rscript}"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
SOFFICE=$(command -v soffice || echo /Applications/LibreOffice.app/Contents/MacOS/soffice)
T=$(mktemp -d)
R="data-raw/render_sheet_range.py"
EX=workbooks/Eelgrass_Carbon_DigitalData_Example.xlsx
LAB=workbooks/Example_Lab_Results.xlsx
CALC=../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx
CALCX=../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2_Tsawwassen_Example.xlsx

# 1. Fresh analysis outputs (figures and reports the cards and screenshots are made from)
"$RS" -e 'SETTINGS_FILE <- "settings_example.R"; source("run_option_A.R")' >/dev/null
"$RS" -e 'SETTINGS_FILE <- "settings_example.R"; source("run_option_B.R")' >/dev/null
"$RS" -e 'SETTINGS_FILE <- "settings_synthetic.R"; source("run_option_B.R")' >/dev/null

# 2. A copy of the Example with one deliberate typo (COW-S5 slice 3 top typed as 1.5, not 2.0)
"$PY" - "$EX" "$T/typo.xlsx" <<'EOF'
import sys, openpyxl
wb = openpyxl.load_workbook(sys.argv[1]); smp = wb["3. Sample Data"]
smp["C8"] = 1.5
wb.save(sys.argv[2])
EOF
"$SOFFICE" --headless --calc --convert-to xlsx --outdir "$T/typo" "$T/typo.xlsx" >/dev/null 2>&1

# 2b. The constructed Tsawwassen field sheet (core WWF-01-A, 03_Field_Methods/datasheets/) typed into a
#     copy of the blank workbook: field columns only, as it stands before the lab results come back
"$PY" - workbooks/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx "$T/tsaw.xlsx" <<'EOF'
import sys, openpyxl
wb = openpyxl.load_workbook(sys.argv[1])
ins, log, smp = wb["1. Instructions"], wb["2. Plot & Core Log"], wb["3. Sample Data"]
ref = wb.defined_names["CORER_DIAMETER_CM"].attr_text.split("!")[1].replace("$", "")
ins[ref] = 7.7
for col, v in zip("ABCDEFGIKLP", ["WWF-01", "WWF-01-A", "2026-06-16", "10:45", "Tsawwassen Beach, BC (teaching example)",
                                   49.033540, -123.131287, "Partly cloudy, low tide", 65, 58, "Zone 3"]):
    log[f"{col}6"] = v
for k, (top, bot) in enumerate([(0, 5), (5, 10), (10, 15), (15, 25), (25, 40), (40, 58)]):
    r = 6 + k
    smp[f"A{r}"], smp[f"B{r}"], smp[f"C{r}"], smp[f"D{r}"] = "WWF-01-A", k + 1, top, bot
smp["E6"] = "Dense live root mat, dark brown silty clay"; smp["E11"] = "Base of core"
wb.save(sys.argv[2])
EOF
"$SOFFICE" --headless --calc --convert-to xlsx --outdir "$T/tsaw" "$T/tsaw.xlsx" >/dev/null 2>&1

# 3. Spreadsheet ranges -> HTML
"$PY" $R "$LAB" Results A10:O13 "$T/lab.html" '{"callouts": {"B12": 1, "D12": 2, "H12": 3, "M12": 4}}'
"$PY" $R "$EX" "3. Sample Data" A3:O7 "$T/wb.html" '{"callouts": {"A6": 1, "C6": 2, "M6": 3, "N6": 4, "O6": 5}}'
"$PY" $R "$EX" "3. Sample Data" A5:AA8 "$T/check_ok.html" \
  '{"hide_cols": ["E","F","G","H","I","J","K","L","P","S","T","U","W","X","Y","Z"], "highlight": ["AA6","AA7","AA8"]}'
"$PY" $R "$T/typo/typo.xlsx" "3. Sample Data" A5:AA8 "$T/check_bad.html" \
  '{"hide_cols": ["E","F","G","H","I","J","K","L","P","S","T","U","W","X","Y","Z"], "highlight": ["C8","AA7","AA8"]}'
"$PY" $R "$CALCX" "2 Stratified" B5:H33 "$T/calc_strat.html" '{"highlight": ["C32","C33","G14","G15"], "callouts": {"C14": 1, "D14": 2, "C32": 3, "G14": 4}}'
"$PY" $R "$CALC" "4 Precision Check" B5:D16 "$T/calc_check.html" '{"highlight": ["C15","C16"]}'
"$PY" $R "$T/tsaw/tsaw.xlsx" "2. Plot & Core Log" A5:T6 "$T/tsaw_log.html" \
  '{"hide_cols": ["D","E","H","I","J","N","Q","R","T"], "highlight": ["B6","K6","L6","P6"]}'
"$PY" $R "$T/tsaw/tsaw.xlsx" "3. Sample Data" A5:AA11 "$T/tsaw_smp.html" \
  '{"hide_cols": ["E","F","H","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"], "highlight": ["AA6","AA7","AA8","AA9","AA10","AA11"]}'

# 4. HTML -> PNG (wide canvas; trimmed in R)
for f in lab wb check_ok check_bad calc_strat calc_check tsaw_log tsaw_smp; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1900,1200 --screenshot="$T/$f.png" "file://$T/$f.html" 2>/dev/null
done
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1000,2400 --screenshot="$T/report_A.png" "file://$PWD/outputs/example/option_A/report_option_A.html" 2>/dev/null
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1000,2600 --screenshot="$T/report_B.png" "file://$PWD/outputs/example/option_B/report_option_B.html" 2>/dev/null

# 5. Compose figures and cards; then the field data sheet figures, cut from the two datasheet PDFs
"$RS" data-raw/make_workshop_figures.R "$T"
"$RS" data-raw/make_datasheet_figures.R

# 6. Example reports kept with the repository
mkdir -p example_reports
cp outputs/example/option_A/report_option_A.html example_reports/cowichan_report_option_A.html
cp outputs/example/option_B/report_option_B.html example_reports/cowichan_report_option_B.html
cp outputs/synthetic/option_B/report_option_B.html example_reports/SYNTHETIC_report_option_B_stratified.html
rm -rf "$T"
echo "figures regenerated"
