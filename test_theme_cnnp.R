# ──────────────────────────────────────────────────────────────────────────────
# test_theme_cnnp.R — surface the CNNP theme across common plot elements.
#
# Renders a small gallery at the three journal widths (single 90 / onehalf 140 /
# double 190 mm) using ggsave_cnnp(), so this doubles as a check of the real
# export path. Uses only built-in datasets (mtcars/iris/economics/diamonds) so
# it makes no assumptions about the lab's science.
#
#   Rscript test_theme_cnnp.R
#
# Output: ./test_out/*.pdf and *.tiff
# ──────────────────────────────────────────────────────────────────────────────

source("theme_cnnp.R")

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

set.seed(1)
out_dir <- "test_out"
dir.create(out_dir, showWarnings = FALSE)

# Apply the lab's neutral geom defaults (opt-in in the theme).
cnnp_set_geom_defaults()

# A reusable semantic palette, the way a real project would define one and pass
# it to scale_*_cnnp(). (Generic categories here.)
pal_cyl <- c("4" = unname(cnnp_okabe_ito["orange"]),
             "6" = unname(cnnp_okabe_ito["sky_blue"]),
             "8" = unname(cnnp_okabe_ito["vermillion"]))

mtc <- transform(mtcars,
                 cyl  = factor(cyl),
                 gear = factor(gear, labels = c("3 gears", "4 gears", "5 gears")),
                 am   = factor(am, labels = c("automatic", "manual")))

# ══ Figure 1 — SINGLE column (90 mm): scatter + smooth + discrete legend ═══════
# Surfaces: discrete colour legend, geom_smooth ribbon, in-panel annotation,
# reference line, title/subtitle/caption.
f1 <- ggplot(mtc, aes(wt, mpg, colour = cyl)) +
  geom_hline(yintercept = mean(mtc$mpg), linetype = "dashed") +  # default grey now
  geom_smooth(method = "lm", se = TRUE, formula = y ~ x, linewidth = 0.5) +
  geom_point(size = 1.4) +
  annotate("text", x = 4.5, y = 30, label = "mean mpg", hjust = 1) +
  scale_colour_cnnp(pal_cyl, name = "cylinders") +
  labs(title = "Fuel economy vs. weight",
       subtitle = "Single column · 90 mm",
       x = "weight (1000 lb)", y = "miles per gallon",
       caption = "source: mtcars") +
  theme_cnnp()

# ══ Figure 2 — ONE-HALF column (140 mm): faceted multi-panel ═══════════════════
# Surfaces: facet_wrap strips, panel.spacing, boxplot + jitter, rotated axis.
f2 <- ggplot(mtc, aes(am, mpg)) +
  geom_boxplot(outlier.shape = NA, width = 0.6) +
  geom_jitter(aes(colour = cyl), width = 0.15, height = 0, size = 1) +
  facet_wrap(~ gear) +
  scale_colour_cnnp(pal_cyl, name = "cylinders") +
  labs(title = "Economy by transmission, split by gear count",
       subtitle = "One-half column · 140 mm — facet strips",
       x = NULL, y = "miles per gallon") +
  theme_cnnp()

# ══ Figure 3 — DOUBLE column (190 mm): patchwork gallery A–F ═══════════════════
# Each sub-panel exercises a different common element. plot_annotation adds A/B/C
# tags (uses theme plot.tag).

# (A) iris scatter + smooth, semantic 3-colour
pal_sp <- c(setosa     = unname(cnnp_okabe_ito["orange"]),
            versicolor = unname(cnnp_okabe_ito["sky_blue"]),
            virginica  = unname(cnnp_okabe_ito["green"]))
A <- ggplot(iris, aes(Sepal.Length, Petal.Length, colour = Species)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 0.5) +
  scale_colour_cnnp(pal_sp) +
  labs(x = "sepal length", y = "petal length") +
  theme_cnnp()

# (B) bar chart with auto discrete fill (Okabe-Ito in order)
B <- ggplot(mtc, aes(gear, fill = cyl)) +
  geom_bar(position = "dodge") +
  scale_fill_cnnp(pal_cyl, name = "cyl") +
  labs(x = NULL, y = "count") +
  theme_cnnp()

# (C) time series line
C <- ggplot(economics, aes(date, unemploy / 1000)) +
  geom_line() +
  scale_x_date_cnnp(n = 4) +                       # tidy, uncrowded date breaks
  labs(x = NULL, y = "unemployed (millions)") +
  theme_cnnp()

# (D) sequential gradient heatmap (white→teal), continuous colourbar
diamonds_tab <- as.data.frame(with(diamonds, table(cut, color)))
D <- ggplot(diamonds_tab, aes(color, cut, fill = Freq)) +
  geom_tile(colour = "white", linewidth = 0.3) +
  scale_fill_gradient_cnnp(name = "n") +
  labs(x = "colour", y = "cut") +
  theme_cnnp()

# (E) diverging gradient — correlation matrix (vermillion↔white↔teal)
cm <- cor(mtcars[, c("mpg","disp","hp","drat","wt","qsec")])
cm_df <- data.frame(
  v1 = rep(rownames(cm), times = ncol(cm)),
  v2 = rep(colnames(cm), each  = nrow(cm)),
  r  = as.vector(cm))
E <- ggplot(cm_df, aes(v1, v2, fill = r)) +
  geom_tile(colour = "white", linewidth = 0.3) +
  scale_fill_gradient2_cnnp(name = "r", limits = c(-1, 1)) +
  labs(x = NULL, y = NULL) +
  theme_cnnp() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# (F) coefficient / forest plot — pointrange with error bars + zero line
fit <- lm(mpg ~ wt + hp + drat + qsec + am, data = mtcars)
co  <- as.data.frame(summary(fit)$coefficients)
co  <- co[rownames(co) != "(Intercept)", ]
co$term <- rownames(co)
co$lo <- co$Estimate - 1.96 * co$`Std. Error`
co$hi <- co$Estimate + 1.96 * co$`Std. Error`
F <- ggplot(co, aes(Estimate, reorder(term, Estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed") +  # default grey now
  geom_pointrange(aes(xmin = lo, xmax = hi), size = 0.3) +
  labs(x = "beta (95% CI)", y = NULL) +
  theme_cnnp()

# NB: NOT using cnnp_collect_guides() here — every panel has a *different* legend
# (Species, cyl, n, r), so collecting them would stack all four into one tall
# column that overflows the figure. guides="collect" pays off when panels SHARE a
# legend (it dedupes to one); with all-distinct legends, per-panel is cleaner.
fig3 <- (A | B | C) / (D | E | F) +
  plot_annotation(
    tag_levels = "A",
    # patchwork titles bypass the auto-sanitizer, so fold by hand:
    title = cnnp_ascii("Gallery — double column · 190 mm"),
    theme = cnnp_annotation_theme()   # supertitle + outer margin on white
  )

# ══ Figure 4 — DOUBLE column (190 mm): pass-2 capabilities gallery ═════════════
# Surfaces: redundant colour+shape coding, violin, density, histogram,
# area+ribbon, and the multi-hue sequential ramp.

# (G) redundant colour+shape — ONE merged legend, decodes in greyscale.
G <- ggplot(iris, aes(Sepal.Length, Petal.Length, colour = Species, shape = Species)) +
  geom_point(size = 1.3) +
  cnnp_scale_redundant(pal_sp, name = "species") +
  labs(title = "redundant colour + shape", x = "sepal length", y = "petal length") +
  theme_cnnp()

# (H) violin + jitter (new violin default: teal body, dark outline)
H <- ggplot(iris, aes(Species, Sepal.Width)) +
  geom_violin() +
  geom_jitter(width = 0.12, height = 0, size = 0.7, colour = cnnp_dark[["midnight"]]) +
  labs(title = "violin", x = NULL, y = "sepal width") +
  theme_cnnp() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# (I) density by group. key_glyph = "path" makes the legend draw LINES, not the
# default outlined boxes (the density geom's key is a filled polygon otherwise).
I <- ggplot(iris, aes(Sepal.Length, colour = Species)) +
  geom_density(linewidth = 0.6, key_glyph = "path") +
  scale_colour_cnnp(pal_sp, name = "species") +
  labs(title = "density", x = "sepal length", y = "density") +
  theme_cnnp()

# (J) histogram (new default teal fill, white separators)
J <- ggplot(iris, aes(Petal.Length)) +
  geom_histogram(bins = 20) +
  labs(title = "histogram", x = "petal length", y = "count") +
  theme_cnnp()

# (K) area + ribbon (defaults: teal area, silver ribbon)
econ <- transform(economics, u = unemploy / 1000)
econ$lo <- econ$u * 0.93; econ$hi <- econ$u * 1.07
K <- ggplot(econ, aes(date)) +
  geom_ribbon(aes(ymin = lo, ymax = hi)) +
  geom_line(aes(y = u)) +
  scale_x_date_cnnp(n = 4) +
  labs(title = "ribbon + line", x = NULL, y = "unemployed (M)") +
  theme_cnnp()

# (L) multi-hue sequential ramp + an explicit NA cell (na.value)
na_tab <- diamonds_tab
na_tab$Freq[c(3, 11, 19, 27)] <- NA          # show the na.value colour
L <- ggplot(na_tab, aes(color, cut, fill = Freq)) +
  geom_tile(colour = "white", linewidth = 0.3) +
  scale_fill_seq_cnnp(name = "n") +
  labs(title = "sequential + NA", x = "colour", y = "cut") +
  theme_cnnp()

fig4 <- (G | H | I) / (J | K | L) +
  cnnp_collect_guides() +
  plot_annotation(
    tag_levels = "A",
    # supertitle (figure-level) + subtitle, to compare against the cream panel
    # titles. cnnp_annotation_theme() keeps the supertitle on WHITE, not cream.
    title    = cnnp_ascii("Pass-2 capabilities gallery"),
    subtitle = cnnp_ascii("Double column · 190 mm — supertitle on white, panel titles on cream"),
    theme    = cnnp_annotation_theme()
  )

# ══ Figure 5 — SINGLE column (90 mm): redundant coding, standalone ═════════════
# The flagship pass-2 feature at true single-column size, so we can judge whether
# the shapes stay distinct when small.
f5 <- ggplot(iris, aes(Sepal.Length, Petal.Length, colour = Species, shape = Species)) +
  geom_point(size = 1.4) +
  cnnp_scale_redundant(pal_sp, name = "species") +
  labs(title = "Redundant colour + shape",
       subtitle = "Single column · 90 mm",
       x = "sepal length", y = "petal length") +
  theme_cnnp()

# ══ Render via the real export helper ══════════════════════════════════════════
message("Rendering to ", normalizePath(out_dir), " …")
ggsave_cnnp(f1,   "fig1_single",   out_dir, width = "single",  aspect = 0.85)
ggsave_cnnp(f2,   "fig2_onehalf",  out_dir, width = "onehalf", aspect = 0.55)
ggsave_cnnp(fig3, "fig3_double",   out_dir, width = "double",  aspect = 0.60)
ggsave_cnnp(fig4, "fig4_double",   out_dir, width = "double",  aspect = 0.60)
ggsave_cnnp(f5,   "fig5_single",   out_dir, width = "single",  aspect = 0.85)
message("Done. Files:")
print(list.files(out_dir, full.names = TRUE))
