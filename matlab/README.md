# CNNP figure theme — MATLAB adapter (on gramm)

The MATLAB adapter is built on **[gramm](https://github.com/piermorel/gramm)**, a
ggplot2-style grammar-of-graphics toolbox for MATLAB (MIT, R2018b+). gramm's
`set_*_options` family maps almost 1:1 onto our design tokens, so this adapter is
mostly mechanical token-injection plus a custom "chrome" theme for the look that
gramm has no native concept of.

Reads the same [`../cnnp_tokens.json`](../cnnp_tokens.json) as the R adapter.
Usage rules: [`../GUIDELINES.md`](../GUIDELINES.md).

## Status: working (validated in MATLAB R2024b on gramm)

| File | Role |
|---|---|
| `cnnp_load_tokens.m` | read `cnnp_tokens.json`, build RGB colormaps + sizes + resolved scale stops |
| `cnnp_style.m` | inject colour / text / line / marker options into a gramm object (before `draw()`) |
| `cnnp_theme_axes.m` | apply the chrome (cream cards, midnight axes, no grid, pt-accurate ticks) **after** `draw()` |
| `cnnp_continuous.m` | apply a token-derived continuous colour scale (`seq` / `gradient` / `div`) |
| `cnnp_colormap.m` | build a continuous colormap (Nx3 RGB), interpolated in CIE-Lab to match R |
| `cnnp_seq.m` / `cnnp_grad.m` / `cnnp_div.m` | named colormap wrappers (the public way to feed gramm a custom RGB ramp) |
| `cnnp_export.m` | export at a journal width (mirrors `ggsave_cnnp`); ASCII-folds the filename |
| `cnnp_ascii.m` | fold non-ASCII typography to ASCII (mirrors R `cnnp_ascii`) |
| `cnnp_set_session_defaults.m` / `cnnp_reset_defaults.m` | apply / undo session-wide `groot` defaults |
| `cnnp_poc.m` | one-figure proof-of-concept |
| `test_theme_cnnp.m` | the full gallery (run this) |

```matlab
cd matlab
test_theme_cnnp   % writes matlab/test_out/*.png  (6-figure gallery)
cnnp_poc          % writes matlab/poc_out/cnnp_poc.png  (single POC)
```

Typical use in lab code:

```matlab
T = cnnp_load_tokens();
cnnp_set_session_defaults(T);          % once per session (optional)
g = gramm('x', x, 'y', y, 'color', grp);
g.geom_point();
g = cnnp_style(g, T);                   % brand colours/fonts/lines/markers
figure('Color','w'); g.draw();
cnnp_theme_axes(g, T);                  % cream cards, midnight axes, no grid
cnnp_export(g, T, 'my_figure', 'out', 'width', 'single');
```

## Token → gramm mapping

| Token | gramm |
|---|---|
| `colors.okabe_ito` (8×1) / `colors.pairs` (3×2) | `set_color_options('map', RGB, 'n_color', N, 'n_lightness', M)` |
| `typography.base_size_pt` + `scale.*` + `font_prefer` | `set_text_options('base_size', …, '*_scaling', …, 'font', …)` |
| `geometry.line_weights_pt.regular` | `set_line_options('base_size', …)` |
| `geometry.marker_point_size_pt` + `shapes` | `set_point_options('base_size', …, 'markers', …)` |
| `scales.sequential` / `gradient` / `diverging` | `cnnp_continuous(g, type)` → `set_continuous_color('colormap', 'cnnp_*')` |
| `export.widths_mm`, `dpi` | `g.export('width','height','units','resolution')` |

MATLAB is points-native (LineWidth/FontSize/MarkerSize all in pt), so token sizes
apply directly — no unit conversion (the R adapter is the only one that converts
pt → mm).

## gramm-specific gotchas (found while validating)
- **Point borders.** This gramm version feeds `border_width` straight to
  `scatter`'s `LineWidth`, which MATLAB requires `> 0`. `cnnp_style` uses a tiny
  width with a `'none'` edge colour (invisible border, legal value).
- **The figure handle** (`gramm.parent`) is protected; `cnnp_theme_axes` reaches
  the figure via `ancestor(facet_axes_handles(1), 'figure')`.
- **Continuous colormaps.** `set_continuous_color` takes only a *named* colormap
  or a linear `LCH_colormap` — there is no custom-RGB-matrix parameter, and
  `continuous_color_options` is protected. The public route is a **named function
  returning an Nx3 map** (gramm evaluates `NAME(256)`), so `cnnp_seq`/`cnnp_grad`/
  `cnnp_div` exist as thin wrappers over `cnnp_colormap`. Ramps are interpolated
  in CIE-Lab (like ggplot2's `colour_ramp`) to match the R figures.
- **Brand-pairs ordering.** gramm orders the colour/lightness factors
  alphabetically by default, which scrambles which group gets which pair.
  `cnnp_style(..., 'palette', 'pairs')` sets `set_order_options('color', 0,
  'lightness', 0)`, so binding is **positional by order of appearance**: 1st
  colour level → teal, 2nd → mustard, 3rd → purple; 1st lightness → dark
  (primary), 2nd → light (secondary). Arrange your factor accordingly.
- **Tick length.** The 2 pt token is converted to MATLAB's normalized
  `TickLength` fraction per-axis (from the axis size in points) in
  `cnnp_theme_axes`, so ticks are physically 2 pt regardless of panel size.
- **Headless export.** Under `matlab -nodisplay`, `export()` prints a benign
  "cannot use OpenGL for printing" warning and uses software rendering; PNGs are
  fine but slightly softer than an interactive session.

## Possible next steps
- A `cnnp_gramm` subclass whose constructor pre-applies `cnnp_style` (closest
  thing to "apply once"), and a `draw()` override that also runs the chrome.
- Native tile/heatmap support: gramm has no `geom_tile`, so for correlation-
  matrix style figures use `imagesc` + `colormap(cnnp_colormap('div'))` directly
  and reuse the chrome on the plain axes.
