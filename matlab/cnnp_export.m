function out_file = cnnp_export(g, T, name, out_dir, varargin)
%CNNP_EXPORT  Export a drawn gramm figure at a journal width (mirrors ggsave_cnnp).
%
%   cnnp_export(g, T, NAME, OUT_DIR) writes OUT_DIR/NAME.pdf and .png at
%   single-column width (90 mm), 300 dpi.
%
%   Name-value:
%     'width'    'single' (90 mm, default) | 'onehalf' (140) | 'double' (190),
%                or a numeric width in mm
%     'aspect'   height / width ratio (default 0.85)
%     'formats'  cellstr of gramm file types, default {'pdf','png'}. 'pdf'/'eps'/
%                'svg' are vector; 'png'/'jpg' raster.
%
%   Saved at the TRUE physical journal width so the theme's point sizes print
%   correctly (widths/dpi from the tokens). A PDF therefore has an exact size —
%   single = 90 mm = 255 pt — identical to the R adapter's PDFs. NAME is
%   ASCII-folded for the filename. Call AFTER g.draw() (and cnnp_theme_axes).

    p = inputParser;
    addParameter(p, 'width',   'single');
    addParameter(p, 'aspect',  0.85);
    addParameter(p, 'formats', {'pdf', 'png'});
    parse(p, varargin{:});

    formats = p.Results.formats;
    if ischar(formats) || isstring(formats), formats = cellstr(formats); end

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

    for k = 1:numel(formats)
        g.export('file_name',   fname, ...
                 'export_path', out_dir, ...
                 'file_type',   formats{k}, ...
                 'width',       width_mm / 10, ...   % mm -> cm (gramm units)
                 'height',      height_mm / 10, ...
                 'units',       'centimeters', ...
                 'resolution',  T.dpi);
    end

    out_file = fullfile(out_dir, [fname '.' formats{1}]);
end
