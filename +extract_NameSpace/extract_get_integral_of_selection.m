function area_integral=extract_get_integral_of_selection(BW,maptoget)
%returns area integral value of selected area
non_masked_area = extract_NameSpace.extract_get_area_of_selection(BW,maptoget,0);
area_integral = non_masked_area * mean((maptoget(BW==1 & ~isnan(maptoget))),'omitnan');
