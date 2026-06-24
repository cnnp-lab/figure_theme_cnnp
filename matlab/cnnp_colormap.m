function map = cnnp_colormap(type, n, T)
%CNNP_COLORMAP  Build a CNNP continuous colormap (Nx3 RGB, 0-1) from tokens.
%
%   map = cnnp_colormap(TYPE) returns a 256-row colormap. TYPE is one of:
%     'seq'       white -> teal.light -> teal.dark  (sequential; the default,
%                 perceptually even — teal.light sits at value 0.374, the CIE-L*
%                 fraction between white and teal.dark, exactly as in the R theme)
%     'gradient'  white -> teal.dark               (simple 2-stop sequential)
%     'div'       vermillion -> white -> teal.dark (diverging, centred on white)
%
%   map = cnnp_colormap(TYPE, N) returns N rows. map = cnnp_colormap(TYPE, N, T)
%   reuses an already-loaded token struct (from CNNP_LOAD_TOKENS).
%
%   Interpolation is done in CIE-L*a*b* space (D65), matching ggplot2's
%   colour_ramp(), so the MATLAB ramps match the R figures rather than the
%   harsher result of naive RGB interpolation.

    if nargin < 2 || isempty(n), n = 256; end
    if nargin < 3 || isempty(T), T = cnnp_load_tokens(); end

    switch lower(type)
        case 'seq'
            stops = T.scales.sequential.colors;     % Nx3 RGB
            pos   = T.scales.sequential.values;     % Nx1 in [0,1]
        case 'gradient'
            stops = [T.scales.gradient.low; T.scales.gradient.high];
            pos   = [0; 1];
        case 'div'
            stops = [T.scales.diverging.low; T.scales.diverging.mid; T.scales.diverging.high];
            pos   = [0; 0.5; 1];
        otherwise
            error('cnnp_colormap: unknown type "%s"', type);
    end

    lab  = srgb2lab(stops);                         % interpolate in Lab
    q    = linspace(0, 1, n)';
    labq = interp1(pos, lab, q, 'linear');
    map  = min(max(lab2srgb(labq), 0), 1);          % back to sRGB, clamp
end

% ── sRGB <-> CIE-L*a*b* (D65), vectorised over rows ─────────────────────────────
function lab = srgb2lab(rgb)
    xyz = rgb2xyz_lin(rgb);
    wp  = [0.95047 1.0 1.08883];                    % D65 white point
    f   = @(t) (t > 0.008856) .* (t .^ (1/3)) + (t <= 0.008856) .* (7.787 .* t + 16/116);
    fx  = f(xyz(:,1) / wp(1));
    fy  = f(xyz(:,2) / wp(2));
    fz  = f(xyz(:,3) / wp(3));
    lab = [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
end

function rgb = lab2srgb(lab)
    wp = [0.95047 1.0 1.08883];
    fy = (lab(:,1) + 16) / 116;
    fx = fy + lab(:,2) / 500;
    fz = fy - lab(:,3) / 200;
    fi = @(t) (t.^3 > 0.008856) .* (t.^3) + (t.^3 <= 0.008856) .* ((t - 16/116) / 7.787);
    xyz = [fi(fx) * wp(1), fi(fy) * wp(2), fi(fz) * wp(3)];
    rgb = xyz2rgb_lin(xyz);
end

function xyz = rgb2xyz_lin(rgb)
    c = (rgb > 0.04045) .* (((rgb + 0.055) / 1.055) .^ 2.4) + (rgb <= 0.04045) .* (rgb / 12.92);
    M = [0.4124 0.3576 0.1805; 0.2126 0.7152 0.0722; 0.0193 0.1192 0.9505];
    xyz = c * M';
end

function rgb = xyz2rgb_lin(xyz)
    M = [ 3.2406 -1.5372 -0.4986; -0.9689 1.8758 0.0415; 0.0557 -0.2040 1.0570];
    c = xyz * M';
    rgb = (c > 0.0031308) .* (1.055 * (max(c,0) .^ (1/2.4)) - 0.055) + (c <= 0.0031308) .* (12.92 * c);
end
