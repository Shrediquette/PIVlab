function update_result
%UPDATE_RESULT Three velocity components from the 2D results of both cameras into the GUI.
%   stereo.update_result
% The 2D results of camera 1 and 2 (validated if the validation was applied) are reconstructed
% (stereo.reconstruct_results) into the result list of the GUI: U, V in rows 1-9 like a validated 2D result,
% W in row 16. The consistency residual and the light sheet position go into gui.retr('stereo_vel').
gui.put('derived', []);
[resultslist, stereo_vel] = stereo.reconstruct_results(false);
gui.put('resultslist', resultslist);
gui.put('stereo_vel', stereo_vel);
end
