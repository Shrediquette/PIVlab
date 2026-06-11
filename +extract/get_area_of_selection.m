function area=get_area_of_selection(BW,maptoget,include_masked)
%returns area in m^2 or pixels^2 (depends on calibration applied or not).
celllength=gui.retr('calxy');
cellarea=celllength^2;
area=nnz(BW)*cellarea;
if include_masked~=1
	area=area-sum(isnan(maptoget(BW)))*cellarea;
end

