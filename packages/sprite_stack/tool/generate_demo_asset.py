#!/usr/bin/env python3
"""Generates the demo slice strip used by the example app.

The output is a horizontal strip: slice 0 (the ground cross-section) on the
left, one slice per column block, all 32x32. Run from the package root:

    python3 tool/generate_demo_asset.py
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

SIZE = 32
SLICES = 24
OUT = Path("example/assets/robot_stack.png")

BODY = (63, 111, 209)
BODY_DARK = (43, 78, 155)
BODY_LIGHT = (111, 160, 255)
HEAD = (198, 204, 216)
HEAD_DARK = (140, 147, 163)
VISOR = (41, 227, 227)
EYE = (240, 255, 255)
OUTLINE = (16, 24, 40)
FEET = (40, 50, 70)
LIGHT = (255, 210, 74)


def chunk(tag: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + tag
        + data
        + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png(path: Path, width: int, height: int, rows: list[bytearray]) -> None:
    raw = b"".join(b"\x00" + bytes(row) for row in rows)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def half_extent(z: int) -> int:
    if z <= 1:
        return 13  # feet plate
    if z <= 13:
        return 11  # torso
    if z <= 15:
        return 7  # neck
    return 9  # head


def in_rounded_square(dx: int, dy: int, half: int, radius: int = 3) -> bool:
    if abs(dx) > half or abs(dy) > half:
        return False
    cx = abs(dx) - (half - radius)
    cy = abs(dy) - (half - radius)
    if cx > 0 and cy > 0 and cx * cx + cy * cy > radius * radius:
        return False
    return True


def paint_slice(z: int) -> bytearray:
    rows = [bytearray(SIZE * 4) for _ in range(SIZE)]
    half = half_extent(z)
    is_head = z >= 16
    is_neck = 14 <= z <= 15

    for y in range(SIZE):
        for x in range(SIZE):
            dx = x - SIZE // 2 + 0.5
            dy = y - SIZE // 2 + 0.5
            if not in_rounded_square(int(dx), int(dy), half):
                continue

            if is_head:
                base = HEAD
                if (int(dx) + int(dy)) % 6 == 0:
                    base = HEAD_DARK
            elif is_neck:
                base = HEAD_DARK
            elif z <= 1:
                base = FEET
            else:
                checker = (int(dx) // 4 + int(dy) // 4) % 2 == 0
                base = BODY_LIGHT if checker else BODY

            color = base

            # Dark rim so the silhouette reads at small sizes.
            rim = (
                abs(dx) > half - 1
                or abs(dy) > half - 1
                or (
                    abs(dx) > half - 4
                    and abs(dy) > half - 4
                    and int(dx) ** 2 + int(dy) ** 2 > (half - 1) ** 2
                )
            )
            if rim:
                color = OUTLINE if is_head else BODY_DARK

            # Visor + eyes on the front face of the head.
            if is_head and z >= 18 and 21 <= y <= 27 and 7 <= x <= 24:
                color = VISOR
                if 23 <= y <= 25 and (9 <= x <= 11 or 20 <= x <= 22):
                    color = EYE

            # Chest light on the front of the torso.
            if 4 <= z <= 10 and 23 <= y <= 26 and 14 <= x <= 17:
                color = LIGHT

            # Antenna cap on the very top slice.
            if z == SLICES - 1 and (dx * dx + dy * dy) < 12:
                color = HEAD_DARK

            offset = x * 4
            rows[y][offset : offset + 4] = bytes((*color, 255))

    return rows


def main() -> None:
    strip = [bytearray() for _ in range(SIZE)]
    for z in range(SLICES):
        rows = paint_slice(z)
        for y in range(SIZE):
            strip[y].extend(rows[y])

    write_png(OUT, SIZE * SLICES, SIZE, strip)
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes, {SLICES} slices)")


if __name__ == "__main__":
    main()
