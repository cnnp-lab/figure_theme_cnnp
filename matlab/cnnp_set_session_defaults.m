function T = cnnp_set_session_defaults(T)
%CNNP_SET_SESSION_DEFAULTS  Apply CNNP defaults to the MATLAB session (groot).
%
%   T = cnnp_set_session_defaults() sets root (groot) defaults so that even
%   plain MATLAB figures — and gramm figures before the per-axes chrome — pick
%   up the lab's font, white figure background, and base font size. This is the
%   "apply once per session" entry point; per-figure styling still goes through
%   CNNP_STYLE (before draw) + CNNP_THEME_AXES (after draw).
%
%   Returns the loaded token struct for convenience. Call CNNP_RESET_DEFAULTS
%   to undo (or restart MATLAB).
%
%   Note: this does NOT set the cream panel background — gramm/most plots paint
%   their own axes background, so the cream "card" is applied post-draw by
%   CNNP_THEME_AXES. groot defaults here are the session-wide neutrals only.

    if nargin < 1 || isempty(T), T = cnnp_load_tokens(); end

    font     = T.font_prefer{1};
    midnight = T.neutral.midnight;

    set(groot, 'defaultFigureColor',         'w');
    set(groot, 'defaultAxesFontName',        font);
    set(groot, 'defaultTextFontName',        font);
    set(groot, 'defaultAxesFontSize',        T.base_size_pt);
    set(groot, 'defaultAxesXColor',          midnight);
    set(groot, 'defaultAxesYColor',          midnight);
    set(groot, 'defaultAxesLineWidth',       T.line_weights_pt.thin);
    set(groot, 'defaultAxesTickDir',         'out');
    set(groot, 'defaultAxesBox',             'off');
    set(groot, 'defaultLineLineWidth',       T.line_weights_pt.regular);
end
