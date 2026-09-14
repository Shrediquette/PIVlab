function mean_area=get_mean_of_selection(BW,maptoget,isangle)
%returns mean value of selected area
%isangle=1: maptoget holds angles in degrees. The arithmetic mean is
%meaningless for those, because atan2d wraps at +-180 deg (e.g. +179 and
%-179 deg point the same way but average to 0 deg). Use the unweighted
%circular mean instead: every vector contributes equally, regardless of its
%magnitude.
if nargin < 3 || isempty(isangle)
	isangle=0;
end
selection = maptoget(BW);
if isangle == 1
	mean_area = atan2d(mean(sind(selection),'omitnan'),mean(cosd(selection),'omitnan'));
else
	mean_area = mean(selection,'omitnan');
end
