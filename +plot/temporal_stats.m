function [u_out, v_out, typevector_out] = temporal_stats(U, V, TV, type)
%TEMPORAL_STATS Temporal mean / sum / standard deviation / TKE of a vector field series (no GUI).
%   [u_out, v_out, typevector_out] = plot.temporal_stats(U, V, TV, type)
%
%   U, V   H x W x N displacements of the selected frames
%   TV     H x W x N typevectors of the selected frames (3 = second peak is treated as valid)
%   type   1 = mean, 0 = sum, 2 = standard deviation, 3 = turbulent kinetic energy
%          (for TKE, u_out / v_out are the x and y components 0.5*var(u), 0.5*var(v))
%
%   typevector_out  0 where the vector is masked in all frames, 2 where more than 50 % of the
%                   vectors were interpolated, else 1. For mean, stdev and TKE, vectors with less
%                   than 25 % valid measurements are set to NaN.
%
%   Used by plot.temporal_operation_Callback (GUI) and pivlab.temporal.
TV(TV == 3) = 1; % 2nd-peak valid counts as a good measurement
typevectormean=mean(TV,3);
typevector_out=ones(size(TV,1),size(TV,2));
typevector_out(typevectormean==0)=0; %masked in all frames
typevector_out(typevectormean>1.5)=2; %if more than 50% of vectors are interpolated, then mark vector in mean as interpolated too.
switch type
    case 3
        %Turbulent kinetic energy TKE, based on discussion with H.E. TOUHAMI, improved by Stefano M.
        u_out=0.5*var(U,0,3,'omitnan');
        v_out=0.5*var(V,0,3,'omitnan');
        u_out(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
        v_out(typevectormean>=1.75)=nan;
    case 2
        u_out=std(U,0,3,'omitnan');
        v_out=std(V,0,3,'omitnan');
        u_out(typevectormean>=1.75)=nan;
        v_out(typevectormean>=1.75)=nan;
    case 1
        u_out=mean(U,3,'omitnan');
        v_out=mean(V,3,'omitnan');
        u_out(typevectormean>=1.75)=nan;
        v_out(typevectormean>=1.75)=nan;
    case 0
        try
            u_out=sum(U,3,'omitnan');
            v_out=sum(V,3,'omitnan');
        catch
            U(isnan(U))=0;
            V(isnan(V))=0;
            u_out=sum(U,3);
            v_out=sum(V,3);
        end
    otherwise
        error('plot:temporal_stats:type','type must be 0 (sum), 1 (mean), 2 (stdev) or 3 (TKE).');
end
end
