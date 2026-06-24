function g = cnnp_continuous(g, type, varargin)
%CNNP_CONTINUOUS  Apply a CNNP continuous colour scale to a gramm object.
%
%   g = cnnp_continuous(g, TYPE) sets a token-derived continuous colormap.
%   TYPE is 'seq' (white->teal.light->teal.dark, the default sequential),
%   'gradient' (white->teal.dark) or 'div' (vermillion<->white<->teal.dark).
%
%   Name-value:
%     'CLim'  [lo hi] colour limits (passed to gramm). For 'div', pass a
%             symmetric range centred on the divergence point, e.g. [-1 1].
%
%   Call BEFORE g.draw(); apply CNNP_THEME_AXES afterwards for the chrome.
%   (The colormap itself is built by CNNP_COLORMAP, interpolated in CIE-Lab to
%   match the R figures; gramm receives it via the named cnnp_seq/grad/div
%   functions, which is the only public way to inject a custom RGB ramp.)

    p = inputParser;
    addParameter(p, 'CLim', []);
    parse(p, varargin{:});

    switch lower(type)
        case 'seq',      name = 'cnnp_seq';
        case 'gradient', name = 'cnnp_grad';
        case 'div',      name = 'cnnp_div';
        otherwise, error('cnnp_continuous: unknown type "%s"', type);
    end

    args = {'colormap', name};
    if ~isempty(p.Results.CLim), args = [args, {'CLim', p.Results.CLim}]; end
    g.set_continuous_color(args{:});
end
