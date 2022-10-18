% PIVlab - Digital Particle Image Velocimetry Tool for MATLAB
% developed by Dr. William Thielicke and Prof. Dr. Eize J. Stamhuis
% programmed with MATLAB Version 7.10 (R2010a) - latest
% March 09, 2010 - today
% http://PIVlab.blogspot.com
% Third party content, thank you for your contributions!
% 3-point gaussian sub-pixel estimator by Uri Shavit, Roi Gurka, Alex Liberzon
% inpaint_nans by John D'Errico
% uipickfiles by Douglas Schwarz
% smoothn, dctn, idctn by Damien Garcia
% Ellipse by D.G. Long
% NaN Suite by Jan Glaescher
% Exportfig by Ben Hinkle
% mmstream2 by Duane Hanselman
% f_readB16 by Carl Hall
function PIVlab_GUI(desired_num_cores,batch_session_file)
%% Make figure
fh = findobj('tag', 'hgui');
if isempty(fh)
	MainWindow = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','INITIALIZING...','Toolbar','none','Units','normalized','Position',[0.05 0.1 0.9 0.8],'ResizeFcn', @MainWindow_ResizeFcn,'CloseRequestFcn', @MainWindow_CloseRequestFcn,'tag','hgui','visible','off','KeyPressFcn', @key_press);
	set (MainWindow,'Units','Characters');
	%clc
	%% Initialize
	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(MainWindow,handles)
	setappdata(0,'hgui',MainWindow);
	version = '2.59';
	put('PIVver', version);
	v=ver('MATLAB');
	%splashscreen = figure('integerhandle','off','resize','off','windowstyle','modal','numbertitle','off','MenuBar','none','DockControls','off','Name','INITIALIZING...','Toolbar','none','Units','pixels','Position',[10 10 100 100],'tag','splashscreen','visible','on','handlevisibility','off');movegui(splashscreen,'center');drawnow;
	disp(['-> Starting PIVlab ' version ' ...'])
	disp(['-> Using MATLAB version ' v.Version ' ' v.Release ' on ' computer '.'])

	margin=1.5;
	panelwidth=37;
	panelheighttools=12;
	panelheightpanels=35;
	do_correlation_matrices=0; % enable or disable the output of raw correlation matrices
	put('do_correlation_matrices',do_correlation_matrices);
	put('panelwidth',panelwidth);
	put('margin',margin);
	put('panelheighttools',panelheighttools);
	put('panelheightpanels',panelheightpanels);
	put('quickwidth',panelwidth);
	put('quickheight',3.2);
	put('quickvisible',1);
	put('alreadydisplayed',0);
	put('video_selection_done',0);

	%% check write access

	try
		temp=rand(3,3);
		save('temp.mat','temp');
		if ispc %Matlab seems to have issues with deleting files on unix systems
			delete 'temp.mat'
		end
		disp('-> Write access in current folder ok.')
	catch
		disp(['-> No write access in ' pwd '. PIVlab won''t work like this.'])
	end


	%% Load defaults
	try
		psdfile=which('PIVlab_settings_default.mat');
		dindex=strfind(psdfile,filesep); %filesep ist '\'
		read_panel_width('PIVlab_settings_default.mat',psdfile(1:(dindex(end)-1)));
	catch
		try
			disp(['Could not load default settings in this path: ' psdfile(1:(dindex(end)-1))])
		catch
		end
		disp('Could not load default settings. But this doesn''t really matter.')
	end
	%% check required files
	[tempfilepath,~,~] = fileparts(mfilename('fullpath'));
	addpath(fullfile(tempfilepath, 'PIVlab_capture_resources'));
	try
		ctr=0;
		pivFiles = {'dctn.m' 'idctn.m' 'inpaint_nans.m' 'piv_DCC.m' 'piv_FFTmulti.m' 'PIVlab_preproc.m' 'PIVlab_postproc.m' 'PIVlablogo.jpg' 'smoothn.m' 'uipickfiles.m' 'PIVlab_settings_default.mat' 'hsbmap.mat' 'parula.mat' 'ellipse.m' 'nanmax.m' 'nanmin.m' 'nanstd.m' 'nanmean.m' 'exportfig.m' 'fastLICFunction.m' 'icons.mat' 'mmstream2.m' 'PIVlab_citing.fig' 'PIVlab_citing.m' 'icons_quick.mat' 'f_readB16.m' 'vid_import.m' 'vid_hint.jpg' 'PIVlab_capture_pco.m' 'PIVlab_image_filter.m' 'pivparpool.m' 'pivprogress.m' 'piv_analysis.m' 'piv_quick.m' 'PIVlab_notch_filter.m' 'PIVlab_correlation_filter.m' 'PIVlab_capture_devicectrl_GUI.m' 'PIVlab_capture_lensctrl_GUI.m' 'PIVlab_capture_lensctrl.m' 'PIVlab_capture_sharpness_indicator.m'};
		for i=1:size(pivFiles,2)
			if exist(pivFiles{1,i},'file')~=2
				disp(['ERROR: A required file was not found: ' pivFiles{1,i}]);
				beep;
			else
				ctr=ctr+1;
			end
		end
		if ctr==size(pivFiles,2)
			disp('-> All required files found.')
		end
	catch
		disp('-> Problem detecting required files.')
	end
	%%
	generateUI
	generateMenu

	%% Prepare axes
	switchui('multip01');
	axes1=axes('units','characters');
	axis image;
	set(gca,'ActivePositionProperty','outerposition');%,'Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');
	set(MainWindow, 'Name',['PIVlab ' retr('PIVver')])% ' by William Thielicke and Eize J. Stamhuis'])

	%%
	Lena
	%% Check Matlab version
	try
		if verLessThan('matlab', '7.10.0') == 0
			disp('-> Matlab version check ok.')
		else
			disp('WARNING: Your Matlab version might be too old for running PIVlab.')
		end
	catch
		disp('MATLAB version could not be checked automatically. You need at least version 7.10.0 (R2010a) to run PIVlab.')
	end
	%% Check image toolbox availability
	try
		result=license('checkout','Image_Toolbox');
		if result == 1
			try
				J = adapthisteq(rand(8,8));
				disp('-> Image Processing Toolbox found.')
			catch
				disp(' ')
				disp('Image Processing Toolbox not accessible! PIVlab won''t work like this.')
				disp('A license has been found, but the toolbox could not be accessed.')
				disp('This is not a PIVlab related issue. Before you can use PIVlab, you need to make sure that the following command can be run without error message from the MATLAB command line:')
				disp('"J = adapthisteq(rand(8,8))" (enter this without quotes)')
				disp(' ')
				disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
				commandwindow
				pause
			end
		else
			disp('ERROR: Image Processing Toolbox not found! PIVlab won''t work like this.')
			disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
			commandwindow
			pause
		end
		%% Check parallel computing toolbox availability
		put('parallel',0);
		try %checking for a parallel license file throws a huge error message wheh it is not available. This might scare users... Better: Try...catch block
			if ~exist('desired_num_cores','var') %no input argument --> use all existing cores
				if pivparpool('size')<=0 %no exisitng pool
					pivparpool('open',feature('numCores')); %use all cores
				end
				put('parallel',1);
			else%parameter supplied
				if desired_num_cores > 1 && desired_num_cores ~= pivparpool('size') %desired doesn't match existing pool
					if desired_num_cores > feature('numCores')%desired too many cores
						desired_num_cores=feature('numCores');
						disp('Selected too many cores. Adjusted to actually existing cores')
					end
					pivparpool('close')
					pivparpool('open',desired_num_cores);
					put('parallel',1);
				elseif desired_num_cores < 2 %leq than 1 core desired --> serial processing.
					pivparpool('close')
					put('parallel',0);
				elseif desired_num_cores==pivparpool('size')
					put('parallel',1);
				end
			end
			if retr('parallel')==1
				disp(['-> Distributed Computing Toolbox found. Parallel pool (' int2str(pivparpool('size')) ' workers) active (default settings).'])
			else
				disp('-> Distributed Computing disabled.')
			end
		catch
			disp('-> Running without parallelization (no distributed computing toolbox installed).')
		end
	catch
		disp('Toolboxes could not be checked automatically. You need the Image Processing Toolbox.')
	end

	%% Variable initialization
	put ('toggler',0);
	put('calu',1);
	put('calv',1);
	put('calxy',1);
	put('offset_x_true',0)
	put('offset_y_true',0)
	put('subtr_u', 0);
	put('subtr_v', 0);
	put('displaywhat',1);%vectors


	%% read current and last directory.....:
	warning('off','all') %if the variables don't exist, an ugly warning is displayed
	load('PIVlab_settings_default.mat','homedir');
	load('PIVlab_settings_default.mat','pathname');
	warning('on','all')
	warning('off','serialport:serialport:ReadlineWarning')
	if ~exist('pathname','var') || ~exist('homedir','var')
		try
			if exist(fullfile(fileparts(mfilename('fullpath')) , 'Examples'),'dir') == 7 %if no previous path -> check if example dir exists
				homedir=fullfile(fileparts(mfilename('fullpath')) , 'Examples'); %... and use it as default
				pathname=homedir;
				disp('-> No previous path found, using default path.')
			else %if example path doesnt exist -> use current directory
				homedir=pwd;
				pathname=pwd;
				disp(['-> Start up path: ' pwd])
			end
		catch %if something goes wrong -> use current dir
			homedir=pwd;
			pathname=pwd;
			disp(['-> Start up path: ' pwd])
		end
	else
		if exist(pathname ,'dir') ~= 7 %stored path doesnt exist -> replace with default
			homedir=pwd;
			pathname=pwd;
		end
		disp(['-> Start up path: ' pathname])
	end
	put('homedir',homedir);
	put('pathname',pathname);
	save('PIVlab_settings_default.mat','homedir','pathname','-append');

	%% Read and apply default settings
	try
		%XP Wu modification:
		psdfile=which('PIVlab_settings_default.mat');
		dindex=strfind(psdfile,filesep); %filesep ist '\'
		%erstes argument datei, zweites pfad bis zum letzten fileseperator.
		read_settings('PIVlab_settings_default.mat',psdfile(1:(dindex(end)-1)));
		disp(['-> Got default settings from: ' psdfile])
	catch
		disp('Could not load default settings. But this doesn''t really matter.')
	end
	%%

	%%
	CheckUpdates
	SetFullScreen

	displogo(1);drawnow;
	set(MainWindow, 'Visible','on');
	%% Batch session  processing in GUI
	if ~exist('batch_session_file','var') %no input argument --> no GUI batch processing
		put('batchModeActive',0)
	else
		if exist (batch_session_file,'file')
			[filepath,name,ext] = fileparts(batch_session_file);
			load_session_Callback (1,batch_session_file)
			disp('')
			disp(['Batch mode, analyzing ' batch_session_file])
			batch_session_file_output=fullfile(filepath,[name '_BATCH' ext]);
			disp(['Output will be saved as:  ' batch_session_file_output ])
			disp('...running PIV analysis...')
			do_analys_Callback
			AnalyzeAll_Callback
			disp('...running post processing...')
			apply_filter_all_Callback
			disp('...saving output...')
			save_session_Callback(1,batch_session_file_output)

			put('batchModeActive',1)
			disp('done, exiting...')
			MainWindow_CloseRequestFcn
		else
			disp(['NOT FOUND: ' batch_session_file])
			put('batchModeActive',0)
		end
	end

else %Figure handle does already exist --> bring PIVlab to foreground.
	disp('Only one instance of PIVlab is allowed to run.')
	figure(fh)
end
function generateMenu
%% Menu items
m1 = uimenu('Label','File');
uimenu(m1,'Label','New session','Callback',@loadimgs_Callback,'Accelerator','N');
m2 = uimenu(m1,'Label','Load');
uimenu(m2,'Label','Import PIVlab settings','Callback',@load_settings_Callback);
uimenu(m2,'Label','Load PIVlab session','Separator','on','Callback',@load_session_Callback);
m3 = uimenu(m1,'Label','Save');
uimenu(m3,'Label','Export PIVlab settings','Callback',@curr_settings_Callback);
uimenu(m3,'Label','Save PIVlab session','Separator','on','Callback',@save_session_Callback);
m14 = uimenu(m1,'Label','Export');
uimenu(m14,'Label','Image or movie (jpg, avi, bmp, eps, pdf)','Callback',@save_movie_Callback);
uimenu(m14,'Label','Text file (ASCII)','Callback',@ascii_chart_Callback);
uimenu(m14,'Label','MAT file','Callback',@matlab_file_Callback);
uimenu(m14,'Label','Tecplot file','Callback',@tecplot_file_Callback);
uimenu(m14,'Label','Paraview binary VTK','Callback',@paraview_Callback);
uimenu(m14,'Label','All results to Matlab workspace','Callback',@write_workspace_Callback);
uimenu(m1,'Label','Preferences','Callback',@preferences_Callback);
m4 = uimenu(m1,'Label','Exit','Separator','on','Callback',@exitpivlab_Callback);
m51 = uimenu('Label','Image acquisition');
uimenu(m51,'Label','Capture PIV images','Callback',@capture_images_Callback);
m5 = uimenu('Label','Image settings');
uimenu(m5,'Label','Exclusions (ROI, mask)','Callback',@img_mask_Callback,'Accelerator','E');
uimenu(m5,'Label','Image pre-processing','Callback',@pre_proc_Callback,'Accelerator','I');
m6 = uimenu('Label','Analysis');
uimenu(m6,'Label','PIV settings','Callback',@piv_sett_Callback,'Accelerator','S');
uimenu(m6,'Label','ANALYZE!','Callback',@do_analys_Callback,'Accelerator','A');
m7 = uimenu('Label','Calibration');
uimenu(m7,'Label','Calibrate using current or external image','Callback',@cal_actual_Callback,'Accelerator','Z');
m8 = uimenu('Label','Post-processing');
uimenu(m8,'Label','Velocity based validation','Callback',@vector_val_Callback,'Accelerator','V');
uimenu(m8,'Label','Image based validation','Callback',@image_val_Callback);
m9 = uimenu('Label','Plot');
uimenu(m9,'Label','Spatial: Derive parameters / modify data','Callback',@plot_derivs_Callback,'Accelerator','D');
uimenu(m9,'Label','Temporal: Derive parameters','Callback',@plot_temporal_derivs_Callback);
uimenu(m9,'Label','Modify plot appearance','Callback',@modif_plot_Callback,'Accelerator','M');
uimenu(m9,'Label','Streamlines','Callback',@streamlines_Callback);
uimenu(m9,'Label','Markers / distance / angle','Callback',@dist_angle_Callback,'Accelerator','T');
m10 = uimenu('Label','Extractions');
uimenu(m10,'Label','Parameters from poly-line','Callback',@poly_extract_Callback,'Accelerator','P');
uimenu(m10,'Label','Parameters from area','Callback',@area_extract_Callback,'Accelerator','Q');
m11 = uimenu('Label','Statistics');
uimenu(m11,'Label','Statistics','Callback',@statistics_Callback,'Accelerator','B');
m12 = uimenu('Label','Synthetic particle image generation');
uimenu(m12,'Label','Settings','Callback',@part_img_sett_Callback,'Accelerator','G');
m13 = uimenu('Label','Help / Referencing');
uimenu(m13,'Label','List keyboard shortcuts','Callback',@shortcuts_Callback);
uimenu(m13,'Label','How to cite PIVlab','Callback',@howtocite_Callback);
uimenu(m13,'Label','Forum','Callback',@Forum_Callback);
uimenu(m13,'Label','Tutorial / getting started','Callback',@pivlabhelp_Callback,'Accelerator','H');
uimenu(m13,'Label','About','Callback',@aboutpiv_Callback);
uimenu(m13,'Label','Website','Callback',@Website_Callback);
menuhandles = findall(getappdata(0,'hgui'),'type','uimenu'); %das soll gemacht werden laut Hilfe
set(menuhandles,'HandleVisibility','off');
disp('-> Menu generated.')

function SetFullScreen
MainWindow=getappdata(0,'hgui');
if verLessThan('matlab','9.4') %r2018a
	if verLessThan('matlab','9.2') %dont know exactly in which release this was supported, 9.2 is a safe assumption
		set (MainWindow,'Units','pixels');
		set(0,'Units','pixels')
		scnsize = get(0,'ScreenSize');
		position = get(MainWindow,'Position');
		outerpos = get(MainWindow,'OuterPosition');
		borders = outerpos - position;
		edge = -borders(1)/2;
		pos1 = [edge, edge+25, scnsize(3) - edge,scnsize(4)-25];
		set(MainWindow,'OuterPosition',pos1)
		set (MainWindow,'Units','Characters');
	else
		try
			warning off
			frame_h = get(handle(gcf),'JavaFrame'); %#ok<*JAVFM>
			set(frame_h,'Maximized',1);
		catch
		end
	end
else
	try
		set(MainWindow,'WindowState','maximized');
	catch
	end
end
warning on

function Lena
MainWindow=getappdata(0,'hgui');
if strncmp (date,'15-Oct',6)
	yr=date;
	since=str2num(yr(8:11))-2005;
	questdlg(['Loving Lena since ' num2str(since) ' years today!'],'It''s 15th of October!','Congratulations!','Congratulations!'); % #FallsNochRelevant
	set(MainWindow, 'Name','Today it''s Lena-day!!')
end

function CheckUpdates
% Check for updates
version=retr('PIVver');
filename_update = 'latest_version.txt';
if retr('parallel')==1
	current_url = 'http://william.thielicke.org/PIVlab/latest_version_p.txt';
else
	current_url = 'http://william.thielicke.org/PIVlab/latest_version.txt';
end
starred_feature_url='http://william.thielicke.org/PIVlab/starred_feature.txt';
filename_starred='starred_feature.txt';
% Update checking inspired by: https://www.mathworks.com/matlabcentral/fileexchange/64294-photoannotation
update_msg = 'Could not check for updates'; %default message will be overwritten by the following lines
starred_feature_text='';
put('update_msg_color',[0 0 0.75]);
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
		put('update_msg_color',[0 0.75 0]);
	elseif str2num (strrep(version,'.','')) < str2num(strrep(web_version,'.',''))
		update_msg = ['PIVlab is outdated. Please update to version ' web_version sprintf('\n') starred_feature_text];
		put('update_msg_color',[0.85 0 0]);
	elseif str2num (strrep(version,'.','')) > str2num(strrep(web_version,'.',''))
		update_msg = ['Your PIVlab version is newer than the latest official release.'];
		put('update_msg_color',[0.5 0.5 0]);
	end
catch
	%Either the download failed, or the file downloaded is empty.
	update_msg = 'Could not check for updates';
	put('update_msg_color',[0.75 0.75 0]);
end
clear filename_update current_url fileID_update outfilename web_version trash_upd
disp (['-> ' update_msg])
put('update_msg',update_msg);

%close(splashscreen)
%movegui(MainWindow,'center')

function key_press(~, event) %General (currently hidden, respectively not documented) keyboard shortcuts in PIVlab
%display currently pressed key name:
%disp(event.Key)
if size(event.Modifier,2)==2 && strcmp(event.Modifier{1},'shift') && strcmp(event.Modifier{2},'control') %ctrl and shift modifiers
	if strcmp(event.Key,'c')
		crosshair_enabled=retr('crosshair_enabled');
		if isempty(crosshair_enabled)
			crosshair_enabled=0;
		end
		put('crosshair_enabled',1-crosshair_enabled);
	elseif strcmp(event.Key,'x')
		sharpness_enabled=retr('sharpness_enabled');
		if isempty(sharpness_enabled)
			sharpness_enabled=0;
		end
		put('sharpness_enabled',1-sharpness_enabled); % only autofocs OR sharpness display must be enabled at a time
	elseif strcmp(event.Key,'hyphen') %minus key
		ac_upper_clim = retr('ac_upper_clim');
		if ac_upper_clim < 2^16
			ac_upper_clim = ac_upper_clim + 5000;
		end
		put('ac_upper_clim',ac_upper_clim);
		put('ac_lower_clim',0);
		caxis([0 ac_upper_clim])
	elseif strcmp(event.Key,'0') %plus
		ac_upper_clim = retr('ac_upper_clim');
		if ac_upper_clim > 5000
			ac_upper_clim = ac_upper_clim - 5000;
		end
		put('ac_upper_clim',ac_upper_clim);
		put('ac_lower_clim',0);
		caxis([0 ac_upper_clim])
	elseif strcmp(event.Key,'k')
		if strmatch (get(gca,'ColorScale'),'log') %#ok<*MATCH2>
			set(gca,'ColorScale','linear')
		else
			set(gca,'ColorScale','log')
		end
	elseif strcmp(event.Key,'h') %
		hist_enabled=retr('hist_enabled');
		if isempty(hist_enabled)
			hist_enabled=0;
		end
		put('hist_enabled',1-hist_enabled);
	end
end

function destroyUI
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
MainWindow=getappdata(0,'hgui');
guidata(MainWindow,handles)
controls = findall(MainWindow,'type','uicontrol');
panels = findall(MainWindow,'type','uipanel');
delete(controls)
delete(panels)
disp('-> UI deleted.')

function generateUI % All the GUI elements are created here
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
MainWindow=getappdata(0,'hgui');
guidata(MainWindow,handles)

panelwidth=retr('panelwidth');
margin=retr('margin');
panelheighttools=retr('panelheighttools');
panelheightpanels=retr('panelheightpanels');
Figure_Size = get(MainWindow, 'Position');

%% Toolspanel
handles.tools = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-panelheighttools-margin panelwidth panelheighttools],'title','Tools', 'Tag','tools','fontweight','bold');
parentitem=get(handles.tools, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text29 = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Current point:');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.u_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','u_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.v_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','v_cp');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.x_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','x_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.y_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','y_cp');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.scalar_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','scalar_cp');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.filenameshow = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','filenameshow');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.fileselector = uicontrol(handles.tools,'Style','slider','units', 'characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'max',4,'min',1,'value',1,'sliderstep',[0.5 1],'Callback',@fileselector_Callback,'tag','fileselector','TooltipString','Step through your frames here');%,'Interruptible','off','busyaction','cancel');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.togglepair = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], 'string','Toggle','Callback',@togglepair_Callback,'tag','togglepair','TooltipString','Toggle images within a frame');%,'Interruptible','off','busyaction','cancel');

item=[parentitem(3)/2 item(2)+item(4) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.zoomon = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@zoomon_Callback,'tag','zoomon','TooltipString','Zoom');

item=[parentitem(3)/2+parentitem(3)/2/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.panon = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@panon_Callback,'tag','panon','TooltipString','Pan');

load icons.mat
set(handles.zoomon, 'cdata',zoompic);
set(handles.panon, 'cdata',panpic);


%% Quick access
iconwidth=5;
iconheight=2;
iconamount=6;
quickwidth = retr('quickwidth')-iconwidth-0.5;
quickheight = retr('quickheight');

handles.quick = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight],'title','Main tasks quick access', 'Tag','quick','fontweight','bold','Visible','on');
handles.quick1 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[1*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick1_Callback,'tag','quick1','TooltipString','Load images');
handles.quick2 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[2*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick2_Callback,'tag','quick2','TooltipString','ROI, Mask');
handles.quick3 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[3*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick3_Callback,'tag','quick3','TooltipString','Pre-processing');
handles.quick4 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[4*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick4_Callback,'tag','quick4','TooltipString','PIV settings');
handles.quick5 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[5*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick5_Callback,'tag','quick5','TooltipString','Analyze');
handles.quick6 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[6*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@quick6_Callback,'tag','quick6','TooltipString','Calibrate');

load icons_quick.mat
set(handles.quick1, 'cdata',loadpic);
set(handles.quick2, 'cdata',maskpic);
set(handles.quick3, 'cdata',prepic);
set(handles.quick4, 'cdata',settpic);
set(handles.quick5, 'cdata',anapic);
set(handles.quick6, 'cdata',calpic);


%% Multip01
handles.multip01 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Input data (CTRL+N)', 'Tag','multip01','fontweight','bold');
parentitem=get(handles.multip01, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.loadimgsbutton = uicontrol(handles.multip01,'Style','pushbutton','String','Load images','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@loadimgsbutton_Callback,1,[]},'Tag','loadimgsbutton','TooltipString','Load image data');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.loadvideobutton = uicontrol(handles.multip01,'Style','pushbutton','String','Load video','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @loadvideobutton_Callback,'Tag','loadvideobutton','TooltipString','Load video file');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 1];
handles.text2 = uicontrol(handles.multip01,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image list:');

item=[0 item(2)+item(4) parentitem(3) 12];
handles.filenamebox = uicontrol(handles.multip01,'Style','ListBox','units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','-empty-','Callback',@filenamebox_Callback,'tag','filenamebox','TooltipString','This list displays the frames that you currently loaded');

item=[0 item(2)+item(4) parentitem(3) 7];
handles.text4 = uicontrol(handles.multip01,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Use the scrollbar in the "Tools" panel to cycle through the images.');

item=[0 item(2)+item(4) parentitem(3) 4];
handles.imsize = uicontrol(handles.multip01,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','imsize');

%% Multip02
handles.multip02 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Exclusions (CTRL+E)', 'Tag','multip02','fontweight','bold');
parentitem=get(handles.multip02, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 12];
handles.uipanel5 = uipanel(handles.multip02, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Region of interest', 'Tag','uipanel5','fontweight','bold');

parentitem=get(handles.uipanel5, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.roi_hint = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','ROI inactive','tag','roi_hint');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.roi_select = uicontrol(handles.uipanel5,'Style','pushbutton','String','Select ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @roi_select_Callback,'Tag','roi_select','TooltipString','Draw a rectangle for selecting a region of interest');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_roi = uicontrol(handles.uipanel5,'Style','pushbutton','String','Clear ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_roi_Callback,'Tag','clear_roi','TooltipString','Remove the ROI');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/5 1.5];
handles.text155 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','x:');

item=[parentitem(3)/4 item(2) parentitem(3)/5 1.5];
handles.text156 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','y:');

item=[parentitem(3)/4*2 item(2) parentitem(3)/3 1.5];
handles.text157 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','width:');

item=[parentitem(3)/4*3 item(2) parentitem(3)/3 1.5];
handles.text158 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','height:');

item=[parentitem(3)/4*0+margin item(2)+item(4) parentitem(3)/4 1.5];
handles.ROI_Man_x = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_x','Callback',@ROI_Man_x_Callback);

item=[parentitem(3)/4*1+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_y = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_y','Callback',@ROI_Man_y_Callback);

item=[parentitem(3)/4*2+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_w = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_w','Callback',@ROI_Man_w_Callback);

item=[parentitem(3)/4*3+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_h = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_h','Callback',@ROI_Man_h_Callback);

item=[0 0 0 0];
parentitem=get(handles.multip02, 'Position');
item=[0 12+margin/2 parentitem(3) 20];
handles.uipanel6 = uipanel(handles.multip02, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Object mask', 'Tag','uipanel6','fontweight','bold');

parentitem=get(handles.uipanel6, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.mask_hint = uicontrol(handles.uipanel6,'Style','text','units','characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Mask inactive','tag','mask_hint');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.draw_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Draw mask(s) for current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @draw_mask_Callback,'Tag','draw_mask','TooltipString','Draw a mask for the current frame');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1.5];
handles.maskToSelected = uicontrol(handles.uipanel6,'Style','pushbutton','String','Apply current mask(s) to frames...','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @maskToSelected_Callback,'Tag','maskToSelected','TooltipString','Apply the mask that is currently displayed to other frames');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text154 = uicontrol(handles.uipanel6,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Apply to frames:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.maskapplyselect = uicontrol(handles.uipanel6,'Style','edit','units','characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1:end','tag','maskapplyselect','TooltipString','e.g. 1:10,15:17');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.clear_current_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Clear current mask(s)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_current_mask_Callback,'Tag','clear_current_mask','TooltipString','Remove all masks of the current frame');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.clear_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Clear all masks','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_mask_Callback,'Tag','clear_mask','TooltipString','Remove all masks of the whole session');

%--
item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.save_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Save mask','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @save_mask_Callback,'Tag','save_mask','TooltipString','Save all masks of the current session to a single file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.load_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Load mask','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @load_mask_Callback,'Tag','load_mask','TooltipString','Load PIVlab mask(s) and replace all masks in the current session. Can also be used to extract existing masks from previously saved PIVlab sessions.');

%--
item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.external_mask = uicontrol(handles.uipanel6,'Style','pushbutton','String','Load external masks','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @external_mask_Callback,'Tag','external_mask','TooltipString','Load a series of black and white TIF images');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.external_mask_progress = uicontrol(handles.uipanel6,'Style','text','Horizontalalignment', 'left','String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','external_mask_progress');


%% Multip03
handles.multip03 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image pre-processing (CTRL+I)', 'Tag','multip03','fontweight','bold');
parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.clahe_enable = uicontrol(handles.multip03,'Style','checkbox', 'value',1, 'String','Enable CLAHE','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','clahe_enable','TooltipString','Contrast limited adaptive histogram equalization: Enhances contrast, should be enabled');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text8 = uicontrol(handles.multip03,'Style','text', 'String','Window size [px]','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text8');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.clahe_size = uicontrol(handles.multip03,'Style','edit', 'String','64','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','clahe_size','TooltipString','Size of the tiles for CLAHE. Default setting is fine in most cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.enable_highpass = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Enable highpass','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enable_highpass','TooltipString','Highpass the image data. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text9 = uicontrol(handles.multip03,'Style','text', 'String','Kernel size [px]','Units','characters','HorizontalAlignment','right', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text9');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.highp_size = uicontrol(handles.multip03,'Style','edit', 'String','15','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highp_size','TooltipString','Kernel size of the lowpass filtered image that is subtracted from the original image');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.enable_intenscap = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Enable intensity capping','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enable_intenscap','TooltipString','Intensity capping. Only needed for some special cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.wienerwurst = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Wiener2 denoise and low pass','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','wienerwurst','TooltipString','Wiener denoise filter and Gaussian low pass. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text159 = uicontrol(handles.multip03,'Style','text', 'String','Window size [px]','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text159');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.wienerwurstsize = uicontrol(handles.multip03,'Style','edit', 'String','15','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','wienerwurstsize','TooltipString','Window size of the Wiener denoise filter');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.Autolimit = uicontrol(handles.multip03,'Style','checkbox', 'value',1, 'String','Auto contrast stretch','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','Autolimit','TooltipString','Automatic stretching of the image intensity histogram. Important for 16-bit images.');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text162 = uicontrol(handles.multip03,'Style','text', 'String','minimum:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text162');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text163 = uicontrol(handles.multip03,'Style','text', 'String','maximum:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text163');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.minintens = uicontrol(handles.multip03,'Style','edit', 'String','0','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','minintens','Callback',@maxintens_Callback,'TooltipString','Lower bound of the histogram [0...1]');

item=[parentitem(3)/2 item(2) parentitem(3)/3*1 1];
handles.maxintens = uicontrol(handles.multip03,'Style','edit', 'String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','maxintens','Callback',@minintens_Callback,'TooltipString','Upper bound of the histogram [0...1]');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 5];
handles.uipanel351 = uipanel(handles.multip03, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Background Subtraction', 'Tag','uipanel351','fontweight','bold');
parentitem=get(handles.uipanel351, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.bg_subtract = uicontrol(handles.uipanel351,'Style','checkbox', 'value',0, 'String','Subtract mean intensity','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','bg_subtract','Callback',@bg_subtract_Callback, 'TooltipString','Automatic stretching of the image intensity histogram. Important for 16-bit images.');
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.bg_view = uicontrol(handles.uipanel351,'Style','pushbutton','String','View background image','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @bg_view_Callback,'Tag','bg_view','TooltipString','Display the generated background image. Click again to toggle between background A and B.');

parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+26 parentitem(3) 2];
handles.preview_preprocess = uicontrol(handles.multip03,'Style','pushbutton','String','Apply and preview current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preview_preprocess_Callback,'Tag','preview_preprocess','TooltipString','Preview the effect of image pre-processing');

item=[0+item(3)/2 item(2)+item(4) parentitem(3)/2 1.5];
handles.export_preprocess = uicontrol(handles.multip03,'Style','pushbutton','String','Export preview','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @export_preprocess_Callback,'Tag','export_preprocess','TooltipString','Export the preprocessed image (use toggle button to switch between image A and B)');


%% Multip04
handles.multip04 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','PIV settings (CTRL+S)', 'Tag','multip04','fontweight','bold');
parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];
%neu
item=[0 item(2)+item(4) parentitem(3)/4 1.5];
handles.textSuggest = uicontrol(handles.multip04,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Help:','tag','textSuggest');

item=[parentitem(3)/4 item(2) parentitem(3)/1.85 1.5];
handles.SuggestSettings = uicontrol(handles.multip04,'Style','pushbutton','String','Suggest settings','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @countparticles,'Tag','SuggestSettings','TooltipString','Suggest PIV settings based on image data in current frame');

item=[0 item(2)+item(4) parentitem(3) 6.5];
handles.uipanel35 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','PIV algorithm', 'Tag','uipanel35','fontweight','bold');

parentitem=get(handles.uipanel35, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.fftmulti = uicontrol(handles.uipanel35,'Style','radiobutton','value',1,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','FFT window deformation','tag','fftmulti','Callback',@fftmulti_Callback,'TooltipString','FFT based multipass algorithm');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.ensemble = uicontrol(handles.uipanel35,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Ensemble correlation','tag','ensemble','Callback',@ensemble_Callback,'TooltipString','Ensemble window deformation correlation. For micro PIV and other sparesly seeded flow.');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.dcc = uicontrol(handles.uipanel35,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','DCC (deprecated)','tag','dcc','Callback',@dcc_Callback,'TooltipString','DCC based single pass algorithm. Not recommended anymore');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 8 parentitem(3) 5];
handles.uipanel41 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Pass 1', 'Tag','uipanel41','fontweight','bold');

parentitem=get(handles.uipanel41, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text11 = uicontrol(handles.uipanel41,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Interrogation area [px]','tag','text11');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.text12 = uicontrol(handles.uipanel41,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Step [px]','tag','text12');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.intarea = uicontrol(handles.uipanel41,'Style','edit', 'String','64','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@intarea_Callback,'Tag','intarea','TooltipString','Interrogation window edge length of the first pass. Should be < 0.25 times your maximum displacement');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.step = uicontrol(handles.uipanel41,'Style','edit', 'String','32','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@step_Callback,'Tag','step','TooltipString','Horizontal and vertical offset or step of the interrogation windows. Usually this is 50 % of the interrogation window edge length (interrogation area)');

item=[parentitem(3)/3*2 item(2)+item(4) parentitem(3)/3*1 1];
handles.steppercentage = uicontrol(handles.uipanel41,'Style','text', 'String','N/A','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','steppercentage');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 13 parentitem(3) 10];
handles.uipanel42 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Pass 2...4', 'Tag','uipanel42','fontweight','bold');

parentitem=get(handles.uipanel42, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text129 = uicontrol(handles.uipanel42,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Interrogation area [px]','tag','text129');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.text130 = uicontrol(handles.uipanel42,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Step [px]','tag','text130');

item=[0 item(2)+item(4)+margin/6 parentitem(3)/2.5 1];
handles.checkbox26 = uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 2','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox26','Callback',@checkbox26_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit50 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@edit50_Callback,'Tag','edit50','TooltipString','Second pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text126 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text126');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1];
handles.checkbox27= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 3','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox27','Callback',@checkbox27_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit51 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@edit51_Callback,'Tag','edit51','TooltipString','Third pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text127 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text127');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1];
handles.checkbox28= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 4','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox28','Callback',@checkbox28_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit52 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@edit52_Callback,'Tag','edit52','TooltipString','Fourth pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text128 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text128');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.repeat_last= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Repeat last pass until','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@repeat_last_Callback,'Tag','repeat_last','TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text128x = uicontrol(handles.uipanel42,'Style','text', 'String','quality slope <','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text128x');

item=[parentitem(3)/2 item(2) parentitem(3)/3.5 1];
handles.edit52x = uicontrol(handles.uipanel42,'Style','edit', 'String','0.025','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@edit52x_Callback,'Tag','edit52x','TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 5+5+11.5+1.5+margin/3 parentitem(3) 1];
handles.text14 = uicontrol(handles.multip04,'Style','text', 'String','Sub-pixel estimator','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text14');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.subpix = uicontrol(handles.multip04,'Style','popupmenu', 'String',{'Gauss 2x3-point','2D Gauss'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','subpix','TooltipString','Subpixel estimation technique. 2D Gauss is supposed to be more accurate for image data that contains motion blur, but there is hardly a difference');

%item=[0 item(2)+item(4)+margin parentitem(3) 1];
%handles.Repeated_box = uicontrol(handles.multip04,'Style','checkbox', 'String','5 x repeated correlation','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','Repeated_box','TooltipString','With very bad image data, enabling the repeated correlation will enhance data yield. But it''s pretty slow');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.mask_auto_box = uicontrol(handles.multip04,'Style','checkbox', 'String','Disable auto-correlation','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','mask_auto_box','TooltipString','This will disallow displacements close to zero. It helps when there is a very strong background signal');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1];
handles.text914 = uicontrol(handles.multip04,'Style','text', 'String','Correlation robustness','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text914');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1];
handles.CorrQuality = uicontrol(handles.multip04,'Style','popupmenu', 'String',{'Standard (recommended)','High','Extreme'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','CorrQuality','TooltipString','Correlation quality. Better = slower...');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1.5];
handles.Settings_Apply_current = uicontrol(handles.multip04,'Style','pushbutton','String','Analyze current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @AnalyzeSingle_Callback,'Tag','Settings_Apply_current','TooltipString','Apply PIV settings to current frame');

%% Multip05
handles.multip05 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Analyze (CTRL+A)', 'Tag','multip05','fontweight','bold');
parentitem=get(handles.multip05, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.AnalyzeSingle = uicontrol(handles.multip05,'Style','pushbutton','String','Analyze current frame','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @AnalyzeSingle_Callback,'Tag','AnalyzeSingle','TooltipString','Perform PIV analysis for current frame');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.AnalyzeAll = uicontrol(handles.multip05,'Style','pushbutton','String','Analyze all frames','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @AnalyzeAll_Callback,'Tag','AnalyzeAll','TooltipString','Perform PIV analyses for all frames');

item=[0 item(2)+item(4) parentitem(3)/4*2.5 1.5];
handles.update_display_checkbox = uicontrol(handles.multip05,'Style','checkbox', 'value',1, 'String','Refresh display','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','update_display_checkbox','TooltipString','Refresh the display during the analysis. Disabling it will increase processing speed.');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1.5];
handles.cancelbutt = uicontrol(handles.multip05,'Style','pushbutton','String','Cancel','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @cancelbutt_Callback,'Tag','cancelbutt','TooltipString','Cancel analysis');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.clear_everything = uicontrol(handles.multip05,'Style','pushbutton','String','Clear all results','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_everything_Callback,'Tag','clear_everything','TooltipString','Clear all results');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.progress = uicontrol(handles.multip05,'Style','text','String','Frame progress: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','progress');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.overall = uicontrol(handles.multip05,'Style','text','String','Total progress: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','overall');

item=[0 item(2)+item(4)+margin*3 parentitem(3) 2];
handles.totaltime = uicontrol(handles.multip05,'Style','text','String','Time left: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','totaltime');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.messagetext = uicontrol(handles.multip05,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','messagetext');

%% Multip06
handles.multip06 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Vector validation (CTRL+V)', 'Tag','multip06','fontweight','bold');
parentitem=get(handles.multip06, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.vel_limit = uicontrol(handles.multip06,'Style','pushbutton','String','Select velocity limits','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @vel_limit_Callback,'Tag','vel_limit','TooltipString','Display a velocity scatter plot and draw a window around the allowed velocities');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.meanofall = uicontrol(handles.multip06,'Style','checkbox','Value',1,'String','display all frames in scatterplot','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanofall','TooltipString','Use velocity data of all frames in the velocity scatter plot');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.vel_limit_active = uicontrol(handles.multip06,'Style','text','String','Limit inactive','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','vel_limit_active');

item=[0 item(2)+item(4) parentitem(3) 3];
handles.limittext = uicontrol(handles.multip06,'Style','text','String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','limittext');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.clear_vel_limit = uicontrol(handles.multip06,'Style','pushbutton','String','Clear velocity limits','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_vel_limit_Callback,'Tag','clear_vel_limit','TooltipString','Remove the velocity limits');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.stdev_check = uicontrol(handles.multip06,'Style','checkbox','String','Standard deviation filter','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','stdev_check','TooltipString','Filter velocities by removing velocities that are outside the mean velocity +- n times the standard deviation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text18 = uicontrol(handles.multip06,'Style','text','String','Threshold [n*stdev]','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text18');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.stdev_thresh = uicontrol(handles.multip06,'Style','edit','String','4.7','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@stdev_thresh_Callback,'Tag','stdev_thresh','TooltipString','Threshold for the standard deviation filter. Velocities that are outside the mean velocity +- n times the standard deviation will be removed');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.loc_median = uicontrol(handles.multip06,'Style','checkbox','String','Local median filter','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','loc_median','TooltipString','Compares each vector to the median of the surrounding vectors. Discards vector if difference is above the selected threshold');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19 = uicontrol(handles.multip06,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.loc_med_thresh = uicontrol(handles.multip06,'Style','edit','String','3','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@loc_med_thresh_Callback,'Tag','loc_med_thresh');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.notch_filter = uicontrol(handles.multip06,'Style','checkbox','String','Magnitude notch filter','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','notch_filter','TooltipString','Notch filter: Discards velocities in the specified range from vL to vH');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchL = uicontrol(handles.multip06,'Style','text','String','vL','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','textnotchL');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_L_thresh = uicontrol(handles.multip06,'Style','edit','String','-1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@notch_L_thresh_Callback,'Tag','notch_L_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchH = uicontrol(handles.multip06,'Style','text','String','vH','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','textnotchH');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_H_thresh = uicontrol(handles.multip06,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@notch_H_thresh_Callback,'Tag','notch_H_thresh');

%item=[0 item(2)+item(4) parentitem(3)/3*2 1];
%handles.text20 = uicontrol(handles.multip06,'Style','text','String','Epsilon','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text20');

%item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
%handles.epsilon = uicontrol(handles.multip06,'Style','edit','String','0.1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@epsilon_Callback,'Tag','epsilon');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.rejectsingle = uicontrol(handles.multip06,'Style','pushbutton','String','Manually reject vector','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @rejectsingle_Callback,'Tag','rejectsingle','TooltipString','Manually remove vectors. Click on the base of the vectors that you want to discard');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.interpol_missing = uicontrol(handles.multip06,'Style','checkbox','String','Interpolate missing data','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpol_missing','TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors','Callback',@set_other_interpol_checkbox);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = uicontrol(handles.multip06,'Style','pushbutton','String','Apply to current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @apply_filter_current_Callback,'Tag','apply_filter_current','TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.apply_filter_all = uicontrol(handles.multip06,'Style','pushbutton','String','Apply to all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @apply_filter_all_Callback,'Tag','apply_filter_all','TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.restore_all = uicontrol(handles.multip06,'Style','pushbutton','String','Undo all validations (all frames)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @restore_all_Callback,'Tag','restore_all','TooltipString','Remove all velocity filters for all frames');

%% Multip07
handles.multip07 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Calibration (CTRL+Z)', 'Tag','multip07','fontweight','bold');
parentitem=get(handles.multip07, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.load_ext_img = uicontrol(handles.multip07,'Style','pushbutton','String','Load calibration image (optional)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @load_ext_img_Callback,'Tag','load_ext_img','TooltipString','Load a reference image for calibration (if you recorded one)');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.optimize_calib_img = uicontrol(handles.multip07,'Style','checkbox','Value',1,'String','Optimize display','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','optimize_calib_img','Callback',@optimize_calib_img_Callback, 'TooltipString','Enhance the display of the calibration image');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
uicontrol(handles.multip07,'Style','text','String','Setup Scaling','FontWeight','bold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.draw_line = uicontrol(handles.multip07,'Style','pushbutton','String','Select reference distance','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @draw_line_Callback,'Tag','draw_line','TooltipString','Draw a line as distance reference in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text26 = uicontrol(handles.multip07,'Style','text','String','Real distance [mm]','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text26');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.realdist = uicontrol(handles.multip07,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@realdist_Callback,'Tag','realdist','TooltipString','Enter the real world length of the line here (in millimeters)');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text27 = uicontrol(handles.multip07,'Style','text','String','time step [ms]','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.time_inp = uicontrol(handles.multip07,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@time_inp_Callback,'Tag','time_inp','TooltipString','Enter the delta t between two images here');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 7.5];
handles.uipanel_offsets = uipanel(handles.multip07, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Setup Offsets', 'Tag','uipanel_offsets','fontweight','bold');
parentitem=get(handles.uipanel_offsets, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27a = uicontrol(handles.uipanel_offsets,'Style','text','String','x increases towards the','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27a');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.x_axis_direction = uicontrol(handles.uipanel_offsets,'Style','popupmenu','String',{'right','left'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','x_axis_direction','TooltipString','Direction of the x axis');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27b = uicontrol(handles.uipanel_offsets,'Style','text','String','y increases towards the','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27b');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.y_axis_direction = uicontrol(handles.uipanel_offsets,'Style','popupmenu','String',{'bottom','top'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','y_axis_direction','TooltipString','Direction of the y axis');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 2];
handles.set_x_offset = uicontrol(handles.uipanel_offsets,'Style','pushbutton','String','Set x offset','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @set_offset_Callback,'Tag','set_x_offset','TooltipString','Click into your calibration image and tell PIVlab what physical x-coordinate this point represents.');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.set_y_offset = uicontrol(handles.uipanel_offsets,'Style','pushbutton','String','Set y offset','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @set_offset_Callback,'Tag','set_y_offset','TooltipString','Click into your calibration image and tell PIVlab what physical y-coordinate this point represents.');
item=[0 0 0 0];
parentitem=get(handles.multip07, 'Position');

item=[0 19.5 parentitem(3) 4];
handles.calidisp = uicontrol(handles.multip07,'Style','text','String','inactive','HorizontalAlignment','center','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calidisp');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_cali = uicontrol(handles.multip07,'Style','pushbutton','String','Apply calibration','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @apply_cali_Callback,'Tag','apply_cali','TooltipString','Apply calibration to the whole session');
item=[0 item(2)+item(4)+margin*0.5 parentitem(3) 2];
handles.clear_cali = uicontrol(handles.multip07,'Style','pushbutton','String','Clear calibration','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @clear_cali_Callback,'Tag','clear_cali','TooltipString','Remove calibration');

%% Multip08
handles.multip08 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Derive Parameters (CTRL+D)', 'Tag','multip08','fontweight','bold');
parentitem=get(handles.multip08, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text33 = uicontrol(handles.multip08,'Style','text','String','Display Parameter','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text33');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.derivchoice = uicontrol(handles.multip08,'Style','popupmenu','String','N/A','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@derivchoice_Callback,'Tag','derivchoice','TooltipString','Select the parameter that you want to display as colour-coded overlay');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.LIChint1 = uicontrol(handles.multip08,'Style','text','String','LIC resolution','Units','characters','visible','off', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','LIChint1');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.licres = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.05 0.05],'max',2,'min',0.1,'value',0.7,'String','Display Parameter','visible','off','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','licres','TooltipString','Resolution of the LIC image. Higher values take longer to calculate','Callback',@licres_Callback);

item=[parentitem(3)/2+parentitem(3)/3 item(2) parentitem(3)/4 1];
handles.LIChint2 = uicontrol(handles.multip08,'Style','text','String','0.7','Units','characters', 'visible','off','HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','LIChint2');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.smooth = uicontrol(handles.multip08,'Style','checkbox','String','Smooth data','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','smooth','TooltipString','Enable smoothing of noisy data. Uses "smoothn" by Damien Garcia');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text32 = uicontrol(handles.multip08,'Style','text','String','Strength:','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text32');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.smoothstr = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.2 0.2],'max',11,'min',1,'value',1,'Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','smoothstr','TooltipString','Strength of smoothing. More information is displayed in Matlabs command window when you clicked "Apply"');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text34 = uicontrol(handles.multip08,'Style','text','String','Subtract flow','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text34');

item=[0 item(2)+item(4) parentitem(3)/3 1];
handles.text35 = uicontrol(handles.multip08,'Style','text','String','u:','Units','characters', 'HorizontalAlignment','right','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text35');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1];
handles.subtr_u = uicontrol(handles.multip08,'Style','edit','String','0','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@subtr_u_Callback,'Tag','subtr_u','TooltipString','Subtract a constant u velocity (horizontal) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.mean_u = uicontrol(handles.multip08,'Style','pushbutton','String','mean u','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@mean_u_Callback,'Tag','mean_u','TooltipString','Subtract the mean u velocity from the results');

item=[0 item(2)+item(4) parentitem(3)/3 1];
handles.text36 = uicontrol(handles.multip08,'Style','text','String','v:','Units','characters', 'HorizontalAlignment','right','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text36');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1];
handles.subtr_v = uicontrol(handles.multip08,'Style','edit','String','0','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@subtr_v_Callback,'Tag','subtr_v','TooltipString','Subtract a constant v velocity (vertical) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.mean_v = uicontrol(handles.multip08,'Style','pushbutton','String','mean v','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@mean_v_Callback,'Tag','mean_v','TooltipString','Subtract the mean v velocity from the results');

item=[0 item(2)+item(4)+margin parentitem(3)/2 1];
handles.text41 = uicontrol(handles.multip08,'Style','text','String','Colormap limits','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text41');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.autoscaler = uicontrol(handles.multip08,'Style','checkbox','String','autoscale','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@autoscaler_Callback,'Tag','autoscaler','TooltipString','Autoscale the color map, so that it is stretched to the min and max of each frame. Should be DISABLED when rendering videos etc.');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text39 = uicontrol(handles.multip08,'Style','text','String','min:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text39');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text40 = uicontrol(handles.multip08,'Style','text','String','max:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text40');

item=[0 item(2)+item(4) parentitem(3)/4 1];
handles.mapscale_min = uicontrol(handles.multip08,'Style','edit','String','-1','Enable','off','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@mapscale_min_Callback,'Tag','mapscale_min','TooltipString','Minimum of the color map');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.mapscale_max = uicontrol(handles.multip08,'Style','edit','String','1','Enable','off','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@mapscale_max_Callback,'Tag','mapscale_max','TooltipString','Maximum of the color map');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.highp_vectors = uicontrol(handles.multip08,'Style','checkbox','String','Highpass vector field','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highp_vectors','TooltipString','High-pass the vector field. Useful when you want to subtract a non-uniform background flow. The modified data is NOT saved');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text83 = uicontrol(handles.multip08,'Style','text','String','Strength:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text83');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.highpass_strength = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.1 0.1],'max',51,'min',1,'value',30,'Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highpass_strength','TooltipString','Strength of the high-pass. The modified data is NOT saved');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_deriv = uicontrol(handles.multip08,'Style','pushbutton','String','Apply to current frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@apply_deriv_Callback,'Tag','apply_deriv','TooltipString','Apply settings to current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_deriv_all = uicontrol(handles.multip08,'Style','pushbutton','String','Apply to all frames','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@apply_deriv_all_Callback, 'Tag','apply_deriv_all','TooltipString','Apply settings to all frames');
%{
item=[0 item(2)+item(4)+margin/3*2 parentitem(3) 7];
handles.uipanel43 = uipanel(handles.multip08, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calculate mean / sum', 'Tag','uipanel43','fontweight','bold');

parentitem=get(handles.uipanel43, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.text153 = uicontrol(handles.uipanel43,'Style','text','String','Frames to calc mean / sum:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text153');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.selectedFramesMean = uicontrol(handles.uipanel43,'Style','edit','String','1:end','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','selectedFramesMean','TooltipString','Select which frames to include for calculating the mean velocity. E.g. "1,3,4,8:10"');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.meanmaker = uicontrol(handles.uipanel43,'Style','pushbutton','String','Calc. mean','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 1}, 'Tag','meanmaker','TooltipString','Calculate mean velocities and append an extra frame with the results');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.summaker = uicontrol(handles.uipanel43,'Style','pushbutton','String','Calc. sum','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 0}, 'Tag','summaker','TooltipString','Calculate sum of displacements and append an extra frame with the results');
%}
%% Multip09
handles.multip09 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Modify plot appearance (CTRL+M)', 'Tag','multip09','fontweight','bold');
parentitem=get(handles.multip09, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.autoscale_vec = uicontrol(handles.multip09,'Style','checkbox','String','autoscale vectors','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@autoscale_vec_Callback,'Tag','autoscale_vec','TooltipString','Enable automatic scaling of the vector display');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text43 = uicontrol(handles.multip09,'Style','text','String','Vector scale','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text43');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1];
handles.vectorscale = uicontrol(handles.multip09,'Style','edit','String','8','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@vectorscale_Callback,'Tag','vectorscale','TooltipString','Manually enter a vector scale factor here');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text114 = uicontrol(handles.multip09,'Style','text','String','Vector line width','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text114');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.vecwidth = uicontrol(handles.multip09,'Style','edit','String','0.5','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@vecwidth_Callback,'Tag','vecwidth','TooltipString','Line width of the vectors');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text132 = uicontrol(handles.multip09,'Style','text','String','plot every nth vector, n =','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','tex132');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.nthvect = uicontrol(handles.multip09,'Style','edit','String','1','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','nthvect','TooltipString','If you are confused by the amount of arrows shown on the screen, then you can reduce the amount here.');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.suppress_vec = uicontrol(handles.multip09,'Style','checkbox','String','hide vectors','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@suppress_vec_Callback,'Tag','suppress_vec','TooltipString','Hide vectors in display');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text200 = uicontrol(handles.multip09,'Style','text','String','Mask transparency [%]','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text200');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.masktransp = uicontrol(handles.multip09,'Style','edit','String','50','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','masktransp','Callback',@masktransp_Callback,'TooltipString','Transparency of the masking area display (red)');

item=[0 item(2)+item(4)+margin/3 parentitem(3) 9.5];
handles.uipanel37 = uipanel(handles.multip09, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Vector colors', 'Tag','uipanel37','fontweight','bold');

parentitem=get(handles.uipanel37, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.text138 = uicontrol(handles.uipanel37,'Style','text','String',' R           G           B         [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text138');

item=[0 item(2)+item(4) parentitem(3)/5 1.5];
handles.validr = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.validg = uicontrol(handles.uipanel37,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.validb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.text139 = uicontrol(handles.uipanel37,'Style','text','String','valid vectors','Units','characters','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text139', 'fontsize', 6);

item=[0 item(2)+item(4) parentitem(3)/5 1.5];
handles.validdr = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.validdg = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.validdb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.text142 = uicontrol(handles.uipanel37,'Style','text','String','vectors on derivatives','HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text142', 'fontsize', 6);

item=[0 item(2)+item(4) parentitem(3)/5 1.5];
handles.interpr = uicontrol(handles.uipanel37,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.interpg = uicontrol(handles.uipanel37,'Style','edit','String','0.5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.interpb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.text140 = uicontrol(handles.uipanel37,'Style','text','String','interpolated vectors','HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text142', 'fontsize', 6);

parentitem=get(handles.multip09, 'Position');
item=[0 9.5+6.5 parentitem(3) 12];
handles.uipanel27 = uipanel(handles.multip09, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Derived parameter appearance', 'Tag','uipanel27','fontweight','bold');

parentitem=get(handles.uipanel27, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text143 = uicontrol(handles.uipanel27,'Style','text','String','Color map','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143');

item=[0+item(3) item(2) parentitem(3)/2 1];
handles.text143a = uicontrol(handles.uipanel27,'Style','text','String','Steps','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143a');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.colormap_choice = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'Parula','HSV','Jet','HSB','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Lines'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_choice','TooltipString','Select the color map for displaying derived parameters here');

item=[0+item(3) item(2) parentitem(3)/2 1];
handles.colormap_steps = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'256','128','64','32','16','8','4','2'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_steps','TooltipString','Select the amount of colors in a colormap');

item=[0 item(2)+item(4)+margin/3*2 parentitem(3)/5*3 1];
handles.text143b = uicontrol(handles.uipanel27,'Style','text','String','Image interpolation','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143b');

item=[0+item(3) item(2)-0.2 parentitem(3)/5*2 1];
handles.colormap_interpolation = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'bilinear','bicubic','nearest'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_interpolation','TooltipString','Image interpolation method for displaying the derived parameters. Default is bilinear');

%item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.img_not_mask = uicontrol(handles.uipanel27,'Style','checkbox','String','Do not display mask','Units','characters','Visible','off','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_not_mask');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.displ_colorbar = uicontrol(handles.uipanel27,'Style','checkbox','String','Display color bar, position:','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','displ_colorbar','TooltipString','Display a colour bar for the derived parameters');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1];
handles.colorbarpos = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'South','North','East','West'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colorbarpos','TooltipString','Position of the colour bar');


item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.text144 = uicontrol(handles.uipanel27,'Style','text','String','Colorbar label color:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text144');


item=[0 item(2)+item(4)+margin/6 parentitem(3) 1];
handles.colorbarcolor = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'k','w','y','b','r'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colorbarcolor','TooltipString','Colour of the text etc. of the colour bar');

parentitem=get(handles.multip09, 'Position');
item=[0 0 0 0];
item=[0 9.5+4+14+margin parentitem(3) 1];
handles.enhance_images = uicontrol(handles.multip09,'Style','checkbox','String','Enhance PIV image display','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enhance_images','TooltipString','Improve contrast of PIV images for display');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.dummy = uicontrol(handles.multip09,'Style','pushbutton','String','Apply','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@dummy_Callback,'Tag','dummy','TooltipString','Apply the settings');

%% Multip10
handles.multip10 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Export as text file (ASCII)', 'Tag','multip10','fontweight','bold');
parentitem=get(handles.multip10, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.addfileinfo = uicontrol(handles.multip10,'Style','checkbox','String','Add file information','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','addfileinfo','TooltipString','Add information like image file names etc. to the output file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.add_header = uicontrol(handles.multip10,'Style','checkbox','String','Add column headers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','add_header','TooltipString','Add a header for each column');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.export_vort = uicontrol(handles.multip10,'Style','checkbox','String','Include derivatives','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','export_vort','TooltipString','Calculate and export derivatives');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.delimitertext = uicontrol(handles.multip10,'Style','text','String','Delimiter:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','delimitertext');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1];
handles.delimiter = uicontrol(handles.multip10,'Style','popupmenu','String',{'comma','tab','space'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','delimiter','TooltipString','Select the delimiter here');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_current = uicontrol(handles.multip10,'Style','pushbutton','String','Export current frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@ascii_current_Callback,'Tag','ascii_current','TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_all = uicontrol(handles.multip10,'Style','pushbutton','String','Export all frames','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@ascii_all_Callback,'Tag','ascii_all','TooltipString','Export data for all frames');


%% Multip11
handles.multip11 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as MATLAB file', 'Tag','multip11','fontweight','bold');
parentitem=get(handles.multip11, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin parentitem(3) 6];
handles.matlab_text = uicontrol(handles.multip11,'Style','text','String','The files will only include the derivatives that you calculated in the ''Plot -> Derive parameters'' panel. If you did not calculate any derivatives, then the corresponding fields will be empty.','Units','characters','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','matlab_text');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_current = uicontrol(handles.multip11,'Style','pushbutton','String','Export current frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_mat_current_Callback,'Tag','save_mat_current','TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_all = uicontrol(handles.multip11,'Style','pushbutton','String','Export all frames','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_mat_all_Callback,'Tag','save_mat_all','TooltipString','Export data for all frames');

%% Multip12
handles.multip12 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Extract parameters from poly-line', 'Tag','multip12','fontweight','bold');
parentitem=get(handles.multip12, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.text55 = uicontrol(handles.multip12,'Style','text','String','Draw a line or circle and extract derived parameters from it.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text55');

item=[0 item(2)+item(4) parentitem(3) 7];
handles.text91 = uicontrol(handles.multip12,'Style','text','String','Draw a poly-line by clicking with left mouse button. Right mouse button ends the poly-line. Draw a circle by clicking twice with the left mouse button: First click is for the centre, second click for radius.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text91');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text57 = uicontrol(handles.multip12,'Style','text','String','Type:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text57');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.draw_what = uicontrol(handles.multip12,'Style','popupmenu','String',{'polyline','circle','circle series (tangent vel. only)'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@draw_what_Callback,'Tag','draw_what','TooltipString','Select the type of object that you want to draw and extract data from');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.draw_stuff = uicontrol(handles.multip12,'Style','pushbutton','String','Draw!','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@draw_stuff_Callback,'Tag','draw_stuff','TooltipString','Draw the object that you selected above');

%%new buttons, load and save polylines
item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.save_polyline = uicontrol(handles.multip12,'Style','pushbutton','String','Save coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_polyline_Callback,'Tag','save_polyline','TooltipString','Save poly line coordinates to *.mat file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.load_polyline = uicontrol(handles.multip12,'Style','pushbutton','String','Load coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@load_polyline_Callback,'Tag','load_polyline','TooltipString','Load poly line coordinates from *.mat file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text56 = uicontrol(handles.multip12,'Style','text','String','Parameter:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text56');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.extraction_choice = uicontrol(handles.multip12,'Style','popupmenu','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extraction_choice_Callback,'Tag','extraction_choice','TooltipString','What parameter do you want to extract along the line / circle?');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 1];
handles.text58 = uicontrol(handles.multip12,'Style','text','String','Nr. of interpolated points:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text58');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.nrpoints = uicontrol(handles.multip12,'Style','edit','String','300','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','nrpoints','TooltipString','Resolution of the line / circle');

item=[0 item(2)+item(4)+margin parentitem(3)/2 2];
handles.plot_data = uicontrol(handles.multip12,'Style','pushbutton','String','Plot data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot_data_Callback,'Tag','plot_data','TooltipString','When you finished drawing a line / circle, you can plot data along the line / circle by pushing this button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_plot = uicontrol(handles.multip12,'Style','pushbutton','String','Clear data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@clear_plot_Callback,'Tag','clear_plot','TooltipString','Clear line / circle data');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.iLoveLenaMaliaAndLine = uicontrol(handles.multip12,'Style','text','String','Save extraction(s)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','iLoveLenaMaliaAndLine');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.extractLineAll = uicontrol(handles.multip12,'Style','checkbox','String','extract and save for all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extractLineAll','TooltipString','Extract data for all frames of the current session');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.save_data = uicontrol(handles.multip12,'Style','pushbutton','String','Save result as text file(s)','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_data_Callback,'Tag','save_data','TooltipString','Extract data and save results to a text file');

%% Multip13
handles.multip13 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Measure distance & angle (CTRL+T)', 'Tag','multip13','fontweight','bold');
parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 10];
handles.uipanel40 = uipanel(handles.multip13, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Distance & angle', 'Tag','uipanel40','fontweight','bold');

parentitem=get(handles.uipanel40, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.set_points = uicontrol(handles.uipanel40,'Style','pushbutton','String','Set points','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@set_points_Callback,'Tag','set_points','TooltipString','Set two points by clicking twice in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text50 = uicontrol(handles.uipanel40,'Style','text','String','Length red:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text50');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltax = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','deltax');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text51 = uicontrol(handles.uipanel40,'Style','text','String','Length blue:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text51');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltay = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','deltay');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text52 = uicontrol(handles.uipanel40,'Style','text','String','Length green:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text52');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.length = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','length');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text53 = uicontrol(handles.uipanel40,'Style','text','String','Angle red/green [째]:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text53');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.alpha = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','alpha');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text54 = uicontrol(handles.uipanel40,'Style','text','String','Angle blue/green [째]:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text54');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.beta = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','beta');

parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];
item=[0 11 parentitem(3) 10];
handles.uipanel39 = uipanel(handles.multip13, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Markers', 'Tag','uipanel39','fontweight','bold');

parentitem=get(handles.uipanel39, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 3];
handles.text146 = uicontrol(handles.uipanel39,'Style','text','String','Highlight points in the analyses. The markers will be memorized even if a new session is started.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text146');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.putmarkers = uicontrol(handles.uipanel39,'Style','pushbutton','String','Set markers','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@putmarkers_Callback,'Tag','putmarkers','TooltipString','Click in the image to place markers. End by clicking the right mouse button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.delmarkers = uicontrol(handles.uipanel39,'Style','pushbutton','String','Clear markers','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@delmarkers_Callback,'Tag','delmarkers','TooltipString','Clear all markers');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.holdmarkers = uicontrol(handles.uipanel39,'Style','checkbox','String','Hold markers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','holdmarkers','TooltipString','Memorize markers even when a new session is started. Will be cleared only when you restart PIVlab');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.displmarker = uicontrol(handles.uipanel39,'Style','checkbox','String','Display markers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@displmarker_Callback,'Tag','displmarker','TooltipString','Show or hide the markers');

%% Multip14
handles.multip14 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Statistics (CTRL+B)', 'Tag','multip14','fontweight','bold');
parentitem=get(handles.multip14, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text59 = uicontrol(handles.multip14,'Style','text','String','mean u:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text59');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.meanu = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanu');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text60 = uicontrol(handles.multip14,'Style','text','String','mean v:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text60');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.meanv = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanv');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text67 = uicontrol(handles.multip14,'Style','text','String','Histogram plot','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text67');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.hist_select = uicontrol(handles.multip14,'Style','popupmenu','String',{'u velocity','v velocity','velocity magnitude'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','hist_select','TooltipString','What data to display in a histogram plot');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.text66 = uicontrol(handles.multip14,'Style','text','String','bins:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text66');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.nrofbins = uicontrol(handles.multip14,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','nrofbins','TooltipString','Nr. of bins in the histogram plot');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.histdraw = uicontrol(handles.multip14,'Style','pushbutton','String','Histogram','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@histdraw_Callback,'Tag','histdraw','TooltipString','Draw a histogram');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.scatterplotter = uicontrol(handles.multip14,'Style','pushbutton','String','Scatter plot u & v','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@scatterplotter_Callback,'Tag','scatterplotter','TooltipString','Scatter plot u vs. v velocities');

%% Multip15
handles.multip15 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Particle image generation (CTRL+G)', 'Tag','multip15','fontweight','bold');
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text68 = uicontrol(handles.multip15,'Style','text','String','Flow simulation:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text68');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.flow_sim = uicontrol(handles.multip15,'Style','popupmenu','String',{'Rankine vortex','Hamel-Oseen vortex','Linear shift','Rotation','Membrane'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@flow_sim_Callback,'Tag','flow_sim','TooltipString','Select the velocity field for the simulation here');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text77 = uicontrol(handles.multip15,'Style','text','String','Image size x [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text77');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.img_sizex = uicontrol(handles.multip15,'Style','edit','String','800','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_sizex','TooltipString','Image width in pixels');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text96 = uicontrol(handles.multip15,'Style','text','String','Image size y [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text96');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.img_sizey = uicontrol(handles.multip15,'Style','edit','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_sizey','TooltipString','Image height in pixels');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 8];
handles.uipanel24 = uipanel(handles.multip15, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Particle simulation', 'Tag','uipanel24','fontweight','bold');

parentitem=get(handles.uipanel24, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text70 = uicontrol(handles.uipanel24,'Style','text','String','Nr. of particles','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text70');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_am = uicontrol(handles.uipanel24,'Style','edit','String','200000','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@part_am_Callback,'Tag','part_am','TooltipString','Amount of particles used for the simulation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text71 = uicontrol(handles.uipanel24,'Style','text','String','Particle diameter [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text71');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_size = uicontrol(handles.uipanel24,'Style','edit','String','3','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@part_size_Callback,'Tag','part_size','TooltipString','Mean particle image diameter');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text72 = uicontrol(handles.uipanel24,'Style','text','String','Random size [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text72');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_var = uicontrol(handles.uipanel24,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@part_var_Callback,'Tag','part_var','TooltipString','Particle image diameter variation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text98 = uicontrol(handles.uipanel24,'Style','text','String','Sheet thickness [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text98');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.sheetthick = uicontrol(handles.uipanel24,'Style','edit','String','0.5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@sheetthick_Callback,'Tag','sheetthick','TooltipString','Simulated laser sheet thickness. A thinner light sheet sheds more light on each particle');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text73 = uicontrol(handles.uipanel24,'Style','text','String','Noise','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text73');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_noise = uicontrol(handles.uipanel24,'Style','edit','String','0.001','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@part_noise_Callback,'Tag','part_noise','TooltipString','Simulated image sensor noise');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text115 = uicontrol(handles.uipanel24,'Style','text','String','Random z position [%]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text115');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_z = uicontrol(handles.uipanel24,'Style','edit','String','10','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@part_z_Callback,'Tag','part_z','TooltipString','Movement of the particles perpendicular to the light sheet (out-of-plane motion)');

%rankinepanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.rankinepanel = uipanel(handles.multip15, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Rankine vortex', 'Tag','rankinepanel','fontweight','bold');

parentitem=get(handles.rankinepanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.singledoublerankine = uicontrol(handles.rankinepanel,'Style','popupmenu','String',{'Single vortex','Vortex pair'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@singledoublerankine_Callback,'Tag','singledoublerankine','TooltipString','Simulate a single vortex or a vortex pair');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text74 = uicontrol(handles.rankinepanel,'Style','text','String','Core radius [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text74');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rank_core = uicontrol(handles.rankinepanel,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@rank_core_Callback,'Tag','rank_core','TooltipString','Radius of the solid body rotation core');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text75 = uicontrol(handles.rankinepanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text75');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rank_displ = uicontrol(handles.rankinepanel,'Style','edit','String','8','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@rank_displ_Callback,'Tag','rank_displ','TooltipString','Maximum displacement of particles in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text99 = uicontrol(handles.rankinepanel,'Style','text','String','Vortex1 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text99');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text102 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','Vortex2 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text102');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text100 = uicontrol(handles.rankinepanel,'Style','text','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text100');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.rankx1 = uicontrol(handles.rankinepanel,'Style','edit','String','200','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@rankx1_Callback,'Tag','rankx1','TooltipString','x-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text103 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text103');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.rankx2 = uicontrol(handles.rankinepanel,'Style','edit','Visible','off','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@rankx2_Callback,'Tag','rankx2','TooltipString','x-centre of the second vortex');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text101 = uicontrol(handles.rankinepanel,'Style','text','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text101');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.ranky1 = uicontrol(handles.rankinepanel,'Style','edit','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@ranky1_Callback,'Tag','ranky1','TooltipString','y-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text104 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text104');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.ranky2 = uicontrol(handles.rankinepanel,'Style','edit','Visible','off','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@ranky2_Callback,'Tag','ranky2','TooltipString','y-centre of the second vortex');

%------------oseen panel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.oseenpanel = uipanel(handles.multip15, 'Units','characters','Visible','off', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Hamel-Oseen vortex', 'Tag','oseenpanel','fontweight','bold');

parentitem=get(handles.oseenpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.singledoubleoseen = uicontrol(handles.oseenpanel,'Style','popupmenu','String',{'Single vortex','Vortex pair'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@singledoubleoseen_Callback,'Tag','singledoubleoseen','TooltipString','Simulate a single vortex or a vortex pair');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text106 = uicontrol(handles.oseenpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text106');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.oseen_displ = uicontrol(handles.oseenpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseen_displ_Callback,'Tag','oseen_displ','TooltipString','Maximum displacement of the particles');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text113 = uicontrol(handles.oseenpanel,'Style','text','String','time [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text113');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.oseen_time = uicontrol(handles.oseenpanel,'Style','edit','String','0.05','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseen_time_Callback,'Tag','oseen_time','TooltipString','Time component of the Hamel-Oseen simulation: The vortex decays with vorticity when time increases');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text107 = uicontrol(handles.oseenpanel,'Style','text','String','Vortex1 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text107');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text110 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','Vortex2 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text110');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text108 = uicontrol(handles.oseenpanel,'Style','text','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text108');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseenx1 = uicontrol(handles.oseenpanel,'Style','edit','String','200','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseenx1_Callback,'Tag','oseenx1','TooltipString','x-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text111 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text111');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseenx2 = uicontrol(handles.oseenpanel,'Style','edit','Visible','off','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseenx2_Callback,'Tag','oseenx2','TooltipString','x-centre of the second vortex');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text109 = uicontrol(handles.oseenpanel,'Style','text','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text109');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseeny1 = uicontrol(handles.oseenpanel,'Style','edit','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseeny1_Callback,'Tag','oseeny1','TooltipString','y-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text112 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text112');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseeny2 = uicontrol(handles.oseenpanel,'Style','edit','Visible','off','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@oseeny2_Callback,'Tag','oseeny2','TooltipString','y-centre of the second vortex');

%rotationpanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.rotationpanel = uipanel(handles.multip15, 'Units','characters','Visible','off', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Rotation', 'Tag','rotationpanel','fontweight','bold');

parentitem=get(handles.rotationpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.text76 = uicontrol(handles.rotationpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text76');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rotationdislacement = uicontrol(handles.rotationpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@rotationdislacement_Callback,'Tag','rotationdislacement','TooltipString','Maximum displacement of the particles');

%linear shiftpanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.shiftpanel = uipanel(handles.multip15, 'Units','characters', 'Visible','off','Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Linear shift', 'Tag','shiftpanel','fontweight','bold');

parentitem=get(handles.shiftpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.text97 = uicontrol(handles.shiftpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text97');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.shiftdisplacement = uicontrol(handles.shiftpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@shiftdisplacement_Callback,'Tag','shiftdisplacement','TooltipString','Maximum displacement of the particles');
%--------------- rest unter panels
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 27 parentitem(3) 1];
handles.status_creation = uicontrol(handles.multip15,'Style','text','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','status_creation');


item=[0 item(2)+item(4) parentitem(3) 2];
handles.generate_it = uicontrol(handles.multip15,'Style','pushbutton','String','Create images','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@generate_it_Callback,'Tag','generate_it','TooltipString','Start particle simulation and create image pair');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.save_imgs = uicontrol(handles.multip15,'Style','pushbutton','String','Save images','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_imgs_Callback,'Tag','save_imgs','TooltipString','Save current set of particle simulation images (e.g. if you want to import them to PIVlab)');

%% Multip16
handles.multip16 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save image (sequence)', 'Tag','multip16','fontweight','bold');
parentitem=get(handles.multip16, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text87 = uicontrol(handles.multip16,'Style','text','String','First frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text87');

item=[ parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text88 = uicontrol(handles.multip16,'Style','text','String','Last frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text87');

item=[0 item(2)+item(4) parentitem(3)/3 1];
handles.firstframe = uicontrol(handles.multip16,'Style','edit','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','firstframe','TooltipString','First frame to export');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.lastframe = uicontrol(handles.multip16,'Style','edit','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','lastframe','TooltipString','Last frame to export');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.avifilesave = uicontrol(handles.multip16,'Style','radiobutton','value',1,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Animation (*.avi)','tag','avifilesave','Callback',@avifilesave_Callback,'TooltipString','Save animation in a single avi file');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.jpgfilesave = uicontrol(handles.multip16,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image (*.jpg)','tag','jpgfilesave','Callback',@jpgfilesave_Callback,'TooltipString','Save image (sequence) as jpg');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.bmpfilesave = uicontrol(handles.multip16,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image (*.bmp)','tag','bmpfilesave','Callback',@bmpfilesave_Callback,'TooltipString','Save image (sequence) as bmp');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.epsfilesave = uicontrol(handles.multip16,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image (*.eps)','tag','epsfilesave','Callback',@epsfilesave_Callback,'TooltipString','Save image (sequence) as eps');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.pdffilesave = uicontrol(handles.multip16,'Style','radiobutton','value',0,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image (*.pdf)','tag','pdffilesave','Callback',@pdffilesave_Callback,'TooltipString','Save image (sequence) as pdf');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.usecompr = uicontrol(handles.multip16,'Style','checkbox','units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','use compression','tag','usecompr','TooltipString','Compress the avi file. Reduces file size and image quality');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text86 = uicontrol(handles.multip16,'Style','text','String','Frames per second','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text86');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.fps_setting = uicontrol(handles.multip16,'Style','edit','String','20','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','fps_setting','TooltipString','Frame rate of the video file');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_only_one = uicontrol(handles.multip16,'Style','pushbutton','String','Save current frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@save_only_one_Callback,'Tag','save_only_one','TooltipString','Save image for current frame only');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.saveavi = uicontrol(handles.multip16,'Style','pushbutton','String','Save frame sequence','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@saveavi_Callback,'Tag','saveavi','TooltipString','Save image sequence for the selected frames');

%% Multip17
handles.multip17 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Extract parameters from area', 'Tag','multip17','fontweight','bold');
parentitem=get(handles.multip17, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 6];
handles.text90 = uicontrol(handles.multip17,'Style','text','String','Select desired parameter and type of area operation. Then click "Draw!" to specify the area with your mouse. Calculations are based on full cells inside the selected region.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text90');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text57 = uicontrol(handles.multip17,'Style','text','String','Type:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text57');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.areatype = uicontrol(handles.multip17,'Style','popupmenu','String',{'Area mean value','Area integral','Area size','Area integral series','Area weighted centroid','Area mean flow direction'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@areatype_Callback,'Tag','areatype','TooltipString','Select the type of operation that you want to perform with the area you will select');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text89 = uicontrol(handles.multip17,'Style','text','String','Parameter:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text89');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.area_para_select = uicontrol(handles.multip17,'Style','popupmenu','String',{'N/A'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','area_para_select','TooltipString','Select the parameter that you want to perform the selected operation with');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 6];
handles.text95 = uicontrol(handles.multip17,'Style','text','Visible','off','String',{'Selection procedure:','1st click: centre of structure','2nd click: upper limit','3rd click: lower limit','4th click: left limit','5th click: right limit'},'Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text95');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.usethreshold = uicontrol(handles.multip17,'Style','checkbox','Visible','off','String','Use threshold','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','usethreshold','TooltipString','Use a threshold for the operation: Only use data that fulfills the condition');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text93 = uicontrol(handles.multip17,'Style','text','Visible','off','String','Theshold','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text93');

item=[0 item(2)+item(4) parentitem(3)/4 1.5];
handles.smallerlarger = uicontrol(handles.multip17,'Style','popupmenu','Visible','off','String',{'>','<'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','smallerlarger','TooltipString','Condition for the threshold');

item=[parentitem(3)/4 item(2) parentitem(3)/3 1.5];
handles.thresholdarea = uicontrol(handles.multip17,'Style','edit','Visible','off','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@thresholdarea_Callback,'Tag','thresholdarea','TooltipString','Threshold value');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text94 = uicontrol(handles.multip17,'Style','text','Visible','off','String','Radius increase [%]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text94');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.radiusincrease = uicontrol(handles.multip17,'Style','edit','Visible','off','String','200','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@radiusincrease_Callback,'Tag','radiusincrease','TooltipString','When using the area integral series, the area will be gradually increased. The final amount of increase is selected here');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.savearea = uicontrol(handles.multip17,'Style','checkbox','String','     save result as text (ASCII) chart','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','savearea','TooltipString','Save the result of the area extraction as a (ASCII) file');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/5 1];
handles.extractareaall = uicontrol(handles.multip17,'Style','checkbox','String','','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extractareaall_Callback,'Tag','extractareaall','TooltipString','Perform the area extraction for all frames of the current session');

item=[parentitem(3)/5 item(2) parentitem(3)/5*4 2];
handles.text145 = uicontrol(handles.multip17,'Style','text','String','Do and save extractions for all frames','Units','characters', 'HorizontalAlignment','left','Position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text145');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.draw_area = uicontrol(handles.multip17,'Style','pushbutton','String','Draw area','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@draw_area_Callback,'Tag','draw_area','TooltipString','Draw the area by clicking with the left mouse button');

%% Multip18
handles.multip18 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Stream lines', 'Tag','multip18','fontweight','bold');
parentitem=get(handles.multip18, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 3];
handles.text117 = uicontrol(handles.multip18,'Style','text','String','Stream lines are global, that means that they apply to all frames of the current session.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text117');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.holdstream = uicontrol(handles.multip18,'Style','checkbox','String','hold streamlines','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','holdstream','TooltipString','If enabled, every streamline that you draw will be added to the list of streamlines, instead of overwriting the list of streamlines');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.drawstreamlines = uicontrol(handles.multip18,'Style','pushbutton','String','Draw stream lines','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@drawstreamlines_Callback,'Tag','drawstreamlines','TooltipString','Every click adds a streamline. End with a right click');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.streamrake = uicontrol(handles.multip18,'Style','pushbutton','String','Draw stream line rake','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@streamrake_Callback,'Tag','streamrake','TooltipString','Draw a rake of streamlines: First click is the starting point of the rake, second click is the end point');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 2];
handles.text118 = uicontrol(handles.multip18,'Style','text','String','Amount of stream lines on rake','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text118');

item=[parentitem(3)/3*2 item(2)+0.5 parentitem(3)/3 1];
handles.streamlamount = uicontrol(handles.multip18,'Style','edit','String','10','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlamount','TooltipString','Amount of streamlines on the rake');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.deletestreamlines = uicontrol(handles.multip18,'Style','pushbutton','String','Delete all stream lines','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@deletestreamlines_Callback,'Tag','deletestreamlines','TooltipString','Remove all streamlines');

item=[0 item(2)+item(4)+margin*3 parentitem(3)/2 1];
handles.text119 = uicontrol(handles.multip18,'Style','text','String','Color','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text119');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.streamlcolor = uicontrol(handles.multip18,'Style','popupmenu','String',{'y','r','b','k','w'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlcolor','TooltipString','Colour of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text120 = uicontrol(handles.multip18,'Style','text','String','Line width','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text120');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.streamlwidth = uicontrol(handles.multip18,'Style','popupmenu','String',{'1','2','3'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlwidth','TooltipString','Line width of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.applycolorwidth = uicontrol(handles.multip18,'Style','pushbutton','String','Apply color and width','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@applycolorwidth_Callback,'Tag','applycolorwidth','TooltipString','Apply the settings for colour and width');

%% Multip19
handles.multip19 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as Paraview VTK file', 'Tag','multip19','fontweight','bold');
parentitem=get(handles.multip19, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 2];
handles.paraview_current = uicontrol(handles.multip19,'Style','pushbutton','String','Save current frame','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@paraview_current_Callback,'Tag','paraview_current','TooltipString','Save current frame as Paraview file');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.paraview_all = uicontrol(handles.multip19,'Style','pushbutton','String','Save all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@paraview_all_Callback,'Tag','paraview_all','TooltipString','Save all frames as Paraview files');

%% Multip20
handles.multip20 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as TECPLOT file', 'Tag','multip20','fontweight','bold');
parentitem=get(handles.multip20, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.export_vort_tec = uicontrol(handles.multip20,'Style','checkbox','String','Include derivatives','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','export_vort_tec','TooltipString','Include derivatives like vorticity etc. in the exported file');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.tecplot_current = uicontrol(handles.multip20,'Style','pushbutton','String','Save current frame','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@tecplot_current_Callback,'Tag','tecplot_current','TooltipString','Save current frame only as Tecplot file');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.tecplot_all = uicontrol(handles.multip20,'Style','pushbutton','String','Save all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@tecplot_all_Callback,'Tag','tecplot_all','TooltipString','Save all frames as Tecplot files');

%% Multip21
handles.multip21 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Preferences', 'Tag','multip21','fontweight','bold');
parentitem=get(handles.multip21, 'Position');
item=[0 0 0 0]; %reset positioning

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
handles.paneltext = uicontrol(handles.multip21,'Style','text','String','Width of the panels','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.panelslider = uicontrol(handles.multip21,'Style','slider','max',50,'min',30,'sliderstep',[0.05 0.05],'Value',37,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','panelslider','TooltipString','Width of the panel that you see on the left side');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.pref_apply = uicontrol(handles.multip21,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@pref_apply_Callback,'Tag','prefapply','TooltipString','Apply the new width. All data from the UI will be cleared');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = uicontrol(handles.multip21,'Style','text','String','If some button texts are clipped or not readable, try to increase the panelwidth here.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext2');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = uicontrol(handles.multip21,'Style','text','String','Warning: Current results and settings will be cleared.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext2');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.paneltext3 = uicontrol(handles.multip21,'Style','text','String','Change font size','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext3');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.textsizeup = uicontrol(handles.multip21,'Style','pushbutton','String','Increase','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@font_size_change,1},'Tag','textsizeup','TooltipString','Increase the text size of buttons etc.');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.textsizedown = uicontrol(handles.multip21,'Style','pushbutton','String','Decrease','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@font_size_change,-1},'Tag','textsizedown','TooltipString','Decrease the text size of buttons etc');

item=[0 item(2)+item(4)+margin parentitem(3) 4];
handles.paneltext4 = uicontrol(handles.multip21,'Style','text','String','Please note: This setting will currently not be saved. Because otherwise this might screw up your user interface permanently.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext4');

%% Multip22
handles.multip22 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Derive Temporal Parameters', 'Tag','multip22','fontweight','bold');
parentitem=get(handles.multip22, 'Position');
item=[0 0 0 0];

%item=[0 item(2)+item(4)+margin/3*2 parentitem(3) 7];
%handles.uipanel43 = uipanel(handles.multip22, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calculate mean / sum', 'Tag','uipanel43','fontweight','bold');


item=[0 item(2)+item(4) parentitem(3) 2];
handles.text153 = uicontrol(handles.multip22,'Style','text','String','Frames to process:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text153');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.selectedFramesMean = uicontrol(handles.multip22,'Style','edit','String','1:end','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','selectedFramesMean','TooltipString','Select which frames to include for calculating the mean velocity. E.g. "1,3,4,8:10"');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.meanmaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate mean','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 1}, 'Tag','meanmaker','TooltipString','Calculate mean velocities and append an extra frame with the results');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.summaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate sum','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 0}, 'Tag','summaker','TooltipString','Calculate sum of displacements and append an extra frame with the results');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.stdmaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate stdev','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 2}, 'Tag','stdmaker','TooltipString','Calculate standard deviation of displacements and append an extra frame with the results');

%% multip23
handles.multip23 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image based validation', 'Tag','multip23','fontweight','bold');
parentitem=get(handles.multip23, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.do_contrast_filter = uicontrol(handles.multip23,'Style','checkbox','String','Filter low contrast','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_contrast_filter','TooltipString','This filter removes vectors from regions where the input image contrast is low.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19a = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19a');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.contrast_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.001','Units','characters', 'Fontunits','points','Callback',@contrast_filter_thresh_Callback, 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','contrast_filter_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_contrast_filter = uicontrol(handles.multip23,'Style','pushbutton','String','Suggest threshold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Finds a threshold that discards vectors in the regions where image contrast is low. Use this as a starting point only.','Tag','suggest_contrast_filter','Callback', @suggest_contrast_filter_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.do_bright_filter = uicontrol(handles.multip23,'Style','checkbox','String','Filter bright objects','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_bright_filter','TooltipString','This filter removes vectors from regions where the input image has connected bright objects.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19b = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19b');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.bright_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.001','Units','characters', 'Fontunits','points','Callback',@bright_filter_thresh_Callback,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','bright_filter_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_bright_filter = uicontrol(handles.multip23,'Style','pushbutton','String','Suggest threshold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Finds a threshold that discards vectors in the regions where bright objects are found. Use this as a starting point only.','Tag','suggest_bright_filter','Callback', @suggest_bright_filter_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.do_corr2_filter = uicontrol(handles.multip23,'Style','checkbox','String','Correlation coefficient filter','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_corr2_filter','TooltipString','This filter removes vectors from image areas that have a low correlation between image A and B. Especially useful after removing the background signal.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19corrfilter = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19corrfilter');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.corr_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.5','Units','characters', 'Fontunits','points','Callback',@corr_filter_thresh_Callback,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','corr_filter_thresh');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.interpol_missing2 = uicontrol(handles.multip23,'Style','checkbox','String','Interpolate missing data','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpol_missing2','TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors','Callback',@set_other_interpol_checkbox);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = uicontrol(handles.multip23,'Style','pushbutton','String','Apply to current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @apply_filter_current_Callback,'Tag','apply_filter_current','TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.apply_filter_all = uicontrol(handles.multip23,'Style','pushbutton','String','Apply to all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @apply_filter_all_Callback,'Tag','apply_filter_all','TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.restore_all = uicontrol(handles.multip23,'Style','pushbutton','String','Undo all validations (all frames)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @restore_all_Callback,'Tag','restore_all','TooltipString','Remove all velocity filters for all frames');

%% Multip24
% General
handles.multip24 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image Acquisition', 'Tag','multip24','fontweight','bold');
parentitem=get(handles.multip24, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 8.5];
handles.uipanelac_general = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','General settings', 'Tag','uipanelac_general','fontweight','bold');

parentitem=get(handles.uipanelac_general, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.ac_projecttxt = uicontrol(handles.uipanelac_general,'Style','text', 'String','Project path:','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_projecttxt');

item=[0 item(2)+item(4) parentitem(3)/1.5 1.5];
handles.ac_project = uicontrol(handles.uipanelac_general,'Style','edit','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ac_project');
set(handles.ac_project,'Fontsize', get(handles.ac_project,'Fontsize')-1);

item=[parentitem(3)/1.5 item(2) parentitem(3)/3 1.5];
handles.ac_browse = uicontrol(handles.uipanelac_general,'Style','pushbutton','String','Browse...','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_browse_Callback,'Tag','ac_browse','TooltipString','Browse for project folder. Images and configurations will be stored here.');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3) 1];
handles.ac_configtxt = uicontrol(handles.uipanelac_general,'Style','text', 'String','Select configuration:','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_configtxt');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.ac_config = uicontrol(handles.uipanelac_general,'Style','popupmenu', 'Value', 1, 'String',{'PIVlab SimpleSync + pco.pixelfly usb' 'PIVlab SimpleSync + pco.panda 26 DS' 'PIVlab LD-PS + pco.pixelfly usb' 'PIVlab LD-PS + pco.panda 26 DS' 'PIVlab LD-PS + Chronos' 'PIVlab LD-PS + Basler acA2000-165um' 'PIVlab LD-PS + FLIR FFY-U3-16S2M' 'PIVlab LD-PS + OPTOcam 2/80'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_config','TooltipString','Lists the available configurations (synchronizer + cameras)','Callback',@select_capture_config_Callback);

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.ac_comport = uicontrol(handles.uipanelac_general,'Style','popupmenu', 'String',{'COM1'},'Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_comport');

item=[parentitem(3)/2 item(2) parentitem(3)/2*0.9 1.5];
handles.ac_connect = uicontrol(handles.uipanelac_general,'Style','pushbutton','String','Connect','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_connect_Callback,'Tag','ac_connect','TooltipString','Connect to PIVlab-SimpleSync');

IndicatorPos=get(handles.ac_connect,'Position');

handles.ac_serialstatus = uicontrol(handles.uipanelac_general,'Style','edit','units','characters','HorizontalAlignment','center','position',[IndicatorPos(1)+IndicatorPos(3) IndicatorPos(2) 2 IndicatorPos(4)],'String','','tag','ac_serialstatus','BackgroundColor',[1 0 0],'Foregroundcolor',[1 1 1],'Enable','inactive','TooltipString','Status of the serial connection to PIVlab-SimpleSync');


% Sync control
parentitem=get(handles.multip24, 'Position');
item=[0 8.5 parentitem(3) 10.75+1];
handles.uipanelac_laser = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Synchronizer control', 'Tag','uipanelac_laser','fontweight','bold');

parentitem=get(handles.uipanelac_laser, 'Position');
item=[0 0 0 0];

item=[0 0 parentitem(3)/4*2.5 1];
handles.ac_fpstxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Frame rate [Hz]:','tag','ac_fpstxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_fps = uicontrol(handles.uipanelac_laser,'Style','popupmenu','String',{'5' '3' '1.5' '1'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_sync_settings_Callback,'Tag','ac_fps','TooltipString','Frame rate during PIV image capture','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2.5 1];
handles.ac_interpulstxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Pulse distance [탎]:','tag','ac_interpulstxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_interpuls = uicontrol(handles.uipanelac_laser,'Style','edit','String','1000','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_sync_settings_Callback,'Tag','ac_interpuls','TooltipString','Pulse spacing of the laser','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2.5 1];
handles.ac_powertxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Laser energy [%]:','tag','ac_powertxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_power = uicontrol(handles.uipanelac_laser,'Style','edit','String','10','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_sync_settings_Callback,'Tag','ac_power','TooltipString','Laser energy','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3) 1];
handles.ac_pulselengthtxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Pulse length: 0 탎','tag','ac_pulselengthtxt');


item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2 2];
handles.ac_laserstatus = uicontrol(handles.uipanelac_laser,'Style','edit','units','characters','HorizontalAlignment','center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','ac_laserstatus','FontName','FixedWidth','BackgroundColor',[1 0 0],'Foregroundcolor',[0 0 0],'Enable','inactive','Fontweight','bold','TooltipString','Status of the laser');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4*2 2];
handles.ac_lasertoggle = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Toggle Laser','Fontweight','bold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_lasertoggle_Callback,'Tag','ac_lasertoggle','TooltipString','Toggle laser on and off','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3)/2 1.5];
handles.ac_enable_ext_trigger = uicontrol(handles.uipanelac_laser,'Style','checkbox','String','Ext. trigger','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_enable_ext_trigger','TooltipString','Use external trigger input on PIVlab-SimpleSync','Callback', @ac_ext_trigger_settings_Callback);

item=[item(3) item(2) parentitem(3)/2 1.5];
handles.ac_device_control = uicontrol(handles.uipanelac_laser,'Style','pushbutton','String','Devices','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_device_control','TooltipString','Setup external devices (such as remote controlled seeding generator etc.)','Callback',@ac_device_control_Callback);


%item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 2];
%handles.ac_ext_trigger_settings = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Setup','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_ext_trigger_settings_Callback,'Tag','ac_ext_trigger_settings','TooltipString','Setup external trigger input on PIVlab-SimpleSync');


% Camera settings
parentitem=get(handles.multip24, 'Position');
item=[0 19.25+1 parentitem(3) 3.25];
handles.uipanelac_camsettings = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Camera settings', 'Tag','uipanelac_camsettings','fontweight','bold');

parentitem=get(handles.uipanelac_camsettings, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)-0.25 parentitem(3)/4 1.5];
handles.ac_calibBinning = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Binning','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @ac_calibBinning_Callback,'Tag','ac_calibBinning','TooltipString','Select pixel binning');

item=[parentitem(3)/4*1  item(2) parentitem(3)/4 1.5];
handles.ac_calibROI = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @ac_calibROI_Callback,'Tag','ac_calibROI','TooltipString','Select ROI in camera image');

item=[parentitem(3)/4*2  item(2) parentitem(3)/4 1.5];
handles.ac_lensctrl = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Lens','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @ac_lensctrl_Callback,'Tag','ac_lensctrl','TooltipString','Control camera lens');

item=[parentitem(3)/4*3  item(2) parentitem(3)/4 1.5];
handles.ac_chronosctrl = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Setup','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @ac_chronosctrl_Callback,'Tag','ac_chronosctrl','TooltipString','Setup Chronos camera');


% Calib capture

parentitem=get(handles.multip24, 'Position');
item=[0 22.5+1 parentitem(3) 4.5];

handles.uipanelac_calib = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Live image', 'Tag','uipanelac_calib','fontweight','bold');

parentitem=get(handles.uipanelac_calib, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.ac_expotxt = uicontrol(handles.uipanelac_calib,'Style','text', 'String','Exposure [ms]: ','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_expotxt');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.ac_expo = uicontrol(handles.uipanelac_calib,'Style','edit','units','characters','HorizontalAlignment','right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','50','tag','ac_expo','TooltipString','Exposure of the camera during calibration image capture','Callback', @ac_expo_Callback);

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/4 1.5];
handles.ac_calibcapture = uicontrol(handles.uipanelac_calib,'Style','pushbutton','String','Start','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)],'Callback', @ac_calibcapture_Callback,'Tag','ac_calibcapture','TooltipString','Start live view of the camera');

item=[parentitem(3)/4*1 item(2) parentitem(3)/4 1.5];
handles.ac_calibsave = uicontrol(handles.uipanelac_calib,'Style','pushbutton','String','Save','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)],'Callback', @ac_camstop_Callback,'Tag','ac_calibsave','TooltipString','Save last image','enable','off');

% PIV capture
parentitem=get(handles.multip24, 'Position');
item=[0 27.25+1 parentitem(3) 5];
handles.uipanelac_capture = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Capture PIV images', 'Tag','uipanelac_capture','fontweight','bold');

parentitem=get(handles.uipanelac_capture, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.ac_imgamounttxt = uicontrol(handles.uipanelac_capture,'Style','text', 'String','Image amount: ','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_imgamounttxt');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.ac_imgamount = uicontrol(handles.uipanelac_capture,'Style','edit','units','characters','HorizontalAlignment','right', 'enable','off','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','100','tag','ac_imgamount','TooltipString','Amount of double images to capture');

item=[parentitem(3)/2+parentitem(3)/4 item(2) parentitem(3)/4 1];
handles.ac_realtime = uicontrol(handles.uipanelac_capture,'Style','checkbox','units','characters','HorizontalAlignment','right','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)],'Value',0,'String','Live','tag','ac_realtime','TooltipString','Enable real-time PIV','Callback',@ac_realtime_Callback);

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/3 1.5];
handles.ac_pivcapture = uicontrol(handles.uipanelac_capture,'Style','pushbutton','String','Start','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_pivcapture_Callback,'Tag','ac_pivcapture','TooltipString','Start PIV image capture and laser');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3 1.5];
handles.ac_pivcapture_save = uicontrol(handles.uipanelac_capture,'Style','checkbox','units','characters','HorizontalAlignment','right','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)],'Value',0,'String','Save','tag','ac_pivcapture_save','TooltipString','Save PIV double images','Callback',@ac_pivcapture_save_Callback);

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.ac_pivstop = uicontrol(handles.uipanelac_capture,'Style','pushbutton','String','Abort','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_camstop_Callback,'Tag','ac_pivstop','TooltipString','Cancel capture and discard images');

parentitem=get(handles.multip24, 'Position');
item=[0 30.5 parentitem(3) 2];
handles.ac_msgbox = uicontrol(handles.multip24,'Style','edit', 'Fontname','fixedwidth', 'enable','inactive','Max', 3, 'min', 1, 'String',{'Welcome to PIVlab' 'image acquisition!'},'Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_msgbox','TooltipString','Messages','visible','off');
set(handles.ac_msgbox,'BackgroundColor', get (handles.ac_msgbox,'BackgroundColor')*0.95); %dim msgbox color

%Image acquisition: load last device
try
	warning off
	load('PIVlab_settings_default.mat','last_selected_device');

if exist('last_selected_device','var')	
set(handles.ac_config, 'value',last_selected_device);
end
	warning on
catch

end


disp('-> UI generated.')

%% Menu items callbacks
function loadimgs_Callback(~, ~, ~)
switchui('multip01')
delete(findobj('tag','hinting'))
%test1=get(gca,'xlim');
%test2=get(gca,'ylim');
%if test1(2)==603 && test2(2)==580 %%only display hint when logo is shown
%	text(400,30,'\leftarrow import your image pairs by clicking on ''Load images''','horizontalalignment','right','verticalalignment','middle','fontsize',14,'tag','hinting')
%end
%loadimgsbutton_Callback

function img_mask_Callback(~, ~, ~)
switchui('multip02')

function pre_proc_Callback(~, ~, ~)
switchui('multip03')
Autolimit_Callback

function piv_sett_Callback(~, ~, ~)
switchui('multip04')
pause(0.01) %otherwise display isn't updated... ?!?
drawnow;drawnow;
dispinterrog
handles=gethand;
overlappercent

function do_analys_Callback(~, ~, ~)
handles=gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
if get(handles.fftmulti,'Value') == 1 || get(handles.dcc,'Value') == 1
	set(handles.AnalyzeAll,'String','Analyze all frames');
end
if get(handles.ensemble,'Value') == 1
	set(handles.AnalyzeAll,'String','Start ensemble analysis');
end
if retr('parallel')==1
	set(handles.update_display_checkbox,'Visible','Off')
end
switchui('multip05')

function vector_val_Callback(~, ~, ~)
switchui('multip06')

function image_val_Callback(~, ~, ~)
switchui('multip23')

function cal_actual_Callback(~, ~, ~) %executed when calibration panel is made visible
switchui('multip07')
pointscali=retr('pointscali');
points_offsetx=retr('points_offsetx');
points_offsety=retr('points_offsety');
if numel(pointscali)>0
	xposition=pointscali(:,1);
	yposition=pointscali(:,2);
	caliimg=retr('caliimg');
	if numel(caliimg)>0
		image(caliimg, 'parent',gca, 'cdatamapping', 'scaled');
		colormap('gray');
		axis image;
		set(gca,'ytick',[])
		set(gca,'xtick',[])
	else
		sliderdisp
	end
	hold on;
	plot (xposition,yposition,'ro-', 'markersize', 10,'LineWidth',3 , 'tag', 'caliline');
	plot (xposition,yposition,'y+:', 'tag', 'caliline');
	hold off;
	for j=1:2
		text(xposition(j)+10,yposition(j)+10, ['x:' num2str(round(xposition(j)*10)/10) sprintf('\n') 'y:' num2str(round(yposition(j)*10)/10) ],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'caliline')
	end
	text(mean(xposition),mean(yposition), ['s = ' num2str(round((sqrt((xposition(1)-xposition(2))^2+(yposition(1)-yposition(2))^2))*100)/100) ' px'],'color','k','fontsize',7, 'BackgroundColor', 'r', 'tag', 'caliline','horizontalalignment','center')
	if numel(points_offsetx)>0 &&  numel(points_offsety)>0
		delete(findobj('tag','offset_label_x'))
		delete(findobj('tag','offset_label_y'))
		hold on;
		plot (points_offsetx(1),points_offsetx(2),'ro-', 'markersize', 10,'LineWidth',3, 'tag', 'offset_label_x');
		plot (points_offsetx(1),points_offsetx(2),'y+:', 'tag', 'offset_label_x');
		plot (points_offsety(1),points_offsety(2),'ro-', 'markersize', 10,'LineWidth',3, 'tag', 'offset_label_y');
		plot (points_offsety(1),points_offsety(2),'y+:', 'tag', 'offset_label_y');
		hold off;
		text(points_offsetx(1)+10,points_offsetx(2)+10, ['x reference:' num2str(round(points_offsetx(1)*10)/10) ' px'],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'offset_label_x')
		text(points_offsety(1)+10,points_offsety(2)+10, ['y reference:' num2str(round(points_offsety(2)*10)/10) ' px'],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'offset_label_y')
	end
	handles=gethand;
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','on')
else %no calibration performed yet
	handles=gethand;
	if retr('video_selection_done') == 1 %video file loaded
		%enter a guess for the time step, based on video file frame rate.
		video_reader_object = retr('video_reader_object');
		video_frame_selection=retr('video_frame_selection');
		skip = video_frame_selection(2) - video_frame_selection(1);
		delta_t = 1/(video_reader_object.FrameRate / skip)*1000;

		set(handles.time_inp,'String',num2str(delta_t))
	end
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
end

function plot_derivs_Callback(~, ~, ~)
handles=gethand;
switchui('multip08');
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set(handles.derivchoice,'String',{'Vectors [px/frame]';'Vorticity [1/frame]';'Velocity magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Simple shear rate [1/frame]';'Simple strain rate [1/frame]';'Line integral convolution (LIC) [1]' ; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
	set(handles.text35,'String','u [px/frame]:')
	set(handles.text36,'String','v [px/frame]:')
else
	set(handles.derivchoice,'String',{'Vectors [m/s]';'Vorticity [1/s]';'Velocity magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Simple shear rate [1/s]';'Simple strain rate [1/s]';'Line integral convolution (LIC) [1]'; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
	set(handles.text35,'String','u [m/s]:')
	set(handles.text36,'String','v [m/s]:')
end
derivchoice_Callback(handles.derivchoice)

function plot_temporal_derivs_Callback(~, ~, ~)
handles=gethand;
switchui('multip22');
%{
if retr('caluv')==1 && retr('calxy')==1
    set(handles.derivchoice,'String',{'Vectors [px/frame]';'Vorticity [1/frame]';'Velocity magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Simple shear rate [1/frame]';'Simple strain rate [1/frame]';'Line integral convolution (LIC) [1]' ; 'Vector direction [degrees]'});
    set(handles.text35,'String','u [px/frame]:')
    set(handles.text36,'String','v [px/frame]:')
else
    set(handles.derivchoice,'String',{'Vectors [m/s]';'Vorticity [1/s]';'Velocity magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Simple shear rate [1/s]';'Simple strain rate [1/s]';'Line integral convolution (LIC) [1]'; 'Vector direction [degrees]'});
    set(handles.text35,'String','u [m/s]:')
    set(handles.text36,'String','v [m/s]:')
end
derivchoice_Callback(handles.derivchoice)
%}

function modif_plot_Callback(~, ~, ~)
switchui('multip09');

function ascii_chart_Callback(~, ~, ~)
switchui('multip10')

function matlab_file_Callback(~, ~, ~)
switchui('multip11')

function poly_extract_Callback(~, ~, ~)
handles=gethand;
switchui('multip12')
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set(handles.extraction_choice,'string', {'Vorticity [1/frame]';'Velocity magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Shear rate [1/frame]';'Strain rate [1/frame]';'Vector direction [degrees]';'Correlation coefficient [-]';'Tangent velocity [px/frame]'});
else
	set(handles.extraction_choice,'string', {'Vorticity [1/s]';'Velocity magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Shear rate [1/s]';'Strain rate [1/s]';'Vector direction [degrees]';'Correlation coefficient [-]';'Tangent velocity [m/s]'});
end

function dist_angle_Callback(~, ~, ~)
switchui('multip13')

function statistics_Callback(~, ~, ~)
switchui('multip14')
filepath=retr('filepath');
if size(filepath,1) > 1
	sliderdisp
end

function part_img_sett_Callback(~, ~, ~)
switchui('multip15')

function save_movie_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
if size(resultslist,2)>=1
	startframe=0;
	endframe=0;
	for i=1:size(resultslist,2)
		if numel(resultslist{1,i})>0 && startframe==0
			startframe=i;
		end
		if numel(resultslist{1,i})>0
			endframe=i;
		end
	end
	set(handles.firstframe, 'String',int2str(startframe));
	set(handles.lastframe, 'String',int2str(endframe));
	if strmatch(get(handles.multip08, 'visible'), 'on')
		put('p8wasvisible',1)
	else
		put('p8wasvisible',0)
	end
	switchui('multip16');
else
	msgbox('No analyses yet...')
end

function area_extract_Callback(~, ~, ~)
handles=gethand;
switchui('multip17');
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set(handles.area_para_select,'string', {'Vorticity [1/frame]';'Velocity magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Shear rate [1/frame]';'Strain rate [1/frame]';'Vector direction [degrees]';'Correlation coefficient [-]'});
else
	set(handles.area_para_select,'string', {'Vorticity [1/s]';'Velocity magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Shear rate [1/s]';'Strain rate [1/s]';'Vector direction [degrees]';'Correlation coefficient [-]'});
end

function streamlines_Callback(~, ~, ~)
switchui('multip18');

function paraview_Callback(~, ~, ~)
switchui('multip19')

function tecplot_file_Callback(~, ~, ~)
switchui('multip20')

function pco_error_msgbox
[filepath,~,~] = fileparts(mfilename('fullpath'));
uiwait(msgbox(['PCO camera drivers not found in this directory:' sprintf('\n') fullfile(filepath, 'PIVlab_capture_resources\PCO_resources') sprintf('\n\n') 'The free pco toolbox for Matlab can be downloaded here:' sprintf('\n') 'https://www.pco.de/de/software/third-party/matlab/' sprintf('\n\n') 'Please download and install this toolbox to use your pco camera in PIVlab.'],'modal'))

function capture_images_Callback(~,~,~) %Menu item is called
[filepath,~,~] = fileparts(mfilename('fullpath'));
switchui('multip24')
select_capture_config_Callback
if exist(fullfile(filepath, 'PIVlab_capture_resources\PCO_resources'),'dir')==7
	%addpath(genpath(fullfile(filepath, 'PCO_resources')));
	addpath(fullfile(filepath, 'PIVlab_capture_resources\PCO_resources\scripts'));
	%PCO setup_files.m copies required dlls and headers to dir.
	%subfolders might not be necessary. Check!
else
	pco_error_msgbox
end
if verLessThan('matlab','9.7') %R2019b
	uiwait(msgbox('Image capture and synchronizer control in PIVlab requires at least MATLAB version 9.7 (R2019b).','modal'))
end
handles=gethand;
if isempty(get(handles.ac_project,'String')) %if user hasnt entered a project path...
	if ~isempty(retr('pathname'))
		set(handles.ac_project,'String',fullfile(retr('pathname'),['PIVlabCapture_' date]));
	else
		set(handles.ac_project,'String',fullfile(pwd,['PIVlabCapture_' date]));
	end
end
serpo=retr('serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
	put('serpo',[]);
	set(handles.ac_comport,'Value',1);
	set(handles.ac_laserstatus,'String','N/A','BackgroundColor',[1 0 0])
end
if alreadyconnected
	serports=serialportlist('available');
	set(handles.ac_comport,'String',[serpo.Port serports]); %fill dropdown with connected port on top, and other available ports at bottom
	set(handles.ac_connect,'String','Connect');
	set(handles.ac_serialstatus,'Backgroundcolor',[0 1 0]);
else
	try
		serports=serialportlist('available');
	catch
		serports=[];
	end
	if isempty(serports)
		serports='No available serial ports found!';
		set(handles.ac_connect,'String','Refresh');
	else
		set(handles.ac_connect,'String','Connect');
	end
	set(handles.ac_comport,'String',serports);
	set(handles.ac_serialstatus,'Backgroundcolor',[1 0 0]);
end


% Set default image colormap limits
put('ac_lower_clim',0);
put('ac_upper_clim',2^16);
delete(findobj('tag','shortcutlist'));
%Keyboard shortcuts
text(10,10,['Image acquisition keyboard shortcuts' sprintf('\n') 'CTRL SHIFT C : Toggle crosshair' sprintf('\n') 'CTRL SHIFT X : Toggle sharpness measure' sprintf('\n') 'CTRL SHIFT + : Increase display brightness' sprintf('\n') 'CTRL SHIFT - : Decrease display brightness' sprintf('\n') 'CTRL SHIFT K : Toggle between log and lin color scale' sprintf('\n') 'CTRL SHIFT H : Toggle histogram display'],'tag','shortcutlist','Color','black','BackgroundColor','white','VerticalAlignment','top');
try
	if ~alreadyconnected
		if ispref('PIVlab_ad','enable_ad') &&  getpref('PIVlab_ad','enable_ad') ==0
			%do not display ad
		else
			if exist('laser_device_id.mat','file') ~= 2
				hardware_Ad
			end
		end
	end
catch
end


function preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gethand;
panelwidth=retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
switchui('multip21')

function font_size_change (~,~,magnifier)
objects=findobj('Type','uicontrol');
objects=[objects; findobj('Type','uipanel')];
A=get (objects,'fontsize');
A=cellfun(@(x) x+magnifier, A);

for i=1:size(A,1)
	try
		set(objects(i), 'FontSize',A(i));
	catch
	end
end


%% Resize functionality
function MainWindow_ResizeFcn(hObject, ~)
handles=guihandles(hObject);
originalunits=get(hObject,'units');
set(hObject,'Units','Characters');
Figure_Size = get(hObject, 'Position');
set(hObject,'Units',originalunits);
margin=1.5;
panelwidth=retr('panelwidth');
%panelwidth=37;
panelheighttools=12;
panelheightpanels=35;
quickwidth=retr('quickwidth');
quickheight=retr('quickheight');
%starts lower left
%                            X    Y    WIDTH    HEIGHT
if (panelheighttools+panelheightpanels+margin*0.25+margin*0.25) <= Figure_Size(4)
	%panels + tools DO fit vertically
	try
		set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
		set (handles.tools, 'position', [0+margin*0.5 0+margin*0.5 panelwidth panelheighttools]);
		set (gca, 'position', [panelwidth+margin 0+margin Figure_Size(3)-panelwidth-margin Figure_Size(4)-margin-quickheight]);
	catch ME
		disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
		disp('https://groups.google.com/forum/#!forum/pivlab ')
		disp(ME)
	end
else
	%panels + tools DO NOT fit vertically
	%--> put them side by side
	try
		set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
		set (handles.tools, 'position', [0+margin*0.5+panelwidth+margin 0+margin*0.5 panelwidth panelheighttools]);
		set (gca, 'position', [0+margin+panelwidth+margin+panelwidth 0+margin Figure_Size(3)-panelwidth-panelwidth-margin-margin Figure_Size(4)-margin-quickheight]);
	catch ME
		disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
		disp('https://groups.google.com/forum/#!forum/pivlab ')
		disp(ME)
	end
end
if (panelheighttools+panelheightpanels+margin*0.25+margin*0.5) <= Figure_Size(4)-quickheight
	try
		set (handles.quick,'Visible','on');
		set (handles.quick, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight])
	catch ME
		disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
		disp('https://groups.google.com/forum/#!forum/pivlab ')
		disp(ME)
	end
else % not enough space for quick access box
	set (handles.quick,'Visible','off');
end
%% Other Callback

function displogo(~)
logoimg=imread('PIVlablogo.jpg');
%{
if zoom==1
	h=image(logoimg+255, 'parent', gca);
	axis image;
	set(gca,'ytick',[])
	set(gca,'xtick',[])
	set(gca, 'xlim', [1 size(logoimg,2)]);
	set(gca, 'ylim', [1 size(logoimg,1)]);
	set(gca, 'ydir', 'reverse');
	set(gca, 'xcolor', [0.94 0.94 0.94], 'ycolor', [0.94 0.94 0.94]) ;
	for i=0.5:0.1:1
		RGB2=logoimg*i;
		try
			set (h, 'cdata', RGB2);
			pause(0.01)
		catch %#ok<*CTCH>
			disp('..')
		end
		drawnow %limitrate;
	end
end
%}

try
	image(logoimg, 'parent', gca,'interpolation','bilinear');
catch
	image(logoimg, 'parent', gca);
end
set(gca, 'xcolor', [0.94 0.94 0.94], 'ycolor', [0.94 0.94 0.94]) ;

axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
set(gca, 'xlim', [1 size(logoimg,2)]);
set(gca, 'ylim', [1 size(logoimg,1)]);

set(gca, 'ydir', 'reverse'); %750%582
text (745,568,['version: ' retr('PIVver')], 'fontsize', 8,'fontangle','italic','horizontalalignment','right');
text (745,570,['   ' sprintf('\n') retr('update_msg')], 'fontsize', 10,'fontangle','italic','horizontalalignment','right','Color',retr('update_msg_color'),'verticalalignment','top');
imgproctoolbox=retr('imgproctoolbox');
put('imgproctoolbox',[]);
if imgproctoolbox==0
	text (90,200,'Image processing toolbox not found!', 'fontsize', 16, 'color', [1 0 0], 'backgroundcolor', [0 0 0]);
end

function switchui (who)
handles=guihandles(getappdata(0,'hgui')); %#ok<*NASGU>

if get(handles.zoomon,'Value')==1
	set(handles.zoomon,'Value',0);
	zoomon_Callback(handles.zoomon)
end
if get(handles.panon,'Value')==1
	set(handles.panon,'Value',0);
	panon_Callback(handles.panon)
end

turnoff=findobj('-regexp','Tag','multip');
set(turnoff, 'visible', 'off');
turnon=findobj('-regexp','Tag',who);
set(turnon, 'visible', 'on');
drawnow;

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hgui=getappdata(0,'hgui');
handles=guihandles(hgui);

function [currentimage,rawimage] = get_img(selected)
handles=gethand;
filepath = retr('filepath');
if retr('video_selection_done') == 0
	[~,~,ext] = fileparts(filepath{selected});
	if strcmp(ext,'.b16')
		currentimage=f_readB16(filepath{selected});
		rawimage=currentimage;
	else
		currentimage=imread(filepath{selected});
		rawimage=currentimage;
	end
else
	video_reader_object = retr('video_reader_object');
	video_frame_selection=retr('video_frame_selection');
	currentimage = read(video_reader_object,video_frame_selection(selected));
	rawimage=currentimage;
end

if get(handles.bg_subtract,'Value')==1
	if mod(selected,2)==1 %uneven image nr.
		bg_img = retr('bg_img_A');
	else
		bg_img = retr('bg_img_B');
	end

	if isempty(bg_img) %checkbox is enabled, but no bg is present
		set(handles.bg_subtract,'Value',0);
	else
		if size(currentimage,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
			currentimage = rgb2gray(currentimage)-bg_img;
		else
			currentimage = currentimage-bg_img;
		end
	end
end
%get and save the image size (assuming that every image of a session has the same size)
size_of_the_image=size(currentimage);
expected_image_size=retr('expected_image_size');
if isempty(expected_image_size) %expected_image_size is empty, we have not read an image before
	expected_image_size = size_of_the_image;
	put('expected_image_size',expected_image_size);
else %expected_image_size is not empty, an image has been read before
	if 	expected_image_size(1) ~= size_of_the_image(1) || expected_image_size(2) ~= size_of_the_image(2)
		cancelbutt_Callback
		uiwait(warndlg('Error: All images in a session  MUST have the same size!'));
		warning off
		recycle('off');
		delete('cancel_piv');
		warning on
	end
end
put('size_of_the_image',size_of_the_image);
currentimage(currentimage<0)=0; %bg subtraction may yield negative
%results. I am unsure about the best way to deal with this data. Is
%negative data useful, or just trash? Doesn't seem to make any difference
%in the results however.


function generate_BG_img
handles=gethand;
if get(handles.bg_subtract,'Value')==1
	bg_img_A = retr('bg_img_A');
	bg_img_B = retr('bg_img_B');
	sequencer=retr('sequencer');%Timeresolved or pairwise 0=timeres.; 1=pairwise
	if sequencer ~= 2 % bg subtraction only makes sense with time-resolved and pairwise sequencing style, not with reference style.
		if isempty(bg_img_A) || isempty(bg_img_B)
			answer = questdlg('Mean intensity background image needs to be calculated. Press ok to start.', 'Background subtraction', 'OK','Cancel','OK');
			if strcmp(answer , 'OK')
				%disp('BG not present, calculating now')
				%% Calculate BG for all images....
				% read first image to determine properties
				filepath = retr('filepath');
				if retr('video_selection_done') == 0
					[~,~,ext] = fileparts(filepath{1});
					if strcmp(ext,'.b16')
						image1=f_readB16(filepath{1});
						image2=f_readB16(filepath{2});
						imagesource='b16_image';
					else
						image1=imread(filepath{1});
						image2=imread(filepath{2});
						imagesource='normal_pixel_image';
					end
				else
					video_reader_object = retr('video_reader_object');
					video_frame_selection=retr('video_frame_selection');
					image1 = read(video_reader_object,video_frame_selection(1));
					image2 = read(video_reader_object,video_frame_selection(2));
					imagesource='from_video';
				end
				classimage=class(image1); %memorize the original image format (double, uint8 etc)

				if size(image1,3)>1
					image1=rgb2gray(image1); %rgb2gray conserves the variable class (single, double, uint8, uint16)
					image2=rgb2gray(image2);
					colorimg=1;
				else
					colorimg=0;
				end
				counter=1;

				%convert all image types to double, ranging from 0...1
				if strcmp(classimage,'double')==1 %double stays double
					%do nothing
				elseif strcmp(classimage,'single')==1 %e.g. 32bit tif, ranges from 0...1
					image1=double(image1);
					image2=double(image2);
				elseif strcmp(classimage,'uint16')==1 %e.g. 16bit tif, ranges from 0...65535
					image1=double(image1)/65535;
					image2=double(image2)/65535;
				elseif strcmp(classimage,'uint8')==1 %0...255
					image1=double(image1)/255;
					image2=double(image2)/255;
				end
				if sequencer==0 %time-resolved
					start_bg=2;
					skip_bg=1;
				else
					start_bg=3;
					skip_bg=2;
				end
				%perform image addition
				%if timeresolved: generate only one background image from all
				%images
				%if not: generate two background images. One from even frames,
				%one from odd frames
				toolsavailable(0)
				updatecntr=0;
				for i=start_bg:skip_bg:size(filepath,1)
					counter=counter+1;
					updatecntr=updatecntr+1;
					if updatecntr==5
						set(handles.preview_preprocess, 'String', ['Progress: ' num2str(round(i/size(filepath,1)*99)) ' %']);drawnow expose;
						updatecntr=0;
					end
					if strcmp('b16_image',imagesource)
						image_to_add1 = f_readB16(filepath{i}); %will be double
						if sequencer==1 %not time-resolved
							image_to_add2 = f_readB16(filepath{i+1});
						end
					elseif strcmp('normal_pixel_image',imagesource)
						image_to_add1 = imread(filepath{i});
						if sequencer==1 %not time-resolved
							image_to_add2 = imread(filepath{i+1}); %will be double or uint8
						end
					elseif strcmp('from_video',imagesource)
						image_to_add1 = read(video_reader_object,video_frame_selection(i));
						if sequencer==1 %not time-resolved
							image_to_add2 = read(video_reader_object,video_frame_selection(i+1));
						end
					end
					%images arrive in their original format here
					%convert everything to grayscale and double [0...1]
					if colorimg==1
						image_to_add1 = rgb2gray(image_to_add1); %will conserve image class
						if sequencer==1 %not time-resolved
							image_to_add2 = rgb2gray(image_to_add2);
						end
					end
					if strcmp(classimage,'double')==1
						image_to_add1=image_to_add1;
						if sequencer==1 %not time-resolved
							image_to_add2=image_to_add2;
						end
					end
					if strcmp(classimage,'single')==1
						image_to_add1=double(image_to_add1);
						if sequencer==1 %not time-resolved
							image_to_add2=double(image_to_add2);
						end
					end
					if strcmp(classimage,'uint8')==1
						image_to_add1=double(image_to_add1)/255;
						if sequencer==1 %not time-resolved
							image_to_add2=double(image_to_add2)/255;
						end
					end
					if strcmp(classimage,'uint16')==1
						image_to_add1=double(image_to_add1)/65535;
						if sequencer==1 %not time-resolved
							image_to_add2=double(image_to_add2)/65535;
						end
					end
					%now everything is double [0...1]
					%Sum up  all images
					img_size_info1=size(image1);
					img_size_info2=size(image_to_add1);
					if img_size_info1(1) ~= img_size_info2(1) || img_size_info1(2) ~= img_size_info2(2)
						uiwait(warndlg('Error: All images in a session  MUST have the same size!'));
						break
					end
					image1=image1 +image_to_add1;
					if sequencer==1 %not time-resolved
						img_size_info1=size(image2);
						img_size_info2=size(image_to_add2);
						if img_size_info1(1) ~= img_size_info2(1) || img_size_info1(2) ~= img_size_info2(2)
							uiwait(warndlg('Error: All images in a session  MUST have the same size!'));
							break
						end
						image2=image2+image_to_add2;
					end
				end %of for loop and image summing

				%divide the sum by the amount of summed images
				image1_bg=image1/counter;
				if sequencer==1 %not time-resolved
					image2_bg=image2/counter;
				end

				%Convert back to original image class, if not double anyway
				if strcmp(classimage,'uint8')==1 %#ok<*STISA>
					image1_bg=uint8(image1_bg*255);
					if sequencer==1 %not time-resolved
						image2_bg=uint8(image2_bg*255);
					end
				end
				if strcmp(classimage,'single')==1
					image1_bg=single(image1_bg);
					if sequencer==1 %not time-resolved
						image2_bg=single(image2_bg);
					end
				end
				if strcmp(classimage,'uint16')==1
					image1_bg=uint16(image1_bg*65535);
					if sequencer==1 %not time-resolved
						image2_bg=uint16(image2_bg*65535);
					end
				end

				%make results accessible to the rest of the GUI:
				put('bg_img_A',image1_bg);
				if sequencer==1 %not time-resolved
					put('bg_img_B',image2_bg);
				else
					put('bg_img_B',image1_bg); %timeresolved --> same bg image for a and b
				end
				set(handles.preview_preprocess, 'String', 'Apply and preview current frame');drawnow;
				toolsavailable(1)
			else % user has checkbox enabled, but doesn't want to calculate the background...
				set(handles.bg_subtract,'Value',0);
			end

		else
			%disp('BG exists')
		end

	else
		set(handles.bg_subtract,'Value',0);
		warndlg(['Background removal is only available with the following sequencing styles:' sprintf('\n') '* Time resolved: [A+B], [B+C], [C+D], ...' sprintf('\n') '* Pairwise: [A+B], [C+D], [E+F], ...'])
		uiwait
	end
end


function sliderdisp %this is the most important function, doing all the displaying
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
filepath=retr('filepath');
capturing=retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	%if the images are not found on the current path, then let user choose new path
	%not found: assign new path to all following elements.
	%check next file. not found -> assign new path to all following.
	%and so on...
	%if retr('video_selection_done') == 0 && isempty(filepath) == 0 && exist(filepath{selected},'file') ~=2
	if isempty(filepath) == 0 && exist(filepath{selected},'file') ~=2
		for i=1:size(filepath,1)
			while exist(filepath{i,1},'file') ~=2
				errordlg(['The image ' sprintf('\n') filepath{i,1} sprintf('\n') '(and probably some more...) could not be found.' sprintf('\n') 'Please select the path where the images are located.'],'File not found!','on')
				uiwait
				new_dir = uigetdir(pwd,'Please specify the path to all the images');
				if new_dir==0
					break
				else
					for j=i:size(filepath,1) %apply new path to all following imgs.
						if ispc==1
							zeichen=strfind(filepath{j,1},'\');
						else
							zeichen=strfind(filepath{j,1},'/');
						end
						currentobject=filepath{j,1};
						currentpath=currentobject(1:(zeichen(1,size(zeichen,2))));
						currentfile=currentobject(zeichen(1,size(zeichen,2))+1:end);
						if ispc==1
							filepath{j,1}=[new_dir '\' currentfile];
						else
							filepath{j,1}=[new_dir '/' currentfile];
						end
					end
				end
				put('filepath',filepath);
			end
			if new_dir==0
				break
			end
		end
		if retr('video_selection_done') == 1 %create new video object with the updated file location.
			put('video_reader_object',VideoReader(filepath{1}));
		end
	end

	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	%display derivatives if available and desired...
	displaywhat=retr('displaywhat');
	delete(findobj('tag', 'derivhint'));
	if size(filepath,1)>0
		if get(handles.zoomon,'Value')==1
			set(handles.zoomon,'Value',0);
			zoomon_Callback(handles.zoomon)
		end
		if get(handles.panon,'Value')==1
			set(handles.panon,'Value',0);
			panon_Callback(handles.panon)
		end
		xzoomlimit=retr('xzoomlimit');
		yzoomlimit=retr('yzoomlimit');

		derived=retr('derived');
		if isempty(derived)==0   %derivatives were calculated
			%derived=retr('derived');
			%1=vectors only
			if displaywhat==1 %vectors only
				[currentimage,~]=get_img(selected);
				if get(handles.enhance_images, 'Value') == 0
					image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
				else
					if size(currentimage,3)==1 % grayscale image
						image(imadjust(currentimage), 'parent',gca, 'cdatamapping', 'scaled');
					else
						image(imadjust(currentimage,stretchlim(rgb2gray(currentimage))), 'parent',gca, 'cdatamapping', 'scaled');
					end
				end
				colormap('gray');
				vectorcolor=[str2double(get(handles.validr,'string')) str2double(get(handles.validg,'string')) str2double(get(handles.validb,'string'))];
				%vectorcolor='g';
				%end
			else %displaywhat>1

				if size(derived,2)>=(currentframe+1)/2 && numel(derived{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
					currentimage=derived{displaywhat-1,(currentframe+1)/2};
					%is currentimage 3d? That would cause problems.-....
					%pcolor(resultslist{1,(currentframe+1)/2},resultslist{2,(currentframe+1)/2},currentimage);shading interp;
					if displaywhat ~=11 % 11 ist vector direction
						image(rescale_maps(currentimage,0), 'parent',gca, 'cdatamapping', 'scaled');
					else
						image(rescale_maps(currentimage,1), 'parent',gca, 'cdatamapping', 'scaled');
					end
					if displaywhat ~=10 %10 is LIC
						avail_maps=get(handles.colormap_choice,'string');
						selected_index=get(handles.colormap_choice,'value');
						if selected_index == 4 %HochschuleBremen map
							load hsbmap.mat;
							colormap(hsb);
						elseif selected_index== 1 %parula
							load parula.mat;
							colormap (parula);
						else
							colormap(avail_maps{selected_index});
						end
						%adjust colormap steps
						%cmap = colormap(gca);
						cmap = colormap;
						colormap_steps_list=get(handles.colormap_steps,'String');
						colormap_steps_value=get(handles.colormap_steps,'Value');
						colormap_steps=str2double(colormap_steps_list{colormap_steps_value});
						cmap_new=interp1(1:size(cmap,1),cmap,linspace(1,size(cmap,1),colormap_steps));
						colormap(cmap_new);
					else %LIC can only be gray
						colormap('gray');
					end
					if get(handles.autoscaler,'value')==1
						minscale=min(min(currentimage));
						maxscale=max(max(currentimage));
						set (handles.mapscale_min, 'string', num2str(minscale))
						set (handles.mapscale_max, 'string', num2str(maxscale))
					else
						minscale=str2double(get(handles.mapscale_min, 'string'));
						maxscale=str2double(get(handles.mapscale_max, 'string'));
					end
					caxis([minscale maxscale])
					vectorcolor=[str2double(get(handles.validdr,'string')) str2double(get(handles.validdg,'string')) str2double(get(handles.validdb,'string'))];
					%vectorcolor='k';
					if get(handles.displ_colorbar,'value')==1
						name=get(handles.derivchoice,'string');
						if strcmp(name,'N/A') %user hasn't visited the derived panel before
							if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
								set(handles.derivchoice,'String',{'Vectors [px/frame]';'Vorticity [1/frame]';'Velocity magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Simple shear rate [1/frame]';'Simple strain rate [1/frame]';'Line integral convolution (LIC) [1]' ; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
								set(handles.text35,'String','u [px/frame]:')
								set(handles.text36,'String','v [px/frame]:')
							else
								set(handles.derivchoice,'String',{'Vectors [m/s]';'Vorticity [1/s]';'Velocity magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Simple shear rate [1/s]';'Simple strain rate [1/s]';'Line integral convolution (LIC) [1]'; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
								set(handles.text35,'String','u [m/s]:')
								set(handles.text36,'String','v [m/s]:')
							end
							name=get(handles.derivchoice,'String');
						end
						posichoice = get(handles.colorbarpos,'String');
						colochoice=get(handles.colorbarcolor,'String');
						coloobj=colorbar(posichoice{get(handles.colorbarpos,'Value')},'FontWeight','bold','Fontsize',12,'color',colochoice{get(handles.colorbarcolor,'Value')},'HitTest','off');

						if strcmp(posichoice{get(handles.colorbarpos,'Value')},'East')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'West')==1
							axis image %needs to be called before changing colorbar labels
							set(coloobj,'YTickLabel',num2str(get(coloobj,'YTick')','%5.5g'))
							ylabel(coloobj,name{retr('displaywhat')},'fontsize',9,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
						end
						if strcmp(posichoice{get(handles.colorbarpos,'Value')},'North')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'South')==1
							axis image %needs to be called before changing colorbar labels
							set(coloobj,'XTickLabel',num2str(get(coloobj,'XTick')','%5.5g'))
							xlabel(coloobj,name{retr('displaywhat')},'fontsize',11,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
						end
					end
				else %no deriv available
					[currentimage,~]=get_img(selected);
					if get(handles.enhance_images, 'Value') == 0
						image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
					else
						if size(currentimage,3)==1 % grayscale image
							image(imadjust(currentimage), 'parent',gca, 'cdatamapping', 'scaled');
						else
							image(imadjust(currentimage,stretchlim(rgb2gray(currentimage))), 'parent',gca, 'cdatamapping', 'scaled');
						end
					end
					colormap('gray');
					vectorcolor=[str2double(get(handles.validr,'string')) str2double(get(handles.validg,'string')) str2double(get(handles.validb,'string'))];
					%vectorcolor='g';
					text(10,10,'This parameter needs to be calculated for this frame first. Go to Plot -> Derive Parameters and click "Apply to current frame".','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'derivhint')
				end
			end
		else %not in derivatives panel
			%try
			[currentimage,~]=get_img(selected);

			%{
            catch
            disp(['Error: ' filepath{selected} ' --> Image could not be found!']);
            resultslist=retr('resultslist');
            maximgx=max(max(resultslist{1,1}))+min(min(resultslist{1,1}));
            maximgy=max(max(resultslist{2,1}))+min(min(resultslist{2,1}));
            currentimage=zeros(maximgy,maximgx);
        end
			%}
			if get(handles.enhance_images, 'Value') == 0
				image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
			else
				try % if user presses 'Toggle' button too fast, a strange error occurs
					if size(currentimage,3)==1 % grayscale image
						image(imadjust(currentimage), 'parent',gca, 'cdatamapping', 'scaled');
					else
						image(imadjust(currentimage,stretchlim(rgb2gray(currentimage))), 'parent',gca, 'cdatamapping', 'scaled');
					end
				catch
				end
			end

			colormap('gray');
			vectorcolor=[str2double(get(handles.validr,'string')) str2double(get(handles.validg,'string')) str2double(get(handles.validb,'string'))];
			%vectorcolor='g';
		end
		axis image;
		set(gca,'ytick',[])
		set(gca,'xtick',[])

		%% include axis tick labels. Doesnt work with exportfig.....?
		%{
		xticks('auto')
		yticks('auto')
		xticklabels('auto')
		yticklabels('auto')
		pixelxticks=xticklabels(gca);
		pixelyticks=yticklabels(gca);
		pixelxticks_S = sprintf('%s ', pixelxticks{:});
		pixelxticks = sscanf(pixelxticks_S, '%f');
		pixelyticks_S = sprintf('%s ', pixelyticks{:});
		pixelyticks = sscanf(pixelyticks_S, '%f');
		
		[xticklabel_cal,yticklabel_cal] = calibrate_xy(pixelxticks,pixelyticks);
		set(gca,'xticklabel',num2cell(xticklabel_cal))
		set(gca,'yticklabel',num2cell(yticklabel_cal))
		%}

		filename=retr('filename');
		ismean=retr('ismean');
		if size(ismean,1)>=(currentframe+1)/2
			if ismean((currentframe+1)/2,1) ==1
				currentwasmean=1;
			else
				currentwasmean=0;
			end
		else
			currentwasmean=0;
		end

		if currentwasmean==1
			set (handles.filenameshow,'BackgroundColor',[0.65 0.65 1]);
		else
			set (handles.filenameshow,'BackgroundColor',[0.9412 0.9412 0.9412]);
		end
		if retr('video_selection_done') == 0
			set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(size(filepath,1)/2) '):' sprintf('\n') filename{selected}]);
			set (handles.filenameshow, 'tooltipstring', filepath{selected});
		else %video loaded
			video_frame_selection=retr('video_frame_selection');
			set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(size(filepath,1)/2) '):' sprintf('\n') filename{selected}]);
			%set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(numel(video_frame_selection)/2) '):' sprintf('\n') filename]);
			set (handles.filenameshow, 'tooltipstring', filepath{selected});
		end
		if strncmp(get(handles.multip01, 'visible'), 'on',2)
			set(handles.imsize, 'string', ['Image size: ' int2str(size(currentimage,2)) '*' int2str(size(currentimage,1)) 'px' ])
		end
		maskiererx=retr('maskiererx');
		if size(maskiererx,2)>=currentframe
			ximask=maskiererx{1,currentframe};
			if size(ximask,1)>1
				dispMASK(1-str2num(get(handles.masktransp,'String'))/100)
			end
		end
		roirect=retr('roirect');
		if size(roirect,2)>1
			dispROI
		end
		resultslist=retr('resultslist');
		delete(findobj('tag', 'smoothhint'));
		%manualmarkers
		if get(handles.displmarker,'value')==1
			manmarkersX=retr('manmarkersX');
			manmarkersY=retr('manmarkersY');
			delete(findobj('tag','manualmarker'));
			if numel(manmarkersX)>0
				hold on
				plot(manmarkersX,manmarkersY, 'o','MarkerEdgeColor','k','MarkerFaceColor',[.2 .2 1], 'MarkerSize',9, 'tag', 'manualmarker');
				plot(manmarkersX,manmarkersY, '*','MarkerEdgeColor','w', 'tag', 'manualmarker');
				hold off
			end
		end


		if size(resultslist,2)>=(currentframe+1)/2 && numel(resultslist{1,(currentframe+1)/2})>0
			x=resultslist{1,(currentframe+1)/2};
			y=resultslist{2,(currentframe+1)/2};
			if size(resultslist,1)>6 %filtered exists
				if size(resultslist,1)>10 && numel(resultslist{10,(currentframe+1)/2}) > 0 %smoothed exists
					u=resultslist{10,(currentframe+1)/2};
					v=resultslist{11,(currentframe+1)/2};
					typevector=resultslist{9,(currentframe+1)/2};
					%text(3,size(currentimage,1)-4, 'Smoothed dataset','tag', 'smoothhint', 'backgroundcolor', 'k', 'color', 'y','fontsize',6);
					if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
						typevector=resultslist{5,(currentframe+1)/2};
					end
				else
					u=resultslist{7,(currentframe+1)/2};
					if size(u,1)>1
						v=resultslist{8,(currentframe+1)/2};
						typevector=resultslist{9,(currentframe+1)/2};
					else %filter was applied for other frames but not for this one
						u=resultslist{3,(currentframe+1)/2};
						v=resultslist{4,(currentframe+1)/2};
						typevector=resultslist{5,(currentframe+1)/2};
					end
				end
			else
				u=resultslist{3,(currentframe+1)/2};
				v=resultslist{4,(currentframe+1)/2};
				typevector=resultslist{5,(currentframe+1)/2};
			end
			if get(handles.highp_vectors, 'value')==1 & strncmp(get(handles.multip08, 'visible'), 'on',2) %#ok<AND2> %disable second expression to make highpass filtered data available for export
				strength=54-round(get(handles.highpass_strength, 'value'));
				h = fspecial('gaussian',strength,strength) ;
				h2= fspecial('gaussian',3,3);
				ubg=imfilter(u,h,'replicate');
				vbg=imfilter(v,h,'replicate');
				ufilt=u-ubg;
				vfilt=v-vbg;
				u=imfilter(ufilt,h2,'replicate');
				v=imfilter(vfilt,h2,'replicate');
			end
			autoscale_vec=get(handles.autoscale_vec, 'Value');
			vecskip=str2double(get(handles.nthvect,'String'));
			if autoscale_vec == 1
				autoscale=1;
				%from quiver autoscale function:
				if min(size(x))==1, n=sqrt(numel(x)); m=n; else; [m,n]=size(x); end
				delx = diff([min(x(:)) max(x(:))])/n;
				dely = diff([min(y(:)) max(y(:))])/m;
				del = delx.^2 + dely.^2;
				if del>0
					len = sqrt((u.^2 + v.^2)/del);
					maxlen = max(len(:));
				else
					maxlen = 0;
				end
				if maxlen>0
					autoscale = autoscale/ maxlen * vecskip;
				else
					autoscale = autoscale; %#ok<*ASGSL>
				end
				vecscale=autoscale;
			else %autoscale off
				vecscale=str2num(get(handles.vectorscale,'string')); %#ok<*ST2NM>
			end
			hold on;

			vectorcolorintp=[str2double(get(handles.interpr,'string')) str2double(get(handles.interpg,'string')) str2double(get(handles.interpb,'string'))];
			if vecskip==1
				q=quiver(x(typevector==1),y(typevector==1),...
					(u(typevector==1)-(retr('subtr_u')/retr('calu')))*vecscale,...
					(v(typevector==1)-(retr('subtr_v')/retr('calv')))*vecscale,...
					'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')));
				q2=quiver(x(typevector==2),y(typevector==2),...
					(u(typevector==2)-(retr('subtr_u')/retr('calu')))*vecscale,...
					(v(typevector==2)-(retr('subtr_v')/retr('calv')))*vecscale,...
					'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')));
				if str2num(get(handles.masktransp,'String')) < 100
					scatter(x(typevector==0),y(typevector==0),'rx') %masked
				end
			else
				typevector_reduced=typevector(1:vecskip:end,1:vecskip:end);
				x_reduced=x(1:vecskip:end,1:vecskip:end);
				y_reduced=y(1:vecskip:end,1:vecskip:end);
				u_reduced=u(1:vecskip:end,1:vecskip:end);
				v_reduced=v(1:vecskip:end,1:vecskip:end);
				q=quiver(x_reduced(typevector_reduced==1),y_reduced(typevector_reduced==1),...
					(u_reduced(typevector_reduced==1)-(retr('subtr_u')/retr('calu')))*vecscale,...
					(v_reduced(typevector_reduced==1)-(retr('subtr_v')/retr('calv')))*vecscale,...
					'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')));
				q2=quiver(x_reduced(typevector_reduced==2),y_reduced(typevector_reduced==2),...
					(u_reduced(typevector_reduced==2)-(retr('subtr_u')/retr('calu')))*vecscale,...
					(v_reduced(typevector_reduced==2)-(retr('subtr_v')/retr('calv')))*vecscale,...
					'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')));
				if str2num(get(handles.masktransp,'String')) < 100
					scatter(x_reduced(typevector_reduced==0),y_reduced(typevector_reduced==0),'rx') %masked
				end
			end
			hold off;
			%streamlines:
			streamlinesX=retr('streamlinesX');
			streamlinesY=retr('streamlinesY');
			delete(findobj('tag','streamline'));
			if numel(streamlinesX)>0
				ustream=u-(retr('subtr_u')/retr('calu'));
				vstream=v-(retr('subtr_v')/retr('calv'));
				ustream(typevector==0)=nan;
				vstream(typevector==0)=nan;
				h=streamline(mmstream2(x,y,ustream,vstream,streamlinesX,streamlinesY,'on'));
				set (h,'tag','streamline');
				contents = get(handles.streamlcolor,'String');
				set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
			end

			if verLessThan('matlab','8.4')

				set(q, 'ButtonDownFcn', @veclick, 'hittestarea', 'on');
				set(q2, 'ButtonDownFcn', @veclick, 'hittestarea', 'on');
			else
				% >R2014a
				img_handle=findobj('type','image');
				set(img_handle, 'ButtonDownFcn', @veclick, 'PickableParts', 'visible');
				set(q, 'ButtonDownFcn', @veclick, 'PickableParts', 'visible');
				set(q2, 'ButtonDownFcn', @veclick, 'PickableParts', 'visible');
			end

			if strncmp(get(handles.multip14, 'visible'), 'on',2) %statistics panel visible
				update_Stats (x,y,u,v);
			end
			if strncmp(get(handles.multip06, 'visible'), 'on',2) %validation panel visible
				manualdeletion=retr('manualdeletion');
				frame=floor(get(handles.fileselector, 'value'));
				framemanualdeletion=[];
				if numel(manualdeletion)>0
					if size(manualdeletion,2)>=frame
						if isempty(manualdeletion{1,frame}) ==0
							framemanualdeletion=manualdeletion{frame};
						end
					end
				end
				if isempty(framemanualdeletion)==0
					hold on;
					if str2num(get(handles.masktransp,'String')) < 100
						for i=1:size(framemanualdeletion,1)
							scatter (x(framemanualdeletion(i,1),framemanualdeletion(i,2)),y(framemanualdeletion(i,1),framemanualdeletion(i,2)), 'rx', 'tag','manualdot')
						end
					end
					hold off;
				end
			end
		end

		if isempty(xzoomlimit)==0
			set(gca,'xlim',xzoomlimit)
			set(gca,'ylim',yzoomlimit)
		end
		if verLessThan('matlab','8.4')
			%do nothing
		else
			% >R2014a
			set(gca,'YlimMode','manual');set(gca,'XlimMode','manual') %in r2014b, vectors are not clipped when set to auto... (?!?)
		end
		drawnow;
	end
end

function update_Stats(x,y,u,v)
handles=gethand;
calu=retr('calu');calv=retr('calv');
calxy=retr('calxy');
x=reshape(x,size(x,1)*size(x,2),1);
y=reshape(y,size(y,1)*size(y,2),1);
u=reshape(u,size(u,1)*size(u,2),1);
v=reshape(v,size(v,1)*size(v,2),1);
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set (handles.meanu,'string', [num2str(nanmean(u*calu)) ' � ' num2str(nanstd(u*calu)) ' [px/frame]'])
	set (handles.meanv,'string', [num2str(nanmean(v*calv)) ' � ' num2str(nanstd(v*calv)) ' [px/frame]'])
else
	set (handles.meanu,'string', [num2str(nanmean(u*calu)) ' � ' num2str(nanstd(u*calu)) ' [m/s]'])
	set (handles.meanv,'string', [num2str(nanmean(v*calv)) ' � ' num2str(nanstd(v*calv)) ' [m/s]'])
end

function [x_cal,y_cal] = calibrate_xy(x,y)
handles=gethand;
x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
size_of_the_image=retr('size_of_the_image');
sizex=size_of_the_image(2);
sizey=size_of_the_image(1);
if x_axis_direction == 1
	x_cal=x;
else
	x_cal=sizex-x;
end
if y_axis_direction == 1
	y_cal=y;
else
	y_cal=sizey-y;
end
x_cal=x_cal*retr('calxy');
y_cal=y_cal*retr('calxy');
x_cal=x_cal-retr('offset_x_true');
y_cal=y_cal-retr('offset_y_true');

function veclick(~,~)
%only active if vectors are displayed.
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
resultslist=retr('resultslist');

%apply calibration, direction and offset to x and y coordinates
x=resultslist{1,(currentframe+1)/2};
y=resultslist{2,(currentframe+1)/2};

[x_cal,y_cal]=calibrate_xy (x,y);

pos=get(gca,'CurrentPoint');

xposition=round(pos(1,1));
yposition=round(pos(1,2));
findx=abs(x/xposition-1);
[trash, imagex]=find(findx==min(min(findx)));
findy=abs(y/yposition-1);
[imagey, trash]=find(findy==min(min(findy)));
info(1,1)=imagey(1,1);
info(1,2)=imagex(1,1);

if size(resultslist,1)>6 %filtered exists
	if size(resultslist,1)>10 && numel(resultslist{10,(currentframe+1)/2}) > 0 %smoothed exists
		u=resultslist{10,(currentframe+1)/2};
		v=resultslist{11,(currentframe+1)/2};
		typevector=resultslist{9,(currentframe+1)/2};
		if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
			typevector=resultslist{5,(currentframe+1)/2};
		end
	else
		u=resultslist{7,(currentframe+1)/2};
		if size(u,1)>1
			v=resultslist{8,(currentframe+1)/2};
			typevector=resultslist{9,(currentframe+1)/2};
		else %filter was applied for other frames but not for this one
			u=resultslist{3,(currentframe+1)/2};
			v=resultslist{4,(currentframe+1)/2};
			typevector=resultslist{5,(currentframe+1)/2};
		end
	end
else
	u=resultslist{3,(currentframe+1)/2};
	v=resultslist{4,(currentframe+1)/2};
	typevector=resultslist{5,(currentframe+1)/2};
end

if typevector(info(1,1),info(1,2)) ~=0
	delete(findobj('tag', 'infopoint'));
	%here, the calibration matters...
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1%not calibrated
		set(handles.u_cp, 'String', ['u:' num2str(round((u(info(1,1),info(1,2))*retr('calu')-retr('subtr_u'))*100000)/100000) ' px/fr']);
		set(handles.v_cp, 'String', ['v:' num2str(round((v(info(1,1),info(1,2))*retr('calv')-retr('subtr_v'))*100000)/100000) ' px/fr']);
		set(handles.x_cp, 'String', ['x:' num2str(round((x_cal(info(1,1),info(1,2)))*10000)/10000) ' px']);
		set(handles.y_cp, 'String', ['y:' num2str(round((y_cal(info(1,1),info(1,2)))*10000)/10000) ' px']);
	else %calibrated
		set(handles.u_cp, 'String', ['u:' num2str(round((u(info(1,1),info(1,2))*retr('calu')-retr('subtr_u'))*100000)/100000) ' m/s']);
		set(handles.v_cp, 'String', ['v:' num2str(round((v(info(1,1),info(1,2))*retr('calv')-retr('subtr_v'))*100000)/100000) ' m/s']);
		set(handles.x_cp, 'String', ['x:' num2str(round((x_cal(info(1,1),info(1,2)))*10000)/10000) ' m']);
		set(handles.y_cp, 'String', ['y:' num2str(round((y_cal(info(1,1),info(1,2)))*10000)/10000) ' m']);
	end
	derived=retr('derived');
	displaywhat=retr('displaywhat');
	if displaywhat>1
		if size (derived,2) >= (currentframe+1)/2
			if numel(derived{displaywhat-1,(currentframe+1)/2})>0
				map=derived{displaywhat-1,(currentframe+1)/2};
				name=get(handles.derivchoice,'string');
				try
					set(handles.scalar_cp, 'String', [name{displaywhat} ': ' num2str(round(map(info(1,1),info(1,2))*10000)/10000)]);
				catch
					plot_derivs_Callback
					name=get(handles.derivchoice,'string');
					set(handles.scalar_cp, 'String', [name{displaywhat} ': ' num2str(round(map(info(1,1),info(1,2))*10000)/10000)]);
				end
			else
				set(handles.scalar_cp, 'String','N/A');
			end
		else
			set(handles.scalar_cp, 'String','N/A');
		end
	else
		set(handles.scalar_cp, 'String','N/A');
	end

	hold on;
	plot(x(info(1,1),info(1,2)),y(info(1,1),info(1,2)), 'ys', 'tag', 'infopoint','linewidth', 1.5, 'markersize', 20);
	plot(x(info(1,1),info(1,2)),y(info(1,1),info(1,2)), 'yx', 'tag', 'infopoint','linewidth', 0.5, 'markersize', 20);
	hold off;

end

function toolsavailable(inpt)
%0: disable all tools
%1: re-enable tools that were previously also enabled
hgui=getappdata(0,'hgui');
handles=gethand;
if inpt==0
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		panon_Callback(handles.panon)
	end
end

elementsOfCrime=findobj(hgui, 'type', 'uicontrol');
elementsOfCrime2=findobj(hgui, 'type', 'uimenu');
statuscell=get (elementsOfCrime, 'enable');
wasdisabled=zeros(size(statuscell),'uint8');

if inpt==0
	set(elementsOfCrime, 'enable', 'off');
	for i=1:size(statuscell,1)
		if strncmp(statuscell{i,1}, 'off',3) ==1
			wasdisabled(i)=1;
		end
	end
	put('wasdisabled', wasdisabled);
	set(elementsOfCrime2, 'enable', 'off');
else
	wasdisabled=retr('wasdisabled');
	set(elementsOfCrime, 'enable', 'on');
	set(elementsOfCrime(wasdisabled==1), 'enable', 'off');
	set(elementsOfCrime2, 'enable', 'on');
end
set(handles.progress, 'enable', 'on');
set(handles.overall, 'enable', 'on');
set(handles.totaltime, 'enable', 'on');
set(handles.messagetext, 'enable', 'on');

function clear_user_content
handles=gethand;
put('pathname',[]); %last path
put ('filename',[]); %only for displaying
put ('filepath',[]); %full path and filename for analyses
set (handles.filenamebox, 'string', 'N/A');
put ('resultslist', []); %clears old results
put ('derived',[]);
put('displaywhat',1);%vectors
put('ismean',[]);
put('framemanualdeletion',[]);
put('manualdeletion',[]);
put('streamlinesX',[]);
put('streamlinesY',[]);
set(handles.fileselector, 'value',1);

set(handles.minintens, 'string', 0);
set(handles.maxintens, 'string', 1);

%Clear all things
clear_vel_limit_Callback %clear velocity limits
clear_roi_Callback
%clear_mask_Callback:
delete(findobj(gca,'tag', 'maskplot'));
put ('maskiererx',{});
put ('maskierery',{});
set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set (handles.external_mask_progress, 'string', '');

%reset zoom
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
put('xzoomlimit', []);
put('yzoomlimit', []);

sliderrange
sliderdisp
zoom reset

function loadvideobutton_Callback(~,~,~)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[retr('pathname') '\'];
else
	pathname=[retr('pathname') '/'];
end
handles=gethand;
displogo(0)
setappdata(hgui,'video_selection_done',0);
if retr('parallel')==1 %videos are not yet supported in parallel processing. But an opened parallel pool (that is not used) slows down video processing
	pivparpool('close')
	disp('Parallel video processing is not yet supported by PIVlab. Parallel pool was therefore closed.')
end
vid_import(pathname);
uiwait
if getappdata(hgui,'video_selection_done')
	put('expected_image_size',[])
	pathname = getappdata(hgui,'pathname');
	filename = getappdata(hgui,'filename');
	filepath = getappdata(hgui,'filepath');
	%save video file object in GUI
	put('video_reader_object',VideoReader(filepath{1}));
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		panon_Callback(handles.zoomon)
	end
	put('xzoomlimit',[]);
	put('yzoomlimit',[]);
	sliderrange
	set (handles.filenamebox, 'string', filename);
	put('bg_img_A',[]);
	put('bg_img_B',[]);
	put ('resultslist', []); %clears old results
	put ('derived',[]);
	put('displaywhat',1);%vectors
	put('ismean',[]);
	put('framemanualdeletion',[]);
	put('manualdeletion',[]);
	put('streamlinesX',[]);
	put('streamlinesY',[]);
	set(handles.fileselector, 'value',1);
	set(handles.minintens, 'string', 0);
	set(handles.maxintens, 'string', 1);
	%Clear all things
	clear_vel_limit_Callback %clear velocity limits
	clear_roi_Callback
	%clear_mask_Callback:
	delete(findobj(gca,'tag', 'maskplot'));
	put ('maskiererx',{});
	put ('maskierery',{});
	set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
	set (handles.external_mask_progress, 'string', '');
	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	put('xzoomlimit', []);
	put('yzoomlimit', []);
	set(handles.filenamebox,'value',1);
	sliderdisp %displays raw image when slider moves
	zoom reset
	put('sequencer',0);%time-resolved = only possibility for video
end

function loadimgsbutton_Callback(~,~,useGUI,path)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[retr('pathname') '\'];
else
	pathname=[retr('pathname') '/'];
end
handles=gethand;
displogo(0)
%remember imagesize of currently loaded images
try
	old_img_size=size(get_img(1));
catch
	old_img_size=0;
end
if useGUI ==1
	if ispc==1
		try
			path=uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		catch
			path=uipickfiles ('FilterSpec', pwd, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		end
	else
		try
			path=uipickfiles ('FilterSpec', pathname, 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		catch
			path=uipickfiles ('FilterSpec', pwd, 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		end
	end
	put('expected_image_size',[])
end
if ~isequal(path,0)
	setappdata(hgui,'video_selection_done',0);
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		panon_Callback(handles.zoomon)
	end
	put('xzoomlimit',[]);
	put('yzoomlimit',[]);

	sequencer=retr('sequencer');
	if sequencer==1
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
				else
					filepath{size(filepath,1)+1,1}=path(i).name;
				end
			end
		end
	elseif sequencer==0
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
				else
					filepath{size(filepath,1)+1,1}=path(i).name;
					filepath{size(filepath,1)+1,1}=path(i).name;
				end
			end
		end
	elseif sequencer == 2 % Reference image style
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					reference_image_i=i;
					filepath=[];
				else
					filepath{size(filepath,1)+1,1}=path(reference_image_i).name;
					filepath{size(filepath,1)+1,1}=path(i).name;
				end
			end
		end
	end
	if size(filepath,1) > 1
		if mod(size(filepath,1),2)==1
			cutoff=size(filepath,1);
			filepath(cutoff)=[];
		end
		filename=cell(1);
		for i=1:size(filepath,1)
			if ispc==1
				zeichen=strfind(filepath{i,1},'\');
			else
				zeichen=strfind(filepath{i,1},'/');
			end
			currentpath=filepath{i,1};
			if mod(i,2) == 1
				filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
			else
				filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
			end
		end
		%extract path:
		pathname=currentpath(1:zeichen(1,size(zeichen,2))-1);
		put('pathname',pathname); %last path
		put ('filename',filename); %only for displaying
		put ('filepath',filepath); %full path and filename for analyses
		sliderrange
		set (handles.filenamebox, 'string', filename);
		put ('resultslist', []); %clears old results
		put ('derived',[]);
		put('displaywhat',1);%vectors
		put('ismean',[]);
		put('framemanualdeletion',[]);
		put('manualdeletion',[]);
		put('streamlinesX',[]);
		put('streamlinesY',[]);
		put('bg_img_A',[]);
		put('bg_img_B',[]);
		set(handles.bg_subtract,'Value',0);
		set(handles.fileselector, 'value',1);

		set(handles.minintens, 'string', 0);
		set(handles.maxintens, 'string', 1);

		%Clear all things
		clear_vel_limit_Callback %clear velocity limits
		if old_img_size ~= 0%ROI should be cleared only when image size of loaded imgs is different from before...
			new_img_size=size(get_img(1));
			if new_img_size(1) ~= old_img_size(1) || new_img_size(2) ~= old_img_size(2)
				clear_roi_Callback
			end
		end
		%clear_mask_Callback:
		delete(findobj(gca,'tag', 'maskplot'));
		put ('maskiererx',{});
		put ('maskierery',{});
		set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
		set (handles.external_mask_progress, 'string', '');
		%reset zoom
		set(handles.panon,'Value',0);
		set(handles.zoomon,'Value',0);
		put('xzoomlimit', []);
		put('yzoomlimit', []);
		%filelistbox auf erste position
		set(handles.filenamebox,'value',1);
		sliderdisp %displays raw image when slider moves
		zoom reset
		set(getappdata(0,'hgui'), 'Name',['PIVlab ' retr('PIVver') '   [Path: ' pathname ']']) %for people like me that always forget what dataset they are currently working on...
	else
		errordlg('Please select at least two images ( = 1 pair of images)','Error','on')
	end
end

function sliderrange
filepath=retr('filepath');
handles=gethand;
if retr('video_selection_done') == 0
	if size(filepath,1)>2
		sliderstepcount=size(filepath,1)/2;
		set(handles.fileselector, 'enable', 'on');
		set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
	else
		sliderstepcount=1;
		set(handles.fileselector, 'enable', 'off');
		set (handles.fileselector,'value',1, 'min', 1,'max',2,'sliderstep', [0.5 0.5]);
	end
else % a video has been imported
	%video_frame_selection=retr('video_frame_selection');
	%sliderstepcount=numel(video_frame_selection)/2;
	%set(handles.fileselector, 'enable', 'on');
	%set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
	sliderstepcount=size(filepath,1)/2;
	set(handles.fileselector, 'enable', 'on');
	set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
end

function fileselector_Callback(~, ~, ~)
filepath=retr('filepath');
if size(filepath,1) > 1 || retr('video_selection_done') == 1
	try
		sliderdisp
	catch
	end
	handles=gethand;
	toggler=retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	if retr('video_selection_done') == 0
		set(handles.filenamebox,'value',selected);
	else
		set(handles.filenamebox,'value',1);
	end
end


function togglepair_Callback(~, ~, ~)
toggler=get(gco, 'value');
put ('toggler',toggler);
filepath=retr('filepath');
capturing=retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	if size(filepath,1) > 1 || retr('video_selection_done') == 1
		sliderdisp
		handles=gethand;
		if strncmp(get(handles.multip03, 'visible'), 'on',2)
			preview_preprocess_Callback
		end
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		if retr('video_selection_done') == 0
			set(handles.filenamebox,'value',selected);
		else
			set(handles.filenamebox,'value',1);
		end
	end
end

function overlappercent
handles=gethand;
perc=100-str2double(get(handles.step,'string'))/str2double(get(handles.intarea,'string'))*100;
set (handles.steppercentage, 'string', ['= ' int2str(perc) '%']);

function scatterplotter_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
			else
				%filter was applied to some other frame than this
				%load unfiltered results
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	calu=retr('calu');calv=retr('calv');
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	h=figure;
	screensize=get( 0, 'ScreenSize' );
	%rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Scatter plot u & v, frame ' num2str(currentframe)],'tag', 'derivplotwindow');
	h2=scatter(u*calu-retr('subtr_u'),v*calv-retr('subtr_v'),'r.');
	set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
		xlabel('u [px/frame]');
		ylabel('v [px/frame]');
	else
		xlabel('u [m/s]');
		ylabel('v [m/s]');
	end
end

function pref_apply_Callback (~, ~)
hgui=getappdata(0,'hgui');
handles=gethand;
panelwidth=round(get(handles.panelslider,'Value'));
put('panelwidth',panelwidth);
put('quickwidth',panelwidth);
destroyUI
generateUI
MainWindow_ResizeFcn(gcf)
preferences_Callback
clear_user_content
displogo(1)
%PIVlab should clear all user data here...

function dcc_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set(handles.fftmulti,'value',0)
	set(handles.ensemble,'value',0)

	set(handles.uipanel42,'visible','off')
	set(handles.CorrQuality,'visible','off')
	set(handles.text914,'visible','off')
	set(handles.mask_auto_box,'visible','off')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')

else
	set(handles.dcc,'value',1)
end
dispinterrog

function autocrop (file,fmt)

A=imread(file);
B=rgb2gray(A);

for i=1:ceil(size(B,1)/2)
	val(i)=mean(B(i,:));
end
startcropy=max([find(val==255) 1]);
for i=size(B,1):-1:ceil(size(B,1)/2)
	val2(i)=mean(B(i,:));
end
endcropy=min(find(val2==255,1,'first'));
clear val val2
for i=1:ceil(size(B,2)/2)
	val(i)=mean(B(:,i));
end
startcropx=max([find(val==255) 1]);
for i=size(B,2):-1:ceil(size(B,2)/2)
	val2(i)=mean(B(:,i));
end
endcropx=min(find(val2==255,1,'first'));

if isempty(startcropx)
	startcropx = 1;
end
if isempty(startcropy)
	startcropy = 1;
end
if isempty(endcropx)
	endcropx = size(B,2);
end
if isempty(endcropy)
	endcropy = size(B,1);
end


A=A(startcropy:endcropy,startcropx:endcropx,:);

if fmt==1 %jpg
	imwrite(A,file,'quality', 100);
else
	imwrite(A,file);
end

function mat_file_save (currentframe,FileName,PathName,type)
resultslist=retr('resultslist');
if isempty(resultslist)==0
	derived=retr('derived');
	calxy=retr('calxy');
	calu=retr('calu');calv=retr('calv');
	nrframes=size(resultslist,2);

	if size(resultslist,1)< 11
		resultslist{11,nrframes}=[]; %make sure resultslist has cells for all params
	end
	if isempty(derived)==0
		if size(derived,1)<= 10 || size(derived,2) < nrframes
			derived{11,nrframes}=[]; %make sure derived has cells for all params
		end
	else
		derived=cell(11,nrframes);
	end

	if calxy==1 && (calu==1 ||calu==-1)
		units='[px] respectively [px/frame]';
	else
		units='[m] respectively [m/s]';
	end
	%ohne alles: 6 hoch
	%mit filtern: 11 hoch
	%mit smoothed, 11 hoch und inhalt...
	u_original=cell(nrframes,1);
	v_original=u_original;
	x=u_original;
	y=u_original;
	typevector_original=u_original;
	u_filtered=u_original;
	v_filtered=v_original;
	typevector_filtered=u_original;
	u_smoothed=u_original;
	v_smoothed=u_original;
	vorticity=cell(size(derived,2),1);
	velocity_magnitude=vorticity;
	u_component=vorticity;
	v_component=vorticity;
	divergence=vorticity;
	vortex_locator=vorticity;
	shear_rate=vorticity;
	strain_rate=vorticity;
	LIC=vorticity;
	vectorangle=vorticity;
	if type==1
		nrframes=1;
	end


	%hier unterscheiden:nur ein frame oder all?

	for i=1:nrframes
		if type==2 %all frames
			currentframe=i;
		end
		[x_cal,y_cal]=calibrate_xy (resultslist{1,currentframe},resultslist{2,currentframe});
		x{i,1}=x_cal;
		y{i,1}=y_cal;

		u_original{i,1}=resultslist{3,currentframe}*calu;
		v_original{i,1}=resultslist{4,currentframe}*calv;
		typevector_original{i,1}=resultslist{5,currentframe};
		u_filtered{i,1}=resultslist{7,currentframe}*calu;
		v_filtered{i,1}=resultslist{8,currentframe}*calv;
		typevector_filtered{i,1}=resultslist{9,currentframe};
		u_smoothed{i,1}=resultslist{10,currentframe}*calu;
		v_smoothed{i,1}=resultslist{11,currentframe}*calv;

		vorticity{i,1}=derived{1,currentframe};
		velocity_magnitude{i,1}=derived{2,currentframe};
		u_component{i,1}=derived{3,currentframe};
		v_component{i,1}=derived{4,currentframe};
		divergence{i,1}=derived{5,currentframe};
		vortex_locator{i,1}=derived{6,currentframe};
		shear_rate{i,1}=derived{7,currentframe};
		strain_rate{i,1}=derived{8,currentframe};
		LIC{i,1}=derived{9,currentframe};
		vectorangle{i,1}=derived{10,currentframe};
		correlation_map{i,1}=derived{11,currentframe};
	end
	if type == 1 %nur ein frame
		x=x{i,1};
		y=y{i,1};
		u_original=u_original{i,1};
		v_original=v_original{i,1};
		typevector_original=typevector_original{i,1};
		u_filtered=u_filtered{i,1};
		v_filtered=v_filtered{i,1};
		typevector_filtered=typevector_filtered{i,1};
		u_smoothed=u_smoothed{i,1};
		v_smoothed=v_smoothed{i,1};

		vorticity=vorticity{i,1};
		velocity_magnitude=velocity_magnitude{i,1};
		u_component=u_component{i,1};
		v_component=v_component{i,1};
		divergence=divergence{i,1};
		vortex_locator=vortex_locator{i,1};
		shear_rate=shear_rate{i,1};
		strain_rate=strain_rate{i,1};
		LIC=LIC{i,1};
		vectorangle=vectorangle{i,1};
		correlation_map=correlation_map{i,1};
	end
end

information={'The first dimension of the variables is the frame number.';'The variables contain all data that was calculated in the PIVlab GUI.';'If some data was not calculated, the corresponding cell is empty.';'Typevector is 0 for masked vector, 1 for regular vector, 2 for filtered vector';'u_original and v_original are the unmodified velocities from the cross-correlation.';'u_filtered and v_filtered is the above incl. your data validation selection.';'u_smoothed and v_smoothed is the above incl. your smoothing selection.'};
save(fullfile(PathName,FileName), 'x','y','u_original','v_original','typevector_original','u_filtered','v_filtered','typevector_filtered','u_smoothed','v_smoothed','vorticity','velocity_magnitude','u_component','v_component','divergence','vortex_locator','shear_rate','strain_rate','LIC','calxy','calu', 'calv','units','information','vectorangle','correlation_map');
%}

function file_save (currentframe,FileName,PathName,type)
handles=gethand;
resultslist=retr('resultslist');
derived=retr('derived');
filename=retr('filename');
calu=retr('calu');calv=retr('calv');
calxy=retr('calxy');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	[x_cal,y_cal]=calibrate_xy (x,y);

	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe};
			if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
				typevector=resultslist{5,currentframe};
			end
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe};
			else
				%filter was applied to some other frame than this
				%load unfiltered results
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
		typevector=resultslist{5,currentframe};
	end
end
u(typevector==0)=NaN;
v(typevector==0)=NaN;
subtract_u=retr('subtr_u');
subtract_v=retr('subtr_v');

if type==1 %ascii file
	delimiter=get(handles.delimiter, 'value');
	if delimiter==1
		delimiter=',';
	elseif delimiter==2
		delimiter='\t';
	elseif delimiter==3
		delimiter=' ';
	end
	if get(handles.addfileinfo, 'value')==1
		header1=['PIVlab, ASCII chart output - ' date];
		header2=['FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> m): ' num2str(calxy) ', conversion factor uv (px/frame -> m/s): ' num2str(calu)];
	else
		header1=[];
		header2=[];
	end
	if get(handles.add_header, 'value')==1
		if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
			if get(handles.export_vort, 'Value') == 1 %alle derivatives exportieren, nicht kalibriert
				header3=['x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'Vector type [-]' delimiter 'vorticity [1/frame]' delimiter 'magnitude [px/frame]' delimiter 'divergence [1/frame]' delimiter 'dcev [1]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
			else
				header3=['x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'Vector type [-]'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			end
		else
			if get(handles.export_vort, 'Value') == 1  %alle derivatives exportieren, kalibriert

				header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'Vector type [-]' delimiter 'vorticity [1/s]' delimiter 'magnitude [m/s]' delimiter 'divergence [1/s]' delimiter 'dcev [1]' delimiter 'simple shear [1/s]' delimiter 'simple strain [1/s]' delimiter 'vector direction [degrees]'];
			else
				header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'Vector type [-]'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			end
		end
	else
		header3=[];
	end
	if isempty(header1)==0
		fid = fopen(fullfile(PathName,FileName), 'w');
		fprintf(fid, [header1 '\r\n']);
		fclose(fid);
	end
	if isempty(header2)==0
		fid = fopen(fullfile(PathName,FileName), 'a');
		fprintf(fid, [header2 '\r\n']);
		fclose(fid);
	end
	if isempty(header3)==0
		fid = fopen(fullfile(PathName,FileName), 'a');
		fprintf(fid, [header3 '\r\n']);
		fclose(fid);
	end
	if get(handles.export_vort, 'Value') == 1 %sollen alle derivatives exportiert werden?
		derivative_calc(currentframe,2,1); %vorticity
		derivative_calc(currentframe,3,1); %magnitude
		%u und v habe ich ja...
		derivative_calc(currentframe,6,1); %divergence
		derivative_calc(currentframe,7,1); %dcev
		derivative_calc(currentframe,8,1); %shear
		derivative_calc(currentframe,9,1); %strain
		derivative_calc(currentframe,11,1); %vectorangle
		derived=retr('derived');
		vort=derived{2-1,currentframe};
		magn=derived{3-1,currentframe};
		div=derived{6-1,currentframe};
		dcev=derived{7-1,currentframe};
		shear=derived{8-1,currentframe};
		strain=derived{9-1,currentframe};
		vectorangle=derived{11-1,currentframe};
		%correlation_map=derived{12-1,currentframe};
		%wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv-subtract_u,size(u,1)*size(u,2),1) reshape(v*caluv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(dcev,size(dcev,1)*size(dcev,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(dcev,size(dcev,1)*size(dcev,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
	else %no derivatives.
		%wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv-subtract_u,size(u,1)*size(u,2),1) reshape(v*caluv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1)];
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1)];
	end
	dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc');
end %type==1

if type==2 %NOT USED ANYMORE matlab file
end

if type==3 %paraview vtk PARAVIEW DATEN OHNE die ganzen derivatives.... Berechnet man doch eh direkt in Paraview.
	u=u*calu-subtract_u;
	v=v*calv-subtract_v;

	nr_of_elements=numel(x_cal);
	fid = fopen(fullfile(PathName,FileName), 'w');
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
		info='[px/frame]';
	else
		info='[m/s]';
	end
	%ASCII file header
	fprintf(fid, '# vtk DataFile Version 3.0\n');
	fprintf(fid, ['VTK from PIVlab ' info '\n']);
	fprintf(fid, 'BINARY\n\n');
	fprintf(fid, 'DATASET STRUCTURED_GRID\n');
	fprintf(fid, ['DIMENSIONS ' num2str(size(x_cal,1)) ' ' num2str(size(x_cal,2)) ' ' num2str(size(x_cal,3)) '\n']);
	fprintf(fid, ['POINTS ' num2str(nr_of_elements) ' float\n']);
	fclose(fid);

	%append binary x,y,z data
	fid = fopen(fullfile(PathName,FileName), 'a');
	fwrite(fid, [reshape(x_cal,1,nr_of_elements);  reshape(y_cal,1,nr_of_elements); reshape(y_cal,1,nr_of_elements)*0],'float','b');

	%append another ASCII sub header
	fprintf(fid, ['\nPOINT_DATA ' num2str(nr_of_elements) '\n']);
	fprintf(fid, 'VECTORS velocity_vectors float\n');

	%append binary u,v,w data
	fwrite(fid, [reshape(u,1,nr_of_elements);  reshape(v,1,nr_of_elements); reshape(v,1,nr_of_elements)*0],'float','b');

	fclose(fid);

end %type3

if type==4 %tecplot file
	delimiter = ' ';
	header1=['# PIVlab by W.Th. & E.J.S., TECPLOT output - ' date];
	header2=['# FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> m): ' num2str(calxy) ', conversion factor uv (px/frame -> m/s): ' num2str(calu)];
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
		if get(handles.export_vort_tec, 'Value') == 1 %alle derivatives exportieren, nicht kalibriert
			header3=['# x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'isNaN?' delimiter 'vorticity [1/frame]' delimiter 'magnitude [px/frame]' delimiter 'divergence [1/frame]' delimiter 'dcev [1]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN", "vorticity", "magnitude", "divergence", "dcev", "simple_shear", "simple_strain", "vector_direction"';
		else
			header3=['# x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'isNaN?'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN"';
		end
	else
		if get(handles.export_vort_tec, 'Value') == 1  %alle derivatives exportieren, kalibriert
			header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'isNaN?' delimiter 'vorticity [1/s]' delimiter 'magnitude [m/s]' delimiter 'divergence [1/s]' delimiter 'dcev [1]' delimiter 'simple shear [1/s]' delimiter 'simple strain [1/s]' delimiter 'vector direction [degrees]'];
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN", "vorticity", "magnitude", "divergence", "dcev", "simple_shear", "simple_strain", "vector_direction"';
		else
			header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'isNaN?'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN"';
		end
	end
	header4 = ['TITLE = "PIVlab frame: ' int2str(currentframe) '"'];
	header6 = ['ZONE I=' int2str(size(x_cal,2)) ', J=' int2str(size(x_cal,1)) ', K=1, F=POINT, T="' int2str(currentframe) '"'];

	fid = fopen(fullfile(PathName,FileName), 'w');
	fprintf(fid, [header1 '\r\n' header2 '\r\n' header3 '\r\n' header4 '\r\n' header5 '\r\n' header6 '\r\n']);
	fclose(fid);

	if get(handles.export_vort_tec, 'Value') == 1 %sollen alle derivatives exportiert werden?
		derivative_calc(currentframe,2,1); %vorticity
		derivative_calc(currentframe,3,1); %magnitude
		%u und v habe ich ja...
		derivative_calc(currentframe,6,1); %divergence
		derivative_calc(currentframe,7,1); %dcev
		derivative_calc(currentframe,8,1); %shear
		derivative_calc(currentframe,9,1); %strain
		derivative_calc(currentframe,11,1); %vectorangle
		%derivative_calc(currentframe,12,1); %correlation coefficient
		derived=retr('derived');
		vort=derived{2-1,currentframe};
		magn=derived{3-1,currentframe};
		div=derived{6-1,currentframe};
		dcev=derived{7-1,currentframe};
		shear=derived{8-1,currentframe};
		strain=derived{9-1,currentframe};
		vectorangle=derived{11-1,currentframe};
		%correlation_map=derived{12-1,currentframe};
		nanmarker=zeros(size(x));
		nanmarker(isnan(u))=1;
		%Nans mit nullen f체llen
		u(isnan(u))=0;
		v(isnan(v))=0;
		vort(isnan(vort))=0;
		magn(isnan(magn))=0;
		div(isnan(div))=0;
		dcev(isnan(dcev))=0;
		shear(isnan(shear))=0;
		strain(isnan(strain))=0;
		vectorangle(isnan(vectorangle))=0;
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(nanmarker,size(v,1)*size(v,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(dcev,size(dcev,1)*size(dcev,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
	else
		nanmarker=zeros(size(x));
		nanmarker(isnan(u))=1;
		u(isnan(u))=0;
		v(isnan(v))=0;
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(nanmarker,size(v,1)*size(v,2),1)];
	end
	wholeLOT=sortrows(wholeLOT,2);

	dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc');
end %f체r mehrere Zones: einfach header6 nochmal appenden, dann whileLOT f체r den n채chsten frame berechnen und appenden etc...
% Dr체cken von "Save current": put('TecplotMultisave',0);Tecplotcallback.
%Dr체cken von "Save all": put('TecplotMultisave',1);Tecplotcallback;put('TecplotMultisave',0)
%type==4


function roi_select_Callback(~, ~, ~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 || retr('video_selection_done') == 1
	delete(findobj('tag','warning'));
	toolsavailable(0);
	toggler=retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	filepath=retr('filepath');
	roirect = round(getrect(gca));
	if roirect(1,3)~=0 && roirect(1,4)~=0
		[currentimage_dummy,~]=get_img(selected);
		imagesize(1)=size(currentimage_dummy,1);
		imagesize(2)=size(currentimage_dummy,2);
		if roirect(1)<1
			roirect(1)=1;
		end
		if roirect(2)<1
			roirect(2)=1;
		end
		if roirect(3)>imagesize(2)-roirect(1)
			roirect(3)=imagesize(2)-roirect(1);
		end
		if roirect(4)>imagesize(1)-roirect(2)
			roirect(4)=imagesize(1)-roirect(2);
		end
		put ('roirect',roirect);
		dispROI

		set(handles.roi_hint, 'String', 'ROI active' , 'backgroundcolor', [0.5 1 0.5]);
	else
		text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k','tag','warning');
	end
	toolsavailable(1);
end

function clear_roi_Callback(~, ~, ~)
handles=gethand;
delete(findobj(gca,'tag', 'roiplot'));
delete(findobj(gca,'tag', 'roitext'));
delete(findobj('tag','warning'));
put ('roirect',[]);
set(handles.roi_hint, 'String', 'ROI inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set(handles.ROI_Man_x,'String','');
set(handles.ROI_Man_y,'String','');
set(handles.ROI_Man_w,'String','');
set(handles.ROI_Man_h,'String','');

function dispROI
handles=gethand;
roirect=retr('roirect');
x=[roirect(1)  roirect(1)+roirect(3) roirect(1)+roirect(3)  roirect(1)            roirect(1) ];
y=[roirect(2)  roirect(2)            roirect(2)+roirect(4)  roirect(2)+roirect(4) roirect(2) ];
delete(findobj(gca,'tag', 'roiplot'));
delete(findobj(gca,'tag', 'roitext'));
rectangle('Position',roirect,'LineWidth',1,'LineStyle','-','edgecolor','b','tag','roiplot')
rectangle('Position',roirect,'LineWidth',1,'LineStyle',':','edgecolor','y','tag','roiplot')
set(handles.ROI_Man_x,'String',int2str(roirect(1)));
set(handles.ROI_Man_y,'String',int2str(roirect(2)));
set(handles.ROI_Man_w,'String',int2str(roirect(3)));
set(handles.ROI_Man_h,'String',int2str(roirect(4)));

function dispMASK(opaqueness)
%if opaqueness == 1
%maskcolor = [0.3 0.1 0.1];
maskcolor = [0.75 0.25 0.25];
%else
%	maskcolor = [1 0 0];
%end
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
maskiererx=retr('maskiererx');
maskierery=retr('maskierery');
delete(findobj(gca,'tag', 'maskplot'));
hold on;
for j=1:min([size(maskiererx,1) size(maskierery,1)])
	if isempty(maskiererx{j,currentframe})==0
		ximask=maskiererx{j,currentframe};
		yimask=maskierery{j,currentframe};
		if verLessThan('matlab','8.4')
			h=fill(ximask,yimask,'r','facecolor', [0.3 0.1 0.1],'linestyle','none','tag','maskplot');
		else
			% >R2014a
			try
				h=fill(ximask,yimask,'r','facecolor', maskcolor,'linestyle','none','tag','maskplot','Facealpha',opaqueness);
			catch
			end
		end
		%h=area(ximask,yimask,'facecolor', [0.3 0.1 0.1],'linestyle', 'none','tag','maskplot');
	else
		break;
	end
end
hold off;

function draw_mask_Callback(~, ~, ~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 || retr('video_selection_done') == 1
	toolsavailable(0);
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	filepath=retr('filepath');
	amount=size(filepath,1);
	%currentframe and currentframe+1 =is a pair with identical mask.
	%maskiererx&y contains masks. 3rd dimension is frame nr.
	maskiererx=retr('maskiererx');
	maskierery=retr('maskierery');
	[mask,ximask,yimask]=roipoly;
	insertion=1;
	for j=size(maskiererx,1):-1:1
		try
			if isempty(maskiererx{j,currentframe})==0
				insertion=j+1;
				break
			end
		catch
			maskiererx{1,currentframe}=[];
			maskierery{1,currentframe}=[];
			insertion=1;
		end
	end
	maskiererx{insertion,currentframe}=ximask;
	maskiererx{insertion,currentframe+1}=ximask;
	maskierery{insertion,currentframe}=yimask;
	maskierery{insertion,currentframe+1}=yimask;
	put('maskiererx' ,maskiererx);
	put('maskierery' ,maskierery);
	dispMASK(0.333) %hier so lassen, damit nach dem zeichnen die Maske angezeigt wird
	set(handles.mask_hint, 'String', 'Mask active', 'backgroundcolor', [0.5 1 0.5]);
	toolsavailable(1);
end

function clear_mask_Callback(~, ~, ~)
button = questdlg('Do you want to remove all masks?','Delete?','Yes','Cancel','Cancel');
if strncmp(button,'Yes',3)==1
	handles=gethand;
	delete(findobj(gca,'tag', 'maskplot'));
	put ('maskiererx',{});
	put ('maskierery',{});
	set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
	set (handles.external_mask_progress, 'string', '');
end

function clear_current_mask_Callback(~, ~, ~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1
	delete(findobj(gca,'tag', 'maskplot'));
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	maskiererx=retr('maskiererx');
	maskierery=retr('maskierery');
	for i=1:size(maskiererx,1)
		maskiererx{i,currentframe}=[];
		maskiererx{i,currentframe+1}=[];
		maskierery{i,currentframe}=[];
		maskierery{i,currentframe+1}=[];
	end
	try
		emptycells=cellfun('isempty',maskiererx);
	catch
		disp('Problems with old Matlab version... Please update Matlab or unexpected things might happen...')
	end
	if mean(double(emptycells))==1 %not very sophisticated way to determine if all cells are empty
		set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
		set (handles.external_mask_progress, 'string', '');
	end
	put('maskiererx' ,maskiererx);
	put('maskierery' ,maskierery);
end

function maskToSelected_Callback(~, ~, ~)
handles=gethand;
filepath=retr('filepath');
if size(filepath,1) > 1 || retr('video_selection_done') == 1
	str = strrep(get(handles.maskapplyselect,'string'),'-',':');
	endinside=strfind(str, 'end');
	if isempty(endinside)==0
		if retr('video_selection_done') == 0
			str = strrep(str,'end',num2str(size(filepath,1)/2));
		else
			video_frame_selection=retr('video_frame_selection');
			str = strrep(str,'end',num2str(numel(video_frame_selection)/2));
		end
	end
	selectionok=1;
	strnum=str2num(str);
	if isempty(strnum)==1 || isempty(strfind(str,'.'))==0 || isempty(strfind(str,';'))==0
		msgbox(['Error in frame selection syntax. Please use the following syntax (examples):' sprintf('\n') '1:3' sprintf('\n') '1,3,7,9' sprintf('\n') '1:3,7,8,9,11:13' ],'Error','error','modal')
		selectionok=0;
	end
	amount=max(strnum);
	if retr('video_selection_done') == 0
		if amount*2>size(filepath,1)
			msgbox(['Selected frames out of range.'],'Error','error','modal')
			selectionok=0;
		end
	else
		video_frame_selection=retr('video_frame_selection');
		if amount*2>numel(video_frame_selection)
			msgbox(['Selected frames out of range.'],'Error','error','modal')
			selectionok=0;
		end
	end
	mini=min(strnum);
	%checken ob nicht gr철횩er als geladene frame anzahl.
	if selectionok==1
		currentframe=2*floor(get(handles.fileselector, 'value'))-1;
		%amount=size(filepath,1);

		maskiererx=retr('maskiererx');
		maskierery=retr('maskierery');

		for i=1:size(strnum,2)
			for j=1:size(maskiererx,1)
				%keyboard
				%in frame 1=maskiererx 1und2
				maskiererx{j,strnum(i)*2-1}=maskiererx{j,currentframe};
				maskiererx{j,strnum(i)*2}=maskiererx{j,currentframe+1};
				maskierery{j,strnum(i)*2-1}=maskierery{j,currentframe};
				maskierery{j,strnum(i)*2}=maskierery{j,currentframe+1};

			end
		end
		put('maskiererx' ,maskiererx);
		put('maskierery' ,maskierery);
	end
end

function save_mask_Callback(~, ~, ~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 %did the user load images?
	[maskfile,maskpath] = uiputfile('*.mat','Save PIVlab mask','PIVlab_mask.mat');
	if isequal(maskfile,0) | isequal(maskpath,0)
		%do nothing
	else
		maskiererx=retr('maskiererx');
		maskierery=retr('maskierery');
		save(fullfile(maskpath,maskfile),'maskiererx','maskierery');
	end
end

function load_mask_Callback(~, ~, ~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 %did the user load images?
	[maskfile,maskpath] = uigetfile('*.mat','Load PIVlab mask','PIVlab_mask.mat');
	if isequal(maskfile,0) | isequal(maskpath,0)
		%do nothing
	else
		load(fullfile(maskpath,maskfile),'maskiererx','maskierery');
		try
			put('maskiererx' ,maskiererx);
			put('maskierery' ,maskierery);
		catch
			disp(['Error. No mask data found in ' fullfile(maskpath,maskfile)])
		end
		sliderdisp
	end
end


function external_mask_Callback(~, ~, ~)
uiwait(helpdlg(['You can load grayscale *.tif image(s) here:' sprintf('\n') 'White = masked, black = no mask.' sprintf('\n') 'If you select multiple mask files, they will be sorted alphabetically and inserted starting from the currently active frame.']));

filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 %did the user load images?
	[FileName,PathName] = uigetfile('*.tif','Select the binary image mask file','multiselect','on');
	if isequal(FileName,0) | isequal(PathName,0)
	else
		if ischar(FileName)==1
			AnzahlMasks=1;
		else
			AnzahlMasks=numel(FileName);
		end
		for j=1:AnzahlMasks
			if AnzahlMasks>1
				A=imread(fullfile(PathName,FileName{j}));
				set (handles.external_mask_progress, 'string', ['Please wait... (' int2str((j-1)/AnzahlMasks*100) '%)']);
				drawnow;
			else
				A=imread(fullfile(PathName,FileName));
			end
			A=im2bw(A,0.5); %#ok<*IM2BW>
			A1=zeros(size(A));
			A2=A1;A3=A1;A4=A1;
			%cut mask in 4 pieces to minimize parent / child / hole problems in masks
			rowshalf=round(size(A,1)/2);
			colshalf=round(size(A,2)/2);
			%A1(1:rowshalf,1:colshalf) = A(1:rowshalf,1:colshalf);%top left part
			%A2(1:rowshalf,colshalf+1:end) = A(1:rowshalf,colshalf+1:end);%top right half
			%A3(rowshalf+1:end,1:colshalf) = A(rowshalf+1:end,1:colshalf); % lower left part
			%A4(rowshalf+1:end,colshalf+1:end) = A(rowshalf+1:end,colshalf+1:end); %lower right part
			A1(1:rowshalf,1:colshalf) = A(1:rowshalf,1:colshalf);%top left part
			A2(1:rowshalf,colshalf:end) = A(1:rowshalf,colshalf:end);%top right half
			A3(rowshalf:end,1:colshalf) = A(rowshalf:end,1:colshalf); % lower left part
			A4(rowshalf:end,colshalf:end) = A(rowshalf:end,colshalf:end); %lower right part


			%A(:,round(size(A,2)/2))=0;
			%A(round(size(A,1)/2),:)=0;
			%B=A;
			%B=im2bw(abs(A-B));


			bwbound=[bwboundaries(A1); bwboundaries(A2) ; bwboundaries(A3) ; bwboundaries(A4)];
			%bwbound=bwboundaries(A);

			importmaskx=cell(size(bwbound,1),1);
			importmasky=importmaskx;
			for i=1:size(bwbound,1)
				temp=bwbound{i,1};
				importmasky{i,1}=temp(1:10:end,1);
				temp=bwbound{i,1};
				importmaskx{i,1}=temp(1:10:end,2);
			end
			maskiererx=retr('maskiererx');
			maskierery=retr('maskierery');

			currentframe=2*floor(get(handles.fileselector, 'value'))-1 + 2*(j-1);
			if isempty(maskiererx)
				maskiererx=cell(i,currentframe+1);
				maskierery=maskiererx;
			end
			maskiererx(1:i,currentframe)=importmaskx;
			maskiererx(1:i,currentframe+1)=importmaskx;
			maskierery(1:i,currentframe)=importmasky;
			maskierery(1:i,currentframe+1)=importmasky;


			put('maskiererx' ,maskiererx);
			put('maskierery' ,maskierery);
			if j >= AnzahlMasks
				set(handles.mask_hint, 'String', 'Mask active', 'backgroundcolor', [0.5 1 0.5]);
				dispMASK(0.5)
			end


		end
		set (handles.external_mask_progress, 'string', 'External mask(s) loaded.');

		%maskiererxundy abschneiden wenn l채nger als anderes zeugs
		if size(maskiererx,2)>size(filepath,1) %user loaded more masks than there are frames
			maskiererx (:,size(filepath,1)+1:end) = [];
			maskierery  (:,size(filepath,1)+1:end) = [];
			put('maskiererx' ,maskiererx);
			put('maskierery' ,maskierery);
		end
	end
end

function preview_preprocess_Callback(~, ~, ~)
filepath=retr('filepath');
if size(filepath,1) >1 || retr('video_selection_done') == 1
	handles=gethand;
	toggler=retr('toggler');
	filepath=retr('filepath');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	generate_BG_img
	[img,~]=get_img(selected);
	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	Autolimit_Callback
	minintens=str2double(get(handles.minintens, 'string'));
	maxintens=str2double(get(handles.maxintens, 'string'));

	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=retr('roirect');
	if size (roirect,2)<4
		roirect=[1,1,size(img,2)-1,size(img,1)-1];
	end
	out = PIVlab_preproc (img,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
	image(out, 'parent',gca, 'cdatamapping', 'scaled');
	colormap('gray');
	axis image;
	set(gca,'ytick',[]);
	set(gca,'xtick',[]);
	roirect=retr('roirect');
	if size(roirect,2)>1
		dispROI
	end
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	maskiererx=retr('maskiererx');
	if size(maskiererx,2)>=currentframe
		ximask=maskiererx{currentframe};
		if size(ximask,1)>1
			dispMASK(1-str2num(get(handles.masktransp,'String'))/100)
		end
	end
end

function export_preprocess_Callback(~, ~, ~)
filepath=retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	sessionpath=retr('sessionpath');
	if isempty(sessionpath)
		sessionpath=retr('pathname');
	end

	preview_preprocess_Callback
	preprocessed_img=findobj(gca,'type','image');
	preprocessed_img=(preprocessed_img.CData);
	toggler=retr('toggler');
	if toggler==0
		img_idx='_A';
	else
		img_idx='_B';
	end
	[FileName,PathName] = uiputfile('*.tif','Save preprocessed image as...',fullfile(sessionpath,['PIVlab_preproc' img_idx '.tif']));
	if isequal(FileName,0) | isequal(PathName,0)
	else
		imwrite(preprocessed_img,fullfile(PathName,FileName),'Compression','none');
	end
end

function fftmulti_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value') ==1
	set(handles.dcc,'value',0)
	set(handles.ensemble,'value',0)
	set(handles.uipanel42,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')
	if get(handles.checkbox26,'value') ~=0
		set(handles.repeat_last,'Enable','on')
		set(handles.edit52x,'Enable','on')
	end
else
	set(handles.fftmulti,'value',1)
end
dispinterrog

function ensemble_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value') ==1
	set(handles.dcc,'value',0)
	set(handles.fftmulti,'value',0)
	set(handles.uipanel42,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
	%set(handles.AnalyzeAll,'visible','off')
	set(handles.AnalyzeSingle,'visible','off')
	set(handles.Settings_Apply_current,'visible','off')
else
	set(handles.ensemble,'value',1)
end
dispinterrog

function checkbox27_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value') == 0
	set(handles.edit51,'enable','off')
	set(handles.edit52,'enable','off')
	set(handles.checkbox28,'value',0)
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
else
	set(handles.edit50,'enable','on')
	set(handles.edit51,'enable','on')
	set(handles.checkbox26,'value',1)
	set(handles.repeat_last,'Enable','on')
	set(handles.edit52x,'Enable','on')
end
if get(handles.checkbox26,'value')==0
	set(handles.checkbox27,'value',0)
	set(handles.edit51,'enable','off')
end
dispinterrog

function checkbox28_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value') == 0
	set(handles.edit52,'enable','off')
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
else
	set(handles.edit52,'enable','on')
	set(handles.edit50,'enable','on')
	set(handles.edit51,'enable','on')
	set(handles.checkbox26,'value',1)
	set(handles.checkbox27,'value',1)
	set(handles.repeat_last,'Enable','on')
	set(handles.edit52x,'Enable','on')
end
if get(handles.checkbox27,'value')==0
	set(handles.checkbox28,'value',0)
	set(handles.edit52,'enable','off')
end
dispinterrog

function dispinterrog
handles=gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=retr('filepath');
if numel(filepath)>1
	[image_dummy,~]=get_img(selected);
	size_img(1)=size(image_dummy,2)/2;
	size_img(2)=size(image_dummy,1)/2;
	step=str2double(get(handles.step,'string'));
	delete(findobj(gca,'Type','hggroup')); %=vectors and scatter markers
	delete(findobj(gca,'tag','intareadispl'));
	centre(1)= size_img(2); %y
	centre(2)= size_img(1); %x

	intarea1=str2double(get(handles.intarea,'string'))/2;
	x1=[centre(2)-intarea1 centre(2)+intarea1 centre(2)+intarea1 centre(2)-intarea1 centre(2)-intarea1];
	y1=[centre(1)-intarea1 centre(1)-intarea1 centre(1)+intarea1 centre(1)+intarea1 centre(1)-intarea1];
	hold on;
	plot(x1,y1,'c-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
	if get(handles.fftmulti,'value')==1 || get(handles.ensemble,'value')==1
		text(x1(1),y1(1), ['pass 1'],'color','c','fontsize',8,'tag','intareadispl','HorizontalAlignment','right','verticalalignment','bottom')
		if get(handles.checkbox26,'value')==1
			intarea2=str2double(get(handles.edit50,'string'))/2;
			x2=[centre(2)-intarea2 centre(2)+intarea2 centre(2)+intarea2 centre(2)-intarea2 centre(2)-intarea2];
			y2=[centre(1)-intarea2 centre(1)-intarea2 centre(1)+intarea2 centre(1)+intarea2 centre(1)-intarea2];
			plot(x2,y2,'y-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x2(2),y2(1), ['pass 2'],'color','y','fontsize',8,'tag','intareadispl','HorizontalAlignment','left','verticalalignment','bottom')
		end
		if get(handles.checkbox27,'value')==1
			intarea3=str2double(get(handles.edit51,'string'))/2;
			x3=[centre(2)-intarea3 centre(2)+intarea3 centre(2)+intarea3 centre(2)-intarea3 centre(2)-intarea3];
			y3=[centre(1)-intarea3 centre(1)-intarea3 centre(1)+intarea3 centre(1)+intarea3 centre(1)-intarea3];
			plot(x3,y3,'g-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x3(2),y3(3), ['pass 3'],'color','g','fontsize',8,'tag','intareadispl','HorizontalAlignment','left','verticalalignment','top')
		end
		if get(handles.checkbox28,'value')==1
			intarea4=str2double(get(handles.edit52,'string'))/2;
			x4=[centre(2)-intarea4 centre(2)+intarea4 centre(2)+intarea4 centre(2)-intarea4 centre(2)-intarea4];
			y4=[centre(1)-intarea4 centre(1)-intarea4 centre(1)+intarea4 centre(1)+intarea4 centre(1)-intarea4];
			plot(x4,y4,'r-', 'linewidth', 1, 'linestyle', ':','tag','intareadispl');
			text(x4(1),y4(3), ['pass 4'],'color','r','fontsize',8,'tag','intareadispl','HorizontalAlignment','right','verticalalignment','top')
		end
	end
	hold off;
	%check if step is ok
	if step/(intarea1*2) < 0.25
		text (centre(2),centre(1)/2,'Warning: Step of pass 1 is very small.','color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k')
	end
	%check if int area sizes are decreasing
	sizeerror=0;
	try
		if intarea4 > intarea3 || intarea4 > intarea2 || intarea4 > intarea1
			sizeerror=1;
		end
	catch
	end
	try
		if intarea3 > intarea2 || intarea3 > intarea1
			sizeerror=1;
		end
	catch
	end
	try
		if intarea2 > intarea1
			sizeerror=1;
		end
	catch
	end
	if sizeerror == 1
		text (centre(2),centre(1)*4/3,['Warning: Interrogation area sizes should be' sprintf('\n') 'gradually decreasing from pass 1 to pass 4.'],'color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k') %#ok<*SPRINTFN>
		sizeerror=0;
	end

	roirect=retr('roirect');

	if isempty(roirect) == 0 %roi eingeschaltet
		roirect=retr('roirect');
		minisize=min([roirect(3) roirect(4)]);
	else
		minisize=min([size_img(1) size_img(2)]);
	end

	if intarea1*2 *2 > minisize
		text (centre(2),centre(1)*5/3,['Warning: Interrogation area of pass 1 is most likely too big.'],'color','r','tag','intareadispl','HorizontalAlignment','center','verticalalignment','top','Fontsize',10,'Backgroundcolor','k')
	end

end

function countparticles(~, ~, ~)
handles=gethand;

selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=retr('filepath');
ok=checksettings;
if ok==1
	uiwait(msgbox({'Please select a rectangle';'that encloses the area that';'you want to analyze.'},'Suggestion for PIV settings','modal'));
	roirect=retr('roirect');
	old_roirect=roirect;
	roirect=[];
	put ('roirect',roirect);
	roi_select_Callback()
	roirect=retr('roirect');
	if numel(roirect) == 4
		%roirect(1,3)~=0 && roirect(1,4)~=0
		if roirect(3) < 50 || roirect(4)< 50
			uiwait(msgbox({'The rectangle you selected is too small.';'Please select a larger rectangle.';'(should be larger than 50 x 50 pixels)'},'Suggestion for PIV settings','modal'));
		else
			text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
			drawnow
			[A,~] = get_img(selected);
			[B,~] = get_img(selected+1);
			A=A(roirect(2):roirect(2)+roirect(4),roirect(1):roirect(1)+roirect(3));
			B=B(roirect(2):roirect(2)+roirect(4),roirect(1):roirect(1)+roirect(3));
			clahe=get(handles.clahe_enable,'value');
			highp=get(handles.enable_highpass,'value');
			intenscap=get(handles.enable_intenscap, 'value');
			clahesize=str2double(get(handles.clahe_size, 'string'))*2; % faster...
			highpsize=str2double(get(handles.highp_size, 'string'));
			wienerwurst=get(handles.wienerwurst, 'value');
			wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
			do_correlation_matrices=retr('do_correlation_matrices');
			roirect=retr('roirect');
			if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				stretcher = stretchlim(A);
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
			A = PIVlab_preproc (A,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
			if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				stretcher = stretchlim(B);
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
			B = PIVlab_preproc (B,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

			interrogationarea=round(min(size(A))/4);
			if interrogationarea > 64
				interrogationarea = 64;
			end
			step=round(interrogationarea/4);
			if step < 6
				step=6;
			end
			[x, y, u, v, typevector,~,correlation_matrices] = piv_FFTmulti (A,B,interrogationarea, step,1,[],[],1,32,16,16,'*linear',1,0,0,do_correlation_matrices,0,0);
			u=medfilt2(u);
			v=medfilt2(v);
			u=inpaint_nans(u,4);
			v=inpaint_nans(v,4);
			maxvel=max(max(sqrt(u.^2+v.^2)));
			%minimum size recommendation based on displacement
			recommended1=ceil(4*maxvel/2)*2;
			A(A<=80)=0;
			A(A>80)=255;
			B(B<=80)=0;
			B(B>80)=255;
			[spots,numA]=bwlabeln(A,8);
			[spots,numB]=bwlabeln(B,8);
			XA=((numA+numB)/2)/(size(A,1)*size(A,2));
			YA=8/XA;
			%minimum size recommendation based on particle density
			recommended2=round(sqrt(YA)/2)*2; % 8 peaks are in Z*Z area
			%minimum size recommendation based on experience with "normal PIV images"
			recommended3= 32; %relativ allgemeing체ltiger Erfahrungswert
			recommendation = median([recommended1 recommended2 recommended3]);
			%[recommended1 recommended2 recommended3]
			uiwait(msgbox({'These are the recommendations for the size of the final interrogation area:';[''];['Based on the displacements: ' num2str(recommended1) ' pixels'];['Based on the particle count: ' num2str(recommended2) ' pixels'];['Based on practical experience: ' num2str(recommended3) ' pixels'];[''];'The settings are automatically updated with the median of the recommendation.'},'Suggestion for PIV settings','modal'));
			set(handles.fftmulti,'Value', 1)
			set(handles.ensemble,'Value', 1)

			set(handles.dcc,'Value', 0)
			set (handles.intarea, 'String', recommendation*2); %two times the minimum recommendation
			set (handles.step, 'String', recommendation);
			set(handles.checkbox26,'Value',1); %pass2
			set(handles.edit50,'String',recommendation); %pass2 size
			set(handles.checkbox27, 'Value',0); %pass3
			set(handles.edit51,'String',recommendation); %pass3 size
			set(handles.checkbox28, 'Value',0); %pass4
			set(handles.edit52,'String',recommendation); %pass4 size
			%set(handles.popupmenu16,'Value',1);
			set(handles.subpix,'value',1);
			%set(handles.Repeated_box,'value',0);
			set(handles.CorrQuality,'value',1)
			set(handles.mask_auto_box,'value',0);
			checkbox26_Callback(handles.checkbox26)
			checkbox27_Callback(handles.checkbox27)
			checkbox28_Callback(handles.checkbox28)
			edit50_Callback(handles.edit50)
			edit51_Callback(handles.edit51)
			edit52_Callback(handles.edit52)
			fftmulti_Callback(handles.fftmulti)
			step_Callback(handles.step)
			dispinterrog
			delete(findobj('tag','hint'));

		end
	end
	roirect=old_roirect;
	put ('roirect',roirect);
	if size(roirect,2)>1
		dispROI
	end
end

function intarea_Callback(~, ~, ~)
overlappercent
dispinterrog

function step_Callback(~, ~, ~)
overlappercent
dispinterrog

function DCC_and_DFT_analyze_all
ok=checksettings;
handles=gethand;
try
	warning off
	recycle('off');
	delete('cancel_piv');
	put('cancel',0);
	warning on
catch ME
	disp('There was an error deleting a temporary file.')
	disp('Please check if this solves your problem:')
	disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
	disp(ME)
end
if ok==1
	try
		if get(handles.update_display_checkbox,'Value')==1
			put('update_display',1);
		else
			put('update_display',0);
			text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
		end
	catch
		put('update_display',1)
	end
	filepath=retr('filepath');
	filename=retr('filename');
	toggler=retr('toggler');
	resultslist=cell(0); %clear old results
	toolsavailable(0);
	set (handles.cancelbutt, 'enable', 'on');
	ismean=retr('ismean');
	maskiererx=retr('maskiererx');
	maskierery=retr('maskierery');
	for i=size(ismean,1):-1:1 %remove averaged results
		if ismean(i,1)==1
			filepath(i*2,:)=[];
			filename(i*2,:)=[];

			filepath(i*2-1,:)=[];
			filename(i*2-1,:)=[];
			if size(maskiererx,2)>=i*2
				maskiererx(:,i*2)=[];
				maskierery(:,i*2)=[];
				maskiererx(:,i*2-1)=[];
				maskierery(:,i*2-1)=[];
			end
		end
	end
	put('filepath',filepath);
	put('filename',filename);
	put('ismean',[]);
	sliderrange

	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	%Autolimit_Callback
	autolimit=get(handles.Autolimit, 'value');
	minintens=str2double(get(handles.minintens, 'string'));
	maxintens=str2double(get(handles.maxintens, 'string'));
	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=retr('roirect');

	interrogationarea=str2double(get(handles.intarea, 'string'));
	step=str2double(get(handles.step, 'string'));
	subpixfinder=get(handles.subpix,'value');

	int2=str2num(get(handles.edit50,'string'));
	int3=str2num(get(handles.edit51,'string'));
	int4=str2num(get(handles.edit52,'string'));
	mask_auto = get(handles.mask_auto_box,'value');
	[imdeform, repeat, do_pad] = CorrQuality;


	if retr('video_selection_done')==0
		num_frames_to_process = size(filepath,1);
	else
		video_frame_selection=retr('video_frame_selection');
		num_frames_to_process = numel(video_frame_selection);
	end

	if retr('parallel')==1 && retr('video_selection_done') == 1
		disp('Parallel processing of video files not yet supported.')
	end
	if retr('parallel')==1 && retr('video_selection_done') == 0
		%parallel toolbox available
		%drawnow; %#ok<*NBRAK>
		set(handles.progress, 'string' , ['Frame progress: 100%']);
		set(handles.overall, 'string' , ['Total progress: 0%']);
		drawnow; %#ok<*NBRAK>
		maskiererx=retr('maskiererx');
		maskierery=retr('maskierery');
		do_correlation_matrices=retr('do_correlation_matrices');
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		mask=cell(0);
		xlist=cell(0);
		ylist=cell(0);
		ulist=cell(0);
		vlist=cell(0);
		typelist=cell(0);
		corrlist=cell(0);
		correlation_matrices_list=cell(0);
		for i=1:2:num_frames_to_process
			k=(i+1)/2;
			ximask={};
			yimask={};
			if size(maskiererx,2)>=i
				for j=1:size(maskiererx,1)
					if isempty(maskiererx{j,i})==0
						ximask{j,1}=maskiererx{j,i}; %#ok<*AGROW>
						yimask{j,1}=maskierery{j,i};
					else
						break
					end
				end
				if size(ximask,1)>0
					mask{k}=[ximask yimask];
				else
					mask{k}=[];
				end
			else
				mask{k}=[];
			end
			slicedfilepath1{k}=filepath{i};
			slicedfilepath2{k}=filepath{i+1};
		end
		%set(handles.totaltime, 'String','Time elapsed: N/A');
		%xpos=size(image1,2)/2-40;
		info=text(60,50, 'Analyzing ...','color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 16, 'BackgroundColor', 'k', 'tag', 'annoyingthing');
		drawnow;
		calc_time_start=tic;
		hbar = pivprogress(size(slicedfilepath1,2),handles.overall);
set(handles.totaltime,'String','');

		if get(handles.dcc,'Value')==1
			if get(handles.bg_subtract,'Value')==1
				bg_img_A = retr('bg_img_A');
				bg_img_B = retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
				bg_img_B=[];
				bg_sub=0;
			end
			parfor i=1:size(slicedfilepath1,2)
				if exist('cancel_piv','file')
					close(hbar);
					continue
				end

				[~,~,ext] = fileparts(slicedfilepath1{i});
				if strcmp(ext,'.b16')
					currentimage1=f_readB16(slicedfilepath1{i});
					currentimage2=f_readB16(slicedfilepath2{i});

				else
					currentimage1=imread(slicedfilepath1{i});
					currentimage2=imread(slicedfilepath2{i});
				end
				if bg_sub==1
					if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
						currentimage1 = rgb2gray(currentimage1)-bg_img_A;
						currentimage2 = rgb2gray(currentimage2)-bg_img_B;
					else
						currentimage1 = currentimage1-bg_img_A;
						currentimage2 = currentimage2-bg_img_B;
					end
				end

				%get and save the image size (assuming that every image of a session has the same size)

				currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
				currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
				image1=currentimage1;
				image2=currentimage2;


				minintenst=minintens;
				maxintenst=maxintens;
				if autolimit == 1
					if toggler==0
						if size(image1,3)>1
							stretcher = stretchlim(rgb2gray(image1));
						else
							stretcher = stretchlim(image1);
						end
					else
						if size(image2,3)>1
							stretcher = stretchlim(rgb2gray(image2));
						else
							stretcher = stretchlim(image2);
						end
					end
					minintenst=stretcher(1);
					maxintenst=stretcher(2);
				end
				image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask{i}, roirect); %#ok<PFTUSW> 
				xlist{i}=x;
				ylist{i}=y;
				ulist{i}=u;
				vlist{i}=v;
				typelist{i}=typevector;
				corrlist{i}=zeros(size(typevector)); %no correlation coefficient in DCC.
				correlation_matrices_list{i}=[];%no correlation matrix output for dcc
				hbar.iterate(1);
			end
		elseif get(handles.fftmulti,'Value')==1
			passes=1;
			if get(handles.checkbox26,'value')==1
				passes=2;
			end
			if get(handles.checkbox27,'value')==1
				passes=3;
			end
			if get(handles.checkbox28,'value')==1
				passes=4;
			end
			repeat_last_pass = get(handles.repeat_last,'Value');
			delta_diff_min = str2double(get(handles.edit52x,'String'));
			if get(handles.bg_subtract,'Value')==1
				bg_img_A = retr('bg_img_A');
				bg_img_B = retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
				bg_img_B=[];
				bg_sub=0;
			end
			parfor i=1:size(slicedfilepath1,2)
				%------------------------
				if exist('cancel_piv','file')
					close(hbar);
					continue
				end

				[~,~,ext] = fileparts(slicedfilepath1{i});
				if strcmp(ext,'.b16')
					currentimage1=f_readB16(slicedfilepath1{i});
					currentimage2=f_readB16(slicedfilepath2{i});

				else
					currentimage1=imread(slicedfilepath1{i});
					currentimage2=imread(slicedfilepath2{i});
				end
				if bg_sub==1
					if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
						currentimage1 = rgb2gray(currentimage1)-bg_img_A;
						currentimage2 = rgb2gray(currentimage2)-bg_img_B;
					else
						currentimage1 = currentimage1-bg_img_A;
						currentimage2 = currentimage2-bg_img_B;
					end
				end

				%get and save the image size (assuming that every image of a session has the same size)
				currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
				currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
				image1=currentimage1;
				image2=currentimage2;

				minintenst=minintens;
				maxintenst=maxintens;
				if autolimit == 1
					if toggler==0
						if size(image1,3)>1
							stretcher = stretchlim(rgb2gray(image1));
						else
							stretcher = stretchlim(image1);
						end
					else
						if size(image2,3)>1
							stretcher = stretchlim(rgb2gray(image2));
						else
							stretcher = stretchlim(image2);
						end
					end
					minintenst=stretcher(1);
					maxintenst=stretcher(2);
				end
				image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask{i}, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min); %#ok<PFTUSW>
				xlist{i}=x;
				ylist{i}=y;
				ulist{i}=u;
				vlist{i}=v;
				typelist{i}=typevector;
				corrlist{i}=correlation_map;
				correlation_matrices_list{i}=correlation_matrices;
				hbar.iterate(1);
			end
		end
		close(hbar);
		zeit=toc(calc_time_start);
		hrs=zeit/60^2;
		mins=(hrs-floor(hrs))*60;
		secs=(mins-floor(mins))*60;
		hrs=floor(hrs);
		mins=floor(mins);
		secs=floor(secs);
		if retr('cancel')==0 %dont output anything if cancelled
			for i=1:size(slicedfilepath1,2)
				resultslist{1,i}=xlist{i};
				resultslist{2,i}=ylist{i};
				resultslist{3,i}=ulist{i};
				resultslist{4,i}=vlist{i};
				resultslist{5,i}=typelist{i};
				resultslist{6,i}=[];
				resultslist{12,i}=corrlist{i};
			end
			put('resultslist',resultslist);
			put('subtr_u', 0);
			put('subtr_v', 0);
		end
		sliderdisp
		delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%']);
		set(handles.totaltime,'string', ['Time elapsed: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
	end
	%% serial (standard) calculation
	if retr('parallel')==0 ||  retr('video_selection_done') == 1
		set (handles.cancelbutt, 'enable', 'on');
		for i=1:2:num_frames_to_process
			if i==1
				tic
			end
			cancel=retr('cancel');
			if isempty(cancel)==1 || cancel ~=1
				image1 = get_img(i);
				image2 = get_img(i+1);
				%if size(image1,3)>1
				%	image1=uint8(mean(image1,3));
				%	image2=uint8(mean(image2,3));
				%disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
				%end
				set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow; %#ok<*NBRAK>
				clahe=get(handles.clahe_enable,'value');
				highp=get(handles.enable_highpass,'value');
				%clip=get(handles.enable_clip,'value');
				intenscap=get(handles.enable_intenscap, 'value');
				clahesize=str2double(get(handles.clahe_size, 'string'));
				highpsize=str2double(get(handles.highp_size, 'string'));
				wienerwurst=get(handles.wienerwurst, 'value');
				wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
				do_correlation_matrices=retr('do_correlation_matrices');
				Autolimit_Callback
				minintens=str2double(get(handles.minintens, 'string'));
				maxintens=str2double(get(handles.maxintens, 'string'));
				%clipthresh=str2double(get(handles.clip_thresh, 'string'));
				roirect=retr('roirect');
				if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
					if size(image1,3)>1
						stretcher = stretchlim(rgb2gray(image1));
					else
						stretcher = stretchlim(image1);
					end
					minintens = stretcher(1);
					maxintens = stretcher(2);
				end
				image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
					if size(image2,3)>1
						stretcher = stretchlim(rgb2gray(image2));
					else
						stretcher = stretchlim(image2);
					end
					minintens = stretcher(1);
					maxintens = stretcher(2);
				end
				image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				maskiererx=retr('maskiererx');
				maskierery=retr('maskierery');
				ximask={};
				yimask={};
				if size(maskiererx,2)>=i
					for j=1:size(maskiererx,1)
						if isempty(maskiererx{j,i})==0
							ximask{j,1}=maskiererx{j,i}; %#ok<*AGROW>
							yimask{j,1}=maskierery{j,i};
						else
							break
						end
					end
					if size(ximask,1)>0
						mask=[ximask yimask];
					else
						mask=[];
					end
				else
					mask=[];
				end
				interrogationarea=str2double(get(handles.intarea, 'string'));
				step=str2double(get(handles.step, 'string'));
				subpixfinder=get(handles.subpix,'value');
				if get(handles.dcc,'Value')==1
					[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask, roirect);
					correlation_matrices=[];%not available for DCC
				elseif get(handles.fftmulti,'Value')==1
					passes=1;
					if get(handles.checkbox26,'value')==1
						passes=2;
					end
					if get(handles.checkbox27,'value')==1
						passes=3;
					end
					if get(handles.checkbox28,'value')==1
						passes=4;
					end
					int2=str2num(get(handles.edit50,'string'));
					int3=str2num(get(handles.edit51,'string'));
					int4=str2num(get(handles.edit52,'string'));
					mask_auto = get(handles.mask_auto_box,'value');
					repeat_last_pass = get(handles.repeat_last,'Value');
					delta_diff_min = str2double(get(handles.edit52x,'String'));
					[imdeform, repeat, do_pad] = CorrQuality;
					[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
					%u=real(u)
					%v=real(v)
				end
				resultslist{1,(i+1)/2}=x;
				resultslist{2,(i+1)/2}=y;
				resultslist{3,(i+1)/2}=u;
				resultslist{4,(i+1)/2}=v;
				resultslist{5,(i+1)/2}=typevector;
				resultslist{6,(i+1)/2}=[];
				if get(handles.dcc,'Value')==1
					correlation_map=zeros(size(x));
				end
				correlation_matrices_list{(i+1)/2}=correlation_matrices;
				resultslist{12,(i+1)/2}=correlation_map;
				put('resultslist',resultslist);
				set(handles.fileselector, 'value', (i+1)/2);
				set(handles.progress, 'string' , ['Frame progress: 100%'])
				set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/num_frames_to_process*200) '%'])
				put('subtr_u', 0);
				put('subtr_v', 0);
				if retr('update_display')==0
				else
					sliderdisp
				end
				%xpos=size(image1,2)/2-40;
				%text(xpos,50, ['Analyzing... ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%' ],'color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 20, 'tag', 'annoyingthing')
				zeit=toc;
				done=(i+1)/2;
				tocome=(num_frames_to_process/2)-done;
				zeit=zeit/done*tocome;
				hrs=zeit/60^2;
				mins=(hrs-floor(hrs))*60;
				secs=(mins-floor(mins))*60;
				hrs=floor(hrs);
				mins=floor(mins);
				secs=floor(secs);
				set(handles.totaltime,'string', ['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
			end %cancel==0
		end

		delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
	end
	cancel=retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		try
			sound(audioread('finished.mp3'),44100);
		catch
		end
	end
	put('cancel',0);
	try
		warning off
		recycle('off');
		delete('cancel_piv')
		warning on
	catch ME
		disp('There was an error deleting a temporary file.')
		disp('Please check if this solves your problem:')
		disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
		disp(ME)
	end
	assignin('base','correlation_matrices',correlation_matrices_list);
end
toolsavailable(1);
sliderdisp

function ensemble_piv_analyze_all
handles=gethand;
try
	if get(handles.update_display_checkbox,'Value')==1
		put('update_display',1);
	else
		put('update_display',0);
		text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
	end
catch
	put('update_display',1)
end
put('cancel',0);
ok=checksettings;
if ok==1
	filepath=retr('filepath');
	filename=retr('filename');
	resultslist=cell(0); %clear old results
	toolsavailable(0);
	set (handles.cancelbutt, 'enable', 'on');
	ismean=retr('ismean');
	maskiererx=retr('maskiererx');
	maskierery=retr('maskierery');
	for i=size(ismean,1):-1:1 %remove averaged results
		if ismean(i,1)==1
			filepath(i*2,:)=[];
			filename(i*2,:)=[];
			filepath(i*2-1,:)=[];
			filename(i*2-1,:)=[];
			if size(maskiererx,2)>=i*2
				maskiererx(:,i*2)=[];
				maskierery(:,i*2)=[];
				maskiererx(:,i*2-1)=[];
				maskierery(:,i*2-1)=[];
			end
		end
	end
	put('filepath',filepath);
	put('filename',filename);
	put('ismean',[]);
	sliderrange
	%% get all parameters for preprocessing
	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	Autolimit_Callback
	minintens1=str2double(get(handles.minintens, 'string'));
	maxintens1=str2double(get(handles.maxintens, 'string'));
	minintens2=str2double(get(handles.minintens, 'string'));
	maxintens2=str2double(get(handles.maxintens, 'string'));
	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=retr('roirect');
	autolimit = get(handles.Autolimit, 'value');
	maskiererx=retr('maskiererx');
	maskierery=retr('maskierery');
	interrogationarea=str2double(get(handles.intarea, 'string'));
	step=str2double(get(handles.step, 'string'));
	subpixfinder=get(handles.subpix,'value');
	passes=1;
	if get(handles.checkbox26,'value')==1
		passes=2;
	end
	if get(handles.checkbox27,'value')==1
		passes=3;
	end
	if get(handles.checkbox28,'value')==1
		passes=4;
	end
	int2=str2num(get(handles.edit50,'string'));
	int3=str2num(get(handles.edit51,'string'));
	int4=str2num(get(handles.edit52,'string'));
	mask_auto = get(handles.mask_auto_box,'value');
	[imdeform, repeat, do_pad] = CorrQuality;
	bg_img_A = retr('bg_img_A'); %contains bg image, or is empty array
	bg_img_B = retr('bg_img_B');
	%�bergeben: Video frame selection
	if retr('video_selection_done') == 0
		video_frame_selection=[];
		[x, y, u, v, typevector,correlation_map] = piv_FFTensemble (autolimit, filepath,video_frame_selection,bg_img_A,bg_img_B,clahe,highp,intenscap,clahesize,highpsize,wienerwurst,wienerwurstsize,roirect,maskiererx,maskierery,interrogationarea,step,subpixfinder,passes,int2,int3,int4,mask_auto,imdeform,repeat,do_pad);
	else
		video_frame_selection=retr('video_frame_selection');
		video_reader_object = retr('video_reader_object');
		[x, y, u, v, typevector,correlation_map] = piv_FFTensemble (autolimit, video_reader_object ,video_frame_selection,bg_img_A,bg_img_B,clahe,highp,intenscap,clahesize,highpsize,wienerwurst,wienerwurstsize,roirect,maskiererx,maskierery,interrogationarea,step,subpixfinder,passes,int2,int3,int4,mask_auto,imdeform,repeat,do_pad);
	end

	cancel = retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		%Fill all frames with the same result
		%{
        for filler=1:size(filepath,1)/2
            resultslist{1,filler}=x;
            resultslist{2,filler}=y;
            resultslist{3,filler}=u;
            resultslist{4,filler}=v;
            resultslist{5,filler}=typevector;
            resultslist{6,filler}=[];
        end
		%}

		%fill only first frame with results
		resultslist{1,1}=x;
		resultslist{2,1}=y;
		resultslist{3,1}=u;
		resultslist{4,1}=v;
		resultslist{5,1}=typevector;
		resultslist{6,1}=[];
		resultslist{12,1}=correlation_map;

		put('resultslist',resultslist);
		set(handles.fileselector, 'value', 1);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		%set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%'])
		put('subtr_u', 0);
		put('subtr_v', 0);
		sliderdisp
		%delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
		try
			sound(audioread('finished.mp3'),44100);
		catch
		end
	else %user pressed cancel, no results
		if verLessThan('matlab','8.4')
			delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
		else
			delete (findobj(getappdata(0,'hgui'),'type', 'quiver'))
		end
		%delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String','Time left: N/A');
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		sliderdisp
	end

	put('cancel',0);
	toolsavailable(1);
end


function AnalyzeAll_Callback(~, ~, ~)
handles=gethand;
if get(handles.ensemble,'value')==0
	DCC_and_DFT_analyze_all
else
	ensemble_piv_analyze_all
end

function [imdeform, repeat, do_pad]=CorrQuality(~,~)
handles=gethand;
quali = get(handles.CorrQuality,'Value');
if quali==1 % normal quality
	imdeform='*linear';
	repeat = 0;
	do_pad = 0;
end
if quali==2 % high quality
	imdeform='*spline';
	repeat = 0;
	do_pad = 1;
end
if quali==3 % ultra quality
	imdeform='*spline';
	repeat = 1;
	do_pad = 1;
end

function AnalyzeSingle_Callback(~, ~, ~)
handles=gethand;
ok=checksettings;
if ok==1
	resultslist=retr('resultslist');
	set(handles.progress, 'string' , ['Frame progress: 0%']);
	set(handles.Settings_Apply_current, 'string' , ['Please wait...']);
	toolsavailable(0);drawnow;
	handles=gethand;
	filepath=retr('filepath');
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	ismean=retr('ismean');
	if size(ismean,1)>=(selected+1)/2
		if ismean((selected+1)/2,1) ==1
			currentwasmean=1;
		else
			currentwasmean=0;
		end
	else
		currentwasmean=0;
	end
	if currentwasmean==0
		tic;
		[image1,~]=get_img(selected);
		[image2,~]=get_img(selected+1);
		%if size(image1,3)>1
		%image1=uint8(mean(image1,3));
		%image2=uint8(mean(image2,3));
		%disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
		%end
		clahe=get(handles.clahe_enable,'value');
		highp=get(handles.enable_highpass,'value');
		%clip=get(handles.enable_clip,'value');
		intenscap=get(handles.enable_intenscap, 'value');
		clahesize=str2double(get(handles.clahe_size, 'string'));
		highpsize=str2double(get(handles.highp_size, 'string'));
		wienerwurst=get(handles.wienerwurst, 'value');
		wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
		Autolimit_Callback
		minintens=str2double(get(handles.minintens, 'string'));
		maxintens=str2double(get(handles.maxintens, 'string'));
		%clipthresh=str2double(get(handles.clip_thresh, 'string'));
		roirect=retr('roirect');
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image1,3)>1
				stretcher = stretchlim(rgb2gray(image1));
			else
				stretcher = stretchlim(image1);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end
		image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image2,3)>1
				stretcher = stretchlim(rgb2gray(image2));
			else
				stretcher = stretchlim(image2);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end

		image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
		maskiererx=retr('maskiererx');
		maskierery=retr('maskierery');
		ximask={};
		yimask={};
		if size(maskiererx,2)>=selected
			for i=1:size(maskiererx,1)
				if isempty(maskiererx{i,selected})==0
					ximask{i,1}=maskiererx{i,selected};
					yimask{i,1}=maskierery{i,selected};
				else
					break
				end
			end
			if size(ximask,1)>0
				mask=[ximask yimask];
			else
				mask=[];
			end
		else
			mask=[];
		end
		interrogationarea=str2double(get(handles.intarea, 'string'));
		step=str2double(get(handles.step, 'string'));
		subpixfinder=get(handles.subpix,'value');
		do_correlation_matrices=retr('do_correlation_matrices');
		if get(handles.dcc,'Value')==1
			[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask, roirect);
			correlation_map=zeros(size(u)); %nor correlation map available with DCC
			correlation_matrices=[];
		elseif get(handles.fftmulti,'Value')==1 || get(handles.ensemble,'Value')==1
			passes=1;
			if get(handles.checkbox26,'value')==1
				passes=2;
			end
			if get(handles.checkbox27,'value')==1
				passes=3;
			end
			if get(handles.checkbox28,'value')==1
				passes=4;
			end
			int2=str2num(get(handles.edit50,'string'));
			int3=str2num(get(handles.edit51,'string'));
			int4=str2num(get(handles.edit52,'string'));
			[imdeform, repeat, do_pad] = CorrQuality;
			mask_auto = get(handles.mask_auto_box,'value');
			repeat_last_pass = get(handles.repeat_last,'Value');
			delta_diff_min = str2double(get(handles.edit52x,'String'));
			if get(handles.fftmulti,'Value')==1
				try
				[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
				catch
					toolsavailable(1);
				end
			end

		end
		toolsavailable(1);
		resultslist{1,(selected+1)/2}=x;
		resultslist{2,(selected+1)/2}=y;
		resultslist{3,(selected+1)/2}=u;
		resultslist{4,(selected+1)/2}=v;
		resultslist{5,(selected+1)/2}=typevector;
		resultslist{6,(selected+1)/2}=[];
		%clear previous interpolation results
		resultslist{7, (selected+1)/2} = [];
		resultslist{8, (selected+1)/2} = [];
		resultslist{9, (selected+1)/2} = [];
		resultslist{10, (selected+1)/2} = [];
		resultslist{11, (selected+1)/2} = [];
		resultslist{12,(selected+1)/2}=correlation_map;
		put('derived', [])
		put('resultslist',resultslist);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		set(handles.overall, 'string' , ['Total progress: 100%'])
		set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
		time1frame=toc;
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(time1frame*100)/100) ' s']);
		set(handles.messagetext, 'String','');
		put('subtr_u', 0);
		put('subtr_v', 0);
		assignin('base','correlation_matrices',correlation_matrices);
		sliderdisp
	end

end

function ok=checksettings
handles=gethand;
mess={};
filepath=retr('filepath');
if size(filepath,1) <2 && retr('video_selection_done') == 0
	mess{size(mess,2)+1}='No images were loaded';
end
if get(handles.clahe_enable, 'value')==1
	if isnan(str2double(get(handles.clahe_size, 'string')))
		mess{size(mess,2)+1}='CLAHE window size contains NaN';
	end
end
if get(handles.enable_highpass, 'value')==1
	if isnan(str2double(get(handles.highp_size, 'string')))
		mess{size(mess,2)+1}='Highpass filter size contains NaN';
	end
end
if get(handles.wienerwurst, 'value')==1
	if isnan(str2double(get(handles.wienerwurstsize, 'string')))
		mess{size(mess,2)+1}='Wiener2 filter size contains NaN';
	end
end
%if get(handles.enable_clip, 'value')==1
%    if isnan(str2double(get(handles.clip_thresh, 'string')))==1
%        mess{size(mess,2)+1}='Clipping threshold contains NaN';
%    end
%end
if isnan(str2double(get(handles.intarea, 'string')))
	mess{size(mess,2)+1}='Interrogation area size contains NaN';
end
if isnan(str2double(get(handles.step, 'string')))
	mess{size(mess,2)+1}='Step size contains NaN';
end
if size(mess,2)>0 %error somewhere
	msgbox(['Errors found:' mess],'Errors detected.','warn','modal')
	ok=0;
else
	ok=1;
end

function cancelbutt_Callback(~, ~, ~)
put('cancel',1);

fileID = fopen('cancel_piv','w');
fwrite(fileID,1);
fclose(fileID);

drawnow;
toolsavailable(1);

function load_settings_Callback(~, ~, ~)
[FileName,PathName] = uigetfile('*.mat','Load PIVlab settings','PIVlab_settings.mat');
if ~isequal(FileName,0)
	handles=gethand;
	try
		fileboxcontents=get (handles.filenamebox, 'string');
	catch
	end
	read_panel_width (FileName,PathName) %read panel settings, apply, rebuild UI
	destroyUI %needed to adapt panel width etc. to changed values in the settings file.
	generateUI
	read_settings (FileName,PathName) %When UI is set up, read settings.
	switchui('multip01')
	try
		put('expected_image_size',[])
		handles=gethand;
		sliderrange
		set (handles.filenamebox, 'string', fileboxcontents);
		sliderdisp
	catch
	end
end

function read_panel_width (FileName,PathName)
handles=gethand;
try
	load(fullfile(PathName,FileName)); %#ok<*LOAD>
	put ('panelwidth',panelwidth);
catch
end

function read_settings (FileName,PathName)
handles=gethand;
try
	load(fullfile(PathName,FileName));

	set(handles.clahe_enable,'value',clahe_enable);
	set(handles.clahe_size,'string',clahe_size);
	set(handles.enable_highpass,'value',enable_highpass);
	set(handles.highp_size,'string',highp_size);
	set(handles.wienerwurst,'value',wienerwurst);
	set(handles.wienerwurstsize,'string',wienerwurstsize);
	%set(handles.enable_clip,'value',enable_clip);
	%set(handles.clip_thresh,'string',clip_thresh);
	set(handles.enable_intenscap,'value',enable_intenscap);
	set(handles.intarea,'string',intarea);
	set(handles.step,'string',stepsize);
	set(handles.subpix,'value',subpix);  %popup
	set(handles.stdev_check,'value',stdev_check);
	set(handles.stdev_thresh,'string',stdev_thresh);
	set(handles.loc_median,'value',loc_median);
	set(handles.loc_med_thresh,'string',loc_med_thresh);
	%set(handles.epsilon,'string',epsilon);
	set(handles.interpol_missing,'value',interpol_missing);
	set(handles.vectorscale,'string',vectorscale);
	set(handles.colormap_choice,'value',colormap_choice); %popup
	set(handles.colormap_steps,'value',colormap_steps);
	set(handles.colormap_interpolation,'value',colormap_interpolation);
	set(handles.addfileinfo,'value',addfileinfo);
	set(handles.add_header,'value',add_header);
	set(handles.delimiter,'value',delimiter);%popup
	set(handles.img_not_mask,'value',img_not_mask);
	set(handles.autoscale_vec,'value',autoscale_vec);

	%set(handles.popupmenu16, 'value',imginterpol);
	set(handles.dcc, 'value',dccmark);
	set(handles.fftmulti, 'value',fftmark);
	set(handles.ensemble, 'value',ensemblemark);
	if fftmark==1 || ensemblemark == 1
		set (handles.uipanel42,'visible','on')
	else
		set (handles.uipanel42,'visible','off')
	end
	set(handles.checkbox26, 'value',pass2);
	set(handles.checkbox27, 'value',pass3);
	set(handles.checkbox28, 'value',pass4);
	if pass2 == 1
		set(handles.edit50, 'enable','on')
	else
		set(handles.edit50, 'enable','off')
	end
	if pass3 == 1
		set(handles.edit51, 'enable','on')
	else
		set(handles.edit51, 'enable','off')
	end
	if pass4 == 1
		set(handles.edit52, 'enable','on')
	else
		set(handles.edit52, 'enable','off')
	end

	set(handles.edit50, 'string',pass2val);
	set(handles.edit51, 'string',pass3val);
	set(handles.edit52, 'string',pass4val);
	set(handles.text126, 'string',step2);
	set(handles.text127, 'string',step3);
	set(handles.text128, 'string',step4);
	set(handles.holdstream, 'value',holdstream);
	set(handles.streamlamount, 'string',streamlamount);
	set(handles.streamlcolor, 'value',streamlcolor);
	set(handles.streamlwidth, 'value',streamlcolor);

	set(handles.realdist, 'string',realdist);
	set(handles.time_inp, 'string',time_inp);

	set(handles.nthvect, 'string',nthvect);
	set(handles.validr,'string',validr);
	set(handles.validg,'string',validg);
	set(handles.validb,'string',validb);
	set(handles.validdr,'string',validdr);
	set(handles.validdg,'string',validdg);
	set(handles.validdb,'string',validdb);
	set(handles.interpr,'string',interpr);
	set(handles.interpg,'string',interpg);
	set(handles.interpb,'string',interpb);
	if exist('offset_x_true','var') == 0
		offset_x_true=0;
	end
	if exist('offset_y_true','var') == 0
		offset_y_true=0;
	end

	try
		put('points_offsetx',points_offsetx);
		put('points_offsety',points_offsety);
		put('size_of_the_image',size_of_the_image);
		set(handles.x_axis_direction,'value',x_axis_direction);
		set(handles.y_axis_direction,'value',y_axis_direction);
	catch %ME
		%disp(ME)
	end
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	else
		set(handles.calidisp, 'string', ['1 px = ' num2str(round(calxy*100000)/100000) ' m' sprintf('\n') '1 px/frame = ' num2str(round(calu*100000)/100000) ' m/s' sprintf('\n') 'x offset: ' round(num2str(offset_x_true)*1000)/1000 ' m' sprintf('\n') 'y offset: ' round(num2str(offset_y_true)*1000)/1000 ' m'],  'backgroundcolor', [0.5 1 0.5]);
	end
	put('offset_x_true',offset_x_true);
	put('offset_y_true',offset_y_true);
	put('calxy',calxy);
	put('calu',calu);
	put('calv',calv);

catch
	disp('something went wrong during settings loading')
end
try
	%neu v1.5:
	%set(handles.Repeated_box,'value',Repeated_box);
	set(handles.mask_auto_box,'value',mask_auto_box);
	set(handles.Autolimit,'value',Autolimit);
	set(handles.minintens,'string',minintens);
	set(handles.maxintens,'string',maxintens);
	%neu v2.0
	set(handles.panelslider,'Value',panelwidth);
	put ('panelwidth',panelwidth);
	%neu v2.11
	set(handles.CorrQuality,'Value',CorrQuality_nr);
	%neu v2.37
	set(handles.enhance_images, 'Value',enhance_disp);
	%neu v2.42
	set(handles.interpol_missing2,'value',interpol_missing);
catch
	disp('Old version compatibility-');
end
try
	%neu v2.41
	set(handles.contrast_filter_thresh,'string',contrast_filter_thresh);
	set(handles.bright_filter_thresh,'string',bright_filter_thresh);
	set(handles.do_bright_filter,'Value',do_bright_filter);
	set(handles.do_contrast_filter,'Value',do_contrast_filter);
catch
	disp('img_filter_settings');
end
try
	%neu v2.54
	set(handles.do_corr2_filter,'value',do_corr2_filter);
	set(handles.corr_filter_thresh,'string',corr_filter_thresh);
	set(handles.notch_L_thresh,'String',notch_L_thresh);
	set(handles.notch_H_thresh,'string',notch_H_thresh);
	set(handles.notch_filter,'Value',notch_filter);
catch
	disp('corr filter / notch settings');
end
%neu v2.52
try
	set (handles.repeat_last,'Value',repeat_last);
	set(handles.edit52x,'String',repeat_last_thresh);
	repeat_last_Callback
catch
	disp('repeat_last didnt work')
end
put('expected_image_size',[])


function curr_settings_Callback(~, ~, ~)
handles=gethand;
clahe_enable=get(handles.clahe_enable,'value');
clahe_size=get(handles.clahe_size,'string');
enable_highpass=get(handles.enable_highpass,'value');
highp_size=get(handles.highp_size,'string');
wienerwurst=get(handles.wienerwurst,'value');
wienerwurstsize=get(handles.wienerwurstsize,'string');

%enable_clip=get(handles.enable_clip,'value');
%clip_thresh=get(handles.clip_thresh,'string');
enable_intenscap=get(handles.enable_intenscap,'value');
intarea=get(handles.intarea,'string');
stepsize=get(handles.step,'string');
subpix=get(handles.subpix,'value');  %popup
stdev_check=get(handles.stdev_check,'value');
stdev_thresh=get(handles.stdev_thresh,'string');
loc_median=get(handles.loc_median,'value');
loc_med_thresh=get(handles.loc_med_thresh,'string');
%epsilon=get(handles.epsilon,'string');
interpol_missing=get(handles.interpol_missing,'value');
vectorscale=get(handles.vectorscale,'string');
colormap_choice=get(handles.colormap_choice,'value'); %popup
colormap_steps=get(handles.colormap_steps,'value');
colormap_interpolation=get(handles.colormap_interpolation,'value');
addfileinfo=get(handles.addfileinfo,'value');
add_header=get(handles.add_header,'value');
delimiter=get(handles.delimiter,'value');%popup
img_not_mask=get(handles.img_not_mask,'value');
autoscale_vec=get(handles.autoscale_vec,'value');

%imginterpol=get(handles.popupmenu16, 'value');
dccmark=get(handles.dcc, 'value');
fftmark=get(handles.fftmulti, 'value');
ensemblemark=get(handles.ensemble, 'value');

pass2=get(handles.checkbox26, 'value');

pass3=get(handles.checkbox27, 'value');
pass4=get(handles.checkbox28, 'value');
pass2val=get(handles.edit50, 'string');
pass3val=get(handles.edit51, 'string');
pass4val=get(handles.edit52, 'string');
step2=get(handles.text126, 'string');
step3=get(handles.text127, 'string');
step4=get(handles.text128, 'string');
holdstream=get(handles.holdstream, 'value');
streamlamount=get(handles.streamlamount, 'string');
streamlcolor=get(handles.streamlcolor, 'value');
streamlcolor=get(handles.streamlwidth, 'value');
realdist=get(handles.realdist, 'string');
time_inp=get(handles.time_inp, 'string');

nthvect=get(handles.nthvect, 'string');
validr=get(handles.validr,'string');
validg=get(handles.validg,'string');
validb=get(handles.validb,'string');
validdr=get(handles.validdr,'string');
validdg=get(handles.validdg,'string');
validdb=get(handles.validdb,'string');
interpr=get(handles.interpr,'string');
interpg=get(handles.interpg,'string');
interpb=get(handles.interpb,'string');

calxy=retr('calxy');
calu=retr('calu');calv=retr('calv');

try
	%neu v1.5:
	%Repeated_box=get(handles.Repeated_box,'value');
	mask_auto_box=get(handles.mask_auto_box,'value');
	Autolimit=get(handles.Autolimit,'value');
	minintens=get(handles.minintens,'string');
	maxintens=get(handles.maxintens,'string');
	%neu v2.0:
	panelwidth=get(handles.panelslider,'Value');
	%neu v2.11
	CorrQuality_nr=get(handles.CorrQuality, 'value');
	%neu v2.37
	enhance_disp=get(handles.enhance_images, 'Value');
catch
	disp('Old version compatibility_');
end
try
	%v2.41
	x_axis_direction=get(handles.x_axis_direction,'value');
	y_axis_direction=get(handles.y_axis_direction,'value');
	size_of_the_image=retr('size_of_the_image');
	points_offsetx=retr('points_offsetx');
	points_offsety=retr('points_offsety');
	offset_x_true=retr('offset_x_true');
	offset_y_true=retr('offset_y_true');
	contrast_filter_thresh=get(handles.contrast_filter_thresh,'string');
	bright_filter_thresh=get(handles.bright_filter_thresh,'string');
	do_bright_filter=get(handles.do_bright_filter,'Value');
	do_contrast_filter=get(handles.do_contrast_filter,'Value');
catch
end
try
	%neu v2.54
	do_corr2_filter=get(handles.do_corr2_filter,'value');
	corr_filter_thresh=get(handles.corr_filter_thresh,'string');
	notch_L_thresh=get(handles.notch_L_thresh,'string');
	notch_H_thresh=get(handles.notch_H_thresh,'string');
	notch_filter=get(handles.notch_filter,'Value');
catch
	disp('corr filter / notch settings');
end
%neu v2.52
try
	repeat_last = get (handles.repeat_last,'Value');
	repeat_last_thresh = get(handles.edit52x,'String');
catch
	disp('repeat_last didnt work2')
end

if ispc==1
	[FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PIVlab_set_' getenv('USERNAME') '.mat']);
else
	try
		[FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PIVlab_set_' getenv('USER') '.mat']);
	catch
		[FileName,PathName] = uiputfile('*.mat','Save current settings as...','PIVlab_set.mat');
	end
end

clear handles hObject eventdata
if ~isequal(FileName,0)
	save('-v6', fullfile(PathName,FileName))
end

function vel_limit_Callback(~, ~, ~)
toolsavailable(0)
%if analys existing
resultslist=retr('resultslist');
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
	x=resultslist{1,(currentframe+1)/2};
	if size(x,1)>1
		if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
			index=1;
			foundfirst=0;
			for i = 1:size(resultslist,2)
				x=resultslist{1,i};
				if isempty(x)==0 && foundfirst==0
					firstsizex=size(x,1);
					secondsizex=size(x,2);
					foundfirst=1;
				end
				if size(x,1)>1 && size(x,1)==firstsizex && size(x,2) == secondsizex
					u(:,:,index)=resultslist{3,i};
					v(:,:,index)=resultslist{4,i};
					index=index+1;
				end
			end
		else
			y=resultslist{2,(currentframe+1)/2};
			u=resultslist{3,(currentframe+1)/2};
			v=resultslist{4,(currentframe+1)/2};
			typevector=resultslist{5,(currentframe+1)/2};
		end
		velrect=retr('velrect');
		calu=retr('calu');calv=retr('calv');
		if numel(velrect)>0
			%user already selected window before...
			%"filter u+v" and display scatterplot
			%problem: if user selects limits and then wants to refine vel
			%limits, all data is filterd out...
			umin=velrect(1);
			umax=velrect(3)+umin;
			vmin=velrect(2);
			vmax=velrect(4)+vmin;
			%check if all results are nan...
			u_backup=u;
			v_backup=v;
			u(u*calu<umin)=NaN;
			u(u*calu>umax)=NaN;
			v(u*calu<umin)=NaN;
			v(u*calu>umax)=NaN;
			v(v*calv<vmin)=NaN;
			v(v*calv>vmax)=NaN;
			u(v*calv<vmin)=NaN;
			u(v*calv>vmax)=NaN;
			if mean(mean(mean((isnan(u)))))>0.9 || mean(mean(mean((isnan(v)))))>0.9
				disp('User calibrated after selecting velocity limits. Discarding limits.')
				u=u_backup;
				v=v_backup;
			end
		end

		%problem: wenn nur ein frame analysiert, dann gibts probleme wenn display all frames in scatterplot an.
		datau=reshape(u*calu,1,size(u,1)*size(u,2)*size(u,3));
		datav=reshape(v*calv,1,size(v,1)*size(v,2)*size(v,3));
		if size(datau,2)>1000000 %more than one million value pairs are too slow in scatterplot.
			pos=unique(ceil(rand(1000000,1)*(size(datau,2)-1))); %select random entries...
			scatter(gca,datau(pos),datav(pos), 0.25,'k.'); %.. and plot them
			set(gca,'Yaxislocation','right','layer','top');
		else
			scatter(gca,datau,datav, 0.25,'k.');
			set(gca,'Yaxislocation','right','layer','top');
		end
		drawnow;%needed from R2021b on... Why...?
		oldsize=get(gca,'outerposition');
		newsize=[oldsize(1)+10 0.15 oldsize(3)*0.87 oldsize(4)*0.87];
		set(gca,'outerposition', newsize)
		%%{
		if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
			xlabel(gca, 'u velocity [px/frame]', 'fontsize', 12)
			ylabel(gca, 'v velocity [px/frame]', 'fontsize', 12)
		else
			xlabel(gca, 'u velocity [m/s]', 'fontsize', 12)
			ylabel(gca, 'v velocity [m/s]', 'fontsize', 12)
		end

		grid on
		%axis equal;
		set (gca, 'tickdir', 'in');
		%rangeu=nanmax(nanmax(nanmax(u*calu)))-nanmin(nanmin(nanmin(u*calu)));
		%rangev=nanmax(nanmax(nanmax(v*calv)))-nanmin(nanmin(nanmin(v*calv)));

		%set(gca,'xlim',[nanmin(nanmin(nanmin(u*caluv)))-rangeu*0.15 nanmax(nanmax(nanmax(u*caluv)))+rangeu*0.15])
		%set(gca,'ylim',[nanmin(nanmin(nanmin(v*caluv)))-rangev*0.15 nanmax(nanmax(nanmax(v*caluv)))+rangev*0.15])
		%=range of data +- 15%
		%%}
		velrect = getrect(gca);
		if velrect(1,3)~=0 && velrect(1,4)~=0
			put('velrect', velrect);
			update_velocity_limits_information
			sliderdisp
			delete(findobj(gca,'Type','text','color','r'));
			text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',10, 'fontweight','bold', 'BackgroundColor', 'k')
		else
			sliderdisp
			text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k')
		end
	end
end
toolsavailable(1)
MainWindow_ResizeFcn(gcf)

function update_velocity_limits_information
velrect=retr('velrect');
handles=gethand;
set (handles.vel_limit_active, 'String', 'Limit active', 'backgroundcolor', [0.5 1 0.5]);
umin=velrect(1);
umax=velrect(3)+umin;
vmin=velrect(2);
vmax=velrect(4)+vmin;
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [px/frame]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [px/frame]']);
else
	set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) ' [m/s]' sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ' [m/s]']);
end
set (handles.vel_limit, 'String', 'Refine velocity limits');


function apply_filter_current_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
put('derived', []); %clear derived parameters if user modifies source data
filtervectors(currentframe)
%put('manualdeletion',[]); %only valid one time, why...? Could work without this line.
sliderdisp;

function apply_filter_all_Callback(~, ~, ~)
resultslist=retr('resultslist');

if ~isempty(resultslist)
	handles=gethand;
	filepath=retr('filepath');
	toolsavailable(0)
	put('derived', []); %clear derived parameters if user modifies source data
	if retr('video_selection_done') == 0
		num_frames_to_process=floor(size(filepath,1)/2)+1;
	else
		video_frame_selection=retr('video_frame_selection');
		num_frames_to_process=floor(numel(video_frame_selection)/2)+1;
	end
	if retr('video_selection_done') == 1 || retr('parallel')==0 %if post-processing a video, parallelization cannot be used.
		for i=1:num_frames_to_process
			filtervectors(i)
			set (handles.apply_filter_all, 'string', ['Please wait... (' int2str((i-1)/num_frames_to_process*100) '%)']);
			drawnow;
		end
	else %not using a video file --> parallel processing possible
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		for i=1:2:size(filepath,1)%num_frames_to_process
			k=(i+1)/2;
			slicedfilepath1{k}=filepath{i};
			slicedfilepath2{k}=filepath{i+1};
		end
		if get(handles.bg_subtract,'Value')==1
			bg_img_A = retr('bg_img_A');
			bg_img_B = retr('bg_img_B');
			bg_sub=1;
		else
			bg_img_A=[];
			bg_img_B=[];
			bg_sub=0;
		end
		resultslist(10,:)={[]}; %remove smoothed results when user modifies original data
		resultslist(11,:)={[]};
		calu=retr('calu');calv=retr('calv');
		x=resultslist(1,:);
		y=resultslist(2,:);
		u=resultslist(3,:);
		v=resultslist(4,:);
		typevector=resultslist(5,:);
		typevector_original=resultslist(5,:);
		manualdeletion=retr('manualdeletion');

		if numel(manualdeletion)>0
			for i=1:size(u,2)
				if size(manualdeletion,2)>=i
					if isempty(manualdeletion{1,i}) ==0
						framemanualdeletion=manualdeletion{i};
						[u{i},v{i},typevector{i}]=manual_point_deletion(u{i},v{i},typevector{i},framemanualdeletion);
					end
				end
			end
		end
		velrect=retr('velrect');
		do_stdev_check = get(handles.stdev_check, 'value');
		stdthresh=str2double(get(handles.stdev_thresh, 'String'));
		do_local_median = get(handles.loc_median, 'value');
		neigh_thresh=str2double(get(handles.loc_med_thresh,'string'));
		%image-based filtering
		do_contrast_filter = get(handles.do_contrast_filter, 'value');
		do_bright_filter = get(handles.do_bright_filter, 'value');
		contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
		bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));
		interpol_missing= get(handles.interpol_missing, 'value');
		do_corr2_filter = get(handles.do_corr2_filter, 'value');
		corr_filter_thresh=str2double(get(handles.corr_filter_thresh,'String'));
		do_notch_filter = get(handles.notch_filter, 'value');
		notch_L_thresh=str2double(get(handles.notch_L_thresh,'String'));
		notch_H_thresh=str2double(get(handles.notch_H_thresh,'String'));

		hbar = pivprogress(size(slicedfilepath1,2),handles.apply_filter_all);
		if size(u,2)<num_frames_to_process-1 %If not all frames have been analyzed. Parfor loop crashes otherwise.
			u(num_frames_to_process-1)={[]};
			v(num_frames_to_process-1)={[]};
			x(num_frames_to_process-1)={[]};
			y(num_frames_to_process-1)={[]};
			typevector_original(num_frames_to_process-1)={[]};
			resultslist(1,num_frames_to_process-1)={[]};
		end
		parfor i=1:num_frames_to_process-1 %without parallel processing toolbox, this is just a normal for loop.
			if ~isempty(x(i))
				if do_contrast_filter == 1 || do_bright_filter == 1
					%% load images in a parfor loop
					[~,~,ext] = fileparts(slicedfilepath1{i});
					if strcmp(ext,'.b16')
						currentimage1=f_readB16(slicedfilepath1{i});
						currentimage2=f_readB16(slicedfilepath2{i});
					else
						currentimage1=imread(slicedfilepath1{i});
						currentimage2=imread(slicedfilepath2{i});
					end
					rawimageA=currentimage1;
					rawimageB=currentimage2;
					if bg_sub==1
						if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
							currentimage1 = rgb2gray(currentimage1)-bg_img_A;
							currentimage2 = rgb2gray(currentimage2)-bg_img_B;
						else
							currentimage1 = currentimage1-bg_img_A;
							currentimage2 = currentimage2-bg_img_B;
						end
					end
					currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
					currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
					A=currentimage1;
					B=currentimage2;
				else
					A=[];B=[];rawimageA=[];rawimageB=[];
				end
				corr2_value=resultslist{12,i};
				[u_new{i},v_new{i},typevector_new{i}]=filtervectors_all_parallel(x{i},y{i},u{i},v{i},typevector_original{i},calu,calv,velrect,do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter,contrast_filter_thresh,bright_filter_thresh,interpol_missing,A,B,rawimageA,rawimageB,do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh);
				hbar.iterate(1); %#ok<*PFBNS>
			end
		end
		close(hbar);

		%% 3D local median filtering test
		%{
		neigh_thresh=3;
		u=u_new;%resultslist(3,:);
		v=v_new;%resultslist(4,:);

		u_3d = cat(3,u{:});
		v_3d = cat(3,v{:});
	
		neigh_filt=medfilt3(u_3d);
		neigh_filt=fillmissing(neigh_filt,'linear');
		neigh_filt=abs(neigh_filt-u_3d);
		u_3d(neigh_filt>neigh_thresh)=nan;
		neigh_filt=medfilt3(v_3d);
		neigh_filt=fillmissing(neigh_filt,'linear');
		neigh_filt=abs(neigh_filt-v_3d);
		v_3d(neigh_filt>neigh_thresh)=nan;
	
		u = squeeze(num2cell(u_3d, [1,2]))';
		v = squeeze(num2cell(v_3d, [1,2]))';
		
		u_new=u;
		v_new=v;
		%}
		resultslist(7, :) = u_new;
		resultslist(8, :) = v_new;
		resultslist(9, :) = typevector_new;
		put('resultslist', resultslist);
	end
	set (handles.apply_filter_all, 'string', 'Apply to all frames');
	toolsavailable(1)
	sliderdisp;
end

function [u,v,typevector]=manual_point_deletion(u,v,typevector,framemanualdeletion)
manualdeletion=retr('manualdeletion');
if numel(manualdeletion)>0
	if numel(u)>0
		for i=1:size(framemanualdeletion,1)
			u(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
			v(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
		end
		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
	end
end


function restore_all_Callback(~, ~, ~)
%clears resultslist at 7,8,9
resultslist=retr('resultslist');

if size(resultslist,1) > 6
	resultslist(7:9,:)={[]};
	if size(resultslist,1) > 9
		resultslist(10:11,:)={[]};
	end
	put('resultslist', resultslist);
	sliderdisp
end
put('manualdeletion',[]);

function clear_vel_limit_Callback(~, ~, ~)
put('velrect', []);
handles=gethand;
set (handles.vel_limit_active, 'String', 'Limit inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set (handles.limittext, 'String', '');
set (handles.vel_limit, 'String', 'Select velocity limits');

function [u,v,typevector]=filtervectors_all_parallel(x,y,u,v,typevector_original,calu,calv,velrect,do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter,contrast_filter_thresh,bright_filter_thresh,interpol_missing,A,B,rawimageA,rawimageB,do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh)
typevector=typevector_original;
%run postprocessing function
if numel(velrect)>0
	valid_vel(1)=velrect(1); %umin
	valid_vel(2)=velrect(3)+velrect(1); %umax
	valid_vel(3)=velrect(2); %vmin
	valid_vel(4)=velrect(4)+velrect(2); %vmax
else
	valid_vel=[];
end
%do_contrast_filter=1
if ~isempty(x)
	if do_contrast_filter == 1 || do_bright_filter == 1
		[u,v,~] = PIVlab_image_filter (do_contrast_filter,do_bright_filter,x,y,u,v,contrast_filter_thresh,bright_filter_thresh,A,B,rawimageA,rawimageB);
	end
else
	u=[];v=[];
end

%correlation filter
if ~isempty(x)
	if do_corr2_filter == 1
		[u,v] = PIVlab_correlation_filter (u,v,corr_filter_thresh,corr2_value);
	end
else
	u=[];v=[];
end

%Notch velocity magnitude filter
if ~isempty(x)
	if do_notch_filter == 1
		[u,v] = PIVlab_notch_filter (u,v,calu,calv,notch_L_thresh,notch_H_thresh);
	end
end

if ~isempty(x)
	%vector-based filtering
	[u,v] = PIVlab_postproc (u,v,calu,calv,valid_vel, do_stdev_check,stdthresh, do_local_median,neigh_thresh);
else
	u=[];v=[];
end

typevector(isnan(u))=2;
typevector(isnan(v))=2;
typevector(typevector_original==0)=0; %restores typevector for mask
%interpolation using inpaint_NaNs
if interpol_missing==1
	u=inpaint_nans(u,4);
	v=inpaint_nans(v,4);
end

function filtervectors(frame)
%executes filters one after another, writes results to resultslist 7,8,9
handles=gethand;
resultslist=retr('resultslist');
resultslist{10,frame}=[]; %remove smoothed results when user modifies original data
resultslist{11,frame}=[];
if size(resultslist,2)>=frame
	calu=retr('calu');calv=retr('calv');
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	typevector_original=resultslist{5,frame};
	typevector=typevector_original;
	manualdeletion=retr('manualdeletion');
	if size(manualdeletion,2)>=frame
		if isempty(manualdeletion{1,frame}) ==0
			framemanualdeletion=manualdeletion{frame};
			[u,v,typevector]=manual_point_deletion(u,v,typevector,framemanualdeletion);
		end
	end
	if numel(u)>0
		velrect=retr('velrect');
		do_stdev_check = get(handles.stdev_check, 'value');
		stdthresh=str2double(get(handles.stdev_thresh, 'String'));
		do_local_median = get(handles.loc_median, 'value');
		%epsilon=str2double(get(handles.epsilon,'string'));
		neigh_thresh=str2double(get(handles.loc_med_thresh,'string'));



		%run postprocessing function
		if numel(velrect)>0
			valid_vel(1)=velrect(1); %umin
			valid_vel(2)=velrect(3)+velrect(1); %umax
			valid_vel(3)=velrect(2); %vmin
			valid_vel(4)=velrect(4)+velrect(2); %vmax
		else
			valid_vel=[];
		end

		%image-based filtering
		do_contrast_filter = get(handles.do_contrast_filter, 'value');
		do_bright_filter = get(handles.do_bright_filter, 'value');
		%do_contrast_filter=1
		if do_contrast_filter == 1 || do_bright_filter == 1
			selected=2*frame-1;
			x=resultslist{1,frame};
			y=resultslist{2,frame};
			contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
			bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));

			[A,rawimageA]=get_img(selected);
			[B,rawimageB]=get_img(selected+1);
			[u,v,~] = PIVlab_image_filter (do_contrast_filter,do_bright_filter,x,y,u,v,contrast_filter_thresh,bright_filter_thresh,A,B,rawimageA,rawimageB);
		end

		%correlation filter
		do_corr2_filter = get(handles.do_corr2_filter, 'value');
		if do_corr2_filter == 1
			corr_filter_thresh=str2double(get(handles.corr_filter_thresh,'String'));
			[u,v] = PIVlab_correlation_filter (u,v,corr_filter_thresh,resultslist{12,frame});
		end

		%Notch velocity magnitude filter
		do_notch_filter = get(handles.notch_filter, 'value');
		if do_notch_filter == 1
			[u,v] = PIVlab_notch_filter (u,v,calu,calv,str2double(get(handles.notch_L_thresh,'String')),str2double(get(handles.notch_H_thresh,'String')));
		end

		%vector-based filtering
		[u,v] = PIVlab_postproc (u,v,calu,calv,valid_vel, do_stdev_check,stdthresh, do_local_median,neigh_thresh);

		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
		typevector(typevector_original==0)=0; %restores typevector for mask
		%interpolation using inpaint_NaNs
		if get(handles.interpol_missing, 'value')==1
			u=inpaint_nans(u,4);
			v=inpaint_nans(v,4);
		end
		resultslist{7, frame} = u;
		resultslist{8, frame} = v;
		resultslist{9, frame} = typevector;
		put('resultslist', resultslist);
	end
end
%sliderdisp

function rejectsingle_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame %2nd dimesnion = frame
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	typevector_original=resultslist{5,frame};
	typevector=typevector_original;
	manualdeletion=retr('manualdeletion');
	framemanualdeletion=[];
	if numel(manualdeletion)>0
		if size(manualdeletion,2)>=frame
			if isempty(manualdeletion{1,frame}) ==0
				framemanualdeletion=manualdeletion{frame};
			end
		end
	end

	if numel(u)>0
		delete(findobj(gca,'tag','manualdot'));
		text(50,10,'Right mouse button exits manual validation mode.','color','g','fontsize',8, 'BackgroundColor', 'k', 'tag', 'hint')
		toolsavailable(0);
		button = 1;
		while button == 1
			[xposition,yposition,button] = ginput(1);
			if button~=1
				break
			end
			if numel (xposition)>0 %will be 0 if user presses enter
				xposition=round(xposition);
				yposition=round(yposition);
				%manualdeletion=zeros(size(xposition,1),2);
				findx=abs(x/xposition-1);
				[trash, imagex]=find(findx==min(min(findx)));
				findy=abs(y/yposition-1);
				[imagey, trash]=find(findy==min(min(findy)));
				idx=size(framemanualdeletion,1);
				%manualdeletion(idx+1,1)=imagey(1,1);
				%manualdeletion(idx+1,2)=imagex(1,1);

				framemanualdeletion(idx+1,1)=imagey(1,1);
				framemanualdeletion(idx+1,2)=imagex(1,1);

				hold on;
				plot (x(framemanualdeletion(idx+1,1),framemanualdeletion(idx+1,2)),y(framemanualdeletion(idx+1,1),framemanualdeletion(idx+1,2)), 'yo', 'markerfacecolor', 'r', 'markersize', 10,'tag','manualdot')
				hold off;
			end
		end
		manualdeletion{frame}=framemanualdeletion;
		put('manualdeletion',manualdeletion);

		delete(findobj(gca,'Type','text','color','r'));
		delete(findobj(gca,'tag','hint'));
		text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',10, 'fontweight','bold', 'BackgroundColor', 'k')
	end
end
toolsavailable(1);

function draw_line_Callback(~, ~, ~)
filepath=retr('filepath');
caliimg=retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	sliderdisp
end
if size(filepath,1) >1 || numel(caliimg)>0 || retr('video_selection_done') == 1
	handles=gethand;
	toolsavailable(0)
	delete(findobj('tag', 'caliline'))
	for i=1:2
		[xposition(i),yposition(i)] = ginput(1);
		if numel(caliimg)==0
			sliderdisp
		end
		hold on;
		plot (xposition,yposition,'ro-', 'markersize', 10,'LineWidth',3, 'tag', 'caliline');
		plot (xposition,yposition,'y+:', 'tag', 'caliline');
		hold off;
		for j=1:i
			text(xposition(j)+10,yposition(j)+10, ['x:' num2str(round(xposition(j)*10)/10) sprintf('\n') 'y:' num2str(round(yposition(j)*10)/10) ],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'caliline')
		end

		put('pointscali',[xposition' yposition']);
	end
	text(mean(xposition),mean(yposition), ['s = ' num2str(round((sqrt((xposition(1)-xposition(2))^2+(yposition(1)-yposition(2))^2))*100)/100) ' px'],'color','k','fontsize',7, 'BackgroundColor', 'r', 'tag', 'caliline','horizontalalignment','center')
	toolsavailable(1)
end

function calccali
put('derived',[]) %calibration makes previously derived params incorrect
handles=gethand;
pointscali=retr('pointscali');
if numel(pointscali)>0
	xposition=pointscali(:,1);
	yposition=pointscali(:,2);
	dist=sqrt((xposition(1)-xposition(2))^2 + (yposition(1)-yposition(2))^2);
	realdist=str2double(get(handles.realdist, 'String'));
	time=str2double(get(handles.time_inp, 'String'));
	calxy=(realdist/1000)/dist; %m/px %realdist=realdistance in m; dist=distance in px
	x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
	if x_axis_direction==1
		calu=calxy/(time/1000);
	else
		calu=-1*(calxy/(time/1000));
	end
	if y_axis_direction==1
		calv=calxy/(time/1000);
	else
		calv=-1*(calxy/(time/1000));
	end
	put('calu',calu);
	put('calv',calv);
	put('calxy',calxy);
	%set(handles.calidisp, 'string', ['1 px = ' num2str(round(calxy*100000)/100000) ' m' sprintf('\n') '1 px/frame = ' num2str(round(caluv*100000)/100000) ' m/s'],  'backgroundcolor', [0.5 1 0.5]);
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','on')
	points_offsetx=retr('points_offsetx');
	if numel(points_offsetx)>0
		offsetx = calculate_offset_axis('x',points_offsetx(1),points_offsetx(3));
		put('offset_x_true',offsetx);
	else %no offsets applied
		put('offset_x_true',0);
	end
	points_offsety=retr('points_offsety');
	if numel(points_offsety)>0
		offsety = calculate_offset_axis('y',points_offsety(2),points_offsety(3));
		put('offset_y_true',offsety);
	else %no offsets applied
		put('offset_y_true',0);
	end

	calxy=retr('calxy');
	calu=retr('calu');calv=retr('calv');
	offset_x_true = retr('offset_x_true');
	offset_y_true = retr('offset_y_true');
	set(handles.calidisp, 'string', ['1 px = ' num2str(round(calxy*100000)/100000) ' m' sprintf('\n') '1 px/frame = ' num2str(round(calu*100000)/100000) ' m/s' sprintf('\n') 'x offset: ' round(num2str(offset_x_true)*1000)/1000 ' m' sprintf('\n') 'y offset: ' round(num2str(offset_y_true)*1000)/1000 ' m'],  'backgroundcolor', [0.5 1 0.5]);
	%sliderdisp

else %no calibration performed yet
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
	set(handles.x_axis_direction,'value',1);
	set(handles.y_axis_direction,'value',1);
	msgbox ('You need to select a reference distance befor applying a calibration.','modal')
end


function clear_cali_Callback(~, ~, ~)
handles=gethand;
put('pointscali',[]);
put('points_offsetx',[]);
put('points_offsety',[]);
put('calu',1);
put('calv',1);
put('calxy',1);
put('offset_x_true',0);
put('offset_y_true',0);
put('caliimg', []);
filepath=retr('filepath');
set(handles.calidisp, 'string', ['inactive'], 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
delete(findobj('tag', 'caliline'));
set(handles.realdist, 'String','1');
set(handles.time_inp, 'String','1');
set(handles.x_axis_direction,'value',1);
set(handles.y_axis_direction,'value',1);
set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
if size(filepath,1) >1 || retr('video_selection_done') == 1
	sliderdisp
else
	displogo(0)
end

function optimize_calib_img_Callback(~,~,~) %optimize display of calibration image
caliimg=retr('caliimg');
if ~isempty(caliimg)
	display_cali_img (caliimg)
end

function display_cali_img (caliimg)
handles=gethand;
if get(handles.optimize_calib_img,'value')==1
	numberoftiles1=round(size(caliimg,1)/40);
	numberoftiles2=round(size(caliimg,2)/40);
	if numberoftiles1 < 2
		numberoftiles1=2;
	end
	if numberoftiles2 < 2
		numberoftiles2=2;
	end

	if size(caliimg,3) == 1
		caliimg=adapthisteq(imadjust(caliimg),'NumTiles',[numberoftiles1 numberoftiles2],'clipLimit',0.01);
	else
		try
			caliimg=adapthisteq(imadjust(rgb2gray(caliimg)),'NumTiles',[numberoftiles1 numberoftiles2],'clipLimit',0.01);
		catch
		end
	end
end
image(caliimg, 'parent',gca, 'cdatamapping', 'scaled');
colormap('gray');
axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])

function load_ext_img_Callback(~, ~, ~) %load extra calibration image
cali_folder=retr('cali_folder');
if isempty (cali_folder)==1
	if ispc==1
		cali_folder=[retr('pathname') '\'];
	else
		cali_folder=[retr('pathname') '/'];
	end
end
try
	[filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;*.tiff;*.b16;','Image Files (*.bmp,*.tif,*.jpg,*.tiff,*.b16)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp'; '*.tiff','tiff';'*.b16','b16'; },'Select calibration image',cali_folder);
catch
	[filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;*.tiff;*.b16;','Image Files (*.bmp,*.tif,*.jpg,*.tiff,*.b16)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp';  '*.tiff','tiff';'*.b16','b16';},'Select calibration image'); %unix/mac system may cause problems, can't be checked due to lack of unix/mac systems...
end
if ~isequal(filename,0)
	[~,~,ext] = fileparts(fullfile(pathname, filename));
	if strcmp(ext,'.b16')
		caliimg=f_readB16(fullfile(pathname, filename));
	else
		caliimg=imread(fullfile(pathname, filename));
	end
	put('caliimg', caliimg);
	put('cali_folder', pathname);
	display_cali_img (caliimg)
end

function write_workspace_Callback(~, ~, ~)
resultslist=retr('resultslist');
if isempty(resultslist)==0
	derived=retr('derived');
	calxy=retr('calxy');
	calu=retr('calu');calv=retr('calv');
	nrframes=size(resultslist,2);
	if size(resultslist,1)< 11
		resultslist{11,nrframes}=[]; %make sure resultslist has cells for all params
	end
	if isempty(derived)==0
		if size(derived,1)<= 10|| size(derived,2) < nrframes
			derived{11,nrframes}=[]; %make sure derived has cells for all params
		end
	else
		derived=cell(11,nrframes);
	end

	if calxy==1 && (calu==1 ||calu==-1)
		units='[px] respectively [px/frame]';
	else
		units='[m] respectively [m/s]';
	end
	%ohne alles: 6 hoch
	%mit filtern: 11 hoch
	%mit smoothed, 11 hoch und inhalt...
	u_original=cell(size(resultslist,2),1);
	v_original=u_original;
	x=u_original;
	y=u_original;
	typevector_original=u_original;
	u_filtered=u_original;
	v_filtered=v_original;
	typevector_filtered=u_original;
	u_smoothed=u_original;
	v_smoothed=u_original;
	vorticity=cell(size(derived,2),1);
	velocity_magnitude=vorticity;
	u_component=vorticity;
	v_component=vorticity;
	divergence=vorticity;
	vortex_locator=vorticity;
	shear_rate=vorticity;
	strain_rate=vorticity;
	LIC=vorticity;
	vectorangle=vorticity;
	correlation_map=vorticity;

	for i=1:nrframes
		[x_cal,y_cal]=calibrate_xy (resultslist{1,i},resultslist{2,i});
		x{i,1}=x_cal;
		y{i,1}=y_cal;
		u_original{i,1}=resultslist{3,i}*calu;
		v_original{i,1}=resultslist{4,i}*calv;
		typevector_original{i,1}=resultslist{5,i};
		u_filtered{i,1}=resultslist{7,i}*calu;
		v_filtered{i,1}=resultslist{8,i}*calv;
		typevector_filtered{i,1}=resultslist{9,i};
		u_smoothed{i,1}=resultslist{10,i}*calu;
		v_smoothed{i,1}=resultslist{11,i}*calv;

		vorticity{i,1}=derived{1,i};
		velocity_magnitude{i,1}=derived{2,i};
		u_component{i,1}=derived{3,i};
		v_component{i,1}=derived{4,i};
		divergence{i,1}=derived{5,i};
		vortex_locator{i,1}=derived{6,i};
		shear_rate{i,1}=derived{7,i};
		strain_rate{i,1}=derived{8,i};
		LIC{i,1}=derived{9,i};
		vectorangle{i,1}=derived{10,i};
		correlation_map{i,1}=derived{11,i};
	end

	assignin('base','x',x);
	assignin('base','y',y);
	assignin('base','u_original',u_original);
	assignin('base','v_original',v_original);
	assignin('base','typevector_original',typevector_original);
	assignin('base','u_filtered',u_filtered);
	assignin('base','v_filtered',v_filtered);
	assignin('base','typevector_filtered',typevector_filtered);
	assignin('base','u_smoothed',u_smoothed);
	assignin('base','v_smoothed',v_smoothed);

	assignin('base','vorticity',vorticity);

	assignin('base','velocity_magnitude',velocity_magnitude);
	assignin('base','u_component',u_component);
	assignin('base','v_component',v_component);
	assignin('base','divergence',divergence);
	assignin('base','vortex_locator',vortex_locator);
	assignin('base','shear_rate',shear_rate);
	assignin('base','strain_rate',strain_rate);
	assignin('base','LIC',LIC);
	assignin('base','vectorangle',vectorangle);
	assignin('base','correlation_map',correlation_map);

	assignin('base','calxy',calxy);
	assignin('base','calu',calu);
	assignin('base','calv',calv);
	assignin('base','units',units);


	clc
	disp('EXPLANATIONS:')
	disp(' ')
	disp('The first dimension of the variables is the frame number.')
	disp('The variables contain all data that was calculated in the PIVlab GUI.')
	disp('If some data was not calculated, the corresponding cell is empty.')
	disp('Typevector is 0 for masked vector, 1 for regular vector, 2 for filtered vector')
	disp(' ')
	disp('u_original and v_original are the unmodified velocities from the cross-correlation.')
	disp('u_filtered and v_filtered is the above incl. your data validation selection.')
	disp('u_smoothed and v_smoothed is the above incl. your smoothing selection.')
end

function mean_u_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
	if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
		u=resultslist{7,currentframe};
	else
		u=resultslist{3,currentframe};
	end
	calu=retr('calu');calv=retr('calv');
	set(handles.subtr_u, 'string', num2str(nanmean(u(:)*calu)));
else
	set(handles.subtr_u, 'string', '0');
end

function mean_v_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
	if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
		v=resultslist{8,currentframe};
	else
		v=resultslist{4,currentframe};
	end
	calu=retr('calu');calv=retr('calv');
	set(handles.subtr_v, 'string', num2str(nanmean(v(:)*calv)));
else
	set(handles.subtr_v, 'string', '0');
end

function derivative_calc (frame,deriv,update)
handles=gethand;
resultslist=retr('resultslist');
if size(resultslist,2)>=frame && numel(resultslist{1,frame})>0 %analysis exists
	filenames=retr('filenames');
	filepath=retr('filepath');
	derived=retr('derived');
	calu=retr('calu');calv=retr('calv');
	calxy=retr('calxy');
	[currentimage,~]=get_img(2*frame-1);
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	%subtrayct mean u
	subtr_u=str2double(get(handles.subtr_u, 'string'));
	if isnan(subtr_u)
		subtr_u=0;set(handles.subtr_u, 'string', '0');
	end
	subtr_v=str2double(get(handles.subtr_v, 'string'));
	if isnan(subtr_v)
		subtr_v=0;set(handles.subtr_v, 'string', '0');
	end
	if size(resultslist,1)>6 && numel(resultslist{7,frame})>0 %filtered exists
		u=resultslist{7,frame};
		v=resultslist{8,frame};
		typevector=resultslist{9,frame};
	else
		u=resultslist{3,frame};
		v=resultslist{4,frame};
		typevector=resultslist{5,frame};
	end
	if get(handles.interpol_missing,'value')==1
		if any(any(isnan(u))) || any(any(isnan(v)))
			if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
				drawnow;
				if retr('alreadydisplayed') == 1
				else
					msgbox('Your dataset contains NaNs. A vector interpolation will be performed automatically to interpolate missing vectors.', 'modal')
					uiwait
				end
				put('alreadydisplayed',1);
			end
			typevector_original=typevector;
			u(isnan(v))=NaN;
			v(isnan(u))=NaN;
			typevector(isnan(u))=2;
			typevector(typevector_original==0)=0;
			u=inpaint_nans(u,4);
			v=inpaint_nans(v,4);
			resultslist{7, frame} = u;
			resultslist{8, frame} = v;
			resultslist{9, frame} = typevector;

		end
	else
		if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.tecplot_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
			drawnow;
			if retr('alreadydisplayed') == 1
			else
				msgbox('Your dataset contains NaNs. Derived parameters will have a lot of missing data. Redo the vector validation with the option to interpolate missing data turned on.', 'modal')
				uiwait
			end
			put('alreadydisplayed',1);
		end
	end
	if get(handles.smooth, 'Value') == 1
		smoothfactor=floor(get(handles.smoothstr, 'Value'));
		try

			u = smoothn(u,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
			v = smoothn(v,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
			%clc
			%disp ('Using smoothn.m from Damien Garcia for data smoothing.')
			%disp (['Input smoothing parameter S for smoothn is: ' num2str(smoothfactor/10)])
			%disp ('see the documentation here: https://de.mathworks.com/matlabcentral/fileexchange/25634-smoothn')

		catch
			h=fspecial('gaussian',smoothfactor+2,(smoothfactor+2)/7);
			u=imfilter(u,h,'replicate');
			v=imfilter(v,h,'replicate');
			%clc
			%disp ('Using Gaussian kernel for data smoothing (your Matlab version is pretty old btw...).')
		end
		resultslist{10,frame}=u; %smoothed u
		resultslist{11,frame}=v; %smoothed v
	else
		%careful if more things are added, [] replaced by {[]}
		resultslist{10,frame}=[]; %remove smoothed u
		resultslist{11,frame}=[]; %remove smoothed v
	end

	%The direction of the coordinate system influences derivatives with gradients.
	x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top

	if x_axis_direction==1
		x_adjusted=x;
	else
		x_adjusted=fliplr(x);
	end

	if y_axis_direction==1
		y_adjusted=y;
	else
		y_adjusted=flipud(y);
	end


	if deriv==1 %vectors only
		%do nothing
		%disp('vectors')
	end
	if deriv==2 %vorticity
		[curlz,~]= curl(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		derived{1,frame}=-curlz;
		%disp('vorticity')
	end
	if deriv==3 %magnitude
		%andersrum, (u*caluv)-subtr_u
		derived{2,frame}=sqrt((u*calu-subtr_u).^2+(v*calv-subtr_v).^2);
		%disp('magnitude')
	end
	if deriv==4
		derived{3,frame}=u*calu-subtr_u;
		%disp('u')
	end
	if deriv==5
		derived{4,frame}=v*calv-subtr_v;
		%disp('v')
	end
	if deriv==6
		derived{5,frame}=divergence(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('divergence')
	end
	if deriv==7
		derived{6,frame}=dcev(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('dcev')
	end
	if deriv==8
		derived{7,frame}=shear(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('shear')
	end
	if deriv==9
		derived{8,frame}=strain(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('strain')
	end
	if deriv==10
		%{
        A=rescale_maps(LIC(v*caluv-subtr_v,u*caluv-subtr_u,frame),0);
        [curlz,cav]= curl(x*calxy,y*calxy,u*caluv,v*caluv);
        B= rescale_maps(curlz,0);
        
        C=B-min(min(B));
        C=C/max(max(C));
        RGB_B = ind2rgb(uint8(C*255),colormap('jet'));
        RGB_A = ind2rgb(uint8(A*255),colormap('gray'));
		%}
		%EDITED for williams visualization
		%Original:
		derived{9,frame}=LIC(v*calv-subtr_v,u*calu-subtr_u,frame);
		%disp('LIC')
	end
	if deriv==11
		try
			derived{10,frame}=atan2d(v*calv-subtr_v,u*calu-subtr_u);
		catch
			derived{10,frame}=v*0;
			beep;
			disp('This operation is not supported in your Matlab version. Sorry...');
		end
		%disp('angle')

	end
	if deriv==12
		derived{11,frame}=resultslist{12,frame}; % correlation map
		%disp('corrmap')
	end

	put('subtr_u', subtr_u);
	put('subtr_v', subtr_v);
	put('resultslist', resultslist);
	put ('derived',derived);
	if update==1
		put('displaywhat', deriv);
	end
end

function out=LIC(vx,vy,frame)
handles=gethand;
LICreso=round(get (handles.licres, 'value')*10)/10;
resultslist=retr('resultslist');
x=resultslist{1,frame};
y=resultslist{2,frame};
text(mean(x(1,:)/1.5),mean(y(:,1)), ['Please wait. LIC in progress...' sprintf('\n') 'If this message stays here for > 20s,' sprintf('\n') 'check MATLABs command window.' sprintf('\n') 'The function might need to be compiled first.'],'tag', 'waitplease', 'backgroundcolor', 'k', 'color', 'r','fontsize',10);
drawnow;
iterations=2;
set(gca,'units','pixels');
axessize=get(gca,'position');
set(gca,'units','points');
axessize=axessize(3:4);
%was ist gr철횩er, x oder y. dann entsprechend die x oder y gr철횩e der axes nehemn
xextend=size(vx,2);
yextend=size(vx,1);
if yextend<xextend
	scalefactor=axessize(1)/xextend;
else
	scalefactor=axessize(2)/yextend;
end

vx=imresize(vx,scalefactor*LICreso,'bicubic');
vy=imresize(vy,scalefactor*LICreso,'bicubic');


%{
this function is from:
Matlab VFV Toolbox 1.0
by courtesy of:
Nima Bigdely Shamlo (email: bigdelys-vfv@yahoo.com)
Computational Science Research Center
San Diego State University
%}

[width,height] = size(vx);
LIClength = round(max([width,height]) / 30);

kernel = ones(2 * LIClength);
LICImage = zeros(width, height);
intensity = ones(width, height); %#ok<*PREALL> % array containing vector intensity

% Making white noise
rand('state',0) % reset random generator to original state
noiseImage=rand(width,height);

% Making LIC Image
try
	for m = 1:iterations
		[LICImage, intensity,normvx,normvy] = fastLICFunction(vx,vy,noiseImage,kernel); % External Fast LIC implemennted in C language
		LICImage = imadjust(LICImage); % Adjust the value range
		noiseImage = LICImage;
	end
	out=LICImage;
	delete(findobj('tag', 'waitplease'));
catch
	h=errordlg(['Could not run the LIC tool.' sprintf('\n') 'Probably the tool is not compiled correctly.' sprintf('\n')  'Please execute the following command in Matlab:' sprintf('\n') sprintf('\n') '     mex fastLICFunction.c     ' sprintf('\n') sprintf('\n') 'Then try again.'],'Error','on');

	uiwait(h);
	out=zeros(size(vx));
end

function apply_deriv_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
deriv=get(handles.derivchoice, 'value');
derivative_calc (currentframe,deriv,1)
sliderdisp

function out=dcev(x,y,u,v)
dUdX=conv2(u,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
	conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dVdX=conv2(v,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
	conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dUdY=conv2(u,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
	conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
dVdY=conv2(v,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
	conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
res=(dUdX+dVdY)/2+sqrt(0.25*(dUdX+dVdY).^2+dUdY.*dVdX);
d=zeros(size(x));
d(2:end-1,2:end-1)=imag(res);
out=((d/(max(max(d))-(min(min(d)))))+abs(min(min(d))))*255;%normalize

function out=strain(x,y,u,v)
hx = x(1,:);
hy = y(:,1);
[px, junk] = gradient(u, hx, hy);
[junk, qy] = gradient(v, hx, hy); %#ok<*ASGLU>
out = px-qy;

function out=shear(x,y,u,v)
hx = x(1,:);
hy = y(:,1);
[junk, py] = gradient(u, hx, hy);
[qx, junk] = gradient(v, hx, hy);
out= qx+py;

function out=rescale_maps(in,isangle)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
handles=gethand;
filepath=retr('filepath');
currentframe=floor(get(handles.fileselector, 'value'));
[currentimage,~]=get_img(2*currentframe-1);
resultslist=retr('resultslist');
x=resultslist{1,currentframe};
y=resultslist{2,currentframe};
out=zeros(size(currentimage));
if size(out,3)>1
	out(:,:,2:end)=[];
end
out(:,:)=mean(in(:)); %Rand wird auf Mittelwert gesetzt
step=x(1,2)-x(1,1)+1;
minx=(min(min(x))-step/2);
maxx=(max(max(x))+step/2);
miny=(min(min(y))-step/2);
maxy=(max(max(y))+step/2);
width=maxx-minx;
height=maxy-miny;
if size(in,3)>1 %why would this actually happen...?
	in(:,:,2:end)=[];
end
if isangle == 1 %angle data is unsteady, needs to interpolated differently
	X_raw=cos(in/180*pi);
	Y_raw=sin(in/180*pi);
	%interpolate
	X_interp = imresize(X_raw,[height width],'bilinear');
	Y_interp = imresize(Y_raw,[height width],'bilinear');
	%reconvert to phase
	dispvar = angle(complex(X_interp,Y_interp))*180/pi;
else
	colormap_interpolation_list=get(handles.colormap_interpolation,'String');
	colormap_interpolation_value = get(handles.colormap_interpolation,'Value');
	dispvar = imresize(in,[height width],colormap_interpolation_list{colormap_interpolation_value}); %INTERPOLATION
end

if miny<1
	miny=1;
end
if minx<1
	minx=1;
end
try
	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar;
catch
	disp('temp workaround')
	A=out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1));
	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar(1:size(A,1),1:size(A,2));
end
maskiererx=retr('maskiererx');
if numel(maskiererx)>0
	if get(handles.img_not_mask, 'value')==1 && numel(maskiererx{currentframe*2-1})>0
		maskierery=retr('maskierery');
		ximask=maskiererx{currentframe*2-1};
		yimask=maskierery{currentframe*2-1};
		BW=poly2mask(ximask,yimask,size(out,1),size(out,2));
		max_img=double(max(max(currentimage)));
		max_map=max(max(out));
		currentimage=double(currentimage)/max_img*max_map;
		out(BW==1)=currentimage(BW==1);
	end
end

function out=rescale_maps_nan(in,isangle)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
%Rand ist nan statt Mittelwert des derivatives
handles=gethand;
filepath=retr('filepath');
currentframe=floor(get(handles.fileselector, 'value'));
[currentimage,~]=get_img(2*currentframe-1);
resultslist=retr('resultslist');
x=resultslist{1,currentframe};
y=resultslist{2,currentframe};
out=zeros(size(currentimage));
if size(out,3)>1
	out(:,:,2:end)=[];
end
out(:,:)=nan; %rand wird auf nan gesetzt
step=x(1,2)-x(1,1)+1;
minx=(min(min(x))-step/2);
maxx=(max(max(x))+step/2);
miny=(min(min(y))-step/2);
maxy=(max(max(y))+step/2);
width=maxx-minx;
height=maxy-miny;
if size(in,3)>1 %why would this actually happen...?
	in(:,:,2:end)=[];
end

if isangle == 1 %angle data is unsteady, needs to interpolated differently
	X_raw=cos(in/180*pi);
	Y_raw=sin(in/180*pi);
	%interpolate
	X_interp = imresize(X_raw,[height width],'bilinear');
	Y_interp = imresize(Y_raw,[height width],'bilinear');
	%reconvert to phase
	dispvar = angle(complex(X_interp,Y_interp))*180/pi;
else
	dispvar = imresize(in,[height width],'bilinear'); %INTERPOLATION
end

if miny<1
	miny=1;
end
if minx<1
	minx=1;
end
try
	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar;
catch
	disp('temp workaround')
	A=out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1));
	out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar(1:size(A,1),1:size(A,2));
end

maskiererx=retr('maskiererx');
if numel(maskiererx)>0
	try
		if numel(maskiererx{currentframe*2-1})>0
			maskierery=retr('maskierery');
			ximask=maskiererx{currentframe*2-1};
			yimask=maskierery{currentframe*2-1};
			BW=poly2mask(ximask,yimask,size(out,1),size(out,2));
			out(BW==1)=nan;
		end
	catch
	end
end

function apply_cali_Callback(~, ~, ~)
calccali

function apply_deriv_all_Callback(~, ~, ~)
handles=gethand;
filepath=retr('filepath');
toolsavailable(0)
for i=1:floor(size(filepath,1)/2)+1
	deriv=get(handles.derivchoice, 'value');
	derivative_calc(i,deriv,1)
	set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
	drawnow;
end
set (handles.apply_deriv_all, 'string', 'Apply to all frames');
toolsavailable(1)
sliderdisp

function autoscaler_Callback(~, ~, ~)
handles=gethand;
if get(handles.autoscaler, 'value')==1
	set (handles.mapscale_min, 'enable', 'off')
	set (handles.mapscale_max, 'enable', 'off')
else
	set (handles.mapscale_min, 'enable', 'on')
	set (handles.mapscale_max, 'enable', 'on')
end

function MainWindow_CloseRequestFcn(hObject, ~, ~)
handles=gethand;
batchModeActive=retr('batchModeActive');
if batchModeActive == 0
	button = questdlg('Do you want to quit PIVlab?','Quit?','Yes','Cancel','Cancel');
else
	button = 'Yes';
end
try
	toolsavailable(1)
catch
end
if strcmp(button,'Yes')==1

	try
		homedir=retr('homedir');
		pathname=retr('pathname');
		save('PIVlab_settings_default.mat','homedir','pathname','-append');
		last_selected_device = get(handles.ac_config, 'value');
		save('PIVlab_settings_default.mat','last_selected_device','-append');
	catch
	end
	try
		PIVlab_capture_lensctrl (1400,1400,0) %lens needs to be set to neutral otherwise re-enabling power might cause issues
	catch
	end
	try
		delete(hObject);
	catch
		delete(gcf);
	end
end

function vectorscale_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	sliderdisp
end

function masktransp_Callback(~, ~, ~)
handles=gethand;

try
	if isempty(str2num(get(handles.masktransp,'String'))) == 1
		set(handles.masktransp,'String','0');
	end
catch
	set(handles.masktransp,'String','0');
end
check_comma(handles.masktransp)
set(handles.masktransp,'String',round(str2num(get(handles.masktransp,'String'))))
if str2num(get(handles.masktransp,'String')) > 100
	set(handles.masktransp,'String','100');
end
if str2num(get(handles.masktransp,'String')) < 0
	set(handles.masktransp,'String','0');
end


function ascii_current_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.txt','Save vector data as...','PIVlab.txt'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0) %#ok<*OR2>
	else
		file_save(currentframe,FileName,PathName,1);
	end
end

function ascii_all_Callback(~, ~, ~)
handles=gethand;
filepath=retr('filepath');
resultslist=retr('resultslist');
[FileName,PathName] = uiputfile('*.txt','Save vector data as...','PIVlab.txt'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
	toolsavailable(0)
	for i=1:floor(size(filepath,1)/2)
		%if analysis exists
		if size(resultslist,2)>=i && numel(resultslist{1,i})>0
			[Dir, Name, Ext] = fileparts(FileName);
			FileName_nr=[Name sprintf('_%.4d', i) Ext];
			file_save(i,FileName_nr,PathName,1)
			set (handles.ascii_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
			drawnow;
		end
	end
	toolsavailable(1)
	set (handles.ascii_all, 'string', 'Export all frames');
end

function tecplot_current_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.dat','Save vector data as...','PIVlab.dat'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0) %#ok<*OR2>
	else
		file_save(currentframe,FileName,PathName,4);
	end
end

function tecplot_all_Callback(~, ~, ~)
handles=gethand;
filepath=retr('filepath');
resultslist=retr('resultslist');
[FileName,PathName] = uiputfile('*.dat','Save vector data as...','PIVlab.dat'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
	toolsavailable(0)
	for i=1:floor(size(filepath,1)/2)
		%if analysis exists
		if size(resultslist,2)>=i && numel(resultslist{1,i})>0
			[Dir, Name, Ext] = fileparts(FileName);
			FileName_nr=[Name sprintf('_%.4d', i) Ext];
			file_save(i,FileName_nr,PathName,4)
			set (handles.tecplot_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
			drawnow;
		end
	end
	toolsavailable(1)
	set (handles.tecplot_all, 'string', 'Export all frames');
end

function save_mat_current_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.mat','Save MATLAB file as...','PIVlab.mat'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0)
	else
		mat_file_save(currentframe,FileName,PathName,1); %option 1 = only currentframe
	end
end

function save_mat_all_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.mat','Save MATLAB file as...','PIVlab.mat'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0)
	else
		mat_file_save(currentframe,FileName,PathName,2); %option2 = all frames
	end
end

function set_points_Callback(~, ~, ~)
sliderdisp
hold on;
toolsavailable(0)
delete(findobj('tag', 'measure'));
n=0;
for i=1:2
	[xi,yi,but] = ginput(1);
	n=n+1;
	xposition(n)=xi;
	yposition(n)=yi;
	plot(xposition(n),yposition(n), 'r*','Color', [0.55,0.75,0.9], 'tag', 'measure');
	line(xposition,yposition,'LineWidth',3, 'Color', [0.05,0,0], 'tag', 'measure');
	line(xposition,yposition,'LineWidth',1, 'Color', [0.05,0.75,0.05], 'tag', 'measure');
end
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',3, 'Color', [0.05,0.0,0.0], 'tag', 'measure');
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',1, 'Color', [0.95,0.05,0.01], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',3, 'Color',[0.05,0.0,0], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',1, 'Color',[0.35,0.35,1], 'tag', 'measure');
hold off;
toolsavailable(1)
deltax=abs(xposition(1,1)-xposition(1,2));
deltay=abs(yposition(1,1)-yposition(1,2));
length=sqrt(deltax^2+deltay^2);
alpha=(180/pi) *(acos(deltax/length));
beta=(180/pi) *(asin(deltax/length));
handles=gethand;
calxy=retr('calxy');
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	set (handles.deltax, 'String', [num2str(deltax*calxy) ' [px]']);
	set (handles.deltay, 'String', [num2str(deltay*calxy) ' [px]']);
	set (handles.length, 'String', [num2str(length*calxy) ' [px]']);

else
	set (handles.deltax, 'String', [num2str(deltax*calxy) ' [m]']);
	set (handles.deltay, 'String', [num2str(deltay*calxy) ' [m]']);
	set (handles.length, 'String', [num2str(length*calxy) ' [m]']);
end
set (handles.alpha, 'String', num2str(alpha));
set (handles.beta, 'String', num2str(beta));

function draw_stuff_Callback(~, ~, ~)
sliderdisp;
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	toolsavailable(0);
	xposition=[];
	yposition=[];
	n = 0;
	but = 1;
	hold on;
	if get(handles.draw_what,'value')==1 %polyline
		while but == 1
			[xi,yi,but] = ginput(1);
			if but~=1
				break
			end
			delete(findobj('tag', 'extractpoint'))
			plot(xi,yi,'r+','tag','extractpoint')
			n = n+1;
			xposition(n)=xi;
			yposition(n)=yi;
			delete(findobj('tag', 'extractline'))
			delete(findobj('tag','areaint'));
			line(xposition,yposition,'LineWidth',3, 'Color', [0,0,0.95],'tag','extractline');
			line(xposition,yposition,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','extractline');
		end
	elseif get(handles.draw_what,'value')==2 %circle
		for i=1:2
			[xi,yi,but] = ginput(1);
			if i==1;delete(findobj('tag', 'extractpoint'));end
			n=n+1;
			xposition_raw(n)=xi;
			yposition_raw(n)=yi;
			plot(xposition_raw(n),yposition_raw(n), 'r+', 'MarkerSize',10,'tag','extractpoint');
		end
		deltax=abs(xposition_raw(1,1)-xposition_raw(1,2));
		deltay=abs(yposition_raw(1,1)-yposition_raw(1,2));
		radius=sqrt(deltax^2+deltay^2);
		valtable=linspace(0,2*pi,361);
		for i=1:size(valtable,2)
			xposition(1,i)=sin(valtable(1,i))*radius+xposition_raw(1,1);
			yposition(1,i)=cos(valtable(1,i))*radius+yposition_raw(1,1);
		end
		delete(findobj('tag', 'extractline'))
		line(xposition,yposition,'LineWidth',3, 'Color', [0,0,0.95],'tag','extractline');
		line(xposition,yposition,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','extractline');
		text(xposition(1,1),yposition(1,1),'\leftarrow start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(1,1),yposition(1,1)+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(1,1),yposition(1,1)-8-radius*2,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(1,1)-radius-8,yposition(1,1)-radius,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
		text(xposition(1,1)+radius+8,yposition(1,1)-radius,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
	elseif get(handles.draw_what,'value')==3 %circle series
		set(handles.extraction_choice,'Value',11);
		for i=1:2
			[xi,yi,but] = ginput(1);
			if i==1;delete(findobj('tag', 'extractpoint'));end
			n=n+1;
			xposition_raw(n)=xi;
			yposition_raw(n)=yi;
			plot(xposition_raw(n),yposition_raw(n), 'r+', 'MarkerSize',10,'tag','extractpoint');
		end
		deltax=abs(xposition_raw(1,1)-xposition_raw(1,2));
		deltay=abs(yposition_raw(1,1)-yposition_raw(1,2));
		radius=sqrt(deltax^2+deltay^2);
		valtable=linspace(0,2*pi,361);
		for m=1:30
			for i=1:size(valtable,2)
				xposition(m,i)=sin(valtable(1,i))*(radius-((30-m)/30)*radius)+xposition_raw(1,1);
				yposition(m,i)=cos(valtable(1,i))*(radius-((30-m)/30)*radius)+yposition_raw(1,1);
			end
		end
		delete(findobj('tag', 'extractline'))
		for m=1:30
			line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
		end
		text(xposition(30,1),yposition(30,1),'\leftarrow start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(30,1),yposition(30,1)+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(30,1),yposition(30,1)-8-radius*2,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
		text(xposition(30,1)-radius-8,yposition(30,1)-radius,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
		text(xposition(30,1)+radius+8,yposition(30,1)-radius,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
	end
	hold off;
	put('xposition',xposition)
	put('yposition',yposition)
	toolsavailable(1);
end

function save_data_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));

if get(handles.extractLineAll, 'value')==0
	startfr=currentframe;
	endfr=currentframe;
else
	startfr=1;
	endfr=size(resultslist,2);
end
selected=0;
for i=startfr:endfr
	set(handles.fileselector, 'value',i)
	%sliderdisp
	currentframe=floor(get(handles.fileselector, 'value'));
	if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
		delete(findobj('tag', 'derivplotwindow'));
		plot_data_Callback %make sure that data was calculated
		%close figure...
		delete(findobj('tag', 'derivplotwindow'));
		extractwhat=get(handles.extraction_choice,'Value');
		current=get(handles.extraction_choice,'string');
		current=current{extractwhat};
		if selected==0
			imgsavepath=retr('imgsavepath');
			if isempty(imgsavepath)
				imgsavepath=retr('pathname');
			end
			%find '\', replace with 'per'
			part1= current(1:strfind(current,'/')-1) ;
			part2= current(strfind(current,'/')+1:end);
			if isempty(part1)==1
				currentED=current;
			else
				currentED=[part1 ' per ' part2];
			end
			[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.txt'])); %framenummer in dateiname
			selected=1;
		end
		if isequal(FileName,0) | isequal(PathName,0)
			%exit for
			break;
		else
			put('imgsavepath',PathName);
			pointpos=strfind(FileName, '.');
			pointpos=pointpos(end);
			FileName_final=[FileName(1:pointpos-1) '_' num2str(currentframe) '.' FileName(pointpos+1:end)];
			c=retr('c');
			distance=retr('distance');
			%also retrieve coordinates of polyline points if possible
			cx=retr('cx');
			cy=retr('cy');
			if size(c,2)>1 %circle series
				if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
					header=['circle nr., Distance on line [px], x-coordinate [px], y-coordinate [px], ' current];
				else
					header=['circle nr., Distance on line [m], x-coordinate [m], y-coordinate [m], ' current];
				end
				wholeLOT=[];
				for z=1:30
					wholeLOT=[wholeLOT;[linspace(z,z,size(c,2))' distance(z,:)' cx(z,:)' cy(z,:)' c(z,:)']]; %anders.... untereinander
				end
			else

				if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
					header=['Distance on line [px], x-coordinate [px], y-coordinate [px], ' current];
				else
					header=['Distance on line [m], x-coordinate [m], y-coordinate [m], ' current];
				end
				wholeLOT=[distance cx cy c];
			end
			fid = fopen(fullfile(PathName,FileName_final), 'w');
			fprintf(fid, [header '\r\n']);
			fclose(fid);
			dlmwrite(fullfile(PathName,FileName_final), wholeLOT, '-append', 'delimiter', ',', 'precision', 10, 'newline', 'pc');
		end
	end
end
sliderdisp

function plot_data_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	xposition=retr('xposition'); %not conflicting...?
	yposition=retr('yposition'); %not conflicting...?
	if numel(xposition)>1
		for i=1:size(xposition,2)-1
			%length of one segment:
			laenge(i)=sqrt((xposition(1,i+1)-xposition(1,i))^2+(yposition(1,i+1)-yposition(1,i))^2);
		end
		length=sum(laenge);
		percentagex=xposition/max(max(x));
		xaufderivative=percentagex*size(x,2);
		percentagey=yposition/max(max(y));
		yaufderivative=percentagey*size(y,1);
		nrpoints=str2num(get(handles.nrpoints,'string'));
		if get(handles.draw_what,'value')==3 %circle series
			set(handles.extraction_choice,'Value',11); %set to tangent
		end
		extractwhat=get(handles.extraction_choice,'Value');
		switch extractwhat
			case {1,2,3,4,5,6,7,8}
				derivative_calc(currentframe,extractwhat+1,0);
				derived=retr('derived');
				maptoget=derived{extractwhat,currentframe};

				maptoget=rescale_maps_nan(maptoget,0);
				[cx, cy, c] = improfile(maptoget,xposition,yposition,round(nrpoints),'bicubic');

				distance=linspace(0,length,size(c,1))';

			case {9,10}
				% auf stelle 9 steht vector angle. Bei derivatives ist der aber auf platz 11. daher zwei dazu
				%auf stelle 10 steht correlation coeff, bei derivatives auf
				%12, daher zwei dazu
				derivative_calc(currentframe,extractwhat+2,0);
				derived=retr('derived');
				maptoget=derived{extractwhat+1,currentframe};

				maptoget=rescale_maps_nan(maptoget,0);
				[cx, cy, c] = improfile(maptoget,xposition,yposition,round(nrpoints),'bicubic');

				distance=linspace(0,length,size(c,1))';
			case 11 %tangent
				if size(xposition,1)<=1 %user did not choose circle series
					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
							u=resultslist{10,currentframe};
							v=resultslist{11,currentframe};
							typevector=resultslist{9,currentframe};
							if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,currentframe};
							end
						else
							u=resultslist{7,currentframe};
							if size(u,1)>1
								v=resultslist{8,currentframe};
								typevector=resultslist{9,currentframe};
							else
								u=resultslist{3,currentframe};
								v=resultslist{4,currentframe};
								typevector=resultslist{5,currentframe};
							end
						end
					else
						u=resultslist{3,currentframe};
						v=resultslist{4,currentframe};
						typevector=resultslist{5,currentframe};
					end
					calu=retr('calu');calv=retr('calv');
					u=u*calu-retr('subtr_u');
					v=v*calv-retr('subtr_v');

					u=rescale_maps_nan(u,0);
					v=rescale_maps_nan(v,0);

					[cx, cy, cu] = improfile(u,xposition,yposition,round(nrpoints),'bicubic');
					cv = improfile(v,xposition,yposition,round(nrpoints),'bicubic');
					cx=cx';
					cy=cy';
					deltax=zeros(1,size(cx,2)-1);
					deltay=zeros(1,size(cx,2)-1);
					laenge=zeros(1,size(cx,2)-1);
					alpha=zeros(1,size(cx,2)-1);
					sinalpha=zeros(1,size(cx,2)-1);
					cosalpha=zeros(1,size(cx,2)-1);
					for i=2:size(cx,2)
						deltax(1,i)=cx(1,i)-cx(1,i-1);
						deltay(1,i)=cy(1,i)-cy(1,i-1);
						laenge(1,i)=sqrt(deltax(1,i)*deltax(1,i)+deltay(1,i)*deltay(1,i));
						alpha(1,i)=(acos(deltax(1,i)/laenge(1,i)));
						if deltay(1,i) < 0
							sinalpha(1,i)=sin(alpha(1,i));
						else
							sinalpha(1,i)=sin(alpha(1,i))*-1;
						end
						cosalpha(1,i)=cos(alpha(1,i));
					end
					sinalpha(1,1)=sinalpha(1,2);
					cosalpha(1,1)=cosalpha(1,2);
					cu=cu.*cosalpha';
					cv=cv.*sinalpha';
					c=cu-cv;
					cx=cx';
					cy=cy';
					distance=linspace(0,length,size(cu,1))';
				else %user chose circle series
					for m=1:30
						for i=1:size(xposition,2)-1
							%length of one segment:
							laenge(m,i)=sqrt((xposition(m,i+1)-xposition(m,i))^2+(yposition(m,i+1)-yposition(m,i))^2);
						end
						length(m)=sum(laenge(m,:));
					end
					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
							u=resultslist{10,currentframe};
							v=resultslist{11,currentframe};
							typevector=resultslist{9,currentframe};
							if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,currentframe};
							end
						else
							u=resultslist{7,currentframe};
							if size(u,1)>1
								v=resultslist{8,currentframe};
								typevector=resultslist{9,currentframe};
							else
								u=resultslist{3,currentframe};
								v=resultslist{4,currentframe};
								typevector=resultslist{5,currentframe};
							end
						end
					else
						u=resultslist{3,currentframe};
						v=resultslist{4,currentframe};
						typevector=resultslist{5,currentframe};
					end
					calu=retr('calu');calv=retr('calv');
					u=u*calu-retr('subtr_u');
					v=v*calv-retr('subtr_v');
					u=rescale_maps_nan(u,0);
					v=rescale_maps_nan(v,0);
					min_y=floor(min(min(yposition)))-1;
					max_y=ceil(max(max(yposition)))+1;
					min_x=floor(min(min(xposition)))-1;
					max_x=ceil(max(max(xposition)))+1;
					if min_y<1
						min_y=1;
					end
					if max_y>size(u,1)
						max_y=size(u,1);
					end
					if min_x<1
						min_x=1;
					end
					if max_x>size(u,2)
						max_x=size(u,2);
					end

					uc=u(min_y:max_y,min_x:max_x);
					vc=v(min_y:max_y,min_x:max_x);
					for m=1:30
						[cx(m,:),cy(m,:),cu(m,:)] = improfile(uc,xposition(m,:)-min_x,yposition(m,:)-min_y,100,'nearest');
						cv(m,:) =improfile(vc,xposition(m,:)-min_x,yposition(m,:)-min_y,100,'nearest');
					end
					deltax=zeros(1,size(cx,2)-1);
					deltay=zeros(1,size(cx,2)-1);
					laenge=zeros(1,size(cx,2)-1);
					alpha=zeros(1,size(cx,2)-1);
					sinalpha=zeros(1,size(cx,2)-1);
					cosalpha=zeros(1,size(cx,2)-1);
					for m=1:30
						for i=2:size(cx,2)
							deltax(m,i)=cx(m,i)-cx(m,i-1);
							deltay(m,i)=cy(m,i)-cy(m,i-1);
							laenge(m,i)=sqrt(deltax(m,i)*deltax(m,i)+deltay(m,i)*deltay(m,i));
							alpha(m,i)=(acos(deltax(m,i)/laenge(m,i)));
							if deltay(m,i) < 0
								sinalpha(m,i)=sin(alpha(m,i));
							else
								sinalpha(m,i)=sin(alpha(m,i))*-1;
							end
							cosalpha(m,i)=cos(alpha(m,i));
						end
						sinalpha(m,1)=sinalpha(m,2); %ersten winkel f체llen
						cosalpha(m,1)=cosalpha(m,2);
					end
					cu=cu.*cosalpha;
					cv=cv.*sinalpha;
					c=cu-cv;
					for m=1:30
						distance(m,:)=linspace(0,length(m),size(cu,2))'; %in pixeln...
					end
				end

		end
		if size(xposition,1)<=1 %user did not choose circle series
			h=figure;
			screensize=get( 0, 'ScreenSize' );
			rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
			set(h,'position', rect);
			current=get(handles.extraction_choice,'string');
			current=current{extractwhat};
			set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
			calxy=retr('calxy');

			%removing nans for integral!
			distance2=distance(~isnan(c));
			c2=c(~isnan(c));

			integral=trapz(distance2*calxy,c2);
			h2=plot(distance*calxy,c);

			%get units
			if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
				distunit='px^2';
			else
				distunit='m^2';
			end

			unitpar=get(handles.extraction_choice,'string');
			unitpar=unitpar{get(handles.extraction_choice,'value')};
			unitpar=unitpar(strfind(unitpar,'[')+1:end-1);

			%text(0+0.05*max(distance*calxy),min(c)+0.05*max(c),['Integral = ' num2str(integral) ' [' unitpar '*' distunit ']'], 'BackgroundColor', 'w','fontsize',7)
			set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')


			if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
				distunit_2=' [px]';
			else
				distunit_2=' [m]';
			end

			currentstripped=current(1:strfind(current,'[')-1);

			%modified units...
			xlabel(['Distance on line' distunit_2 sprintf('\n') 'Integral of ' currentstripped ' = ' num2str(integral) ' [' unitpar '*' distunit_2 ']']);

			ylabel(current);
			put('distance',distance*calxy);
			put('c',c);
			[cx_cal,cy_cal] = calibrate_xy(cx,cy);
			put('cx',cx_cal);
			put('cy',cy_cal);
			h_extractionplot=retr('h_extractionplot');
			h_extractionplot(size(h_extractionplot,1)+1,1)=h;
			put ('h_extractionplot', h_extractionplot);
		else %user chose circle series
			calxy=retr('calxy');
			for m=1:30
				integral(m)=trapz(distance(m,:)*calxy,c(m,:));
			end
			%highlight circle with highest circ
			delete(findobj('tag', 'extractline'))
			for m=1:30
				line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
			end
			[r,col]=find(max(abs(integral))==abs(integral)); %find absolute max of integral
			line(xposition(col,:),yposition(col,:),'LineWidth',2.5, 'Color', [0.2,0.5,0.7],'tag','extractline');
			h=figure;
			screensize=get( 0, 'ScreenSize' );
			rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
			set(h,'position', rect);
			current=get(handles.extraction_choice,'string');
			current=current{extractwhat};
			set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
			hold on;
			for m=1:30
				h2=plot(distance(m,:)*calxy,c(m,:), 'color',[m/30, rand(1)/4+0.5, 1-m/30]);
			end
			hold off;
			set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
			if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
				xlabel('Distance on line [px]');
			else
				xlabel('Distance on line [m]');
			end
			ylabel(current);
			h3=figure;
			screensize=get( 0, 'ScreenSize' );
			rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
			set(h3,'position', rect);
			current=get(handles.extraction_choice,'string');
			current=current{extractwhat};
			set(h3,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
			calxy=retr('calxy');
			%user can click on point, circle will be displayed in main window
			plot (1:30, integral);
			hold on;
			scattergroup1=scatter(1:30, integral, 80, 'ko');
			hold off;

			if verLessThan('matlab','8.4')
				set(scattergroup1, 'ButtonDownFcn', @hitcircle, 'hittestarea', 'off');
			else
				% >R2014a
				set(scattergroup1, 'ButtonDownFcn', @hitcircle, 'pickableparts', 'visible');
			end



			title('Click the points of the graph to highlight it''s corresponding circle.')
			set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
			xlabel('circle series nr. (circle with max. circulation highlighted in blue)');
			if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
				ylabel('tangent velocity loop integral (circulation) [px^2/frame]');
			else
				ylabel('tangent velocity loop integral (circulation) [m^2/s]');
			end
			put('distance',distance*calxy);
			put('c',c);
			[cx_cal,cy_cal] = calibrate_xy(cx,cy);
			put('cx',cx_cal);
			put('cy',cy_cal);
			put('h3plot', h3);
			put('integral', integral);
			h_extractionplot=retr('h_extractionplot');
			h_extractionplot(size(h_extractionplot,1)+1,1)=h;
			put ('h_extractionplot', h_extractionplot);
			h_extractionplot2=retr('h_extractionplot2');
			h_extractionplot2(size(h_extractionplot2,1)+1,1)=h3;
			put ('h_extractionplot2', h_extractionplot2);
		end
	end
end

function hitcircle(~,~)
posreal=get(gca,'CurrentPoint');
delete(findobj('tag','circstring'));
pos=round(posreal(1,1));
xposition=retr('xposition');
yposition=retr('yposition');
integral=retr('integral');
hgui=getappdata(0,'hgui');
h3plot=retr('h3plot');
figure(hgui);
delete(findobj('tag', 'extractline'))
for m=1:30
	line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
end
line(xposition(pos,:),yposition(pos,:),'LineWidth',2.5, 'Color',[0.2,0.5,0.7],'tag','extractline');
figure(h3plot);
marksize=linspace(80,80,30)';
marksize(pos)=150;
set(gco, 'SizeData', marksize);
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	units='px^2/frame';
else
	units='m^2/s';
end
text(posreal(1,1)+0.75,posreal(2,2),['\leftarrow ' num2str(integral(pos)) ' ' units],'tag','circstring','BackgroundColor', [1 1 1], 'margin', 0.01, 'fontsize', 7, 'HitTest', 'off')

function clear_plot_Callback(~, ~, ~)
h_extractionplot=retr('h_extractionplot');
h_extractionplot2=retr('h_extractionplot2');
for i=1:size(h_extractionplot,1)
	try
		close (h_extractionplot(i));
	catch
	end
	try
		close (h_extractionplot2(i));
	catch
	end
end
put ('h_extractionplot', []);
put ('h_extractionplot2', []);
delete(findobj('tag', 'extractpoint'));
delete(findobj('tag', 'extractline'));
delete(findobj('tag', 'circstring'));

function histdraw_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=retr('ismean');
	if    numel(ismean)>0
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end

	u(typevector==0)=nan;
	v(typevector==0)=nan;

	calu=retr('calu');calv=retr('calv');
	calxy=retr('calxy');
	x=reshape(x,size(x,1)*size(x,2),1);
	y=reshape(y,size(y,1)*size(y,2),1);
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	choice_plot=get(handles.hist_select,'value');
	current=get(handles.hist_select,'string');
	current=current{choice_plot};
	h=figure;
	screensize=get( 0, 'ScreenSize' );
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Histogram ' current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
	nrofbins=str2double(get(handles.nrofbins, 'string'));
	if choice_plot==1
		[n, xout]=hist(u*calu-retr('subtr_u'),nrofbins); %#ok<*HIST>
		xdescript='velocity (u)';
	elseif choice_plot==2
		[n, xout]=hist(v*calv-retr('subtr_v'),nrofbins);
		xdescript='velocity (v)';
	elseif choice_plot==3
		[n, xout]=hist(sqrt((u*calu-retr('subtr_u')).^2+(v*calv-retr('subtr_v')).^2),nrofbins);
		xdescript='velocity magnitude';
	end
	h2=bar(xout,n);
	set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
	if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
		xlabel([xdescript ' [px/frame]']);
	else
		xlabel([xdescript ' [m/s]']);
	end
	ylabel('frequency');
end

function generate_it_Callback(~, ~, ~)
handles=gethand;
flow_sim=get(handles.flow_sim,'value');
switch flow_sim
	case 1 %rankine
		v0 = str2double(get(handles.rank_displ,'string')); %max velocity
		vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
		center1=[str2double(get(handles.rankx1,'string')),str2double(get(handles.ranky1,'string'))]; %x,y
		center2=[str2double(get(handles.rankx2,'string')),str2double(get(handles.ranky2,'string'))]; %x,y
		[x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
		[o,r] = cart2pol(x,y);
		uo=zeros(size(x));
		R0 = str2double(get(handles.rank_core,'string')); %radius %35
		uoin = (r <= R0);
		uout = (r > R0);
		uo = uoin+uout;
		uo(uoin) =  v0*r(uoin)/R0;
		uo(uout) =  v0*R0./r(uout);
		uo(isnan(uo))=0;
		u = -uo.*sin(o);
		v = uo.*cos(o);
		if get(handles.singledoublerankine,'value')==2
			[x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
			[o,r] = cart2pol(x,y);
			uo=zeros(size(x));
			R0 = str2double(get(handles.rank_core,'string')); %radius %35
			uoin = (r <= R0);
			uout = (r > R0);
			uo = uoin+uout;
			uo(uoin) =  v0*r(uoin)/R0;
			uo(uout) =  v0*R0./r(uout);
			uo(isnan(uo))=0;
			u2 = -uo.*sin(o);
			v2 = uo.*cos(o);
			u=u-u2;
			v=v-v2;
		end
	case 2 %oseen
		v0 = str2double(get(handles.oseen_displ,'string'))*3; %max velocity
		vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
		center1=[str2double(get(handles.oseenx1,'string')),str2double(get(handles.oseeny1,'string'))]; %x,y
		center2=[str2double(get(handles.oseenx2,'string')),str2double(get(handles.oseeny2,'string'))]; %x,y
		[x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
		[o,r] = cart2pol(x,y);
		uo=zeros(size(x));
		zaeh=1;
		t=str2double(get(handles.oseen_time,'string'));
		r=r/100;

		%uo wird im zwentrum NaN!!
		uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
		uo(isnan(uo))=0;
		u = -uo.*sin(o);
		v = uo.*cos(o);
		if get(handles.singledoubleoseen,'value')==2
			[x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
			[o,r] = cart2pol(x,y);
			r=r/100;
			uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
			uo(isnan(uo))=0;
			u2 = -uo.*sin(o);
			v2 = uo.*cos(o);
			u=u-u2;
			v=v-v2;
		end
	case 3 %linear
		u=zeros(str2double(get(handles.img_sizey,'string')),str2double(get(handles.img_sizex,'string')));
		v(1:str2double(get(handles.img_sizey,'string')),1:str2double(get(handles.img_sizex,'string')))=str2double(get(handles.shiftdisplacement,'string'));
	case 4 % rotation
		[v,u] = meshgrid(-(str2double(get(handles.img_sizex,'string')))/2:1:(str2double(get(handles.img_sizex,'string')))/2-1,-(str2double(get(handles.img_sizey,'string')))/2:1:(str2double(get(handles.img_sizey,'string')))/2-1);

		u=u/max(max(u));
		v=-v/max(max(v));
		u=u*str2double(get(handles.rotationdislacement,'string'));
		v=v*str2double(get(handles.rotationdislacement,'string'));
		[x,y]=meshgrid(1:1:str2double(get(handles.img_sizex,'string'))+1);
	case 5 %membrane
		[x,y]=meshgrid(linspace(-3,3,str2double(get(handles.img_sizex,'string'))),linspace(-3,3,str2double(get(handles.img_sizey,'string'))));
		u = peaks(x,y)/3;
		v = peaks(y,x)/3;
end
%% Create Particle Image
set(handles.status_creation,'string','Calculating particles...');drawnow;
i=[];
j=[];
sizey=str2double(get(handles.img_sizey,'string'));
sizex=str2double(get(handles.img_sizex,'string'));
noise=str2double(get(handles.part_noise,'string'));
A=zeros(sizey,sizex);
B=A;
partAm=str2double(get(handles.part_am,'string'));
Z=str2double(get(handles.sheetthick,'string')); %0.25 sheet thickness
dt=str2double(get(handles.part_size,'string')); %particle diameter
ddt=str2double(get(handles.part_var,'string')); %particle diameter variation

z0_pre=randn(partAm,1); %normal distributed sheet intensity
randn('state', sum(100*clock)); %#ok<*RAND>
z1_pre=randn(partAm,1); %normal distributed sheet intensity

z0=z0_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z1_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));
z1=z1_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z0_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));

%z0=abs(randn(partAm,1)); %normal distributed sheet intensity
I0=255*exp(-(Z^2./(0.125*z0.^2))); %particle intensity
I0(I0>255)=255;
I0(I0<0)=0;

I1=255*exp(-(Z^2./(0.125*z1.^2))); %particle intensity
I1(I1>255)=255;
I1(I1<0)=0;

randn('state', sum(100*clock));
d=randn(partAm,1)/2; %particle diameter distribution
d=dt+d*ddt;
d(d<0)=0;
rand('state', sum(100*clock));
x0=rand(partAm,1)*sizex;
y0=rand(partAm,1)*sizey;
rd = -8.0 ./ d.^2;
offsety=v;
offsetx=u;

xlimit1=floor(x0-d/2); %x min particle extent image1
xlimit2=ceil(x0+d/2); %x max particle extent image1
ylimit1=floor(y0-d/2); %y min particle extent image1
ylimit2=ceil(y0+d/2); %y max particle extent image1
xlimit2(xlimit2>sizex)=sizex;
xlimit1(xlimit1<1)=1;
ylimit2(ylimit2>sizey)=sizey;
ylimit1(ylimit1<1)=1;

%calculate particle extents for image2 (shifted image)
x0integer=round(x0);
x0integer(x0integer>sizex)=sizex;
x0integer(x0integer<1)=1;
y0integer=round(y0);
y0integer(y0integer>sizey)=sizey;
y0integer(y0integer<1)=1;

xlimit3=zeros(partAm,1);
xlimit4=xlimit3;
ylimit3=xlimit3;
ylimit4=xlimit3;
for n=1:partAm
	xlimit3(n,1)=floor(x0(n)-d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x min particle extent image2
	xlimit4(n,1)=ceil(x0(n)+d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x max particle extent image2
	ylimit3(n,1)=floor(y0(n)-d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y min particle extent image2
	ylimit4(n,1)=ceil(y0(n)+d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y max particle extent image2
end
xlimit3(xlimit3<1)=1;
xlimit4(xlimit4>sizex)=sizex;
ylimit3(ylimit3<1)=1;
ylimit4(ylimit4>sizey)=sizey;

set(handles.status_creation,'string','Placing particles...');drawnow;
for n=1:partAm
	r = rd(n);
	for j=xlimit1(n):xlimit2(n)
		rj = (j-x0(n))^2;
		for i=ylimit1(n):ylimit2(n)
			A(i,j)=A(i,j)+I0(n)*exp((rj+(i-y0(n))^2)*r);
		end
	end
	for j=xlimit3(n):xlimit4(n)
		for i=ylimit3(n):ylimit4(n)
			B(i,j)=B(i,j)+I1(n)*exp((-(j-x0(n)+offsetx(i,j))^2-(i-y0(n)+offsety(i,j))^2)*-rd(n)); %place particle with gaussian intensity profile
		end
	end
end

A(A>255)=255;
B(B>255)=255;

gen_image_1=imnoise(uint8(A),'gaussian',0,noise);
gen_image_2=imnoise(uint8(B),'gaussian',0,noise);

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
put('gen_image_1',gen_image_1);
put('gen_image_2',gen_image_2);
put('real_displ_u',offsetx);
put('real_displ_v',offsety);

function save_imgs_Callback(~, ~, ~)
gen_image_1=retr('gen_image_1');
gen_image_2=retr('gen_image_2');
real_displacement_u=retr('real_displ_u');
real_displacement_v=retr('real_displ_v');
if isempty(gen_image_1)==0
	[FileName,PathName] = uiputfile('*.tif','Save generated images as...',['PIVlab_gen.tif']);
	if isequal(FileName,0) | isequal(PathName,0)
	else
		[Dir, Name, Ext] = fileparts(FileName);
		FileName_1=[Name '_01' Ext];
		FileName_2=[Name '_02' Ext];
		if exist(fullfile(PathName,FileName_1),'file') >0 || exist(fullfile(PathName,FileName_2),'file') >0
			butt = questdlg(['Warning: File ' FileName_1 ' already exists.'],'File exists','Overwrite','Cancel','Overwrite');
			if strncmp(butt, 'Overwrite',9) == 1
				write_it=1;
			else
				write_it=0;
			end
		else
			write_it=1;
		end
		if write_it==1
			imwrite(gen_image_1,fullfile(PathName,FileName_1),'Compression','none')
			imwrite(gen_image_2,fullfile(PathName,FileName_2),'Compression','none')
			save(fullfile(PathName,[Name '_real_displacement.mat']) ,'real_displacement_u','real_displacement_v')
		end
	end
end

function dummy_Callback(~, ~, ~)
sliderdisp

function pivlabhelp_Callback(~, ~, ~)
try
	web('http://pivlab.blogspot.de/p/blog-page_19.html','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://pivlab.blogspot.de/p/blog-page_19.html')
end

function aboutpiv_Callback(~, ~, ~)
string={...
	'PIVlab - Time-Resolved Digital Particle Image Velocimetry Tool for MATLAB';...
	['version: ' retr('PIVver')];...
	'';...
	'developed by Dr. William Thielicke and Prof. Dr. Eize J. Stamhuis';...
	'published under the BSD and CC-BY licence.';...
	'';...
	'';...
	'programmed with MATLAB Version 7.10 (R2010a)';...
	'first released March 09, 2010';...
	'';...
	'http://PIVlab.blogspot.com';...
	'contact: PIVlab@gmx.com';...
	'';...
	'Lasers, synchronizers and cameras for PIVlab:';...
	'www.optolution.com';...
	};
helpdlg(string,'About')

function clear_everything_Callback(~, ~, ~)
put ('resultslist', []); %clears old results
put ('derived', []);
handles=gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
sliderdisp

function autoscale_vec_Callback(~, ~, ~)
handles=gethand;
if get(handles.autoscale_vec, 'value')==1
	set(handles.vectorscale,'enable', 'off');
else
	set(handles.vectorscale,'enable', 'on');
end

function save_session_Callback(auto_save_session, auto_save_session_filename)
sessionpath=retr('sessionpath');
if isempty(sessionpath)
	sessionpath=retr('pathname');
end
if auto_save_session ~= 1
	[FileName,PathName] = uiputfile('*.mat','Save current session as...',fullfile(sessionpath,'PIVlab_session.mat'));
else
	[PathName,FileName,ext] = fileparts(auto_save_session_filename);
	FileName = [FileName ext];
end
if isequal(FileName,0) | isequal(PathName,0)
else
	put('expected_image_size',[])
	put('sessionpath',PathName );
	savesessionfuntion (PathName,FileName)
end

function savesessionfuntion (PathName,FileName)
hgui=getappdata(0,'hgui');
handles=gethand;
app=getappdata(hgui);
text(150,150,'Please wait, saving session. This might take a while.','color','y','fontsize',13, 'BackgroundColor', 'k','tag','savehint')
drawnow;
%Newer versions of Matlab do really funny things when the following vars are not empty...:
app.GUIDEOptions =[];
app.GUIOnScreen  =[];
app.Listeners  =[];
app.SavedVisible  =[];
app.ScribePloteditEnable  =[];
app.UsedByGUIData_m  =[];
app.lastValidTag =[];
iptPointerManager=[];
app.ZoomObject=[]; %Matlab crashes if this is not empty. Weird...
app.ZoomFigureState=[];
app.ZoomOnState=[];
app.PanFigureState=[];
app.uitools_FigureToolManager=[];

try
	iptPointerManager(gcf, 'disable');
catch
end
clear hgui iptPointerManager GUIDEOptions GUIOnScreen Listeners SavedVisible ScribePloteditEnable UsedByGUIData_m ZoomObject
deli={'UsedByGUIData_m', 'uitools_FigureToolManager','PanFigureState','ZoomOnState','ZoomFigureState','ZoomObject','lastValidTag','SavedVisible','Listeners','GUIOnScreen','GUIDEOptions','ScribePloteditEnable','nonexistingfield'};
for i=1:size(deli,2)
	try
		app=rmfield(app,deli{i});
	catch
	end
end
clear deli
%save('-v6', fullfile(PathName,FileName), '-struct', 'app')
%save(fullfile(PathName,FileName), '-struct', 'app') % AKTUELL PUBLIZIERT
warning off
save(fullfile(PathName,FileName), '-struct', 'app','-v7.3')% riesig aber nur das geht...
warning on

clear app %hgui iptPointerManager
clear hgui iptPointerManager GUIDEOptions GUIOnScreen Listeners SavedVisible ScribePloteditEnable UsedByGUIData_m

clahe_enable=get(handles.clahe_enable,'value');
clahe_size=get(handles.clahe_size,'string');
enable_highpass=get(handles.enable_highpass,'value');
highp_size=get(handles.highp_size,'string');
wienerwurst=get(handles.wienerwurst,'value');
wienerwurstsize=get(handles.wienerwurstsize,'string');
%enable_clip=get(handles.enable_clip,'value');
%clip_thresh=get(handles.clip_thresh,'string');
enable_intenscap=get(handles.enable_intenscap,'value');
intarea=get(handles.intarea,'string');
stepsize=get(handles.step,'string');
subpix=get(handles.subpix,'value');  %popup
stdev_check=get(handles.stdev_check,'value');
stdev_thresh=get(handles.stdev_thresh,'string');
loc_median=get(handles.loc_median,'value');
loc_med_thresh=get(handles.loc_med_thresh,'string');
%epsilon=get(handles.epsilon,'string');
interpol_missing=get(handles.interpol_missing,'value');
vectorscale=get(handles.vectorscale,'string');
colormap_choice=get(handles.colormap_choice,'value'); %popup
colormap_steps=get(handles.colormap_steps,'value');
colormap_interpolation=get(handles.colormap_interpolation,'value');
addfileinfo=get(handles.addfileinfo,'value');
add_header=get(handles.add_header,'value');
delimiter=get(handles.delimiter,'value');%popup
img_not_mask=get(handles.img_not_mask,'value');
autoscale_vec=get(handles.autoscale_vec,'value');
calxy=retr('calxy');
calu=retr('calu');calv=retr('calv');
pointscali=retr('pointscali');

x_axis_direction=get(handles.x_axis_direction,'value');
y_axis_direction=get(handles.y_axis_direction,'value');
size_of_the_image=retr('size_of_the_image');
points_offsetx=retr('points_offsetx');
points_offsety=retr('points_offsety');
offset_x_true=retr('offset_x_true');
offset_y_true=retr('offset_y_true');

realdist_string=get(handles.realdist, 'String');
time_inp_string=get(handles.time_inp, 'String');

%imginterpol=get(handles.popupmenu16, 'value');
dccmark=get(handles.dcc, 'value');
fftmark=get(handles.fftmulti, 'value');
ensemblemark=get(handles.ensemble, 'value');
pass2=get(handles.checkbox26, 'value');
pass3=get(handles.checkbox27, 'value');
pass4=get(handles.checkbox28, 'value');
pass2val=get(handles.edit50, 'string');
pass3val=get(handles.edit51, 'string');
pass4val=get(handles.edit52, 'string');
step2=get(handles.text126, 'string');
step3=get(handles.text127, 'string');
step4=get(handles.text128, 'string');
holdstream=get(handles.holdstream, 'value');
streamlamount=get(handles.streamlamount, 'string');
streamlcolor=get(handles.streamlcolor, 'value');

try
	%neu v1.5:
	%Repeated_box=get(handles.Repeated_box,'value');
	mask_auto_box=get(handles.mask_auto_box,'value');
	Autolimit=get(handles.Autolimit,'value');
	minintens=get(handles.minintens,'string');
	maxintens=get(handles.maxintens,'string');
	%neu v2.11
	CorrQuality_nr=get(handles.CorrQuality,'value');
	%neu v2.37
	enhance_disp=get(handles.enhance_images, 'Value');
catch
	disp('Old version compatibility|');
end
try
	contrast_filter_thresh=get(handles.contrast_filter_thresh,'string');
	bright_filter_thresh=get(handles.bright_filter_thresh,'string');
	do_bright_filter=get(handles.do_bright_filter,'Value');
	do_contrast_filter=get(handles.do_contrast_filter,'Value');
catch
end
try
	%neu v2.54
	do_corr2_filter=get(handles.do_corr2_filter,'value');
	corr_filter_thresh=get(handles.corr_filter_thresh,'string');
	notch_L_thresh=get(handles.notch_L_thresh,'string');
	notch_H_thresh=get(handles.notch_H_thresh,'string');
	notch_filter=get(handles.notch_filter,'Value');
catch
	disp('corr filter / notch settings');
end
%neu v2.52
try
	repeat_last = get (handles.repeat_last,'Value');
	repeat_last_thresh = get(handles.edit52x,'String');
catch
	disp('repeat_last didnt work3')
end

try
	bg_img_A=retr('bg_img_A');
	bg_img_B=retr('bg_img_B');
catch
	disp('Could not fetch bg imgs')
end

clear handles

%save('-v6', fullfile(PathName,FileName), '-append');
%save(fullfile(PathName,FileName), '-append');
save(fullfile(PathName,FileName), '-append');

delete(findobj('tag','savehint'));
drawnow;

function load_session_Callback(auto_load_session, auto_load_session_filename)
sessionpath=retr('sessionpath');
if isempty(sessionpath)
	sessionpath=retr('pathname');
end
if auto_load_session ~= 1
	[FileName,PathName, filterindex] = uigetfile({'*.mat','MATLAB Files (*.mat)'; '*.mat','mat'},'Load PIVlab session',fullfile(sessionpath, 'PIVlab_session.mat'));
else
	[PathName,FileName,ext] = fileparts(auto_load_session_filename);
	FileName = [FileName ext];
end
if isequal(FileName,0) | isequal(PathName,0)
else
	put('expected_image_size',[])
	clear iptPointerManager
	put('sessionpath',PathName );
	put('derived',[]);
	put('resultslist',[]);
	put('maskiererx',[]);
	put('maskierery',[]);
	put('roirect',[]);
	put('velrect',[]);
	put('filename',[]);
	put('filepath',[]);
	hgui=getappdata(0,'hgui');
	warning off all
	try
		%even if a variable doesn't exist, this doesn't throw an error...
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu', 'calv','calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_choice', 'colormap_steps', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'maskiererx', 'maskierery', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','dccmark','fftmark','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize','mask_auto_box','Autolimit','minintens','maxintens','CorrQuality_nr','ensemblemark','enhance_disp','video_selection_done','video_frame_selection','video_reader_object','bg_img_A','bg_img_B','x_axis_direction','y_axis_direction','size_of_the_image','points_offsetx','points_offsety','offset_x_true','offset_y_true','bright_filter_thresh','contrast_filter_thresh','do_bright_filter','do_contrast_filter','repeat_last','repeat_last_thresh','do_corr2_filter','corr_filter_thresh','notch_L_thresh','notch_H_thresh','notch_filter');
	catch
		disp('Old version compatibility.')
		vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', 'caliimg', 'calu','calv', 'calxy', 'cancel', 'clahe_enable', 'clahe_size', 'colormap_steps','colormap_choice', 'colormap_interpolation', 'delimiter', 'derived', 'displaywhat', 'distance', 'enable_highpass', 'enable_intenscap', 'epsilon', 'filename', 'filepath', 'highp_size', 'homedir', 'img_not_mask', 'intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', 'manualdeletion', 'maskiererx', 'maskierery', 'pathname', 'pointscali', 'resultslist', 'roirect', 'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix', 'subtr_u', 'subtr_v', 'toggler', 'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY','manmarkersX','manmarkersY','imginterpol','dccmark','fftmark','pass2','pass3','pass4','pass2val','pass3val','pass4val','step2','step3','step4','holdstream','streamlamount','streamlcolor','ismean','wienerwurst','wienerwurstsize');
	end
	names=fieldnames(vars);
	for i=1:size(names,1)
		setappdata(hgui,names{i},vars.(names{i}))
	end
	sliderrange
	handles=gethand;

	set(handles.clahe_enable,'value',retr('clahe_enable'));
	set(handles.clahe_size,'string',retr('clahe_size'));
	set(handles.enable_highpass,'value',retr('enable_highpass'));
	set(handles.highp_size,'string',retr('highp_size'));

	set(handles.wienerwurst,'value',retr('wienerwurst'));
	set(handles.wienerwurstsize,'string',retr('wienerwurstsize'));

	%set(handles.enable_clip,'value',retr('enable_clip'));
	%set(handles.clip_thresh,'string',retr('clip_thresh'));
	set(handles.enable_intenscap,'value',retr('enable_intenscap'));
	set(handles.intarea,'string',retr('intarea'));
	set(handles.step,'string',retr('stepsize'));
	set(handles.subpix,'value',retr('subpix'));  %popup
	set(handles.stdev_check,'value',retr('stdev_check'));
	set(handles.stdev_thresh,'string',retr('stdev_thresh'));
	set(handles.loc_median,'value',retr('loc_median'));
	set(handles.loc_med_thresh,'string',retr('loc_med_thresh'));
	set(handles.interpol_missing,'value',retr('interpol_missing'));

	set(handles.vectorscale,'string',retr('vectorscale'));
	set(handles.colormap_choice,'value',retr('colormap_choice')); %popup
	set(handles.colormap_steps,'value',retr('colormap_steps'));
	set(handles.colormap_interpolation,'value',retr('colormap_interpolation'));
	set(handles.addfileinfo,'value',retr('addfileinfo'));
	set(handles.add_header,'value',retr('add_header'));
	set(handles.delimiter,'value',retr('delimiter'));%popup
	set(handles.img_not_mask,'value',retr('img_not_mask'));
	set(handles.autoscale_vec,'value',retr('autoscale_vec'));

	set(handles.dcc, 'value',vars.dccmark);
	set(handles.fftmulti, 'value',vars.fftmark);


	try
		set(handles.ensemble, 'value',vars.ensemblemark);
	catch
		vars.ensemblemark=0;
	end


	if vars.fftmark==1 || vars.ensemblemark ==1
		set (handles.uipanel42,'visible','on')
	else
		set (handles.uipanel42,'visible','off')
	end
	set(handles.checkbox26, 'value',vars.pass2);
	set(handles.checkbox27, 'value',vars.pass3);
	set(handles.checkbox28, 'value',vars.pass4);

	if vars.pass2 == 1
		set(handles.edit50, 'enable','on')
	else
		set(handles.edit50, 'enable','off')
	end
	if vars.pass3 == 1
		set(handles.edit51, 'enable','on')
	else
		set(handles.edit51, 'enable','off')
	end
	if vars.pass4 == 1
		set(handles.edit52, 'enable','on')
	else
		set(handles.edit52, 'enable','off')
	end
	set(handles.edit50, 'string',vars.pass2val);
	set(handles.edit51, 'string',vars.pass3val);
	set(handles.edit52, 'string',vars.pass4val);
	set(handles.text126, 'string',vars.step2);
	set(handles.text127, 'string',vars.step3);
	set(handles.text128, 'string',vars.step4);
	set(handles.holdstream, 'value',vars.holdstream);
	set(handles.streamlamount, 'string',vars.streamlamount);
	set(handles.streamlcolor, 'value',vars.streamlcolor);
	set(handles.streamlwidth, 'value',vars.streamlcolor);

	try
		%neu v1.5:
		set(handles.mask_auto_box,'value',vars.mask_auto_box);
		set(handles.Autolimit,'value',vars.Autolimit);
		set(handles.minintens,'string',vars.minintens);
		set(handles.maxintens,'string',vars.maxintens);
		set(handles.CorrQuality,'Value',vars.CorrQuality_nr);
		%neu v2.37
		set(handles.enhance_images, 'Value',vars.enhance_disp);
	catch
		disp('Old version compatibility,')
	end
	try %neu v2.42
		set(handles.interpol_missing2,'value',retr('interpol_missing'));
	catch
	end

	try %neu 2.42
		set (handles.x_axis_direction,'value',vars.x_axis_direction);
		set (handles.y_axis_direction,'value',vars.y_axis_direction);

		set(handles.contrast_filter_thresh,'string',vars.contrast_filter_thresh);
		set(handles.bright_filter_thresh,'string',vars.bright_filter_thresh);
		set(handles.do_bright_filter,'Value',vars.do_bright_filter);
		set(handles.do_contrast_filter,'Value',vars.do_contrast_filter);
	catch
	end

	try
		%neu v2.54
		set(handles.do_corr2_filter,'value',vars.do_corr2_filter);
		set(handles.corr_filter_thresh,'string',vars.corr_filter_thresh);
		set(handles.notch_L_thresh,'string',vars.notch_L_thresh);
		set(handles.notch_H_thresh,'string',vars.notch_H_thresh);
		set(handles.notch_filter,'Value',vars.notch_filter);
	catch
		disp('corr filter / notch settings');
	end

	try
		if vars.velrect(1,3)~=0 && vars.velrect(1,4)~=0
			put('velrect', vars.velrect);
			update_velocity_limits_information
		end
	catch
	end

	try
		set(handles.realdist, 'String',vars.realdist_string);
		set(handles.time_inp, 'String',vars.time_inp_string);

		if isempty(vars.pointscali)==0
			handles=gethand;
			calu=retr('calu');calv=retr('calv');
			calxy=retr('calxy');
			if isfield(vars,'offset_x_true') == 1
				offset_x_true = retr('offset_x_true');
			else
				offset_x_true=0;
			end
			if isfield(vars,'offset_y_true') == 1
				offset_y_true = retr('offset_y_true');
			else
				offset_y_true=0;
			end
			set(handles.calidisp, 'string', ['1 px = ' num2str(round(calxy*100000)/100000) ' m' sprintf('\n') '1 px/frame = ' num2str(round(calu*100000)/100000) ' m/s' sprintf('\n') 'x offset: ' round(num2str(offset_x_true)*1000)/1000 ' m' sprintf('\n') 'y offset: ' round(num2str(offset_y_true)*1000)/1000 ' m'],  'backgroundcolor', [0.5 1 0.5]);
		end
	catch
		disp('...')
	end

	try
		if ~isempty(vars.bg_img_A)
			set(handles.bg_subtract,'Value',1);
		else
			set(handles.bg_subtract,'Value',0);
		end
	catch
		disp('Could not set bg checkbox')
	end

	%neu v2.52
	try
		set (handles.repeat_last,'Value',vars.repeat_last);
		set(handles.edit52x,'String',vars.repeat_last_thresh);
		repeat_last_Callback
	catch
		disp('repeat_last didnt work4')
	end


	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	put('xzoomlimit', []);
	put('yzoomlimit', []);
	sliderdisp
	try
		if retr('parallel')==1
			modestr=' (parallel)';
		else
			modestr=' (serial)';
		end
		set(getappdata(0,'hgui'), 'Name',['PIVlab ' retr('PIVver')  modestr '   [Path: ' vars.pathname ']']) %for people like me that always forget what dataset they are currently working on...
	catch
	end
	zoom reset
	try
		set (handles.filenamebox, 'string', vars.filename);
	catch
	end
end


function save_only_one_Callback(~, ~, ~)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
set(handles.firstframe,'string',int2str(currentframe));
set(handles.lastframe,'string',int2str(currentframe));
put('only_single_frame',1);
saveavi_Callback

function saveavi_Callback(~, ~, ~)
only_single_frame=retr('only_single_frame');
handles=gethand;
filepath=retr('filepath');
if only_single_frame==1
	startframe=str2num(get(handles.firstframe,'string'));
	endframe=str2num(get(handles.lastframe,'string'));
	%formattype=2; %single frame --> only jpg
	%set (handles.jpgfilesave, 'value',1)
	%set (handles.avifilesave, 'value',0)
	drawnow;
else
	set(handles.fileselector, 'value',1)
	startframe=str2num(get(handles.firstframe,'string'));
	if startframe <1
		startframe=1;
	elseif startframe>size(filepath,1)/2
		startframe=size(filepath,1)/2;
	end
	set(handles.firstframe,'string',int2str(startframe));
	endframe=str2num(get(handles.lastframe,'string'));
	if endframe <startframe
		endframe=startframe;
	elseif endframe>size(filepath,1)/2
		endframe=size(filepath,1)/2;
	end
	set(handles.lastframe,'string',int2str(endframe));
end
if get (handles.avifilesave, 'value')==1
	formattype=1;
end
if get (handles.jpgfilesave, 'value')==1
	formattype=2;
end
if get (handles.bmpfilesave, 'value')==1
	formattype=3;
end
if get (handles.epsfilesave, 'value')==1
	formattype=4;
end
if get (handles.pdffilesave, 'value')==1
	formattype=5;
end

put('only_single_frame',0);

p8wasvisible=retr('p8wasvisible');
if p8wasvisible==1
	switchui('multip08');
	sliderdisp
end
imgsavepath=retr('imgsavepath');
if isempty(imgsavepath)
	imgsavepath=retr('pathname');
end

if formattype==1
	[filename, pathname] = uiputfile({ '*.avi','movie (*.avi)'}, 'Save movie as',fullfile(imgsavepath, 'PIVlab_out'));
	if isequal(filename,0) || isequal(pathname,0)
		return
	end
	put('imgsavepath',pathname );
	compr=get(handles.usecompr,'value');


	if verLessThan('matlab','8.4')
		if compr==0
			compr='none';
		else
			compr='cinepak';
		end
		aviobj = avifile(fullfile(pathname,filename),'compression',compr,'quality', 100, 'fps', str2double(get(handles.fps_setting,'string'))); %#ok<*DAVIFL>
	else
		if compr==0
			compr='Uncompressed AVI';
		else
			compr='Motion JPEG AVI';
		end
		aviobj = VideoWriter(fullfile(pathname,filename),compr);
		aviobj.FrameRate = str2double(get(handles.fps_setting,'string'));
		open(aviobj);
	end

	for i=startframe:endframe
		set(handles.fileselector, 'value',i)
		sliderdisp
		hgca=gca;
		colo=get(gcf, 'colormap');
		axes_units = get(hgca,'Units');
		axes_pos = get(hgca,'Position');
		newFig=figure('visible', 'off');
		set(newFig,'visible', 'off');
		set(newFig,'Units',axes_units);
		set(newFig,'Position',[15 5 axes_pos(3)+30 axes_pos(4)+10]);
		axesObject2=copyobj(hgca,newFig);
		set(axesObject2,'Units',axes_units);
		set(axesObject2,'Position',[15 5 axes_pos(3) axes_pos(4)]);

		colormap(colo);

		if get(handles.displ_colorbar,'value')==1
			name=get(handles.derivchoice,'string');
			posichoice = get(handles.colorbarpos,'String');
			colochoice=get(handles.colorbarcolor,'String');
			coloobj=colorbar(posichoice{get(handles.colorbarpos,'Value')},'FontWeight','bold','Fontsize',12,'color',colochoice{get(handles.colorbarcolor,'Value')},'HitTest','off');

			set(axesObject2,'ydir','reverse')
			set(axesObject2,'Clipping','on')

			if strcmp(posichoice{get(handles.colorbarpos,'Value')},'East')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'West')==1
				set(coloobj,'YTickLabel',num2str(get(coloobj,'YTick')','%5.5g'))
				ylabel(coloobj,name{retr('displaywhat')},'fontsize',9,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
			end
			if strcmp(posichoice{get(handles.colorbarpos,'Value')},'North')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'South')==1
				set(coloobj,'XTickLabel',num2str(get(coloobj,'XTick')','%5.5g'))
				xlabel(coloobj,name{retr('displaywhat')},'fontsize',11,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
			end
		end
		delete(findobj('tag','smoothhint'));
		F=getframe(axesObject2);
		close(newFig)
		if verLessThan('matlab','8.4')
			aviobj = addframe(aviobj,F);
		else
			writeVideo(aviobj,F);
		end
	end
	if verLessThan('matlab','8.4')
		aviobj = close(aviobj);
	else
		close(aviobj);
	end
elseif formattype ==2 || formattype==3 || formattype==4 || formattype==5
	if formattype==2
		[filename, pathname] = uiputfile({ '*.jpg','images (*.jpg)'}, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));
	elseif formattype==3
		[filename, pathname] = uiputfile({ '*.bmp','images (*.bmp)'}, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));
	elseif formattype==4
		[filename, pathname] = uiputfile({ '*.eps','images (*.eps)'}, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));
	elseif formattype==5
		[filename, pathname] = uiputfile({ '*.pdf','PostScript (*.pdf)'}, 'Save images as',fullfile(imgsavepath, 'PIVlab_out'));
	end
	if isequal(filename,0) || isequal(pathname,0)
		return
	end
	put('imgsavepath',pathname );
	if formattype==2 || formattype==3
		reso=inputdlg(['Please enter scale factor' sprintf('\n') '(1 = render image at same size as currently displayed)'],'Specify resolution',1,{'1'});
		[reso, status] = str2num(reso{1});  % Use curly bracket for subscript
		if ~status
			reso=1;
		end
	end

	for i=startframe:endframe
		set(handles.fileselector, 'value',i)
		sliderdisp
		hgca=gca;
		colo=get(gcf, 'colormap');
		axes_units = get(hgca,'Units');
		axes_pos = get(hgca,'Position');
		aspect=axes_pos(3)/axes_pos(4);
		newFig=figure;
		set(newFig,'visible', 'off');
		set(newFig,'Units',axes_units);
		set(newFig,'Position',[15 5 axes_pos(3)+30 axes_pos(4)+10]);
		axesObject2=copyobj(hgca,newFig);
		set(axesObject2,'Units',axes_units);
		set(axesObject2,'Position',[15 5 axes_pos(3) axes_pos(4)]);
		colormap(colo);
		if get(handles.displ_colorbar,'value')==1
			name=get(handles.derivchoice,'string');
			posichoice = get(handles.colorbarpos,'String');
			colochoice=get(handles.colorbarcolor,'String');
			coloobj=colorbar(posichoice{get(handles.colorbarpos,'Value')},'FontWeight','bold','Fontsize',12,'color',colochoice{get(handles.colorbarcolor,'Value')},'HitTest','off');
			if strcmp(posichoice{get(handles.colorbarpos,'Value')},'East')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'West')==1
				axis image
				set(coloobj,'YTickLabel',num2str(get(coloobj,'YTick')','%5.5g'))
				ylabel(coloobj,name{retr('displaywhat')},'fontsize',9,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
			end
			if strcmp(posichoice{get(handles.colorbarpos,'Value')},'North')==1 | strcmp(posichoice{get(handles.colorbarpos,'Value')},'South')==1
				axis image
				set(coloobj,'XTickLabel',num2str(get(coloobj,'XTick')','%5.5g'))
				xlabel(coloobj,name{retr('displaywhat')},'fontsize',11,'fontweight','bold','color',colochoice{get(handles.colorbarcolor,'Value')});
			end
		end
		delete(findobj('tag','smoothhint'));
		[Dir, Name, Ext] = fileparts(filename);
		newfilename=[Name sprintf('_%03d',i) Ext];
		drawnow
		if formattype==2 || formattype==3
			exportfig(newFig,fullfile(pathname,newfilename),'height',3,'color','rgb','format','bmp','resolution',96*reso,'FontMode','scaled','FontSizeMin',16);
		elseif formattype ==4
			exportfig(newFig,fullfile(pathname,newfilename),'preview','tiff','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16);
		elseif formattype==5
			f = gcf;
			a = axesObject2; %gca;
			set(a,'LooseInset',get(a,'TightInset'))
			set(f,'Units','inches');
			pos = get(f,'Position');
			set(f,'PaperPositionMode','auto','PaperUnits','inches','PaperPosition',[0,0,pos(3),pos(4)],'PaperSize',[pos(3), pos(4)])
			exportfig(newFig,fullfile(pathname,newfilename),'format','pdf','preview','tiff','color','rgb','linemode','scaled','FontMode','scaled','FontSizeMin',16);

		end
		close(newFig)
		if formattype==2
			autocrop(fullfile(pathname,newfilename),1);
		elseif formattype==3
			autocrop(fullfile(pathname,newfilename),0);
		end
	end
end

function extraction_choice_Callback(hObject, ~, ~)
if get(hObject, 'value') ~= 11
	handles=gethand;
	if get(handles.draw_what, 'value')==3
		set(handles.draw_what, 'value', 1)
	end
end

function draw_what_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject, 'value') == 3
	handles=gethand;
	set (handles.extraction_choice, 'value', 11);
	set (handles.extraction_choice, 'enable', 'off');
else
	set (handles.extraction_choice, 'enable', 'on');
end

function check_comma(who)
boxcontent=get(who,'String');% returns contents of time_inp as text
s = regexprep(boxcontent, ',', '.');
set(who,'String',s);

function draw_area_Callback(~, ~, ~)
%noch probleme wenn erster frame leer...
%dann geht er sofort zu datei asuwahl...
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');

%NEU
if get(handles.extractareaall, 'value')==0
	startfr=currentframe;
	endfr=currentframe;
else
	%sollte erstes element sein mit inhalt...
	for findcontent=size(resultslist,2):-1:1
		if numel(resultslist{1,findcontent}) > 0
			startfr=findcontent;
		end
	end

	endfr=size(resultslist,2);
end
selected=0;
areaoperation=get(handles.areatype, 'value');
toolsavailable(0)
for i=startfr:endfr
	set(handles.fileselector, 'value',i)
	%sliderdisp
	currentframe=floor(get(handles.fileselector, 'value'));

	if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
		if areaoperation==1
			%area mean value
			sliderdisp
			filepath=retr('filepath');
			x=resultslist{1,currentframe};
			extractwhat=get(handles.area_para_select,'Value');
			if extractwhat==9 || extractwhat==10
				derivative_calc(currentframe,extractwhat+2,0);
			else
				derivative_calc(currentframe,extractwhat+1,0);
			end
			derived=retr('derived');
			[currentimage,~]=get_img(2*currentframe-1);
			sizeold=size(currentimage,1);
			sizenew=size(x,1);

			%{
            extractwhat9 ist vectorangle
            extractwhat10 ist correlation_map
            
            
            derived 9 ist LIC
            derived10 ist vectorangle
            derived11 ist correlation map
			%}

			if extractwhat==9 || extractwhat==10
				maptoget=derived{extractwhat+1,currentframe};
			else
				maptoget=derived{extractwhat,currentframe};
			end
			maptoget=rescale_maps_nan(maptoget,0);
			if selected==0
				[BW,ximask,yimask]=roipoly;
			end
			if isempty(BW)
			else
				delete(findobj('tag','areaint'));
				delete(findobj('tag', 'extractline'))
				delete(findobj('tag', 'extractpoint'))
				numcells=0;
				summe=0;
				for i=1:size(BW,1) %#ok<*FXSET>
					for j=1:size(BW,2)
						if BW(i,j)==1
							if ~isnan(maptoget(i,j))
								summe=summe+maptoget(i,j);
								numcells=numcells+1;
							end
						end
					end
				end
				average=summe/numcells;
				hold on;
				plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
				plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
				hold off;
				%get units
				unitpar=get(handles.area_para_select,'string');
				unitpar=unitpar{get(handles.area_para_select,'value')};
				unitpar=unitpar(strfind(unitpar,'[')+1:end-1);


				text(min(ximask),mean(yimask), ['area mean value = ' num2str(average) ' [' unitpar ']'], 'BackgroundColor', 'w','tag','areaint');
				areaoutput=average;
				varis='[mean]';
			end
		elseif areaoperation==2
			%area integral
			sliderdisp
			filepath=retr('filepath');
			x=resultslist{1,currentframe};
			extractwhat=get(handles.area_para_select,'Value');
			if extractwhat==9 || extractwhat==10
				derivative_calc(currentframe,extractwhat+2,0);
			else
				derivative_calc(currentframe,extractwhat+1,0);
			end
			derived=retr('derived');
			if extractwhat==9 || extractwhat==10
				maptoget=derived{extractwhat+1,currentframe};
			else
				maptoget=derived{extractwhat,currentframe};
			end
			maptoget=rescale_maps_nan(maptoget,0);

			calxy=retr('calxy');
			[currentimage,~]=get_img(2*currentframe-1);
			sizeold=size(currentimage,1);
			sizenew=size(x,1);
			if selected==0
				[BW,ximask,yimask]=roipoly; %select in currently displayed image
			end
			if isempty(BW)
			else
				delete(findobj('tag','areaint'));
				delete(findobj('tag', 'extractline'))
				delete(findobj('tag', 'extractpoint'))
				celllength=1*calxy; %size of one pixel
				cellarea=celllength^2; %area of one cell
				integral=0;
				for i=1:size(BW,1)
					for j=1:size(BW,2)
						if BW(i,j)==1
							if ~isnan(maptoget(i,j)) %do not include nans and nan area in integral.
								integral=integral+cellarea*maptoget(i,j);
							end
						end
					end
				end
				hold on;
				plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
				plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
				hold off;

				%get units
				if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
					distunit='px^2';
				else
					distunit='m^2';
				end

				unitpar=get(handles.area_para_select,'string');
				unitpar=unitpar{get(handles.area_para_select,'value')};
				unitpar=unitpar(strfind(unitpar,'[')+1:end-1);


				text(min(ximask),mean(yimask), ['area integral = ' num2str(integral) ' [' unitpar '*' distunit ']'], 'BackgroundColor', 'w','tag','areaint');
				areaoutput=integral;
				varis='[integral]';
			end
		elseif areaoperation==3
			% area only
			sliderdisp
			filepath=retr('filepath');
			[currentimage,~]=get_img(2*currentframe-1);
			x=resultslist{1,currentframe};
			sizeold=size(currentimage,1);
			sizenew=size(x,1);
			if selected==0
				[BW,ximask,yimask]=roipoly;
			end
			if isempty(BW)
			else
				delete(findobj('tag','areaint'));
				delete(findobj('tag', 'extractline'))
				delete(findobj('tag', 'extractpoint'))
				calxy=retr('calxy');
				celllength=1*calxy;
				cellarea=celllength^2;
				summe=0;
				for i=1:size(BW,1)
					for j=1:size(BW,2)
						if BW(i,j)==1
							summe=summe+cellarea;
						end
					end
				end
				hold on;
				plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
				plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
				hold off;

				%get units
				if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
					distunit='px^2';
				else
					distunit='m^2';
				end


				text(min(ximask),mean(yimask), ['area = ' num2str(summe) ' [' distunit ']'], 'BackgroundColor', 'w','tag','areaint');
				areaoutput=summe;
				varis='[area]';
			end
		elseif areaoperation==4
			%area series
			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
				x=resultslist{1,currentframe};
				y=resultslist{2,currentframe};
				if size(resultslist,1)>6 %filtered exists
					if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
						u=resultslist{10,currentframe};
						v=resultslist{11,currentframe};
					else
						u=resultslist{7,currentframe};
						if size(u,1)>1
							v=resultslist{8,currentframe};
						else
							u=resultslist{3,currentframe};
							v=resultslist{4,currentframe};
						end
					end
				else
					u=resultslist{3,currentframe};
					v=resultslist{4,currentframe};
				end
				calu=retr('calu');calv=retr('calv');
				u=u*calu-retr('subtr_u');
				v=v*calv-retr('subtr_v');
				calxy=retr('calxy');

				extractwhat=get(handles.area_para_select,'Value');
				if extractwhat==9 || extractwhat==10
					derivative_calc(currentframe,extractwhat+2,0);
				else
					derivative_calc(currentframe,extractwhat+1,0);
				end
				derived=retr('derived');

				if extractwhat==9 || extractwhat==10
					currentimage=derived{extractwhat+1,currentframe};
				else
					currentimage=derived{extractwhat,currentframe};
				end
				currentimage=rescale_maps_nan(currentimage,0);
				hgui=getappdata(0,'hgui');
				figure(hgui);
				sliderdisp

				delete(findobj('tag','vortarea'));

				%draw ellipse
				if selected==0
					for i=1:5
						[xellip(i),yellip(i),but] = ginput(1);
						if but~=1
							break
						end
						hold on;
						plot (xellip(i),yellip(i),'w*')
						hold off;
						if i==3
							line(xellip(2:3),yellip(2:3))
						end
						if i==5
							line(xellip(4:5),yellip(4:5))
						end
					end
				end
				if size(xellip,2)==5
					%click1=centre of vortical structure
					%click2=top of vortical structure
					%click3=bottom of vortical structure
					%click4=left of vortical structure
					%click5=right of vortical structure
					x0=(mean(xellip)+xellip(1))/2;
					y0=(mean(yellip)+yellip(1))/2;
					if xellip(2)<xellip(3)
						ang=acos((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)))-pi/2;
					else
						ang=asin((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)));
					end
					rb=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
					ra=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;
					ra=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
					rb=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;

					celllength=1*calxy;
					%celllength=(x(1,2)-x(1,1))*calxy; %size of one cell
					cellarea=celllength^2; %area of one cell
					integralindex=0;

					if get(handles.usethreshold,'value')==1
						%sign=currentimage(round(yellip(1)),round(xellip(1)));
						condition=get(handles.smallerlarger, 'value'); %1 is larger, 2 is smaller
						thresholdareavalue=str2num(get(handles.thresholdarea, 'string'));

						if condition==1
							currentimage(currentimage>thresholdareavalue)=nan;
						else
							currentimage(currentimage<thresholdareavalue)=nan;
						end
						%{
                    %redraw map to show excluded areas
                    [xhelper,yhelper]=meshgrid(1:size(u,2),1:size(u,1));
                    areaincluded=ones(size(u));
                    areaincluded(isnan(currentimage)==1)=0;
                    imagesc(currentimage);
                    axis image
                    hold on;
                    quiver(xhelper(areaincluded==1),yhelper(areaincluded==1),u(areaincluded==1),v(areaincluded==1),'k','linewidth',str2double(get(handles.vecwidth,'string')))
                    scatter(xhelper(areaincluded==0),yhelper(areaincluded==0),'rx')
                    hold off;
						%}
					end
					increasefactor=str2num(get(handles.radiusincrease,'string'))/100;
					if ra<rb
						minimumrad=ra;
					else
						minimumrad=rb;
					end
					%for incr = -(minimumrad)/1.5 :0.5: (ra+rb)/2*increasefactor
					for incr = -(minimumrad)/1.5 :5: (ra+rb)/2*increasefactor
						integralindex=integralindex+1;
						[outputx, outputy]=ellipse(ra+incr,rb+incr,ang,x0,y0,'w');
						%BW = roipoly(u,outputx,outputy);
						BW = roipoly(currentimage,outputx,outputy);
						ra_all(integralindex)=ra+incr;
						rb_all(integralindex)=rb+incr;

						integral=0;
						%for i=1:size(u,1)
						for i=1:size(currentimage,1)
							%for j=1:size(u,2)
							for j=1:size(currentimage,2)
								if BW(i,j)==1
									if ~isnan(currentimage(i,j))
										integral=integral+cellarea*currentimage(i,j);
									end
								end
							end
						end
						integralseries(integralindex)=integral;
					end
					put('ra',ra_all);
					put('rb',rb_all)
					put('ang',ang)
					put('x0',x0)
					put('y0',y0)
					h2=figure;
					%plot(integralseries)
					set(h2, 'tag', 'vortarea');

					plot (1:size(integralseries,2), integralseries);
					hold on;
					scattergroup1=scatter(1:size(integralseries,2), integralseries, 80, 'ko');
					hold off;
					if verLessThan('matlab','8.4')
						set(scattergroup1, 'ButtonDownFcn', @hitcircle2, 'hittestarea', 'off');
					else
						% >R2014a
						set(scattergroup1, 'ButtonDownFcn', @hitcircle2, 'pickableparts', 'visible');
					end

					title('Click the points of the graph to highlight it''s corresponding circle.')
					put('integralseries',integralseries);
					put ('hellipse',h2);
					screensize=get( 0, 'ScreenSize' );
					rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
					set(h2,'position', rect);

					extractwhat=get(handles.area_para_select,'Value');
					current=get(handles.area_para_select,'string');
					current=current{extractwhat};
					set(h2,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ' area integral series, frame ' num2str(currentframe)]);
					set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
					xlabel('Ellipse series nr.');

					if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
						units='px^2';
					else
						units='m^2';
					end

					current_2=current(1:strfind(current, '[')-1);
					current_3=current(strfind(current, '[')+1:end-1);


					ylabel([current_2 ' area integral [' current_3 '*' units ']']);
					areaoutput=integralseries;
					varis='[integral, starting at ellipse with smallest radius]';
				end
			end
		elseif areaoperation==5
			%weighted centroid
			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
				x=resultslist{1,currentframe};
				y=resultslist{2,currentframe};
				if size(resultslist,1)>6 %filtered exists
					if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
						u=resultslist{10,currentframe};
						v=resultslist{11,currentframe};
					else
						u=resultslist{7,currentframe};
						if size(u,1)>1
							v=resultslist{8,currentframe};
						else
							u=resultslist{3,currentframe};
							v=resultslist{4,currentframe};
						end
					end
				else
					u=resultslist{3,currentframe};
					v=resultslist{4,currentframe};
				end
				calu=retr('calu');calv=retr('calv');
				u_orig=u;
				v_orig=v;
				u=u*calu-retr('subtr_u');
				v=v*calv-retr('subtr_v');
				calxy=retr('calxy');
				extractwhat=get(handles.area_para_select,'Value');
				if extractwhat==9 || extractwhat==10
					derivative_calc(currentframe,extractwhat+2,0);
				else
					derivative_calc(currentframe,extractwhat+1,0);
				end

				derived=retr('derived');

				if extractwhat==9 || extractwhat==10
					currentimage=derived{extractwhat+1,currentframe};
				else
					currentimage=derived{extractwhat,currentframe};
				end

				delete(findobj('tag','vortarea'));
				%keyboard
				imagesc(currentimage);
				axis image
				hold on;
				quiver(u_orig-(retr('subtr_u')/retr('calu')),v_orig-(retr('subtr_v')/retr('calv')),'k','linewidth',str2double(get(handles.vecwidth,'string')))
				hold off;

				avail_maps=get(handles.colormap_choice,'string');
				selected_index=get(handles.colormap_choice,'value');
				if selected_index == 4 %HochschuleBremen map
					load hsbmap.mat;
					colormap(hsb);
				elseif selected_index== 1 %rainbow
					%load rainbow.mat;
					colormap (parula);
				else
					colormap(avail_maps{selected_index});
				end
				if selected==0
					[BW,ximask,yimask]=roipoly;
				end
				if isempty(BW)
				else

					delete(findobj('tag', 'extractline'));
					line(ximask,yimask,'tag', 'extractline');
					[rows,cols] = size(currentimage);

					x = ones(rows,1)*[1:cols];
					y = [1:rows]'*ones(1,cols);
					area=0;
					meanx=0;
					meany=0;
					for i=1:size(currentimage,1)
						for j=1:size(currentimage,2)
							if BW(i,j)==1
								area=area+double(currentimage(i,j));%sum image intesity
								meanx=meanx+x(i,j)*double(currentimage(i,j));%sum position*intensity
								meany=meany+y(i,j)*double(currentimage(i,j));
							end
						end
					end
					meanx=meanx/area;%*(sizeold/sizenew)
					meany=meany/area;%*(sizeold/sizenew)
					hold on; plot(meanx,meany,'w*','markersize',20,'tag', 'extractline');hold off;
					xecht=resultslist{1,currentframe};
					yecht=resultslist{2,currentframe};
					step=(xecht(1,2)-xecht(1,1))*calxy;
					%+x(1,1)
					[xecht_cal,yecht_cal]=calibrate_xy(xecht(1,1),yecht(1,1));
					areaoutput=[xecht_cal+(meanx-1)*step yecht_cal+(meany-1)*step];

					if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
						un=' px';
					else
						un=' m';
					end
					textposix=x(1,round(size(x,2)/4));
					textposiy=y(round(size(y,1)/4),1);
					text(textposix, textposiy,  ['x =' num2str(xecht_cal+(meanx-1)*step) un sprintf('\n') 'y =' num2str(yecht_cal+(meany-1)*step) un], 'margin', 0.01, 'fontsize', 10, 'color','w','fontweight','bold','BackgroundColor', [0 0 0],'verticalalignment','top','horizontalalignment','left');

					varis='[x coordinate, y coordinate]';
				end
			end
		elseif areaoperation==6
			%mean flow direction
			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
				x=resultslist{1,currentframe};
				y=resultslist{2,currentframe};
				if size(resultslist,1)>6 %filtered exists
					if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
						u=resultslist{10,currentframe};
						v=resultslist{11,currentframe};
					else
						u=resultslist{7,currentframe};
						if size(u,1)>1
							v=resultslist{8,currentframe};
						else
							u=resultslist{3,currentframe};
							v=resultslist{4,currentframe};
						end
					end
				else
					u=resultslist{3,currentframe};
					v=resultslist{4,currentframe};
				end
				sliderdisp
				calu=retr('calu');calv=retr('calv');
				u=u*calu-retr('subtr_u');
				v=v*calv-retr('subtr_v');
				calxy=retr('calxy');
				delete(findobj('tag','vortarea'));
				filepath=retr('filepath');
				x=resultslist{1,currentframe};
				y=resultslist{2,currentframe};
				if selected==0
					[BW,ximask,yimask]=roipoly;
				end
				if isempty(BW)
				else
					delete(findobj('tag', 'extractline'));
					line(ximask,yimask,'tag', 'extractline');
					umean=0;
					vmean=0;
					uamount=0;
					u=rescale_maps_nan(u,0);
					v=rescale_maps_nan(v,0);
					for i=1:size(u,1)
						for j=1:size(u,2)
							if BW(i,j)==1
								if ~isnan(u(i,j)) && ~isnan(v(i,j))
									umean=umean+u(i,j);
									vmean=vmean+v(i,j);
									uamount=uamount+1;
								end
							end
						end
					end
					umean=umean/uamount;
					vmean=vmean/uamount;
					veclength=(x(1,2)-x(1,1))*6;
					if vmean/calv<=0
						angle=-atan2(vmean/calv,umean/calu)*180/pi; %divided by calibration to remove sign resulting from calibration. because the angle should not depend on the coordinate system.
					else
						angle=360-atan2(vmean/calv,umean/calu)*180/pi;
					end
					magg=sqrt(umean^2+vmean^2);
					areaoutput=[magg angle];
					varis='[magnitude, angle in degrees, 0 = right, 90 = up, 180 = left, 270 = down, 360 = right]';

					hold on;quiver(mean2(ximask), mean2(yimask), (umean/calu)/sqrt((umean/calu)^2+(vmean/calv)^2)*veclength,(vmean/calv)/sqrt((umean/calu)^2+(vmean/calv)^2)*veclength,'r','autoscale','off', 'autoscalefactor', 100, 'linewidth',2,'MaxHeadSize',3,'tag', 'extractline');hold off;

					if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
						un=' px/frame';
					else
						un=' m/s';
					end
					textposix=x(1,round(size(x,2)/4));
					textposiy=y(round(size(y,1)/4),1);
					text(textposix, textposiy, ['angle=' num2str(angle) '�' sprintf('\n') 'magnitude=' num2str(magg) un], 'margin', 0.01, 'fontsize', 10, 'color','w','fontweight','bold','BackgroundColor', [0 0 0],'verticalalignment','top','horizontalalignment','left');
				end
			end
		end %areaoperation
	end
	if get(handles.savearea,'Value')==1
		%nur wenn man es auch speichern will...
		if selected==0
			switch areaoperation
				case 1
					whatoperation = 'mean_value';
				case 2
					whatoperation = 'integral';
				case 3
					whatoperation = 'area';
				case 4
					whatoperation = 'integral_series';
				case 5
					whatoperation = 'weighted centroid';
				case 6
					whatoperation = 'mean_flow';
			end
			par = get(handles.area_para_select,'string');
			par=par{get(handles.area_para_select,'Value')};
			if areaoperation==3 || areaoperation==6
				par=[];
			end
			imgsavepath=retr('imgsavepath');
			if isempty(imgsavepath)
				imgsavepath=retr('pathname');
			end

			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0

				part1= par(1:strfind(par,'/')-1) ;
				part2= par(strfind(par,'/')+1:end);
				if isempty(part1)==1
					parED=par;
				else
					parED=[part1 ' per ' part2];
				end

				[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' whatoperation '_' parED '.txt'])); %framenummer in dateiname
				selected=1;
				if isequal(FileName,0) | isequal(PathName,0)
					break
				else
					put ('imgsavepath',PathName);
					fid = fopen(fullfile(PathName,FileName), 'w');
					fprintf(fid, ['Frame Nr.,' par ': ' whatoperation ' ' varis '\r\n']);
					fclose(fid);
				end
			end
		end
		if isequal(FileName,0) | isequal(PathName,0)
		else
			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
				dlmwrite(fullfile(PathName,FileName), [currentframe areaoutput], '-append', 'delimiter', ',', 'precision', 10, 'newline', 'pc'); %#ok<*DLMWT>
			end
		end
	end
	%areaoutput
end

toolsavailable(1)

function hitcircle2(~,~)
posreal=get(gca,'CurrentPoint');
delete(findobj('tag','circstring'));
pos=round(posreal(1,1));
integralseries=retr('integralseries');
hgui=getappdata(0,'hgui');
h3plot=retr('hellipse');
figure(hgui);
delete(findobj('type', 'line', 'color', 'w')) %delete white ellipses
ra=retr('ra');
rb=retr('rb');
ang=retr('ang');
x0= retr('x0');
y0=retr('y0');

for m=1:size(ra,2)
	ellipse(ra(1,m),rb(1,m),ang,x0,y0,'w');
end
ellipse(ra(1,pos),rb(1,pos),ang,x0,y0,'b');
figure(h3plot);
marksize=linspace(80,80,size(ra,2))';
marksize(pos)=150;
set(gco, 'SizeData', marksize);
%units
handles=gethand;
extractwhat=get(handles.area_para_select,'Value');
current=get(handles.area_para_select,'string');
current=current{extractwhat};
if (retr('calu')==1 || retr('calu')==-1) && retr('calxy')==1
	units='px^2';
else
	units='m^2';
end
current_3=current(strfind(current, '[')+1:end-1);
text(posreal(1,1)+0.25,posreal(2,2),['\leftarrow ' num2str(integralseries(pos)) ' ' current_3 '*' units],'tag','circstring','BackgroundColor', [1 1 1], 'margin', 0.01, 'fontsize', 7, 'HitTest', 'off')

function areatype_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'value')==4
	set(handles.text93, 'visible', 'on')
	set(handles.smallerlarger, 'visible', 'on')
	set(handles.text94, 'visible', 'on')
	set(handles.radiusincrease, 'visible', 'on')
	set(handles.thresholdarea, 'visible', 'on')
	set(handles.usethreshold, 'visible', 'on')
	set(handles.text95, 'visible', 'on')
else
	set(handles.text93, 'visible', 'off')
	set(handles.smallerlarger, 'visible', 'off')
	set(handles.text94, 'visible', 'off')
	set(handles.radiusincrease, 'visible', 'off')
	set(handles.thresholdarea, 'visible', 'off')
	set(handles.usethreshold, 'visible', 'off')
	set(handles.text95, 'visible', 'off')
end
if get(hObject,'value')==3 || get(hObject,'value')==6
	set(handles.area_para_select,'visible','off');
	set(handles.text89,'visible','off');
else
	set(handles.area_para_select,'visible','on');
	set(handles.text89,'visible','on');
end

function flow_sim_Callback(hObject, ~, ~)
handles=gethand;
contents = get(hObject,'value');
set(handles.rankinepanel,'visible','off');
set(handles.shiftpanel,'visible','off');
set(handles.rotationpanel,'visible','off');
set(handles.oseenpanel,'visible','off');
if contents==1
	set(handles.rankinepanel,'visible','on');
elseif contents==2
	set(handles.oseenpanel,'visible','on');
elseif contents==3
	set(handles.shiftpanel,'visible','on');
elseif contents==4
	set(handles.rotationpanel,'visible','on');
end

function singledoublerankine_Callback(hObject, ~, ~)
handles=gethand;
contents = get(hObject,'value');
set(handles.rankx1,'visible','off');
set(handles.rankx2,'visible','off');
set(handles.ranky1,'visible','off');
set(handles.ranky2,'visible','off');
set(handles.text102,'visible','off');
set(handles.text103,'visible','off');
set(handles.text104,'visible','off');
if contents==1
	set(handles.rankx1,'visible','on');
	set(handles.ranky1,'visible','on');
elseif contents==2
	set(handles.rankx1,'visible','on');
	set(handles.ranky1,'visible','on');
	set(handles.rankx2,'visible','on');
	set(handles.ranky2,'visible','on');
	set(handles.text102,'visible','on');
	set(handles.text103,'visible','on');
	set(handles.text104,'visible','on');
end

function singledoubleoseen_Callback(hObject, ~, ~)
handles=gethand;
contents = get(hObject,'value');
set(handles.oseenx1,'visible','off');
set(handles.oseenx2,'visible','off');
set(handles.oseeny1,'visible','off');
set(handles.oseeny2,'visible','off');
set(handles.text110,'visible','off');
set(handles.text111,'visible','off');
set(handles.text112,'visible','off');
if contents==1
	set(handles.oseenx1,'visible','on');
	set(handles.oseeny1,'visible','on');
elseif contents==2
	set(handles.oseenx1,'visible','on');
	set(handles.oseeny1,'visible','on');
	set(handles.oseenx2,'visible','on');
	set(handles.oseeny2,'visible','on');
	set(handles.text110,'visible','on');
	set(handles.text111,'visible','on');
	set(handles.text112,'visible','on');
end

function temporal_operation_Callback(~, ~, type)
handles=gethand;
filepath=retr('filepath');
resultslist=retr('resultslist');
if isempty(resultslist)==0
	if size(filepath,1)>0
		sizeerror=0;
		typevectormittel=ones(size(resultslist{1,1}));
		ismean=retr('ismean');
		if isempty(ismean)==1
			ismean=zeros(size(resultslist,2),1);
		end
		str = strrep(get(handles.selectedFramesMean,'string'),'-',':');
		endinside=strfind(str, 'end');
		if isempty(endinside)==0 %#ok<*STREMP>
			str = strrep(get(handles.selectedFramesMean,'string'),'end',num2str(max(find(ismean==0)))); %#ok<MXFND>
		end
		selectionok=1;

		strnum=str2num(str);
		if isempty(strnum)==1 || isempty(strfind(str,'.'))==0 || isempty(strfind(str,';'))==0
			msgbox(['Error in frame selection syntax. Please use the following syntax (examples):' sprintf('\n') '1:3' sprintf('\n') '1,3,7,9' sprintf('\n') '1:3,7,8,9,11:13' ],'Error','error','modal')
			selectionok=0;
		end
		if selectionok==1
			mincount=(min(strnum));
			for count=mincount:size(resultslist,2)
				if size(resultslist,2)>=count && numel(resultslist{1,count})>0
					x=resultslist{1,count};
					y=resultslist{2,count};
					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,count}) > 0 %smoothed exists
							u=resultslist{10,count};
							v=resultslist{11,count};
							typevector=resultslist{9,count};
							if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,count};
							end
						else
							u=resultslist{7,count};
							if size(u,1)>1
								v=resultslist{8,count};
								typevector=resultslist{9,count};
							else %filter was applied for other frames but not for this one
								u=resultslist{3,count};
								v=resultslist{4,count};
								typevector=resultslist{5,count};
							end
						end
					else
						u=resultslist{3,count};
						v=resultslist{4,count};
						typevector=resultslist{5,count};
					end

					%if count==mincount %besser: wenn orgsize nicht existiert
					if exist('originalsizex','var')==0
						originalsizex=size(u,2);
						originalsizey=size(u,1);
					else

						if size(u,2)~=originalsizex || size(u,1)~=originalsizey
							sizeerror=1;
						end
					end
					if ismean(count,1)==0 && sizeerror==0
						umittel(:,:,count)=u;
						vmittel(:,:,count)=v;
					end
					if sizeerror==0
						typevectormittel(:,:,count)=typevector;
					end
				end

			end
			if sizeerror==0
				for i=1:size(strnum,2)
					if size(resultslist,2)>=strnum(i) %dann ok
						x_tmp=resultslist{1,strnum(i)};
						if isempty(x_tmp)==1 %dann nicht ok
							msgbox('Your selected range includes non-analyzed frames.','Error','error','modal')
							selectionok=0;
							break
						end
					else
						msgbox('Your selected range includes non-analyzed frames.','Error','error','modal')
						selectionok=0;
						break
					end
					if size(ismean,1)>=strnum(i)
						if ismean(strnum(i))==1
							msgbox('You must not include frames in your selection that already consist of mean vectors.','Error','error','modal')
							selectionok=0;
							break
						end
					else
						msgbox('Your selected range exceeds the amount of analyzed frames.','Error','error','modal')
						selectionok=0;
						break
					end
				end

				if selectionok==1
					maskiererx=retr('maskiererx');
					maskierery=retr('maskierery');
					if isempty(maskiererx)==1
						maskiererx=cell(1,1);
						maskierery=cell(1,1);
					end
					maskiererx_temp=cell(1,1);
					maskierery_temp=cell(1,1);
					maskiererx_temp=maskiererx(:,1:2:end);
					maskierery_temp=maskierery(:,1:2:end);
					%kopieren in temp "originalmaske", dann alles l철schen was nicht
					%ausgew채hlt. (auf [] setzen)
					% z.B.: maskiererxselected=maskiererx_temp(1,[1:6])
					try
						eval(['maskiererxselected=maskiererx_temp(:,[' str ']);']);
						eval(['maskiereryselected=maskierery_temp(:,[' str ']);']);
					catch
						maskiererxselected=cell(1,1);
						maskiereryselected=cell(1,1);
					end
					newmaskx=cell(0,0);
					for i=1:size(maskiererxselected,1)
						for j=1:size(maskiererxselected,2)
							if numel(maskiererxselected{i,j})~=0
								newmaskx{size(newmaskx,1)+1,1}=maskiererxselected{i,j};
							end
						end
					end
					for i=size(newmaskx,1):-1:2
						if numel(newmaskx{i,1})==numel(newmaskx{i-1,1})
							A=newmaskx{i-1,1};
							B=newmaskx{i,1};
							if mean(A-B)==0
								newmaskx{i,1}={};
							end
						end
					end

					try
						newmaskx(cellfun(@isempty,newmaskx))=[];
					catch
						disp('Problems with old Matlab version... Please update Matlab or unexpected things might happen...')
					end
					newmasky=cell(0,0);
					for i=1:size(maskiereryselected,1)
						for j=1:size(maskiereryselected,2)
							if numel(maskiereryselected{i,j})~=0
								newmasky{size(newmasky,1)+1,1}=maskiereryselected{i,j};
							end
						end
					end
					for i=size(newmasky,1):-1:2
						if numel(newmasky{i,1})==numel(newmasky{i-1,1})
							A=newmasky{i-1,1};
							B=newmasky{i,1};
							if mean(A-B)==0
								newmasky{i,1}={};
							end
						end
					end
					try
						newmasky(cellfun(@isempty,newmasky))=[];
					catch
						disp('Problems with old Matlab version... Please update Matlab or unexpected things might happen...')
					end
					for i=1:min ([size(newmaskx,1) size(newmasky,1)])
						%ans Ende der originalmaske wird eine zusammengesetzte maske
						%aus allen gew채hlten frames geh채ngt.
						maskiererx{i,size(filepath,1)+1}=newmaskx{i,1};
						maskiererx{i,size(filepath,1)+2}=newmaskx{i,1};
						maskierery{i,size(filepath,1)+1}=newmasky{i,1};
						maskierery{i,size(filepath,1)+2}=newmasky{i,1};
					end
					put('maskiererx',maskiererx);
					put('maskierery',maskierery);
					typevectoralle=ones(size(typevector));



					%Hier erst neue matrix erstellen mit ausgew채hlten frames
					%typevectoralle ist ausgabe f체r gui
					%typevectormean ist der mittelwert aller types
					%typevectormittel ist der stapel aus allen typevectors

					eval(['typevectormittelselected=typevectormittel(:,:,[' str ']);']);

					typevectormean=mean(typevectormittelselected,3);  %#ok<USENS>
					%for i=1:size(typevectormittelselected,3)
					for i=1:size(typevectormittelselected,1)
						for j=1:size(typevectormittelselected,2)
							if mean(typevectormittelselected(i,j,:))==0 %#ok<*IDISVAR>
								typevectoralle(i,j)=0;
							end
						end
					end
					%da wo ALLE null sidn auf null setzen.
					%typevectoralle(typevectormittelselected(:,:,i)==0)=0; %maskierte vektoren sollen im Mean maskiert sein
					% end

					typevectoralle(typevectormean>1.5)=2; %if more than 50% of vectors are interpolated, then mark vector in mean as interpolated too.
					resultslist{5,size(filepath,1)/2+1}=typevectoralle;
					resultslist{1,size(filepath,1)/2+1}=x;
					resultslist{2,size(filepath,1)/2+1}=y;

					%hier neue matrix mit ausgew채hlten frames!
					eval(['umittelselected=umittel(:,:,[' str ']);']);
					eval(['vmittelselected=vmittel(:,:,[' str ']);']);
					if type==2
						%standard deviation
						%ROCHE Modifikation
						out_mean_u=nanstd(umittelselected,3); %#ok<*NANSTD,NODEF>
						out_mean_v=nanstd(vmittelselected,3); %#ok<NODEF>
						out_mean_u(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
						out_mean_v(typevectormean>=1.75)=nan;
						resultslist{3,size(filepath,1)/2+1}=out_mean_u;
						resultslist{4,size(filepath,1)/2+1}=out_mean_v;
						%resultslist{3,size(filepath,1)/2+1}=nanstd(umittelselected,3); %#ok<NODEF>
						%resultslist{4,size(filepath,1)/2+1}=nanstd(vmittelselected,3); %#ok<NODEF>
					end

					if type==1
						%ROCHE Modifikation
						out_mean_u=nanmean(umittelselected,3); %#ok<*NANMEAN>
						out_mean_v=nanmean(vmittelselected,3);
						out_mean_u(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
						out_mean_v(typevectormean>=1.75)=nan;
						resultslist{3,size(filepath,1)/2+1}=out_mean_u;
						resultslist{4,size(filepath,1)/2+1}=out_mean_v;
						%resultslist{3,size(filepath,1)/2+1}=nanmean(umittelselected,3);
						%resultslist{4,size(filepath,1)/2+1}=nanmean(vmittelselected,3);
					end

					if type==0
						try
							resultslist{3,size(filepath,1)/2+1}=sum(umittelselected,3,'omitnan');
							resultslist{4,size(filepath,1)/2+1}=sum(vmittelselected,3,'omitnan');
						catch
							umittelselected(isnan(umittelselected))=0;
							vmittelselected(isnan(vmittelselected))=0;
							resultslist{3,size(filepath,1)/2+1}=sum(umittelselected,3);
							resultslist{4,size(filepath,1)/2+1}=sum(vmittelselected,3);
						end
					end

					filepathselected=filepath(1:2:end);
					eval(['filepathselected=filepathselected([' str '],:);']);
					filepath{size(filepath,1)+1,1}=filepathselected{1,1};
					filepath{size(filepath,1)+1,1}=filepathselected{1,1};
					if retr('video_selection_done') == 1
						video_frame_selection=retr('video_frame_selection');
						video_frame_selection(end+1,1)=video_frame_selection(strnum(end)*2);
						video_frame_selection(end+1,1)=video_frame_selection(strnum(end)*2);
						put('video_frame_selection',video_frame_selection);
					end
					filename=retr('filename');
					if type == 2
						filename{size(filename,1)+1,1}=['STDEV of frames ' str];
						filename{size(filename,1)+1,1}=['STDEV of frames ' str];
					end
					if type == 1
						filename{size(filename,1)+1,1}=['MEAN of frames ' str];
						filename{size(filename,1)+1,1}=['MEAN of frames ' str];
					end
					if type == 0
						filename{size(filename,1)+1,1}=['SUM of frames ' str];
						filename{size(filename,1)+1,1}=['SUM of frames ' str];
					end
					ismean(size(resultslist,2),1)=1;
					put('ismean',ismean);

					put ('resultslist', resultslist);
					put ('filepath', filepath);
					put ('filename', filename);
					put ('typevector', typevector);
					sliderrange
					try
						set (handles.fileselector,'value',get (handles.fileselector,'max'));
					catch
					end

					sliderdisp
				end
			else %user tried to average analyses with different sizes
				errordlg('All analyses of one session have to be of the same size and have to be analyzed with identical PIV settings.','Averaging / summing not possible...')
			end
		end
	end
end

function part_am_Callback(hObject, ~, ~)
check_comma(hObject)
function part_size_Callback(hObject, ~, ~)
check_comma(hObject)
function part_var_Callback(hObject, ~, ~)
check_comma(hObject)
function part_noise_Callback(hObject, ~, ~)
check_comma(hObject)
function oseenx1_Callback(hObject, ~, ~)
check_comma(hObject)
function rank_core_Callback(hObject, ~, ~)
check_comma(hObject)
function rank_displ_Callback(hObject, ~, ~)
check_comma(hObject)
function rotationdislacement_Callback(hObject, ~, ~)
check_comma(hObject)
function realdist_Callback(hObject, ~, ~)
check_comma(hObject)
function time_inp_Callback(hObject, ~, ~)
check_comma(hObject)
function subtr_u_Callback(hObject, ~, ~)
check_comma(hObject)
function subtr_v_Callback(hObject, ~, ~)
check_comma(hObject)
function mapscale_min_Callback(hObject, ~, ~)
check_comma(hObject)
function mapscale_max_Callback(hObject, ~, ~)
check_comma(hObject)
function stdev_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function loc_med_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function thresholdarea_Callback(hObject, ~, ~)
check_comma(hObject)
function shiftdisplacement_Callback(hObject, ~, ~)
check_comma(hObject)
function sheetthick_Callback(hObject, ~, ~)
check_comma(hObject)
function ranky1_Callback(hObject, ~, ~)
check_comma(hObject)
function rankx1_Callback(hObject, ~, ~)
check_comma(hObject)
function rankx2_Callback(hObject, ~, ~)
check_comma(hObject)
function ranky2_Callback(hObject, ~, ~)
check_comma(hObject)
function oseen_displ_Callback(hObject, ~, ~)
check_comma(hObject)
function oseenx2_Callback(hObject, ~, ~)
check_comma(hObject)
function oseeny1_Callback(hObject, ~, ~)
check_comma(hObject)
function oseeny2_Callback(hObject, ~, ~)
check_comma(hObject)
function oseen_time_Callback(hObject, ~, ~)
check_comma(hObject)
function part_z_Callback(hObject, ~, ~)
check_comma(hObject)
function vecwidth_Callback(hObject, ~, ~)
check_comma(hObject)
function notch_L_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function notch_H_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function contrast_filter_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function bright_filter_thresh_Callback(hObject, ~, ~)
check_comma(hObject)
function corr_filter_thresh_Callback(hObject, ~, ~)
check_comma(hObject)

function avifilesave_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set (handles.jpgfilesave, 'value', 0);
	set (handles.bmpfilesave, 'value', 0);
	set (handles.epsfilesave, 'value', 0);
	set (handles.pdffilesave, 'value', 0);
	set(handles.usecompr,'enable','on');
	set(handles.fps_setting,'enable','on');
else
	set (handles.avifilesave, 'value', 1);
end

function jpgfilesave_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set (handles.avifilesave, 'value', 0);
	set (handles.bmpfilesave, 'value', 0);
	set (handles.epsfilesave, 'value', 0);
	set (handles.pdffilesave, 'value', 0);
	set(handles.usecompr,'value',0);
	set(handles.usecompr,'enable','off');
	set(handles.fps_setting,'enable','off');

else
	set (handles.jpgfilesave, 'value', 1);
end

function bmpfilesave_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set (handles.avifilesave, 'value', 0);
	set (handles.jpgfilesave, 'value', 0);
	set (handles.epsfilesave, 'value', 0);
	set (handles.pdffilesave, 'value', 0);
	set(handles.usecompr,'value',0);
	set(handles.usecompr,'enable','off');
	set(handles.fps_setting,'enable','off');

else
	set (handles.bmpfilesave, 'value', 1);
end

function pdffilesave_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set (handles.avifilesave, 'value', 0);
	set (handles.jpgfilesave, 'value', 0);
	set (handles.epsfilesave, 'value', 0);
	set (handles.bmpfilesave, 'value', 0);
	set(handles.usecompr,'value',0);
	set(handles.usecompr,'enable','off');
	set(handles.fps_setting,'enable','off');

else
	set (handles.pdffilesave, 'value', 1);
end

function drawstreamlines_Callback(~, ~, ~)
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	toolsavailable(0);
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=retr('ismean');
	if    numel(ismean)>0
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end
	calu=retr('calu');calv=retr('calv');
	ustream=u-(retr('subtr_u')/retr('calu'));
	vstream=v-(retr('subtr_v')/retr('calv'));
	ustream(typevector==0)=nan;
	vstream(typevector==0)=nan;
	calxy=retr('calxy');
	button=1;
	streamlinesX=retr('streamlinesX');
	streamlinesY=  retr('streamlinesY');
	if get(handles.holdstream,'value')==1
		if numel(streamlinesX)>0
			i=size(streamlinesX,2)+1;
			xposition=streamlinesX;
			yposition=streamlinesY;
		else
			i=1;
		end
	else
		i=1;
		put('streamlinesX',[]);
		put('streamlinesY',[]);
		xposition=[];
		yposition=[];
		delete(findobj('tag','streamline'));
	end
	while button == 1
		[rawx,rawy,button] = ginput(1);
		if button~=1
			break
		end
		xposition(i)=rawx;
		yposition(i)=rawy;

		h=streamline(mmstream2(x,y,ustream,vstream,xposition(i),yposition(i),'on'));
		set (h,'tag','streamline');
		i=i+1;
	end
	delete(findobj('tag','streamline'));
	if exist('xposition','var')==1
		h=streamline(mmstream2(x,y,ustream,vstream,xposition,yposition,'on'));
		set (h,'tag','streamline');
		contents = get(handles.streamlcolor,'String');
		set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')})
		put('streamlinesX',xposition);
		put('streamlinesY',yposition);
	end
end
toolsavailable(1);

function deletestreamlines_Callback(~, ~, ~)
put('streamlinesX',[]);
put('streamlinesY',[]);
delete(findobj('tag','streamline'));

function streamrake_Callback(~, ~, ~)
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	toolsavailable(0);
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=retr('ismean');
	if    numel(ismean)>0
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end
	calu=retr('calu');calv=retr('calv');
	ustream=u-(retr('subtr_u')/retr('calu'));
	vstream=v-(retr('subtr_v')/retr('calv'));
	ustream(typevector==0)=nan;
	vstream(typevector==0)=nan;
	calxy=retr('calxy');
	button=1;
	streamlinesX=retr('streamlinesX');
	streamlinesY=  retr('streamlinesY');
	if get(handles.holdstream,'value')==1
		if numel(streamlinesX)>0
			i=size(streamlinesX,2)+1;
			xposition=streamlinesX;
			yposition=streamlinesY;
		else
			i=1;
		end
	else
		i=1;
		put('streamlinesX',[]);
		put('streamlinesY',[]);
		xposition=[];
		yposition=[];
		delete(findobj('tag','streamline'));
	end
	[rawx,rawy,~] = ginput(1);
	hold on; scatter(rawx,rawy,'y*','tag','streammarker');hold off;
	[rawx(2),rawy(2),~] = ginput(1);
	delete(findobj('tag','streammarker'))
	rawx=linspace(rawx(1),rawx(2),str2num(get(handles.streamlamount,'string')));
	rawy=linspace(rawy(1),rawy(2),str2num(get(handles.streamlamount,'string')));

	xposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawx;
	yposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawy;
	h=streamline(mmstream2(x,y,ustream,vstream,xposition(i),yposition(i),'on'));
	set (h,'tag','streamline');
	i=i+1;
end
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	delete(findobj('tag','streamline'));
	h=streamline(mmstream2(x,y,ustream,vstream,xposition,yposition,'on'));
	contents = get(handles.streamlcolor,'String');
	set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
	set (h,'tag','streamline');
	put('streamlinesX',xposition);
	put('streamlinesY',yposition);
end
toolsavailable(1);

function applycolorwidth_Callback(~, ~, ~)
sliderdisp

function putmarkers_Callback(~, ~, ~)
handles=gethand;
button=1;
manmarkersX=retr('manmarkersX');
manmarkersY=retr('manmarkersY');
if get(handles.holdmarkers,'value')==1

	if numel(manmarkersX)>0
		i=size(manmarkersX,2)+1;
		xposition=manmarkersX;
		yposition=manmarkersY;
	else
		i=1;
	end
else
	i=1;
	put('manmarkersX',[]);
	put('manmarkersY',[]);
	xposition=[];
	yposition=[];
	delete(findobj('tag','manualmarker'));
end
hold on;
toolsavailable(0)
while button == 1
	[rawx,rawy,button] = ginput(1);
	if button~=1
		break
	end
	xposition(i)=rawx;
	yposition(i)=rawy;
	plot(xposition(i),yposition(i), 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
	i=i+1;
end
toolsavailable(1)
delete(findobj('tag','manualmarker'));
plot(xposition,yposition, 'o','MarkerEdgeColor','k','MarkerFaceColor',[.2 .2 1], 'MarkerSize',9, 'tag', 'manualmarker');
plot(xposition,yposition, '*','MarkerEdgeColor','w', 'tag', 'manualmarker');
put('manmarkersX',xposition);
put('manmarkersY',yposition);
hold off

function delmarkers_Callback(~, ~, ~)
put('manmarkersX',[]);
put('manmarkersY',[]);
delete(findobj('tag','manualmarker'));

function displmarker_Callback(~, ~, ~)
sliderdisp;

function checkbox26_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value') == 0
	set(handles.edit50,'enable','off')
	set(handles.edit51,'enable','off')
	set(handles.edit52,'enable','off')
	set(handles.checkbox27,'value',0)
	set(handles.checkbox28,'value',0)
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
else
	set(handles.edit50,'enable','on')
	set(handles.repeat_last,'Enable','on')
	set(handles.edit52x,'Enable','on')
end
dispinterrog

function edit50_Callback(hObject, ~, ~)
handles=gethand;
step=str2double(get(hObject,'String'));
set (handles.text126, 'string', int2str(step/2));
dispinterrog

function edit51_Callback(hObject, ~, ~)
handles=gethand;
step=str2double(get(hObject,'String'));
set (handles.text127, 'string', int2str(step/2));
dispinterrog

function edit52x_Callback(hObject, ~, ~)
check_comma(hObject)

function repeat_last_Callback (~,~,~)
handles=gethand;
if get (handles.checkbox26,'Value')==1
	if get(handles.repeat_last,'Value')
		set(handles.edit52x,'Enable','on')
	else
		set(handles.edit52x,'Enable','off')
	end
else
	set(handles.edit52x,'Enable','off')
end

function edit52_Callback(hObject, ~, ~)
handles=gethand;
step=str2double(get(hObject,'String'));
set (handles.text128, 'string', int2str(step/2));
dispinterrog

function extractareaall_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set(handles.savearea,'enable','off');
	set(handles.savearea,'value',1);
else
	set(handles.savearea,'enable','on');
end

function radiusincrease_Callback(hObject, ~, ~)
check_comma(hObject)
val=get(hObject,'string');
if str2double(val)>500
	set(hObject,'string',500);
end
if str2double(val)<0 || isempty(val)==1 || isnan(str2double(val))
	set(hObject,'string',0);
end

function licres_Callback(~,~,~)
handles=gethand;
value=num2str(round(get(handles.licres,'Value')*10)/10);
set(handles.LIChint2,'String',value)

function derivdropdown(hObject, ~, ~)
handles=gethand;
if get(hObject,'value')==10
	set(handles.LIChint1,'visible','on');
	set(handles.LIChint2,'visible','on');
	%set(handles.LIChint3,'visible','on');
	set(handles.licres,'visible','on');
else
	set(handles.LIChint1,'visible','off');
	set(handles.LIChint2,'visible','off');
	%set(handles.LIChint3,'visible','off');
	set(handles.licres,'visible','off');
end

function derivchoice_Callback(hObject, ~, ~)
handles=gethand;
contents = get(hObject,'String');
currstring=contents{get(hObject,'Value')};
currstring=currstring(strfind(currstring,'['):end);
set(handles.text39,'String', ['min ' currstring ':']);
set(handles.text40,'String', ['max ' currstring ':']);
derivdropdown(hObject);

function epsfilesave_Callback(hObject, ~, ~)
handles=gethand;
if get(hObject,'Value')==1
	set (handles.avifilesave, 'value', 0);
	set (handles.jpgfilesave, 'value', 0);
	set (handles.bmpfilesave, 'value', 0);
	set (handles.pdffilesave, 'value', 0);
	set(handles.usecompr,'value',0);
	set(handles.usecompr,'enable','off');
	set(handles.fps_setting,'enable','off');

else
	set (handles.epsfilesave, 'value', 1);
end

function zoomcontext(~,~)
handles=gethand;
setappdata(getappdata(0,'hgui'),'xzoomlimit',[]);
setappdata(getappdata(0,'hgui'),'yzoomlimit',[]);
zoom reset
set(handles.zoomon,'Value',0);
set(handles.panon,'Value',0);
zoom(gca,'off')
pan(gca,'off')

sliderdisp;

function zoomon_Callback(hObject, ~, ~)
hgui=getappdata(0,'hgui');
handles=gethand;
if get(hObject,'Value')==1
	hCMZ = uicontextmenu;
	hZMenu = uimenu('Parent',hCMZ,'Label','Reset Zoom / Pan','Callback',@zoomcontext);
	hZoom=zoom(gcf);
	hZoom.UIContextMenu = hCMZ;
	zoom(gca,'on')
	set(handles.panon,'Value',0);
else
	zoom(gca,'off')
	put('xzoomlimit', get (gca, 'xlim'));
	put('yzoomlimit', get (gca, 'ylim'));

end

function panon_Callback(hObject, ~, ~)

handles=gethand;
if get(hObject,'Value')==1

	hCMP = uicontextmenu;
	hPMenu = uimenu('Parent',hCMP,'Label','Reset Pan / Zoom','Callback',@zoomcontext);
	hPan=pan(gcf);
	hPan.UIContextMenu = hCMP;
	pan(gca,'on')
	set(handles.zoomon,'Value',0);
else
	pan(gca,'off')
	put('xzoomlimit', get (gca, 'xlim'));
	put('yzoomlimit', get (gca, 'ylim'));

end

function paraview_current_Callback(~, ~, ~)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.vtk','Save Paraview binary vtk as...','PIVlab.vtk'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0)
	else
		file_save(currentframe,FileName,PathName,3);
	end
end

function paraview_all_Callback(~, ~, ~)
handles=gethand;
filepath=retr('filepath');
resultslist=retr('resultslist');
[FileName,PathName] = uiputfile('*.vtk','Save Paraview binary vtk as...','PIVlab.vtk'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
	toolsavailable(0)
	for i=1:floor(size(filepath,1)/2)
		%if analysis exists
		if size(resultslist,2)>=i && numel(resultslist{1,i})>0
			[Dir, Name, Ext] = fileparts(FileName);
			FileName_nr=[Name sprintf('_%.4d', i) Ext];
			file_save(i,FileName_nr,PathName,3)
			set (handles.paraview_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
			drawnow;
		end
	end
	toolsavailable(1)
	set (handles.paraview_all, 'string', 'Save all frames');
end

function Website_Callback(~, ~, ~)
try
	web('http://pivlab.blogspot.com','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://PIVlab.blogspot.de')
end

function Man_ROI_Callback
handles=gethand;
try
	x=round(str2num(get(handles.ROI_Man_x,'String')));
	y=round(str2num(get(handles.ROI_Man_y,'String')));
	w=round(str2num(get(handles.ROI_Man_w,'String')));
	h=round(str2num(get(handles.ROI_Man_h,'String')));
catch
end
if isempty(x)== 0 && isempty(y)== 0 && isempty(w)== 0 && isempty(h)== 0 && isnumeric(x) && isnumeric(y) && isnumeric(w) && isnumeric(h)
	roirect(1)=x;
	roirect(2)=y;
	roirect(3)=w;
	roirect(4)=h;

	toggler=retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	filepath=retr('filepath');
	[dummy_image,~]=get_img(selected);
	imagesize(1)=size(dummy_image,1);
	imagesize(2)=size(dummy_image,2);
	if roirect(1)<1
		roirect(1)=1;
	end
	if roirect(2)<1
		roirect(2)=1;
	end
	if roirect(3)>imagesize(2)-roirect(1)
		roirect(3)=imagesize(2)-roirect(1);
	end
	if roirect(4)>imagesize(1)-roirect(2)
		roirect(4)=imagesize(1)-roirect(2);
	end
	put ('roirect',roirect);
	dispROI
	set(handles.roi_hint, 'String', 'ROI active' , 'backgroundcolor', [0.5 1 0.5]);
end

function ROI_Man_x_Callback(~, ~, ~)
Man_ROI_Callback

function ROI_Man_y_Callback(~, ~, ~)
Man_ROI_Callback

function ROI_Man_w_Callback(~, ~, ~)
Man_ROI_Callback

function ROI_Man_h_Callback(~, ~, ~)
Man_ROI_Callback

function howtocite_Callback(~, ~, ~)
PIVlab_citing

function exitpivlab_Callback(~, ~, ~)
close(gcf)

function Forum_Callback(~, ~, ~)
try
	web('http://pivlab.blogspot.de/p/forum.html','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://pivlab.blogspot.de/p/forum.html')
end

function Autolimit_Callback(~, ~, ~)
handles=gethand;
if get(handles.Autolimit, 'value') == 1
	filepath=retr('filepath');
	if size(filepath,1) >1 || retr('video_selection_done') == 1
		toggler=retr('toggler');
		filepath=retr('filepath');
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		[img,~]=get_img(selected);
		if size(img,3)>1
			img = rgb2gray(img);
		end
		stretcher = stretchlim(img,[0.01 0.995]);
		set(handles.minintens, 'String',stretcher(1));
		set(handles.maxintens, 'String',stretcher(2));
	end
end


function maxintens_Callback(hObject, ~, ~)
if str2num(get(hObject,'String'))>1
	set(hObject,'String',1)
end

if str2num(get(hObject,'String'))<0
	set(hObject,'String',1)
end

function minintens_Callback(hObject, ~, ~)
if str2num(get(hObject,'String'))<0
	set(hObject,'String',0);
end

if str2num(get(hObject,'String'))>1
	set(hObject,'String',0);
end

function filenamebox_Callback (~, ~)
handles=gethand;
box_select=get(handles.filenamebox,'value');
set(handles.fileselector, 'value',ceil(box_select/2));
if mod(box_select,2) == 1 %ungerade
	toggler=0;
else
	toggler=1;
end

set(handles.togglepair, 'Value',toggler);
put('toggler',toggler);
try %if user presses buttons too quickly, error occurs.
	sliderdisp
catch
end


%set(handles.fileselector, 'value',goto);
%togglepair_Callback

%sliderdisp
%togglepair_Callback;
%fileselector_Callback;

function shortcuts_Callback (~, ~)
try
	open('PIVlab_shortcuts.pdf')
catch
	msgbox('Could not open "PIVlab_Shortcuts.pdf".')
end

function quick1_Callback (~,~)
handles=gethand;
set(handles.quick1,'Value',0)
loadimgs_Callback

function quick2_Callback (~,~)
handles=gethand;
set(handles.quick2,'Value',0)
img_mask_Callback

function quick3_Callback (~,~)
handles=gethand;
set(handles.quick3,'Value',0)
pre_proc_Callback

function quick4_Callback (~,~)
handles=gethand;
set(handles.quick4,'Value',0)
piv_sett_Callback

function quick5_Callback (~,~)
handles=gethand;
set(handles.quick5,'Value',0)
do_analys_Callback

function quick6_Callback (~,~)
handles=gethand;
set(handles.quick6,'Value',0)
cal_actual_Callback

function suggest_bright_filter_Callback (~,~,~)
handles=gethand;
resultslist=retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame
	%image-based filtering
	set(handles.do_bright_filter, 'value',1);
	%do_contrast_filter=1
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));
	[A,rawimageA]=get_img(selected);
	[B,rawimageB]=get_img(selected+1);
	[~,~,threshold_suggestion] = PIVlab_image_filter (0,1,x,y,u,v,0,bright_filter_thresh,A,B,rawimageA,rawimageB);
	set(handles.bright_filter_thresh, 'String',num2str(threshold_suggestion));
	[u,v,~] = PIVlab_image_filter (0,1,x,y,u,v,0,threshold_suggestion,A,B,rawimageA,rawimageB);
end

function suggest_contrast_filter_Callback (~,~,~)
handles=gethand;
resultslist=retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame
	%image-based filtering
	set(handles.do_contrast_filter, 'value',1);
	%do_contrast_filter=1
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
	[A,rawimageA]=get_img(selected);
	[B,rawimageB]=get_img(selected+1);
	[~,~,threshold_suggestion] = PIVlab_image_filter (1,0,x,y,u,v,contrast_filter_thresh,0,A,B,rawimageA,rawimageB);
	set(handles.contrast_filter_thresh, 'String',num2str(threshold_suggestion));
	[u,v,~] = PIVlab_image_filter (1,0,x,y,u,v,threshold_suggestion,0,A,B,rawimageA,rawimageB);
end

function set_other_interpol_checkbox(hObject,~,~) %synchronizes the two existing "interpoalte missing data" checkboxes
handles=gethand;
set(handles.interpol_missing,'Value',get(hObject,'Value'));
set(handles.interpol_missing2,'Value',get(hObject,'Value'));

function set_offset_Callback (hObject,~,~)
%calxy=retr('calxy');
filepath=retr('filepath');
caliimg=retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	sliderdisp
end
if size(filepath,1) >1 || numel(caliimg)>0 || retr('video_selection_done') == 1
	handles=gethand;
	toolsavailable(0)
	[xposition,yposition] = ginput(1);
	hold on;
	plot (xposition,yposition,'y.', 'markersize', 20,'LineWidth',3, 'tag', 'offset_label_x');
	hold off;
	if numel(caliimg)==0
		sliderdisp
	end
	if strcmp(get(hObject,'tag'),'set_x_offset')
		offset_dim='x';
	else
		offset_dim='y';
	end
	prompt =['Enter true ' offset_dim ' coordinate in mm:'];
	dlgtitle = ['Set ' offset_dim ' offset'];
	definput = {'0'};
	answer = inputdlg(prompt,dlgtitle,[1 40],definput);
	if ~isempty(answer)
		answer{1} = regexprep(answer{1}, ',', '.');
		if strcmp(get(hObject,'tag'),'set_x_offset')
			points_offsetx = [xposition,yposition,str2num(answer{1})];
			put('points_offsetx',points_offsetx);
		else
			points_offsety = [xposition,yposition,str2num(answer{1})];
			put('points_offsety',points_offsety);
		end
	end
	if strcmp(get(hObject,'tag'),'set_x_offset')
		delete(findobj('tag','offset_label_x'))
		y_limits=get(gca,'ylim');
		hold on;
		plot([xposition xposition],y_limits, 'y-','tag', 'offset_label_x')
		%plot (xposition,yposition,'ro-', 'markersize', 10,'LineWidth',3, 'tag', 'offset_label_x');
		plot (xposition,yposition,'r+:', 'tag', 'offset_label_x');
		hold off;
		text(xposition+10,yposition+10, ['x reference:' num2str(round(xposition*10)/10) ' px'],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'offset_label_x')
	else
		delete(findobj('tag','offset_label_y'))
		x_limits=get(gca,'xlim');
		hold on;
		plot(x_limits,[yposition yposition], 'y-','tag', 'offset_label_y')
		%plot (xposition,yposition,'ro-', 'markersize', 10,'LineWidth',3, 'tag', 'offset_label_y');
		plot (xposition,yposition,'r+:', 'tag', 'offset_label_y');
		hold off;
		text(xposition+10,yposition+10, ['y reference:' num2str(round(yposition*10)/10) ' px'],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'offset_label_y')
	end
	toolsavailable(1)

end

function offset = calculate_offset_axis (axis,pixel_position,true_position)
handles=gethand;
calxy=retr('calxy');
size_of_the_image=retr('size_of_the_image');
if isempty(size_of_the_image)%user applies calibration before loading images
	caliimg=retr('caliimg');
	size_of_the_image=size(caliimg);
	put('size_of_the_image',size_of_the_image);
end
if strcmp(axis,'x')
	axis_direction=get(handles.x_axis_direction,'value');
	size_dim=size_of_the_image(2);
end
if strcmp(axis,'y')
	axis_direction=get(handles.y_axis_direction,'value');
	size_dim=size_of_the_image(1);
end
if axis_direction ==1
	offset = pixel_position*calxy - true_position/1000;
else
	offset = (size_dim-pixel_position)*calxy - true_position/1000;
end

function suppress_vec_Callback (hObject,~)
handles=gethand;
if get(hObject,'Value')==1
	set(handles.nthvect,'String','100000');
	set(handles.vectorscale,'String','0');
else
	set(handles.nthvect,'String','1');
	set(handles.vectorscale,'String','8');
end

function save_polyline_Callback (~,~)
xposition=retr('xposition');
yposition=retr('yposition');
if ~isempty(xposition) && ~isempty(yposition)
	[polyfile,polypath] = uiputfile('*.mat','Save coordinates','PIVlab_coordinates.mat');
	if isequal(polyfile,0) | isequal(polypath,0)
		%do nothing
	else
		save(fullfile(polypath,polyfile),'xposition','yposition');
	end
end

function load_polyline_Callback (~,~)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1 %did the user load images?
	[polyfile,polypath] = uigetfile('*.mat','Load coordinate','PIVlab_coordinates.mat');
	if isequal(polyfile,0) | isequal(polypath,0)
		%do nothing
	else
		load(fullfile(polypath,polyfile),'xposition','yposition');
		try
			put('xposition',xposition);
			put('yposition',yposition);
			delete(findobj('tag', 'extractline'))
			delete(findobj('tag','areaint'));
			if size(xposition,1)==1
				line(xposition,yposition,'LineWidth',3, 'Color', [0,0,0.95],'tag','extractline');
				line(xposition,yposition,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','extractline');
			else
				for m=1:30
					line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
				end
			end
		catch
			disp(['Error. No coordinate data found in ' fullfile(polypath,polyfile)])
		end
	end
end

function bg_view_Callback (~,~) %displays background in GUI
handles=gethand;
bg_toggle=retr('bg_toggle');
if isempty(bg_toggle)
	bg_toggle=0;
elseif bg_toggle==0
	bg_toggle=1;
elseif bg_toggle==1
	bg_toggle=0;
end
put('bg_toggle',bg_toggle)
if get(handles.bg_subtract,'Value')==1
	bg_img_A = retr('bg_img_A');
	bg_img_B = retr('bg_img_B');
	sequencer=retr('sequencer');%Timeresolved or pairwise 0=timeres.; 1=pairwise
	if sequencer ~= 2 % bg subtraction only makes sense with time-resolved and pairwise sequencing style, not with reference style.
		if isempty(bg_img_A) || isempty(bg_img_B)
			generate_BG_img
			bg_img_A = retr('bg_img_A');
			bg_img_B = retr('bg_img_B');
		end
		%display it (needs to be toggable....)
		if bg_toggle==0
			image(imadjust(bg_img_A), 'parent',gca, 'cdatamapping', 'scaled');
		elseif bg_toggle==1
			image(imadjust(bg_img_B), 'parent',gca, 'cdatamapping', 'scaled');
		end
		colormap('gray');
		axis image;
		set(gca,'ytick',[])
		set(gca,'xtick',[])
	end
end

%% Camera capture callbacks
function ac_lasertoggle_Callback(~,~,~)
handles=gethand;
serpo=retr('serpo');
laser_running = retr('laser_running');
if isempty(laser_running)
	laser_running=0;
end
try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	pause(0.1)
	if laser_running %laser is on
		control_simple_sync_serial(0);
		laser_running=0;
	else %laser is off
		control_simple_sync_serial(1);
		laser_running=1;
	end
	put('laser_running',laser_running);
else
	no_dongle_msgbox
end

function ac_sync_settings_Callback(~,~,~)
serpo=retr('serpo');
handles=gethand;

if str2double(get(handles.ac_interpuls,'String')) < retr('min_allowed_interframe')
	old_bg=get(handles.ac_interpuls,'BackgroundColor');
	for i=1:3
		set(handles.ac_interpuls,'BackgroundColor',[1 0 0]);
		pause(0.1)
		set(handles.ac_interpuls,'BackgroundColor',old_bg);
		pause(0.1)
	end
	set(handles.ac_interpuls,'String',num2str(retr('min_allowed_interframe')))
end

if isnan(str2double(get(handles.ac_power,'String')))
	set(handles.ac_power,'String','0')
end
if str2double(get(handles.ac_power,'String')) > 100
	%camera_type=retr('camera_type');
	%if ~strcmp(camera_type,'chronos')
		set(handles.ac_power,'String','100')
	%end
end

try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	laser_running=retr('laser_running');
	if isempty(laser_running)
		laser_running=0;
	end
	control_simple_sync_serial(laser_running);
end

function laser_device_id = find_laser_device
handles=gethand;
serpo=retr('serpo');
try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	
	if exist('laser_device_id.mat','file') == 2
		old_laser_device_id = load('laser_device_id.mat','id');
		old_laser_device_id = old_laser_device_id.id;
	else
		old_laser_device_id='%';
	end
	try
		writeline(serpo,'WhoAreYou?');
		pause(0.3)
		warning off
		serial_answer=readline(serpo);
		warning on
	catch
	end
	if isempty(serial_answer)
		uiwait(msgbox(['No laser found.' sprintf('\n') 'Is the laser turned on?' sprintf('\n') 'Please try again.'],'modal'))
	end
	if strncmp(old_laser_device_id,serial_answer,20)==0 %if last laser ID DOES NOT equal current laser ID
		get_laser_id = inputdlg(['Please enter the ID of your laser / synchronizer.' sprintf('\n') 'It can be found on the sticker on the device.'],'First time connection',1,{convertStringsToChars(serial_answer)});
		if ~isempty(get_laser_id)
			id=get_laser_id{1};
			[filepath,~,~] = fileparts(mfilename('fullpath'));
			save (fullfile(filepath, 'PIVlab_capture_resources', 'laser_device_id.mat'),'id')
		end
	end
	laser_device_id = load('laser_device_id.mat','id');
	laser_device_id = laser_device_id.id;
else
	no_dongle_msgbox
end

function serial_answer = control_simple_sync_serial(switch_it)
try %try to switch of camera angle report
	stop(timerfind)
	delete(timerfind)
	set(getappdata(0,'handle_to_lens_timer_checkbox'),'Value',0)
catch
end
handles=gethand;
serpo=retr('serpo');
try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	%Master frequency in Hz
	master_freq =retr('master_freq'); %will depend on the laser system (frequency with best beam quality)
	%frame 1 exposure time incl. readout time in 탎
	f1exp = retr('f1exp'); % will depend on camera model
	%External trigger input settings
	if get(handles.ac_enable_ext_trigger,'Value') == 0
		extdly = -1; % external trigger input delay. -1 disables external trigger
		extskp = 0; %external trigger amount of signals to skip.
	else
		extdly = retr('selectedtriggerdelay'); % external trigger input delay. -1 disables external trigger
		extskp = retr('selectedtriggerskip'); %external trigger amount of signals to skip.
	end
	%Camera fps
	ac_fps_value=get(handles.ac_fps,'Value');
	ac_fps_str=get(handles.ac_fps,'String');
	cam_prescaler=master_freq/str2double(ac_fps_str(ac_fps_value));
	%Laser power
	las_percent=str2double(get(handles.ac_power,'String'));
	%specific laser power polynom for converting Q-switch delay to laser energy
	load q_delay_to_laser_power_polynom.mat %loads q and min_energy
	energy_us = round(polyval(p,las_percent));
	if energy_us > min_energy
		energy_us = min_energy;
	end
	%Pulse distance
	pulse_sep=str2double(get(handles.ac_interpuls,'String'));
	laser_device_id=retr('laser_device_id');
%{
	if ~exist('laser_device_id.mat','file') == 2
		try
			writeline(serpo,'WhoAreYou?');
			pause(0.3)
			warning off
			serial_answer=readline(serpo);
			assignin ('base','serial_answer',serial_answer)
			warning on
		catch
		end
		get_laser_id = inputdlg(['Please enter the ID of your laser / synchronizer.' sprintf('\n') 'It can be found on the sticker on the device.'],'First time connection',1,{convertStringsToChars(serial_answer)});
		if ~isempty(get_laser_id)
			id=get_laser_id{1};
			[filepath,~,~] = fileparts(mfilename('fullpath'));
			save (fullfile(filepath, 'PIVlab_capture_resources', 'laser_device_id.mat'),'id')
		end
	end
	laser_device_id = load('laser_device_id.mat','id');
	laser_device_id = laser_device_id.id;
	%}
	%{
	[filepath,~,~] = fileparts(mfilename('fullpath'));
	disp([fullfile(filepath, 'PIVlab_capture_resources', 'laser_device_id.mat')]);
	disp('requested laser_device_id = ')
		disp(laser_device_id)
	pause(1)
	writeline(serpo,'WhoAreYou?');
	disp(['reported laser_device_id = ' ])
	disp(readline(serpo))
	pause(1)
	%}
	if switch_it==1
		flush(serpo)
		camera_type=retr('camera_type');

		if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_pixelfly')
			send_string=['TALKINGTO:' laser_device_id ';FREQ:' int2str(master_freq) ';CAM:' int2str(cam_prescaler) ';ENER:' int2str(energy_us) ';ener%:' int2str(las_percent) ';F1EXP:' int2str(f1exp) ';INTERF:' int2str(pulse_sep) ';EXTDLY:' int2str(extdly) ';EXTSKP:' int2str(extskp) ';LASER:enable'];
		else
			send_string=['TALKINGTO:' laser_device_id ';FREQ:' int2str(str2double(ac_fps_str(ac_fps_value))) ';CAM:' int2str(0) ';ENER:' int2str(0) ';ener%:' int2str(las_percent) ';F1EXP:' int2str(0) ';INTERF:' int2str(pulse_sep) ';EXTDLY:' int2str(0) ';EXTSKP:' int2str(0) ';LASER:enable'];
		end
		%send_string='FREQ:3;EXPO:300;CAMDLY:0;LDPULS:300;INTERF:500;LASER:enable'
		%disp('testing laserdiode')
		writeline(serpo,send_string);
	else
		flush(serpo)
		%configureTerminator(serpo,'CR');
		writeline(serpo,['TALKINGTO:' laser_device_id ';FREQ:1;CAM:1;ENER:' int2str(min_energy) ';ener%:0;F1EXP:100;INTERF:1234;EXTDLY:-1;EXTSKP:0;LASER:disable']);
		%writeline(serpo,'FREQ:5;EXPO:300;CAMDLY:835;LDPULS:300;INTERF:500;LASER:disable');
		%disp('testing laserdiode')
	end
	pause(0.1)
	warning off
	%configureTerminator(serpo,'CR/LF');
	%disp('Answer received:')
	%HIER WAR ALTER CODE
	serial_answer = ac_process_sync_reply(serpo);
else
	no_dongle_msgbox
end


function serial_answer = ac_process_sync_reply(serpo)
handles=gethand;
serial_answer=readline(serpo);
warning on
sync_setting=serial_answer;
if isempty(sync_setting)
	sync_setting='No answer from Sync';
end
update_ac_status(sync_setting);

set(handles.ac_laserstatus,'BackgroundColor',[1 1 0]); %yellow=warning
set(handles.ac_laserstatus,'String','No Answer');drawnow;
C = strsplit(sync_setting,'\t');
if ~isempty(C)
	if size(C,2)==8 %entspricht standard datenpaket
		if strcmp(C{8},'1') %laser is reported to be on
			set(handles.ac_laserstatus,'BackgroundColor',[0 1 0]); %green = on
			set(handles.ac_laserstatus,'String','Laser ON');
		else
			set(handles.ac_laserstatus,'BackgroundColor',[1 0 0]); %red = off
			set(handles.ac_laserstatus,'String','Laser OFF');
		end
	end
	if size(C,2)==12 %entspricht erweitertem datenpaket
		if strcmp(C{8},'1') %laser is reported to be on
			set(handles.ac_laserstatus,'BackgroundColor',[0 1 0]); %green = on
			set(handles.ac_laserstatus,'String','Laser ON');
		else
			set(handles.ac_laserstatus,'BackgroundColor',[1 0 0]); %red = off
			set(handles.ac_laserstatus,'String','Laser OFF');
			pl_msg=['Pulse length: 0 탎'];
			set (handles.ac_pulselengthtxt,'String', pl_msg);
		end
		if strcmp(C{8},'1') %laser is reported to be on
			pl_msg=['Pulse length: ' C{9} ' 탎'];
			set (handles.ac_pulselengthtxt,'String', pl_msg);
			disp (pl_msg)
		end
	end

end


%Settings_logger
logger_path = get(handles.ac_project,'String');
if exist(logger_path,'dir') %only log when directory has been set up.
	timestamp=datestr(datetime(now,'ConvertFrom','datenum'));
	if exist (fullfile(logger_path, 'acquisition_log.txt'),'file')~=2
		try
			logger_fid = fopen(fullfile(logger_path, 'acquisition_log.txt'), 'w');
			fprintf(logger_fid,'Time\tProject_folder\tMaster_frequency\tCamera_divider\tEnergy_us\tFrame_1_exposure_us\tInterframe_us\tExternal_delay_us\tExternal_skip\tLaser_status\tBinning\tROI');
			fprintf(logger_fid, '\n');
			fclose(logger_fid);
		catch
		end
	end
	try
		ac_ROI_general=retr('ac_ROI_general');
		binning=retr('binning');
		logger_fid = fopen(fullfile(logger_path, 'acquisition_log.txt'), 'a');
		fprintf(logger_fid, '%s', timestamp);
		fprintf(logger_fid, '\t');
		fprintf(logger_fid, '%s', logger_path);
		fprintf(logger_fid, '\t');
		fprintf(logger_fid, '%s', sync_setting);
		fprintf(logger_fid, '\t');
		fprintf(logger_fid, '%s', num2str(binning));
		fprintf(logger_fid, '\t');
		fprintf(logger_fid, '%s', mat2str(ac_ROI_general));
		fprintf(logger_fid, '\n');
		fclose(logger_fid);
	catch
	end
end



function no_dongle_msgbox
uiwait(msgbox(['No connection to the PIVlab-SimpleSync found.' sprintf('\n') 'Is the USB dongle connected?'],'modal'))


function ac_connect_Callback (~,~,~)
handles=gethand;
set(handles.ac_serialstatus,'Backgroundcolor',[1 0 0]);
if strcmp(get(handles.ac_comport,'String'),'No available serial ports found!')
	capture_images_Callback; %will also refresh the comport list
else
	try
		delete(retr('serpo')); %delete old serialport
		selected_item=get(handles.ac_comport,'Value');
		avail_ports=get(handles.ac_comport,'String');
		if size(avail_ports,1)>1
			selected_port=avail_ports{selected_item};
		else
			selected_port=avail_ports;
		end
		serpo = serialport(selected_port,9600,'Timeout',1);
		configureTerminator(serpo,'CR/LF');
		put('serpo',serpo);
		set(handles.ac_serialstatus,'Backgroundcolor',[0 1 0]);
		update_ac_status(['Connected to ' selected_port]);
		put('laser_running',0);

	laser_device_id = find_laser_device;
	put('laser_device_id',laser_device_id);

		control_simple_sync_serial(0);
	catch ME
		update_ac_status(ME.message);
		capture_images_Callback;
	end
end

function ac_calibBinning_Callback (~,~,~)
handles=gethand;
camera_type=retr('camera_type');
if ~strcmp(camera_type,'pco_panda')  %ROI selection available only for pco panda
	uiwait(msgbox('Binning is (up to now) only available for the pco.panda 26 DS.','modal'))
else
	binning=retr('binning');
	if isempty(binning)
		binning=1;
	end
	definput = {num2str(binning)};
	prompt = {'Pixel binning (1, 2, 4)'};
	dlgtitle = 'Pixel binning Configuration';
	dims = [1 50];
	answer = inputdlg(prompt,dlgtitle,dims,definput);
	if ~isempty(answer)
		if str2double(answer{1}) ~= 1 && str2double(answer{1}) ~= 2 && str2double(answer{1}) ~= 4
			msgbox('Not a valid binning option.','modal')
			put('binning',1)
		else
			put('binning',str2double(answer{1}));
			clear_roi_Callback %PIV-ROI must be cleared when camera resolution is chnaged.
		end
		if answer{1} ~= definput{1}
			set(handles.ac_realtime,'Value',0);%reset realtime roi
			put('do_realtime',0);
			%reset roi too
			ac_ROI_general=[];
			put('ac_ROI_general',ac_ROI_general);
			save('PIVlab_settings_default.mat','ac_ROI_general','-append');
		end
	end
end

function ac_calibROI_Callback (~,~,~)
handles=gethand;
put('capturing',0);
put('hist_enabled',0);
camera_type=retr('camera_type');
binning=retr('binning');
if isempty(binning)
	binning=1;
end
if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'chronos') %ROI selection not yet available for pixelfly and chronos
	uiwait(msgbox('ROI selection is not (yet) available for the selected camera type.'))
end


if strcmp(camera_type,'flir')
	uiwait(msgbox('ROI selection for the FLIR camera series will be implemented soon!','modal'))
end

if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'basler') || strcmp(camera_type,'OPTOcam')
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
			expos=100000;
		end
	projectpath=get(handles.ac_project,'String');
	capture_ok=check_project_path(projectpath,'calibration');
	if capture_ok==1
		put('cancel_capture',0);
		put('capturing',1);
		max_cam_res=retr('max_cam_res');
		if strcmp(camera_type,'pco_panda')
		try
			[errorcode, caliimg,~]=PIVlab_capture_pco(1,expos,'Calibration',projectpath,[],0,[],binning,[1,1, max_cam_res(1)/binning,max_cam_res(2)/binning],camera_type,0);
		catch ME
			disp(ME)
			uiwait(msgbox('Camera not connected'))
			displogo
			capture_ok=0;
		end
		elseif strcmp(camera_type,'basler')
			[errorcode, caliimg]=PIVlab_capture_basler_calibration_image(1,expos,[1,1,max_cam_res]);
		end
		put('capturing',0);

		if capture_ok==1
			displaysize_x=floor(get(gca,'XLim'));
			displaysize_y=floor(get(gca,'YLim'));
			ac_ROI_general=[];
			warning off
			load('PIVlab_settings_default.mat','ac_ROI_general');
			warning on
			
			bla=findobj(gca,'type','image');
			current_image_size=size(bla.CData);

			if isempty(ac_ROI_general)
				ac_ROI_general=[0.5,0.5,current_image_size(2)/binning,current_image_size(1)/binning]; %1 Hz default ROI
			end
			put('doing_roi',1)
			stretched_image=adapthisteq(bla.CData);
			bla.CData=stretched_image;
			ac_ROI_general_handle = drawrectangle(gca,'Position',ac_ROI_general,'LabelVisible','hover','Deletable',0,'DrawingArea',[1 1 current_image_size(2) current_image_size(1)],'tag','new_ROImethod','StripeColor','y');
			addlistener(ac_ROI_general_handle,'MovingROI',@ROIallevents);
			addlistener(ac_ROI_general_handle,'ROIMoved',@ROIallevents);
			evt.EventName='ROIMoved';
			evt.CurrentPosition=ac_ROI_general;
			ROIallevents(ac_ROI_general_handle,evt)

			c_menu = uicontextmenu;
			ac_ROI_general_handle.UIContextMenu = c_menu;

			if strcmp(camera_type,'pco_panda')
				m0 = uimenu(c_menu,'Label','pco.panda 50 Hz','Callback',@setdefaultroi);
				m1 = uimenu(c_menu,'Label','pco.panda 30 Hz','Callback',@setdefaultroi);
				m2 = uimenu(c_menu,'Label','pco.panda 15 Hz','Callback',@setdefaultroi);
				m3 = uimenu(c_menu,'Label','pco.panda 7.5 Hz','Callback',@setdefaultroi);
				m4 = uimenu(c_menu,'Label','pco.panda 5 Hz','Callback',@setdefaultroi);
				m5 = uimenu(c_menu,'Label','pco.panda 3 Hz','Callback',@setdefaultroi);
				m6 = uimenu(c_menu,'Label','pco.panda 1 Hz','Callback',@setdefaultroi);
				m7 = uimenu(c_menu,'Label','Enter ROI','Callback',@setdefaultroi);
			end
			if strcmp(camera_type,'basler')
				m0 = uimenu(c_menu,'Label','Basler 2048x1088','Callback',@setdefaultroi);
				m1 = uimenu(c_menu,'Label','Basler 1280x720','Callback',@setdefaultroi);
				m2 = uimenu(c_menu,'Label','Basler 1024x1024','Callback',@setdefaultroi);
				m3 = uimenu(c_menu,'Label','Basler 640x480','Callback',@setdefaultroi);
				m4 = uimenu(c_menu,'Label','Enter ROI','Callback',@setdefaultroi);
			end

			position = customWait(ac_ROI_general_handle);

			put('ac_ROI_general_handle',ac_ROI_general_handle);
			put('doing_roi',0)
			position=round(position);

			xmin=position(1);
			ymin=position(2);
			xmax=position(1)+position(3)-1;
			ymax=position(2)+position(4)-1;

			% Round so it fits the requirements of the camera ROI
			xmin=floor(xmin/8)*8+1;
			ymin=floor(ymin/2)*2+1;
			xmax=floor(xmax/8)*8;
			ymax=floor(ymax/2)*2;

			if xmin<1
				xmin=1;
			end
			if ymin<1
				ymin=1;
			end
			if xmax>max_cam_res(1)
				xmax=max_cam_res(1);
			end
			if ymax>max_cam_res(2)
				ymax=max_cam_res(2);
			end
			position(1)=xmin;
			position(2)=ymin;
			position(3)=xmax-xmin+1;
			position(4)=ymax-ymin+1;
			ac_ROI_general=position;
			put('ac_ROI_general',ac_ROI_general);
			save('PIVlab_settings_default.mat','ac_ROI_general','-append');
			delete(ac_ROI_general_handle)
			rectangle('Position',position,'EdgeColor','y','linewidth',2)
			if strcmp(camera_type,'pco_panda')
				%% jetzt nochmal mit finalen einstellungen bild capturen zum messen der framerate...
				%Camera fps
				ac_fps_value=get(handles.ac_fps,'Value');
				ac_fps_str=get(handles.ac_fps,'String');
				cam_fps=str2double(ac_fps_str(ac_fps_value));
				ac_ROI_general=retr('ac_ROI_general');
				[~,~,framerate_max]=PIVlab_capture_pco(1,retr('f1exp_cam'),'Synchronizer',projectpath,cam_fps,0,[],binning,ac_ROI_general,camera_type,1);
				delete(findobj('tag','roitxt'));
				text(50,50,['Max framerate: ' num2str(round(framerate_max,2)) ' Hz'],'tag','roitxt','Color','yellow','FontSize',14,'FontWeight','bold')
			end
			set(handles.ac_realtime,'Value',0);%reset realtime roi
			put('do_realtime',0);
		end
	end
end

function ac_calibcapture_Callback(~,~,~)
[filepath,~,~] = fileparts(mfilename('fullpath'));
camera_type=retr('camera_type');
if ~strcmp(camera_type,'chronos') %calib
	if exist(fullfile(filepath, 'PIVlab_capture_resources\PCO_resources\scripts\pco_camera_load_defines.m'),'file')
		ready=1;
	else
		ready=0;
		pco_error_msgbox
	end
else
	ready=1;
end
if ready==1
	handles=gethand;
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
		expos=100000;
	end
	put('cancel_capture',0);
	projectpath=get(handles.ac_project,'String');
	capture_ok=check_project_path(projectpath,'calibration');
	ac_ROI_general=retr('ac_ROI_general');
	binning=retr('binning');
	if isempty(binning)
		binning=1;
	end
	if isempty(ac_ROI_general)
		max_cam_res=retr('max_cam_res');
		ac_ROI_general=[1,1,max_cam_res(1)/binning,max_cam_res(2)/binning];
	end
	capturing=retr('capturing');
	if isempty(capturing);capturing=0;end
	if capture_ok==1 && capturing == 0
		put('capturing',1);
		toolsavailable(0)
		%set(handles.ac_calibsave,'enable','on')
		set(handles.ac_calibcapture,'enable','on')
		set(handles.ac_serialstatus,'enable','on')
		set(handles.ac_laserstatus,'enable','on')
		set(handles.ac_lasertoggle,'enable','on')
		set(handles.ac_lensctrl,'enable','on')
		set(handles.ac_power,'enable','on')

		%try
		set(handles.ac_calibcapture,'String','Stop')
		if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda') %pco cameras
			[errorcode, caliimg,framerate_max]=PIVlab_capture_pco(50000,expos,'Calibration',projectpath,[],0,[],binning,ac_ROI_general,camera_type,0);
		elseif strcmp(camera_type,'basler')
			[errorcode, caliimg]=PIVlab_capture_basler_calibration_image(inf,expos,ac_ROI_general);
		elseif strcmp(camera_type,'OPTOcam')
			[errorcode, caliimg]=PIVlab_capture_OPTOcam_calibration_image(inf,expos,ac_ROI_general);
		elseif strcmp(camera_type,'flir')
			[errorcode, caliimg]=PIVlab_capture_flir_calibration_image(expos);
		elseif strcmp(camera_type,'chronos')
			cameraIP=retr('Chronos_IP');
			if isempty(cameraIP)
				uiwait(msgbox({'Chronos Setup not performed.' 'Please click "Setup" in "Camera settings"'}))
			else
				[errorcode, caliimg] = PIVlab_capture_chronos_calibration_image(cameraIP,expos);
			end
		end
		put('caliimg',caliimg);
		put('fresh_calib_image',1);
		%{
		catch
			set(handles.ac_calibcapture,'String','Start')
			uiwait(msgbox('Camera not connected'))
			displogo
			put('capturing',0);
			toolsavailable(1)
		end
		%}
	elseif capture_ok==1 && capturing == 1
		put('cancel_capture',1);
		put('capturing',0);
		set(handles.ac_calibcapture,'String','Start')
		toolsavailable(1)
		set(handles.ac_calibsave,'enable','on')
	end
end
%toolsavailable(1)

function result=check_project_path(projectpath,caller)
handles=gethand;
result=0;
if ~exist(projectpath,'dir')
	button = questdlg('Folder does not exist. Create?','Create?','Yes','Cancel','Yes');
	if strmatch(button,'Yes')==1
		mkdir(projectpath);
		result=1;
		update_ac_status(['Created folder ' projectpath]);
	end
else
	result=1;
end
if strcmp(caller,'double_images')
	if result==1 && exist(fullfile(projectpath,'PIVlab_0000_A.tif'),'file') || exist(fullfile(projectpath,'frame_000001.tiff'),'file')
		button = questdlg('Overwrite files?','Overwrite?','Yes','Cancel','Yes');
		if strmatch(button,'Yes')==1
			result=1;
		else
			result=0;
		end
	end
end

function ac_pivcapture_save_Callback(inpt,~)
handles=gethand;
if inpt.Value == 0
	set (handles.ac_imgamount, 'enable','off')
else
	set (handles.ac_imgamount, 'enable','on')
end




function ac_pivcapture_Callback(~,~,~)
put('capturing',0);
[filepath,~,~] = fileparts(mfilename('fullpath'));
if exist(fullfile(filepath, 'PIVlab_capture_resources\PCO_resources\scripts\pco_camera_load_defines.m'),'file')
	button = questdlg('Start Laser and camera?','Warning','Yes','Cancel','Yes');
	if strmatch(button,'Yes')==1
		handles=gethand;
		put('cancel_capture',0);
		projectpath=get(handles.ac_project,'String');
		if get(handles.ac_pivcapture_save,'Value')==1 %check settings only when user wants to save data
			imageamount=str2double(get(handles.ac_imgamount,'String'));
			capture_ok=check_project_path(projectpath,'double_images');
		else
			imageamount=inf; %run forever if user doesnt want to save images
			capture_ok=1;
		end
		%Camera fps
		ac_fps_value=get(handles.ac_fps,'Value');
		ac_fps_str=get(handles.ac_fps,'String');
		cam_fps=str2double(ac_fps_str(ac_fps_value));
		ac_ROI_realtime=retr('ac_ROI_realtime');
		do_realtime=retr('do_realtime');
		if isempty(do_realtime)
			do_realtime=0;
		end
		if capture_ok==1
			put('expected_image_size',[])
			ac_ROI_general=retr('ac_ROI_general');
			if isempty(ac_ROI_general)
				max_cam_res=retr('max_cam_res');
				ac_ROI_general=[1 1 max_cam_res(1) max_cam_res(2)];
			end
			put('capturing',1);
			toolsavailable(0)
			set(handles.ac_pivstop,'enable','on')
			set(handles.togglepair,'enable','on')
			set(handles.ac_serialstatus,'enable','on')
			set(handles.ac_laserstatus,'enable','on')
			set(handles.ac_lasertoggle,'enable','on')

			value=get(handles.ac_config,'value');

			if value== 1 || value == 2 %setups without lD-PS
				set(handles.ac_power,'enable','on') %here, laser power can be adjusted while it is running.
			end
			set(handles.ac_lensctrl,'enable','on')

			f = waitbar(0,'Initializing...');
			%if any external device is activated for automatic control, then...
			if (~isempty(retr('ac_enable_seeding1')) && retr('ac_enable_seeding1') ~=0) || (~isempty(retr('ac_enable_device1')) && retr('ac_enable_device1') ~=0) || (~isempty(retr('ac_enable_device2')) && retr('ac_enable_device2') ~=0)
				external_device_control(1); %starts selected devices
				waitbar(.15,f,'Starting external devices...');
				pause(1)
				waitbar(.33,f,'Starting external devices...');
				pause(1)
			end
			if value==1 || value==2 %setup withOUT LD-PS
				%Start-up sequence for normal Q-Switched laser
				waitbar(.5,f,'Starting laser...');
				control_simple_sync_serial(1);
				put('laser_running',1);
				pause(1)
				waitbar(.6,f,'Starting laser...');
				pause(1)
				waitbar(.7,f,'Laser stabilization...');
				pause(1)
				waitbar(.85,f,'Starting camera...');
				pause(1)
				waitbar(1,f,'Starting camera...');
				pause(1)
				close(f)
			elseif value == 3 || value == 4 %pco cameras with laser diode
				%Start-up sequence for PIVlab LD-PS (much quicker)
				waitbar(.01,f,'Starting laser...');
				control_simple_sync_serial(1);
				put('laser_running',1);
				close(f)
			elseif value== 5 || value == 6 || value==7 %chronos and basler and flir: Camera needs to be started first, afterwards the laser is enabled.
				close(f)
			end
			camera_type=retr('camera_type');
			binning=retr('binning');
			if isempty(binning)
				binning=1;
			end
			value=get(handles.ac_config,'value');
			if value== 3 || value == 4 %setup with LD-PS and pco
				%require a calculation of the exposure time which depends on the laser pulse length
				las_percent=str2double(get(handles.ac_power,'String'));
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				f1exp_cam =floor(pulse_sep*las_percent/100)+1; %+1 because in the snychronizer, the cam expo is started 1 us before the ld pulse
				disp(['camera exposure time = ' num2str(f1exp_cam)])
				if f1exp_cam < 6
					msgbox (['Exposure time of camera too low. Please increase laser energy or pulse distance.' sprintf('\n') 'Pulse_distance[탎] * laser_energy[%] must be >= 6 탎'])
					uiwait
				end
			else 
				f1exp_cam=retr('f1exp_cam');
			end
			if value == 5 %chronos
				%capture to camera RAM
				%zuerst:camera konfigurieren. Dann kamera starten. dann laser. nach laserstart warten und aufnahme beenden.dann laser aus
				cameraIP=retr('Chronos_IP');
				[OutputError] = PIVlab_capture_chronos_synced_start(cameraIP,cam_fps); %prepare cam and start camera (waiting for trigger...)
				control_simple_sync_serial(1); put('laser_running',1); %turn on laser
				[OutputError,ima,frame_nr_display] = PIVlab_capture_chronos_synced_capture(cameraIP,imageamount,cam_fps,do_realtime,ac_ROI_realtime); %capture n images, display livestream
			elseif value == 1 || value == 2 || value == 3 || value == 4  %pco cameras
				PIVlab_capture_pco(imageamount,f1exp_cam,'Synchronizer',projectpath,cam_fps,do_realtime,ac_ROI_realtime,binning,ac_ROI_general,camera_type,0);
			elseif value == 6  %basler cameras
				[OutputError,basler_vid,frame_nr_display] = PIVlab_capture_basler_synced_start(imageamount,ac_ROI_general); %prepare cam and start camera (waiting for trigger...)
				control_simple_sync_serial(1); put('laser_running',1); %turn on laser
				[OutputError,basler_vid] = PIVlab_capture_basler_synced_capture(basler_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display); %capture n images, display livestream
			elseif value == 7  %flir cameras
				[OutputError,flir_vid,frame_nr_display] = PIVlab_capture_flir_synced_start(imageamount,cam_fps); %prepare cam and start camera (waiting for trigger...)
				control_simple_sync_serial(1); put('laser_running',1); %turn on laser
				[OutputError,flir_vid] = PIVlab_capture_flir_synced_capture(flir_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display); %capture n images, display livestream

			end
			%disable external devices
			external_device_control(0); % stops all external devices
			control_simple_sync_serial(0);pause(0.1);control_simple_sync_serial(0);
			put('laser_running',0);
			if value == 5 %chronos
				%when Chronos:save the images when finished recording to camera ram
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					PIVlab_capture_chronos_save (cameraIP,imageamount,projectpath,frame_nr_display)
				end
			end
			if value == 6 %basler
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					[OutputError] = PIVlab_capture_basler_save(basler_vid,imageamount,projectpath,frame_nr_display); %save the images from ram to disk.
				end
			end
			if value == 7 %flir
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					[OutputError] = PIVlab_capture_flir_save(flir_vid,imageamount,projectpath,frame_nr_display); %save the images from ram to disk.
				end
			end

			if retr('cancel_capture')==0
				camera_type=retr('camera_type');
				found_the_data=push_recorded_to_GUI(camera_type);
				if found_the_data==1
					put('sessionpath',projectpath );
					set(handles.time_inp,'String',num2str(str2num(get(handles.ac_interpuls,'String'))/1000));
					savesessionfuntion (projectpath,'PIVlab_Capture_Session.mat');
				else
					displogo
				end
			end
		end
	end
else
	pco_error_msgbox
end
put('capturing',0);
toolsavailable(1)

function external_device_control(switch_it)
handles=gethand;
serpo=retr('serpo');
if ~isempty(serpo)
	flush(serpo)
	if switch_it==1
		if ~isempty(retr('ac_enable_seeding1')) && retr('ac_enable_seeding1') == 1
			ext_dev_01_pwm = retr('ext_dev_01_pwm');
			line_to_write=['SEEDER_01:' num2str(ext_dev_01_pwm)];
			writeline(serpo,line_to_write);
			put('ac_seeding1_status',1);
			pause(0.2)
		end
		if ~isempty(retr('ac_enable_device1')) && retr('ac_enable_device1') == 1
			ext_dev_02_pwm = retr('ext_dev_02_pwm');
			line_to_write=['DEVICE_01:' num2str(ext_dev_02_pwm)];
			writeline(serpo,line_to_write);
			put('ac_device1_status',1);
			pause(0.2)
		end
		if ~isempty(retr('ac_enable_device2')) && retr('ac_enable_device2') == 1
			ext_dev_03_pwm = retr('ext_dev_03_pwm');
			line_to_write=['DEVICE_02:' num2str(ext_dev_03_pwm)];
			writeline(serpo,line_to_write);
			put('ac_device2_status',1);
			pause(0.2)
		end
	else
		writeline(serpo,'SEEDER_01:0');
		pause(0.1)
		writeline(serpo,'DEVICE_01:0');
		pause(0.1)
		writeline(serpo,'DEVICE_02:0');
		put('ac_seeding1_status',0);
		put('ac_device1_status',0);
		put('ac_device2_status',0);
	end
end




function found_the_data = push_recorded_to_GUI(camera_type)
handles=gethand;
projectpath=get(handles.ac_project,'String');
imageamount=str2double(get(handles.ac_imgamount,'String'));
pathlist={};
pathfilelist={};
file_existing=zeros(imageamount,1);
for i=1:imageamount
	if ~strcmp(camera_type,'chronos')
		pathfileA=fullfile(projectpath,['PIVlab_' sprintf('%4.4d',i-1) '_A.tif']);
		pathfileB=fullfile(projectpath,['PIVlab_' sprintf('%4.4d',i-1) '_B.tif']);
	elseif strcmp(camera_type,'chronos')
		pathfileA=fullfile(projectpath,['frame_' sprintf('%6.6d',2*i-1) '.tiff']);
		pathfileB=fullfile(projectpath,['frame_' sprintf('%6.6d',2*i) '.tiff']);
	end

	pathA=projectpath;
	pathB=projectpath;

	pathfilelist{i*2-1,1}=pathfileA;
	pathfilelist{i*2,1}=pathfileB;

	file_existing(i,1) = (isfile(pathfileA) + isfile(pathfileB))/2;

	pathlist{i*2-1,1}=pathA;
	pathlist{i*2,1}=pathB;
end
if all(file_existing)
	s = struct('name',pathfilelist,'folder',pathlist,'isdir',0);
	put('sequencer',1);
	put('capturing',0);
	loadimgsbutton_Callback([],[],0,s);
	found_the_data=1;
else
	found_the_data=0;
end

function update_ac_status(status)
handles=gethand;
contents=get(handles.ac_msgbox,'String');
try
	contents=[status;contents];
catch
end
set(handles.ac_msgbox,'String',contents);


function ac_camstop_Callback(~,~,~)
put('cancel_capture',1);
control_simple_sync_serial(0);
external_device_control(0);
put('laser_running',0);
put('capturing',0);
toolsavailable(1)
fresh_calib_image=retr('fresh_calib_image');
if ~isempty(fresh_calib_image) && fresh_calib_image == 1
	put('fresh_calib_image',0);
	handles=gethand;
	projectpath=get(handles.ac_project,'String');
	numbi = 0;
	imgA_path = fullfile(projectpath, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']);
	while exist(imgA_path, 'file')
		numbi = numbi+1;
		imgA_path = fullfile(projectpath, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']);
	end
	imwrite(retr('caliimg'),imgA_path);
	set(handles.ac_calibsave,'enable','off')
end
drawnow;


function ac_browse_Callback(~,~,~)
handles=gethand;
folder_name = uigetdir(retr('pathname'),'Select image folder for saving');
if ~isequal(folder_name,0)
	set(handles.ac_project,'String',folder_name);
	put('pathname',folder_name);
end

function ac_realtime_Callback(~,~,~)
handles=gethand;
if get(handles.ac_realtime,'Value')==1
	put('capturing',0);
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
		expos=100000;
	end
	projectpath=get(handles.ac_project,'String');
	capture_ok=check_project_path(projectpath,'calibration');
	ac_ROI_general=retr('ac_ROI_general');
	binning=retr('binning');
	if isempty(binning)
		binning=1;
	end
	if isempty(ac_ROI_general)
		max_cam_res=retr('max_cam_res');
		ac_ROI_general=[1,1,max_cam_res(1)/binning,max_cam_res(2)/binning];
	end
	camera_type=retr('camera_type');
	try
		if capture_ok==1
			put('cancel_capture',0);
			put('capturing',1);
			if ~strcmp(camera_type,'chronos') %calib
				[errorcode, caliimg]=PIVlab_capture_pco(1,expos,'Calibration',projectpath,[],0,[],binning,ac_ROI_general,camera_type,0);
			else
				%not supported yet....

			end
		end
		put('capturing',0);
		uiwait(msgbox(['Please select the ROI for real-time PIV.'],'modal'))
		roirect = round(getrect(gca));
		if roirect(1,3)~=0 && roirect(1,4)~=0
			put('ac_ROI_realtime',roirect);
			put('do_realtime',1);
		end
	catch
		put('do_realtime',0);
		set(handles.ac_realtime,'Value',0)
	end
else
	put('do_realtime',0);
end

function ac_ext_trigger_settings_Callback (~,~,~)
handles=gethand;
serpo=retr('serpo');
if ~isempty(serpo)
	control_simple_sync_serial(0);
	if get(handles.ac_enable_ext_trigger,'Value')==1 %execute only if checkbox was off before it was clicked.
		old_label=get(handles.ac_enable_ext_trigger,'String');
		set(handles.ac_enable_ext_trigger,'String','Acquiring...','Enable','off')

		drawnow;
		flush(serpo)
		%configureTerminator(serpo,'CR');
		writeline(serpo,'TrigFreq?');
		pause(1.25);
		warning off
		%configureTerminator(serpo,'CR/LF');
		serial_answer=readline(serpo);
		warning on
		set(handles.ac_enable_ext_trigger,'String',old_label,'Enable','on');
		selectedtriggerdelay=retr('selectedtriggerdelay');
		if isempty(selectedtriggerdelay)
			selectedtriggerdelay=100;
		end
		selectedtriggerskip=retr('selectedtriggerskip');
		if isempty(selectedtriggerskip)
			selectedtriggerdelay=0;
		end
		prompt = {['Detected frequency on trigger input: ' num2str(serial_answer) ' Hz.' sprintf('\n\n') 'Trigger delay in 탎 (must be > 100):'],'Nr. of trigger signals to skip:'};
		dlgtitle = 'External Trigger Configuration';
		dims = [1 50];
		definput = {num2str(selectedtriggerdelay),num2str(selectedtriggerskip)};
		answer = inputdlg(prompt,dlgtitle,dims,definput);
		if ~isempty(answer)
			put('selectedtriggerdelay',str2double(answer{1}));
			put('selectedtriggerskip',str2double(answer{2}));
		end
	end
end

function ac_device_control_Callback (~,~,~)
try %try to switch of camera angle report
	stop(timerfind)
	delete(timerfind)
	set(getappdata(0,'handle_to_lens_timer_checkbox'),'Value',0)
catch
end
PIVlab_capture_devicectrl_GUI

function select_capture_config_Callback (~,~,~)
handles=gethand;
value=get(handles.ac_config,'value');

old_setting=retr('old_setting');
if isempty(old_setting)
	put ('old_setting',inf)
end
put ('old_setting',value)

put('do_realtime',0);
set(handles.ac_realtime,'Value',0)
if value==1 || value==3 % ILA.piv nano / pco pixelfly with evergreen or LD-PS
	put('camera_type','pco_pixelfly'); % Exposure start -> Q1 delay
	put('f1exp',406); % Exposure start -> Q1 delay
	put('f1exp_cam',400); %exposure time setting first frame
	put('master_freq',15);
	put('binning',1);
	avail_freqs={'5' '3' '1.5' '1'};
	put('max_cam_res',[1392,1040]);
	put('min_allowed_interframe',10);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if value == 2 || value == 4% pco panda with evergreen or LD-PS
	put('camera_type','pco_panda');
	put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	put('f1exp_cam',350); %exposure time setting first frame
	put('master_freq',50); %war auf 50 f�r noch h�here framerates auf panda
	avail_freqs={'50' '30' '15' '7.5' '5' '3' '1.5' '1'};
	put('max_cam_res',[5120,5120]);
	put('min_allowed_interframe',10);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if value == 5 % chronos LD-PS
	put('camera_type','chronos');
	put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	put('f1exp_cam',350); %exposure time setting first frame
	put('master_freq',15);
	avail_freqs={'1000' '850' '600' '500' '400' '300' '200' '150' '100' '70' '50' '25' '10' '5'};
	put('max_cam_res',[1280,1024]);
	put('min_allowed_interframe',10);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if value == 6 % basler
	put('camera_type','basler');
	put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	put('f1exp_cam',350); %exposure time setting first frame
	put('master_freq',15);
	avail_freqs={'168' '100' '75' '60' '50' '25' '10'};
	put('max_cam_res',[2048,1088]);
	put('min_allowed_interframe',150);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if value == 7 % Flir
	put('camera_type','flir');
	put('f1exp',352) % Exposure start -> Q1 delay
	%disp('testing laserdiode')
	%put('f1exp_cam',300)
	%put('master_freq',3);
	put('f1exp_cam',350); %exposure time setting first frame
	put('master_freq',15);
	avail_freqs={'60' '50' '40' '30' '20' '10'};
	put('max_cam_res',[1440,1080]);
	put('min_allowed_interframe',470);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end
if value == 8 % OPTOcam
	put('camera_type','OPTOcam');
	put('f1exp',352) % Exposure start -> Q1 delay
	put('f1exp_cam',350); %exposure time setting first frame
	put('master_freq',15);
	avail_freqs={'160' '100' '75' '60' '50' '25' '10'};
	put('max_cam_res',[1936,1216]);
	put('min_allowed_interframe',50);
	set(handles.ac_fps,'string',avail_freqs);
	%if get(handles.ac_fps,'value') > numel(avail_freqs)
	if old_setting ~= value
		set(handles.ac_fps,'value',numel(avail_freqs))
	end
	%end
end


ac_expo_Callback

function ac_expo_Callback(~,~,~)
handles=gethand;
camera_type=retr('camera_type');
if strcmp(camera_type,'pco_pixelfly')
	if str2double(get(handles.ac_expo,'String')) < 1
		set(handles.ac_expo,'String','1')
	end
	if str2double(get(handles.ac_expo,'String')) > 2000
		set(handles.ac_expo,'String','2000')
	end
end
if strcmp(camera_type,'pco_panda')
	if str2double(get(handles.ac_expo,'String')) < 6
		set(handles.ac_expo,'String','6')
	end
	if str2double(get(handles.ac_expo,'String')) > 350
		set(handles.ac_expo,'String','350')
	end
end
if strcmp(camera_type,'chronos')
	if str2double(get(handles.ac_expo,'String')) < 0.1
		set(handles.ac_expo,'String','0.1')
	end
	if str2double(get(handles.ac_expo,'String')) > 100000
		set(handles.ac_expo,'String','100000')
	end
end
if strcmp(camera_type,'basler')
	if str2double(get(handles.ac_expo,'String')) < 0.05
		set(handles.ac_expo,'String','0.05')
	end
	if str2double(get(handles.ac_expo,'String')) > 1000
		set(handles.ac_expo,'String','1000')
	end
end

function bg_subtract_Callback (~,~,~)
handles=gethand;
if get(handles.bg_subtract,'Value')==0
	%remove the background image. Needs to be done for ensemble correlation to work properly
	put('bg_img_A',[]);
	put('bg_img_B',[]);
end

function ac_chronosctrl_Callback(~,~,~)
camera_type=retr('camera_type');
if strcmp(camera_type,'chronos')
	PIVlab_capture_chronos_settings_GUI
else
	uiwait(msgbox('Available for Chronos cameras only.','modal'))
end

function ac_lensctrl_Callback (~,~,~)
handles=gethand;
PIVlab_capture_lensctrl_GUI

function pos = customWait(hROI)
% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@ROIclickCallback);
% Block program execution
uiwait;
% Remove listener
delete(l);
% Return the current position
pos = hROI.Position;


function ROIclickCallback(~,evt)
if strcmp(evt.SelectionType,'double')
	uiresume;
end

function ROIallevents(src,evt)
%src.Position = round(evt.CurrentPosition ,-1);
src.Position = floor(evt.CurrentPosition/8)*8;

if src.Position(1)<0.5
	src.Position(1) = 0.5;
end
if src.Position(2)<0.5
	src.Position(2) = 0.5;
end
evname = evt.EventName;
switch(evname)
	case{'MovingROI'}
		src.Label =([int2str(ceil(evt.PreviousPosition(1))) ' ' int2str(ceil(evt.PreviousPosition(2))) ' ' int2str(ceil(evt.PreviousPosition(3))) ' ' int2str(ceil(evt.PreviousPosition(4)))]);
	case{'ROIMoved'}
		src.Label =([int2str(ceil(evt.CurrentPosition(1))) ' ' int2str(ceil(evt.CurrentPosition(2))) ' ' int2str(ceil(evt.CurrentPosition(3))) ' ' int2str(ceil(evt.CurrentPosition(4)))]);
end

function setdefaultroi(source,~)
if ~isempty(retr('doing_roi')) && retr('doing_roi')==1
	ac_ROI_general_handle = findobj('tag','new_ROImethod');
	binning=retr('binning');
	max_cam_res =retr('max_cam_res');
	if isempty(binning)
		binning=1;
	end
	selection=1; %automatic centering of ROI
	switch source.Label
		case 'pco.panda 50 Hz'
			des_x=320;
			des_y=240;
		case 'pco.panda 30 Hz'
			des_x=640;
			des_y=480;
		case 'pco.panda 15 Hz'
			des_x=1160;
			des_y=864;
		case 'pco.panda 7.5 Hz'
			des_x=2352;
			des_y=1824;
		case 'pco.panda 5 Hz'
			des_x=3464;
			des_y=2728;%2624;
		case 'pco.panda 3 Hz'
			des_x=4488;
			des_y=3320;
		case 'pco.panda 1 Hz'
			des_x=5120;
			des_y=5120;

		case 'Basler 2048x1088'
			des_x=2048;
			des_y=1088;
		case 'Basler 1280x720'
			des_x=1280;
			des_y=720;
		case 'Basler 1024x1024'
			des_x=1024;
			des_y=1024;
		case 'Basler 640x480'
			des_x=640;
			des_y=480;


		case 'Enter ROI'
			prompt = {'x','y','w','h'};
			dlgtitle = 'ROI';
			dims = [1 15];
			current_pos=get(ac_ROI_general_handle,'Position');
			definput = {num2str(current_pos(1)),num2str(current_pos(2)),num2str(current_pos(3)),num2str(current_pos(4))};
			answer = inputdlg(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				selection=2; %manual x and y coordinates
				des_x=str2num(answer{3});
				des_y=str2num(answer{4});
				min_x=str2num(answer{1});
				min_y=str2num(answer{2});
				img_size=[des_x des_y];
			else
				des_x=max_cam_res(1);
				des_y=max_cam_res(2);
			end
	end
	if selection==1
		img_size=[des_x/binning des_y/binning]; %must be even, %X Y
		min_x=(max_cam_res(1)/binning-img_size(1))/2+1;
		min_y=(max_cam_res(2)/binning-img_size(2))/2+1;
	end
	set(findobj('tag','new_ROImethod'), 'Position',[min_x,min_y,img_size(1),img_size(2)])
	evt.EventName='ROIMoved';
	evt.CurrentPosition=[min_x,min_y,img_size(1),img_size(2)];
	ROIallevents(ac_ROI_general_handle,evt)
end