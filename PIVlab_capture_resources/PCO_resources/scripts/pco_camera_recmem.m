function [errorCode,imacount,glvar] = pco_camera_recmem(imacount,segment,glvar)
%grab image(s) to internal camera memory if avaiable
%
%   [errorCode,glvar] = pco_camera_recmem(imacount,segment,glvar)
%
% * Input parameters :
%    glvar                   structure to hold status info
%    imacount                number of images to grab
%    segment                 segment to use for recording  
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    glvar                   structure to hold status info
%
%setup structure of camera memory segment and 
%grab 'imacount' images into the selected camera memory segment
%
%
%structure glvar is used to set different modes for
%load/unload library
%open/close camera SDK
%
%glvar.do_libunload: 1 unload lib at end
%glvar.do_close:     1 close camera SDK at end
%glvar.camera_open:  open status of camera SDK
%glvar.out_ptr:      libpointer to camera SDK handle
%
%if glvar does not exist,
%the library is loaded at begin and unloaded at end
%the SDK is opened at begin and closed at end
%
%if imacount does not exist, it is set to '1'
%if segment does not exist, it is set to '1'

%
%function workflow
%parameters are checked
%Alignment for the image data is set to LSB
%the size of the images is readout from the camera
%calculate amount of camera memory, which is needed to grab imacount images
%setup camera memory structure
%set camera to recorder submode SEQUENCE
%start camera
%wait until camera has grabbed all images
%return

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamMatlab.h' ...
                ,'addheader','SC2_CamExport.h' ...
                ,'alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

% Declaration of internal variables
if(~exist('imacount','var'))
 imacount = uint16(1);   
end

if(~exist('segment','var'))
 segment = uint16(1);   
end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=glvar.do_close;
else
 unload=1;   
 cam_open=0;
 do_close=1;
end


ph_ptr = libpointer('voidPtrPtr');

%libcall PCO_OpenCamera
if(cam_open==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
 if(errorCode == 0)
  disp('PCO_OpenCamera done');
  cam_open=1;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.camera_open=1;
   glvar.out_ptr=out_ptr;
  end 
 else
   pco_errdisp('PCO_OpenCamera',errorCode);   
  if(unload)
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end
end

pco_camera_load_defines();
subfunc=pco_camera_subfunction();
subfunc.fh_lasterr(0);

%get Camera Description to test if camera has internal memory
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_RECORDER)~=0)
 errorCode=PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED;
 disp('function is not supported because the selected camera does not have internal memory');
 return;
end    

if((segment<1)||(segment>4))
 errorCode=PCO_ERROR_APPLICATION|PCO_ERROR_WRONGVALUE;
 disp('value of segment must be in the range from 1 to 4');
 return;
end 


act_trigmode = uint16(10); 
[errorCode,~,act_trigmode] = calllib('PCO_CAM_SDK', 'PCO_GetTriggerMode', out_ptr,act_trigmode);
pco_errdisp('PCO_GetTriggerMode',errorCode);   

%stop camera before camera memory structure is set
act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 errorCode=PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED;
 disp('function is not supported while camera is in recording state ON');
 return;
end 

disp(['number of images to grab: ',int2str(imacount)]);
disp(['segment to be used      : ',int2str(segment)]);

[errorCode,imacount]=setup_recmem(out_ptr,imacount,segment);

imatime=subfunc.fh_get_frametime(out_ptr);

%it might be necessary to increase looptime for external trigger
looptime=imatime*imacount+10;
imatime=imatime+0.010;

d=10;
if(imacount>100)
 if(imacount<500)
  d=50;
 else
  d=100;
 end 
end 


dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
if(errorCode==PCO_NOERROR)
 disp('start camera and wait until all images are done');

 if(act_trigmode>=2)
  disp('send external trigger pulses within 5 seconds');   
  pause(0.00001); 
 elseif(act_trigmode==1)
  disp('call PCO_ForceTrigger');   
  trigdone=int16(1);    
  errorCode = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
  pco_errdisp('PCO_ForceTrigger',errorCode);   
 end        

 [errorCode,~] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState',out_ptr,1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   

 tic;
 while(dwValidImageCnt<imacount)
  pause(imatime);

  if(errorCode==PCO_NOERROR)
   [errorCode,~,dwValidImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
   pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
  end

  if(rem(dwValidImageCnt,d)==0)
   disp([int2str(dwValidImageCnt),'. image grabbed into camera memory']);
  end
  
  if(errorCode==PCO_NOERROR)
   [errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
   pco_errdisp('PCO_GetRecordingState',errorCode);   
  end
  
  if(errorCode~=PCO_NOERROR)
   disp('break on error');
   break;
  end 
  if(act_recstate==0)
   disp('break on act_recstate==0');
   break;
  end 
  
  if(act_trigmode==1)
   errorCode = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
   pco_errdisp('PCO_ForceTrigger',errorCode);   
  end
  
  t=toc;
  if(t>looptime)
   disp('break on looptime');
   break;
  end 
 end 
end

if(errorCode==PCO_NOERROR)
 [errorCode,~,dwValidImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
 pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
end

imacount=dwValidImageCnt;
disp([int2str(imacount),' images grabbed to camera memory']); 

if(exist('glvar','var'))
 glvar = close_camera(out_ptr,unload,do_close,cam_open,glvar);
else
 close_camera(out_ptr,unload,do_close,cam_open);   
end

end


function [errorCode,imacount]=setup_recmem(out_ptr,imacount,segment)

subfunc=pco_camera_subfunction();
pco_camera_load_defines();

act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
pco_errdisp('PCO_GetSizes',errorCode);   

size=uint32(act_xsize);
size=size*uint32(act_ysize)*2;

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetStorageMode',out_ptr,STORAGE_MODE_RECORDER);
 pco_errdisp('PCO_SetStorageMode',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode',out_ptr,RECORDER_SUBMODE_SEQUENCE);
 pco_errdisp('PCO_SetRecorderSubmode',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ArmCamera',out_ptr);
 pco_errdisp('PCO_ArmCamera',errorCode);   
end

%get Size of installed Camera memory
dwRamSize=uint32(220);
wPageSize=uint16(110);
if(errorCode==PCO_NOERROR)
 [errorCode,~,dwRamSize,wPageSize]=calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSize',out_ptr,dwRamSize,wPageSize);
 pco_errdisp('PCO_GetCameraRamSize',errorCode);   
end

%disp(['dwRamSize :',int2str(dwRamSize),'  wPageSized :',int2str(wPageSize)]);

%get actual sizes of Segments
dwSegment=uint32(zeros(1,4));
if(errorCode==PCO_NOERROR)
 [errorCode,~,dwSegment]=calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSegmentSize',out_ptr,dwSegment);
 pco_errdisp('PCO_GetCameraRamSegmentSize',errorCode);   
end


dwImageMemsize=uint32(size/(uint32(wPageSize*2)));
if(rem(dwImageMemsize,uint32(wPageSize)))
 dwImageMemsize=dwImageMemsize+1;
end

dwSegmentSize=uint32(dwImageMemsize*imacount);

dwSegment(segment)=0;
max_avail_size=dwRamSize-dwSegment(1)-dwSegment(2)-dwSegment(3)-dwSegment(4);

if(max_avail_size<dwSegmentSize)
 imacount=max_avail_size/dwImageMemsize;
 disp(['imagecount reduced to ',int2str(imacount),'because internal Ram is too small']);
 if(imacount<1)
  errorCode=PCO_ERROR_APPLICATION|PCO_ERROR_NOMEMORY;
  return;
 end 
 dwSegmentSize=uint32(dwImageMemsize*imacount);
end 

dwSegment(segment)=dwSegmentSize;

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize',out_ptr,dwSegment);
 pco_errdisp('PCO_SetCameraRamSegmentSize',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment',out_ptr,segment);
 pco_errdisp('PCO_SetActiveRamSegment',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ArmCamera',out_ptr);
 pco_errdisp('PCO_ArmCamera',errorCode);   
end 

%now we look if enough memory is assigned to the memory segment
dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
if(errorCode==PCO_NOERROR)
 [errorCode,~,dwValidImageCnt,dwMaxImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
 pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
end

if(dwMaxImageCnt==0)
 subfunc.fh_start_camera(out_ptr);
 subfunc.fh_stop_camera(out_ptr);
 if(errorCode==PCO_NOERROR)
  [errorCode,~,dwValidImageCnt,dwMaxImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
  pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
 end
end

%increase or decrease segment_size to adjust for correct dwMaxImageCnt
while(dwMaxImageCnt~=imacount)
 if(errorCode~=PCO_NOERROR)
  break;
 end
 
 if(dwMaxImageCnt<imacount)
  if((imacount-dwMaxImageCnt)>1)
   num=dwSegmentSize;
   num=num/(dwMaxImageCnt-1);
   num=num*imacount;
   dwSegmentSize=uint32(num);
  else
   dwSegmentSize=dwSegmentSize+uint32(wPageSize/32);
  end
 elseif(dwMaxImageCnt>imacount)
  if((dwMaxImageCnt-imacount)>1)
   num=dwSegmentSize;
   num=num/(dwMaxImageCnt-1);
   num=num*imacount;
   dwSegmentSize=uint32(num);
  else
   dwSegmentSize=dwSegmentSize-wPageSize/32;
  end
 end 
 
 if((dwSegmentSize<uint32(wPageSize*2))||(dwSegmentSize>(max_avail_size-uint32(wPageSize*2))))
  break;
 end
 
 dwSegment(segment)=dwSegmentSize;
 
 if(errorCode==PCO_NOERROR)
  [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize',out_ptr,dwSegment);
  pco_errdisp('PCO_SetCameraRamSegmentSize',errorCode);   
 end

 if(errorCode==PCO_NOERROR)
  [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ArmCamera',out_ptr);
  pco_errdisp('PCO_ArmCamera',errorCode);   
 end 
 
 if(errorCode==PCO_NOERROR)
  [errorCode,~,dwValidImageCnt,dwMaxImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
  pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
 end

 if(dwMaxImageCnt==0)
     
     
  subfunc.fh_start_camera(out_ptr);
  subfunc.fh_stop_camera(out_ptr);
  if(errorCode==PCO_NOERROR)
   [errorCode,~,dwValidImageCnt,dwMaxImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
   pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
  end
 end
end 

disp(['dwMaxImageCnt :',int2str(dwMaxImageCnt),'  dwValidImageCnt :',int2str(dwValidImageCnt)]);

imacount=dwMaxImageCnt;

%clear all data in active segment
if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ClearRamSegment',out_ptr);
 pco_errdisp('PCO_ClearRamSegment',errorCode);   
end   

end
  

function [glvar] = close_camera(out_ptr,unload,do_close,cam_open,glvar)
 if((do_close==1)&&(cam_open==1))
  errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera',out_ptr);
  if(errorCode)
   pco_errdisp('PCO_CloseCamera',errorCode);   
  else
   disp('PCO_CloseCamera done');
   cam_open=0;
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
  end    
 end
 if((unload==1)&&(cam_open==0))
  unloadlibrary('PCO_CAM_SDK');
  disp('PCO_CAM_SDK unloadlibrary done');
  commandwindow;
 end 
end
