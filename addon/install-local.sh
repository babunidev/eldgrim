#!/usr/bin/env bash
# Copy addon/Eldgrim into the local Forever AddOns folder for testing.
# The repository copy is the source. This does not copy the game folder back.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/addon/Eldgrim"
dest="${ELDGRIM_ADDON_DEST:-/home/babuni/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns/Eldgrim}"
force=0

if [[ "${1:-}" == "--force" ]]; then
    force=1
elif [[ -n "${1:-}" ]]; then
    echo "Eldgrim: use addon/install-local.sh or addon/install-local.sh --force." >&2
    exit 2
fi

if [[ ! -f "$src/Eldgrim.toc" || ! -f "$src/Eldgrim.lua" ]]; then
    echo "Eldgrim: the project addon is missing." >&2
    exit 1
fi

if [[ -d "$dest" && "$force" -ne 1 ]]; then
    # Compare every file. The ember file is edited on the master's machine and
    # the verified file is written by the daily run, so both are left out here
    # and handled below.
    differs=0
    ahead=()
    for file in "$src"/*; do
        [[ -f "$file" ]] || continue
        name=$(basename "$file")
        [[ "$name" == "EldgrimEmbers.lua" || "$name" == "EldgrimVerified.lua" ]] && continue
        if ! cmp -s "$file" "$dest/$name"; then
            differs=1
            if [[ -f "$dest/$name" && "$dest/$name" -nt "$file" ]]; then
                ahead+=("$name")
            fi
        fi
    done
    if [[ ! -f "$dest/EldgrimVerified.lua" ]]; then
        differs=1
    fi
    if [[ "$differs" -eq 0 ]]; then
        echo "Eldgrim: the installed addon already matches the project copy."
        exit 0
    fi
    if [[ "${#ahead[@]}" -gt 0 ]]; then
        echo "Eldgrim: the installed addon is ahead of the project copy in: ${ahead[*]}. Left it in place." >&2
        echo "Eldgrim: pass --force to replace it with the project copy." >&2
        exit 1
    fi
fi

mkdir -p "$dest"
shopt -s nullglob
for file in "$src"/*; do
    if [[ ! -f "$file" ]]; then
        continue
    fi
    name=$(basename "$file")
    # The weekly ember is edited on the master's machine. A newer installed
    # copy keeps its revision instead of being replaced by the shipped blank.
    if [[ "$name" == "EldgrimEmbers.lua" && -f "$dest/$name" && "$dest/$name" -nt "$file" ]]; then
        echo "Eldgrim: left the installed ember file in place."
        continue
    fi
    # The daily run writes the verified embers here. The project copy is
    # always empty, so an installed copy is never replaced, even with --force.
    if [[ "$name" == "EldgrimVerified.lua" && -f "$dest/$name" ]]; then
        echo "Eldgrim: left the installed verified-ember file in place."
        continue
    fi
    cp -p "$file" "$dest/"
done
echo "Eldgrim: copied the project addon into the Forever AddOns folder."
