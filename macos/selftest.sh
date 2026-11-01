#!/bin/bash
# Tests the Mac app for real: builds a test copy against a scratch copy of this repo, then lets it
# click through its own window (downloads, links, dialogs, file import, server start and stop) and
# prints its report. A window appears for about half a minute; your own data isn't touched.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
copy="$work/quant-terminal"
rsync -a --exclude .git --exclude data "$here/../" "$copy/"
QT_SELFTEST=1 QT_APP_FOLDER="$copy" "$here/build.sh" "$work" >/dev/null
mkdir -p "$work/out" "$work/downloads"

# 60 daily bars for the import step.
csv="$work/selftest-bars.csv"
echo "time,open,high,low,close,volume" >"$csv"
for i in $(seq 0 59); do
  c=$((100 + i))
  echo "$(date -j -v+"${i}"d -f %Y-%m-%d 2026-01-01 +%Y-%m-%d),$c,$((c + 2)),$((c - 2)),$((c + 1)),1000" >>"$csv"
done

QT_SELFTEST_OUT="$work/out" QT_SELFTEST_DOWNLOADS="$work/downloads" QT_SELFTEST_FILE="$csv" \
  QT_SELFTEST_ANSWERS="Selftest strategy|Temp|cancel|ok" \
  "$work/Quant Terminal Selftest.app/Contents/MacOS/Quant Terminal Selftest" &
pid=$!
for _ in $(seq 120); do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid"
  echo "The test app didn't finish within 2 minutes." >&2
fi
node "$copy/scripts/stop.js" >/dev/null  # in case the app stopped before it could
cat "$work/out/report.json" 2>/dev/null || echo "No report was written." >&2
echo "Snapshots, downloads and the scratch copy: $work"
