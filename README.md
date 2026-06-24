# CNNP lab figure theme

A brand-consistent figure theme + colour system for CNNP lab figures. It is
intentionally *domain-agnostic* — typography, colour-blind-safe palettes, scale
helpers, and export tooling that every lab paper can reuse unchanged.
Paper-specific *semantic* palettes (e.g. "physical activity is always orange")
belong in that project's own config, **not** here.

## Architecture: tokens + per-language adapters

All design values live in one language-neutral file,
[`cnnp_tokens.json`](cnnp_tokens.json) — colours, palettes, font/stroke/marker
sizes, scale recipes. Each language has a thin **adapter** that reads those
tokens and wires them into its own plotting API:

| File | Role |
|---|---|
| [`cnnp_tokens.json`](cnnp_tokens.json) | **Source of truth** — edit colours/sizes/palettes here |
| [`GUIDELINES.md`](GUIDELINES.md) | Human-facing usage rules (applies to every language) |
| [`theme_cnnp.R`](theme_cnnp.R) | R / ggplot2 adapter |
| [`matlab/`](matlab/) | MATLAB adapter (on [gramm](https://github.com/piermorel/gramm)) |
| [`python/`](python/) | Python / matplotlib adapter (uv project; seaborn-compatible) |

**Edit design values in the token file, not in an adapter.** Units are physical
and language-neutral: colours as hex, font/stroke/marker sizes in **points**,
figure widths in **mm**, the type scale as unitless ratios (the R adapter
converts pt → ggplot's mm units internally). See [`GUIDELINES.md`](GUIDELINES.md)
for the colour-usage rules and the unit convention.

A runnable gallery that exercises the whole R API is in
[`test_theme_cnnp.R`](test_theme_cnnp.R) — when in doubt, copy a pattern from
there.

---

## Quick start

```r
source("theme_cnnp.R")
library(ggplot2)

cnnp_set_geom_defaults()          # optional: branded neutral look for every geom

ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_cnnp()                    # <- the theme
```

To see all the pieces working together, render the gallery:

```sh
Rscript test_theme_cnnp.R         # writes PDFs + TIFFs to ./test_out/
```

### Requirements
- R with **ggplot2** (≥ 4.x) and **jsonlite** (reads `cnnp_tokens.json`).
  Optional: **systemfonts** (font resolution), **ragg** (TIFF/PNG),
  **patchwork** (multi-panel + guide collection), **scales** (date breaks —
  usually already present via ggplot2).

---

## The theme

```r
theme_cnnp(base_size = 8, base_family = CNNP_FONT, gutter = 3)
```

- `base_size = 8` is tuned for print: save figures at their **true final width**
  (see *Export* below) so 8 pt text prints as 8 pt.
- Font resolves to **Helvetica** (a PDF base-14 font → renders in the standard
  `pdf()` device with no font embedding) and falls back gracefully if absent.
- The whole plot is a **brand-cream card** (data area + axis margins), midnight
  axis chrome, no gridlines (classic look), facet strips with no grey box.
  Titles and the A/B/C panel tags are bold; both at the same size.
- `gutter` (pt) is the white separation between panels in a **multi-panel**
  (patchwork) figure — a white border on the cream card that reads as an
  invisible frame on a single figure and as the inter-panel gap when composed.
  Lower it for tighter grids, raise it for more air.

---

## Colour

The colour system splits cleanly into **structural** colours (never carry data
meaning) and **data** colours. The full rules live in
[`GUIDELINES.md`](GUIDELINES.md); the R objects (built from `cnnp_tokens.json`)
are:

| Object | Kind | Use |
|---|---|---|
| `cnnp_neutral` | structural | brand chrome: `cream` (background only), `midnight` (axes/ticks/text), `bluegrey` (secondary structure), `brown` (brand stand-in for midnight) |
| `cnnp_greys` | structural | pure-neutral ramp (no brand hue) for geom defaults: reference lines, ribbons, NA fills — *not* for data categories |
| `cnnp_pairs` | data | brand plot colours as dark/light pairs: `teal`, `mustard`, `purple` (priority teal > mustard > purple). `dark` = primary/foreground, `light` = secondary/background |
| `cnnp_okabe_ito` | data | 8 colour-blind-safe categorical hues, for many unordered levels |

```r
cnnp_neutral[["midnight"]]    # "#223344"  (structural chrome)
cnnp_pairs$teal[["dark"]]     # "#005d76"  (a brand data colour)
```

A few rules worth knowing (see [`GUIDELINES.md`](GUIDELINES.md) for the rest): don't mix
`cnnp_pairs` with Okabe-Ito hues in the same panel; only `midnight`/`cream` from
`cnnp_neutral` should appear alongside Okabe-Ito; and `cnnp_okabe_ito` is fully
colour-blind-safe whereas `cnnp_pairs` is not guaranteed to be.

### Discrete scales

**Automatic** — "give me N colour-blind-safe colours" (Okabe-Ito in order). Use
when the specific colour carries no fixed meaning:

```r
+ scale_colour_cnnp_d()
+ scale_fill_cnnp_d()
```

**Semantic** — a category must map to a *fixed* colour across every figure. Define
a named vector in your project and pass it in:

```r
pal_groups <- c(pa = unname(cnnp_okabe_ito["orange"]),
                sleep = unname(cnnp_okabe_ito["blue"]))
+ scale_colour_cnnp(pal_groups)
+ scale_fill_cnnp(pal_groups)
```

### Redundant colour + shape (greyscale-safe)

Colour alone fails in B/W print and photocopies. Encode **one** category as both
colour and shape and get a **single merged legend**. Map both aesthetics to the
same variable:

```r
ggplot(iris, aes(Sepal.Length, Petal.Length, colour = Species, shape = Species)) +
  geom_point() +
  cnnp_scale_redundant(name = "species") +        # automatic Okabe-Ito + shapes
  theme_cnnp()

# or with fixed semantic colours:
  + cnnp_scale_redundant(pal_species, name = "species")
```

`scale_shape_cnnp()` is available on its own if you only want branded shapes.

### Continuous scales

```r
# Sequential, single-hue (white → dark teal)
+ scale_fill_gradient_cnnp()            # direction = -1 reverses

# Sequential, brand multi-stop (white → light teal → dark teal),
# tuned so perceived lightness drops EVENLY across the scale
+ scale_fill_seq_cnnp()

# Diverging, centred (vermillion ← white → teal), e.g. correlation / z-score
+ scale_fill_gradient2_cnnp(midpoint = 0)
```

Each has a `scale_colour_*` twin, and every continuous scale accepts `na.value`
(defaults to `CNNP_NA_COLOUR`, a structural grey that reads as "no data").

---

## Geom defaults (optional)

Call once per session, after sourcing, to give every geom a neutral branded look
(teal data marks, structural-grey reference lines, etc.). Mapped/explicit
aesthetics always override these:

```r
cnnp_set_geom_defaults()
```

Covers points, lines, bars/cols, boxplots, violins, histograms, area/ribbon,
density, error bars/pointrange, reference lines (`hline`/`vline`/`abline`), and
in-panel `text`/`label`.

---

## Date axes

ggplot's default date breaks crowd in narrow panels. These pick tidy,
evenly-spaced breaks (`scales::breaks_pretty()`):

```r
+ scale_x_date_cnnp(n = 4)                       # ~4 nice breaks
+ scale_x_datetime_cnnp(n = 5, date_labels = "%Y")
```

---

## Multi-panel figures (patchwork)

Compose with patchwork as usual. To fold duplicate legends into one shared legend:

```r
library(patchwork)
(p1 | p2) / p3 +
  cnnp_collect_guides() +
  plot_annotation(title = "Figure 1", theme = cnnp_annotation_theme())
```

Each panel is a cream card; **`cnnp_annotation_theme()`** is the theme for the
patchwork wrapper itself — it keeps the figure-level **supertitle** and the outer
margin on **white** (panels stay cream). Without it, the supertitle would sit on a
cream strip.

`cnnp_collect_guides()` also sets `axis_titles = "collect"`, which keeps each axis
title pinned to its own tick labels (otherwise a tall shared legend can stretch the
row and drop the x-title away from its ticks) and de-duplicates titles shared
across panels. Override either via its arguments, e.g.
`cnnp_collect_guides(axis_titles = "keep")`.

> **When to use it:** `cnnp_collect_guides()` shines when panels *share* a legend
> (it dedupes to one). If every panel has a *different* legend, collecting stacks
> them all into one tall column that can overflow — leave it off and let each
> panel keep its own. (`theme_cnnp()` can't carry this itself: a theme object is
> not a patchwork layout.)

---

## In-panel text

Text drawn *inside* the panel (`geom_text`, `annotate("text")`) is a layer, not a
theme element, so the theme can't style it. Use the constants as the single source
of truth so labels stay in lockstep with the axis chrome:

```r
annotate("text", x = 1, y = 2, label = "n = 42",
         colour = CNNP_LABEL_COLOUR, size = CNNP_LABEL_SIZE)
```

`cnnp_set_geom_defaults()` already applies these to `geom_text`/`geom_label`.

---

## Export

Save at a fixed **physical** size so the theme's point sizes print correctly.
Standard journal column widths (mm) are named:

```r
cnnp_widths    # single = 90, onehalf = 140, double = 190
```

```r
ggsave_cnnp(plot, "figure_2",
            out_dir = "figures",
            width   = "onehalf",      # or a number in mm
            aspect  = 0.6,            # height = width * aspect (or pass height = ...)
            formats = c("pdf", "tiff"))   # "png" also available
```

- **PDF** uses the dependency-free base-14 device (no font embedding/cairo).
- **TIFF/PNG** route through ragg (system fonts, LZW compression).

### A gotcha: PDF and special characters

The base-14 PDF device only covers Latin-1, so em/en-dashes, smart quotes, and
ellipses get silently mangled (and disagree with the ragg output). `ggsave_cnnp()`
**auto-folds** a plain ggplot's titles/axis/legend labels to safe ASCII on the PDF
path. Text it *can't* reach automatically — **patchwork** titles, **facet** labels,
**in-panel** `geom_text` — should be wrapped by hand:

```r
title = cnnp_ascii("Gallery — double column")    # — becomes -
```

---

## Worked example

[`test_theme_cnnp.R`](test_theme_cnnp.R) renders six figures across all three
widths and is the best reference for real usage:

- **fig0** (double) — the colour system, visualised: a labelled swatch card of
  every palette (structural · brand pairs · Okabe-Ito) over a row of worked
  examples (teal alone, teal+mustard pair, Okabe-Ito for many categories,
  diverging scale). Look here first to understand the colour guidelines.
- **fig1** (single) — scatter + smooth + discrete legend, reference line, caption
- **fig2** (onehalf) — faceted boxplot + jitter
- **fig3** (double) — patchwork gallery: scatter, bars, time series, sequential &
  diverging heatmaps, forest/pointrange
- **fig4** (double) — redundant colour+shape, violin, density, histogram,
  area+ribbon, even-lightness sequential ramp with an NA cell; also shows the
  cream-card panels, white gutters, and a supertitle on white
- **fig5** (single) — redundant colour+shape at true single-column size

fig3/fig4 are the reference for multi-panel composition (`cnnp_collect_guides()` +
`cnnp_annotation_theme()`); fig1/fig5 for single-column layout.
