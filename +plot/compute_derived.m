function out = compute_derived(x, y, u, v, deriv, cal, opts)
%COMPUTE_DERIVED Derived quantity of one velocity field, as shown in PIVlab (no GUI needed).
%   out = plot.compute_derived(x, y, u, v, deriv, cal, opts)
%
%   x, y, u, v  vector positions and displacements in pixels / pixels per frame
%   deriv       2 = vorticity, 3 = magnitude, 4 = u, 5 = v, 6 = divergence, 7 = Q criterion,
%               8 = shear rate, 9 = simple strain rate, 10 = LIC, 11 = vector direction,
%               12 = correlation coefficient, 13 = uncertainty, 14 = w component (stereo-PIV)
%               (PIVlab's "Display parameter")
%   cal         struct with calxy, calu, calv, x_axis_direction, y_axis_direction
%   opts        struct with optional fields
%                 subtr_u, subtr_v  velocity subtracted for magnitude/u/v/LIC/direction (calibrated units)
%                 statistic         '' (default) or 'mean', 'sum', 'std', 'tke' for frames of temporal
%                                   statistics (calibrate.statistic_factors; magnitude of a TKE frame is
%                                   the sum of the components)
%                 correlation_map   needed for deriv 12
%                 uncertainty       uncertainty map in px/frame, needed for deriv 13
%                 lic               function handle @(vx,vy) computing the LIC image (deriv 10)
%                 w                 out-of-plane component in pixels per frame (stereo-PIV): the magnitude
%                                   (3) is then the 3D magnitude, and 14 gives w
%
%   out  the derived map (same size as u), or [] if not available.
%   Used by plot.derivative_calc (GUI) and pivlab.derive.
if nargin < 7
    opts = struct();
end
subtr_u = get_opt(opts,'subtr_u',0);
subtr_v = get_opt(opts,'subtr_v',0);
calxy = cal.calxy;
%factors to the user's units: velocities (w positive along z = x cross y), or standard deviation / TKE
f = calibrate.statistic_factors(cal.calu, cal.calv, get_opt(opts,'statistic',''));
calu = f.u; calv = f.v; calw = f.w;

%Derivatives are computed in the user's coordinate system (x, y, z right-handed, z = x cross y).
if cal.x_axis_direction==1
    x_adjusted=x;
else
    x_adjusted=fliplr(x);
end
if cal.y_axis_direction==1
    y_adjusted=y;
else
    y_adjusted=flipud(y);
end

out = [];
%spatial derivatives need at least 2 x 2 vectors (e.g. only one row of vectors in a thin image strip)
if any(deriv==[2 6 7 8 9]) && (size(u,1)<2 || size(u,2)<2)
    out=nan(size(u));
    return
end
switch deriv
    case 2 %vorticity: z component of the curl, dv/dx - du/dy
        [curlz,~]= curl(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
        out=curlz;
    case 3 %magnitude
        w = get_opt(opts,'w',[]); %stereo-PIV: 3D magnitude
        if strcmpi(get_opt(opts,'statistic',''),'tke') % total TKE is to be calculated, just a simple sum of x and y
            out=(u*calu)+(v*calv);
            if ~isempty(w)
                out=out+w*calw;
            end
        elseif ~isempty(w)
            out=sqrt((u*calu-subtr_u).^2+(v*calv-subtr_v).^2+(w*calw).^2);
        else
            out=sqrt((u*calu-subtr_u).^2+(v*calv-subtr_v).^2);
        end
    case 4
        out=u*calu-subtr_u;
    case 5
        out=v*calv-subtr_v;
    case 6
        out=divergence(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
    case 7
        out=plot.qcrit(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
    case 8
        out=plot.shear(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
    case 9
        out=plot.strain(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
    case 10
        lic = get_opt(opts,'lic',[]);
        if ~isempty(lic)
            %the LIC image is drawn on the image: components in image directions (x right, y down)
            out=lic((v*calv-subtr_v)*sign(calv),(u*calu-subtr_u)*sign(calu));
        end
    case 11
        try
            out=atan2d(v*calv-subtr_v,u*calu-subtr_u);
        catch
            out=v*0;
            beep;
            disp('This operation is not supported in your Matlab version. Sorry...');
        end
    case 12
        out=get_opt(opts,'correlation_map',[]); % correlation map
    case 13
        unc = get_opt(opts,'uncertainty',[]);
        if ~isempty(unc)
            out=unc * abs(cal.calu);
        end
    case 14 %w component (stereo-PIV)
        w = get_opt(opts,'w',[]);
        if ~isempty(w)
            out=w * calw;
        end
end
end

function v = get_opt(opts, name, default)
if isfield(opts,name)
    v = opts.(name);
else
    v = default;
end
end
