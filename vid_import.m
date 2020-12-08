% Video file selection, startframe, endframe and skipping of frames for PIVlab
function vid_import(pathname)
big_scroll = 30;
click = 0;
f = 1;  %current frame

%% Make figure
fig_handle = figure('MenuBar','none', 'Toolbar','none', 'Units','characters', 'WindowButtonDownFcn',@button_down, 'WindowButtonUpFcn',@button_up,  'WindowButtonMotionFcn', @on_click,'KeyPressFcn', @key_press,'Name','Video preview','numbertitle','off','Visible','off','Windowstyle','modal','resize','off','dockcontrol','off');

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
handles.startframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1','Tag','startframe');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text2 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','End frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.endframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','10','Tag','endframe');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text3 = uicontrol(fig_handle,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Decimate framerate by: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.skipframe = uicontrol(fig_handle,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','2','Tag','skipframe');
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

h_fig=imshow(0);drawnow
play_timer = timer('TimerFcn',@play_timer_callback, 'ExecutionMode','fixedRate');
scroll_bar_handles = [scroll_axes_handle; scroll_handle];
scroll_func = @scroll;
video_loaded=0;




    function select_Callback(~,~,pathname)
        fig_handle=getappdata(0,'fig_handle');
        handles=guihandles(fig_handle);
        [filename,pathname] = uigetfile({'*.avi';'*.mp4';'*.mpg';'*.wmv';'*.*'},'Video File Selector',pathname)
        if ~isequal(filename,0)
            video_loaded = 1;
            % videofile='xylophone.mpg';
            
            v = VideoReader(fullfile(pathname,filename));
            play_fps = v.FrameRate;
            num_frames=v.NumberOfFrames;
            scroll_bar_width = max(1 / num_frames, 0.02);
            
            if isnan(v.Height)
                fprintf('Failed to create video object.\n');
            else
                axes (axes_handle)
                h_fig=imshow(read(v,1));drawnow
                scroll(1)
                set(handles.importvideo,'enable','on')
                setappdata(fig_handle,'filename',filename);
                setappdata(fig_handle,'pathname',pathname);
                setappdata(fig_handle,'startframe',str2num(get(handles.startframe,'String')));
                setappdata(fig_handle,'endframe',str2num(get(handles.endframe,'string')));
                setappdata(fig_handle,'skipframe',str2num(get(handles.skipframe,'String')));
            end
        end
    end


    function key_press(src, event)  %#ok, unused arguments
        if video_loaded
            switch event.Key  %process shortcut keys
                case 'leftarrow'
                    scroll(f - 1);
                case 'rightarrow'
                    scroll(f + 1);
                case 'downarrow'
                    if f - big_scroll < 1  %scrolling before frame 1, stop at frame 1
                        scroll(1);
                    else
                        scroll(f - big_scroll);
                    end
                case 'uparrow'
                    if f + big_scroll > num_frames  %scrolling after last frame
                        scroll(num_frames);
                    else
                        scroll(f + big_scroll);
                    end
                case 'home'
                    scroll(1);
                case 'end'
                    scroll(num_frames);
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
            scroll(f + 1);
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
            
            %convert frame number to appropriate x-coordinate of scroll bar
            scroll_x = (f - 1) / num_frames;
            
            %move scroll bar to new position
            set(scroll_handle, 'XData', scroll_x + [0 1 1 0] * scroll_bar_width);
            
            %set to the right axes and call the custom redraw function
            set(fig_handle, 'CurrentAxes', axes_handle);
            
            try
                %h_fig.CData = read(v,f);
                set(h_fig,'CData',read(v,f));
                %imshow(read(v,f));
            catch
            end
            set (frametext,'String', ['Frame Nr.: ' int2str(f) '/' int2str(num_frames)])
            
            %used to be "drawnow", but when called rapidly and the CPU is busy
            %it didn't let Matlab process events properly (ie, close figure).
            pause(0.001)
            %drawnow limitrate
        end
    end

    function import_Callback(~,~,~)
        fig_handle=getappdata(0,'fig_handle');
        hgui=getappdata(0,'hgui');
        
        setappdata(hgui,'filename',getappdata(fig_handle,'filename'));
        setappdata(hgui,'pathname',getappdata(fig_handle,'pathname'));
        setappdata(hgui,'startframe',getappdata(fig_handle,'startframe'));
        setappdata(hgui,'endframe',getappdata(fig_handle,'endframe'));
        setappdata(hgui,'skipframe',getappdata(fig_handle,'skipframe'));
        
        close(fig_handle)
        disp('import')
    end
end