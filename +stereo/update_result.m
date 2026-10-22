function update_result
%UPDATE_RESULT Three velocity components from the 2D results of both cameras into the GUI.
%   stereo.update_result
% The 2D results of camera 1 and 2 (validated if the validation was applied) are reconstructed
% (stereo.reconstruct_results) into the result list of the GUI: U, V in rows 1-9 like a validated 2D result,
% W in row 16. The consistency residual and the light sheet position go into gui.retr('stereo_vel').
gui.put('derived', []);
try
	[resultslist, stereo_vel] = stereo.reconstruct_results(false);
catch err
	if ~strcmp(err.identifier, 'stereo:update_result')
		rethrow(err)
	end
	% image pairs analysed on different grids (region of interest or PIV settings changed, then only the
	% current frame analysed): no common 3D result. Otherwise the result list would still hold the 2D
	% result of the last camera of stereo.per_camera. The 2D results of both cameras are kept.
	resultslist = [];
	stereo_vel = [];
	gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Stereo-PIV', ['The image pairs were analysed on different grids ' ...
		'(the region of interest or the PIV settings were changed). Please analyze all frames again.'], 'modal');
end
gui.put('resultslist', resultslist);
gui.put('stereo_vel', stereo_vel);
end
