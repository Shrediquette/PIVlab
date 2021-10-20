function [errorCode,image_stack] = pco_sdk_example_recorder(imacount,exposure_time,triggermode)
% Set variables and grab images with the pco.recorder.
% When done copy imagedata from Recorder to a Matlab array
%
%   [ima_stack] = pco_sdk_example_recorder(imacount,exposure_time,triggermode)
%
% * Input parameters :
%    imacount                number of images to grab
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    ima_stack               stack with grabbed images  
%    errorCode               ErrorCode returned from pco.camera SDK or pco.recorder functions  
%

%function workflow
%open camera
%set variables 
%create recorder
%initialize recorder
%grab images with recorder
%stop camera
%copy image data from recorder to matlab image stack
%close camera
%
%%

%%initialize camera
glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('imacount','var'))
 imacount = 120;   
end

if(~exist('exposure_time','var'))
 exposure_time = 10;   
end

if(~exist('triggermode','var'))
 triggermode = 0;   
end

pco_camera_load_defines();
subfunc=pco_camera_subfunction();

disp('Open and initialize camera');
[errorCode,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(errorCode~=PCO_NOERROR)
 glvar.do_close=1;    
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
 commandwindow;
 return;
end 

hcam_ptr=glvar.out_ptr;

try

subfunc.fh_stop_camera(hcam_ptr);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', hcam_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(hcam_ptr,TIMESTAMP_MODE_BINARYANDASCII);
end 

subfunc.fh_set_exposure_times(hcam_ptr,exposure_time,2,0,2);
subfunc.fh_set_triggermode(hcam_ptr,triggermode);
subfunc.fh_set_bitalignment(hcam_ptr,BIT_ALIGNMENT_LSB);
subfunc.fh_set_transferparameter(hcam_ptr);

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', hcam_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   
%if PCO_ArmCamera does fail no images can be grabbed
if(errorCode~=PCO_NOERROR)
 if(glvar.camera_open==1)
  glvar.do_close=1;
  glvar.do_libunload=1;
  pco_camera_open_close(glvar);
 end   
 commandwindow;
 return;
end 

subfunc.fh_get_triggermode(hcam_ptr);
imatime=subfunc.fh_show_frametime(hcam_ptr);
disp('Initialize camera done ');

%%
%////////////////////////////////////////////////////////////
%   here is the startpoint of the pco.recorder part
%////////////////////////////////////////////////////////////

% Test if recorder library is loaded
if (~libisloaded('PCO_CAM_RECORDER'))
  warning off MATLAB:loadlibrary:StructTypeExists
 % make sure the dll and h file specified below resides in your current folder
  loadlibrary('PCO_Recorder','SC2_CamMatlab.h' ...
              ,'addheader','PCO_Recorder_Export.h' ...    
              ,'alias','PCO_CAM_RECORDER');
  disp('PCO_CAM_RECORDER library is loaded!');
else
 [errorCode] = calllib('PCO_CAM_RECORDER','PCO_RecorderResetLib',0);
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_RecorderResetLib',errorCode);
  ME = MException('PCO_ERROR:RecorderResetLib','Cannot continue script if ResetLib is not done');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end 
end

%uncomment to show functions and parameters of the recorder library
%libfunctionsview('PCO_CAM_RECORDER');

%Create and setup recorder for single (or dual) camera operation
%storing images in RAM
camcount=1;

MaxImgCountArr=zeros(1,camcount,'uint32');
pMaxImgCountArr=libpointer('uint32Ptr',MaxImgCountArr);

pImgDistributionArr=libpointer('uint32Ptr');

%fill structures according to available cameras
if camcount==1
 ml_camlist.cam_ptr1=libpointer('voidPtr',hcam_ptr);
%uncomment if ImgDistributionArr setting is necessary
 %ImgDistributionArr=zeros(1,camcount,'uint32');
 %ImgDistributionArr(1)=imacount+10;
 %pImgDistributionArr=libpointer('uint32Ptr',ImgDistributionArr);
elseif camcount==2    
 ml_camlist.cam_ptr1=libpointer('voidPtr',hcam_ptr);
 ml_camlist.cam_ptr2=libpointer('voidPtr');
%uncomment if ImgDistributionArr setting is necessary
 %ImgDistributionArr=zeros(1,camcount,'uint32');
 %ImgDistributionArr(1)=imacount+10;
 %ImgDistributionArr(2)=imacount+10;
 %pImgDistributionArr=libpointer('uint32Ptr',ImgDistributionArr);
end        

camera_array=libstruct('PCO_cam_ptr_List',ml_camlist);

diskchar=int8('C');

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
 pco_errdisp('PCO_RecorderCreate',errorCode);   
 ME = MException('PCO_ERROR:RecorderCreate','Cannot continue script when creation of recorder fails');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
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
 clear camera_array;
 ME = MException('PCO_ERROR:RecorderInit','Cannot continue script when initialisation of recorder fails');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

IsRunning   =true;
IsNotValid  =false;
ProcImgCount=uint32(0);
ReqImgCount =uint32(0);
StartTime   =uint32(0);
StopTime    =uint32(0);

[errorCode,~,~...
 ,IsRunning,~,~...
 ,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                           ,hrec_ptr,hcam_ptr ...
                           ,IsRunning,IsNotValid,IsNotValid ...
                           ,ProcImgCount,ReqImgCount ...
                           ,[],[] ...
                           ,StartTime,StopTime);
pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 

if IsRunning
 s='started';
else
 s='stopped';
end 

disp(['Current runstate: ',s]);
disp(['images done:      ',int2str(ProcImgCount)]);
disp(['images requested: ',int2str(ReqImgCount)]);

%not really necessary here
[errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderCleanup',hrec_ptr,[]);
pco_errdisp('PCO_RecorderCleanup',errorCode);   
 
looptime=(imatime*imacount);
disp(['time for all images is:   ',int2str(looptime),' seconds']); 

disp('Start Recorder'); 
tic;
[errorCode] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderStartRecord',hrec_ptr,[]);
pco_errdisp('PCO_RecorderStartRecord',errorCode);   

[errorCode,~,~,IsRunning] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr ...
                          ,IsRunning,IsNotValid,IsNotValid ...
                          ,ProcImgCount,ReqImgCount ...
                          ,[],[],[],[]);
pco_errdisp('PCO_RecorderGetStatus',errorCode);   

if IsRunning
 s='started';
else
 s='stopped';
end 
disp(['Current runstate: ',s]);

while(IsRunning)
 pause(0.5);
 
[errorCode,~,~...
 ,IsRunning,~,~...
 ,ProcImgCount,ReqImgCount] = calllib('PCO_CAM_RECORDER', 'PCO_RecorderGetStatus' ...
                          ,hrec_ptr,hcam_ptr ...
                          ,IsRunning,IsNotValid,IsNotValid ...
                          ,ProcImgCount,ReqImgCount ...
                          ,[],[] ...
                          ,StartTime,StopTime);
 pco_errdisp('PCO_PCO_RecorderGetStatus',errorCode); 
 disp(['images done: ',int2str(ProcImgCount)]);
 
 if(ProcImgCount>=ReqImgCount)
  disp('break on ImageCount');
  break;
 end
   
 t=toc;
 if(t>looptime+10)
  disp('break on looptime');
  break;
 end
end


[errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderStopRecord',hrec_ptr,hcam_ptr);
pco_errdisp('PCO_RecorderStopRecord',errorCode);   

[errorCode,image_stack]=pco_recorder_copy_images(hrec_ptr,hcam_ptr,imacount);
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

catch ME
 errorCode=subfunc.fh_lasterr();
 txt=blanks(101);
 txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);

 if(exist('hrec_ptr','var'))
  [erri]=calllib('PCO_CAM_RECORDER','PCO_RecorderDelete',hrec_ptr);
  pco_errdisp('PCO_RecorderDelete',erri);   
 end 

 clearvars -except ME glvar errorCode txt;

 if(libisloaded('PCO_CAM_RECORDER'))
  unloadlibrary('PCO_CAM_RECORDER');
 end
 
 if(glvar.camera_open==1)
  glvar.do_close=1;
  glvar.do_libunload=1;
  pco_camera_open_close(glvar);
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
  clearvars -except errorCode;
  commandwindow;
  return;
 else
  close(); 
  clearvars -except ME;
  rethrow(ME)
 end
end    

clearvars -except glvar errorCode image_stack;

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

%draw_images(ima_stack,1);

clear glvar;
commandwindow;
end

%%

function [errorCode,image_stack,metastructs,timestructs]=pco_recorder_copy_images(hrec_ptr,hcam_ptr,imacount)
   
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

[errorCode,~,~,~,act_xsize,act_ysize]=calllib('PCO_CAM_RECORDER','PCO_RecorderGetImageAddress',hrec_ptr,hcam_ptr,1,bufadr,act_xsize,act_ysize,[]);
pco_errdisp('PCO_RecorderGetImageAddress',errorCode);   

%allocate matlab array and copy images from recorder
imasize= bytepix*double(act_xsize)* double(act_ysize); 
disp(['allocated matlab memory is ',num2str((imasize*imacount)/(1024*1024*1024),'%.2f'),'GByte'])

image_stack=zeros(act_xsize,act_ysize,imacount,'uint16');
 
libmeta=libstruct('PCO_METADATA_STRUCT');
set(libmeta,'wSize',libmeta.structsize);

libtime=libstruct('PCO_TIMESTAMP_STRUCT');
set(libtime,'wSize',libtime.structsize);


%check if recorderdata has metastructs and timestructs included
im_ptr=libpointer('uint16Ptr',image_stack(:,:,1));
[errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderCopyImage',hrec_ptr,hcam_ptr,0,1,1,act_xsize,act_ysize,im_ptr,[],libmeta,libtime); 
pco_errdisp('PCO_RecorderCopyImage',errorCode);
str_meta=get(libmeta);
if(str_meta.wSize ~= 0)
 metastructs(imacount)=get(libmeta);
 set(libmeta,'wSize',libmeta.structsize);    
else
 libmeta=libpointer;   
end
    
str_time=get(libtime);
if(str_time.wSize ~= 0)
 timestructs(imacount)=get(libtime);   
 set(libtime,'wSize',libtime.structsize);
else
 libtime=libpointer;   
end

%copy images 
for n=1:imacount
 im_ptr=libpointer('uint16Ptr',image_stack(:,:,n));
 [errorCode]=calllib('PCO_CAM_RECORDER','PCO_RecorderCopyImage',hrec_ptr,hcam_ptr,n-1,1,1,act_xsize,act_ysize,im_ptr,[],libmeta,libtime); 
 pco_errdisp('PCO_RecorderCopyImage',errorCode);
 if errorCode ~= 0
  break;
 end
 
 disp(['PCO_RecorderCopyImage ',int2str(n),' done']);
 image_stack(:,:,n)=get(im_ptr,'Value');

 if(exist('timestructs','var'))
  txt=subfunc.fh_print_timestamp(image_stack(1:100,1:2,n),bitalign,bitpix);
  disp(['Timestamp data of image      (',num2str(n,'%04d'),'): ',txt]);
  timestructs(n)=get(libtime);
  txt=subfunc.fh_print_struct_timestamp(timestructs(n));
  disp(['Timestamp data of timestruct (',num2str(n,'%04d'),'): ',txt]);
  set(libtime,'wSize',libtime.structsize);    
 end

 if(exist('metastructs','var'))
  metastructs(n)=get(libmeta);
  txt=subfunc.fh_print_meta_timestamp(metastructs(n));
  disp(['Timestamp data of meta       (',num2str(n,'%04d'),'): ',txt]);
  set(libmeta,'wSize',libmeta.structsize);    
 end

 tmin=['min Value: ',int2str(min(min(image_stack(10:end-10,10:end-10,n))))];
 tmax=['max Value: ',int2str(max(max(image_stack(10:end-10,10:end-10,n))))];
 disp([tmin,'   ',tmax]);
end 

if errorCode == 0
 disp('transpose images');
 image_stack=permute(image_stack,[2 1 3]);
end

if(exist('timestructs','var'))
 n=3;   
 txt=subfunc.fh_print_timestamp_t(image_stack(1:2,1:100,n),bitalign,bitpix);
 disp(['Timestamp data of image      (',num2str(n,'%04d'),'): ',txt]);
 txt=subfunc.fh_print_struct_timestamp(timestructs(n));
 disp(['Timestamp data of timestruct (',num2str(n,'%04d'),'): ',txt]);
end

if(exist('metastructs','var'))
 n=3;   
 txt=subfunc.fh_print_meta_timestamp(metastructs(n));
 disp(['Timestamp data of meta       (',num2str(n,'%04d'),'): ',txt]);
 subfunc.fh_print_meta_struct(metastructs(n));
end

pause(0.5);
clear libmeta; 
clear libtime; 
end