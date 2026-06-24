function map = cnnp_div(n)
%CNNP_DIV  CNNP diverging colormap (vermillion -> white -> teal.dark).
%   Named wrapper so it can be passed to gramm as
%   g.set_continuous_color('colormap', 'cnnp_div') — gramm resolves a custom
%   colormap by evaluating NAME(256). See CNNP_COLORMAP / cnnp_continuous.
    if nargin < 1 || isempty(n), n = 256; end
    map = cnnp_colormap('div', n);
end
