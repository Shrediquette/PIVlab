function [suggested_interframe] = automatic_interframe(~,~,~)

button = questdlg('This will switch on the laser!','Warning','OK','Cancel','Cancel');
if strmatch(button,'OK')==1
    hgui=getappdata(0,'hgui');
    setappdata(hgui,'cancel_capture',0);
    handles=gui.gethand;

    serpo = gui.retr('serpo');
    camera_type=gui.retr('camera_type');
    camera_sub_type=gui.retr('camera_sub_type');

    acquisition.control_simple_sync_serial(0,0);
    ac_fps_value=get(handles.ac_fps,'Value');
    ac_fps_str=get(handles.ac_fps,'String');
    cam_fps=str2double(ac_fps_str(ac_fps_value))

    min_allowed_interframe = gui.retr('min_allowed_interframe');


    imageamount=2;
    ac_ROI_general=gui.retr('ac_ROI_general');
    if isempty(ac_ROI_general)
        max_cam_res=gui.retr('max_cam_res');
        ac_ROI_general=[1 1 max_cam_res(1) max_cam_res(2)];
    end

    do_realtime=gui.retr('do_realtime');
    if isempty(do_realtime)
        do_realtime=0;
    end
    ac_ROI_realtime=gui.retr('ac_ROI_realtime');

    if strcmpi(camera_type,'OPTRONIS')
        OPTRONIS_bits=gui.retr('OPTRONIS_bits');
        if isempty(OPTRONIS_bits)
            OPTRONIS_bits=8;
        end
        displ=0;
        pulse_sep=min_allowed_interframe;
        laserpower=100;

        while displ < 5 && getappdata(hgui,'cancel_capture') ~=1
            pulse_sep = pulse_sep + 100
            [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_synced_start(imageamount,ac_ROI_general,cam_fps,OPTRONIS_bits); %prepare cam and start camera (waiting for trigger...)
            pause(0.1) %make sure OPTRONIS is ready to capture.
            %reihe von min dings bis 1/fps... abbrechen wenn displacement um die 5
            %px
            set(handles.ac_interpuls,'String',num2str(pulse_sep))
            set(handles.ac_power,'String',num2str(laserpower));

            acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
            [OutputError,OPTRONIS_vid] = PIVlab_capture_OPTRONIS_synced_capture(OPTRONIS_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display,OPTRONIS_bits); %capture n images, display livestream
            while OPTRONIS_vid.FramesAcquired < imageamount
                disp ('waiting for data acquisition')
                pause(0.1)
            end
            acquisition.control_simple_sync_serial(0,0);
            OPTRONIS_data = getdata(OPTRONIS_vid,imageamount);
            [~, ~, u, v] = piv.piv_quick(OPTRONIS_data(:,:,:,1),OPTRONIS_data(:,:,:,2),128, 128);

            [u,v] = postproc.PIVlab_postproc (u,v,[],[], [], 1,6,1,3); %validate results

            magn=(u.^2+v.^2).^0.5;
            displ=max(magn(:),[],'omitnan')

            relative_bright = double(mean(OPTRONIS_data(:,:,:,1:2),'all')) / double(max(OPTRONIS_data(:,:,:,1:2),[],'all'))

            if relative_bright > 0.25
                laserpower = round(laserpower * 0.75);
            end

        end
        suggested_interframe=0;
    end
else
    suggested_interframe=0
end
acquisition.control_simple_sync_serial(0,0);

