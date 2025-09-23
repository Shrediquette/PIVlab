% PIVlab - Digital Particle Image Velocimetry Tool for MATLAB
% initiated by by Dr. William Thielicke and Prof. Dr. Eize J. Stamhuis
% developed by William Thielicke
% http://PIVlab.blogspot.com
% Third party content, thank you for your contributions!
% 3-point gaussian sub-pixel estimator by Uri Shavit, Roi Gurka, Alex Liberzon
% inpaint_nans by John D'Errico
% uipickfiles by Douglas Schwarz
% smoothn, dctn, idctn by Damien Garcia
% Exportfig by Ben Hinkle
% mmstream2 by Duane Hanselman
% f_readB16 by Carl Hall
% natsort, natsortfiles by Stephen23
%% TODO:

function PIVlab_GUI(desired_num_cores,batch_session_file)
%% display splash screen in deployed version
%isdeployed=1 %debug splash screen
if isdeployed
	splashscreen = figure('integerhandle','off','resize','off','windowstyle','modal','numbertitle','off','MenuBar','none','DockControls','off','Name','PIVlab standalone','Toolbar','none','Units','pixels','Position',[10 10 150 150],'tag','splashscreen','visible','off','handlevisibility','on');
	%splashscreen = figure('integerhandle','off','resize','off','numbertitle','off','MenuBar','none','DockControls','off','Name','PIVlab standalone','Toolbar','none','Units','pixels','Position',[10 10 100 100],'tag','splashscreen','visible','off','handlevisibility','on');
	splash_ax=axes(splashscreen,'units','normalized');
	imshow(imread(fullfile('images','pivlab_standalone_splashscreen_2.jpg')),'Parent',splash_ax,'border','tight');
	set(splash_ax,'Position',[0 0 1 1])
	set(gca,'DataAspectRatioMode','auto')
	movegui(splashscreen,'center');
	set(splashscreen,'visible','on')
	handle_splash_text = text(splash_ax,300,590,'Generating figure window, please wait...','Color','w','VerticalAlignment','bottom','HorizontalAlignment','center','FontName','FixedWidth','Fontweight','bold','FontSize',9,'Interpreter','none');
	drawnow expose
end
%% Make figure
fh = findobj('tag', 'hgui');
if isempty(fh)
	disp('-> Starting PIVlab...')
	MainWindow = figure('numbertitle','off','MenuBar','none','Windowstyle','normal','DockControls','off','Name','INITIALIZING...','Toolbar','none','Units','normalized','Position',[0 0.1 1 0.8],'ResizeFcn', @gui.MainWindow_ResizeFcn,'CloseRequestFcn', @gui.MainWindow_CloseRequestFcn,'tag','hgui','visible','off','KeyPressFcn', @gui.key_press);
    set (MainWindow,'Units','Characters');
    try
        set (MainWindow,'icon',fullfile('images','appicon.png'));
    catch
    end
    movegui(MainWindow,'center');
    %clc
	%% Initialize
	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(MainWindow,handles)
	setappdata(0,'hgui',MainWindow);
	version = '3.12';
	gui.put('PIVver', version);
	try
		warning off
		load('PIVlab_settings_default.mat','build_date');
		warning on
	catch
		build_date=' ';
	end

	if ~exist ('build_date','var')
		build_date=' ';
	end
	if isempty(build_date)
		build_date=' ';
	else
	end

	v=ver('MATLAB'); %#ok<*VERMATLAB>

	if ~exist('desired_num_cores','var')
		if ~isdeployed
			disp('-> Use the command "PIVlab_GUI(Nr_of_cores)" to select the amount of computation cores.')
		end
	end

	if ~exist('splash_ax','var')
		disp(['-> PIVlab ' version ', built on: ' char(datetime(build_date)) ' ...'])
		disp(['-> Using MATLAB version ' v.Version ' ' v.Release ' on ' computer '.'])
	else
		text_content=get(handle_splash_text,'String');
		set (handle_splash_text, 'String',[text_content newline '-> Starting PIVlab ' version ' ...' newline '-> Using MATLAB version ' v.Version ' ' v.Release ' on ' computer '.']);drawnow
	end

	margin=1.5;%1.5; %for Matlab 2025 this probably needs to be increased to 2.5, together with more fixes on all panels...
	panelwidth=45;
	panelheighttools=13;%12;
	panelheightpanels=45;%35;
	do_correlation_matrices=0; % enable or disable the output of raw correlation matrices
	gui.put('do_correlation_matrices',do_correlation_matrices);
	gui.put('panelwidth',panelwidth);
	gui.put('margin',margin);
	gui.put('panelheighttools',panelheighttools);
	gui.put('panelheightpanels',panelheightpanels);
	gui.put('quickwidth',panelwidth);
	gui.put('quickheight',3.5);
	gui.put('quickvisible',1);
	gui.put('alreadydisplayed',0);
	gui.put('video_selection_done',0);
	if ~verLessThan('Matlab','25') %#ok<*VERLESSMATLAB>
		if ispref('PIVlab_ad','dark_mode_theme')
			gui.put('darkmode',getpref('PIVlab_ad','dark_mode_theme'));
			if getpref('PIVlab_ad','dark_mode_theme') == 1
				MainWindow.Theme = 'dark';
			else
				MainWindow.Theme = 'light';
			end
		else
			theme=MainWindow.Theme;
			if strcmpi(theme.BaseColorStyle,'dark')
				gui.put('darkmode',1);
			end
		end
	else
		gui.put('darkmode',0);
	end
	%% check write access
	disp(['-> User path is ' userpath]);
	try
		temp=rand(3,3);
		save(fullfile(userpath,'temp.mat' ),'temp');
		if ispc %Matlab seems to have issues with deleting files on unix systems
			delete (fullfile(userpath,'temp.mat' ))
		end
		if ~exist('splash_ax','var')
			disp('-> Write access in current folder ok.')
		else
			text_content=get(handle_splash_text,'String');
			text_content{end+1} = '-> Write access in current folder ok.';
			set (handle_splash_text, 'String',text_content);drawnow
		end

	catch
		if isdeployed
			uiwait(msgbox(['No write access in ' userpath newline newline 'PIVlab will not work properly like this.' newline 'Please make sure that there is write permission for the folder ' userpath ],'modal'));
		else
			disp(['-> No write access in ' pwd '. PIVlab won''t work like this.'])
			disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
			beep;commandwindow;pause
		end
	end


	%% Load defaults
	try
		psdfile=which('PIVlab_settings_default.mat');
		dindex=strfind(psdfile,filesep); %filesep ist '\'
		import.read_panel_width('PIVlab_settings_default.mat',psdfile(1:(dindex(end)-1)));
	catch
		try
			disp(['Could not load default settings in this path: ' psdfile(1:(dindex(end)-1))])
		catch
		end
		disp('Could not load default settings. But this doesn''t really matter.')
	end
	%% check required package folders
	tempfilepath = fileparts(which('PIVlab_GUI.m'));
	addpath(tempfilepath);
	addpath(fullfile(tempfilepath, 'images'));
	addpath(fullfile(tempfilepath, 'help'));
	addpath(fullfile(tempfilepath, 'PIVlab_capture_resources'));
	addpath(fullfile(tempfilepath, 'PIVlab_capture_resources','pco_resources'));
	try
		ctr=0;
		pivFiles = {'+acquisition' '+calibrate' '+export' '+extract' '+gui' '+import' '+mask' '+misc' '+piv' '+plot' '+postproc' '+preproc' '+roi' '+simulate' '+validate' '+wOFV' 'OptimizationSolvers' 'PIVlab_capture_resources'};
		for i=1:size(pivFiles,2)
			if exist(fullfile(tempfilepath,pivFiles{1,i}),'dir')~=7
				disp(['ERROR: A required package folder was not found: ' pivFiles{1,i}]);
				disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
				if ~isdeployed
					beep;commandwindow;pause
				end
			else
				ctr=ctr+1;
			end
		end
		if ctr==size(pivFiles,2)
			if ~exist('splash_ax','var')
				disp('-> All required package folders found.')
			else
				text_content=get(handle_splash_text,'String');
				text_content{end+1}='-> All required package folders found.';
				set (handle_splash_text, 'String',text_content);drawnow
			end

		end
	catch
		disp('-> Problem detecting required package folders.')
	end
	%%
	gui.generateUI
	gui.generateMenu

	%% Prepare axes
	gui.switchui('multip01');
	pivlab_axis=axes('units','characters','parent',MainWindow);
	axis image;
	set(gca,'ActivePositionProperty','outerposition');%,'Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');
	set(MainWindow, 'Name',['PIVlab ' gui.retr('PIVver')])% ' by William Thielicke and Eize J. Stamhuis'])
	gui.put('pivlab_axis',pivlab_axis);
	%%
	misc.Lena
	%% Check Matlab version
	try
		if verLessThan('matlab', '9.7') == 0
			if ~exist('splash_ax','var')
				disp('-> Matlab version check ok.')
			else
				text_content=get(handle_splash_text,'String');
				text_content{end+1}='-> Matlab version check ok.';
				set (handle_splash_text, 'String',text_content);drawnow
			end

		else
			disp('WARNING: Your Matlab version is too old for running PIVlab.')
			disp('WARNING: You need at least version 9.7 (R2019b) to use all features.')
			disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
			if ~isdeployed
				beep;commandwindow;pause
			end
		end
	catch
		disp('MATLAB version could not be checked automatically.')
		disp('WARNING: You need at least version 9.7 (R2019b) to use all features.')
		disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
		if ~isdeployed
			beep;commandwindow;pause
		end
	end
	%% Check image toolbox availability
	try
		result=license('checkout','Image_Toolbox');
		if result == 1
			try
				J = adapthisteq(rand(8,8)); %#ok<NASGU>
				if ~exist('splash_ax','var')
					disp('-> Image Processing Toolbox found.')
				else
					text_content=get(handle_splash_text,'String');
					text_content{end+1}='-> Image Processing Toolbox found.';
					set (handle_splash_text, 'String',text_content);drawnow
				end

			catch
				disp(' ')
				disp('Image Processing Toolbox not accessible! PIVlab won''t work like this.')
				disp('A license has been found, but the toolbox could not be accessed.')
				disp('This is not a PIVlab related issue. Before you can use PIVlab, you need to make sure that the following command can be run without error message from the MATLAB command line:')
				disp('"J = adapthisteq(rand(8,8))" (enter this without quotes)')
				disp(' ')
				disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
				if ~isdeployed
					beep;commandwindow;pause
				end
			end
		else
			disp('ERROR: Image Processing Toolbox not found! PIVlab won''t work like this.')
			disp('Press any key to continue... (but remember, PIVlab won''t work like this...)')
			if ~isdeployed
				beep;commandwindow;pause
			end
		end
		%% Check parallel computing toolbox availability
		gui.put('parallel',0);
		try %checking for a parallel license file throws a huge error message wheh it is not available. This might scare users... Better: Try...catch block
			if ~exist('desired_num_cores','var') %no input argument --> use all existing cores
				if misc.pivparpool('size')<=0 %no exisitng pool
					%if isdeployed
						answer = questdlg(['PIVlab can be run with parallel computing.' newline newline '- Recommended when processing multiple images.' newline '- Not required when acquiring images or processing mp4 and avi files.' newline newline 'Open parallel pool?'],'Parallel processing', 'Yes', 'No','Yes');
						switch answer
							case 'Yes'
								misc.pivparpool('open',maxNumCompThreads('automatic')); %use matlab suggested num of cores
								gui.put('parallel',1);
							case 'No'
						end
					%else
					%	misc.pivparpool('open',maxNumCompThreads('automatic')); %use all cores
					%	gui.put('parallel',1);
					%end
				end
			else%parameter supplied
				if ~isnumeric(desired_num_cores)
					disp('You need to enter a number for the amount of cores, e.g. PIVlab_GUI(4)')
					beep;
					disp('Press a key to continue.')
					pause
					misc.pivparpool('close')
					gui.put('parallel',0);
				else
					if desired_num_cores > 1 && desired_num_cores ~= misc.pivparpool('size') %desired doesn't match existing pool
						if desired_num_cores > maxNumCompThreads%desired too many cores
							desired_num_cores=maxNumCompThreads;
							disp('Selected too many cores. Adjusted to actually existing cores')
						end
						misc.pivparpool('close')
						misc.pivparpool('open',desired_num_cores);
						gui.put('parallel',1);
					elseif desired_num_cores < 2 %leq than 1 core desired --> serial processing.
						misc.pivparpool('close')
						gui.put('parallel',0);
					elseif desired_num_cores==misc.pivparpool('size')
						gui.put('parallel',1);
					end
				end
			end
			if gui.retr('parallel')==1
				if ~exist('splash_ax','var')
					disp(['-> Distributed Computing Toolbox found. Parallel pool (' int2str(misc.pivparpool('size')) ' workers) active (default settings).'])
				else
					text_content=get(handle_splash_text,'String');
					text_content{end+1}=['-> Distributed Computing Toolbox found.' newline '-> Parallel pool (' int2str(misc.pivparpool('size')) ' workers) active (default settings).'];
					set (handle_splash_text, 'String',text_content);drawnow;pause(1)
				end

			else
				if ~exist('splash_ax','var')
					disp('-> Distributed Computing disabled.')
				else
					text_content=get(handle_splash_text,'String');
					text_content{end+1}='-> Distributed Computing disabled.';
					set (handle_splash_text, 'String',text_content);drawnow;pause(1)
				end

			end
		catch
			disp('-> Running without parallelization (no distributed computing toolbox installed).')
		end

		handles=gui.gethand;
		load (fullfile('images','icons.mat'),'parallel_off','parallel_on');
		if gui.retr('darkmode')
			parallel_on=1-parallel_on+35/255;
			parallel_off=1-parallel_off+35/255;
			parallel_on(parallel_on>1)=1;
			parallel_off(parallel_off>1)=1;
		end
		if gui.retr('parallel') == 1
			set(handles.toggle_parallel, 'cdata',parallel_on,'TooltipString','Parallel processing on. Click to turn off.');
		else
			set(handles.toggle_parallel, 'cdata',parallel_off,'TooltipString','Parallel processing off. Click to turn on.');
		end

	catch
		disp('Toolboxes could not be checked automatically. You need the Image Processing Toolbox.')
	end

	%% Variable initialization
	gui.put ('toggler',0);
	gui.put('calu',1);
	gui.put('calv',1);
	gui.put('calxy',1);
	gui.put('offset_x_true',0)
	gui.put('offset_y_true',0)
	gui.put('subtr_u', 0);
	gui.put('subtr_v', 0);
	gui.put('displaywhat',1);%vectors


	%% read current and last directory.....:
	warning('off','all') %if the variables don't exist, an ugly warning is displayed
	load('PIVlab_settings_default.mat','homedir');
	load('PIVlab_settings_default.mat','pathname');
	warning('on','all')
	warning('off','serialport:serialport:ReadlineWarning')
	if ~exist('pathname','var') || ~exist('homedir','var')
		try
			if exist(fullfile(fileparts(which('PIVlab_GUI.m')), 'Example_data'),'dir') == 7 %if no previous path -> check if example dir exists
				homedir =fullfile(fileparts(which('PIVlab_GUI.m')), 'Example_data'); %... and use it as default
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
	gui.put('homedir',homedir);
	gui.put('pathname',pathname);
	save('PIVlab_settings_default.mat','homedir','pathname','-append');

	%% Read and apply default settings
	try
		%XP Wu modification:
		psdfile=which('PIVlab_settings_default.mat');
		dindex=strfind(psdfile,filesep); %filesep ist '\'
		%erstes argument datei, zweites pfad bis zum letzten fileseperator.
		import.read_settings('PIVlab_settings_default.mat',psdfile(1:(dindex(end)-1)));
		if ~exist('splash_ax','var')
			disp(['-> Got default settings from: ' psdfile])
		else
			text_content=get(handle_splash_text,'String');
			text_content{end+1}='-> Got default settings from:';
			text_content{end+1}=psdfile;
			set (handle_splash_text, 'String',text_content);drawnow
		end
	catch
		disp('Could not load default settings. But this doesn''t really matter.')
	end

	misc.CheckUpdates
    if isdeployed || exist('splash_ax','var')
        pause(1)
        close(splashscreen)
    end
    gui.SetFullScreen
    gui.displogo(1);

    %% Apply fix for wrong UI scaling introduced between matlab 2025a prerelease5 and Matlab2025a
    try
        if ~isMATLABReleaseOlderThan("R2025a") && isMATLABReleaseOlderThan("R2025b")
            gui.fix_R2025a_GUI_sizing
            disp('-> Applied GUI scaling bug fix for release 2025a...')
        end
    catch
    end

    set(MainWindow, 'Visible','on');drawnow;
    
	%% Batch session  processing in GUI
	if ~exist('batch_session_file','var') %no input argument --> no GUI batch processing
		gui.put('batchModeActive',0)
	else
		if exist (batch_session_file,'file')
			gui.put('batchModeActive',1)
			[filepath,name,ext] = fileparts(batch_session_file);
			import.load_session_Callback (1,batch_session_file)
			disp('')
			disp(['Batch mode, analyzing ' batch_session_file])
			batch_session_file_output=fullfile(filepath,[name '_BATCH' ext]);
			disp(['Output will be saved as:  ' batch_session_file_output ])
			disp('...running PIV analysis...')
			piv.do_analys_Callback
			piv.AnalyzeAll_Callback
			disp('...running post processing...')
			validate.apply_filter_all_Callback
			disp('...saving output...')
			export.save_session_Callback(1,batch_session_file_output)
			disp('done, exiting...')
			gui.MainWindow_CloseRequestFcn
		else
			disp(['NOT FOUND: ' batch_session_file])
			gui.put('batchModeActive',0)
		end
	end

else %Figure handle does already exist --> bring PIVlab to foreground.
	disp('Only one instance of PIVlab is allowed to run.')
	figure(fh)
end
