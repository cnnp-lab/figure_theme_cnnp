# CNNP figure theme — MATLAB adapter (on gramm)

The MATLAB adapter is built on **[gramm](https://github.com/piermorel/gramm)**, a
ggplot2-style grammar-of-graphics toolbox for MATLAB (MIT, R2018b+). gramm's
`set_*_options` family maps almost 1:1 onto our design tokens, so this adapter is
mostly mechanical token-injection plus a custom "chrome" theme for the look that
gramm has no native concept of.

Reads the same [`../cnnp_tokens.json`](../cnnp_tokens.json) as the R adapter.
Usage rules: [`../GUIDELINES.md`](../GUIDELINES.md).

## Status: proof-of-concept

| File | Role |
|---|---|
| `cnnp_load_tokens.m` | read `cnnp_tokens.json`, build RGB colormaps + sizes |
| `cnnp_style.m` | inject colour / text / line / marker options into a gramm object (before `draw()`) |
| `cnnp_theme_axes.m` | apply the chrome (cream cards, midnight axes, no grid) **after** `draw()` |
| `cnnp_poc.m` | one-figure proof-of-concept (run this) |

```matlab
cd matlab
cnnp_poc          % writes matlab/poc_out/cnnp_poc.png
```

## Token → gramm mapping

| Token | gramm |
|---|---|
| `colors.okabe_ito` (8×1) / `colors.pairs` (3×2) | `set_color_options('map', RGB, 'n_color', N, 'n_lightness', M)` |
| `typography.base_size_pt` + `scale.*` + `font_prefer` | `set_text_options('base_size', …, '*_scaling', …, 'font', …)` |
| `geometry.line_weights_pt.regular` | `set_line_options('base_size', …)` |
| `geometry.marker_point_size_pt` + `shapes` | `set_point_options('base_size', …, 'markers', …)` |
| `export.widths_mm`, `dpi` | `g.export('width','height','units','resolution')` |

MATLAB is points-native (LineWidth/FontSize/MarkerSize all in pt), so token sizes
apply directly — no unit conversion (the R adapter is the only one that converts
pt → mm).

## Still to verify in real MATLAB (no MATLAB in the dev env)
- `jsondecode` on the token file: the `ascii_fold` keys are non-identifier Unicode;
  jsondecode should mangle them to valid field names without error (we never read
  `ascii_fold` in MATLAB). Confirm it doesn't throw.
- `set_continuous_color` with a **custom N×3 RGB matrix** vs. its `LCH_colormap`
  form — needed for the sequential (white→teal) and diverging scales (not in the POC).
- The post-draw chrome on `legend_axe_handle` / `title_axe_handle` (cream vs white)
  and `TickLength` (token is 2 pt; MATLAB `TickLength` is a normalized fraction).

## Still to build (after POC sign-off)
- `cnnp_pairs` palette demo (color × lightness), continuous-scale colormaps,
  facet-strip styling, multi-panel gutters, a `cnnp_export` wrapper, and a full
  `test_theme_cnnp.m` gallery mirroring the R one. A `cnnp_gramm` subclass
  (constructor pre-applies `cnnp_style`) is an option for the closest thing to
  "apply once per session".
