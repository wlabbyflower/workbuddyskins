#!/usr/bin/env python3
"""Patch WorkBuddy's custom ASAR without extracting native unpacked files."""

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Inject a WorkBuddy skin into a custom ASAR archive")
    parser.add_argument("--input", required=True, help="Clean or current app.asar input")
    parser.add_argument("--skin", required=True, help="Built skin.css")
    parser.add_argument("--output", required=True, help="Output app.asar")
    return parser.parse_args()


def walk(node: dict[str, Any], prefix: str = "") -> list[tuple[str, dict[str, Any]]]:
    leaves: list[tuple[str, dict[str, Any]]] = []
    for name, child in node.get("files", {}).items():
        path = f"{prefix}/{name}" if prefix else name
        if "files" in child:
            leaves.extend(walk(child, path))
        else:
            leaves.append((path, child))
    return leaves


def resolve_data_start(buffer: bytes, json_len: int, leaves: list[tuple[str, dict[str, Any]]]) -> int:
    candidates = [
        entry for entry in leaves
        if re.fullmatch(r"renderer/assets/index-.*\.css", entry[0]) and not entry[1].get("unpacked")
    ]
    if len(candidates) != 1:
        raise SystemExit(f"Expected exactly one renderer index CSS, found {len(candidates)}")
    _, node = candidates[0]
    offset = int(node["offset"])
    size = int(node["size"])
    expected_hash = node["integrity"]["hash"]
    for delta in range(-8, 9):
        start = 16 + json_len + delta
        content = buffer[start + offset:start + offset + size]
        if hashlib.sha256(content).hexdigest() == expected_hash:
            return start
    raise SystemExit("Unable to resolve the custom ASAR data start")


def strip_skin(content: bytes) -> bytes:
    start = content.find(b"/* WORKBUDDY_SKIN")
    if start < 0:
        return content
    end_marker = b"/* END SKIN */"
    end = content.rfind(end_marker)
    if end <= start:
        raise SystemExit("Found an incomplete WORKBUDDY_SKIN block")
    return content[:start].rstrip() + b"\n" + content[end + len(end_marker):].lstrip()


def patch_source_css(text: str) -> str:
    replacements = [
        (r"(\.\_popover\_zugj5\_8 \{[^}]+)border: 0\.5px solid var\(--cb-popover-border, #e5e5e5\);", r"\1border: 1px solid rgba(255,255,255,0.30);"),
        (r"(\.\_popover\_zugj5\_8 \{[^}]+)box-shadow: var\(--cb-shadow-popover\);", r"\1box-shadow: 0 8px 24px rgba(0,0,0,0.08);"),
        (r"(\.\_popover\_zugj5\_8 \{[^}]+)background: var\(--cb-dropdown-bg-color\);", r"\1background: rgba(255,255,255,0.18); backdrop-filter: blur(12px) saturate(1.15); -webkit-backdrop-filter: blur(12px) saturate(1.15);"),
        (r"(\.\_groupLabel\_zugj5\_80 \{[^}]+)background: var\(--cb-dropdown-bg-color, #ffffff\);", r"\1background: transparent;"),
        (r"(\.\_autoModeSection\_zugj5\_200 \{[^}]+)background: var\(--cb-dropdown-bg-color, #ffffff\);", r"\1background: transparent;"),
        (r"(\.\_modelListContainer\_zugj5\_41\.\_modelListAfterDivider\_zugj5\_53 \{)\n  border-top: 2px solid var\(--cb-dropdown-bg-color, #ffffff\);", r"\1\n  border-top: 1px solid rgba(0,0,0,0.08);"),
        (r"(\.\_modelItem\_162g9\_1 \.\_modelName\_162g9\_12 \{)\n  color: var\(--cb-text-primary\);", r"\1\n  color: rgba(0,0,0,0.85);"),
        (r"(\.\_modelCredits\_162g9\_126 \{[^}]+)color: var\(--cb-text-secondary, #858699\);", r"\1color: rgba(0,0,0,0.60);"),
        (r"(\.\_groupLabelText\_zugj5\_93 \{[^}]+)color: var\(--cb-text-secondary, #858699\);", r"\1color: rgba(0,0,0,0.60);"),
        (r"(\.\_subMenu\_1slp5\_6 \{[^}]+)background: var\(--cb-dropdown-bg-color\);", r"\1background: rgba(255,255,255,0.18); backdrop-filter: blur(12px) saturate(1.15); -webkit-backdrop-filter: blur(12px) saturate(1.15);"),
        (r"(\.\_subMenuPanel\_1slp5\_6 \{[^}]+)background: var\(--cb-dropdown-bg-color\);", r"\1background: rgba(255,255,255,0.18); backdrop-filter: blur(12px) saturate(1.15); -webkit-backdrop-filter: blur(12px) saturate(1.15);"),
        (r"(\.\_modelName\_1slp5\_36 \{[^}]+)color: var\(--cb-text-primary, #d2d3e0\);", r"\1color: rgba(0,0,0,0.85);"),
        (r"(\.\_description\_1slp5\_64 \{[^}]+)color: var\(--cb-text-secondary, #858699\);", r"\1color: rgba(0,0,0,0.60);"),
        (r"(\.\_metaLabel\_1slp5\_99 \{[^}]+)color: var\(--cb-text-primary, #d2d3e0\);", r"\1color: rgba(0,0,0,0.85);"),
        (r"(\.\_metaValue\_1slp5\_104 \{[^}]+)color: var\(--cb-text-secondary, #858699\);", r"\1color: rgba(0,0,0,0.60);"),
        (r"(\.\_actionLabel\_1slp5\_130 \{[^}]+)color: var\(--cb-text-primary, #d2d3e0\);", r"\1color: rgba(0,0,0,0.85);"),
        (r"(\.\_actionValue\_1slp5\_135 \{[^}]+)color: var\(--cb-text-secondary, #858699\);", r"\1color: rgba(0,0,0,0.60);"),
    ]
    for pattern, replacement in replacements:
        text = re.sub(pattern, replacement, text)
    return text


def verify(buffer: bytes) -> None:
    json_len = int.from_bytes(buffer[12:16], "little")
    header = json.loads(buffer[16:16 + json_len].decode("utf-8"))
    leaves = walk(header)
    data_start = resolve_data_start(buffer, json_len, leaves)
    for path, node in leaves:
        if node.get("unpacked") or node.get("offset") is None:
            continue
        offset = int(node["offset"])
        size = int(node["size"])
        content = buffer[data_start + offset:data_start + offset + size]
        actual = hashlib.sha256(content).hexdigest()
        if actual != node["integrity"]["hash"]:
            raise SystemExit(f"Integrity verification failed: {path}")


def main() -> None:
    args = parse_args()
    input_path = Path(args.input).expanduser().resolve()
    skin_path = Path(args.skin).expanduser().resolve()
    output_path = Path(args.output).expanduser().resolve()
    if not input_path.is_file() or not skin_path.is_file():
        raise SystemExit("Input ASAR and skin CSS must exist")

    buffer = input_path.read_bytes()
    json_len = int.from_bytes(buffer[12:16], "little")
    header = json.loads(buffer[16:16 + json_len].decode("utf-8"))
    leaves = walk(header)
    data_start = resolve_data_start(buffer, json_len, leaves)

    index_entries = [entry for entry in leaves if re.fullmatch(r"renderer/assets/index-.*\.css", entry[0]) and not entry[1].get("unpacked")]
    source_entries = [entry for entry in leaves if re.fullmatch(r"renderer/assets/src-.*\.css", entry[0]) and not entry[1].get("unpacked")]
    if len(index_entries) != 1:
        raise SystemExit("Unable to identify renderer index CSS")

    modifications: dict[str, bytes] = {}
    index_path, index_node = index_entries[0]
    index_offset = int(index_node["offset"])
    index_size = int(index_node["size"])
    index_content = buffer[data_start + index_offset:data_start + index_offset + index_size]
    skin = skin_path.read_bytes()
    modifications[index_path] = strip_skin(index_content).rstrip() + b"\n" + skin.rstrip() + b"\n"

    for source_path, source_node in source_entries:
        source_offset = int(source_node["offset"])
        source_size = int(source_node["size"])
        source_content = buffer[data_start + source_offset:data_start + source_offset + source_size]
        source_text = source_content.decode("utf-8", errors="replace")
        if any(token in source_text for token in ("_popover_zugj5_8", "_subMenu_1slp5_6")):
            modifications[source_path] = patch_source_css(source_text).encode("utf-8")

    ordered_modifications = sorted(
        [(path, next(node for leaf_path, node in leaves if leaf_path == path), content) for path, content in modifications.items()],
        key=lambda item: int(item[1]["offset"]),
    )
    data_region = buffer[data_start:]
    rebuilt_parts: list[bytes] = []
    cursor = 0
    cumulative_delta = 0
    deltas: list[tuple[int, int]] = []

    for path, node, content in ordered_modifications:
        old_offset = int(node["offset"])
        old_size = int(node["size"])
        rebuilt_parts.append(data_region[cursor:old_offset])
        rebuilt_parts.append(content)
        cursor = old_offset + old_size
        delta = len(content) - old_size
        cumulative_delta += delta
        deltas.append((old_offset, delta))
        digest = hashlib.sha256(content).hexdigest()
        node["size"] = len(content)
        node["integrity"]["hash"] = digest
        node["integrity"]["blocks"] = [digest]

    rebuilt_parts.append(data_region[cursor:])
    rebuilt_data = b"".join(rebuilt_parts)

    for path, node in leaves:
        if node.get("unpacked") or node.get("offset") is None:
            continue
        old_offset = int(node["offset"])
        shift = sum(delta for modified_offset, delta in deltas if old_offset > modified_offset)
        if shift:
            node["offset"] = str(old_offset + shift)

    header_bytes = json.dumps(header, separators=(",", ":")).encode("utf-8")
    if len(header_bytes) != json_len:
        raise SystemExit(f"ASAR header length changed: {json_len} -> {len(header_bytes)}")

    prefix = buffer[:16]
    padding = buffer[16 + json_len:data_start]
    output = prefix + header_bytes + padding + rebuilt_data
    verify(output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(output)
    print(f"Patched files: {', '.join(sorted(modifications))}")
    print(f"Output: {output_path} ({len(output):,} bytes)")
    print(f"SHA256: {hashlib.sha256(output).hexdigest()}")
    print("Integrity: OK")


if __name__ == "__main__":
    main()
