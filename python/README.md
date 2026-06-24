# CNNP figure theme — Python (matplotlib) adapter

The Python adapter in the shared design-token system. It reads the same
[`../cnnp_tokens.json`](../cnnp_tokens.json) as the R and MATLAB adapters and
applies the lab's publication look to **matplotlib** — and therefore to anything
built on it (seaborn, pandas `.plot`).

Usage rules: [`../GUIDELINES.md`](../GUIDELINES.md).

## Why matplotlib (not seaborn)

In Python the theme *is* `rcParams` — matplotlib's native styling layer. seaborn
sits **on top of** matplotlib (its plot functions return matplotlib `Axes`, and
`sns.set_theme()` just writes `rcParams`), so the chrome is a matplotlib concern
either way. The adapter is therefore matplotlib-native and seaborn-*compatible*:
seaborn is an optional extra, and `cnnp_theme.seaborn.cnnp_seaborn()` pushes the
same tokens through `sns.set_theme(rc=...)` so seaborn plots inherit the look.

## Environment (uv)

This is a [uv](https://docs.astral.sh/uv/) project — the recommended way to run
it (and a good template for lab analysis repos):

```bash
cd python
uv sync                      # matplotlib + numpy
uv sync --extra seaborn      # + seaborn, if you want the seaborn path
uv run python test_theme_cnnp.py     # writes python/test_out/*.pdf + *.png
```

## Quick start

`cnnp_theme` is imported directly from this folder (it's not installed as a
wheel — see `pyproject.toml`), so run from `python/` — e.g. `uv run python
your_script.py` — or add `python/` to `PYTHONPATH`.

```python
import cnnp_theme as cnnp
import matplotlib.pyplot as plt

tok = cnnp.use_cnnp()                 # apply the theme once per session
fig, ax = plt.subplots()
ax.scatter(x, y)
cnnp.cnnp_theme_ax(ax)                # optional per-axes cleanup
cnnp.cnnp_savefig(fig, "my_figure", "out", width="single")   # 90 mm, 300 dpi
```

With seaborn:

```python
from cnnp_theme.seaborn import cnnp_seaborn
cnnp_seaborn()                        # sns.set_theme(rc=cnnp_rc()) + palette
sns.boxplot(df, x="grp", y="val")
```

The whole figure is the cream "card" — data panels, margins, and (for facets)
the gaps between panels — with a thin white frame around the outer edge. This is
applied automatically by `cnnp_savefig`, single and multi-panel alike, matching
the R look. No extra call is needed for subplots.

## Files

| File | Role | R / MATLAB analog |
|---|---|---|
| `cnnp_theme/tokens.py` | load `cnnp_tokens.json`, resolve refs, expose palettes + sizes | `cnnp_load_tokens.m` |
| `cnnp_theme/colormap.py` | sequential/gradient/diverging colormaps, **CIE-Lab interpolated** | `cnnp_colormap.m` |
| `cnnp_theme/palettes.py` | Okabe-Ito cycle, brand-pair helpers, markers, `cnnp_ascii` | `scale_*_cnnp` / `cnnp_ascii` |
| `cnnp_theme/theme.py` | `cnnp_rc` + `use_cnnp` / `cnnp_context` / `cnnp_theme_ax` / `cnnp_savefig` | `theme_cnnp()` / session defaults + chrome + `ggsave_cnnp` |
| `cnnp_theme/seaborn.py` | optional `cnnp_seaborn()` integration | — |
| `test_theme_cnnp.py` | the gallery (run this) | `test_theme_cnnp.{R,m}` |

## Token → matplotlib mapping

| Token | matplotlib |
|---|---|
| `neutral.cream` / `neutral.midnight` | `axes.facecolor` / `axes.edgecolor`,`*.color` (+ white `figure.facecolor`) |
| `colors.okabe_ito` | `axes.prop_cycle` (a `cycler` over the hex list) |
| `colors.pairs` | `pair_palette(role='dark'\|'light')` |
| `scales.sequential` / `gradient` / `diverging` | registered cmaps `cnnp_seq` / `cnnp_gradient` / `cnnp_div` |
| `typography.base_size_pt` + `scale.*` + `font_prefer` | `font.size`, `axes.titlesize`/`labelsize`, `*tick.labelsize`, `legend.*`, `font.sans-serif` |
| `geometry.line_weights_pt` | `axes.linewidth` (thin), `*tick.major.width` (hairline), `lines.linewidth` (regular) |
| `geometry.axis_tick_length_pt` | `*tick.major.size` (matplotlib tick size is already in points — no conversion) |
| `export.widths_mm`, `dpi` | `cnnp_savefig(width=..., dpi=...)` |

matplotlib is points-native, so token pt sizes apply directly — only the R
adapter converts pt → mm.

## Fonts

The theme targets **Helvetica** (then Arial, then DejaVu Sans), set in
`font.sans-serif`. On **macOS** Helvetica is a system font and matplotlib uses it
automatically — no setup. If you just installed it and matplotlib still falls
back, clear its cache so it re-scans: `rm -rf ~/.cache/matplotlib`.

On **Linux/Windows** without Helvetica, either install it (or a metric-compatible
free substitute such as **TeX Gyre Heros** / **Nimbus Sans**) system-wide, or
register a font file at runtime, then clear the cache:

```python
import matplotlib.font_manager as fm
fm.fontManager.addfont("/path/to/Helvetica.ttf")   # then rm -rf ~/.cache/matplotlib
```

With none present it falls back to DejaVu Sans (the layout is otherwise identical).

## Notes / gotchas
- The continuous colormaps are interpolated in **CIE-Lab** (pure numpy, no
  `colour-science` dependency) to match ggplot2's `colour_ramp` and the MATLAB
  adapter, rather than matplotlib's default RGB interpolation.
- `cnnp_theme_ax()` is idempotent cleanup for axes that libraries restyle after
  creation (notably seaborn); plain matplotlib usually doesn't need it because
  `rcParams` already cover the look.
