#!/usr/bin/env bash
# Render previews of the hearth board from sample data.
#   addon/tools/preview/preview.sh <output folder> [scale]
# Writes hearth-board.png, hearth-form.png and hearth-empty.png.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=${1:?give an output folder}
scale=${2:-1.5}
mkdir -p "$out"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
python3 "$here/render.py" --metrics "$work/metrics.lua"
for scene in board form empty; do
    LUA_PATH="$work/?.lua;;" luajit "$here/preview.lua" "$scene" > "$work/$scene.json"
    python3 "$here/render.py" "$work/$scene.json" "$out/hearth-$scene.png" "$scale"
done
