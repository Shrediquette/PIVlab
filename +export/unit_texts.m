function units=unit_texts(calu, calxy, displacement_only, statistic)
%Unit texts of the exported data: units.length (x, y), units.velocity (calibration of u, v),
%units.value (u, v, w, magnitude: squared for TKE frames), units.time (derivatives).
%statistic: second output of gui.frame_factors ('tke' squares the velocity unit), may be [].
if (calu==1 || calu==-1) && calxy==1 %not calibrated
	units.length='px';
	units.velocity='px/frame';
	units.time='frame';
elseif ~isempty(displacement_only) && displacement_only == 1
	units.length='m';
	units.velocity='m/frame';
	units.time='frame';
else
	units.length='m';
	units.velocity='m/s';
	units.time='s';
end
units.value=units.velocity;
if strcmp(statistic,'tke')
	units.value=['(' units.velocity ')^2']; %TKE: velocity squared
end
