function T = cnnp_load_tokens(tokens_path)
%CNNP_LOAD_TOKENS  Read cnnp_tokens.json and build MATLAB-ready palettes.
%
%   T = cnnp_load_tokens() locates cnnp_tokens.json one level above this
%   file (the repo root). T = cnnp_load_tokens(PATH) uses an explicit path.
%
%   This is the MATLAB half of the shared design-token system (see
%   ../GUIDELINES.md). The R adapter reads the same JSON. Units in the token
%   file are physical: colours = hex, font/stroke/marker sizes = POINTS,
%   figure widths = mm. MATLAB is points-native, so sizes drop straight in
%   (no conversion — unlike ggplot2, which needs pt -> mm).
%
%   Returns struct T with:
%     T.raw          - decoded token tree (jsondecode output)
%     T.okabe_rgb    - 8x3 Okabe-Ito RGB (0-1), in token order
%     T.pairs_rgb    - 6x3 brand-pair RGB in gramm's color x lightness row
%                      order: teal/dark, teal/light, mustard/dark, mustard/light,
%                      purple/dark, purple/light  (n_color=3, n_lightness=2)
%     T.pair_names   - {'teal','mustard','purple'}
%     T.neutral, T.greys - structs mapping name -> [r g b]
%     T.base_size_pt, T.label_size_pt, T.scale (ratios struct),
%     T.font_prefer (cellstr), T.line_weights_pt (struct, points),
%     T.marker_size_pt, T.tick_len_pt, T.gutter_pt, T.dpi,
%     T.widths_mm (struct), T.shapes (cellstr).

    if nargin < 1 || isempty(tokens_path)
        here = fileparts(mfilename('fullpath'));
        tokens_path = fullfile(here, '..', 'cnnp_tokens.json');
    end
    assert(isfile(tokens_path), 'cnnp_load_tokens: not found: %s', tokens_path);

    raw = jsondecode(fileread(tokens_path));
    T.raw = raw;

    % ---- colours ----
    T.okabe_rgb = struct_to_rgb(raw.colors.okabe_ito);   % field order preserved
    T.neutral   = struct_map_rgb(raw.colors.neutral);
    T.greys     = struct_map_rgb(raw.colors.greys);

    % brand pairs -> gramm color x lightness ordering
    pn = fieldnames(raw.colors.pairs);                   % teal, mustard, purple
    pr = zeros(numel(pn) * 2, 3);
    for i = 1:numel(pn)
        p = raw.colors.pairs.(pn{i});
        pr(2*i - 1, :) = hex2rgb(p.dark);
        pr(2*i,     :) = hex2rgb(p.light);
    end
    T.pairs_rgb  = pr;
    T.pair_names = pn;

    % ---- scalars / typography / geometry ----
    T.base_size_pt    = raw.typography.base_size_pt;
    T.label_size_pt   = raw.typography.label_size_pt;
    T.scale           = raw.typography.scale;            % struct of unitless ratios
    T.font_prefer     = cellstr(raw.typography.font_prefer);
    T.line_weights_pt = raw.geometry.line_weights_pt;    % struct, points
    T.marker_size_pt  = raw.geometry.marker_point_size_pt;
    T.tick_len_pt     = raw.geometry.axis_tick_length_pt;
    T.gutter_pt       = raw.geometry.panel_gutter;
    T.dpi             = raw.export.dpi;
    T.widths_mm       = raw.export.widths_mm;            % struct: single/onehalf/double
    T.shapes          = cellstr(raw.shapes);

    % ---- continuous-scale colour stops (resolved to RGB) ----
    % Palette refs in the token file are dotted strings ("teal.light",
    % "okabe_ito.vermillion", "greys.light") or the literal "white"; resolve
    % them against the colour groups so the colormaps stay token-driven.
    T.scales.sequential.colors = resolve_refs(raw.scales.sequential.colors, raw);
    T.scales.sequential.values = raw.scales.sequential.values(:);
    T.scales.gradient.low      = resolve_ref(raw.scales.gradient.low,  raw);
    T.scales.gradient.high     = resolve_ref(raw.scales.gradient.high, raw);
    T.scales.diverging.low     = resolve_ref(raw.scales.diverging.low,  raw);
    T.scales.diverging.mid     = resolve_ref(raw.scales.diverging.mid,  raw);
    T.scales.diverging.high    = resolve_ref(raw.scales.diverging.high, raw);
    T.scales.na_value          = resolve_ref(raw.scales.na_value, raw);
end

% ── local helpers ─────────────────────────────────────────────────────────────
function rgb = hex2rgb(h)
    h = char(h);
    if ~isempty(h) && h(1) == '#', h(1) = []; end
    rgb = [hex2dec(h(1:2)), hex2dec(h(3:4)), hex2dec(h(5:6))] / 255;
end

function M = struct_to_rgb(s)            % ordered Nx3 matrix from a struct of hex
    fn = fieldnames(s);
    M  = zeros(numel(fn), 3);
    for i = 1:numel(fn), M(i, :) = hex2rgb(s.(fn{i})); end
end

function out = struct_map_rgb(s)         % struct of name -> [r g b]
    fn  = fieldnames(s);
    out = struct();
    for i = 1:numel(fn), out.(fn{i}) = hex2rgb(s.(fn{i})); end
end

function M = resolve_refs(refs, raw)     % cellstr/array of refs -> Nx3 RGB
    refs = cellstr(refs);
    M = zeros(numel(refs), 3);
    for i = 1:numel(refs), M(i, :) = resolve_ref(refs{i}, raw); end
end

function rgb = resolve_ref(ref, raw)
%RESOLVE_REF  Map a palette reference to RGB. Accepts:
%   "white"/"black", a literal "#rrggbb", or a dotted "<group>.<name>" where
%   group is a colour group in the token file (pairs use "<pair>.<dark|light>",
%   e.g. "teal.light"; others use "<group>.<name>", e.g. "okabe_ito.vermillion",
%   "greys.light", "neutral.cream").
    ref = char(ref);
    switch lower(ref)
        case 'white', rgb = [1 1 1]; return
        case 'black', rgb = [0 0 0]; return
    end
    if ~isempty(ref) && ref(1) == '#'
        rgb = hex2rgb(ref); return
    end
    parts = strsplit(ref, '.');
    assert(numel(parts) == 2, 'cnnp_load_tokens: bad colour ref "%s"', ref);
    grp = parts{1}; nm = parts{2};
    if isfield(raw.colors.pairs, grp)            % "teal.light" -> pairs.teal.light
        rgb = hex2rgb(raw.colors.pairs.(grp).(nm));
    elseif isfield(raw.colors, grp)              % "okabe_ito.vermillion", "greys.light"
        rgb = hex2rgb(raw.colors.(grp).(nm));
    else
        error('cnnp_load_tokens: unknown colour group "%s" in "%s"', grp, ref);
    end
end
