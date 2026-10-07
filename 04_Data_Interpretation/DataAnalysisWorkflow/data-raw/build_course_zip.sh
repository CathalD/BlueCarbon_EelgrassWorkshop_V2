#!/bin/sh
# Maintainer tool: build the participant download, dist/BlueCarbon_Part4_Workshop.zip — one folder
# holding the RStudio project, Start_Here.R, the workflow, the workbooks, the reference data and the
# worked example's reports. It is assembled from the files git tracks in this folder, so there is no
# second copy to maintain; maintainer material (advanced/, data-raw/, tests/, the synthetic demo)
# is left out. usethis::use_course() opens the unpacked folder as an RStudio project.
# Run from DataAnalysisWorkflow/:  sh data-raw/build_course_zip.sh
set -e
NAME=BlueCarbon_Part4_Workshop
OUT="$(pwd)/dist/$NAME.zip"
T=$(mktemp -d)
D="$T/$NAME"
mkdir -p "$D" dist

git ls-files -- . | while IFS= read -r f; do
  case "$f" in
    advanced/*|data-raw/*|tests/*|data/synthetic/*|settings_synthetic.R|example_reports/SYNTHETIC*|.gitignore) continue ;;
  esac
  [ -f "$f" ] || continue
  mkdir -p "$D/$(dirname "$f")"
  cp "$f" "$D/$f"
done
mkdir -p "$D/my_data"
{
  echo "Blue Carbon Eelgrass Workshop - Part 4: data analysis workflow"
  echo "Built from commit $(git rev-parse --short HEAD) on $(date +%Y-%m-%d)."
  echo "https://github.com/CathalD/BlueCarbon_EelgrassWorkshop_V2"
} > "$D/VERSION.txt"
[ -z "$(git status --porcelain -- .)" ] || echo "Note: uncommitted changes in this folder are included; VERSION.txt names the last commit."

rm -f "$OUT"
(cd "$T" && zip -q -r -X "$OUT" "$NAME")
rm -rf "$T"
n=$(unzip -Z1 "$OUT" | grep -vc '/$')
echo "wrote $OUT ($n files, $(du -h "$OUT" | cut -f1))"
