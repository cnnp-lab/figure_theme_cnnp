function map = cnnp_grad(n)
%CNNP_GRAD  CNNP simple sequential colormap (white -> teal.dark).
%   Named wrapper for gramm's g.set_continuous_color('colormap', 'cnnp_grad').
%   See CNNP_COLORMAP / cnnp_continuous.
    if nargin < 1 || isempty(n), n = 256; end
    map = cnnp_colormap('gradient', n);
end
