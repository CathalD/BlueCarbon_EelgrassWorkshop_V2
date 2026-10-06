"""
render_sheet_range.py — maintainer tool for the workshop's spreadsheet figures.

Draws a cell range of a saved (recalculated) .xlsx as an HTML page that looks like the
spreadsheet — column letters, row numbers, the cells' own fills, fonts, merges and widths — with
optional numbered callouts and highlighted cells. data-raw/render_screenshots.sh turns the page
into a PNG with headless Chrome. Every value shown is read from the workbook; nothing is typed in.

Usage:
  python3 render_sheet_range.py <book.xlsx> <sheet> <A1:Z9> <out.html> [json_options]
json_options (all optional):
  {"callouts": {"B12": 1, "M12": 2}, "highlight": ["AA12"], "hide_cols": ["F", "G"],
   "title": "…", "note": "…", "scale": 1.0}
"""
import html, json, sys
import openpyxl
from openpyxl.utils import column_index_from_string, get_column_letter, range_boundaries


def fmt(v, nf):
    if v is None:
        return ""
    if isinstance(v, bool):
        return str(v)
    if isinstance(v, (int, float)):
        if nf and "%" in nf and "." not in nf:
            return f"{v:.0%}"
        if nf and "%" in nf:
            d = len(nf.split(".")[1].rstrip("%")) if "." in nf else 0
            return f"{v:.{d}%}"
        if nf and nf.startswith("0.") and set(nf[2:]) <= {"0"}:
            return f"{v:.{len(nf) - 2}f}"
        if nf in ("0", "#,##0"):
            return f"{v:,.0f}" if "," in nf else f"{v:.0f}"
        if isinstance(v, float):
            return f"{v:.4g}" if abs(v) < 1e5 else f"{v:,.0f}"
        return f"{v:,}" if abs(v) >= 10000 else str(v)
    return str(v)


def colour(c):
    try:
        rgb = c.rgb if c is not None else None
    except Exception:
        return None
    if isinstance(rgb, str) and len(rgb) == 8 and rgb not in ("00000000",):
        return "#" + rgb[2:]
    return None


def render(book, sheet, rng, out, opts):
    wb = openpyxl.load_workbook(book, data_only=True)
    ws = wb[sheet]
    c0, r0, c1, r1 = range_boundaries(rng)
    hide = {column_index_from_string(x) for x in opts.get("hide_cols", [])}
    cols = [c for c in range(c0, c1 + 1) if c not in hide]
    merged = {}
    covered = set()
    for m in ws.merged_cells.ranges:
        if m.min_row > r1 or m.max_row < r0 or m.min_col > c1 or m.max_col < c0:
            continue
        mc = [c for c in range(max(m.min_col, c0), min(m.max_col, c1) + 1) if c not in hide]
        merged[(max(m.min_row, r0), mc[0] if mc else m.min_col)] = (min(m.max_row, r1) - max(m.min_row, r0) + 1, len(mc))
        for r in range(max(m.min_row, r0), min(m.max_row, r1) + 1):
            for c in mc:
                covered.add((r, c))
    callouts = opts.get("callouts", {})
    hl = set(opts.get("highlight", []))
    def width(c):
        w = ws.column_dimensions[get_column_letter(c)].width
        return int((w or 8.43) * 7 + 5)
    css = """
    body { margin: 0; padding: 14px; background: #ffffff; font-family: Calibri, Carlito, Arial, sans-serif; }
    .t { font: bold 15px Helvetica, Arial, sans-serif; color: #1b1f23; margin: 0 0 4px 2px; }
    .n { font: 12px Helvetica, Arial, sans-serif; color: #57606a; margin: 0 0 8px 2px; max-width: 1100px; }
    table { border-collapse: collapse; table-layout: fixed; }
    td { border: 1px solid #d4d4d4; font-size: 12px; padding: 2px 4px; overflow: hidden; vertical-align: top;
         position: relative; }
    td.h, th { background: #f3f3f3; color: #666; font: 11px Arial, sans-serif; text-align: center; border: 1px solid #c8c8c8; }
    td.hl { outline: 3px solid #b5402a; outline-offset: -3px; }
    td.cot { padding-left: 24px; }
    .co { position: absolute; top: 1px; left: 2px; background: #b5402a; color: #fff; border-radius: 50%;
          width: 18px; height: 18px; font: bold 11px/18px Arial, sans-serif; text-align: center; z-index: 2; }
    """
    h = [f"<!doctype html><meta charset='utf-8'><style>{css}</style>"]
    if opts.get("title"):
        h.append(f"<div class='t'>{html.escape(opts['title'])}</div>")
    if opts.get("note"):
        h.append(f"<div class='n'>{html.escape(opts['note'])}</div>")
    h.append("<table><colgroup><col style='width:34px'>" + "".join(f"<col style='width:{width(c)}px'>" for c in cols) + "</colgroup>")
    h.append("<tr><td class='h'></td>" + "".join(f"<td class='h'>{get_column_letter(c)}</td>" for c in cols) + "</tr>")
    for r in range(r0, r1 + 1):
        ht = ws.row_dimensions[r].height
        h.append(f"<tr style='height:{int((ht or 15) * 1.33)}px'><td class='h'>{r}</td>")
        for c in cols:
            if (r, c) in covered and (r, c) not in merged:
                continue
            cell = ws.cell(r, c)
            st = []
            bg = colour(cell.fill.fgColor) if cell.fill and cell.fill.fill_type == "solid" else None
            if bg: st.append(f"background:{bg}")
            if cell.font is not None:
                if cell.font.b: st.append("font-weight:bold")
                if cell.font.i: st.append("font-style:italic")
                fc = colour(cell.font.color)
                if fc: st.append(f"color:{fc}")
                if cell.font.sz: st.append(f"font-size:{min(float(cell.font.sz), 16) * 1.0:.0f}px")
            al = cell.alignment
            wrap = al is not None and al.wrap_text
            st.append("white-space:" + ("normal" if wrap else "nowrap"))
            v = cell.value
            if isinstance(v, (int, float)) and not isinstance(v, bool):
                st.append("text-align:right")
            if al is not None and al.horizontal in ("center", "centerContinuous"):
                st.append("text-align:center")
            span = merged.get((r, c))
            attrs = f" rowspan={span[0]} colspan={span[1]}" if span else ""
            ref = f"{get_column_letter(c)}{r}"
            klass = " ".join(k for k, on in (("hl", ref in hl), ("cot", ref in callouts)) if on)
            cls = f" class='{klass}'" if klass else ""
            badge = f"<span class='co'>{callouts[ref]}</span>" if ref in callouts else ""
            text = html.escape(fmt(v, cell.number_format)).replace("\n", "<br>")
            h.append(f"<td{attrs}{cls} style='{';'.join(st)}'>{badge}{text}</td>")
        h.append("</tr>")
    h.append("</table>")
    open(out, "w", encoding="utf-8").write("\n".join(h))


if __name__ == "__main__":
    book, sheet, rng, out = sys.argv[1:5]
    opts = json.loads(sys.argv[5]) if len(sys.argv) > 5 else {}
    render(book, sheet, rng, out, opts)
    print("wrote", out)
