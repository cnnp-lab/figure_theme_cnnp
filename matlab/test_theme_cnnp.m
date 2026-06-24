% test_theme_cnnp.m — surface the CNNP MATLAB (gramm) adapter across common
% plot types, mirroring the R gallery (test_theme_cnnp.R) as far as gramm allows.
%
% Renders a small gallery at the journal widths via cnnp_export(), so it doubles
% as a check of the real export path. Uses only built-in datasets (carsmall /
% carbig / fisheriris) so it makes no assumptions about the lab's science.
%
%   cd matlab; test_theme_cnnp
%
% Output: matlab/test_out/*.pdf + *.png
%
% Requirements: MATLAB R2018b+ and gramm on the path
% (https://github.com/piermorel/gramm).

% --- ensure gramm is available ---
if exist('gramm', 'class') ~= 8
    GRAMM_DIR = '';   % <- set to your gramm folder if not already on the path
    if ~isempty(GRAMM_DIR), addpath(GRAMM_DIR); end
    assert(exist('gramm', 'class') == 8, ...
        'gramm not found on the path. Install it and add it, or set GRAMM_DIR.');
end

here    = fileparts(mfilename('fullpath'));
out_dir = fullfile(here, 'test_out');

T = cnnp_load_tokens();
cnnp_set_session_defaults(T);     % apply-once-per-session neutrals (groot)

% ── Figure 1 — SINGLE column: scatter + linear fit, discrete Okabe-Ito ─────────
% Surfaces: discrete colour legend, stat_glm CI band, title/axis names.
load carsmall Weight MPG Cylinders
keep = ~isnan(Weight) & ~isnan(MPG);
cyl  = categorical(Cylinders(keep));

g1 = gramm('x', Weight(keep), 'y', MPG(keep), 'color', cyl);
g1.geom_point();
g1.stat_glm('distribution', 'normal', 'geom', 'area');   % linear fit + CI band
g1.set_names('x', 'weight (lb)', 'y', 'miles per gallon', 'color', 'cylinders');
g1.set_title('Fuel economy vs. weight');
g1 = cnnp_style(g1, T, 'palette', 'okabe_ito');
draw_and_theme(g1, T);
cnnp_export(g1, T, 'fig1_scatter', out_dir, 'width', 'single', 'aspect', 0.85);

% ── Figure 2 — ONE-HALF column: faceted boxplot + jitter ───────────────────────
% Surfaces: facet_wrap strips, inter-panel gutters, boxplot + jittered points.
load fisheriris                      % meas (150x4), species (150x1 cellstr)
sl = meas(:,1); pl = meas(:,3);
pw_class = repmat({'narrow petal'}, size(meas,1), 1);
pw_class(meas(:,4) > median(meas(:,4))) = {'wide petal'};

g2 = gramm('x', species, 'y', pl, 'color', species);
g2.facet_wrap(pw_class, 'ncols', 2);
g2.stat_boxplot('width', 0.6);
g2.geom_jitter('width', 0.3, 'dodge', 0);
g2.set_names('x', '', 'y', 'petal length (cm)', 'color', 'species', 'column', '');
g2.set_title('Petal length by species, split by petal width');
g2 = cnnp_style(g2, T, 'palette', 'okabe_ito');
draw_and_theme(g2, T);
cnnp_export(g2, T, 'fig2_facet_box', out_dir, 'width', 'onehalf', 'aspect', 0.55);

% ── Figure 3 — SINGLE column: brand pairs as colour x lightness ────────────────
% Surfaces: the cnnp_pairs palette (teal/mustard/purple, dark=primary), driven
% by gramm's colour x lightness model — 3 colours x 2 lightness = 6 series.
pair_names = {'teal', 'mustard', 'purple'};
cond_names = {'1 primary', '2 secondary'};   % numeric prefix forces dark-first order
xx = []; yy = []; cc = {}; ll = {};
base = [3 5 4 6 5 7];
for ci = 1:3
    for li = 1:2
        x = (1:6)';
        y = base' + ci*0.6 - (li-1)*1.5 + 0.3*sin(x);
        xx = [xx; x];                       %#ok<AGROW>
        yy = [yy; y];                       %#ok<AGROW>
        cc = [cc; repmat(pair_names(ci), 6, 1)];   %#ok<AGROW>
        ll = [ll; repmat(cond_names(li),  6, 1)];  %#ok<AGROW>
    end
end
g3 = gramm('x', xx, 'y', yy, 'color', cc, 'lightness', ll);
g3.geom_line();
g3.geom_point();
g3.set_names('x', 'time', 'y', 'response', 'color', 'pair', 'lightness', 'role');
g3.set_title('Brand pairs: dark = primary, light = secondary');
g3 = cnnp_style(g3, T, 'palette', 'pairs');
draw_and_theme(g3, T);
cnnp_export(g3, T, 'fig3_pairs', out_dir, 'width', 'single', 'aspect', 0.85);

% ── Figure 4 — SINGLE column: sequential continuous colour (white -> teal) ─────
% Surfaces: continuous colourbar with the CNNP sequential ramp (Lab-interpolated).
g4 = gramm('x', Weight(keep), 'y', MPG(keep), 'color', Weight(keep));
g4.geom_point();
g4.set_names('x', 'weight (lb)', 'y', 'miles per gallon', 'color', 'weight');
g4.set_title('Sequential colour (white -> teal)');
g4 = cnnp_style(g4, T, 'palette', 'okabe_ito');     % text/line/point tokens
g4 = cnnp_continuous(g4, 'seq');                    % overrides colour -> sequential
draw_and_theme(g4, T);
cnnp_export(g4, T, 'fig4_sequential', out_dir, 'width', 'single', 'aspect', 0.85);

% ── Figure 5 — SINGLE column: diverging continuous colour (vermillion<->teal) ──
% Surfaces: diverging ramp centred on white, symmetric colour limits.
accel = MPG(keep) - mean(MPG(keep));                % signed, centred on 0
lim   = max(abs(accel));
g5 = gramm('x', Weight(keep), 'y', MPG(keep), 'color', accel);
g5.geom_point();
g5.set_names('x', 'weight (lb)', 'y', 'miles per gallon', 'color', 'mpg - mean');
g5.set_title('Diverging colour (vermillion <-> white <-> teal)');
g5 = cnnp_style(g5, T, 'palette', 'okabe_ito');
g5 = cnnp_continuous(g5, 'div', 'CLim', [-lim lim]);
draw_and_theme(g5, T);
cnnp_export(g5, T, 'fig5_diverging', out_dir, 'width', 'single', 'aspect', 0.85);

% ── Figure 6 — SINGLE column: many categories, Okabe-Ito bar ───────────────────
% Surfaces: counts per category with the categorical palette cycling through
% several hues, rotated x labels.
clear MPG
load carbig Origin
origin = cellstr(Origin);
[countries, ~, idx] = unique(origin);
counts = accumarray(idx, 1);                 % rows per country -> explicit bar height
g6 = gramm('x', countries, 'y', counts, 'color', countries);
g6.geom_bar('EdgeColor', 'none');             % clean, edgeless bars
g6.set_names('x', '', 'y', 'count', 'color', 'origin');
g6.set_title('Counts by origin (Okabe-Ito)');
g6.no_legend();
g6 = cnnp_style(g6, T, 'palette', 'okabe_ito');
draw_and_theme(g6, T);
cnnp_export(g6, T, 'fig6_bar', out_dir, 'width', 'single', 'aspect', 0.85);

fprintf('Done. Wrote gallery to %s\n', out_dir);
cnnp_reset_defaults();

% ── local helper: draw on a white figure, then apply the CNNP chrome ───────────
function draw_and_theme(g, T)
    figure('Color', 'w', 'Units', 'centimeters', 'Position', [2 2 18 12]);
    g.draw();
    cnnp_theme_axes(g, T);
end
