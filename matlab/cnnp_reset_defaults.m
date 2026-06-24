function cnnp_reset_defaults()
%CNNP_RESET_DEFAULTS  Undo CNNP_SET_SESSION_DEFAULTS (restore factory groot).
    props = {'defaultFigureColor','defaultAxesFontName','defaultTextFontName', ...
             'defaultAxesFontSize','defaultAxesXColor','defaultAxesYColor', ...
             'defaultAxesLineWidth','defaultAxesTickDir','defaultAxesBox', ...
             'defaultLineLineWidth'};
    for i = 1:numel(props)
        try, set(groot, props{i}, 'remove'); catch, end
    end
end
