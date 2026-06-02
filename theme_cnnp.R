# CNNP lab ggplot2 theme and colour scales.
# Usage:
#   source("theme_cnnp.R")
#   p + theme_cnnp() + scale_fill_cnnp("circadian_lifestyle")
#   p + theme_cnnp() + scale_fill_cnnp(c(a = "#E69F00", b = "#56B4E9"))

library(ggplot2)

# ── Typography ────────────────────────────────────────────────────────────────
# Resolve the lab's base sans-serif. Helvetica is preferred because it is one of
# the PDF "base-14" fonts — it renders natively in the standard pdf() device with
# no font embedding (so no cairo/XQuartz needed) and is also installed for ragg's
# TIFF/PNG output, so the same typeface renders cleanly in every format with zero
# extra dependencies. Falls back to the device default if absent, so the theme
# never errors on a machine lacking it (the old "invalid font type" trap).
cnnp_font <- function(prefer = c("Helvetica", "Arial")) {
  if (requireNamespace("systemfonts", quietly = TRUE)) {
    have <- unique(systemfonts::system_fonts()$family)
    hit  <- prefer[prefer %in% have]
    if (length(hit)) return(hit[[1]])
    warning("cnnp_font(): none of {", paste(prefer, collapse = ", "),
            "} installed; using the device default sans.")
  }
  ""   # generic device sans-serif
}

CNNP_FONT <- cnnp_font()

# ── Theme ─────────────────────────────────────────────────────────────────────

# gutter (in pt) is the white separation drawn between panels in a multi-panel
# (patchwork) figure — see the plot.background note below. Tune per project.
theme_cnnp <- function(base_size = 8, base_family = CNNP_FONT, gutter = 3) {
  theme_classic(base_size = base_size, base_family = base_family) %+replace%
    theme(
      axis.line         = element_line(linewidth = 0.25, color = cnnp_dark[["midnight"]]),
      axis.ticks        = element_line(linewidth = 0.15, color = cnnp_dark[["midnight"]]),
      axis.ticks.length = unit(2, "pt"),
      axis.text         = element_text(size = rel(1.0), color = cnnp_dark[["midnight"]]),
      axis.title        = element_text(size = rel(1.15),  color = cnnp_dark[["midnight"]]),
      # The whole plot is brand cream (data area + axis margins), so a panel reads
      # as one solid card. The white *border* on plot.background does double duty:
      # on a single figure it's an invisible frame on the white page; in a patchwork
      # it forms the white gutter between panels (panels sit flush, so each panel's
      # border contributes half the gap). plot.margin keeps content clear of it.
      panel.background  = element_rect(fill = cnnp_light[["cream"]], color = NA),
      plot.background   = element_rect(fill = cnnp_light[["cream"]], color = "white",
                                       linewidth = gutter),
      plot.margin       = margin(gutter + 1, gutter + 1, gutter + 1, gutter + 1, "pt"),
      panel.grid        = element_blank(),
      legend.background = element_rect(fill = cnnp_light[["cream"]], color = NA),
      legend.key        = element_rect(fill = cnnp_light[["cream"]], color = NA),
      legend.text       = element_text(size = rel(1.0), color = cnnp_dark[["midnight"]]),
      legend.title      = element_text(size = rel(1.15), face = "plain", color = cnnp_dark[["midnight"]]),
      # facet strips: no grey box; label colour matches the axis chrome. Per-plot
      # layout (angle/justification) is left to the figure (see plot_beta_forest).
      strip.background  = element_blank(),
      strip.text        = element_text(size = rel(1.0), color = cnnp_dark[["midnight"]]),
      # bold, matching the plot.tag (panel letter) weight so titles and tags read
      # as one typographic level. Supertitles use plot.title too, so they inherit it.
      plot.title        = element_text(size = rel(1.15), face = "bold",
                                       hjust = 0, color = cnnp_dark[["midnight"]]),
      plot.subtitle     = element_text(size = rel(1.0), hjust = 0, color = cnnp_dark[["midnight"]]),
      # captions: same midnight chrome, right-aligned and a touch smaller.
      plot.caption      = element_text(size = rel(0.9), hjust = 1, color = cnnp_dark[["midnight"]]),
      plot.tag          = element_text(face = "bold", size = rel(1.15), color = cnnp_dark[["midnight"]]),
      plot.tag.position = "topleft"
    )
}

# ── Okabe-Ito palette (colour-blind and greyscale safe) ───────────────────────
# Reference: Okabe & Ito (2008), jfly.iam.u-tokyo.ac.jp/color/

cnnp_okabe_ito <- c(
  orange       = "#E69F00",
  sky_blue     = "#56B4E9",
  green        = "#009E73",
  yellow       = "#F0E442",
  blue         = "#0072B2",#very close to lab brand blue, use with care!
  vermillion   = "#D55E00",
  pink         = "#CC79A7",
  black        = "#111111"
)

# Structural greys — ordered faint to dark (do not use for science categories).
# For backgrounds, gridlines, reference lines, secondary data marks.
cnnp_greys <- c(
  faint    = "#F0F0F0",
  light    = "#E8E8E8",
  silver   = "#D9D9D9",
  medium   = "#CCCCCC",
  dark     = "#AAAAAA",
  charcoal = "#4D4D4D"
)

# Reserved colour-blind-safe purple, outside the Okabe-Ito 8. Use as a 9th
# categorical hue, or — as a dark/light pair — for a secondary two-level axis
# orthogonal to the main palette (in this paper, trait vs state). Distinguishable
# from the Okabe-Ito hues by colour, and from itself by lightness.
cnnp_purple <- c(
  dark  = "#6A51A3",
  light = "#BCBDDC"
)

# Brand colours: light and dark pairs of cream + teal.
cnnp_light <- c(
  cream = "#fffdef",   # panel background, soft branded fills
  teal  = "#9dc2cc"    # soft teal — secondary branded marks/outlines
)

cnnp_dark <- c(
  brown = "#3d2307",   # brand brown
  teal = "#005d76",    # teal
  midnight = "#223344"    # midnight — axis lines, ticks, text
)

# NOTE: this file holds only the reusable CNNP foundation (brand) — typography,
# the colour-blind-safe primitives above, scale machinery, and export helpers.
# It is intentionally domain-agnostic so every lab paper can source it unchanged.
#
# Paper-specific *semantic* palettes (e.g. "physical activity is always orange")
# belong in that project's own config, NOT here. Define a named colour vector in
# the project and pass it to scale_*_cnnp(). See R/config.R for this paper's.

# ── Discrete scales ───────────────────────────────────────────────────────────
# Automatic case: "give me N colour-blind-safe colours" — Okabe-Ito in order.
# Use this for any categorical aesthetic where the specific colour carries no
# fixed meaning (works for any paper, any categories, no configuration).

cnnp_pal <- function(order = names(cnnp_okabe_ito)) {
  cols <- unname(cnnp_okabe_ito[order])
  function(n) {
    if (n > length(cols))
      warning("cnnp_pal: only ", length(cols), " colour-blind-safe colours available; ",
              n, " requested.")
    cols[seq_len(n)]
  }
}

scale_colour_cnnp_d <- function(...) ggplot2::discrete_scale("colour", palette = cnnp_pal(), ...)
scale_fill_cnnp_d   <- function(...) ggplot2::discrete_scale("fill",   palette = cnnp_pal(), ...)

# Semantic case: pass a named colour vector you defined in your project, e.g.
#   scale_fill_cnnp(palette_groups)   # c(pa = "#E69F00", sleep = "#0072B2", ...)
# Use when a category must map to a fixed colour across every figure.

scale_colour_cnnp <- function(palette, ...) scale_colour_manual(values = palette, ...)
scale_fill_cnnp   <- function(palette, ...) scale_fill_manual(values = palette, ...)

# Missing-value colour for every continuous scale below: a structural grey that
# reads as "no data", distinct from any hue in the data ramps.
CNNP_NA_COLOUR <- unname(cnnp_greys["light"])

# Sequential gradient (e.g. a single-variable heatmap). Low end is white — not the
# cream panel tint — so low values never blend into a tinted panel background.
# direction = 1 → white (low) to teal (high); -1 reverses.
scale_fill_gradient_cnnp <- function(direction = 1, na.value = CNNP_NA_COLOUR, ...) {
  ends <- c("white", unname(cnnp_dark["teal"]))   # low → high
  if (direction != 1) ends <- rev(ends)
  scale_fill_gradient(low = ends[[1]], high = ends[[2]], na.value = na.value, ...)
}

scale_colour_gradient_cnnp <- function(direction = 1, na.value = CNNP_NA_COLOUR, ...) {
  ends <- c("white", unname(cnnp_dark["teal"]))
  if (direction != 1) ends <- rev(ends)
  scale_colour_gradient(low = ends[[1]], high = ends[[2]], na.value = na.value, ...)
}

# Brand sequential ramp for wide-range continuous data, where the single-hue
# white→teal scale above loses resolution at the top end. Three brand stops:
# white → light teal → dark teal. The middle stop is placed at 0.374 (not 0.5)
# because that is its CIE-L* fraction between white (L*=100) and dark teal
# (L*=36) — so perceived lightness drops *evenly* across the whole scale (both
# segments slope ≈ -64 L* per unit) instead of plateauing near the light end.
# Even lightness ⇒ greyscale-safe and colour-blind-safe. Low end is white (not
# the cream panel tint) so low values never blend in. direction = -1 reverses.
cnnp_seq_cols   <- c("white", unname(cnnp_light["teal"]), unname(cnnp_dark["teal"]))
cnnp_seq_values <- c(0, 0.374, 1)

scale_fill_seq_cnnp <- function(direction = 1, na.value = CNNP_NA_COLOUR, ...) {
  cols <- cnnp_seq_cols; vals <- cnnp_seq_values
  if (direction != 1) { cols <- rev(cols); vals <- rev(1 - vals) }
  scale_fill_gradientn(colours = cols, values = vals, na.value = na.value, ...)
}

scale_colour_seq_cnnp <- function(direction = 1, na.value = CNNP_NA_COLOUR, ...) {
  cols <- cnnp_seq_cols; vals <- cnnp_seq_values
  if (direction != 1) { cols <- rev(cols); vals <- rev(1 - vals) }
  scale_colour_gradientn(colours = cols, values = vals, na.value = na.value, ...)
}

# Diverging gradient centred on midpoint (e.g. Pearson r, z-score).
# Negative → vermillion, zero → white (fades out), positive → CNNP teal.
scale_colour_gradient2_cnnp <- function(midpoint = 0, na.value = CNNP_NA_COLOUR, ...) {
  scale_colour_gradient2(
    low      = unname(cnnp_okabe_ito["vermillion"]),
    mid      = "white",
    high     = unname(cnnp_dark["teal"]),
    midpoint = midpoint,
    na.value = na.value,
    ...
  )
}

scale_fill_gradient2_cnnp <- function(midpoint = 0, na.value = CNNP_NA_COLOUR, ...) {
  scale_fill_gradient2(
    low      = unname(cnnp_okabe_ito["vermillion"]),
    mid      = "white",
    high     = unname(cnnp_dark["teal"]),
    midpoint = midpoint,
    na.value = na.value,
    ...
  )
}

# ── Shape scale + redundant colour↔shape coding ───────────────────────────────
# Colour alone fails in greyscale/B&W print and photocopies. Redundantly encoding
# a category as BOTH colour and shape keeps it decodable. Shapes chosen to stay
# distinct at small print sizes: circle, triangle, square, diamond, plus, star…
cnnp_shapes <- c(16, 17, 15, 18, 3, 8, 7, 4)

cnnp_shape_pal <- function() {
  function(n) {
    if (n > length(cnnp_shapes))
      warning("cnnp_shape_pal: only ", length(cnnp_shapes), " distinct shapes defined; ",
              n, " requested.")
    cnnp_shapes[seq_len(n)]
  }
}

scale_shape_cnnp <- function(...) ggplot2::discrete_scale("shape", palette = cnnp_shape_pal(), ...)

# One helper for the common case: map a single category to BOTH colour and shape
# and get ONE merged legend. Map both aesthetics to the same variable, e.g.
#   ggplot(d, aes(x, y, colour = grp, shape = grp)) + geom_point() +
#     cnnp_scale_redundant(name = "group")              # automatic Okabe-Ito order
#   ... + cnnp_scale_redundant(palette_groups, name = "group")   # fixed semantic colours
# (ggplot merges the colour and shape guides because they share a name + breaks.)
cnnp_scale_redundant <- function(palette = NULL, name = ggplot2::waiver(), ...) {
  if (is.null(palette)) {
    list(
      ggplot2::discrete_scale("colour", palette = cnnp_pal(),       name = name, ...),
      ggplot2::discrete_scale("shape",  palette = cnnp_shape_pal(), name = name, ...)
    )
  } else {
    shp <- cnnp_shapes[seq_along(palette)]
    if (!is.null(names(palette))) names(shp) <- names(palette)
    list(
      scale_colour_manual(values = palette, name = name, ...),
      scale_shape_manual(  values = shp,     name = name, ...)
    )
  }
}

# ── Date axes ─────────────────────────────────────────────────────────────────
# ggplot's default date breaks crowd and overlap in narrow panels (especially at
# single-column width). scales::breaks_pretty() picks a sensible, evenly-spaced
# set of "nice" dates and adapts the count to the axis. n = target break count.
#   p + scale_x_date_cnnp()                       # ~5 tidy breaks
#   p + scale_x_date_cnnp(n = 4, date_labels = "%Y")
scale_x_date_cnnp <- function(n = 5, ...) {
  scale_x_date(breaks = scales::breaks_pretty(n = n), ...)
}

scale_x_datetime_cnnp <- function(n = 5, ...) {
  scale_x_datetime(breaks = scales::breaks_pretty(n = n), ...)
}

# ── Multi-panel composition (patchwork) ───────────────────────────────────────
# theme_cnnp() is a ggplot *theme* object, so it cannot carry a patchwork layout
# (a different object type). Guide collection — folding one shared legend out of
# the per-panel duplicates — therefore lives in this helper. Compose panels as
# usual with patchwork, then add it:
#   (p1 | p2) / p3 + cnnp_collect_guides()
#
# axis_titles = "collect" is on by default: it keeps each axis title pinned to its
# own tick labels (otherwise a tall shared legend stretches the cell and patchwork
# drops the x-title to the cell bottom, leaving a gap), and de-duplicates titles
# that are shared across panels. Override via ... (e.g. axis_titles = "keep").
# Pass-through ... forwards to plot_layout() (e.g. widths, heights, ncol).
cnnp_collect_guides <- function(guides = "collect", axis_titles = "collect", ...) {
  if (!requireNamespace("patchwork", quietly = TRUE))
    stop("cnnp_collect_guides() needs the 'patchwork' package.")
  patchwork::plot_layout(guides = guides, axis_titles = axis_titles, ...)
}

# Theme for the patchwork wrapper itself — pass to plot_annotation(theme = ...).
# Same as theme_cnnp() but with a WHITE outer background, so the figure-level
# supertitle and the margin around the panels sit on white, while each panel
# stays a cream card. Without this the supertitle would sit on a cream strip.
#   ... + plot_annotation(title = "Figure 1", theme = cnnp_annotation_theme())
cnnp_annotation_theme <- function(...) {
  theme_cnnp(...) %+replace%
    theme(plot.background = element_rect(fill = "white", colour = NA),
          plot.margin     = margin(2, 2, 2, 2, "pt"))
}

# ── Figure export ─────────────────────────────────────────────────────────────
# Standard journal column widths in millimetres. Save figures at their true
# final width so theme_cnnp()'s point sizes print at their nominal pt values.

cnnp_widths <- c(
  single  = 90,    # single column
  onehalf = 140,   # 1.5 columns
  double  = 190    # full page width
)

# The base-14 PDF font only covers Latin-1, so non-Latin-1 glyphs (em/en dashes,
# smart quotes, ellipsis) are silently substituted by pdf() — and worse, differ
# from the ragg TIFF/PNG output. cnnp_ascii() folds the common offenders down to
# safe ASCII so the same text renders identically in every format. Use it on any
# label you build by hand (facet labels, in-panel geom_text); ggsave_cnnp() also
# applies it automatically to a ggplot's titles/axis/legend labels before writing
# PDF. (Middot "·" is in Latin-1 and renders fine, so it is left untouched.)
cnnp_ascii <- function(x) {
  if (!is.character(x)) return(x)
  repl <- c("—" = "-", "–" = "-", "−" = "-",   # em / en / minus dash
            "‘" = "'", "’" = "'",                     # smart single quotes
            "“" = '"', "”" = '"',                     # smart double quotes
            "…" = "...")                                    # ellipsis
  for (from in names(repl)) x <- gsub(from, repl[[from]], x, fixed = TRUE)
  x
}

# Best-effort: fold a plain ggplot's labels (title/subtitle/caption/axis/legend)
# to ASCII for the PDF device. No-op on anything else (e.g. patchwork), so it
# never breaks a save; hand-build patchwork/facet/in-panel text with cnnp_ascii().
cnnp_sanitize_labels <- function(plot) {
  tryCatch({
    # In ggplot2 4.x plot$labels is an S7 object whose validator rejects a plain
    # list, so re-apply the folded labels through labs() (which builds the proper
    # object). as.list() is needed because lapply won't iterate the S7 fields.
    if (inherits(plot, "ggplot") && length(plot$labels)) {
      folded <- lapply(as.list(plot$labels), cnnp_ascii)
      plot <- plot + do.call(ggplot2::labs, folded)
    }
    plot
  }, error = function(e) plot)
}

# Save a ggplot at a fixed physical size, as vector PDF and/or 300 dpi RGB TIFF.
#   width   : millimetres, or a name from cnnp_widths ("single"/"onehalf"/"double")
#   height  : millimetres; if NULL, derived from width * aspect
#   formats : any of "pdf", "tiff", "png"
# The base font is a PDF base-14 font, so the standard pdf() device renders it
# with no embedding/cairo. TIFF/PNG route to ragg, which renders system fonts and
# supports LZW compression.
ggsave_cnnp <- function(plot, filename, out_dir = ".",
                        width = "onehalf", height = NULL, aspect = 0.75,
                        dpi = 300, formats = c("pdf", "tiff")) {
  if (is.character(width)) width <- unname(cnnp_widths[[width]])
  if (is.null(height)) height <- width * aspect

  for (fmt in formats) {
    path <- file.path(out_dir, paste0(filename, ".", fmt))
    if (fmt == "tiff") {
      ggsave(path, plot = plot, width = width, height = height, units = "mm",
             dpi = dpi, device = "tiff", compression = "lzw", bg = "white")
    } else {
      # PDF uses the base-14 device: fold labels to ASCII so glyphs don't get
      # silently substituted (and stay consistent with the ragg raster output).
      pdf_plot <- if (fmt == "pdf") cnnp_sanitize_labels(plot) else plot
      ggsave(path, plot = pdf_plot, width = width, height = height, units = "mm",
             dpi = dpi, device = fmt, bg = "white")
    }
  }
  invisible(plot)
}

# ── In-panel label defaults ───────────────────────────────────────────────────
# Text drawn *inside* the panel (geom_text / annotate("text")) is a layer, not a
# theme element, so theme_cnnp() can't style it. These constants are the single
# source of truth: the geom_text/geom_label defaults below reference them, and
# annotate() calls (which bypass geom defaults) reference them directly. Colour
# matches the axis chrome so labels and axes stay in lockstep.
CNNP_LABEL_COLOUR <- unname(cnnp_dark["midnight"])
CNNP_LABEL_SIZE   <- 2.6

# ── Geom defaults ─────────────────────────────────────────────────────────────
# Call once per session after sourcing this file to give every geom a neutral
# default look (structural greys). Mapped/explicit aesthetics always override
# these. Opt-in — not called on source.

cnnp_set_geom_defaults <- function() {
  update_geom_defaults("bar",     list(fill = unname(cnnp_light["teal"]), colour = "white", linewidth = 0.2))
  update_geom_defaults("col",     list(fill = unname(cnnp_light["teal"]), colour = "white", linewidth = 0.2))
  # boxplot: dark outline (not white) so whiskers/staples stay visible where they
  # cross the cream panel; the teal fill still reads as the box body.
  update_geom_defaults("boxplot", list(fill = unname(cnnp_light["teal"]), colour = unname(cnnp_dark["midnight"]), linewidth = 0.25))
  update_geom_defaults("point",      list(colour = unname(cnnp_dark["teal"]), size = 1.2))
  update_geom_defaults("line",       list(colour = unname(cnnp_dark["teal"]), linewidth = 0.5))
  # smooth: branded line over a faint grey confidence ribbon (was default grey60).
  update_geom_defaults("smooth",     list(colour = unname(cnnp_dark["teal"]), fill = unname(cnnp_greys["silver"]), linewidth = 0.5))
  # reference lines default to a structural grey so they recede behind the data.
  update_geom_defaults("hline",   list(colour = unname(cnnp_greys["dark"]), linewidth = 0.25))
  update_geom_defaults("vline",   list(colour = unname(cnnp_greys["dark"]), linewidth = 0.25))
  update_geom_defaults("abline",  list(colour = unname(cnnp_greys["dark"]), linewidth = 0.25))
  update_geom_defaults("segment", list(colour = unname(cnnp_greys["dark"]), linewidth = 0.25))
  # distributions and filled areas: teal body, with the same dark/white framing
  # logic as the bars and boxes above.
  update_geom_defaults("violin",    list(fill = unname(cnnp_light["teal"]), colour = unname(cnnp_dark["midnight"]), linewidth = 0.25))
  update_geom_defaults("histogram", list(fill = unname(cnnp_light["teal"]), colour = "white", linewidth = 0.2))
  update_geom_defaults("area",      list(fill = unname(cnnp_light["teal"]), colour = NA))
  update_geom_defaults("ribbon",    list(fill = unname(cnnp_greys["silver"]), colour = NA))
  update_geom_defaults("density",   list(fill = NA, colour = unname(cnnp_dark["teal"]), linewidth = 0.5))
  update_geom_defaults("freqpoly",  list(colour = unname(cnnp_dark["teal"]), linewidth = 0.5))
  update_geom_defaults("step",      list(colour = unname(cnnp_dark["teal"]), linewidth = 0.5))
  update_geom_defaults("rug",       list(colour = unname(cnnp_dark["teal"]), linewidth = 0.3))
  update_geom_defaults("tile",      list(fill = unname(cnnp_light["teal"]), colour = NA))
  update_geom_defaults("errorbar",   list(colour = unname(cnnp_dark["teal"]), linewidth = 0.4))
  update_geom_defaults("linerange",  list(colour = unname(cnnp_dark["teal"]), linewidth = 0.4))
  update_geom_defaults("pointrange", list(colour = unname(cnnp_dark["teal"]), linewidth = 0.4))
  update_geom_defaults("crossbar",   list(colour = unname(cnnp_dark["teal"]), linewidth = 0.4))
  update_geom_defaults("text",       list(colour = CNNP_LABEL_COLOUR, size = CNNP_LABEL_SIZE))
  update_geom_defaults("label",      list(colour = CNNP_LABEL_COLOUR, size = CNNP_LABEL_SIZE))
}
