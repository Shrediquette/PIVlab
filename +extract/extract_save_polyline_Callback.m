function extract_save_polyline_Callback (~,~)
xposition=gui.gui_retr('xposition');
yposition=gui.gui_retr('yposition');
extract_type = gui.gui_retr('extract_type');

if ~isempty(xposition) && ~isempty(yposition)
	[polyfile,polypath] = uiputfile('*.mat','Save coordinates','PIVlab_coordinates.mat');
	if isequal(polyfile,0) | isequal(polypath,0)
		%do nothing
	else
		save(fullfile(polypath,polyfile),'xposition','yposition','extract_type');
	end
end

