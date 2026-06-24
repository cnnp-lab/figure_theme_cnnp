"""CNNP figure theme for matplotlib.

The Python adapter in the shared design-token system (see ../GUIDELINES.md): it
reads the same cnnp_tokens.json as the R and MATLAB adapters and applies the
lab's publication look to matplotlib (and anything built on it, e.g. seaborn).

Quick start::

    import cnnp_theme as cnnp
    import matplotlib.pyplot as plt

    tok = cnnp.use_cnnp()                 # apply once per session
    fig, ax = plt.subplots()
    ax.scatter(x, y)
    cnnp.cnnp_theme_ax(ax)                # optional per-axes cleanup
    cnnp.cnnp_savefig(fig, "my_figure", "out", width="single")
"""

from .colormap import make_colormap, register_colormaps
from .palettes import cnnp_ascii, markers, okabe_cycle, pair_palette
from .theme import (
    cnnp_context,
    cnnp_rc,
    cnnp_savefig,
    cnnp_theme_ax,
    fig_size_inches,
    use_cnnp,
)
from .tokens import Tokens, load_tokens

__all__ = [
    "load_tokens",
    "Tokens",
    "use_cnnp",
    "cnnp_context",
    "cnnp_rc",
    "cnnp_theme_ax",
    "cnnp_savefig",
    "fig_size_inches",
    "make_colormap",
    "register_colormaps",
    "okabe_cycle",
    "pair_palette",
    "markers",
    "cnnp_ascii",
]

__version__ = "0.1.0"
