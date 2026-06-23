function cnnp_theme_axes(g, T)
%CNNP_THEME_AXES  Apply the CNNP chrome to a drawn gramm object.
%
%   cnnp_theme_axes(g, T) must be called AFTER g.draw(). It reproduces the R
%   theme's signature look that gramm has no native concept for:
%     - cream "card" panel backgrounds, on a white figure (white = inter-panel
%       gutter / outer margin)
%     - midnight axis lines, ticks, tick labels, and axis titles
%     - classic L-shaped axes (no top/right box), ticks pointing outward
%     - no gridlines
%   Sizes come from the shared tokens; MATLAB axes LineWidth is in points, so
%   the token weights apply directly (same physical width as the R figures).
%
%   Operates on gramm's data axes (obj.facet_axes_handles) plus the legend and
%   title axes, found via the documented gramm handle properties.

    cream    = T.neutral.cream;
    midnight = T.neutral.midnight;
    axlw     = T.line_weights_pt.thin;     % axis line width, points
    fontname = T.font_prefer{1};

    % ── data axes: the cream cards + midnight chrome ──
    axs = g(1).facet_axes_handles;

    % white outer figure = the inter-panel gutter / margin. gramm's `parent`
    % property is protected in this version, so reach the figure via the axes.
    fig = ancestor(axs(1), 'figure');
    if ishghandle(fig), set(fig, 'Color', 'w'); end

    for ax = reshape(axs, 1, [])
        if ~ishghandle(ax) || ~strcmp(get(ax, 'Type'), 'axes'), continue; end
        set(ax, ...
            'Color',     cream, ...        % cream data card
            'XColor',    midnight, ...     % axis line + ticks + tick labels
            'YColor',    midnight, ...
            'LineWidth', axlw, ...
            'TickDir',   'out', ...
            'Box',       'off', ...        % drop top/right -> L-shaped axes
            'XGrid',     'off', 'YGrid', 'off', ...
            'FontName',  fontname);
        % titles / axis labels share the midnight chrome
        trySetColor(ax.Title,  midnight);
        trySetColor(ax.XLabel, midnight);
        trySetColor(ax.YLabel, midnight);
    end

    % ── legend + title axes: keep them on the cream card, no box ──
    for h = [g(1).legend_axe_handle, g(1).title_axe_handle]
        if ishghandle(h) && strcmp(get(h, 'Type'), 'axes')
            set(h, 'Color', cream, 'Box', 'off', 'FontName', fontname);
        end
    end
end

function trySetColor(h, c)
    if ~isempty(h) && ishghandle(h), set(h, 'Color', c); end
end
