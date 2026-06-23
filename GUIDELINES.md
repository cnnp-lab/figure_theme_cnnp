# CNNP colour & figure system — usage guidelines

These rules apply to **every** language adapter (R, MATLAB, Python). The machine-
readable values live in [`cnnp_tokens.json`](cnnp_tokens.json); this file is the
human-facing companion. Edit colours and sizes in the token file, not here.

---

## 1. Structural elements (never carry data meaning)

**`colors.neutral`**

| token | role |
|---|---|
| `midnight` | axes, ticks, all text labels, panel borders |
| `bluegrey` | secondary gridlines, reference lines, non-data structure |
| `cream`    | plot background only — never use as a data colour |
| `brown`    | brand stand-in for midnight (print/brand contexts only); not for data |

**`colors.greys`** — pure-neutral ramp, no brand hue, for geom defaults
(reference lines, confidence ribbons, NA fills). Distinct from `neutral`, which
carries brand identity. Do not use greys for science categories.

## 2. Brand plot colours (primary data colours)

**`colors.pairs`** — `teal`, `mustard`, `purple` — for markers, lines, fills, and
other data-carrying elements. Priority order:

- `teal` and `mustard` are first choice. Either may be used alone as a single
  colour, or together as a contrasting pair.
- `purple` is a fallback for paired categories only, when both `teal` and
  `mustard` are already committed in the same figure.
- Within a pair, `dark` = primary condition / foreground; `light` = secondary or
  background. Both together signal a paired relationship. Either may be used alone
  — pairs are not required to appear together.

## 3. Okabe-Ito (many unordered categorical levels)

**`colors.okabe_ito`** — use when you have more categories than `pairs` can
accommodate, or when categorical distinctiveness across many levels is the
priority.

- Do **not** mix with `pairs` colours in the same panel. In multi-panel figures,
  keep them in separate panels with a clear rationale.
- Only `midnight` and `cream` from `neutral` may appear alongside Okabe-Ito (for
  structure only — axes, background).
- Avoid `sky_blue`, `blue`, and `black` unless all other OI colours are taken:
  `sky_blue`/`blue` clash with brand teal; `black` clashes with midnight.
- `mustard` (light or dark) must not appear alongside OI `orange` or `yellow` in
  the same panel.

## 4. Continuous scales

- **Sequential** (`scales.sequential`, `scales.gradient`): the low end is
  **white**, not cream. This is intentional — low values on a cream panel
  background would be invisible. Do not "fix" this to cream.
  - The multi-stop sequential ramp places its middle stop at **0.374**, not 0.5.
    That is the CIE-L\* fraction between white (L\*≈100) and dark teal (L\*≈36), so
    perceived lightness drops **evenly** across the whole scale (both segments
    slope ≈ −64 L\* per unit) instead of plateauing near the light end. Even
    lightness ⇒ greyscale-safe and colour-blind-safe.
- **Diverging** (`scales.diverging`): poles are `vermillion` (negative) and dark
  `teal` (positive). **Warning:** `vermillion` is an Okabe-Ito colour — if a
  figure also uses Okabe-Ito categorical colours, ensure no category is assigned
  vermillion, or it will clash with the diverging scale's negative pole.

## 5. Colourblind safety

`okabe_ito` is fully colourblind-safe. `pairs` is **not** guaranteed
colourblind-safe on its own. If accessibility is a hard requirement, prefer
Okabe-Ito throughout, or verify `pairs` choices with a simulator.

---

## Units (for adapter authors)

Tokens are stored in physical, language-neutral units:

| token group | unit |
|---|---|
| `colors.*` | hex strings |
| `typography.*_pt`, `geometry.*_pt` (fonts, strokes, marker sizes) | **points (pt)** |
| `typography.scale.*` | unitless ratios of `base_size_pt` |
| `export.widths_mm` | **millimetres (mm)** |

matplotlib and MATLAB take pt directly. ggplot2's line-width and text-`size`
units are **mm**, so the R adapter converts pt → mm via the factor `72.27 / 25.4`
(≈ 2.8453). The `geometry.line_weights_pt` ladder is the stroke palette
(mm equivalents: hairline 0.15, fine 0.20, thin 0.25, rule 0.30, medium 0.40,
regular 0.50).

## Shapes / markers

`shapes` lists semantic marker names in priority order. Each adapter maps the
names to its own codes (ggplot integer `pch`, matplotlib marker strings, MATLAB
marker strings). The names are chosen to stay distinct at small print sizes.
