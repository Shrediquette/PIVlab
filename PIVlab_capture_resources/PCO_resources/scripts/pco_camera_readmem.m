function [errorCode,image_stack,metadata_stack,glvar] = pco_camera_readmem(imacount,start,segment,glvar)
%read grabbed image from Camera memory to image_stack 
%
%   [errorCode,image_stack,glvar] = pco_camera_readmem(glvar,imacount,start,segment)
%
% * Input parameters :
%    glvar                   structure to hold status info
%    imacount                number of images to grab
%    start                   first image to read 
%    segment                 segment to use for readout  
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    image_stack uint16(,,)  grabbed images
%    glvar                   structure to hold status info
%
%read 'imacount' images from internal camera memory
%start with image number start
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
%
%function workflow
%parameters are checked
%Alignment for the image data is set to LSB
%the size of the images is readout from the camera
%labview array is build
%allocate buffer(s) in camera SDK 
%to readout single images PCO_GetImageEx function is used
%to readout multiple images
%PCO_AddBufferEx and PCO_WaitforBuffer functions are used in a loop
%free previously allocated buffer(s) in camera SDK 
%errorCode, if available glvar, and the image_stack with uint16 image data is returned
%

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

if(~exist('start','var'))
 start = 1;   
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

showall=0; %enable this to show more information

try

%get Camera Description
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_RECORDER)~=0)
 errorCode=bitor(PCO_ERROR_SDKAPPLICATION,PCO_ERROR_APPLICATION);
 errorCode=bitor(errorCode,PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED);
 ME = MException('PCO_ERROR:GENERALCAPS1_NO_RECORDER','Function is not supported because the selected camera does not have internal memory');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end    

if((segment<1)||(segment>4))
 errorCode=bitor(PCO_ERROR_SDKAPPLICATION,PCO_ERROR_APPLICATION);
 errorCode=bitor(errorCode,PCO_ERROR_WRONGVALUE);
 ME = MException('PCO_ERROR:SegmentNumber','value of segment must be in the range from 1 to 4');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 errorCode=bitor(PCO_ERROR_SDKAPPLICATION,PCO_ERROR_APPLICATION);
 errorCode=bitor(errorCode,PCO_ERROR_WRONGVALUE);
 ME = MException('PCO_ERROR:RecordingState','Function is not supported while camera is in recording state ON');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
if(errorCode==PCO_NOERROR)
 [errorCode,~,dwValidImageCnt]=calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment',out_ptr,segment,dwValidImageCnt,dwMaxImageCnt);
 pco_errdisp('PCO_GetNumberOfImagesInSegment',errorCode);   
end

if(dwValidImageCnt<1)
 errorCode=bitor(PCO_ERROR_SDKAPPLICATION,PCO_ERROR_APPLICATION);
 errorCode=bitor(errorCode,PCO_ERROR_WRONGVALUE);
 subfunc.fh_lasterr(errorCode);
 ME = MException('PCO_ERROR:ValidImageCount','No valid images found in selected segment %d',segment);
 throw(ME);   
end

if(imacount>dwValidImageCnt)
 imacount=dwValidImageCnt;   
 disp(['only ',int2str(dwValidImageCnt),' images found in camera memory reduce imacount to ',int2str(imacount)]);
end

if(start>dwValidImageCnt)
 start=1;   
 disp(['start exceeds valid image count ',int2str(dwValidImageCnt),' start is set to ',int2str(start)]);
end

if(start-1+imacount>dwValidImageCnt)
 imacount=dwValidImageCnt-start+1;   
 disp(['start + imacount exceeds valid image count ',int2str(dwValidImageCnt),' reduce imacount to ',int2str(imacount)]);
end


cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);
[errorCode,~,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
pco_errdisp('PCO_GetCameraType',errorCode);   

interface=uint16(cam_type.wInterfaceType);
bitpix=uint16(cam_desc.wDynResDESC);
bytepix=fix(double(bitpix+7)/8);

act_align = uint16(0); 
[errorCode,~,act_align] = calllib('PCO_CAM_SDK', 'PCO_GetBitAlignment', out_ptr,act_align);
pco_errdisp('PCO_GetBitAlignment',errorCode);   


wXRes=uint16(0);
wYRes=uint16(0);
wBinHorz=uint16(0);
wBinVert=uint16(0);
wRoiX0=uint16(0);
wRoiY0=uint16(0);
wRoiX1=uint16(0);
wRoiY1=uint16(0);
%[errorCode,~,wXRes,wYRes,~,~,wRoiX0,wRoiY0,wRoiX1,wRoiY1]  = calllib('PCO_CAM_SDK','PCO_GetSegmentImageSettings',out_ptr,segment,wXRes,wYRes,wBinHorz,wBinVert,wRoiX0,wRoiY0,wRoiX1,wRoiY1);
[errorCode,~,wXRes,wYRes]  = calllib('PCO_CAM_SDK','PCO_GetSegmentImageSettings',out_ptr,segment,wXRes,wYRes,wBinHorz,wBinVert,wRoiX0,wRoiY0,wRoiX1,wRoiY1);
pco_errdisp('PCO_GetSegmentImageSettings',errorCode);   

flags=1; %IMAGEPARAMETERS_READ_FROM_SEGMENTS
errorCode = calllib('PCO_CAM_SDK', 'PCO_SetImageParameters', out_ptr,wXRes,wYRes,flags,[],0);
if(errorCode)
 pco_errdisp('PCO_CamLinkSetImageParameters',errorCode);   
 return;
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment',out_ptr,segment);
 pco_errdisp('PCO_SetActiveRamSegment',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ArmCamera',out_ptr);
 pco_errdisp('PCO_ArmCamera',errorCode);   
end

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

act_xsize=wXRes;
act_ysize=wYRes;
% disp(['act_xsize: ',num2str(act_xsize),' act_ysize: ',num2str(act_ysize)]);
% disp(['wRoiX0: ',num2str(wRoiX0),' wRoiX1: ',num2str(wRoiX1),' xsize ',num2str(wRoiX1-wRoiX0+1)]);
% disp(['wRoiY0: ',num2str(wRoiY0),' wRoiY1: ',num2str(wRoiY1),' ysize ',num2str(wRoiY1-wRoiY0+1)]);
    
lineadd=0;   
if(metadatasize>0)
 xs=bytepix*double(act_xsize);
 i=fix(metadatasize/xs);
 lineadd=i+1;
end

imasize= bytepix * double(act_ysize+lineadd)* double(act_xsize);   

%only for firewire add always some lines
%to ensure enough memory is allocated for the transfer
if(interface==INTERFACE_FIREWIRE)
  imas= imasize;   
  i=fix(imas/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-imas;
  xs=bytepix*double(act_xsize);
  i=fix(i/xs);
  i=i+1;
  lineadd=lineadd+i;%
% disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
end
%disp([int2str(lineadd),' additional line(s) must be allocated ']);

disp(['actual recording state:   ',int2str(act_recstate)]);   
disp(['number of images to grab: ',int2str(imacount)]);
disp(['starting from number:     ',int2str(start)]);
if showall==1
 disp(['interface type:           ',int2str(interface)]);
 disp(['actual alignment:         ',int2str(act_align)]);
 disp(['imasize is:               ',int2str(imasize)]); 
end


image_stack=zeros(act_xsize,(act_ysize+lineadd),imacount,'uint16');

% if((imasize*imacount)<(1024*1024*512))
%  disp(['allocated memory is ',num2str((imasize*imacount)/(1024*1024),'%.2f'),'MByte'])
% else    
%  disp(['allocated memory is ',num2str((imasize*imacount)/(1024*1024*1024),'%.2f'),'GByte'])
% end

[errorCode,image_stack] = pco_read_image_multi(out_ptr,image_stack,start);

if(errorCode==0)
 [~,height,count]=size(image_stack);
 if(count~=imacount)
  disp(['Only ',int2str(count),' images grabbed']);
 end 
 
 if(metadatasize>0)
  metaline=zeros(metadatasize,imacount,'uint16');
 end
 
 for n=1:count
  if showall==1
   txt=subfunc.fh_print_timestamp(image_stack(:,:,n),act_align,bitpix);
   disp(['Timestamp of image(',num2str(n,'%04d'),'): ',txt]);
  end
  if(metadatasize>0)
   meta=image_stack(:,act_ysize+1:end,n);
   metaline(:,n)=meta(1:metadatasize);
  end
 end
 
 if(height>act_ysize)
  disp('remove added lines');
  image_stack=image_stack(:,1:act_ysize,:);
 end 

 if((act_align==BIT_ALIGNMENT_MSB)&&(bitpix<16))
  s=int16(16-bitpix);
  disp(['bitshift image (>>',num2str(s),') to LSB alignment']);
  s=s*-1;   
  image_stack=bitshift(image_stack,s);
 end 

 disp('transpose images');
 image_stack=permute(image_stack,[2 1 3]);
end 

if(metadatasize>0)
 metadata_stack=metaline;   
else
 metadata_stack=[];   
end


catch MES
 if(~exist('glvar','var'))
  errorCode=subfunc.fh_lasterr();
  txt=blanks(101);
  txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);
     
  close_camera(out_ptr,unload,do_close,cam_open);
  
  msg=[MES.identifier,' ',MES.message];
  warning('off','backtrace')
  warning(msg);
  disp(txt);
  for k=1:length(MES.stack)
    disp(['from file ',MES.stack(k).file,' at line ',num2str(MES.stack(k).line)]);
  end
  clearvars;
  return;
 else
  rethrow(MES);
 end 
end


if(exist('glvar','var'))
 glvar = close_camera(out_ptr,unload,do_close,cam_open,glvar);
else
 close_camera(out_ptr,unload,do_close,cam_open);   
end

end

function [errorCode,image_stack] = pco_read_image_multi(out_ptr,image_stack,start)
%act_xsize,act_ysize,bitpix,interface)

pco_camera_load_defines();
subfunc=pco_camera_subfunction();

try
    
[width,height,imacount]=size(image_stack);
imasize=2*height*width;
%disp(['imacount is: ',num2str(imacount),' start is: ',num2str(start)]); 

%need a dummy image, which can be added at end of loop
%to ensure event for this buffer is reset (SDK 1.25)
dummy_image=zeros(width,height,'uint16');

if(imacount==1)
 bufcount=1;
else
 if(imacount<4)
  bufcount=2;
 else
  bufcount=4;
 end 
end

buflist=libstruct('PCO_Buflist');
names=fieldnames(buflist);
x=1:4:length(names);
var_bufnr=names(x);
x=3:4:length(names);
var_statusdll=names(x);
x=4:4:length(names);
var_statusdrv=names(x);

%Allocate SDK buffers and set address of buffers in stack
sBufNr=zeros(1,bufcount,'int16');
bufset=zeros(1,bufcount,'int16');
ev_ptr=libpointer('voidPtr',bufcount);

%create pointer arrays
count=imacount+bufcount;
status_drv_ptr(count)=libpointer('uint32Ptr');
im_ptr(count)=libpointer('voidPtr');

for n=1:imacount
 image_stack(1:10,1,n)=uint16(n);
 im_ptr(n)=libpointer('uint16Ptr',image_stack(:,:,n));
 status_drv_ptr(n)=libpointer('uint32Ptr',n);
end 

%add dummy buffer for last entries in arrays im_ptr and status_drv_ptr
for n=1:bufcount
 dummy_image(1:10,1)=uint16(1234);
 z=imacount+n;  
 im_ptr(z)=libpointer('uint16Ptr',dummy_image(:,:));
 status_drv_ptr(z)=libpointer('uint32Ptr',z);
end

%PCO_AllocateBuffer is used to create necessary Events
for n=1:bufcount   
 sBufNri=int16(-1);
 ev_ptr(n) = libpointer('voidPtr');

 [errorCode,~,sBufNri] = calllib('PCO_CAM_SDK','PCO_AllocateBuffer',out_ptr,sBufNri,imasize,im_ptr(n),ev_ptr(n));
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_AllocateBuffer',errorCode);   
  ME = MException('PCO_ERROR:AllocateBuffer','Cannot continue script without allocated Buffers');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end
 sBufNr(n)=sBufNri;
 buflist.(var_bufnr{n})=sBufNri;
%SDK 1.25 and below: PCO_WaitforBuffer does not handle this Flag correctly 
 e=bitor(buflist.(var_statusdll{n}),uint32(PCO_BUFFER_EVAUTORES),'uint32');
 buflist.(var_statusdll{n})=e;
 buflist.(var_statusdrv{n})=0;
end

% for n=1:imacount+bufcount
%   a=im_ptr(n).Value(1,1);
%   disp(['after alloc image ',num2str(n),' Value ',num2str(a)]);
% end 

set=1;
last=start+imacount-1;

for n=1:bufcount
% disp(['call PCO_AddBufferExtern start ',num2str(start),' set ',num2str(set),' value ',num2str(im_ptr(set).Value(1,1))]);   
 errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferExtern',out_ptr,ev_ptr(n),1,start,start,0,im_ptr(set),imasize,status_drv_ptr(set)); %buflist.(var_statusdrv{n})
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_AddBufferExtern',errorCode);   
  ME = MException('PCO_ERROR:AddBufferExtern','Cannot continue script without added Buffers');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end 
 bufset(n)=set;
%  disp(['set',num2str(set),' statusdrv : ',num2str(status_drv_ptr(set).Value,'%08x')]); 
 set=set+1;
 if(start<last)
  start=start+1;
 end 
end

image_error=0;
last_ok=0;

tic;

%Image Loop
ima_nr=1;
while(ima_nr<=imacount)      
 [errorCode,~,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,5000);
 if(errorCode)
  pco_errdisp('PCO_WaitforBuffer',errorCode);
  image_error=errorCode;
  break;
 end 
% disp(['After wait image ',num2str(ima_nr),' last_ok ',num2str(last_ok)]);
%PCO_WaitforBuffer does return if one or more buffer events are set
%Therefore Status of all buffers, which had been setup, must be checked 
%We start at estimated next buffer
 next=last_ok+1;
 multi=0;
 for n=1:bufcount
  if(next>bufcount)
   next=1;
  end 
%    disp(['Status buf',num2str(next),' StatusDll ',num2str(buflist.(var_statusdll{next}),'%08X') ...
%         ,' StatusDrv bs',num2str(bufset(next)),' ',num2str(status_drv_ptr(bufset(next)).Value,'%08X') ... 
%         ,' bufval ',num2str(im_ptr(bufset(next)).Value(1,1)) ... 
%         ,' StatusDrv ima',num2str(ima_nr),' ',num2str(status_drv_ptr(ima_nr).Value,'%08X')]);
  if(bitand(buflist.(var_statusdll{next}),PCO_BUFFER_EVENTSET))
   if(status_drv_ptr(ima_nr).Value==0)
    last_ok=next;
    multi=multi+1;
    ima_nr=ima_nr+1;
    if(ima_nr>imacount)
     disp('break loop ima_nr >imacount');   
     break;
    end
    if(((bitand(buflist.(var_statusdll{next}),PCO_BUFFER_RESETEV_DONE))==0)||(set<=imacount))
%    disp(['call PCO_AddBufferExtern start ',num2str(start),' set ',num2str(set),' buf',num2str(next),' value ',num2str(im_ptr(set).Value(1,1))]);
     errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferExtern',out_ptr,ev_ptr(next),1,start,start,0,im_ptr(set),imasize,status_drv_ptr(set));
     pco_errdisp('PCO_AddBufferExtern',errorCode);   
     bufset(next)=set;
     set=set+1;
     if(start<last)
      start=start+1;
%    else
%     disp('wait for last image');   
     end 
    end 
   else 
    image_error=status_drv_ptr(ima_nr).Value;
   end
  end 
  next=next+1;
 end
  
 if(multi>1)
  disp(['Multi Buffers found after wait:',num2str(multi)]);
 end 
  
 if(image_error~=0)
  break;   
 end 
end


%adjust ima_nr
ima_nr=ima_nr-1;

t=toc;
disp([num2str(ima_nr),' images done in ',num2str(t),' seconds. time per image is ',num2str(t/double(ima_nr),'%.3f'),'s ',num2str((double(imasize)*ima_nr)/(t*1024*1024),'%.3f'),'MByte/sec']);  

%this will remove all pending buffers in the queue
%disp('Call PCO_CancelImages to remove pending buffers');
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
pco_errdisp('PCO_CancelImages',errorCode);   


% [errorCode,~,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,0);
% pco_errdisp('PCO_WaitforBuffer',errorCode);
% for next=1:bufcount
%  disp(['Status buf',num2str(next),' StatusDll ',num2str(buflist.(var_statusdll{next}),'%08X') ...
%       ,' StatusDrv bs',num2str(bufset(next)),' ',num2str(status_drv_ptr(bufset(next)).Value,'%08X') ... 
%       ,' bufval ',num2str(im_ptr(bufset(next)).Value(1,1)) ... 
%       ]);
% end


%this will load all dat into workspace
for n=1:ima_nr
 image_stack(:,:,n)=get(im_ptr(n),'Value');
end 

if(ima_nr~=imacount)
 image_stack=image_stack(:,:,1:ima_nr);
end

catch MEB
 calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
 for n=1:bufcount   
  calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr(n));
 end   
 rethrow(MEB)
end

%free buffers
for n=1:bufcount   
 errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr(n));
 pco_errdisp('PCO_FreeBuffer',errorCode);   
end   

if(image_error~=0)
 errorCode=image_error;
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


