function [q, q2] = draw_vectors(target_axis, x, y, u, v, typevector, vecskip, vecscale, vectorcolor, o)
%DRAW_VECTORS Draw the vector field like the PIVlab display (no GUI needed).
%   [q, q2] = plot.draw_vectors(target_axis, x, y, u, v, typevector, vecskip, vecscale, vectorcolor, o)
%
%   x, y, u, v     vector positions (px) and displacements (px/frame)
%   typevector     1 = valid, 2 = interpolated, 3 = second peak, 0 = masked
%   vecskip        draw every vecskip-th vector
%   vecscale       scale factor for the vector length
%   vectorcolor    RGB colour of the valid vectors, or 'magnitude' to colour by magnitude
%   o              options:
%     interp_color, secondpeak_color   RGB colours of interpolated / second peak vectors
%     uniform                          true: all vectors have the same length
%     power, power_factor              compress the vector lengths with an exponent
%     vecwidth                         line width
%     masktransp                       < 100: masked vectors are marked with red crosses
%     ref_position                     'Off','Top left','Top right','Bottom right','Bottom left'
%     ref_length                       length of the reference vector (calibrated units)
%     calu, calv, calxy, displacement_only, subtr_u, subtr_v   calibration
%     colormap_name, colormap_steps    colours of the magnitude mode
%     colorbar_position, colorbar_format   colour bar of the magnitude mode
%
%   Used by plot.vectors (GUI) and pivlab.display.
hold(target_axis,'on');
vectorcolorintp    = o.interp_color;
vectorcolor2ndpeak = o.secondpeak_color;

% "color vectors by magnitude" is signalled by passing a char vector instead of an RGB
% triple. The colors must represent the TRUE velocity, so the magnitude is captured here,
% before the length-altering display transforms below (uniform / power scaling) touch u and v.
magnitude_mode = ~isnumeric(vectorcolor);
if magnitude_mode
    magnitude_true = sqrt( (u*o.calu - o.subtr_u).^2 + ...
        (v*o.calv - o.subtr_v).^2 );
else
    magnitude_true = [];
end

%normalize vector lengths so we can better see flow directions of small velocities:
if o.uniform
    mag_uniform = sqrt(u(:,:,1).^2 + v(:,:,1).^2);
    mag_uniform(mag_uniform==0) = 1;             % avoid 0/0 -> NaN at zero vectors
    u = u(:,:,1)./mag_uniform;                   % normalized u
    v = v(:,:,1)./mag_uniform;                   % normalized v
end
if o.power
    exponent_1=o.power_factor;
    mag_old = sqrt(u.^2 + v.^2);                 % original vector lengths
    mag_new = mag_old.^exponent_1;               % compressed lengths
    % preserve the overall mean length so the plot scale stays comparable
    scale = mean(mag_old(:),'omitnan') / mean(mag_new(:),'omitnan');
    mag_new = mag_new * scale;
    ratio = mag_new ./ mag_old;                  % per-vector length change
    ratio(mag_old==0) = 0;                       % avoid 0/0 -> NaN at zero vectors
    u = u .* ratio;                              % keep direction, change length only
    v = v .* ratio;
end

% Decimate once, so the flat and magnitude paths below share one set of arrays.
if vecskip==1
    typevector_reduced = typevector;
    x_reduced = x;
    y_reduced = y;
    u_reduced = u;
    v_reduced = v;
    magnitude_reduced = magnitude_true;
else
    typevector_reduced=typevector(1:vecskip:end,1:vecskip:end);
    x_reduced=x(1:vecskip:end,1:vecskip:end);
    y_reduced=y(1:vecskip:end,1:vecskip:end);
    u_reduced=u(1:vecskip:end,1:vecskip:end);
    v_reduced=v(1:vecskip:end,1:vecskip:end);
    if magnitude_mode
        magnitude_reduced = magnitude_true(1:vecskip:end,1:vecskip:end);
    else
        magnitude_reduced = [];
    end
end

subtr_u_px = o.subtr_u/o.calu;
subtr_v_px = o.subtr_v/o.calv;
vecwidth   = o.vecwidth;

if magnitude_mode
    show = typevector_reduced>0;
    cmap  = plot.vector_colormap_core(o.colormap_name, o.colormap_steps, 64, nnz(show));
    clims = magnitude_limits(magnitude_reduced(show));
    q = plot.quiverc(target_axis, ...
        x_reduced(show), y_reduced(show), ...
        (u_reduced(show)-subtr_u_px)*vecscale, ...
        (v_reduced(show)-subtr_v_px)*vecscale, ...
        magnitude_reduced(show), cmap, clims, vecwidth);
    q2 = gobjects(0);
    update_magnitude_colorbar(target_axis, o, cmap, clims);
else
    delete(findobj(ancestor(target_axis,'figure'),'Tag','magnitude_colorbar'));
    q=quiver(x_reduced(typevector_reduced==1),y_reduced(typevector_reduced==1),...
        (u_reduced(typevector_reduced==1)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==1)-subtr_v_px)*vecscale,...
        'Color', vectorcolor,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');
    q2=quiver(x_reduced(typevector_reduced==2),y_reduced(typevector_reduced==2),...
        (u_reduced(typevector_reduced==2)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==2)-subtr_v_px)*vecscale,...
        'Color', vectorcolorintp,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');
    quiver(x_reduced(typevector_reduced==3),y_reduced(typevector_reduced==3),...
        (u_reduced(typevector_reduced==3)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==3)-subtr_v_px)*vecscale,...
        'Color', vectorcolor2ndpeak,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');
end
if o.masktransp < 100
    scatter(x_reduced(typevector_reduced==0),y_reduced(typevector_reduced==0),'rx','parent',target_axis) %masked
end

% reference vector display
if ~strcmpi(o.ref_position,'Off')
    plot.reference_vector_core(x,y,vecscale,target_axis,o.ref_position,o.ref_length,o.calu,o.calxy,o.displacement_only);
end
hold(target_axis,'off');
target_axis.Clipping = "on";
end

% -------------------------------------------------------------------------
function clims = magnitude_limits(mag)
%MAGNITUDE_LIMITS Color limits for the magnitude scale, robust to empty/flat data.
mag = mag(isfinite(mag));
if isempty(mag)
    clims = [0 1];
    return
end
clims = [min(mag) max(mag)];
if clims(2) <= clims(1)
    clims = clims(1) + [0 max(abs(clims(1))*0.01, eps)];
end
end

% -------------------------------------------------------------------------
function update_magnitude_colorbar(target_axis, o, cmap, clims)
%UPDATE_MAGNITUDE_COLORBAR Colorbar describing the vector magnitude scale.
%   Magnitude coloring is only used when no derived scalar is displayed, so nothing else is
%   using the axes colormap here: the particle image and the mask are both drawn as truecolor
%   RGB and ignore it. That makes it safe to point the axes colormap and CLim at the vector
%   scale and let a normal colorbar read it.
parentfig = ancestor(target_axis,'figure');
delete(findobj(parentfig,'Tag','magnitude_colorbar'));
if strcmpi(o.colorbar_position,'None')
    return
end

colormap(target_axis, cmap);
set(target_axis,'CLim',clims); % property assignment, not clim(): works on old releases too

position = o.colorbar_position;
coloobj = colorbar(position,'Fontsize',12,'HitTest','off','parent',parentfig,'Tag','magnitude_colorbar');

if (o.calu==1 || o.calu==-1) && o.calxy==1 % not calibrated
    label = 'Velocity magnitude in px/frame';
else
    if ~isempty(o.displacement_only) && o.displacement_only == 1
        label = 'Velocity magnitude in m/frame';
    else
        label = 'Velocity magnitude in m/s';
    end
end
if strcmp(position,'EastOutside') || strcmp(position,'WestOutside')
    ylabel(coloobj,label,'fontsize',12,'fontweight','bold');
else
    xlabel(coloobj,label,'fontsize',12,'fontweight','bold');
end

% Match the tick formatting of the scalar colorbar.
switch o.colorbar_format
    case 2
        fmt = '%0.3e';
    case 3
        fmt = '%0.3f';
    otherwise
        fmt = '%0.3g';
end
ticks = linspace(clims(1), clims(2), min(size(cmap,1),8)+1);
coloobj.Ticks      = ticks;
coloobj.TickLabels = num2str(ticks(:), fmt);
end
