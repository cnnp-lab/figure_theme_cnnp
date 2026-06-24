function out_file = cnnp_export(g, T, name, out_dir, varargin)
%CNNP_EXPORT  Export a drawn gramm figure at a journal width (mirrors ggsave_cnnp).
%
%   cnnp_export(g, T, NAME, OUT_DIR) writes OUT_DIR/NAME.png at single-column
%   width (90 mm), 300 dpi, on a white background.
%
%   Name-value:
%     'width'   'single' (90 mm, default) | 'onehalf' (140) | 'double' (190),
%               or a numeric width in mm
%     'aspect'  height / width ratio (default 0.85)
%     'format'  'png' (default) | 'pdf' | 'eps' | ... (gramm file_type)
%
%   Widths and dpi come from the shared tokens (export.widths_mm, export.dpi),
%   so MATLAB figures come out at the same physical size as the R ones. NAME is
%   ASCII-folded for the filename. Call AFTER g.draw() (and cnnp_theme_axes).

    p = inputParser;
    addParameter(p, 'width',  'single');
    addParameter(p, 'aspect', 0.85);
    addParameter(p, 'format', 'png');
    parse(p, varargin{:});

    if isnumeric(p.Results.width)
        width_mm = p.Results.width;
    else
        assert(isfield(T.widths_mm, p.Results.width), ...
            'cnnp_export: unknown width "%s"', p.Results.width);
        width_mm = T.widths_mm.(p.Results.width);
    end
    height_mm = width_mm * p.Results.aspect;

    if ~exist(out_dir, 'dir'), mkdir(out_dir); end
    fname = cnnp_ascii(name);

    g.export('file_name',   fname, ...
             'export_path', out_dir, ...
             'file_type',   p.Results.format, ...
             'width',       width_mm / 10, ...      % mm -> cm (gramm units)
             'height',      height_mm / 10, ...
             'units',       'centimeters', ...
             'resolution',  T.dpi);

    out_file = fullfile(out_dir, [fname '.' p.Results.format]);
end
