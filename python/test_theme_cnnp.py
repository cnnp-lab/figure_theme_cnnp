"""Gallery for the CNNP matplotlib adapter, mirroring the R and MATLAB galleries.

Renders a small set of figures at the journal widths via cnnp_savefig(), so it
also exercises the export path. Uses only synthetic (seeded) data so it makes no
assumptions about the lab's science and runs fully offline.

Run:  uv run python test_theme_cnnp.py     ->  python/test_out/*.pdf + *.png
"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

import cnnp_theme as cnnp

OUT = Path(__file__).parent / "test_out"
rng = np.random.default_rng(1)

tok = cnnp.use_cnnp()                     # apply the theme once
okabe = cnnp.okabe_cycle(tok)


# ── Figure 1 — SINGLE column: scatter + linear fit, discrete Okabe-Ito ─────────
def fig1_scatter():
    fig, ax = plt.subplots()
    bases = {"4 cyl": (2200, 30), "6 cyl": (3200, 22), "8 cyl": (4000, 15)}
    for i, (label, (w0, m0)) in enumerate(bases.items()):
        w = w0 + rng.normal(0, 350, 22)
        m = m0 - 0.004 * (w - w0) + rng.normal(0, 1.8, 22)
        ax.scatter(w, m, s=tok.marker_size_pt ** 2, color=okabe[i], label=label)
        b, a = np.polyfit(w, m, 1)
        xs = np.array([w.min(), w.max()])
        ax.plot(xs, a + b * xs, color=okabe[i], linewidth=tok.line_weights_pt["thin"])
    ax.set(xlabel="weight (lb)", ylabel="miles per gallon", title="Fuel economy vs. weight")
    ax.legend(title="cylinders")
    cnnp.cnnp_theme_ax(ax, tok)
    cnnp.cnnp_savefig(fig, "fig1_scatter", OUT, width="single", aspect=0.85, tokens=tok)
    plt.close(fig)


# ── Figure 2 — ONE-HALF column: faceted boxplot ────────────────────────────────
def fig2_facet_box():
    species = ["setosa", "versicolor", "virginica"]
    centres = [1.5, 4.2, 5.6]
    fig, axes = plt.subplots(1, 2, sharey=True)
    for f, (ax, facet) in enumerate(zip(axes, ["narrow petal", "wide petal"])):
        data = [rng.normal(c + 0.4 * f, 0.4, 40) for c in centres]
        bp = ax.boxplot(data, patch_artist=True, widths=0.6,
                        medianprops=dict(color=tok.neutral["midnight"]),
                        flierprops=dict(marker="o", markersize=2,
                                        markerfacecolor=tok.greys["dark"],
                                        markeredgecolor="none"))
        for patch, col in zip(bp["boxes"], okabe):
            patch.set_facecolor(col)
            patch.set_edgecolor(tok.neutral["midnight"])
        ax.set_xticks(range(1, len(species) + 1), species, rotation=20, ha="right")
        ax.set_title(facet)
        cnnp.cnnp_theme_ax(ax, tok)
    axes[0].set_ylabel("petal length (cm)")
    fig.suptitle("Petal length by species, split by petal width")
    cnnp.cnnp_savefig(fig, "fig2_facet_box", OUT, width="onehalf", aspect=0.55, tokens=tok)
    plt.close(fig)


# ── Figure 3 — SINGLE column: brand pairs (dark = primary, light = secondary) ──
def fig3_pairs():
    fig, ax = plt.subplots()
    x = np.arange(1, 7)
    darks = cnnp.pair_palette(role="dark", tokens=tok)
    lights = cnnp.pair_palette(role="light", tokens=tok)
    for i, name in enumerate(tok.pair_names):
        trend = 3 + 0.6 * x + 0.6 * i
        ax.plot(x, trend, color=darks[i], marker="o", label=f"{name} primary")
        ax.plot(x, trend - 1.4, color=lights[i], marker="o", label=f"{name} secondary")
    ax.set(xlabel="time", ylabel="response",
           title="Brand pairs: dark = primary, light = secondary")
    ax.legend(ncols=3, fontsize=tok.base_size_pt * 0.8)
    cnnp.cnnp_theme_ax(ax, tok)
    cnnp.cnnp_savefig(fig, "fig3_pairs", OUT, width="single", aspect=0.85, tokens=tok)
    plt.close(fig)


# ── Figures 4 & 5 — continuous colour: sequential and diverging ────────────────
def fig45_continuous():
    w = 2000 + rng.uniform(0, 2700, 120)
    m = 45 - 0.009 * (w - 2000) + rng.normal(0, 2.5, 120)

    fig, ax = plt.subplots()
    sc = ax.scatter(w, m, c=w, cmap="cnnp_seq", s=tok.marker_size_pt ** 2)
    ax.set(xlabel="weight (lb)", ylabel="miles per gallon",
           title="Sequential colour (white -> teal)")
    fig.colorbar(sc, ax=ax, label="weight")
    cnnp.cnnp_theme_ax(ax, tok)
    cnnp.cnnp_savefig(fig, "fig4_sequential", OUT, width="single", aspect=0.85, tokens=tok)
    plt.close(fig)

    centred = m - m.mean()
    lim = np.abs(centred).max()
    fig, ax = plt.subplots()
    sc = ax.scatter(w, m, c=centred, cmap="cnnp_div", vmin=-lim, vmax=lim,
                    s=tok.marker_size_pt ** 2)
    ax.set(xlabel="weight (lb)", ylabel="miles per gallon",
           title="Diverging colour (vermillion <-> white <-> teal)")
    fig.colorbar(sc, ax=ax, label="mpg - mean")
    cnnp.cnnp_theme_ax(ax, tok)
    cnnp.cnnp_savefig(fig, "fig5_diverging", OUT, width="single", aspect=0.85, tokens=tok)
    plt.close(fig)


# ── Figure 6 — SINGLE column: many categories, via SEABORN (integration check) ─
def fig6_seaborn():
    """Built with seaborn to prove the theme carries through sns.set_theme()."""
    try:
        import pandas as pd
        import seaborn as sns
    except ImportError:
        print("  (skipping fig6: seaborn/pandas not installed — `uv sync --extra seaborn`)")
        return

    from cnnp_theme.seaborn import cnnp_seaborn
    cnnp_seaborn(tok)                      # switch to the seaborn entry point

    countries = ["England", "France", "Germany", "Italy", "Japan", "Sweden", "USA"]
    counts = [1, 14, 39, 8, 79, 11, 254]
    df = pd.DataFrame({"origin": countries, "count": counts})

    fig, ax = plt.subplots()
    sns.barplot(df, x="origin", y="count", hue="origin", palette=okabe,
                legend=False, ax=ax)
    ax.set(xlabel="", ylabel="count", title="Counts by origin (Okabe-Ito) - seaborn")
    ax.tick_params(axis="x", rotation=30)
    cnnp.cnnp_theme_ax(ax, tok)
    cnnp.cnnp_savefig(fig, "fig6_bar_seaborn", OUT, width="single", aspect=0.85, tokens=tok)
    plt.close(fig)


if __name__ == "__main__":
    fig1_scatter()
    fig2_facet_box()
    fig3_pairs()
    fig45_continuous()
    fig6_seaborn()
    print(f"Done. Wrote gallery to {OUT}")
