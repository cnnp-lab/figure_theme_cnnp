function s = cnnp_ascii(s)
%CNNP_ASCII  Fold common non-ASCII typography to ASCII (mirrors R cnnp_ascii).
%
%   Replaces em/en dashes, the minus sign, curly quotes and the ellipsis with
%   plain ASCII, so titles/labels render identically across fonts and survive
%   export to every file type. This is the MATLAB half of the shared
%   `ascii_fold` token map; the substitutions are defined here by Unicode code
%   point (keeping this source pure-ASCII) rather than read from the decoded
%   token struct, because jsondecode mangles the non-identifier Unicode keys.

    from = char([8212 8211 8722 8216 8217 8220 8221 8230]); % — – − ‘ ’ “ ” …
    to   = {'-', '-', '-', '''', '''', '"', '"', '...'};

    s = char(s);
    for i = 1:numel(from)
        s = strrep(s, from(i), to{i});
    end
end
