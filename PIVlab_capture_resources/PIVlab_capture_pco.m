function [OutputError,image_stack,framerate_max] = PIVlab_capture_pco(imacount,exposure_time,TriggerModeString,ImagePath,binning,ROI_general,camera_type)
hgui=getappdata(0,'hgui');
if strcmpi(TriggerModeString,'calibration')
    triggermode=0; %internal trigger
elseif  strcmpi(TriggerModeString,'synchronizer')
    triggermode=2; %external Trigger
elseif  strcmpi(TriggerModeString,'oneimage_calibration')
    triggermode=0; %internal trigger, single image
elseif  strcmpi(TriggerModeString,'oneimage_piv')
    triggermode=0; %internal trigger, dual image (actually only for measuring max acquisition speed)
end
OutputError=0;
image_stack=[];
framerate_max=1;
PIVlab_axis = findobj(hgui,'Type','Axes');
image_handle_pco=imagesc(zeros(100,100),'Parent',PIVlab_axis,[0 2^16]);
setappdata(hgui,'image_handle_pco',image_handle_pco);

frame_nr_display=text(10,10,'Detecting camera...','Color',[1 1 0],'HorizontalAlignment','left','VerticalAlignment','top','FontSize',12);
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar

%% delete data in image directory, manage rcordfiles
filePattern = fullfile(ImagePath, 'PIVlab_pco*.tif');
pathparts = strsplit(filePattern,filesep);
diskchar = [pathparts{1} filesep];
%diskchar='C:\\';
if triggermode==2 && ~isinf(imacount) %external Trigger, with the desire to save
    direc= dir(filePattern);
    filenames={};
    [filenames{1:length(direc),1}] = deal(direc.name);
    amount = length(filenames);
    for i=1:amount
        delete(fullfile(ImagePath,filenames{i}));
    end
end

%% Initialize camera
glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
pco_camera_load_defines();
subfunc=pco_camera_subfunction();
[errorCode,glvar]=pco_camera_open_close(glvar);
figure(hgui)
pco_errdisp('pco_camera_setup',errorCode);
if(errorCode~=PCO_NOERROR)
    glvar.do_close=1;
    glvar.do_libunload=1;
    pco_camera_open_close(glvar);
    figure(hgui)
    set(frame_nr_display,'String',['Camera not found. Is the pco.USB driver installed? Is it connected?' newline 'If problem persists, you might' newline 'need to restart Matlab.']);
    %% RESET camera and recorder when camera crashed.
    try
        pause(1)
        disp('resetting library and recorder...')
        loadlibrary('sc2_cam','sc2_cammatlab.h' ...
            ,'addheader','sc2_common.h' ...
            ,'addheader','sc2_camexport.h' ...
            ,'alias','PCO_CAM_SDK' ...
            );
        %libfunctionsview('PCO_CAM_SDK')
        calllib('PCO_CAM_SDK', 'PCO_ResetLib')
        loadlibrary('pco_recorder','sc2_cammatlab.h' ...
            ,'addheader','pco_recorder_export.h' ...
            ,'alias','PCO_CAM_RECORDER');
        calllib('PCO_CAM_RECORDER', 'PCO_RecorderResetLib',0);
        calllib('PCO_CAM_SDK', 'PCO_RebootCamera',0);
        unloadlibrary('PCO_CAM_SDK');
        unloadlibrary('PCO_CAM_RECORDER');
        pause(1)
        gui.put('cancel_capture',1);
        gui.put('capturing',0);
        handles=gui.gethand;
        set(handles.ac_calibcapture,'String','Start')
        gui.toolsavailable(1)
    catch
        disp('resetting not successful...')
    end
    return;
end
hcam_ptr=glvar.out_ptr;
%% Set to double /single shutter
if triggermode == 2
    [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', hcam_ptr,1); %on
elseif triggermode==0
    if strcmpi(TriggerModeString,'calibration') || strcmpi(TriggerModeString,'oneimage_calibration')
        [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', hcam_ptr,0); %off
    end
    if  strcmpi(TriggerModeString,'oneimage_piv')
        [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', hcam_ptr,1); %off
    end
end
if(errorCode)
    pco_errdisp('PCO_SetDoubleImageMode',errorCode);
end

if strcmp(camera_type,'pco_panda')
    %% set I/O lines
    hwio_sig=libstruct('PCO_Signal');
    set(hwio_sig,'wSize',hwio_sig.structsize);
    [errorCode,~,hwio_sig] = calllib('PCO_CAM_SDK', 'PCO_GetHWIOSignal', hcam_ptr,0,hwio_sig);
    pco_errdisp('PCO_GetHWIOSignal',errorCode);
    hwio_sig.wEnabled = 1;
    [errorCode,~,~] = calllib('PCO_CAM_SDK', 'PCO_SetHWIOSignal', hcam_ptr,0,hwio_sig);
    pco_errdisp('PCO_SetHWIOSignal',errorCode);
    [errorCode,~,hwio_sig] = calllib('PCO_CAM_SDK', 'PCO_GetHWIOSignal', hcam_ptr,0,hwio_sig);
    if(errorCode)
        pco_errdisp('PCO_GetHWIOSignal',errorCode);
    end
    %% enable exposure active output on panda
    hwio_sig=libstruct('PCO_Signal');
    set(hwio_sig,'wSize',hwio_sig.structsize);
    [errorCode,~,hwio_sig] = calllib('PCO_CAM_SDK', 'PCO_GetHWIOSignal', hcam_ptr,3,hwio_sig);
    pco_errdisp('PCO_GetHWIOSignal',errorCode);
    hwio_sig.wEnabled = 1;
    [errorCode,~,~] = calllib('PCO_CAM_SDK', 'PCO_SetHWIOSignal', hcam_ptr,3,hwio_sig);
    pco_errdisp('PCO_SetHWIOSignal',errorCode);
    [errorCode,~,hwio_sig] = calllib('PCO_CAM_SDK', 'PCO_GetHWIOSignal', hcam_ptr,3,hwio_sig);
    if(errorCode)
        pco_errdisp('PCO_GetHWIOSignal',errorCode);
    end
elseif strcmp(camera_type,'pco_pixelfly')
    disp('hier muss sicher was hin für die pixelfly...')
    %no special treatment
end
%% camera description
subfunc.fh_stop_camera(hcam_ptr);
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', hcam_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);

%% Pixel Binning
%binning funktioniert nur wenn gleichzeitig ROI gesetzt wird.
if isempty(binning)
    binning=1;
end
h_binning=binning; %1,2,4
v_binning=binning; %1,2,4
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetBinning', hcam_ptr,h_binning,v_binning); %2,4, etc.
pco_errdisp('PCO_SetBinning',errorCode);
%% ROI selection
%kommt nur richtig voreingestellt wenn calibration mode
if strcmp(camera_type,'pco_panda')
    xmin=ROI_general(1);
    ymin=ROI_general(2);
    xmax=ROI_general(1)+ROI_general(3)-1;
    ymax=ROI_general(2)+ROI_general(4)-1;

    %dieser Code failt:
    [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetROI', hcam_ptr,xmin,ymin,xmax,ymax);
    pco_errdisp('PCO_SetROI',errorCode);
    errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', hcam_ptr);
    pco_errdisp('PCO_ArmCamera',errorCode);
    %if PCO_ArmCamera does fail no images can be grabbed
    if(errorCode~=PCO_NOERROR)
        if(glvar.camera_open==1)
            glvar.do_close=1;
            glvar.do_libunload=1;
            pco_camera_open_close(glvar);
            figure(hgui)
        end
        return;
    end
end

bitpix=uint16(cam_desc.wDynResDESC);
%subfunc.fh_set_bitalignment(hcam_ptr,BIT_ALIGNMENT_LSB);
subfunc.fh_set_bitalignment(hcam_ptr,BIT_ALIGNMENT_MSB); %better display: Data is captured as 12 bit and saved as 16 bit.
subfunc.fh_set_transferparameter(hcam_ptr);
%set default Pixelrate
subfunc.fh_set_pixelrate(hcam_ptr,2);

%Enable or disable timestamps in image
panda_timestamp=getappdata(hgui,'panda_timestamp');
if isempty (panda_timestamp)
    panda_timestamp='none';
end
if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
    if strcmp(panda_timestamp,'none')
        subfunc.fh_enable_timestamp(hcam_ptr,TIMESTAMP_MODE_OFF);
    elseif strcmp(panda_timestamp,'ASCII')
        subfunc.fh_enable_timestamp(hcam_ptr,TIMESTAMP_MODE_ASCII);
    elseif strcmp(panda_timestamp,'binary')
        subfunc.fh_enable_timestamp(hcam_ptr,TIMESTAMP_MODE_BINARY);
    elseif strcmp(panda_timestamp,'both')
        subfunc.fh_enable_timestamp(hcam_ptr,TIMESTAMP_MODE_BINARYANDASCII);
    end
    disp(['setting timestamp = ' panda_timestamp]);
end

%% exposure mode (auto vs. external trigger)
subfunc.fh_set_triggermode(hcam_ptr,triggermode); %0=auto, 2= external trigger
subfunc.fh_set_exposure_times(hcam_ptr,exposure_time,1,0,1); %set units to µs
subfunc.fh_get_triggermode(hcam_ptr);
framerate_max=1/subfunc.fh_show_frametime(hcam_ptr);

%% PCO recorder code
try
    if(strcmp(computer('arch'),'win64'))
        recLibName = 'pco_recorder';
    elseif(strcmp(computer('arch'),'glnxa64'))
        recLibName = 'libpco_recorder';
    else
        error('This platform is not supported.');
    end

    % Test if recorder library is loaded
    if (~libisloaded('PCO_CAM_RECORDER'))
        warning off MATLAB:loadlibrary:StructTypeExists
        % make sure the dll and h file specified below resides in your current folder
        %The files can also be placed in a known folder, but it is necessary to call LoadLibrary with the
        % complete path in this case.
        if strcmp(computer('arch'),'glnxa64') %linux: Probably no way to work with prototype files
            loadlibrary(recLibName,'sc2_cammatlab.h' ...
                ,'addheader','pco_recorder_export.h' ...
                ,'alias','PCO_CAM_RECORDER');
        elseif strcmp(computer('arch'),'win64') %64bit windows: generate prototype file on the fly (required for standalone tool)
            if ~exist('pco_recorder_mfile.m','file') %if prototype file not exists
                loadlibrary('pco_recorder','sc2_cammatlab.h' ,'addheader','pco_recorder_export.h' ,'alias','PCO_CAM_RECORDER', 'mfilename', 'pco_recorder_mfile');
                disp('Making prototype file')
            end
            loadlibrary('pco_recorder',@pco_recorder_mfile,'alias','PCO_CAM_RECORDER'); %neuer aufruf mit prototype file
        end
    else
        [errorCode] = calllib('PCO_CAM_RECORDER','PCO_RecorderResetLib',0);
        if(errorCode~=PCO_NOERROR)
            pco_errdisp('PCO_RecorderResetLib',errorCode);
            ME = MException('PCO_ERROR:RecorderResetLib','Cannot continue script if ResetLib is not done');
            subfunc.fh_lasterr(errorCode);
            throw(ME);
        end
    end
    camcount=1;
    MaxImgCountArr=zeros(1,camcount,'uint32');
    pMaxImgCountArr=libpointer('uint32Ptr',MaxImgCountArr);
    pImgDistributionArr=libpointer('uint32Ptr');
    %fill structures according to available cameras
    ml_camlist.cam_ptr1=libpointer('voidPtr',hcam_ptr);
    camera_array=libstruct('PCO_cam_ptr_List',ml_camlist);
    hreci_ptr = libpointer('voidPtrPtr');

    %je nach modus in RAM ringbuffer oder als datei:
    if triggermode==2 && ~isinf(imacount) %external trigger, PIV recording
        [errorCode,hrec_ptr,~,~,MaxImgCountArr] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCreate',hreci_ptr,camera_array ,pImgDistributionArr,camcount,PCO_RECORDER_MODE_FILE,diskchar,pMaxImgCountArr);
    end
    if triggermode==0 || isinf(imacount) %Internal trigger, or data should not be saved.
        [errorCode,hrec_ptr,~,~,MaxImgCountArr] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCreate',hreci_ptr,camera_array ,pImgDistributionArr,camcount,PCO_RECORDER_MODE_MEMORY,diskchar,pMaxImgCountArr);
    end

    pco_errdisp('PCO_RecorderCreate',errorCode);
    if errorCode ~= 0
        clear camera_array;
        pco_errdisp('PCO_RecorderCreate',errorCode);
        ME = MException('PCO_ERROR:RecorderCreate','Cannot continue script when creation of recorder fails');
        set(frame_nr_display,'String',['Camera not found. [2]' newline 'If problem persists, you might' newline 'need to restart Matlab.']);
        subfunc.fh_lasterr(errorCode);
        throw(ME);
    end
    %disp(['MaxImgCount:     ',int2str(MaxImgCountArr)]);
    %{
    if imacount>min(MaxImgCountArr)
        imacount=min(MaxImgCountArr);
        disp(['imacount changed to ' num2str(imacount)]);
    end
    %}
    ImgCountArr=zeros(1,camcount,'uint32');
    if ~isinf(imacount)
        ImgCountArr(1)=imacount;
    else
        ImgCountArr(1)=5; %ringbuffer for 5 images seems to be minimum.
    end

    panda_filetype=getappdata(hgui,'panda_filetype');
    if isempty (panda_filetype)
        panda_filetype='Single TIFF';
    end

    if strcmp(panda_filetype,'Single TIFF')
        if triggermode==2 && ~isinf(imacount) %external trigger, PIV recording
            [errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderInit' ...
                ,hrec_ptr ...
                ,ImgCountArr,camcount ...
                ,PCO_RECORDER_FILE_TIF ...
                ,1,fullfile(ImagePath, 'PIVlab_pco.tif'),[]);
            pco_errdisp('PCO_RecorderInit',errorCode);
        end
    elseif strcmp(panda_filetype,'Multi TIFF')
        if triggermode==2 && ~isinf(imacount) %external trigger, PIV recording
            [errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderInit' ...
                ,hrec_ptr ...
                ,ImgCountArr,camcount ...
                ,PCO_RECORDER_FILE_MULTITIF ...
                ,1,fullfile(ImagePath, 'PIVlab_pco.tif'),[]);
            pco_errdisp('PCO_RecorderInit',errorCode);
        end
    end

    if triggermode==0 || isinf(imacount) %Internal trigger, or data should not be saved.
        [errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderInit' ...
            ,hrec_ptr ...
            ,ImgCountArr,camcount ...
            ,PCO_RECORDER_MEMORY_RINGBUF ...
            ,0,[],[]);
        pco_errdisp('PCO_RecorderInit',errorCode);
    end

    if errorCode ~= 0
        clear camera_array;
        ME = MException('PCO_ERROR:RecorderInit','Cannot continue script when initialisation of recorder fails');
        set(frame_nr_display,'String',['Camera not found. [3]' newline 'If problem persists, you might' newline 'need to restart Matlab.']);
        subfunc.fh_lasterr(errorCode);
        throw(ME);
    end
    IsRunning   =true;
    IsNotValid  =false;
    ProcImgCount=uint32(0);
    ReqImgCount =uint32(0);
    StartTime   =uint32(0);
    StopTime    =uint32(0);
    %{
	[errorCode,~,~...
		,IsRunning,~,~...
		,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
		,hrec_ptr,hcam_ptr ...
		,IsRunning,IsNotValid,IsNotValid ...
		,ProcImgCount,ReqImgCount ...
		,[],[] ...
		,StartTime,StopTime);
    %}
    [errorCode,~,~...
        ,IsRunning,~,~...
        ,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
        ,hrec_ptr,hcam_ptr ...
        ,IsRunning,IsNotValid,IsNotValid ...
        ,ProcImgCount,ReqImgCount ...
        ,0,0 ...
        ,StartTime,StopTime);

    pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode);

    if IsRunning
        s='started';
    else
        s='stopped';
    end

    %disp(['Current runstate: ',s]);
    %disp(['images done:      ',int2str(ProcImgCount)]);
    %disp(['images requested: ',int2str(ReqImgCount)]);

    %not really necessary here
    [errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCleanup',hrec_ptr,[]);
    pco_errdisp('PCO_RecorderCleanup',errorCode);

    %looptime=(imatime*imacount);
    %disp(['time for all images is:   ',int2str(looptime),' seconds']);

    %disp('Start Recorder');
    tic;
    [errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderStartRecord',hrec_ptr,[]);
    pco_errdisp('PCO_RecorderStartRecord',errorCode);

    %{
	[errorCode,~,~,IsRunning] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
		,hrec_ptr,hcam_ptr ...
		,IsRunning,IsNotValid,IsNotValid ...
		,ProcImgCount,ReqImgCount ...
		,[],[],[],[]);
    %}
    [errorCode,~,~,IsRunning] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
        ,hrec_ptr,hcam_ptr ...
        ,IsRunning,IsNotValid,IsNotValid ...
        ,ProcImgCount,ReqImgCount ...
        ,0,0,0,0);


    pco_errdisp('PCO_RecorderGetStatus',errorCode);

    if IsRunning
        s='started';
    else
        s='stopped';
    end
    %disp(['Current runstate: ',s]);

    subfunc=pco_camera_subfunction();

    cam_desc=libstruct('PCO_Description');
    set(cam_desc,'wSize',cam_desc.structsize);
    [errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', hcam_ptr,cam_desc);
    pco_errdisp('PCO_GetCameraDescription',errorCode);

    bitpix=uint16(cam_desc.wDynResDESC);
    bytepix=fix(double(bitpix+7)/8);
    bitalign=subfunc.fh_get_bitalignment(hcam_ptr);

    act_xsize=uint16(0);
    act_ysize=uint16(0);
    max_xsize=uint16(0);
    max_ysize=uint16(0);
    %use PCO_GetSizes because this always returns accurat image size for next recording
    [errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', hcam_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
    pco_errdisp('PCO_GetSizes',errorCode);

    bufadr=libpointer('uint16Ptr');

    libmeta=libstruct('PCO_METADATA_STRUCT');
    set(libmeta,'wSize',libmeta.structsize);

    libtime=libstruct('PCO_TIMESTAMP_STRUCT');
    set(libtime,'wSize',libtime.structsize);

    image_stack=zeros(act_xsize,act_ysize,1,'uint16');
    im_ptr=libpointer('uint16Ptr',image_stack);
    ProcImgCount=0;
    old_ProcImgCount=ProcImgCount;
    if triggermode==2 % external trigger, PIV mode
        set(frame_nr_display,'String','Waiting for trigger...');
    end
    %% loop running while recording
    while IsRunning && getappdata(hgui,'cancel_capture') ~=1
        drawnow limitrate
        cancel_capture=getappdata(hgui,'cancel_capture');
        if cancel_capture %duplicate statement, does it help?
            break
        end
        drawnow limitrate
        %{
        [errorCode,~,~...
			,IsRunning,~,~...
			,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
			,hrec_ptr,hcam_ptr ...
			,IsRunning,IsNotValid,IsNotValid ...
			,ProcImgCount,ReqImgCount ...
			,[],[] ...
			,StartTime,StopTime);
        %}

        [errorCode,~,~...
            ,IsRunning,~,~...
            ,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
            ,hrec_ptr,hcam_ptr ...
            ,IsRunning,IsNotValid,IsNotValid ...
            ,ProcImgCount,ReqImgCount ...
            ,0,0 ...
            ,StartTime,StopTime);

        pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode);
        if ProcImgCount~=old_ProcImgCount %if there has been progress (one more image in buffer)
            %if ProcImgCount>=1
            [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderCopyImage',hrec_ptr,hcam_ptr,PCO_RECORDER_LATEST_IMAGE,1,1,act_xsize,act_ysize,im_ptr,[],libmeta,libtime);
            pco_errdisp('PCO_RecorderCopyImage',errorCode);
            image_stack=get(im_ptr,'Value');
            image_stack=permute(image_stack,[2 1 3]);
            if triggermode==2 % external trigger, PIV mode
                toggle_image_state=getappdata(hgui,'toggler');
                if toggle_image_state == 0
                    set(image_handle_pco,'CData',(image_stack(1:act_ysize/2  ,  1:act_xsize)));
                else
                    set(image_handle_pco,'CData',(image_stack(act_ysize/2+1:end  ,  1:act_xsize)));
                end
                if ~isinf(imacount)
                    set(frame_nr_display,'String',['Image nr.: ' int2str(ProcImgCount)]);
                else
                    set(frame_nr_display,'String','PIV preview');
                end
            else %Calibration mode
                if ~strcmpi(TriggerModeString,'oneimage_piv') %dont show the image that is captured after ROI is selected (it is only captured to measure max framerate)
                    set(image_handle_pco,'CData',(image_stack));
                    set(frame_nr_display,'String','Live image');
                   %disp('autodetect here')
                   %try catch here einfach drum rum.... Und dann immer ausführen
                    %PIVlab_capture_charuco_detector(image_stack,image_handle_pco);
                end
            end
            if strcmpi(TriggerModeString,'oneimage_calibration') || strcmpi(TriggerModeString,'oneimage_piv')
                break;
            end
            %% Additional functions that process realtime image data go here.
            live_data=get(image_handle_pco,'CData');
            %% Image sharpness display
            sharpness_enabled = getappdata(hgui,'sharpness_enabled');
            if sharpness_enabled == 1 %cross-hair and sharpness indicator
                %% sharpness indicator for particle images
                if strcmp(camera_type,'pco_panda')
                    textx=ROI_general(3)-10;
                    texty=ROI_general(4)-50;
                else
                    textx=1300;
                    texty=950;
                end
                [~,~] = PIVlab_capture_sharpness_indicator (live_data,textx,texty);
            else
                delete(findobj('tag','sharpness_display_text'));
            end

            %% Cross-hair
            crosshair_enabled = getappdata(hgui,'crosshair_enabled');
            if crosshair_enabled == 1 %cross-hair
                %% cross-hair
                %locations=[0.15 0.5 0.85];
                locations=[0.1:0.1:0.9];
                if numel(live_data)<10000000
                    half_thickness=2;
                else
                    half_thickness=4;
                end
                brightness_incr=10000;
                ima_ed=live_data;
                old_max=max(live_data(:));
                for loca=locations
                    %vertical
                    ima_ed(:,round(size(live_data,2)*loca)-half_thickness:round(size(live_data,2)*loca)+half_thickness)=ima_ed(:,round(size(live_data,2)*loca)-half_thickness:round(size(live_data,2)*loca)+half_thickness)+brightness_incr;
                    %horizontal
                    ima_ed(round(size(live_data,1)*loca)-half_thickness:round(size(live_data,1)*loca)+half_thickness,:)=ima_ed(round(size(live_data,1)*loca)-half_thickness:round(size(live_data,1)*loca)+half_thickness,:)+brightness_incr;
                end
                ima_ed(ima_ed>old_max)=old_max;
                set(image_handle_pco,'CData',ima_ed);
            end

            %% HISTOGRAM
            if getappdata(hgui,'hist_enabled')==1
                if isvalid(image_handle_pco)
                    hist_fig=findobj('tag','hist_fig');
                    if isempty(hist_fig)
                        hist_fig=figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Live histogram','Toolbar','none','tag','hist_fig','CloseRequestFcn', @HistWindow_CloseRequestFcn);
                    end
                    if ~exist ('old_hist_y_limits','var')
                        old_hist_y_limits =[0 35000];
                    else
                        if isvalid(hist_obj)
                            old_hist_y_limits=get(hist_obj.Parent,'YLim');
                        end
                    end
                    hist_obj=histogram(live_data(1:2:end,1:2:end),'Parent',hist_fig,'binlimits',[0 65535]);
                end
                %lowpass hist y limits for better visibility
                if ~exist ('new_hist_y_limits','var')
                    new_hist_y_limits =[0 35000];
                end
                new_hist_y_limits=get(hist_obj.Parent,'YLim');

                set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
            else
                hist_fig=findobj('tag','hist_fig');
                if ~isempty(hist_fig)
                    close(hist_fig)
                end
            end



            %% Autofocus
            %% Lens control
            %Sowieso machen: Nicht lineare schritte für die anzufahrenden fokuspositionen. Diese Liste vorher ausrechnen und dann nur index anspringen
            autofocus_enabled = getappdata(hgui,'autofocus_enabled');
            if autofocus_enabled == 1
                delaycounter=delaycounter+1;
            else
                delaycounter=0;
                delaycounter2=0;
                delay_time_1=tic;
            end
            %immer mehrere Bilder abfragen nachdem fokus verstellt wurde.... nicht nur eins, sondern z.B. drei Davon nur das letzte per sharpness beurteilen
            delay_time= 0.5; %1 seconds delay between measurements %350000 / exposure_time;
            if autofocus_enabled == 1
                if delaycounter>10 %wait 10 images before starting autofocus. Needed so that servo can reach target position
                    focus_start = getappdata(hgui,'focus_servo_lower_limit');
                    focus_end = getappdata(hgui,'focus_servo_upper_limit');
                    amount_of_raw_steps=20;
                    fine_step_resolution_increase = 8;
                    focus_step_raw=round(abs(focus_end - focus_start)/amount_of_raw_steps);% in microseconds)
                    focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end - focus_start)/amount_of_raw_steps));% in microseconds)
                    if ~exist('sharpness_focus_table','var') || isempty(sharpness_focus_table) || isempty(sharp_loop_cnt)
                        sharpness_focus_table=zeros(1,2);
                        sharp_loop_cnt=0;
                        focus=focus_start;
                        raw_finished=0;
                        aperture=getappdata(hgui,'aperture');
                        lighting=getappdata(hgui,'lighting');
                        PIVlab_capture_lensctrl(focus,aperture,lighting)
                    end
                    if raw_finished==0
                        if focus < focus_end % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                            if toc(delay_time_1)>=delay_time %only every second image is taken for analysis. This gives more time to the servo to reach position
                                delay_time_1=tic;
                                sharp_loop_cnt=sharp_loop_cnt+1;
                                [sharpness,~] = PIVlab_capture_sharpness_indicator (live_data,[],[]);
                                sharpness_focus_table(sharp_loop_cnt,1)=focus;
                                sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                                focus=focus+focus_step_raw;
                                PIVlab_capture_lensctrl(focus,aperture,lighting)		%kann steuern und aktuelle position ausgeben
                                autofocus_notification(1)
                            else
                                %do nothing
                            end
                        else
                            %assignin('base','sharpness_focus_table',sharpness_focus_table)
                            %find best focus
                            [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                            focus_peak=sharpness_focus_table(r(1),1);
                            disp(['Best raw focus: ' num2str(focus_peak)])
                            raw_finished=1;
                            %focus vs. distance is not linear!
                            focus_start_fine=focus_peak-6*focus_step_raw; %start of finer focussearch
                            focus_end_fine=focus_peak+3*focus_step_raw;
                            if focus_start_fine < focus_start
                                focus_start_fine = focus_start;
                            end
                            if focus_end_fine > focus_end
                                focus_end_fine = focus_end;
                            end
                            %original focus=focus_end_fine;
                            focus=focus_start_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)
                            sharp_loop_cnt=0;
                            raw_data=[sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range')];
                            sharpness_focus_table=zeros(1,2);
                        end
                    end

                    if raw_finished == 1
                        delaycounter2=delaycounter2+1;
                    else
                        delaycounter2=0;
                    end

                    if raw_finished == 1
                        delay_time= 0.35;
                        if delaycounter2>10
                            %repeat with finer steps
                            %original if focus > focus_start_fine % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                            if focus < focus_end_fine % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                                if toc(delay_time_1)>=delay_time %only every second image is taken for analysis. This gives more time to the servo to reach position
                                    delay_time_1=tic;
                                    sharp_loop_cnt=sharp_loop_cnt+1;
                                    [sharpness,~] = PIVlab_capture_sharpness_indicator (live_data,[],[]);
                                    sharpness_focus_table(sharp_loop_cnt,1)=focus;
                                    sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                                    %original focus=focus-focus_step_fine;
                                    focus=focus+focus_step_fine;
                                    PIVlab_capture_lensctrl(focus,aperture,lighting)		%kann steuern und aktuelle position ausgeben
                                    autofocus_notification(1)
                                else
                                    %do nothing
                                end
                            else %fine focus search finished
                                %assignin('base','sharpness_focus_table',sharpness_focus_table)
                                %find best focus
                                [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                                focus_peak=sharpness_focus_table(r(1),1);
                                disp(['Best fine focus: ' num2str(focus_peak)])
                                PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)%backlash compensation
                                pause(0.5)
                                PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting) %backlash compensation
                                pause(0.5)
                                PIVlab_capture_lensctrl(focus_peak,aperture,lighting) %set to best focus

                                setappdata(hgui,'autofocus_enabled',0); %autofocus am ende ausschalten

                                lens_control_window = getappdata(0,'hlens');
                                focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                                set(focus_edit_field,'String',num2str(focus_peak)); %update
                                %setappdata(hgui,'cancel_capture',1); %stop recording....?
                                figure;plot(raw_data(:,1),raw_data(:,2),'Linewidth',2)
                                hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'),'Linewidth',2);hold off
                                title('Focus search')
                                xlabel('Pulsewidth us')
                                ylabel('Sharpness')
                                legend('Coarse search','Fine search')
                                grid on

                            end
                        end
                    end
                end
            else
                autofocus_notification(0)
                sharpness_focus_table=[];
                sharp_loop_cnt=[];
            end
        end
        old_ProcImgCount=ProcImgCount;
        if ~isinf(imacount) && triggermode==2 && (ProcImgCount>=ReqImgCount) %actually a duplicate exiting the while loop.
            %disp('Capture complete.');
            break;
        end
    end
    set(frame_nr_display,'String','');
    [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderStopRecord',hrec_ptr,hcam_ptr);
    pco_errdisp('PCO_RecorderStopRecord',errorCode);
    [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderDelete',hrec_ptr);
    pco_errdisp('PCO_RecorderDelete',errorCode);


catch ME
    errorCode=subfunc.fh_lasterr();
    txt=blanks(101);
    txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);

    if(exist('hrec_ptr','var'))
        [erri]=calllib('PCO_CAM_RECORDER','PCO_RecorderDelete',hrec_ptr);
        pco_errdisp('PCO_RecorderDelete',erri);
    end

    clearvars -except ME glvar errorCode txt framerate_max hgui;

    if(libisloaded('PCO_CAM_RECORDER'))
        unloadlibrary('PCO_CAM_RECORDER');
    end

    if(glvar.camera_open==1)
        glvar.do_close=1;
        glvar.do_libunload=1;
        pco_camera_open_close(glvar);
        figure(hgui)
    end

    if strfind(ME.identifier,'PCO_ERROR:')
        msg=[ME.identifier,' ',ME.message];
        disp(txt);
        warning('off','backtrace')
        warning(msg)
        for k=1:length(ME.stack)
            disp(['from file ',ME.stack(k).file,' at line ',num2str(ME.stack(k).line)]);
        end
        close();
        clearvars -except errorCode hgui;
        return;
    else
        close();
        clearvars -except ME hgui;
        rethrow(ME)
    end
end

clearvars -except glvar errorCode image_stack OutputError hgui framerate_max hgui;

if(glvar.camera_open==1)
    glvar.do_close=1;
    glvar.do_libunload=1;
    pco_camera_open_close(glvar);
    figure(hgui)
end
%clear glvar;
unloadlibrary('PCO_CAM_RECORDER')


function HistWindow_CloseRequestFcn(hObject,~)
hgui=getappdata(0,'hgui');
setappdata(hgui,'hist_enabled',0);
try
    delete(hObject);
catch
    delete(gcf);
end

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1

    hgui=getappdata(0,'hgui');
    PIVlab_axis = findobj(hgui,'Type','Axes');
    %image_handle_OPTOcam=getappdata(hgui,'image_handle_OPTOcam');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor'); % Toggle background color while autofocus is active

    if ~isempty(bg_col)
        if  sum(bg_col)==0.75 %hint is currently displayed
            bg_col = [0.05 0.05 0.05];
        else
            bg_col = [0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col= [0.25 0.25 0.25];
        axes(PIVlab_axis);
        text(postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24, 'BackgroundColor', bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');

    end
else
    delete(auto_focus_active_hint);
end