"""Load cnnp_tokens.json and expose it as MATLAB/R-parallel Python data.

This is the Python half of the shared design-token system (see ../GUIDELINES.md).
The R and MATLAB adapters read the same JSON. Units in the token file are
physical: colours = hex, font/stroke/marker sizes = POINTS, figure widths = mm.
matplotlib is points-native (like MATLAB), so sizes drop straight in — only the
R adapter has to convert pt -> mm.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Tuple

RGB = Tuple[float, float, float]


def _find_tokens(explicit: str | os.PathLike | None = None) -> Path:
    """Locate cnnp_tokens.json.

    Resolution order (mirrors the R/MATLAB adapters): explicit argument, the
    ``CNNP_TOKENS`` environment variable, then the nearest ``cnnp_tokens.json``
    found by walking up from this file (the repo root sits above ``python/``),
    then the current working directory.
    """
    if explicit:
        p = Path(explicit)
        if p.is_file():
            return p
        raise FileNotFoundError(f"cnnp tokens not found: {p}")

    env = os.environ.get("CNNP_TOKENS")
    if env and Path(env).is_file():
        return Path(env)

    for base in Path(__file__).resolve().parents:
        candidate = base / "cnnp_tokens.json"
        if candidate.is_file():
            return candidate

    cwd = Path.cwd() / "cnnp_tokens.json"
    if cwd.is_file():
        return cwd

    raise FileNotFoundError(
        "cnnp_tokens.json not found (set $CNNP_TOKENS or pass an explicit path)"
    )


def _hex_to_rgb(h: str) -> RGB:
    h = h.lstrip("#")
    return (int(h[0:2], 16) / 255, int(h[2:4], 16) / 255, int(h[4:6], 16) / 255)


@dataclass
class Tokens:
    """Resolved design tokens. Colours are hex strings (matplotlib-ready);
    use :meth:`rgb` / the ``*_rgb`` views when you need float RGB."""

    raw: dict
    path: Path

    # colours (name -> hex)
    neutral: Dict[str, str] = field(default_factory=dict)
    greys: Dict[str, str] = field(default_factory=dict)
    okabe_ito: Dict[str, str] = field(default_factory=dict)
    pairs: Dict[str, Dict[str, str]] = field(default_factory=dict)

    # typography / geometry
    font_prefer: List[str] = field(default_factory=list)
    base_size_pt: float = 8.0
    label_size_pt: float = 8.0
    scale: Dict[str, float] = field(default_factory=dict)
    line_weights_pt: Dict[str, float] = field(default_factory=dict)
    marker_size_pt: float = 0.0
    tick_len_pt: float = 2.0
    gutter_pt: float = 1.0

    # export
    dpi: int = 300
    widths_mm: Dict[str, float] = field(default_factory=dict)

    shapes: List[str] = field(default_factory=list)

    # ---- ordered palette views ----
    @property
    def okabe_list(self) -> List[str]:
        """Okabe-Ito hex values in token order (for the colour cycle)."""
        return list(self.okabe_ito.values())

    @property
    def pair_names(self) -> List[str]:
        return list(self.pairs.keys())

    # ---- reference resolver ----
    def resolve(self, ref: str) -> str:
        """Resolve a palette reference to a hex string.

        Accepts ``"white"``/``"black"``, a literal ``"#rrggbb"``, or a dotted
        ``"<group>.<name>"`` where pairs use ``"<pair>.<dark|light>"`` (e.g.
        ``"teal.light"``) and other groups use ``"<group>.<name>"`` (e.g.
        ``"okabe_ito.vermillion"``, ``"greys.light"``, ``"neutral.cream"``).
        """
        low = ref.lower()
        if low == "white":
            return "#ffffff"
        if low == "black":
            return "#000000"
        if ref.startswith("#"):
            return ref
        group, _, name = ref.partition(".")
        if not name:
            raise ValueError(f"bad colour ref {ref!r}")
        colors = self.raw["colors"]
        if group in colors.get("pairs", {}):
            return colors["pairs"][group][name]
        if group in colors:
            return colors[group][name]
        raise ValueError(f"unknown colour group {group!r} in {ref!r}")

    def rgb(self, ref: str) -> RGB:
        return _hex_to_rgb(self.resolve(ref))

    # ---- resolved continuous-scale stops ----
    def scale_stops(self, kind: str) -> Tuple[List[RGB], List[float]]:
        """Return (colours, positions) for a continuous scale.

        kind: 'sequential' (3-stop white->teal.light->teal.dark with the
        perceptually-even 0.374 midpoint), 'gradient' (white->teal.dark), or
        'diverging' (vermillion<->white<->teal.dark).
        """
        s = self.raw["scales"]
        if kind == "sequential":
            cols = [self.rgb(c) for c in s["sequential"]["colors"]]
            return cols, list(s["sequential"]["values"])
        if kind == "gradient":
            return [self.rgb(s["gradient"]["low"]), self.rgb(s["gradient"]["high"])], [0.0, 1.0]
        if kind == "diverging":
            d = s["diverging"]
            return [self.rgb(d["low"]), self.rgb(d["mid"]), self.rgb(d["high"])], [0.0, 0.5, 1.0]
        raise ValueError(f"unknown scale kind {kind!r}")

    @property
    def na_rgb(self) -> RGB:
        return self.rgb(self.raw["scales"]["na_value"])


def load_tokens(path: str | os.PathLike | None = None) -> Tokens:
    """Read cnnp_tokens.json and return a :class:`Tokens`."""
    tok_path = _find_tokens(path)
    raw = json.loads(tok_path.read_text())

    colors = raw["colors"]
    typo = raw["typography"]
    geo = raw["geometry"]
    exp = raw["export"]

    return Tokens(
        raw=raw,
        path=tok_path,
        neutral=dict(colors["neutral"]),
        greys=dict(colors["greys"]),
        okabe_ito=dict(colors["okabe_ito"]),
        pairs={k: dict(v) for k, v in colors["pairs"].items()},
        font_prefer=list(typo["font_prefer"]),
        base_size_pt=float(typo["base_size_pt"]),
        label_size_pt=float(typo["label_size_pt"]),
        scale=dict(typo["scale"]),
        line_weights_pt=dict(geo["line_weights_pt"]),
        marker_size_pt=float(geo["marker_point_size_pt"]),
        tick_len_pt=float(geo["axis_tick_length_pt"]),
        gutter_pt=float(geo["panel_gutter"]),
        dpi=int(exp["dpi"]),
        widths_mm=dict(exp["widths_mm"]),
        shapes=list(raw["shapes"]),
    )
