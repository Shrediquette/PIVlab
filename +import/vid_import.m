% Video file selection, startframe, endframe and skipping of frames for PIVlab
function vid_import(pathname)
if nargin < 1
	pathname=pwd;
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
%% Make figure
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
handles.importvideo = uicontrol(fig_handle,'Style','pushbutton','String','Import video frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import_Callback,'Tag','importvideo','TooltipString','Import video frames','enable','off');
item=[0 item(2)+item(4)+margin parentitem(3) 13];
axes_handle=axes('Parent',fig_handle,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);
axis image;
set(gca,'ActivePositionProperty','outerposition');%,'Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');

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

batchModeActive=gui.retr('batchModeActive');
if isempty (batchModeActive) || batchModeActive == 0
	if ~ispref('PIVlab_ad','video_warn') || getpref('PIVlab_ad','video_warn') == 0
		pause(0.1);drawnow
		gui.custom_msgbox('msg',getappdata(0,'hgui'),'PIVlab is better with image files','Hint: If possible you should always prefer image files over video files, e.g. by converting them to a lossless format before importing in PIVlab.','modal',{'OK'},'OK');
		setpref('PIVlab_ad','video_warn',1)
	end
end


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
                gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',{'Matlab could not import this video file. Most likely, the video codec cannot be used by Matlab. This is not a PIVlab-related issue. The exact error message is: ' sprintf('\n') ME.identifier sprintf('\n') ME.message},'modal');
			end
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
			
			%get x-coordinate of click
			%set(fig_handle, 'Units', 'normalized');
			click_point = get(fig_handle, 'CurrentPoint')/fig_size(3);
			%set(fig_handle, 'Units', 'pixels');
			x = click_point(1);
			
			%get corresponding frame number
			new_f = floor(1 + x * num_frames);
			
			if new_f < 1 || new_f > num_frames, return; end  %outside valid range
			
			if new_f ~= f  %don't redraw if the frame is the same (to prevent delays)
				if new_f<num_frames
					try
						scroll(new_f);
					catch
					end
				end
				
			end
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
end