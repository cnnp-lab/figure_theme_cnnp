"""The CNNP matplotlib theme: an rcParams style + per-axes chrome + export.

The theme is rcParams-based, so it applies to plain matplotlib AND to anything
built on it (seaborn, pandas .plot). This mirrors the R theme_cnnp() object and
the MATLAB cnnp_set_session_defaults + cnnp_theme_axes split:

  * ``use_cnnp()``        -> apply once per session (like the groot defaults)
  * ``cnnp_context()``    -> scoped application (``with`` block)
  * ``cnnp_theme_ax(ax)`` -> per-axes cleanup (re-assert chrome libraries override)
  * ``cnnp_savefig(...)`` -> export at a journal width (like ggsave_cnnp)

matplotlib is points-native, so token pt sizes (fonts, line widths, tick length,
markers) drop straight into rcParams with no conversion.
"""

from __future__ import annotations

import os
from contextlib import contextmanager
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
from cycler import cycler

from .colormap import register_colormaps
from .palettes import cnnp_ascii, okabe_cycle
from .tokens import Tokens, load_tokens

_MM_PER_INCH = 25.4


def cnnp_rc(tokens: Tokens | None = None) -> dict:
    """Build the CNNP rcParams dict from tokens (does not apply it)."""
    tok = tokens or load_tokens()
    base = tok.base_size_pt
    s = tok.scale
    lw = tok.line_weights_pt
    midnight = tok.neutral["midnight"]
    cream = tok.neutral["cream"]

    return {
        # the whole figure is the cream "card" — data panel AND the surrounding
        # margins/legend — matching the R theme (white is only a hairline gutter
        # frame there, which we omit). Set figure + savefig + axes all to cream.
        "figure.facecolor": cream,
        "savefig.facecolor": cream,
        "axes.facecolor": cream,
        "legend.facecolor": cream,

        # midnight chrome on every line of ink that isn't data
        "axes.edgecolor": midnight,
        "axes.labelcolor": midnight,
        "text.color": midnight,
        "xtick.color": midnight,
        "ytick.color": midnight,
        "xtick.labelcolor": midnight,
        "ytick.labelcolor": midnight,

        # classic L-shaped axes, ticks out, no grid
        "axes.spines.top": False,
        "axes.spines.right": False,
        "xtick.direction": "out",
        "ytick.direction": "out",
        "axes.grid": False,

        # typography (scale ratios x base, in points)
        "font.family": "sans-serif",
        "font.sans-serif": list(tok.font_prefer) + ["Helvetica", "Arial", "DejaVu Sans"],
        "font.size": base,
        "axes.titlesize": base * s["plot_title"],
        "axes.titleweight": "bold",
        "axes.titlelocation": "left",          # ggplot left-aligns titles
        "axes.labelsize": base * s["axis_title"],
        "xtick.labelsize": base * s["axis_text"],
        "ytick.labelsize": base * s["axis_text"],
        "legend.fontsize": base * s["legend_text"],
        "legend.title_fontsize": base * s["legend_title"],
        "figure.titlesize": base * s["plot_title"],
        "figure.titleweight": "bold",

        # stroke ladder (points)
        "axes.linewidth": lw["thin"],
        "xtick.major.width": lw["hairline"],
        "ytick.major.width": lw["hairline"],
        "xtick.major.size": tok.tick_len_pt,
        "ytick.major.size": tok.tick_len_pt,
        "lines.linewidth": lw["regular"],
        "lines.markersize": tok.marker_size_pt,
        "patch.linewidth": lw["hairline"],

        # discrete colour cycle = Okabe-Ito
        "axes.prop_cycle": cycler(color=okabe_cycle(tok)),

        # legend + layout
        "legend.frameon": False,
        "figure.constrained_layout.use": True,
        "savefig.dpi": tok.dpi,
        "figure.dpi": 100,

        # embed real (TrueType) fonts in PDF/PS instead of matplotlib's default
        # Type 3 — Type 3 glyphs import into Illustrator as individual paths, so
        # text isn't editable. fonttype 42 keeps text selectable and editable.
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    }


def use_cnnp(tokens: Tokens | None = None) -> Tokens:
    """Apply the CNNP theme to the current matplotlib session (like a groot set).

    Also registers the cnnp_seq / cnnp_gradient / cnnp_div colormaps. Returns the
    loaded tokens for convenience.
    """
    tok = tokens or load_tokens()
    mpl.rcParams.update(cnnp_rc(tok))
    register_colormaps(tok)
    return tok


@contextmanager
def cnnp_context(tokens: Tokens | None = None):
    """Scoped CNNP theme (``with cnnp_context(): ...``)."""
    tok = tokens or load_tokens()
    register_colormaps(tok)
    with mpl.rc_context(cnnp_rc(tok)):
        yield tok


def cnnp_theme_ax(ax, tokens: Tokens | None = None) -> None:
    """Re-assert the CNNP chrome on a single Axes.

    rcParams already cover most of the look, but libraries (notably seaborn) and
    some plot helpers restyle axes after creation. Call this on each Axes for an
    idempotent cleanup: cream face, hidden top/right spines, midnight spines and
    ticks at the token widths, ticks out, no grid.
    """
    tok = tokens or load_tokens()
    midnight = tok.neutral["midnight"]
    cream = tok.neutral["cream"]
    lw = tok.line_weights_pt

    ax.set_facecolor(cream)
    ax.grid(False)
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    for side in ("left", "bottom"):
        ax.spines[side].set_visible(True)
        ax.spines[side].set_color(midnight)
        ax.spines[side].set_linewidth(lw["thin"])
    ax.tick_params(
        direction="out", color=midnight, labelcolor=midnight,
        width=lw["hairline"], length=tok.tick_len_pt,
    )
    ax.xaxis.label.set_color(midnight)
    ax.yaxis.label.set_color(midnight)


def fig_size_inches(width: str | float, aspect: float = 0.85,
                    tokens: Tokens | None = None) -> tuple:
    """Figure size in inches for a journal width.

    width: 'single' (90 mm), 'onehalf' (140), 'double' (190), or a number in mm.
    """
    tok = tokens or load_tokens()
    width_mm = tok.widths_mm[width] if isinstance(width, str) else float(width)
    w_in = width_mm / _MM_PER_INCH
    return (w_in, w_in * aspect)


def cnnp_savefig(fig, name: str, out_dir: str | os.PathLike,
                 width: str | float = "single", aspect: float = 0.85,
                 formats=("pdf", "png"), tokens: Tokens | None = None):
    """Size a figure to a journal width and save it (mirrors ggsave_cnnp).

    Saved at the **true physical** journal width so the theme's point sizes print
    correctly: single = 90 mm, onehalf = 140, double = 190 (from the tokens), at
    300 dpi for raster formats. A PDF therefore has an exact MediaBox — e.g.
    single = 255 pt (90 mm) — identical to the R adapter's PDFs.

    ``formats`` is an iterable of extensions ('pdf' for vector, 'png'/'tiff' for
    raster); pass a single string for one format. ``name`` is ASCII-folded for the
    filename. Returns the written path(s).
    """
    tok = tokens or load_tokens()
    if isinstance(formats, str):
        formats = (formats,)
    fig.set_size_inches(*fig_size_inches(width, aspect, tok))
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)

    # R-style thin white frame: the whole figure is the cream card (single and
    # multi-panel alike — inter-facet gaps stay cream); a thin white border rings
    # the outer edge. Drawn as a perimeter outline (linewidth in points, so it is
    # figure-size independent), then removed so the figure isn't mutated.
    from matplotlib.patches import Rectangle
    frame = Rectangle((0, 0), 1, 1, transform=fig.transFigure, fill=False,
                      edgecolor="white", linewidth=2 * tok.gutter_pt,
                      zorder=1000, clip_on=False)
    fig.add_artist(frame)
    paths = []
    for fmt in formats:
        path = out / f"{cnnp_ascii(name)}.{fmt}"
        fig.savefig(path, dpi=tok.dpi, facecolor=fig.get_facecolor())
        paths.append(path)
    frame.remove()
    return paths[0] if len(paths) == 1 else paths
