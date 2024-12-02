function CheckUpdates
% Check for updates
version=gui.retr('PIVver');
filename_update = fullfile(userpath ,'latest_version.txt');
if ~isdeployed
	if gui.retr('parallel')==1
		current_url = 'http://william.thielicke.org/PIVlab/latest_version_p.txt';
	else
		current_url = 'http://william.thielicke.org/PIVlab/latest_version.txt';
	end
else
	current_url = 'http://william.thielicke.org/PIVlab/latest_version_standalone.txt';
end
if strcmpi(getenv('USERNAME'),'trash') || strcmpi(getenv('USERNAME'),'thiel') % these are my usernames, don't count my own starts (too many...).
	current_url = 'http://william.thielicke.org/PIVlab/latest_version_william.txt';
end
starred_feature_url='http://william.thielicke.org/PIVlab/starred_feature.txt';
filename_starred=fullfile(userpath ,'starred_feature.txt');
% Update checking inspired by: https://www.mathworks.com/matlabcentral/fileexchange/64294-photoannotation
update_msg = 'Could not check for updates'; %default message will be overwritten by the following lines
starred_feature_text='';
gui.put('update_msg_color',[0 0 0.75]);
try
	if exist('websave','builtin')||exist('websave','file')
		outfilename=websave(filename_update,current_url,weboptions('Timeout',10));
		try
			outfilename2=websave(filename_starred,starred_feature_url,weboptions('Timeout',2));
		catch
		end
	else
		outfilename=urlwrite(current_url,filename_update); %#ok<*URLWR>
		try
			outfilename2=urlwrite(starred_feature_url,filename_starred); %#ok<*URLWR>
		catch
		end
	end

	%version number
	fileID_update = fopen(filename_update);
	web_version = textscan(fileID_update,'%s');
	web_version=cell2mat(web_version{1});
	trash_upd = fclose(fileID_update);
	if ispc %Matlab seems to have issues with deleting files on unix systems
		recycle('on');
		delete(filename_update)
	end
	%starred feature message
	starred_feature_text = fileread(filename_starred);
	if ispc %Matlab seems to have issues with deleting files on unix systems
		recycle('on');
		delete(filename_starred)
	end
	if strcmp(version,web_version) == 1
		update_msg = 'You have the latest PIVlab version.';
		gui.put('update_msg_color',[0 0.75 0]);
	elseif str2num (strrep(version,'.','')) < str2num(strrep(web_version,'.',''))
		update_msg = ['PIVlab is outdated. Please update to version ' web_version sprintf('\n') starred_feature_text];
		gui.put('update_msg_color',[0.85 0 0]);
	elseif str2num (strrep(version,'.','')) > str2num(strrep(web_version,'.',''))
		update_msg = ['Your PIVlab version is newer than the latest official release.'];
		gui.put('update_msg_color',[0.5 0.5 0]);
	end
catch
	%Either the download failed, or the file downloaded is empty.
	update_msg = 'Could not check for updates';
	gui.put('update_msg_color',[0.75 0.75 0]);
end
clear filename_update current_url fileID_update outfilename web_version trash_upd
disp (['-> ' update_msg])
gui.put('update_msg',update_msg);