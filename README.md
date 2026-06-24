# CNNP lab figure theme

A brand-consistent figure theme + colour system for CNNP lab figures, available
for **R, MATLAB, and Python**. It is intentionally *domain-agnostic* —
typography, colour-blind-safe palettes, scale helpers, and export tooling that
every lab paper can reuse unchanged. Paper-specific *semantic* palettes (e.g.
"physical activity is always orange") belong in that project's own config,
**not** here.

## Getting started — choose your language

Each language has a self-contained adapter in its own folder, with its own README
and a runnable gallery. Start there:

| Language | Folder | First steps |
|---|---|---|
| **R** (ggplot2) | [`r/`](r/) — [README](r/README.md) | `cd r && Rscript -e 'renv::restore()'` then `source("theme_cnnp.R")` |
| **Python** (matplotlib) | [`python/`](python/) — [README](python/README.md) | `cd python && uv sync` then `import cnnp_theme as cnnp; cnnp.use_cnnp()` |
| **MATLAB** (gramm) | [`matlab/`](matlab/) — [README](matlab/README.md) | install [gramm](https://github.com/piermorel/gramm), then `g = cnnp_style(g, cnnp_load_tokens())` |

Each folder has a `test_theme_cnnp.*` gallery script — the best reference for real
usage; when in doubt, copy a pattern from there.

## Architecture: tokens + per-language adapters

All design values live in one language-neutral file,
[`cnnp_tokens.json`](cnnp_tokens.json) — colours, palettes, font/stroke/marker
sizes, scale recipes. Each language has a thin **adapter** that reads those
tokens and wires them into its own plotting API:

| File | Role |
|---|---|
| [`cnnp_tokens.json`](cnnp_tokens.json) | **Source of truth** — edit colours/sizes/palettes here |
| [`GUIDELINES.md`](GUIDELINES.md) | Human-facing usage rules (applies to every language) |
| [`r/`](r/) | R / ggplot2 adapter |
| [`matlab/`](matlab/) | MATLAB adapter (on [gramm](https://github.com/piermorel/gramm)) |
| [`python/`](python/) | Python / matplotlib adapter (uv project; seaborn-compatible) |

**Edit design values in the token file, not in an adapter.** Units are physical
and language-neutral: colours as hex, font/stroke/marker sizes in **points**,
figure widths in **mm**, the type scale as unitless ratios. matplotlib and MATLAB
take points directly; the R adapter converts pt → ggplot's mm units internally.
See [`GUIDELINES.md`](GUIDELINES.md) for the colour-usage rules and the unit
convention.

## The colour system (shared)

The full rules — when to use which palette, mixing constraints, colourblind
safety — live in [`GUIDELINES.md`](GUIDELINES.md). In short, colours split into
**structural** (never carry data meaning) and **data** colours:

| Group | Kind | Use |
|---|---|---|
| `neutral` | structural | brand chrome: `cream` (background only), `midnight` (axes/ticks/text), `bluegrey` (secondary structure), `brown` |
| `greys` | structural | pure-neutral ramp for reference lines, ribbons, NA fills — *not* for data categories |
| `pairs` | data | brand colours as dark/light pairs: `teal`, `mustard`, `purple` (priority teal > mustard > purple); `dark` = primary, `light` = secondary |
| `okabe_ito` | data | 8 colour-blind-safe categorical hues, for many unordered levels |

Continuous scales come in **sequential** (white → teal), an even-lightness
multi-stop variant, and **diverging** (vermillion ↔ white ↔ teal). Each adapter
exposes these through its native API — see the per-language README.

A few rules worth knowing up front (the rest are in [`GUIDELINES.md`](GUIDELINES.md)):
don't mix `pairs` with Okabe-Ito hues in the same panel; only `midnight`/`cream`
should appear alongside Okabe-Ito; `okabe_ito` is fully colour-blind-safe whereas
`pairs` is not guaranteed to be.

## What the figures look like

The whole plot is a **brand-cream card** with midnight axis chrome, no gridlines
(classic look), facet strips with no grey box, and bold titles. Figures are sized
to standard journal column widths (single 90 mm / one-half 140 / double 190) at
300 dpi. Each adapter's gallery renders the same set of figures to its own
`test_out/` folder, so you can compare the look across languages.
