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
%                 is_tke            true: magnitude of a TKE frame is the sum of both components
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
calu = cal.calu; calv = cal.calv; calxy = cal.calxy;

%The direction of the coordinate system influences derivatives with gradients.
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
switch deriv
    case 2 %vorticity
        [curlz,~]= curl(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
        out=-curlz;
    case 3 %magnitude
        w = get_opt(opts,'w',[]); %stereo-PIV: 3D magnitude (|calu| for w: an axis flip does not flip w)
        if get_opt(opts,'is_tke',false) % total TKE is to be calculated, just a simple sum of x and y
            out=(u*calu)+(v*calv);
            if ~isempty(w)
                out=out+w*abs(calu);
            end
        elseif ~isempty(w)
            out=sqrt((u*calu-subtr_u).^2+(v*calv-subtr_v).^2+(w*abs(calu)).^2);
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
            out=lic(v*calv-subtr_v,u*calu-subtr_u);
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
            out=unc * abs(calu);
        end
    case 14 %w component (stereo-PIV)
        w = get_opt(opts,'w',[]);
        if ~isempty(w)
            out=w * abs(calu);
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
