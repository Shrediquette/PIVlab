function [OutputError,ima] = PIVlab_Capture_Pixelfly(nr_of_images,exposure_time,TriggerModeString,ImagePath)

%{
PIVlab UI elements
select setup type (PIVlabSync + ILA PIV.nano)
select Project path
Calibration, Exposure time
Capture Images, nr of imgs (enables laser, loads in session when done)

Laser control komplett wie im simple sync
%}
hgui=getappdata(0,'hgui');
OutputError=0;
PIVlab_axis = findobj(hgui,'Type','Axes');
image_handle=imagesc(zeros(1040,1392),'Parent',PIVlab_axis,[0 2^16]);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
new_map=colormap('gray');
new_map(1:3,:)=[0 0.3 0;0 0.3 0;0 0.3 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar

%{
needed:
'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_camera_def.txt'
    'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_camera_load_defines.m'
    'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_camera_open_close.m'
    'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_camera_subfunction.m'
    'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_errdisp.m'
    'C:\Program Files\PCO Digital Camera Toolbox\pco.matlab\scripts\pco_uint32err.m'}
%}
if strcmp(TriggerModeString,'Calibration') || strcmp(TriggerModeString,'calibration')
	triggermode=0; %External trigger
elseif  strcmp(TriggerModeString,'Synchronizer') || strcmp(TriggerModeString,'synchronizer')
	triggermode=2; %Internal Trigger
end
image_save_number=0;
glvar=struct('do_libunload',1,'do_close',0,'camera_open',0,'out_ptr',[]);
pco_camera_load_defines();
subfunc=pco_camera_subfunction();
[errorCode,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',errorCode);
out_ptr=glvar.out_ptr;

try
	act_recstate = uint16(10);
	[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
	if(errorCode)
		pco_errdisp('PCO_GetRecordingState',errorCode);
	end
	%% Set to double /single image
	if triggermode == 2
		[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', out_ptr,1);
	elseif triggermode==0
		[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', out_ptr,0);
	end
	%stop camera
	subfunc.fh_stop_camera(out_ptr);
	cam_desc=libstruct('PCO_Description');
	set(cam_desc,'wSize',cam_desc.structsize);
	[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
	pco_errdisp('PCO_GetCameraDescription',errorCode);
	bitpix=uint16(cam_desc.wDynResDESC);
	%set bitalignment LSB
	bitalign=uint16(BIT_ALIGNMENT_LSB);
	errorCode = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
	pco_errdisp('PCO_SetBitAlignment',errorCode);
	
	errorCode = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode',out_ptr,RECORDER_SUBMODE_RINGBUFFER);
	pco_errdisp('PCO_SetRecorderSubmode',errorCode);
	
	%disnable ASCII and binary timestamp
	if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
		subfunc.fh_enable_timestamp(out_ptr,TIMESTAMP_MODE_OFF);
	end
	
	%change timebase for camera
	
	%enable MetaData if available
	if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_METADATA))
		subfunc.fh_set_metadata_mode(out_ptr,1);
	end
	
	%set default Pixelrate
	subfunc.fh_set_pixelrate(out_ptr,2);
	
	subfunc.fh_set_triggermode(out_ptr,triggermode);
	%subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2); %ms
	subfunc.fh_set_exposure_times(out_ptr,exposure_time,1,0,1); %us
	
	%if PCO_ArmCamera does fail no images can be grabbed
	errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
	if(errorCode~=PCO_NOERROR)
		pco_errdisp('PCO_ArmCamera',errorCode);
		ME = MException('PCO_ERROR:ArmCamera','Cannot continue script with not armed camera');
		subfunc.fh_lasterr(errorCode);
		throw(ME);
	end
	
	%adjust transfer parameter if necessary
	subfunc.fh_set_transferparameter(out_ptr);
	
	triggermode=subfunc.fh_get_triggermode(out_ptr);
	
	metadatasize=0;
	if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_METADATA))
		wMetaDataMode=uint16(0);
		wMetaDataSize=uint16(0);
		wMetaDataVersion=uint16(0);
		
		[errorCode,~,wMetaDataMode,wMetaDataSize,wMetaDataVersion] = calllib('PCO_CAM_SDK', 'PCO_GetMetaDataMode',out_ptr,wMetaDataMode,wMetaDataSize,wMetaDataVersion);
		pco_errdisp('PCO_GetMetaDataMode',errorCode);
		if(errorCode)
			pco_errdisp('PCO_GetMetaDataMode',errorCode);
			return;
		end
		
		disp(['Camera supports Metadata Version: ',num2str(wMetaDataVersion)]);
		
		if(wMetaDataMode~=0)
			metadatasize=wMetaDataSize;
			disp(['Metadata is enabled. Number of Bytes: ',num2str(metadatasize)]);
		end
	end
	
	act_xsize=uint16(0);
	act_ysize=uint16(0);
	ccd_xsize=uint16(0);
	ccd_ysize=uint16(0);
	
	%use PCO_GetSizes because this always returns accurate image size for next recording
	[errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,ccd_xsize,ccd_ysize);
	if(errorCode)
		pco_errdisp('PCO_GetSizes',errorCode);
	end
	
	%disp(['sizes: horizontal ',int2str(act_xsize),' vertical ',int2str(act_ysize)]);
	
	flags=2; %IMAGEPARAMETERS_READ_WHILE_RECORDING;
	errorCode = calllib('PCO_CAM_SDK', 'PCO_SetImageParameters', out_ptr,act_xsize,act_ysize,flags,[],0);
	pco_errdisp('PCO_SetImageParameters',errorCode);
	
	lineadd=0;
	if(metadatasize>0)
		xs=uint32(fix((double(bitpix)+7)/8));
		xs=xs*uint32(act_xsize);
		i=uint16(floor((metadatasize*2)/double(xs)));
		lineadd=i+1;
	end
	
	%disp(['lines added: ',int2str(lineadd)]);
	
	%allocate memory for display, 4 buffers are used
	bufcount=4;
	bufnum=zeros(4,1,'int16');
	
	imas=uint32(fix((double(bitpix)+7)/8));
	imas= imas*uint32(act_xsize)* uint32(act_ysize);
	imasize=imas;
	
	image_stack=zeros(act_xsize,(act_ysize+lineadd),bufcount,'uint16');
	
	%Allocate 4 SDK buffer and set address of buffers from image_stack
	ev_ptr(bufcount) = libpointer('voidPtr');
	im_ptr(bufcount) = libpointer('voidPtr');
	
	buflist=libstruct('PCO_Buflist');
	names=fieldnames(buflist);
	x=1:4:length(names);
	bufnr=names(x);
	x=3:4:length(names);
	statusdll=names(x);
	x=4:4:length(names);
	statusdrv=names(x);
	
	for n=1:bufcount
		sBufNri=int16(-1);
		im_ptr(n) = libpointer('uint16Ptr',image_stack(:,:,n));
		ev_ptr(n) = libpointer('voidPtr');
		
		[errorCode,~,sBufNri]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNri,imasize,im_ptr(n),ev_ptr(n));
		if(errorCode~=PCO_NOERROR)
			pco_errdisp('PCO_AllocateBuffer',errorCode);
			ME = MException('PCO_ERROR:AllocateBuffer','Cannot continue script without allocated Buffers');
			subfunc.fh_lasterr(errorCode);
			throw(ME);
		end
		buflist.(bufnr{n})=int16(sBufNri);
		bufnum(n)=int16(sBufNri);
		e=bitor(buflist.(statusdll{n}),uint32(PCO_BUFFER_EVAUTORES),'uint32');
		buflist.(statusdll{n})=e;
	end
	
	%show figure
	ima=image_stack(:,1:act_ysize,1);
	ima=ima';
	pause(0.05);
	
	%this will remove all pending buffers in the queue and does reset grabber
	errorCode = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
	pco_errdisp('PCO_CancelImages',errorCode);
	errorCode=subfunc.fh_start_camera(out_ptr);
	if(errorCode~=PCO_NOERROR)
		ME = MException('PCO_ERROR:StartCamera','Cannot continue script with stopped camera');
		subfunc.fh_lasterr(errorCode);
		throw(ME);
	end
	
	%setup loop
	for n=1:bufcount
		errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,bufnum(n),act_xsize,act_ysize,bitpix);
		if(errorCode~=PCO_NOERROR)
			pco_errdisp('PCO_AddBufferEx',errorCode);
			ME = MException('PCO_ERROR:AddBufferEx','Cannot continue script without added buffers');
			subfunc.fh_lasterr(errorCode);
			throw(ME);
		end
	end
	
	[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',glvar.out_ptr,act_recstate);
	if(errorCode)
		pco_errdisp('PCO_GetRecordingState',errorCode);
	end
	
	if(act_recstate==1)
		trigdone=int16(1);
		trigcount=0;
		if(triggermode==1)
			[errorCode,~,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
			if(errorCode)
				pco_errdisp('PCO_ForceTrigger',errorCode);
			else
				trigcount=trigcount+1;
				%disp(['first trigger done return: ',int2str(trigdone)]);
			end
		end
		pause(0.0001);
		tic;
		
		%grab and display loop
		ima_nr=0;
		last_ok=0;
		while(ima_nr<nr_of_images) && getappdata(hgui,'cancel_capture') ~=1
			drawnow
			%wait for buffers
			[errorCode,~,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,1000);
			if(errorCode)
				pco_errdisp('PCO_WaitforBuffer',errorCode);
				OutputError='NoTrigger';
				break;
			end
			%  disp(['After wait image ',int2str(ima_nr),' last_ok ',num2str(last_ok)]);
			%first image done trigger next
			if(triggermode==1)
				[errorCode,~,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
				if(errorCode)
					pco_errdisp('PCO_ForceTrigger',errorCode);
				else
					trigcount=trigcount+1;
				end
			end
			
			%test and display buffer
			next=last_ok+1;
			multi=0;
			for n=1:bufcount
				if(next>bufcount)
					next=1;
				end
				%   disp(['Status buf',int2str(next),' StatusDll ',num2str(buflist.(statusdll{next}),'%08X'),' StatusDrv ',num2str(buflist.(statusdrv{next}),'%08X')]);
				if((bitand(buflist.(statusdll{next}),hex2dec('00008000')))&&(buflist.(statusdrv{next})==0))
					%get data and show image
					last_ok=next;
					ima=get(im_ptr(next),'Value');
					ima_nr=ima_nr+1;
					multi=multi+1;
					
					if(metadatasize>0)
						ima=ima(:,1:act_ysize);
					end
					ima=ima';
					if(bitalign==BIT_ALIGNMENT_MSB)
						s=int16(16-bitpix);
						s=s*-1;
						ima=bitshift(ima,s);
					end
					
					%% Save images with external trigger
					ima=bitshift(ima,2); %16 bit to 14 bit conversion
					if triggermode == 2 %external trigger
						imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',image_save_number) '_A.tif']);
						imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',image_save_number) '_B.tif']);
						imwrite(ima(1:1040,:),imgA_path);
						imwrite(ima(1041:end,:),imgB_path);
						toggle_image_state=getappdata(hgui,'toggler');
						if toggle_image_state == 0
							set(image_handle,'CData',(ima(1:1040,:)));
						else
							set(image_handle,'CData',(ima(1041:end,:)));
						end
						set(frame_nr_display,'String',int2str(image_save_number));
						image_save_number=image_save_number+1;
					elseif triggermode==0
						set(image_handle,'CData',ima);
					end
					pause(0.0001);
					errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,bufnum(next),act_xsize,act_ysize,bitpix);
					if(errorCode)
						pco_errdisp('PCO_AddBufferEx',errorCode);
						break;
					end
				end
				next=next+1;
			end
		end
		% SAVE calibration Image when live view is cancelled
		if triggermode==0 %calibration
			numbi = 0;
			imgA_path = fullfile(ImagePath, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']);
			while exist(imgA_path, 'file')
				numbi = numbi+1;
				imgA_path = fullfile(ImagePath, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']);
			end
			imwrite(ima,imgA_path);
			set(image_handle,'CData',ima);
		end
		
		%this will remove all pending buffers in the queue
		errorCode = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
		pco_errdisp('PCO_CancelImages',errorCode);
		
		[errorCode,~,buflist] = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,500);
		pco_errdisp('PCO_WaitforBuffer',errorCode);
	end
	
	subfunc.fh_stop_camera(out_ptr);
	
	for n=1:bufcount
		errorCode = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,bufnum(n));
		if(errorCode)
			pco_errdisp('PCO_FreeBuffer',errorCode);
		end
	end
	
	
catch ME
	disp(ME)
	errorCode=subfunc.fh_lasterr();
	txt=blanks(101);
	txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);
	
	calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
	for n=1:bufcount
		calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,bufnum(n));
	end
	if(glvar.camera_open==1)
		glvar.do_close=1;
		glvar.do_libunload=1;
		pco_camera_open_close(glvar);
	end
	if strfind(ME.identifier,'PCO_ERROR:')
		msg=[ME.identifier,' ',ME.message];
		warning('off','backtrace')
		warning(msg)
		disp(txt);
		for k=1:length(ME.stack)
			disp(['from file ',ME.stack(k).file,' at line ',num2str(ME.stack(k).line)]);
		end
		close();
		%clearvars -except errorCode;
		%commandwindow;
		return;
	else
		close();
		%clearvars -except ME;
		rethrow(ME)
	end
end

%clearvars -except glvar errorCode;

if(glvar.camera_open==1)
	glvar.do_close=1;
	glvar.do_libunload=1;
	pco_camera_open_close(glvar);
end
