% cnnp_poc.m — proof-of-concept for the CNNP MATLAB (gramm) adapter.
%
% Validates the whole token pipeline on ONE figure before we build the full
% gallery: tokens load from cnnp_tokens.json, the custom Okabe-Ito colormap and
% the typography/line/marker options inject into gramm, the post-draw chrome
% produces the cream-card / midnight-axes look, and export() writes a file.
%
% Mirrors R fig1: weight vs. fuel economy, coloured by cylinder count.
%
% Requirements: MATLAB R2018b+ and gramm on the path
% (https://github.com/piermorel/gramm). If gramm is not installed, set
% GRAMM_DIR below to its folder.
%
% Run:  cd matlab; cnnp_poc        % writes matlab/poc_out/cnnp_poc.png
addpath(genpath('~/Documents/GitHub/gramm'))
% --- ensure gramm is available ---
if exist('gramm', 'class') ~= 8
    GRAMM_DIR = '';   % <- set to your gramm folder if not already on the path
    if ~isempty(GRAMM_DIR), addpath(GRAMM_DIR); end
    assert(exist('gramm', 'class') == 8, ...
        ['gramm not found on the MATLAB path. Install it ', ...
         '(https://github.com/piermorel/gramm) and add it to the path, ', ...
         'or set GRAMM_DIR in this script.']);
end

here = fileparts(mfilename('fullpath'));

% --- load shared tokens ---
T = cnnp_load_tokens();      % reads ../cnnp_tokens.json

% --- data: built-in carsmall (no toolbox needed), mirrors mtcars wt/mpg/cyl ---
load carsmall Weight MPG Cylinders
cyl = categorical(Cylinders);                 % discrete colour groups (4/6/8)

% --- build the gramm plot ---
g = gramm('x', Weight, 'y', MPG, 'color', cyl);
g.geom_point();
g.set_names('x', 'weight (lb)', 'y', 'miles per gallon', 'color', 'cylinders');
g.set_title('Fuel economy vs. weight');

% --- inject CNNP brand tokens (colours / fonts / line / markers) ---
g = cnnp_style(g, T, 'palette', 'okabe_ito');

% --- draw, then apply the CNNP chrome (cream cards, midnight axes) ---
figure('Color', 'w', 'Units', 'centimeters', ...
       'Position', [2 2 T.widths_mm.single/10 T.widths_mm.single/10*0.85]);
g.draw();
cnnp_theme_axes(g, T);

% --- export at true single-column width (mm -> cm for gramm), 300 dpi ---
out_dir = fullfile(here, 'poc_out');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
g.export('file_name',  'cnnp_poc', ...
         'export_path', out_dir, ...
         'file_type',   'png', ...
         'width',       T.widths_mm.single / 10, ...
         'height',      T.widths_mm.single / 10 * 0.85, ...
         'units',       'centimeters', ...
         'resolution',  T.dpi);

fprintf('Wrote %s\n', fullfile(out_dir, 'cnnp_poc.png'));
