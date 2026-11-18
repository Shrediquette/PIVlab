function cancelbutt_Callback(~, ~, ~)
gui.put('cancel',1);
gui.put('cancel_pressed',1); %stays set after the analysis returns ('cancel' is reset there): stereo.per_camera then skips camera 2

fileID = fopen(fullfile(userpath,'cancel_piv'),'w');
fwrite(fileID,1);
fclose(fileID);

drawnow;
gui.toolsavailable(1);

