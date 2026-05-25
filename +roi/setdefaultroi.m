function setdefaultroi(source,~)
if ~isempty(gui.retr('doing_roi')) && gui.retr('doing_roi')==1
    ac_ROI_general_handle = findobj('tag','new_ROImethod');
    binning=gui.retr('binning');
    max_cam_res =gui.retr('max_cam_res');
    camera_type=gui.retr('camera_type');
    if isempty(binning)
        binning=1;
    end
    selection=1; %automatic centering of ROI
    switch source.Label
        case 'pco.edge 26 DS 70 Hz'
            des_x=5120;
            des_y=5120;
        case 'pco.edge 26 DS 100 Hz'
            des_x=4288;
            des_y=3296;
        case 'pco.edge 26 DS 180 Hz'
            des_x=2400;
            des_y=1920;
        case 'pco.edge 26 DS 300 Hz'
            des_x=1920;
            des_y=1080;
        case 'pco.edge 26 DS 750 Hz'
            des_x=608;
            des_y=448;

        case 'pco.panda 45 Hz'
            des_x=480;
            des_y=340;
        case 'pco.panda 22.5 Hz'
            des_x=720;
            des_y=576;
        case 'pco.panda 15 Hz'
            des_x=1200;
            des_y=896;
        case 'pco.panda 7.5 Hz'
            des_x=2400;
            des_y=1904;
        case 'pco.panda 5 Hz'
            des_x=4000;
            des_y=3000;
        case 'pco.panda 3 Hz'
            des_x=4296;
            des_y=3296;
        case 'pco.panda 1.5 Hz'
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

        case 'OPTOcam 1936x1216 (8bit: 160 fps, 12bit: 80 fps)'
            des_x=1936;
            des_y=1216;
        case 'OPTOcam 1600x600 (8bit: 320 fps)'
            des_x=1600;
            des_y=600;
        case 'OPTOcam 1600x480 (8bit: 400 fps)'
            des_x=1600;
            des_y=480;

        case 'Cyclone-2-2000-M 1920x1080 (max. 2000 fps)'
            des_x=1920;
            des_y=1080;
        case 'Cyclone-2-2000-M 1792x480 (max. 5000 fps)'
            des_x=1792;
            des_y=480;
        case 'Cyclone-2-2000-M 1024x240 (max. 10000 fps)'
            des_x=1024;
            des_y=240;

        case 'Cyclone-1HS-3500-M 1280x860 (max. 3500 fps)'
            des_x=1280;
            des_y=860;
        case 'Cyclone-1HS-3500-M 1280x320 (max. 9200 fps)'
            des_x=1280;
            des_y=320;
        case 'Cyclone-1HS-3500-M 1280x240 (max. 12200 fps)'
            des_x=1280;
            des_y=240;

        case 'Cyclone-25-150-M 5120x5120 (max. 145 fps)'
            des_x=5120;
            des_y=5120;
        case 'Cyclone-25-150-M 5120x2160 (max. 300 fps)'
            des_x=5120;
            des_y=2160;
        case 'Cyclone-25-150-M 5120x1080 (max. 650 fps)'
            des_x=5120;
            des_y=1080;
        case 'Cyclone-25-150-M 5120x720 (max. 1000 fps)'
            des_x=5120;
            des_y=720;

        case 'Enter ROI'
            c = roi.get_roi_constraints(camera_type, max_cam_res);
            labels = {sprintf('x (step %d)', c.step_x), sprintf('y (step %d)', c.step_y), ...
                      sprintf('w (step %d, min %d)', c.step_w, c.min_w), ...
                      sprintf('h (step %d, min %d)', c.step_h, c.min_h)};
            current_pos = round(get(ac_ROI_general_handle,'Position'));
            try
                hgui_local = getappdata(0,'hgui');
                mainpos = get(hgui_local,'Position');
            catch
                mainpos = [0 2.8571 240 50.9524];
            end
            roi_fig = figure('numbertitle','off','MenuBar','none','DockControls','off', ...
                'Toolbar','none','Name','Enter ROI','resize','off', ...
                'Units','characters', ...
                'Position',[mainpos(1)+mainpos(3)/2-18, mainpos(2)+mainpos(4)/2, 36, 12], ...
                'WindowStyle','normal');
            col_lbl = 1;  col_fld = 19;
            w_lbl   = 17; w_fld   = 14;
            row_h   = 1.5;
            % Pass 1: create all edit fields (no callbacks yet)
            edit_handles = zeros(1,4);
            for k = 1:4
                y_pos = 11 - k*2;
                uicontrol(roi_fig,'Style','text','String',labels{k}, ...
                    'Units','characters','FontUnits','points', ...
                    'HorizontalAlignment','right', ...
                    'Position',[col_lbl, y_pos, w_lbl, row_h]);
                edit_handles(k) = uicontrol(roi_fig,'Style','edit', ...
                    'String',num2str(current_pos(k)), ...
                    'Units','characters','FontUnits','points', ...
                    'Position',[col_fld, y_pos, w_fld, row_h]);
            end
            % Pass 2: assign callbacks now that edit_handles is fully populated
            for k = 1:4
                set(edit_handles(k),'Callback',@(~,~) roi.update_roi_field(edit_handles, ac_ROI_general_handle, c));
            end
            uicontrol(roi_fig,'Style','pushbutton','String','OK', ...
                'Units','characters','FontUnits','points', ...
                'Position',[col_lbl+1, 0.5, 14, 2], ...
                'Callback',@(~,~) uiresume(roi_fig));
            uicontrol(roi_fig,'Style','pushbutton','String','Cancel', ...
                'Units','characters','FontUnits','points', ...
                'Position',[col_lbl+17, 0.5, 14, 2], ...
                'Callback',@(~,~) delete(roi_fig));
            uiwait(roi_fig);
            if ishandle(roi_fig)
                vals = arrayfun(@(h) str2double(get(h,'String')), edit_handles);
                delete(roi_fig);
                selection = 2;
                min_x = vals(1);  min_y = vals(2);
                des_x = vals(3);  des_y = vals(4);
                img_size = [des_x des_y];
            else
                des_x = max_cam_res(1);
                des_y = max_cam_res(2);
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
    roi.ROIallevents(ac_ROI_general_handle,evt,camera_type,max_cam_res)
end

