function map = cnnp_seq(n)
%CNNP_SEQ  CNNP sequential colormap (white -> teal.light -> teal.dark).
%   Named wrapper so it can be passed to gramm as
%   g.set_continuous_color('colormap', 'cnnp_seq') — gramm resolves a custom
%   colormap by evaluating NAME(256). See CNNP_COLORMAP / cnnp_continuous.
    if nargin < 1 || isempty(n), n = 256; end
    map = cnnp_colormap('seq', n);
end
