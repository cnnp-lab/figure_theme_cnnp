function g = cnnp_style(g, T, varargin)
%CNNP_STYLE  Apply CNNP brand tokens to a gramm object (before draw()).
%
%   g = cnnp_style(g, T) sets gramm's colour/text/line/point options from the
%   tokens T (from CNNP_LOAD_TOKENS). The figure CHROME (cream cards, midnight
%   axes, no gridlines) cannot be set through gramm options — apply it AFTER
%   g.draw() with CNNP_THEME_AXES(g, T).
%
%   Name-value:
%     'palette'  'okabe_ito' (default) — many categorical levels, Okabe-Ito
%                'pairs'               — brand teal/mustard/purple as
%                                        color x lightness (map a 'color' AND a
%                                        'lightness' aesthetic in gramm)
%
%   Typical use:
%     T = cnnp_load_tokens();
%     g = gramm('x', x, 'y', y, 'color', grp);
%     g.geom_point();
%     g = cnnp_style(g, T);
%     figure('Color','w'); g.draw();
%     cnnp_theme_axes(g, T);

    p = inputParser;
    addParameter(p, 'palette', 'okabe_ito');
    parse(p, varargin{:});

    % ── colour: inject a custom RGB map (gramm expects rows ordered
    %    color#1/light#1, color#1/light#2, ...; n_color * n_lightness = rows) ──
    switch p.Results.palette
        case 'okabe_ito'
            g.set_color_options('map', T.okabe_rgb, ...
                'n_color', size(T.okabe_rgb, 1), 'n_lightness', 1);
        case 'pairs'
            g.set_color_options('map', T.pairs_rgb, ...
                'n_color', numel(T.pair_names), 'n_lightness', 2, ...
                'legend', 'separate');
            % The pairs map rows are in priority order (teal, mustard, purple)
            % x (dark, light). gramm otherwise orders the colour and lightness
            % factors alphabetically, which scrambles which group gets which
            % pair. Bind them positionally by order of APPEARANCE instead: the
            % 1st colour level -> teal, 2nd -> mustard, 3rd -> purple; the 1st
            % lightness level -> dark (primary), 2nd -> light (secondary).
            g.set_order_options('color', 0, 'lightness', 0);
        otherwise
            error('cnnp_style: unknown palette "%s"', p.Results.palette);
    end

    % ── typography: gramm base_size is the axis-tick text size; the *_scaling
    %    parameters are ratios relative to it — exactly our typography.scale. ──
    g.set_text_options( ...
        'base_size',            T.base_size_pt, ...
        'label_scaling',        T.scale.axis_title, ...
        'legend_scaling',       T.scale.legend_text, ...
        'legend_title_scaling', T.scale.legend_title, ...
        'facet_scaling',        T.scale.strip_text, ...
        'title_scaling',        T.scale.plot_title, ...
        'big_title_scaling',    T.scale.plot_title, ...
        'font',                 T.font_prefer{1});

    % ── line widths (points, native) — gramm's base_size is the default geom
    %    line width; use our 'regular' weight. ──
    g.set_line_options('base_size', T.line_weights_pt.regular);

    % ── markers: size in points (native), no border (matches R points), and
    %    the semantic shape order mapped to MATLAB marker glyphs. gramm always
    %    feeds border_width to scatter's LineWidth, which MATLAB requires to be
    %    > 0 even when the edge is invisible, so use a tiny positive width with a
    %    'none' edge colour. ──
    g.set_point_options( ...
        'base_size',    T.marker_size_pt, ...
        'border_width', 0.5, ...
        'border_color', 'none', ...
        'markers',      cnnp_markers(T.shapes));
end

% ── local helper ──────────────────────────────────────────────────────────────
function mk = cnnp_markers(shape_names)
%CNNP_MARKERS  Map semantic shape names to MATLAB marker glyphs.
%   MATLAB has fewer marker glyphs than ggplot's pch set: there is no
%   square-with-cross, so 'square_cross' falls back to a pentagram. This is the
%   MATLAB-specific half of the shared 'shapes' token (R maps the same names to
%   integer pch codes).
    lut = struct( ...
        'circle_filled',   'o', ...
        'triangle_filled', '^', ...
        'square_filled',   's', ...
        'diamond_filled',  'd', ...
        'plus',            '+', ...
        'asterisk',        '*', ...
        'square_cross',    'p', ...   % no MATLAB equivalent; pentagram filler
        'cross',           'x');
    mk = cell(1, numel(shape_names));
    for i = 1:numel(shape_names)
        if isfield(lut, shape_names{i})
            mk{i} = lut.(shape_names{i});
        else
            mk{i} = 'o';
        end
    end
end
