#!/usr/bin/env python3
"""Build addon/downloads/Eldgrim.zip, the install zip members download.

The zip holds one folder, Eldgrim/, with exactly what the game loads: the toc,
every file the toc lists, and the textures. Nothing else from the project goes
in: no tests, tools, documents or saved data. The test quest file is shipped
empty, so a member's copy never carries the founder's test quest.

The zip is reproducible: the same source gives the same bytes, so it changes in
git only when the addon changes.

    python3 addon/build-zip.py           write the zip
    python3 addon/build-zip.py --check   exit 1 if the zip is missing or stale
"""

from __future__ import annotations

import io
import sys
import zipfile
from pathlib import Path

ADDON = Path(__file__).resolve().parent
SOURCE = ADDON / "Eldgrim"
TARGET = ADDON / "downloads" / "Eldgrim.zip"
FOLDER = "Eldgrim"
STAMP = (2026, 1, 1, 0, 0, 0)

# Shipped in place of the founder's test quest.
EMPTY_TEST_QUEST = b"""-- A test quest for the hearth board. Empty in the download: it is used only
-- on the founder's client while developing the addon.

EldgrimTestQuestFile = {
    quest = nil,
}
"""


def toc_files(toc: Path) -> list[str]:
    names = []
    for line in toc.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            names.append(line.replace("\\", "/"))
    return names


def contents() -> list[tuple[str, bytes]]:
    toc = SOURCE / "Eldgrim.toc"
    names = ["Eldgrim.toc", *toc_files(toc)]
    names += sorted(path.name for path in SOURCE.glob("*.tga"))
    files = []
    for name in names:
        path = SOURCE / name
        if not path.is_file():
            raise SystemExit(f"Eldgrim: {name} is listed but missing.")
        data = EMPTY_TEST_QUEST if name == "EldgrimTestQuest.lua" else path.read_bytes()
        files.append((name, data))
    return files


def build() -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        folder = zipfile.ZipInfo(FOLDER + "/", STAMP)
        folder.external_attr = (0o40755 << 16) | 0x10
        archive.writestr(folder, b"")
        for name, data in contents():
            info = zipfile.ZipInfo(f"{FOLDER}/{name}", STAMP)
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, data, compresslevel=9)
    return buffer.getvalue()


def main() -> int:
    data = build()
    current = TARGET.read_bytes() if TARGET.is_file() else None
    if "--check" in sys.argv[1:]:
        if current != data:
            print("Eldgrim: addon/downloads/Eldgrim.zip is out of date. Run python3 addon/build-zip.py.", file=sys.stderr)
            return 1
        print("Eldgrim: the download zip matches the addon.")
        return 0
    if current == data:
        print("Eldgrim: the download zip is already current.")
        return 0
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_bytes(data)
    print(f"Eldgrim: wrote {TARGET.relative_to(ADDON.parent)} ({len(data)} bytes).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
