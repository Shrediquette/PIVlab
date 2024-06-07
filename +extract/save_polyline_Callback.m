function save_polyline_Callback (~,~)
xposition=gui.retr('xposition');
yposition=gui.retr('yposition');
extract_type = gui.retr('extract_type');

if ~isempty(xposition) && ~isempty(yposition)
	[polyfile,polypath] = uiputfile('*.mat','Save coordinates','PIVlab_coordinates.mat');
	if isequal(polyfile,0) | isequal(polypath,0)
		%do nothing
	else
		save(fullfile(polypath,polyfile),'xposition','yposition','extract_type');
	end
end

