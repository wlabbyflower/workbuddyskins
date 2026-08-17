#!/usr/bin/env python3
"""Normalize one image and store it as the static WorkBuddy skin background."""

import argparse
import base64
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
OUTPUT_B64 = SKILL_DIR / "assets" / "static" / "bg.b64.txt"


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, check=True, text=True, capture_output=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert an image to an optimized JPEG background for the static WorkBuddy skin."
    )
    parser.add_argument("image", help="Source image path (JPEG, PNG, WebP, HEIC, TIFF, etc.)")
    parser.add_argument("--max-size", type=int, default=2560, help="Maximum width or height (default: 2560)")
    parser.add_argument("--quality", type=int, default=90, help="JPEG quality from 1 to 100 (default: 90)")
    parser.add_argument("--output", help="Optional bg.b64.txt output path (defaults to the static skill asset)")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Path(args.image).expanduser().resolve()
    if not source.is_file():
        raise SystemExit(f"Image does not exist: {source}")
    if not 1 <= args.quality <= 100:
        raise SystemExit("--quality must be between 1 and 100")
    if args.max_size < 512:
        raise SystemExit("--max-size must be at least 512")

    sips = shutil.which("sips")
    if not sips:
        raise SystemExit("macOS sips is required to normalize the background image")

    with tempfile.TemporaryDirectory(prefix="workbuddy-skin-image-") as temp_dir:
        normalized = Path(temp_dir) / "background.jpg"
        run([
            sips,
            "-Z",
            str(args.max_size),
            "-s",
            "format",
            "jpeg",
            "-s",
            "formatOptions",
            str(args.quality),
            str(source),
            "--out",
            str(normalized),
        ])
        raw = normalized.read_bytes()
        if not raw.startswith(b"\xff\xd8\xff"):
            raise SystemExit("Normalized output is not a valid JPEG")
        info = run([sips, "-g", "pixelWidth", "-g", "pixelHeight", str(normalized)]).stdout

    encoded = base64.b64encode(raw).decode("ascii")
    output_b64 = Path(args.output).expanduser().resolve() if args.output else OUTPUT_B64
    output_b64.parent.mkdir(parents=True, exist_ok=True)
    output_b64.write_text(encoded, encoding="ascii")

    dimensions = []
    for line in info.splitlines():
        if "pixelWidth:" in line or "pixelHeight:" in line:
            dimensions.append(line.strip())
    print(f"Background source: {source}")
    print(f"Normalized JPEG: {len(raw):,} bytes")
    if dimensions:
        print("; ".join(dimensions))
    print(f"Updated: {output_b64}")


if __name__ == "__main__":
    main()
