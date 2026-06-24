"""Discrete palettes, marker mapping, and text helpers."""

from __future__ import annotations

from typing import Dict, List

from .tokens import Tokens, load_tokens

# Semantic shape names -> matplotlib markers. matplotlib has no square-with-cross
# glyph, so 'square_cross' falls back to the filled X (the R adapter maps the
# same names to integer pch codes, MATLAB to its own glyphs).
_MARKERS = {
    "circle_filled": "o",
    "triangle_filled": "^",
    "square_filled": "s",
    "diamond_filled": "D",
    "plus": "P",
    "asterisk": "*",
    "square_cross": "X",
    "cross": "x",
}

# ASCII folding, defined by Unicode code point so this source stays pure-ASCII
# (mirrors the shared `ascii_fold` token map and the R/MATLAB cnnp_ascii).
_FOLD = {
    "—": "-",    # em dash
    "–": "-",    # en dash
    "−": "-",    # minus sign
    "‘": "'",    # left single quote
    "’": "'",    # right single quote
    "“": '"',    # left double quote
    "”": '"',    # right double quote
    "…": "...",  # ellipsis
}


def okabe_cycle(tokens: Tokens | None = None) -> List[str]:
    """Okabe-Ito hex values in token order (for ``axes.prop_cycle``)."""
    tok = tokens or load_tokens()
    return tok.okabe_list


def pair_palette(order: List[str] | None = None, role: str = "dark",
                 tokens: Tokens | None = None) -> List[str]:
    """Brand-pair hex values for one role across pairs in priority order.

    role: 'dark' (primary) or 'light' (secondary). order: which pairs and in
    what order (default teal, mustard, purple — the priority order).
    """
    tok = tokens or load_tokens()
    names = order or tok.pair_names
    return [tok.pairs[n][role] for n in names]


def markers(tokens: Tokens | None = None) -> List[str]:
    """Marker glyphs for the token shape order (redundant colour+shape coding)."""
    tok = tokens or load_tokens()
    return [_MARKERS.get(s, "o") for s in tok.shapes]


def cnnp_ascii(s: str) -> str:
    """Fold common non-ASCII typography to ASCII (dashes, quotes, ellipsis)."""
    for src, dst in _FOLD.items():
        s = s.replace(src, dst)
    return s
