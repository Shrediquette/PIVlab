function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);
plan("check") = CodeIssuesTask;
plan("test") = TestTask;


plan.DefaultTasks = ["williamclean" "william_upload_version_nr"];
end

%% TODO: vesionsnummer in toolbox und standalonapp.
% kompilieren toolbox und standalone

function william_make_toolboxTask(~)
PIVlab_toolbox_options=matlab.addons.toolbox.ToolboxOptions("PIVlab_source.prj");
PIVlab_toolbox_options.ToolboxVersion
end


function william_upload_version_nrTask(~)
%% Upload file version identifier via FTP
answer = questdlg('Upload new file version to thielicke.org server?', 'Upload?','Yes', 'No','Yes');
if strcmp(answer,'Yes')
	opts.windowstlye = 'modal';
	answer = inputdlg('Please enter highlighted feature here','Starred feature of the release',1,{'New: '},opts);
	answer=answer{1};
	writematrix(answer,'starred_feature.txt');
	update_file_name='latest_version.txt';
	writematrix(version,update_file_name)
	copyfile 'latest_version.txt' 'latest_version_p.txt'
	copyfile 'latest_version.txt' 'latest_version_standalone.txt'
	copyfile 'latest_version.txt' 'latest_version_william.txt'
	pass=readlines('ftp_info.txt');
    ftpobj = ftp('shared03.keymachine.de','ftp_kh_27973_1',pass);
	cd(ftpobj,'PIVlab');
	mput(ftpobj,fullfile(pwd, update_file_name));
	mput(ftpobj,fullfile(pwd, 'latest_version_p.txt'));
	mput(ftpobj,fullfile(pwd, 'latest_version_standalone.txt'));
	mput(ftpobj,fullfile(pwd, 'latest_version_william.txt'));
	mput(ftpobj,fullfile(pwd, 'starred_feature.txt'));

	close(ftpobj);
	fprintf('Version file contents:')
	type(update_file_name)
	type('starred_feature.txt')
	delete(update_file_name)
	delete('starred_feature.txt');
	delete('latest_version_p.txt')
	delete('latest_version_standalone.txt')
	delete('latest_version_william.txt')
end
end

function williamcleanTask(~)
clearvars
try
    rmpref('PIVlab_ad','enable_ad')
catch
end
try
    rmpref('PIVlab_ad','video_warn')
catch
end
load ('PIVlab_capture_resources\PIVlab_capture_lensconfig.mat');
selected_lens_config_nr = 4; %set default to OPTOcam
lens_configurations("Pitch_Offset",2) = {0};
lens_configurations("Roll_Offset",2) = {0};
save ('PIVlab_capture_resources\PIVlab_capture_lensconfig.mat','lens_configurations','selected_lens_config_nr');
clear
try
    rmdir('+wOFV\Filter matrices\', 's')
catch
    disp('Filter matrices directory does not exist')
end
try
    rmdir('Toolbox', 's')
catch
    disp('old Toolbox directory does not exist')
end
load('PIVlab_settings_default.mat');
clear homedir
clear pathname
clear ac_ROI_general
clear Chronos_IP
clear last_selected_device
clear selected_com_port
build_date='';
save('PIVlab_settings_default.mat');
warning off
delete ('PIVlab_capture_resources\laser_device_id.mat');
delete ('+plot\fastLICFunction.mexw64')
warning on
end