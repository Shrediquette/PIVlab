function [returned_data, returned_header]=extract_plot_data_area(currentframe,refreshdisplay)
%returned_data=cell(0);
handles=gui_NameSpace.gui_gethand;
resultslist=gui_NameSpace.gui_retr('resultslist');
extractwhat=get(handles.extraction_choice_area,'Value');
if extractwhat==9 || extractwhat==10
	plot_NameSpace.plot_derivative_calc(currentframe,extractwhat+2,0);
else
	plot_NameSpace.plot_derivative_calc(currentframe,extractwhat+1,0);
end
derived=gui_NameSpace.gui_retr('derived');
if extractwhat==9 || extractwhat==10
	maptoget=derived{extractwhat+1,currentframe};
else
	maptoget=derived{extractwhat,currentframe};
end
xposition=gui_NameSpace.gui_retr('xposition');
yposition=gui_NameSpace.gui_retr('yposition');
extract_type = gui_NameSpace.gui_retr('extract_type');
if ~strcmp(extract_type,'extract_poly_area') && ~strcmp(extract_type,'extract_rectangle_area') && ~strcmp(extract_type,'extract_circle_area') && ~strcmp(extract_type,'extract_circle_series_area')
	if refreshdisplay
		msgbox('No area was drawn. Click ''Draw!'' on the left panel to start drawing an extraction area.','Error','error','modal')
	end
else
	if (gui_NameSpace.gui_retr('calu')==1 || gui_NameSpace.gui_retr('calu')==-1) && gui_NameSpace.gui_retr('calxy')==1
		distunit='px^2';
	else
		distunit='m^2';
	end
	if (gui_NameSpace.gui_retr('calu')==1 || gui_NameSpace.gui_retr('calu')==-1) && gui_NameSpace.gui_retr('calxy')==1
		distunit_2=' px';
	else
		distunit_2=' m';
	end

	current=get(handles.extraction_choice_area,'string');
	current=current{extractwhat};
	currentstripped=current(1:strfind(current,'[')-1);

	unitpar=get(handles.extraction_choice_area,'string');
	unitpar=unitpar{get(handles.extraction_choice_area,'value')};
	unitpar=unitpar(strfind(unitpar,'[')+1:end-1);

	if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %if there is data in the current frame
		maptoget=plot_NameSpace.plot_rescale_maps_nan(maptoget,0,currentframe);
		if strcmp(extract_type,'extract_poly_area') || strcmp(extract_type,'extract_rectangle_area') || strcmp(extract_type,'extract_circle_area')
			BW=extract_NameSpace.extract_convert_roi_to_binary(xposition,yposition,extract_type,size(maptoget));
			area=extract_NameSpace.extract_get_area_of_selection(BW,maptoget,1);
			mean_value=extract_NameSpace.extract_get_mean_of_selection(BW,maptoget);
			area_integral=extract_NameSpace.extract_get_integral_of_selection(BW,maptoget);
			returned_header = {strjoin({'Area (' distunit ')'},''),strjoin({'Mean (' unitpar ')'},'') , strjoin({'Integral (' unitpar '*' distunit ')'},'')};
			returned_data = {area, mean_value, area_integral};
		elseif strcmp(extract_type,'extract_circle_series_area')
			%draw circles as displayed
			x=resultslist{1,currentframe};
			stepsize=ceil((x(1,2)-x(1,1)));
			radii=[linspace(stepsize,yposition-stepsize,round(((yposition-stepsize)/stepsize))) yposition];
			length = 2*radii*pi; %column vector with the lengths of the circle series
			%convert circular roi object to series of coordinates
			valtable=linspace(0,2*pi,361)';
			extraction_coordinates_x=zeros(size(valtable,1),numel(length)); %rows=coordinates of one circle, cols = the different circles of the series
			extraction_coordinates_y=zeros(size(valtable,1),numel(length));
			for i=1:size(valtable,1)
				for j=1:numel(length)
					extraction_coordinates_x (i,j)=sin(valtable(i,1))*radii(j)+xposition(1);
					extraction_coordinates_y (i,j)=cos(valtable(i,1))*radii(j)+xposition(2);
				end
			end
			BW=zeros(size(maptoget));
			returned_data=cell(size(extraction_coordinates_x,2),4);
			for i=1:size(extraction_coordinates_x,2)
				BW = poly2mask(extraction_coordinates_x(:,i),extraction_coordinates_y(:,i),size(maptoget,1),size(maptoget,2));
				area=extract_NameSpace.extract_get_area_of_selection(BW,maptoget,1);
				mean_value=extract_NameSpace.extract_get_mean_of_selection(BW,maptoget);
				area_integral=extract_NameSpace.extract_get_integral_of_selection(BW,maptoget);
				old_string=get (handles.area_results,'String');
				returned_header = {strjoin({'Circle Nr.'},''),strjoin({'Area (' distunit ')'},''),strjoin({'Mean (' unitpar ')'},'') , strjoin({'Integral (' unitpar '*' distunit ')'},'')};
				returned_data{i,1}=i;
				returned_data{i,2}=area;
				returned_data{i,3}=mean_value;
				returned_data{i,4}=area_integral;
			end
		end
		if refreshdisplay
			old_color=get (handles.area_results,'Backgroundcolor');
			set(handles.area_results,'Backgroundcolor',[0.5 0.8 0.5]);
			pause(0.1)
			set(handles.area_results,'Backgroundcolor',old_color);
			outputstring=cell(0);
			for j = 1: size(returned_data,2)
				for jj=1:size(returned_data,1)
					outputstring{j,jj}=[num2str(returned_header{1,j}), ' = ' num2str(returned_data{jj,j})];
				end
			end
			set (handles.area_results,'String',outputstring)
		end
	end
end
