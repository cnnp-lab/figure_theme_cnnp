"""Optional seaborn integration.

seaborn is NOT required by the rest of the adapter — the theme is rcParams-based
and applies to plain matplotlib. This module just funnels the same tokens through
seaborn's own entry points so seaborn plots inherit the CNNP look (and its
palette/style system doesn't clobber it).
"""

from __future__ import annotations

from .palettes import okabe_cycle
from .theme import cnnp_rc
from .tokens import Tokens, load_tokens


def cnnp_seaborn(tokens: Tokens | None = None):
    """Apply the CNNP theme via seaborn (``sns.set_theme``) + register cmaps.

    Use this instead of :func:`cnnp_theme.use_cnnp` when you plot with seaborn,
    so seaborn's defaults don't override the theme. Plain matplotlib plots still
    inherit it. Raises a clear error if seaborn isn't installed.
    """
    try:
        import seaborn as sns
    except ImportError as e:  # pragma: no cover
        raise ImportError(
            "seaborn is not installed. Install the extra:\n"
            "    uv sync --extra seaborn\n"
            "or use cnnp_theme.use_cnnp() for plain matplotlib."
        ) from e

    from .colormap import register_colormaps

    tok = tokens or load_tokens()
    register_colormaps(tok)
    # 'ticks' is seaborn's L-spine base; our rc overrides colours/sizes/grid on top.
    sns.set_theme(style="ticks", rc=cnnp_rc(tok))
    sns.set_palette(okabe_cycle(tok))
    return tok
