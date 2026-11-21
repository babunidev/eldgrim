#!/usr/bin/env python3
"""Draw the hearth board's textures as TGA files.

Run from the repository root:

    python3 addon/tools/hearth_art.py

Each texture is drawn four times larger than its file and scaled down, so
edges are smooth. The geometry here must match EldgrimSkin.lua: the corner
size, the cut, and the offset and width of every frame line. Change both
together.
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Eldgrim")
SS = 4  # supersampling factor

# Palette. EldgrimSkin.lua repeats these values.
COAL = (0.075, 0.060, 0.052)
PANEL = (0.110, 0.085, 0.070)
ORANGE = (0.90, 0.42, 0.10)
GOLD = (1.00, 0.76, 0.32)
RED = (0.72, 0.17, 0.07)
AMBER = (0.86, 0.55, 0.20)
DEEP = (0.36, 0.07, 0.03)
PALE = (1.00, 0.95, 0.72)

# The large frame. Offsets are measured inward from the outer edge, in UI units.
MAJOR = {
    "size": 64,  # corner piece, units
    "tex": 256,  # corner file, pixels
    "cut": 20,  # leg of the cut corner
    "lines": [  # offset, width, colour, broken
        (0, 4, ORANGE, False),
        (6, 2, GOLD, True),
        (10, 1, RED, False),
        (16, 2, AMBER, False),
    ],
    "notch": 3.0,  # gap between the corner triangle and the thick line
}

# The smaller frame around each column.
MINOR = {
    "size": 32,
    "tex": 128,
    "cut": 10,
    "lines": [
        (0, 2, ORANGE, False),
        (4, 1, RED, False),
    ],
    "notch": 2.0,
}


class Canvas:
    """A float RGBA canvas drawn in unit space."""

    def __init__(self, width_px, height_px, px_per_unit):
        self.w = width_px * SS
        self.h = height_px * SS
        self.k = px_per_unit * SS
        self.rgb = np.zeros((self.h, self.w, 3), np.float64)
        self.a = np.zeros((self.h, self.w), np.float64)
        ys, xs = np.mgrid[0 : self.h, 0 : self.w]
        self.x = (xs + 0.5) / self.k
        self.y = (ys + 0.5) / self.k

    def over(self, mask, colour, alpha=1.0):
        """Paint colour over the canvas where mask (0..1 or bool) is set."""
        m = np.asarray(mask, np.float64) * alpha
        col = np.asarray(colour, np.float64)
        if col.ndim == 1:
            col = np.broadcast_to(col, self.rgb.shape)
        self.rgb = self.rgb * (1 - m[..., None]) + col * m[..., None]
        self.a = self.a * (1 - m) + m

    def add(self, mask, colour, alpha=1.0):
        """Additive glow, clipped to existing alpha plus the glow itself."""
        m = np.asarray(mask, np.float64) * alpha
        self.rgb = np.clip(self.rgb + np.asarray(colour) * m[..., None], 0, 1)
        self.a = np.clip(self.a + m, 0, 1)

    def polygon(self, points):
        """Boolean mask of a polygon given in unit space."""
        img = Image.new("L", (self.w, self.h), 0)
        ImageDraw.Draw(img).polygon([(x * self.k, y * self.k) for x, y in points], fill=255)
        return np.asarray(img) > 127

    def stroke(self, points, width):
        """Mask of a polyline stroked with round joins and ends."""
        img = Image.new("L", (self.w, self.h), 0)
        draw = ImageDraw.Draw(img)
        pts = [(x * self.k, y * self.k) for x, y in points]
        r = width * self.k / 2
        draw.line(pts, fill=255, width=max(1, int(round(width * self.k))), joint="curve")
        for x, y in (pts[0], pts[-1]):
            draw.ellipse((x - r, y - r, x + r, y + r), fill=255)
        return np.asarray(img) > 127

    def image(self):
        a = self.a
        # Colours are kept straight, not premultiplied: over() mixes them that
        # way. Fully clear pixels carry no colour.
        rgb = np.where(a[..., None] > 0, self.rgb, 0)
        data = np.dstack([rgb, a])
        img = Image.fromarray((np.clip(data, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA")
        return img.resize((self.w // SS, self.h // SS), Image.LANCZOS)


def save(img, name):
    path = os.path.join(OUT, name)
    # Uncompressed, top-left origin, 8 bits of alpha.
    img.save(path, compression=None, orientation=1)
    print("wrote", os.path.relpath(path))


def lerp(a, b, t):
    t = np.asarray(t)[..., None] if np.ndim(t) else t
    return np.asarray(a) * (1 - t) + np.asarray(b) * t


# ---------------------------------------------------------------- flames


def flame_outline(base, angle, length, width, sway=0.0, bulge=0.38, taper=1.6, steps=120):
    """One tongue of flame: a round belly low down and a long, bending tip.

    angle is the direction the tip points. sway bends the tip sideways.
    """
    bx, by = base
    ux, uy = math.cos(angle), math.sin(angle)
    vx, vy = -uy, ux
    left, right = [], []
    for i in range(steps + 1):
        s = i / steps
        if s < bulge:
            hw = math.sqrt(max(0.0, 1 - ((bulge - s) / bulge) ** 2))
            c = 0.0
        else:
            q = (s - bulge) / (1 - bulge)
            hw = (1 - q) ** taper
            c = sway * math.sin(math.pi * q) * q
        hw *= width / 2
        u = s * length
        for side, out in ((-1, left), (1, right)):
            v = c + side * hw
            out.append((bx + ux * u + vx * v, by + uy * u + vy * v))
    return left + right[::-1]


FIRE = [DEEP, RED, ORANGE, GOLD, PALE]


def flame(cv, tongues, palette=None, glow=0.45, blur=3.0):
    """Several tongues drawn as one fire, in nested colour layers.

    Each tongue is (base, angle, length, width, sway).
    """
    palette = palette or FIRE
    if glow:
        m = np.zeros(cv.a.shape)
        for b, ang, length, width, sway in tongues:
            m = np.maximum(m, cv.polygon(flame_outline(b, ang, length * 1.05, width * 1.45, sway)))
        img = Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(cv.k * blur))
        cv.add(np.asarray(img) / 255.0, ORANGE, glow)
    for i, colour in enumerate(palette):
        f = 1 - i * 0.19
        mask = np.zeros(cv.a.shape, bool)
        for b, ang, length, width, sway in tongues:
            ux, uy = math.cos(ang), math.sin(ang)
            lift = (1 - f) * width * 0.55
            bb = (b[0] + ux * lift, b[1] + uy * lift)
            mask |= cv.polygon(flame_outline(bb, ang, length * f**0.7 - lift * 0.3, width * f, sway * f))
        cv.over(mask, colour)


def turned(base, angle, parts):
    """Lay out a flame drawn pointing up so that it points along angle.

    parts are tongues relative to an upward flame at the origin:
    (dx, dy, tilt, length, width, sway), with dy negative going up.
    """
    rot = angle + math.pi / 2
    cs, sn = math.cos(rot), math.sin(rot)
    out = []
    for dx, dy, tilt, length, width, sway in parts:
        x = base[0] + dx * cs - dy * sn
        y = base[1] + dx * sn + dy * cs
        out.append(((x, y), angle + tilt, length, width, sway))
    return out


def spiral(cx, cy, r0, r1, a0, turns, steps=80, direction=1):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        r = r0 + (r1 - r0) * t
        a = a0 + direction * turns * 2 * math.pi * t
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def bezier(p0, p1, p2, p3, steps=60):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt * mt * t * p1[0] + 3 * mt * t * t * p2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt * mt * t * p1[1] + 3 * mt * t * t * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    return pts


# ---------------------------------------------------------------- corners


def octagon(left, top, right, bottom, cut):
    """Inset distance inside a box with cut corners, from the distances to
    each of its four sides."""
    r2 = math.sqrt(2)
    return np.minimum.reduce([
        left, top, right, bottom,
        (left + top - cut) / r2, (right + top - cut) / r2,
        (left + bottom - cut) / r2, (right + bottom - cut) / r2,
    ])


class Mirror:
    """Draw one corner of a frame in top-left terms, placed in any corner.

    x and y are local unit coordinates, measured inward from the corner.
    """

    def __init__(self, cv, size, ox, oy, fx, fy):
        self.cv, self.size, self.ox, self.oy, self.fx, self.fy = cv, size, ox, oy, fx, fy
        x = cv.x - ox
        y = cv.y - oy
        self.inside = (x >= 0) & (x < size) & (y >= 0) & (y < size)
        self.x = size - x if fx else x
        self.y = size - y if fy else y

    def P(self, x, y):
        """Local point to canvas units."""
        return (self.ox + (self.size - x if self.fx else x), self.oy + (self.size - y if self.fy else y))

    def over(self, mask, colour, alpha=1.0):
        self.cv.over(np.asarray(mask) & self.inside, colour, alpha)

    def polygon(self, points):
        return self.cv.polygon([self.P(x, y) for x, y in points])

    def stroke(self, points, width):
        return self.cv.stroke([self.P(x, y) for x, y in points], width)


def frame_lines(m, spec, fill, breaks):
    d = np.minimum(np.minimum(m.x, m.y), (m.x + m.y - spec["cut"]) / math.sqrt(2))
    m.over(d >= 0, fill)
    for offset, width, colour, broken in spec["lines"]:
        band = (d >= offset) & (d < offset + width)
        if broken:
            for lo, hi, axis in breaks:
                if axis == "x":
                    pos, near = m.x, m.y <= m.x
                elif axis == "y":
                    pos, near = m.y, m.x < m.y
                else:  # along the cut, measured as x - y
                    pos, near = m.x - m.y, np.abs(m.x - m.y) < spec["cut"] + offset * 2
                band &= ~((pos >= lo) & (pos < hi) & near)
        m.over(band, colour)


def notch_triangle(m, spec):
    """The triangle that sits in the cut-away corner."""
    legs = spec["cut"] - spec["notch"] * math.sqrt(2)
    m.over(m.polygon([(0, 0), (legs, 0), (0, legs)]), ORANGE)
    rim = 1.0 if spec is MAJOR else 0.7
    inner_legs = legs - rim * (2 + math.sqrt(2))
    o = rim
    t = np.clip((m.x + m.y) / max(legs, 1), 0, 1)
    m.over(m.polygon([(o, o), (o + inner_legs, o), (o, o + inner_legs)]), lerp(DEEP, RED, t))
    if spec is MAJOR:
        # A gold shard along the long side.
        m.over(m.polygon([(legs * 0.62, legs * 0.12), (legs * 0.80, legs * 0.12),
                          (legs * 0.12, legs * 0.80), (legs * 0.12, legs * 0.62)]), GOLD, 0.95)


def gap_teeth(m, spec):
    """Small triangles in the gap between the thin line and the inner line."""
    cut = spec["cut"]
    thin_end, inner_start = 11.0, 16.0
    r2 = math.sqrt(2)

    def at(dist, along):
        s = (cut + dist * r2) / 2
        return (s + along / r2, s - along / r2)

    for along in (-6.5, 0.0, 6.5):
        size = 1.0 if along == 0 else 0.8
        half = 2.4 * size
        tri = [at(inner_start - 0.3, along - half), at(inner_start - 0.3, along + half),
               at(thin_end + 0.8 + (1 - size) * 2.2, along)]
        m.over(m.polygon(tri), GOLD if along == 0 else ORANGE)
    for tri in ([(30, thin_end + 1.0), (30, inner_start - 1.0), (34.5, 13.5)],
                [(thin_end + 1.0, 30), (inner_start - 1.0, 30), (13.5, 34.5)]):
        m.over(m.polygon(tri), RED)


def plaque(m, spec):
    """A small octagon on the corner's axis holding an upright flame, with
    scrolls running along both edges."""
    cv = m.cv
    c, half, cut = 31.0, 9.0, 5.0
    for flip in (False, True):
        def Q(x, y):
            return (y, x) if flip else (x, y)

        stem = bezier(Q(c + half - 0.5, c - 2.0), Q(c + half + 6, c - 3.0), Q(46, 21.2), Q(52.5, 23.4))
        m.over(m.stroke(stem, 1.25), GOLD)
        cx, cy = Q(53.2, 27.2)
        start = math.atan2(stem[-1][1] - cy, stem[-1][0] - cx)
        curl = spiral(cx, cy, math.hypot(stem[-1][0] - cx, stem[-1][1] - cy), 0.7, start, 0.9,
                      direction=-1 if flip else 1)
        m.over(m.stroke(curl, 1.1), GOLD)
        for idx, r in ((12, 0.95), (44, 0.8)):
            bx, by = stem[idx]
            m.over((m.x - bx) ** 2 + (m.y - by) ** 2 <= r * r, ORANGE)
        # A small upright flame rooted on the scroll.
        root = m.P(*stem[30])
        flame(cv, turned(root, -math.pi / 2, [(0, 0, 0, 8.5, 4.4, -1.0 if flip else 1.0)]),
              [RED, ORANGE, GOLD], glow=0.3, blur=1.0)
    # The plaque itself.
    d = octagon(m.x - (c - half), m.y - (c - half), (c + half) - m.x, (c + half) - m.y, cut)
    m.over(d >= 0, COAL)
    cx, cy = m.P(c, c)
    glow = np.clip(1 - np.hypot(cv.x - cx, cv.y - (cy + 4)) / 9, 0, 1) ** 2
    m.over(d >= 0, (0.55, 0.16, 0.04), glow * 0.9)
    m.over((d >= 0) & (d < 1.4), ORANGE)
    m.over((d >= 2.2) & (d < 2.9), GOLD, 0.85)
    flame(cv, turned((cx, cy + 6.2), -math.pi / 2, [
        (0, 0, 0.0, 13.5, 7.2, -1.3),
        (-2.0, -1.0, -0.5, 7.0, 3.2, -0.9),
        (2.0, -1.4, 0.45, 8.0, 3.2, 1.0),
    ]), glow=0.35, blur=1.2)


# Breaks in the gold line differ in each corner, so the pattern does not repeat.
CORNER_BREAKS = [
    [(33, 35.5, "x"), (51, 53.5, "x"), (44.5, 47.5, "y"), (-6.5, -4, "d"), (3, 4.5, "d")],
    [(39, 42, "x"), (28.5, 30, "y"), (49, 52.5, "y"), (1.5, 4.5, "d")],
    [(45, 47, "x"), (55, 58.5, "x"), (36, 38, "y"), (-3.5, -1, "d"), (6, 7.5, "d")],
    [(30, 33, "x"), (42, 43.5, "y"), (56, 58.5, "y"), (-7, -5.5, "d")],
]


def major_corner():
    """One file, four corners: top-left, top-right, bottom-left, bottom-right."""
    spec = MAJOR
    size, tex = spec["size"], spec["tex"]
    cv = Canvas(tex * 2, tex * 2, tex / size)
    for index, (fx, fy) in enumerate(((0, 0), (1, 0), (0, 1), (1, 1))):
        m = Mirror(cv, size, fx * size, fy * size, fx, fy)
        frame_lines(m, spec, COAL, CORNER_BREAKS[index])
        notch_triangle(m, spec)
        gap_teeth(m, spec)
        plaque(m, spec)
    save(cv.image(), "EldgrimCorner.tga")


def minor_corner():
    """The small frame's top-left corner. It has no flame, so it is mirrored
    into the other corners in game."""
    spec = MINOR
    size, tex = spec["size"], spec["tex"]
    cv = Canvas(tex, tex, tex / size)
    m = Mirror(cv, size, 0, 0, 0, 0)
    frame_lines(m, spec, PANEL, [])
    notch_triangle(m, spec)
    s = (spec["cut"] + 7.2 * math.sqrt(2)) / 2
    m.over(np.abs(m.x - s) + np.abs(m.y - s) <= 1.9, GOLD)
    m.over(np.abs(m.x - s) + np.abs(m.y - s) <= 0.8, PALE)
    save(cv.image(), "EldgrimCornerSmall.tga")


# ---------------------------------------------------------------- emblem


def emblem():
    """The flame mark: the guild-panel button and the window's crest."""
    size = 64  # units across
    tex = 256
    cv = Canvas(tex, tex, tex / size)
    c = size / 2
    cut = 17
    # An octagon: the same cut corners and lines as the frame.
    d = np.minimum.reduce(
        [
            cv.x - 2,
            cv.y - 2,
            size - 2 - cv.x,
            size - 2 - cv.y,
            (cv.x + cv.y - 4 - cut) / math.sqrt(2),
            (size - cv.x + cv.y - 4 - cut) / math.sqrt(2),
            (cv.x + size - cv.y - 4 - cut) / math.sqrt(2),
            (2 * size - cv.x - cv.y - 4 - cut) / math.sqrt(2),
        ]
    )
    cv.over(d >= 0, COAL)
    # Warm floor of embers.
    r = np.hypot(cv.x - c, cv.y - (c + 14)) / 30
    cv.add((d >= 0) * np.clip(1 - r, 0, 1) ** 2, (0.55, 0.16, 0.04), 0.9)
    for offset, width, colour in ((0, 3.2, ORANGE), (4.6, 1.4, GOLD), (7.3, 0.9, RED)):
        band = (d >= offset) & (d < offset + width)
        if colour is GOLD:
            # Broken, but not in a mirrored pattern.
            ang = np.degrees(np.arctan2(cv.y - c, cv.x - c)) % 360
            for lo, hi in ((12, 19), (101, 106), (196, 204), (283, 287)):
                band &= ~((ang >= lo) & (ang < hi))
        cv.over(band, colour)
    # Corner triangles in each cut-away corner.
    legs = cut - 3.4
    for fx, fy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        def P(x, y):
            return (size - x if fx else x, size - y if fy else y)

        o = 0.6
        tri = [P(o, o), P(o + legs, o), P(o, o + legs)]
        cv.over(cv.polygon(tri), ORANGE)
        o2 = o + 1.0
        inner = [P(o2, o2), P(o2 + legs - 3.4, o2), P(o2, o2 + legs - 3.4)]
        cv.over(cv.polygon(inner), RED)
    # The flame: a tall leaning tongue with a lick on each side.
    base = (c, size - 13.0)
    flame(cv, turned(base, -math.pi / 2, [
        (0, 0, 0.0, 41, 21, -3.6),
        (-5.5, -3, -0.50, 21, 9, -2.6),
        (5.5, -4, 0.45, 24, 9, 3.0),
    ]), glow=0.5, blur=3.0)
    # Sparks.
    for sx, sy, sr in ((c + 11.5, 15.5, 1.15), (c - 12.8, 19.5, 0.9), (c + 15, 25, 0.7)):
        cv.add(np.clip(1 - np.hypot(cv.x - sx, cv.y - sy) / (sr * 2.4), 0, 1) ** 1.5, ORANGE, 0.8)
        cv.over(np.hypot(cv.x - sx, cv.y - sy) <= sr, GOLD)
    # A line of coal under the flame.
    coal_line = cv.polygon([(c - 12, size - 12.2), (c + 12, size - 12.2), (c + 9.5, size - 10.6), (c - 9.5, size - 10.6)])
    cv.over(coal_line, GOLD)
    save(cv.image(), "EldgrimFlame.tga")


# ---------------------------------------------------------------- widgets


def button_atlas():
    """Rows of a three-slice button: normal, hover, pressed, disabled, then
    the same four without the gems, for small buttons.

    Each row is 128 x 32 pixels. The left and right 16 pixels are caps; the
    middle stretches. The face changes only from top to bottom, so it can
    stretch sideways.
    """
    W, H = 128, 32
    cv = Canvas(W, H * 8, 1.0)
    styles = [
        # border, inner highlight, face top, face bottom, stud
        (ORANGE, (0.98, 0.62, 0.26), (0.34, 0.13, 0.05), (0.17, 0.065, 0.035), GOLD),
        (GOLD, PALE, (0.50, 0.20, 0.07), (0.26, 0.09, 0.04), PALE),
        ((0.75, 0.32, 0.08), (0.30, 0.11, 0.05), (0.12, 0.05, 0.03), (0.24, 0.09, 0.045), ORANGE),
        ((0.34, 0.29, 0.25), (0.28, 0.24, 0.21), (0.17, 0.15, 0.13), (0.12, 0.10, 0.09), (0.36, 0.31, 0.27)),
    ]
    ch = 7.0  # cut
    rows = [(i, style, True) for i, style in enumerate(styles)]
    rows += [(i + 4, style, False) for i, style in enumerate(styles)]
    for row, (border, hi, top, bottom, stud), studded in rows:
        y0 = row * H
        x, y = cv.x, cv.y - y0
        inrow = (y >= 0) & (y < H)
        d = np.minimum.reduce(
            [
                x - 0.5,
                y - 1.0,
                W - 0.5 - x,
                H - 1.0 - y,
                (x + y - 1.5 - ch) / math.sqrt(2),
                (W - x + y - 1.5 - ch) / math.sqrt(2),
                (x + H - y - 1.5 - ch) / math.sqrt(2),
                (W - x + H - y - 1.5 - ch) / math.sqrt(2),
            ]
        )
        d = np.where(inrow, d, -1)
        t = np.clip((y - 1) / (H - 2), 0, 1)
        cv.over(d >= 0, lerp(top, bottom, t))
        cv.over((d >= 0) & (d < 2.0), border)
        cv.over((d >= 3.0) & (d < 4.0) & (y < H * 0.45), hi, 0.55)
        cv.over((d >= 3.0) & (d < 4.0) & (y >= H * 0.45), hi, 0.15)
        # Diamond studs in the caps.
        for sx in (7.5, W - 7.5) if studded else ():
            cv.over((np.abs(x - sx) + np.abs(y - H / 2) <= 3.0) & inrow, stud)
            cv.over((np.abs(x - sx) + np.abs(y - H / 2) <= 1.2) & inrow, border)
    save(cv.image(), "EldgrimButton.tga")


def well_atlas():
    """Two nine-slice text fields, 32 x 32: normal, then focused."""
    cv = Canvas(64, 32, 1.0)
    ch = 4.0
    for cell, (border, glow) in enumerate([((0.46, 0.27, 0.14), 0.0), (ORANGE, 1.0)]):
        x0 = cell * 32
        x, y = cv.x - x0, cv.y
        incell = (x >= 0) & (x < 32)
        d = np.minimum.reduce(
            [
                x - 1,
                y - 1,
                31 - x,
                31 - y,
                (x + y - 2 - ch) / math.sqrt(2),
                (32 - x + y - 2 - ch) / math.sqrt(2),
                (x + 32 - y - 2 - ch) / math.sqrt(2),
                (64 - x - y - 2 - ch) / math.sqrt(2),
            ]
        )
        d = np.where(incell, d, -9)
        if glow:
            cv.add(np.clip(1 + d / 1.6, 0, 1) * (d < 0) * incell, ORANGE, 0.55)
        cv.over(d >= 0, (0.035, 0.028, 0.024))
        # Shadow along the top, so the field reads as sunk.
        cv.over((d >= 0) & (y < 8), (0, 0, 0), np.clip((8 - y) / 8, 0, 1) * 0.55)
        cv.over((d >= 0) & (d < 1.4), border)
        if glow:
            cv.over((d >= 1.4) & (d < 2.4), GOLD, 0.35)
    save(cv.image(), "EldgrimField.tga")


def glyph_atlas():
    """Small pieces in a 4 x 4 grid of 32-pixel cells (see EldgrimSkin.GLYPH)."""
    cv = Canvas(128, 128, 1.0)

    def cell(i):
        cx = (i % 4) * 32
        cy = (i // 4) * 32
        return cv.x - cx, cv.y - cy, (cv.x >= cx) & (cv.x < cx + 32) & (cv.y >= cy) & (cv.y < cy + 32)

    def X(i, colour, back):
        x, y, inc = cell(i)
        oct_ = np.minimum.reduce([x - 3, y - 3, 29 - x, 29 - y, (x + y - 13) / 1.414, (32 - x + y - 13) / 1.414,
                                  (x + 32 - y - 13) / 1.414, (64 - x - y - 13) / 1.414])
        cv.over(inc & (oct_ >= 0), back)
        cv.over(inc & (oct_ >= 0) & (oct_ < 1.8), colour)
        arm = (np.abs((x - 16) - (y - 16)) < 2.4) | (np.abs((x - 16) + (y - 16)) < 2.4)
        cv.over(inc & arm & (np.abs(x - 16) < 6.5) & (np.abs(y - 16) < 6.5), colour)

    X(0, ORANGE, (0.20, 0.07, 0.04))
    X(1, PALE, (0.45, 0.14, 0.05))
    # 2: diamond gem
    x, y, inc = cell(2)
    dd = np.abs(x - 16) + np.abs(y - 16)
    cv.over(inc & (dd <= 9), ORANGE)
    cv.over(inc & (dd <= 6.5), lerp(GOLD, RED, np.clip((y - 9) / 14, 0, 1)))
    cv.over(inc & (dd <= 2.5) & (y < 16), PALE)
    # 3: flame bullet
    flame(cv, turned((96 + 16, 29), -math.pi / 2, [(0, 0, 0, 25, 14, -2.2), (-3, -2, -0.5, 13, 6, -1.5), (3, -2.5, 0.45, 14, 6, 1.8)]), glow=0)
    # 4/5: question mark plaque, normal and hover
    for i, (rim, back, mark) in ((4, (ORANGE, (0.18, 0.07, 0.04), GOLD)), (5, (GOLD, (0.42, 0.15, 0.05), PALE))):
        x, y, inc = cell(i)
        dd = np.abs(x - 16) + np.abs(y - 16)
        cv.over(inc & (dd <= 14), rim)
        cv.over(inc & (dd <= 12), back)
        q = bezier((11.6, 12.2), (11.6, 6.0), (20.8, 6.0), (20.4, 11.6), 40) + bezier(
            (20.4, 11.6), (20.0, 15.4), (16.0, 14.6), (16.0, 19.0), 40
        )
        q = [(px + (i % 4) * 32, py + (i // 4) * 32) for px, py in q]
        cv.over(inc & cv.stroke(q, 2.6), mark)
        dot = ((x - 16) ** 2 + (y - 23.3) ** 2) <= 1.7**2
        cv.over(inc & dot, mark)
    # 6: check
    x, y, inc = cell(6)
    pts = [(8 + 64, 16 + 32), (14 + 64, 22 + 32), (25 + 64, 9 + 32)]
    cv.over(inc & cv.stroke(pts, 3.4), GOLD)
    # 7/8: radio, empty and chosen
    for i, chosen in ((7, False), (8, True)):
        x, y, inc = cell(i)
        dd = np.abs(x - 16) + np.abs(y - 16)
        cv.over(inc & (dd <= 11), ORANGE if chosen else (0.50, 0.30, 0.16))
        cv.over(inc & (dd <= 9.2), (0.04, 0.03, 0.025))
        if chosen:
            cv.over(inc & (dd <= 6), lerp(GOLD, RED, np.clip((y - 10) / 12, 0, 1)))
            cv.over(inc & (dd <= 2) & (y < 16), PALE)
    # 9: soft round glow, white, for tinting
    x, y, inc = cell(9)
    cv.over(inc, (1, 1, 1), np.clip(1 - np.hypot(x - 16, y - 16) / 15.5, 0, 1) ** 1.8)
    # 10: horizontal fade, white to clear
    x, y, inc = cell(10)
    cv.over(inc, (1, 1, 1), np.clip(1 - x / 32, 0, 1) ** 1.3)
    # 11: vertical fade, white at the bottom
    x, y, inc = cell(11)
    cv.over(inc, (1, 1, 1), np.clip(y / 32, 0, 1) ** 1.6)
    # 12: small triangle pointing right
    x, y, inc = cell(12)
    tri = cv.polygon([(10, 104), (24, 112), (10, 120)])
    cv.over(inc & tri, ORANGE)
    # 13: divider end, a short spike of flame pointing left
    flame(cv, [((32 + 30, 96 + 16), math.pi, 27, 8, 0.0)], [RED, ORANGE, GOLD], glow=0)
    # 14: scroll bar thumb (vertical), 15: scroll track
    x, y, inc = cell(14)
    d = np.minimum.reduce([x - 10, 22 - x, y - 1, 31 - y, (x + y - 15) / 1.414, (32 - x + y - 15) / 1.414,
                           (x - y + 17) / 1.414, (64 - x - y - 15 + 2) / 1.414])
    cv.over(inc & (d >= 0), lerp(ORANGE, RED, np.clip(y / 32, 0, 1)))
    cv.over(inc & (d >= 1.2) & (np.abs(x - 16) < 1.0), GOLD, 0.7)
    x, y, inc = cell(15)
    cv.over(inc & (np.abs(x - 16) < 1.0), (0.42, 0.20, 0.10))
    save(cv.image(), "EldgrimGlyphs.tga")


def main():
    os.makedirs(OUT, exist_ok=True)
    emblem()
    major_corner()
    minor_corner()
    button_atlas()
    well_atlas()
    glyph_atlas()


if __name__ == "__main__":
    sys.exit(main())
