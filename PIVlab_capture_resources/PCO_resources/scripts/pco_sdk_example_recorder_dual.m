function [ima_stack1,ima_stack2,errorCode] = pco_sdk_example_recorder_dual(imacount,exposure_time,triggermode)
% set variables and grab images with the pco.recorder from 2 cameras.
% When done copy imagedata from Recorder to a Matlab arrays
%
%   [ima_stack1,imastack2] = pco_sdk_example_recorder(imacount,exposure_time,triggermode)
%
% * Input parameters :
%    imacount                number of images to grab
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    ima_stack1              stack with grabbed images from camera 1  
%    ima_stack2              stack with grabbed images from camera 2  
%    errorCode               ErrorCode returned from pco.camera SDK or pco.recorder functions  
%

%function workflow
%open camera1
%open camera2
%set variables 
%create recorder
%initialize recorder
%grab images with recorder
%stop camera
%copy image data from recorder to matlab image stacks
%close camera
%
%%

%%initialize cameras
glvar1=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
glvar2=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('imacount','var'))
 imacount = 10;   
end

if(~exist('exposure_time','var'))
 exposure_time = 10;   
end

if(~exist('triggermode','var'))
 triggermode = 0;   
end

pco_camera_load_defines();
subfunc=pco_camera_subfunction();

disp('Open and initialize camera 1');
[errorCode,glvar1]=pco_camera_open_close(glvar1);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar1.camera_open)]);
if(errorCode~=PCO_NOERROR)
 glvar1.do_close=1;    
 glvar1.do_libunload=1;
 pco_camera_open_close(glvar1);
 commandwindow;
 return;
end 

hcam_ptr1=glvar1.out_ptr;

subfunc.fh_stop_camera(hcam_ptr1);

cam_desc1=libstruct('PCO_Description');
set(cam_desc1,'wSize',cam_desc1.structsize);
[errorCode,~,cam_desc1] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', hcam_ptr1,cam_desc1);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc1.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(hcam_ptr1,TIMESTAMP_MODE_BINARYANDASCII);
end 

subfunc.fh_set_exposure_times(hcam_ptr1,exposure_time,2,0,2);
subfunc.fh_set_triggermode(hcam_ptr1,triggermode);
subfunc.fh_set_bitalignment(hcam_ptr1,BIT_ALIGNMENT_LSB);
subfunc.fh_set_transferparameter(hcam_ptr1);

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', hcam_ptr1);
pco_errdisp('PCO_ArmCamera',errorCode);   
%if PCO_ArmCamera does fail no images can be grabbed
if(errorCode~=PCO_NOERROR)
 if(glvar1.camera_open==1)
  glvar1.do_close=1;
  glvar1.do_libunload=1;
  pco_camera_open_close(glvar1);
 end   
 commandwindow;
 return;
end 

subfunc.fh_get_triggermode(hcam_ptr1);
imatime1=subfunc.fh_show_frametime(hcam_ptr1);
disp('Initialize camera 1 done ');

disp('Open and initialize camera 2');
[errorCode,glvar2]=pco_camera_open_close(glvar2);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar2.camera_open)]);
if(errorCode~=PCO_NOERROR)
 if(glvar1.camera_open==1)
  glvar1.do_close=1;
  glvar1.do_libunload=1;
  pco_camera_open_close(glvar1);
 end   
 commandwindow;
 return;
end 

hcam_ptr2=glvar2.out_ptr;

subfunc.fh_stop_camera(hcam_ptr2);

cam_desc2=libstruct('PCO_Description');
set(cam_desc2,'wSize',cam_desc2.structsize);
[errorCode,~,cam_desc2] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', hcam_ptr2,cam_desc2);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc2.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(hcam_ptr2,TIMESTAMP_MODE_BINARYANDASCII);
end 

subfunc.fh_set_exposure_times(hcam_ptr2,exposure_time,2,0,2);
subfunc.fh_set_triggermode(hcam_ptr2,triggermode);
subfunc.fh_set_bitalignment(hcam_ptr2,BIT_ALIGNMENT_LSB);
subfunc.fh_set_transferparameter(hcam_ptr2);

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', hcam_ptr2);
pco_errdisp('PCO_ArmCamera',errorCode);   
%if PCO_ArmCamera does fail no images can be grabbed
if(errorCode~=PCO_NOERROR)
 if(glvar2.camera_open==1)
  glvar2.do_close=1;
  pco_camera_open_close(glvar2);
 end   
 if(glvar1.camera_open==1)
  glvar1.do_close=1;
  glvar1.do_libunload=1;
  pco_camera_open_close(glvar1);
 end   
 commandwindow;
 return;
end 

subfunc.fh_get_triggermode(hcam_ptr2);
imatime2=subfunc.fh_show_frametime(hcam_ptr2);
disp('Initialize camera 2 done ');



%%
%////////////////////////////////////////////////////////////
%     here is the startpoint of the pco.recorder part
%////////////////////////////////////////////////////////////

% Test if recorder library is loaded
if (~libisloaded('PCO_CAM_RECORDER'))
 % make sure the dll and h file specified below resides in your current folder
  loadlibrary('PCO_Recorder','SC2_CamMatlab.h' ...
              ,'addheader','PCO_Recorder_Export.h' ...    
              ,'alias','PCO_CAM_RECORDER');
  disp('PCO_CAM_RECORDER library is loaded!');
else
 [errorCode] = calllib('PCO_CAM_RECORDER','PCO_RecorderResetLib',1);
 pco_errdisp('PCO_RecorderResetLib',errorCode);
 if(errorCode~=PCO_NOERROR)
  commandwindow;
  return;
 end 
end

%uncomment to show functions and parameters of the recorder library
%libfunctionsview('PCO_CAM_RECORDER');

%Create and setup recorder for dual camera operation
%storing images in RAM
camcount=2;

MaxImgCountArr=zeros(1,camcount,'uint32');
pMaxImgCountArr=libpointer('uint32Ptr',MaxImgCountArr);

pImgDistributionArr=libpointer('uint32Ptr');

%fill structures according to available cameras
if camcount==1
 ml_camlist.cam_ptr1=libpointer('voidPtr',hcam_ptr1);
%uncomment if ImgDistributionArr setting is necessary
 %ImgDistributionArr=zeros(1,camcount,'uint32');
 %ImgDistributionArr(1)=imacount+10;
 %pImgDistributionArr=libpointer('uint32Ptr',ImgDistributionArr);
elseif camcount==2    
 ml_camlist.cam_ptr1=libpointer('voidPtr',hcam_ptr1);
 ml_camlist.cam_ptr2=libpointer('voidPtr',hcam_ptr2);
%uncomment if ImgDistributionArr setting is necessary
 %ImgDistributionArr=zeros(1,camcount,'uint32');
 %ImgDistributionArr(1)=imacount+10;
 %ImgDistributionArr(2)=imacount+10;
 %pImgDistributionArr=libpointer('uint32Ptr',ImgDistributionArr);
end        

camera_array=libstruct('PCO_cam_ptr_List',ml_camlist);

diskchar=int8(67);  %'C'

hreci_ptr = libpointer('voidPtrPtr');

[errorCode,hrec_ptr,~,ImgDistributionArr,MaxImgCountArr] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCreate' ...
                          ,hreci_ptr ...
                          ,camera_array ...
                          ,pImgDistributionArr ...
                          ,camcount ...
                          ,PCO_RECORDER_MODE_MEMORY ...
                          ,diskchar ...
                          ,pMaxImgCountArr);
pco_errdisp('PCO_RecorderCreate',errorCode);   

if errorCode ~= 0
 clear camera_array;
 unloadlibrary('PCO_CAM_RECORDER');
 disp('PCO_CAM_RECORDER unloadlibrary done');

 if(glvar2.camera_open==1)
  glvar2.do_close=1;
  pco_camera_open_close(glvar2);
 end   
 if(glvar1.camera_open==1)
  glvar1.do_close=1;
  glvar1.do_libunload=1;
  pco_camera_open_close(glvar1);
 end   
 commandwindow; 
 return;
end 

if ~isNull(pImgDistributionArr)
 disp(['ImgDistribution: ',int2str(ImgDistributionArr)]);
 if imacount>min(ImgDistributionArr)
  imacount=min(ImgDistributionArr);
  disp('imacount changed to ',imacount);
 end 
end

disp(['MaxImgCount:     ',int2str(MaxImgCountArr)]);

if imacount>min(MaxImgCountArr)
 imacount=min(MaxImgCountArr);
 disp('imacount changed to ',imacount);
end 

ImgCountArr=zeros(1,camcount,'uint32');
ImgCountArr(1)=imacount;
if camcount==2    
 ImgCountArr(2)=imacount;
end        

[errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderInit' ...
                      ,hrec_ptr ...
                      ,ImgCountArr,camcount ...
                      ,PCO_RECORDER_MEMORY_SEQUENCE ...
                      ,1,[],[]);
pco_errdisp('PCO_RecorderInit',errorCode);   

if errorCode ~= 0
 [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderDelete',hrec_ptr);
 pco_errdisp('PCO_RecorderDelete',errorCode);   
    
 clear camera_array;
 
 unloadlibrary('PCO_CAM_RECORDER');
 disp('PCO_CAM_RECORDER unloadlibrary done');

 if(glvar2.camera_open==1)
  glvar2.do_close=1;
  pco_camera_open_close(glvar2);
 end   
 if(glvar1.camera_open==1)
  glvar1.do_close=1;
  glvar1.do_libunload=1;
  pco_camera_open_close(glvar1);
 end   
 commandwindow; 
 return;
end 

IsRunning1    =true;
IsNotValid    =false;
ProcImgCount1 =uint32(0);
ReqImgCount1  =uint32(0);
StartTime     =uint32(0);
StopTime      =uint32(0);

[errorCode,~,~...
 ,IsRunning1,~,~...
 ,ProcImgCount1,ReqImgCount1] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                           ,hrec_ptr,hcam_ptr1 ...
                           ,IsRunning1,IsNotValid,IsNotValid ...
                           ,ProcImgCount1,ReqImgCount1 ...
                           ,[],[] ...
                           ,StartTime,StopTime);
pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 

if IsRunning1
 s='started';
else
 s='stopped';
end 
disp(['Cam1 Current runstate: ',s]);
disp(['Cam1 images done:      ',int2str(ProcImgCount1)]);
disp(['Cam1 images requested: ',int2str(ReqImgCount1)]);

IsRunning2    =true;
ProcImgCount2 =uint32(0);
ReqImgCount2  =uint32(0);

[errorCode,~,~...
 ,IsRunning2,~,~...
 ,ProcImgCount2,ReqImgCount2] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                           ,hrec_ptr,hcam_ptr2 ...
                           ,IsRunning2,IsNotValid,IsNotValid ...
                           ,ProcImgCount2,ReqImgCount2 ...
                           ,[],[] ...
                           ,StartTime,StopTime);
pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 

if IsRunning2
 s='started';
else
 s='stopped';
end 
disp(['Cam2 Current runstate: ',s]);
disp(['Cam2 images done:      ',int2str(ProcImgCount2)]);
disp(['Cam2 images requested: ',int2str(ReqImgCount2)]);

%not really necessary here
[errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCleanup',hrec_ptr,[]);
pco_errdisp('PCO_RecorderCleanup',errorCode);   
 
imatime=max(imatime1,imatime2);
looptime=(imatime*imacount);
disp(['time for all images is:   ',int2str(looptime),' seconds']); 

disp('Start Recorder'); 
tic;
[errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderStartRecord',hrec_ptr,[]);
pco_errdisp('PCO_PCO_RecorderStartRecord',errorCode);   

[errorCode,~,~,IsRunning1] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr1 ...
                          ,IsRunning1,IsNotValid,IsNotValid ...
                          ,ProcImgCount1,ReqImgCount1 ...
                          ,[],[],[],[]);
pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 

if IsRunning1
 s='started';
else
 s='stopped';
end 
disp(['Cam1 Current runstate: ',s]);

[errorCode,~,~,IsRunning2] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr2 ...
                          ,IsRunning2,IsNotValid,IsNotValid ...
                          ,ProcImgCount2,ReqImgCount2 ...
                          ,[],[],[],[]);
pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 

if IsRunning2
 s='started';
else
 s='stopped';
end 
disp(['Cam2 Current runstate: ',s]);


while( IsRunning1 || IsRunning2)
 pause(0.5);
 
[errorCode,~,~...
 ,IsRunning1,~,~...
 ,ProcImgCount1,ReqImgCount1] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr1 ...
                          ,IsRunning1,IsNotValid,IsNotValid ...
                          ,ProcImgCount1,ReqImgCount1 ...
                          ,[],[] ...
                          ,StartTime,StopTime);
 pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 
 disp(['CAM1 images done: ',int2str(ProcImgCount1)]);
 
[errorCode,~,~...
 ,IsRunning2,~,~...
 ,ProcImgCount2,ReqImgCount2] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr2 ...
                          ,IsRunning2,IsNotValid,IsNotValid ...
                          ,ProcImgCount2,ReqImgCount2 ...
                          ,[],[] ...
                          ,StartTime,StopTime);
 pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 
 disp(['CAM2 images done: ',int2str(ProcImgCount2)]);
 
 
 if((ProcImgCount1>=ReqImgCount1)&&(ProcImgCount2>=ReqImgCount2))
  disp('break on ImageCount');
  break;
 end
 
 t=toc;
 if(t>looptime+10)
  disp('break on looptime');
  break;
 end
end


[errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderStopRecord',hrec_ptr,hcam_ptr1);
pco_errdisp('PCO_RecorderStopRecord',errorCode);   
[errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderStopRecord',hrec_ptr,hcam_ptr2);
pco_errdisp('PCO_RecorderStopRecord',errorCode);   

disp(' ');
disp('Cam1 Copy images');
[errorCode,ima_stack1]=pco_recorder_copy_images(hrec_ptr,hcam_ptr1,imacount,uint16(cam_desc1.wDynResDESC));
pco_errdisp('pco_recorder_copy_images',errorCode);   

disp(' ');
disp('Cam2 Copy images');
[errorCode,ima_stack2]=pco_recorder_copy_images(hrec_ptr,hcam_ptr2,imacount,uint16(cam_desc2.wDynResDESC));
pco_errdisp('pco_recorder_copy_images',errorCode);   

[errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderDelete',hrec_ptr);
pco_errdisp('PCO_RecorderDelete',errorCode);   

clear camera_array;

unloadlibrary('PCO_CAM_RECORDER');
disp('PCO_CAM_RECORDER unloadlibrary done');

%////////////////////////////////////////////////////////////
%    here is the endpoint of the pco.recorder part
%////////////////////////////////////////////////////////////
%%

if(glvar2.camera_open==1)
 glvar2.do_close=1;
 pco_camera_open_close(glvar2);
end   

if(glvar1.camera_open==1)
 glvar1.do_close=1;
 glvar1.do_libunload=1;
 pco_camera_open_close(glvar1);
end   

%draw_images(ima_stack,1);

clear glvar2;
clear glvar1;
commandwindow;
end

%%
function [errorCode,ima_stack]=pco_recorder_copy_images(hrec_ptr,hcam_ptr,imacount,bitpix)
   
subfunc=pco_camera_subfunction();

act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', hcam_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
pco_errdisp('PCO_GetSizes',errorCode);   

bitalign=subfunc.fh_get_bitalignment(hcam_ptr);

disp(['bitpix:   ',int2str(bitpix)]);
disp(['bitalign: ',int2str(bitalign)]);


%allocate matlab array and copy images from recorder

imasize=uint32(fix((double(bitpix)+7)/8));
imasize= imasize*uint32(act_xsize)* uint32(act_ysize); 

image=zeros(act_xsize,act_ysize,'uint16');
ima_stack=zeros(act_ysize,act_xsize,imacount,'uint16');
 
disp(['allocated matlab memory is ',num2str((double(imasize)*imacount)/(1024*1024*1024),'%.2f'),'GByte'])
 
str_meta=libstruct('PCO_METADATA_STRUCT');
set(str_meta,'wSize',str_meta.structsize);
str_time=libstruct('PCO_TIMESTAMP_STRUCT');
set(str_time,'wSize',str_time.structsize);

im_ptr=libpointer('uint16Ptr',image(:,:));
 
%copy images 
for n=1:imacount
 set(str_meta,'wSize',str_meta.structsize);
 set(str_time,'wSize',str_time.structsize);
 [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderCopyImage',hrec_ptr,hcam_ptr,n-1,1,1,act_xsize,act_ysize,im_ptr,[],str_meta,str_time); 
 pco_errdisp('PCO_RecorderCopyImage',errorCode);
 if errorCode ~= 0
  break;
 end
 
 disp(['PCO_RecorderCopyImage ',int2str(n),' done']);
 ima=get(im_ptr,'Value');
 ima_stack(:,:,n)=ima';
 txt=subfunc.fh_print_timestamp_t(ima_stack(1:2,1:50,n),bitalign,bitpix);
 disp(['Timestamp data of image ',int2str(n),' ',txt]);
 tmin=['min Value: ',int2str(min(min(ima_stack(10:end-10,10:end-10,n))))];
 tmax=['max Value: ',int2str(max(max(ima_stack(10:end-10,10:end-10,n))))];
 disp([tmin,'   ',tmax]);
end 

pause(0.5);
clear image; 
end
