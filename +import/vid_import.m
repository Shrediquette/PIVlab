% Video file selection, startframe, endframe and skipping of frames for PIVlab
% convert_mode = 0 (default): legacy on-the-fly video reading (deprecated).
% convert_mode = 1: extract the selected frames to lossless grayscale image
%                   files on disk, so they can be loaded like a normal image
%                   sequence (recommended, keeps parallel processing etc.).
function vid_import(pathname,convert_mode)
if nargin < 1
	pathname=pwd;
end
if nargin < 2 || isempty(convert_mode)
	convert_mode=0;
end

big_scroll = 30;
click = 0;
f = 1;  %current frame
video_start=1;
video_end=1;
skip_frame=1;
frame_selection=[];
filename=[];
video_pathname=[];
video_loaded = 0;
is_scrolling = false;      %re-entrancy guard: discard new scroll events while one is in progress
cancel_conversion = false; %set by the cancel button during frame conversion
%% Make figure
%NOTE: do NOT set 'BusyAction','cancel' on this figure. It would also discard
%the WindowButtonUpFcn (button_up) event when it arrives during a slow frame
%read, leaving 'click' stuck at 1 so the slider stays glued to the pointer
%after release. Stale scrollbar events are instead dropped by the
%'is_scrolling' re-entrancy guard in on_click (see below).
fig_handle = figure('MenuBar','none', 'Toolbar','none', 'Units','characters', 'WindowButtonDownFcn',@button_down, 'WindowButtonUpFcn',@button_up,  'WindowButtonMotionFcn', @on_click,'KeyPressFcn', @key_press,'Name','Video preview','numbertitle','off','Visible','off','Windowstyle','modal','resize','off','dockcontrol','off');
fig_handle.Position(3)=100;
fig_handle.Position(4)=30;
warning('off','MATLAB:TIMER:RATEPRECISION')

%% Initialize
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(fig_handle,handles)
setappdata(0,'fig_handle',fig_handle);
movegui(fig_handle,'center')
set(fig_handle, 'Visible','on');

margin=1;
parentitem=get(fig_handle, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.selectvideo = uicontrol(fig_handle,'Style','pushbutton','String','Select video file','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@select_Callback, pathname},'Tag','selectvideo','TooltipString','Select video file');
item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];
handles.text1 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Start frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.startframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1','Tag','startframe','Callback',@startframe_change,'enable','off');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text2 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','End frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.endframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1','Tag','endframe','Callback',@endframe_change,'enable','off');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text3 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Process every nth frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.skipframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1','Tag','skipframe','Callback',@skipframe_change,'enable','off');
item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];
handles.text4 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Preview frame nr.: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
item=[0 item(2)+item(4)+margin parentitem(3) 2];
if convert_mode==1
	importbutton_label='Convert & import frames';
	importbutton_tooltip='Convert the selected frames to lossless grayscale image files, then load them';
else
	importbutton_label='Import video frames';
	importbutton_tooltip='Import video frames';
end
handles.importvideo = uicontrol(fig_handle,'Style','pushbutton','String',importbutton_label,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import_Callback,'Tag','importvideo','TooltipString',importbutton_tooltip,'enable','off');
item=[0 item(2)+item(4)+margin parentitem(3) 13];
axes_handle=axes('Parent',fig_handle,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);
axis image;
set(axes_handle,'ActivePositionProperty','outerposition');%,'Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');

%axes for scroll bar
fig_size = get(fig_handle, 'Position');
scroll_axes_handle = axes('Parent',fig_handle, 'Units', 'characters', 'Position',[0 0 fig_size(3) 2], 'Visible','off');
axis([0 1 0 1]);
axis off
%scroll bar
scroll_bar_width = max(1 / 10, 0.02);
scroll_handle = patch([0 1 1 0] * scroll_bar_width, [0 0 1 1], [.5 .5 .5], 'Parent',scroll_axes_handle, 'EdgeColor','none', 'ButtonDownFcn', @on_click);

%framenrdisplay
frametext = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[0,2,60,1],'String',['Frame Nr.: 1/' num2str(1)]);


%videofile='xylophone.mpg';
%v = VideoReader(videofile);
%play_fps = v.FrameRate;
%num_frames=v.NumberOfFrames;
%scroll_bar_width = max(1 / num_frames, 0.02);

v = [];
play_fps = 1;
num_frames=1;
scroll_bar_width = 0.5;

%timer to play video
axes (axes_handle)

h_fig=imshow(imread(fullfile('images','vid_hint.jpg')),'Interpolation','bilinear');drawnow
play_timer = timer('TimerFcn',@play_timer_callback, 'ExecutionMode','fixedRate','busymode','drop');
scroll_bar_handles = [scroll_axes_handle; scroll_handle];
scroll_func = @scroll;
video_loaded=0;


	function startframe_change (~,~,~)
		if video_loaded
			handles=guihandles(fig_handle);
			if floor(str2double(get(handles.startframe,'String'))) ~= (str2double(get(handles.startframe,'String'))) %check if integer
				set(handles.startframe,'String','1');
			else
				if str2double(get(handles.startframe,'String')) <=0
					set(handles.startframe,'String','1');
				end
				num_frames=floor((str2double(get(handles.endframe,'String')) - (str2double(get(handles.startframe,'String'))-1))/ str2double(get(handles.skipframe,'String')));
				scroll_bar_width = max(1 / num_frames, 0.02);
				video_start=str2double(get(handles.startframe,'String'));
				frame_selection = [video_start:skip_frame:video_end];
			end
			scroll(1)
		end
	end

	function endframe_change (~,~,~)
		if video_loaded
			handles=guihandles(fig_handle);
			if floor(str2double(get(handles.endframe,'String'))) ~= (str2double(get(handles.endframe,'String'))) %check if integer
				set(handles.endframe,'String',num2str(v.NumberOfFrames));
			else
				if str2double(get(handles.endframe,'String')) <=0
					set(handles.endframe,'String','1');
				end
				if str2double(get(handles.endframe,'String')) > v.NumberOfFrames
					set(handles.endframe,'String',num2str(v.NumberOfFrames));
				end
				num_frames=floor((str2double(get(handles.endframe,'String')) - (str2double(get(handles.startframe,'String'))-1))/ str2double(get(handles.skipframe,'String')));
				scroll_bar_width = max(1 / num_frames, 0.02);
				video_end=str2double(get(handles.endframe,'String'));
				frame_selection = [video_start:skip_frame:video_end];
			end
			scroll(1)
		end
	end

	function skipframe_change (~,~,~)
		if video_loaded
			handles=guihandles(fig_handle);
			if floor(str2double(get(handles.skipframe,'String'))) ~= (str2double(get(handles.skipframe,'String'))) %check if integer
				set(handles.skipframe,'String','1');
			else
				if str2double(get(handles.skipframe,'String')) < 1
					set(handles.skipframe,'String','1');
				end
				num_frames=floor((str2double(get(handles.endframe,'String')) - (str2double(get(handles.startframe,'String'))-1))/ str2double(get(handles.skipframe,'String')));
				scroll_bar_width = max(1 / num_frames, 0.02);
				skip_frame = str2double(get(handles.skipframe,'String'));
				frame_selection = [video_start:skip_frame:video_end];
			end
			scroll(1)
		end
	end

	function select_Callback(~,~,pathname)
		fig_handle=getappdata(0,'fig_handle');
		handles=guihandles(fig_handle);
		%[filename,video_pathname] = uigetfile({'*.mp4';'*.avi';'*.mpg';'*.mpeg';'*.wmv';'*.mov';'*.*'},'Video File Selector',pathname);
		[filename,video_pathname] = uigetfile({'*.mp4;*.avi;*.mpg;*.mpeg;*.wmv;*.mov','Video Files (*.mp4,*.avi,*.mpg,*.mpeg,*.wmv,*.mov)';'*.*','All Files'},'Video File Selector',pathname);
		if ~isequal(filename,0)
			video_loaded = 1;
			%Opening the video (VideoReader + counting frames + first decode) can
			%take several seconds. Show the user that something is happening.
			set(fig_handle,'Pointer','watch');
			set(handles.selectvideo,'String','Opening video...','Enable','off');
			set(frametext,'String',['Opening "' filename '", please wait...']);
			drawnow
			% videofile='xylophone.mpg';
			success=0;
			try
				v = VideoReader(fullfile(video_pathname,filename));
				success=1;
			catch ME
				success=0;
			end
			if success==1
				play_fps = v.FrameRate;
				num_frames=v.NumberOfFrames;
				scroll_bar_width = max(1 / num_frames, 0.02);
				video_end=num_frames;
				
				if isnan(v.Height)
					fprintf('Failed to create video object.\n');
				else
					axes (axes_handle)
					h_fig=imshow(read(v,1));drawnow
					set(handles.startframe,'String', num2str(1))
					set(handles.endframe,'String', num2str(num_frames))
					set(handles.skipframe,'String', num2str(1))
					frame_selection = [1:1:num_frames];
					scroll(1)
					set(handles.importvideo,'enable','on')
					set(handles.startframe,'enable','on')
					set(handles.endframe,'enable','on')
					set(handles.skipframe,'enable','on')
				end
			else
                modal_safe_msgbox('error',getappdata(0,'hgui'),'Error',{'Matlab could not import this video file. Most likely, the video codec cannot be used by Matlab. This is not a PIVlab-related issue. The exact error message is: ' sprintf('\n') ME.identifier sprintf('\n') ME.message},'modal');
			end
			%restore the "Select video file" button and normal cursor
			set(fig_handle,'Pointer','arrow');
			set(handles.selectvideo,'String','Select video file','Enable','on');
		end

	end


	function key_press(src, event)  %#ok, unused arguments
		if video_loaded
			switch event.Key  %process shortcut keys
				case 'leftarrow'
					scroll(f - 1);
					stop(play_timer);
				case 'rightarrow'
					scroll(f + 1);
					stop(play_timer);
				case 'downarrow'
					if f - big_scroll < 1  %scrolling before frame 1, stop at frame 1
						scroll(1);
					else
						scroll(f - big_scroll);
					end
					stop(play_timer);
				case 'uparrow'
					if f + big_scroll > num_frames  %scrolling after last frame
						scroll(num_frames);
					else
						scroll(f + big_scroll);
					end
					stop(play_timer);
				case 'home'
					scroll(1);
					stop(play_timer);
				case 'end'
					scroll(num_frames);
					stop(play_timer);
				case 'space'
					play(1/play_fps)
				case 'backspace'
					play(5/play_fps)
			end
		end
	end

%mouse handler
	function button_down(src, event)  %#ok, unused arguments
		if video_loaded
			%set(src,'Units','norm')
			
			click_pos = get(src, 'CurrentPoint');
			if click_pos(2) <= 2%0.03  %only trigger if the scrollbar was clicked
				click = 1;
				on_click([],[]);
			end
			stop(play_timer);
		end
	end

	function button_up(src, event)  %#ok, unused arguments
		click = 0;
	end

	function on_click(src, event)  %#ok, unused arguments
		if video_loaded
			if click == 0, return; end
			if is_scrolling, return; end %already busy reading a frame -> discard this event instead of queueing it
			is_scrolling = true;

			%get x-coordinate of click
			%set(fig_handle, 'Units', 'normalized');
			click_point = get(fig_handle, 'CurrentPoint')/fig_size(3);
			%set(fig_handle, 'Units', 'pixels');
			x = click_point(1);

			%get corresponding frame number
			new_f = floor(1 + x * num_frames);

			if new_f >= 1 && new_f <= num_frames && new_f ~= f && new_f < num_frames
				%don't redraw if the frame is the same (to prevent delays)
				try
					scroll(new_f);
				catch
				end
			end
			is_scrolling = false;
		end
	end

	function play(period)
		%toggle between stoping and starting the "play video" timer
		if strcmp(get(play_timer,'Running'), 'off')
			set(play_timer, 'Period', period);
			start(play_timer);
		else
			stop(play_timer);
		end
	end
	function play_timer_callback(src, event)  %#ok
		%executed at each timer period, when playing the video
		if f < num_frames
			%scroll(f + 1);
			scroll(f + skip_frame);
		elseif strcmp(get(play_timer,'Running'), 'on')
			stop(play_timer);  %stop the timer if the end is reached
		end
	end

	function scroll(new_f)
		if video_loaded
			if nargin == 1  %scroll to another position (new_f)
				if new_f < 1 || new_f > num_frames
					return
				end
				f = new_f;
			end
			%was soll es tun:
			%video soll nicht weiter vorgespult werden können als startframe.
			%Dann soll scrollbar ganz links sein
			%Und nicht weiter nach rechts spulen als enframe.
			%dann scrollbar ganz rechts.
			%skipframes soll auch berücksichtigt werden
			%Das video soll also so angezeigt werden, als ging ee snur von start bis
			%end mit skip frames.
			
			%convert frame number to appropriate x-coordinate of scroll bar
			%scroll_x = (f - 1) / num_frames; %[0...1]
			
			scroll_x = (f - 1) / num_frames; %[0...1]
			
			%move scroll bar to new position
			set(scroll_handle, 'XData', scroll_x + [0 1 1 0] * scroll_bar_width);
			
			set(fig_handle, 'CurrentAxes', axes_handle);
			try
				%set(h_fig,'CData',read(v,f+video_start-1));
				set(h_fig,'CData',read(v,frame_selection(f)));
			catch
			end
			set (frametext,'String', ['frame nr.: ' int2str(frame_selection(f)) ', total frames: ' int2str(num_frames)])
			pause(0.001)
		end
	end

	function import_Callback(~,~,~)
		fig_handle=getappdata(0,'fig_handle');
		hgui=getappdata(0,'hgui');
		if convert_mode==1
			convert_to_disk_Callback();
			return
		end
		%Video must haven even nr. of frames, so frames can be arranged in pairs
		frame_selection_out=frame_selection(1);
		for i= 2:numel(frame_selection)
			frame_selection_out (end+1,1) = frame_selection(i);
			frame_selection_out (end+1,1) = frame_selection(i);
		end
		frame_selection_out(end)=[];
		if mod(numel(frame_selection_out),2)==1
			cutoff=numel(frame_selection_out);
			frame_selection_out(cutoff)=[];
		end
		filename_out={};
		filepath_out={};
		for j=1:numel(frame_selection_out)
			if mod(j,2) == 1
				filename_out{j,1} = ['A:['  int2str(frame_selection_out(j)) ']' filename];
			else
				filename_out{j,1} = ['B:['  int2str(frame_selection_out(j)) ']' filename];
			end
			filepath_out{j,1} = fullfile(video_pathname, filename);
		end
		setappdata(hgui,'filename',filename_out);
		setappdata(hgui,'filepath',filepath_out);
		setappdata(hgui,'pathname',video_pathname);
		setappdata(hgui,'video_frame_selection',frame_selection_out);
		setappdata(hgui,'video_selection_done',1);
		close(fig_handle)
	end

	function convert_to_disk_Callback()
		fig_handle=getappdata(0,'fig_handle');
		hgui=getappdata(0,'hgui');
		[~,videoname,~]=fileparts(filename);
		outdir=fullfile(video_pathname,[videoname '_frames']);

		%Warn if the output folder already contains extracted frames.
		if exist(outdir,'dir')
			existing=dir(fullfile(outdir,'*.tif'));
			if ~isempty(existing)
				answer=modal_safe_msgbox('quest',hgui,'Folder exists',['The folder' newline outdir newline 'already contains ' num2str(numel(existing)) ' tif file(s).' newline newline 'Overwrite / add frames there?'],'modal',{'Yes','Cancel'},'Cancel');
				if ~strcmp(answer,'Yes')
					return
				end
			end
		else
			[mkok,mkmsg]=mkdir(outdir);
			if ~mkok
				modal_safe_msgbox('error',hgui,'Error',['Could not create output folder:' newline outdir newline mkmsg],'modal');
				return
			end
		end

		nframes=numel(frame_selection);
		filelist=cell(nframes,1);
		cancel_conversion=false;
		%Turn the (now unused) "Select video file" button into a Cancel button
		%so the user can abort the slow conversion. Video decoding is inherently
		%slow (MATLAB VideoReader), so aborting must always be possible.
		set(handles.selectvideo,'String','Cancel conversion','Enable','on','Callback',@cancel_Callback);
		set(handles.importvideo,'enable','off','String','Converting...');
		set([handles.startframe handles.endframe handles.skipframe],'Enable','off');
		for i=1:nframes
			if cancel_conversion, break; end
			try
				fr=read(v,frame_selection(i));
			catch
				continue
			end
			if size(fr,3)>1 %color (or multi-channel) frame -> grayscale
				fr=rgb2gray(fr(:,:,1:3));
			end
			outfile=fullfile(outdir,sprintf('%s_%06d.tif',videoname,frame_selection(i)));
			imwrite(fr,outfile,'tif','Compression','none');
			filelist{i}=outfile;
			set(frametext,'String',['Converting frame ' int2str(i) ' / ' int2str(nframes) ' (' int2str(100*i/nframes) '%)']);
			drawnow %full drawnow so the Cancel button click is processed promptly
		end

		%Restore the "Select video file" button.
		set(handles.selectvideo,'String','Select video file','Enable','on','Callback',{@select_Callback,pathname});

		if cancel_conversion
			%Aborted: return to the preview so the user can adjust and retry.
			%Partially written frames are left in the folder (the overwrite
			%prompt will handle them on the next attempt).
			set(frametext,'String','Conversion cancelled.');
			set(handles.importvideo,'enable','on','String',importbutton_label);
			set([handles.startframe handles.endframe handles.skipframe],'Enable','on');
			return
		end

		filelist=filelist(~cellfun(@isempty,filelist));
		if isempty(filelist)
			modal_safe_msgbox('error',hgui,'Error','No frames could be read from this video file.','modal');
			return
		end

		setappdata(hgui,'converted_frames_dir',outdir);
		setappdata(hgui,'converted_frames_list',filelist);
		setappdata(hgui,'video_selection_done',0); %not using on-the-fly video reading
		setappdata(hgui,'video_convert_done',1);
		close(fig_handle)
	end

	function cancel_Callback(~,~,~)
		cancel_conversion=true;
	end

	function answer=modal_safe_msgbox(type,~,windowtitle,message,~,options,default)
		%gui.custom_msgbox parents its dialog to the main PIVlab window, which
		%then hides BEHIND this (modal) video preview window. Instead we use
		%MATLAB's stand-alone classic dialogs (questdlg / errordlg): they create
		%their own top-level modal window that appears ON TOP of the preview.
		%Signature is kept compatible with gui.custom_msgbox (target/modal args
		%are ignored here).
		answer=[];
		%Honour PIVlab's headless/test mode (same behaviour as gui.custom_msgbox).
		if isappdata(0,'PIVlabTestMode') && isequal(getappdata(0,'PIVlabTestMode'),true)
			if nargin>=7 && ~isempty(default)
				answer=default;
			elseif nargin>=6 && ~isempty(options)
				answer=options{1};
			end
			return
		end
		%Drop the preview out of modal state so the dialog can grab focus.
		ws='modal';
		if isvalid(fig_handle)
			ws=get(fig_handle,'WindowStyle');
			set(fig_handle,'WindowStyle','normal');
		end
		switch type
			case 'quest'
				if nargin<7 || isempty(default), default=options{1}; end
				if numel(options)==2
					answer=questdlg(message,windowtitle,options{1},options{2},default);
				elseif numel(options)==1
					answer=questdlg(message,windowtitle,options{1},default);
				else
					answer=questdlg(message,windowtitle,options{1},options{2},options{3},default);
				end
			otherwise %'error','warn','msg','success'
				uiwait(errordlg(message,windowtitle,'modal'));
		end
		if isvalid(fig_handle)
			set(fig_handle,'WindowStyle',ws);
		end
	end
end