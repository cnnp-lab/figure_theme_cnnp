"""CNNP continuous colormaps, interpolated in CIE-L*a*b* (D65).

Matches ggplot2's ``colour_ramp`` (and the MATLAB adapter's ``cnnp_colormap``),
so the Python ramps look the same as the R and MATLAB figures rather than the
harsher result of naive RGB interpolation. Pure numpy — no Image-toolbox /
colour-science dependency.
"""

from __future__ import annotations

import numpy as np
from matplotlib.colors import ListedColormap

from .tokens import Tokens, load_tokens

_WP = np.array([0.95047, 1.0, 1.08883])  # D65 white point

_RGB2XYZ = np.array([
    [0.4124, 0.3576, 0.1805],
    [0.2126, 0.7152, 0.0722],
    [0.0193, 0.1192, 0.9505],
])
_XYZ2RGB = np.array([
    [3.2406, -1.5372, -0.4986],
    [-0.9689, 1.8758, 0.0415],
    [0.0557, -0.2040, 1.0570],
])


def _srgb_to_lab(rgb: np.ndarray) -> np.ndarray:
    c = np.where(rgb > 0.04045, ((rgb + 0.055) / 1.055) ** 2.4, rgb / 12.92)
    xyz = c @ _RGB2XYZ.T
    t = xyz / _WP
    f = np.where(t > 0.008856, np.cbrt(t), 7.787 * t + 16 / 116)
    fx, fy, fz = f[:, 0], f[:, 1], f[:, 2]
    return np.stack([116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)], axis=1)


def _lab_to_srgb(lab: np.ndarray) -> np.ndarray:
    fy = (lab[:, 0] + 16) / 116
    fx = fy + lab[:, 1] / 500
    fz = fy - lab[:, 2] / 200
    f = np.stack([fx, fy, fz], axis=1)
    t3 = f ** 3
    xyz = np.where(t3 > 0.008856, t3, (f - 16 / 116) / 7.787) * _WP
    c = xyz @ _XYZ2RGB.T
    rgb = np.where(c > 0.0031308, 1.055 * np.clip(c, 0, None) ** (1 / 2.4) - 0.055, 12.92 * c)
    return np.clip(rgb, 0, 1)


def make_colormap(kind: str, n: int = 256, tokens: Tokens | None = None) -> ListedColormap:
    """Build a CNNP continuous colormap.

    kind: 'seq' (white->teal.light->teal.dark, the default sequential),
    'gradient' (white->teal.dark), or 'div' (vermillion<->white<->teal.dark).
    """
    tok = tokens or load_tokens()
    kinds = {"seq": "sequential", "gradient": "gradient", "div": "diverging"}
    if kind not in kinds:
        raise ValueError(f"unknown colormap kind {kind!r}")

    stops, pos = tok.scale_stops(kinds[kind])
    lab = _srgb_to_lab(np.asarray(stops, dtype=float))
    q = np.linspace(0, 1, n)
    labq = np.stack([np.interp(q, pos, lab[:, c]) for c in range(3)], axis=1)
    rgb = _lab_to_srgb(labq)
    return ListedColormap(rgb, name=f"cnnp_{kind}")


def register_colormaps(tokens: Tokens | None = None) -> None:
    """Register cnnp_seq / cnnp_gradient / cnnp_div as named matplotlib cmaps."""
    import matplotlib as mpl

    tok = tokens or load_tokens()
    for kind in ("seq", "gradient", "div"):
        cmap = make_colormap(kind, tokens=tok)
        if cmap.name not in mpl.colormaps:
            mpl.colormaps.register(cmap)
