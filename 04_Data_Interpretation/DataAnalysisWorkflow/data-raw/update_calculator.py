"""
update_calculator.py — maintainer tool, participants never need to run this.

Applies the 2026.2 changes to the Part 2 Sample Allocation Calculator and writes a separate
Tsawwassen worked-example copy:

  * a "Plots are the sampling frame?" switch (Yes/No, default No) on sheets 1, 2 and 4, feeding
    sheet 5. With No, the area is treated as continuous and no finite-population correction is
    applied: n = (z·CV/E)². With Yes, Cochran's finite-population form is used;
  * sheet 4 (precision check) uses Student's t (n − 1 degrees of freedom; n − H when stratified);
  * sheet 2's example rows are labelled with the priors they actually use;
  * notes, version and changelog updated.

Usage (from DataAnalysisWorkflow/), with a Python that has openpyxl:
  python3 data-raw/update_calculator.py <calculator_after_LibreOffice_roundtrip.xlsx>
data-raw/update_calculator.sh does the LibreOffice round trip before and the recalculation after
(the round trip turns the sheet-1 prior dropdown into a standard data validation that openpyxl keeps).
"""
import sys
from copy import copy
import openpyxl
from openpyxl.worksheet.datavalidation import DataValidation

SRC = sys.argv[1]
OUT = "../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx"
OUT_EX = "../../02_Project_Planning/BlueCarbon_SampleAllocation_Spreadsheet_V2_Tsawwassen_Example.xlsx"
FRAME_NOTE = ("Yes only if cores are drawn from a fixed list of plots (e.g. the sampling tool's grid of "
              "positions). No = treat the area as continuous (no finite-population correction).")


def like(dst, src):
    dst.font, dst.fill, dst.border = copy(src.font), copy(src.fill), copy(src.border)
    dst.alignment, dst.number_format, dst.protection = copy(src.alignment), src.number_format, copy(src.protection)


def switch(ws, row, label_from, input_from, note_from, note=FRAME_NOTE):
    ws[f"B{row}"] = "Plots are the sampling frame?"; like(ws[f"B{row}"], ws[label_from])
    ws[f"C{row}"] = "No"; like(ws[f"C{row}"], ws[input_from])
    ws[f"D{row}"] = note; like(ws[f"D{row}"], ws[note_from])
    dv = DataValidation(type="list", formula1='"No,Yes"', allow_blank=False)
    ws.add_data_validation(dv); dv.add(f"C{row}")


def update(wb):
    s1, s2, s4, s5, notes, start = (wb[n] for n in ["1 Sample Size", "2 Stratified", "4 Precision Check",
                                                     "5 Sensitivity", "Notes and Sources", "Start Here"])
    # ---- sheet 1
    switch(s1, 9, "B8", "C7", "D8")
    s1["D8"] = "area ÷ plot size (used only if the plots are the sampling frame)"
    s1["C25"] = ('=IFERROR(IF(UPPER(C9)="YES",ROUNDUP((C12^2*C8*C20^2)/((C8-1)*C13^2+C12^2*C20^2),0),'
                 'ROUNDUP((C12*C20/C13)^2,0)),"")')
    # ---- sheet 2
    switch(s2, 11, "B10", "C9", "D10")
    s2["C32"] = ('=IFERROR(IF(UPPER(C11)="YES",ROUNDUP((C8^2*C28*C31)/((C28-1)*C9^2+C8^2*C31),0),'
                 'ROUNDUP(C8^2*C31/C9^2,0)),"")')
    s2["B38"] = ("Example rows use two seagrass priors from sheet 3 — British Columbia (20.6 / 11.9) and "
                 "Washington (17.1 / 6.9) — standing in for two strata. Overwrite them with your own.")
    # ---- sheet 4
    s4["B12"] = "t multiplier (n − 1 degrees of freedom)"
    s4["C12"] = '=IFERROR(TINV(1-C10,C7-1),"")'
    switch(s4, 13, "B11", "C11", "B11", note=None)
    s4["D13"] = None
    s4["B6"] = "Possible plot locations, N (only if the plots are the sampling frame)"
    s4["C14"] = '=IFERROR(SQRT(IF(UPPER(C13)="YES",1-C7/C6,1)*C9^2/C7),"")'
    for r in range(21, 31):
        s4[f"G{r}"] = (f'=IFERROR((C{r}/$C$32)^2*IF(UPPER($C$13)="YES",1-F{r}/(C{r}/$C$33),1)*E{r}^2/F{r},"")')
    s4["C36"] = '=IFERROR(TINV(1-C10,SUM(F21:F30)-COUNT(F21:F30))*C35/C34,"")'
    s4["B39"] = ("Part B uses the confidence level, target and sampling-frame setting from part A; its t "
                 "multiplier uses n − H degrees of freedom (H = number of strata with cores).")
    # ---- sheet 5
    s5["B3"] = "Appendix A4. Live from sheet 1's confidence level and sampling-frame setting."
    for r in range(11, 19):
        for col in "CDEFGH":
            s5[f"{col}{r}"] = (f"=IFERROR(IF(UPPER('1 Sample Size'!$C$9)=\"YES\","
                               f"ROUNDUP(($C$7^2*$C$5*$B{r}^2)/(($C$5-1)*{col}$10^2+$C$7^2*$B{r}^2),0),"
                               f"ROUNDUP(($C$7*$B{r}/{col}$10)^2,0)),\"\")")
    # ---- notes, version
    notes["C5"] = "N = study area ÷ plot size, rounded down — used only if the plots are the sampling frame"
    notes["C7"] = ("n = (z·CV/E)² for a continuous area (default); with a plot frame, Cochran: "
                   "n = z²·N·CV² / ((N−1)·E² + z²·CV²)")
    notes["C8"] = "same formula with V = pooled variance ÷ overall mean² (both area-weighted) in place of CV²"
    notes["C10"] = ("RME = t × SE ÷ sample mean, t with n − 1 df (n − H stratified); SE = √(s²/n), "
                    "times (1 − n/N) only with a plot frame")
    notes["B25"] = ("•  Planning (sheets 1, 2 and 5) uses z; the precision check (sheet 4) uses Student's t, "
                    "which is wider for small campaigns.")
    if notes["B29"].value is None:
        notes["B29"] = ("•  The finite-population correction is used only when cores are drawn from a fixed list "
                        "of plots. For most meadows it changes the answer by less than one core.")
        like(notes["B29"], notes["B28"])
    notes["B39"] = "Version 2026.2 · Replaces SampleDesign_SampleAllocationCalculator_WithStrata.xlsx"
    notes["B40"] = (str(notes["B40"].value) + " 2026.2: sampling-frame switch (finite-population correction "
                    "optional, default off); t in the precision check; sheet 2 example labels.")
    start["B29"] = str(start["B29"].value).replace("Version 2026.1", "Version 2026.2")


def tsawwassen(wb):
    s1, s2, start = wb["1 Sample Size"], wb["2 Stratified"], wb["Start Here"]
    start["B2"] = str(start["B2"].value) + " — Tsawwassen worked example"
    start["B6"] = ("TSAWWASSEN WORKED EXAMPLE (Part 2). The inputs are the Tsawwassen team's: two eelgrass zones "
                   "from the sampling-design tool, and the tool's Pacific Northwest eelgrass prior "
                   "(24.8 ± 16.8 Mg C/ha to 30 cm, Janousek et al. 2025). Use the blank calculator for your own "
                   "site. " + str(start["B6"].value))
    s1["C6"] = 10757500; s1["C9"] = "No"; s1["C11"] = 0.90; s1["C13"] = 0.20
    s1["C16"] = "Custom — enter my own mean and SD"; s1["C17"] = 30; s1["C21"] = 24.8; s1["C22"] = 16.8
    s2["C7"] = 0.90; s2["C9"] = 0.20; s2["C11"] = "No"
    rows = [("Zone 3 — high-density eelgrass", 7138000), ("Zone 2 — low-density eelgrass", 3619500)]
    for k, (name, area) in enumerate(rows):
        r = 14 + k
        s2[f"B{r}"], s2[f"C{r}"], s2[f"D{r}"], s2[f"E{r}"] = name, area, 24.8, 16.8
    s2["B38"] = ("Tsawwassen zones from the sampling-design tool (Zone 1, 171.14 ha of wetland edge, excluded). "
                 "Both use the tool's Pacific Northwest eelgrass prior, 24.8 ± 16.8 Mg C/ha to 30 cm.")


if __name__ == "__main__":
    wb = openpyxl.load_workbook(SRC); update(wb); wb.save(OUT)
    wb = openpyxl.load_workbook(OUT); tsawwassen(wb); wb.save(OUT_EX)
    print("written", OUT, OUT_EX)
