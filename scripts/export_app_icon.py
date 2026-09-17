#!/usr/bin/env python3
"""Flatten a square RGB (no alpha) App Store icon and a matching launch mark.

Usage:
  python3 scripts/export_app_icon.py /path/to/source.png
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BEIGE = (243, 239, 232)


def ensure_pillow() -> None:
    try:
        from PIL import Image  # noqa: F401
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow", "--user"])


def flatten(src: Path, size: int):
    from PIL import Image

    im = Image.open(src).convert("RGBA")
    im = im.resize((size, size), Image.Resampling.LANCZOS)
    bg = Image.new("RGB", (size, size), BEIGE)
    bg.paste(im, mask=im.split()[-1])
    return bg


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("usage: export_app_icon.py /path/to/source.png")
    src = Path(sys.argv[1]).expanduser()
    if not src.exists():
        raise SystemExit(f"missing source icon: {src}")

    ensure_pillow()
    marketing = ROOT / "Marketing"
    marketing.mkdir(parents=True, exist_ok=True)
    icon_1024 = flatten(src, 1024)
    dests = [
        marketing / "AppIcon-1024.png",
        ROOT / "Headshot/Assets.xcassets/AppIcon.appiconset/AppIcon.png",
    ]
    for dest in dests:
        dest.parent.mkdir(parents=True, exist_ok=True)
        icon_1024.save(dest, "PNG")
        print(f"wrote {dest} {icon_1024.size} mode={icon_1024.mode}")

    mark = flatten(src, 384)
    mark_path = ROOT / "Headshot/Assets.xcassets/LaunchMark.imageset/LaunchMark.png"
    mark.save(mark_path, "PNG")
    print(f"wrote {mark_path} {mark.size} mode={mark.mode}")


if __name__ == "__main__":
    main()
