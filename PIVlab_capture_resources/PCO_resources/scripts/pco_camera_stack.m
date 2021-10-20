function [errorCode,image_stack,metadata_stack,glvar] = pco_camera_stack(imacount,glvar)
%grab image(s) to image_stack with actual settings from pco.camera
%
%   [errorCode,glvar,image_stack] = pco_camera_stack(imacount,glvar)
%
% * Input parameters :
%    imacount                number of images to grab
%    glvar                   structure to hold status info
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    image_stack uint16(,,)  grabbed image(s)
%    data_stack              if camera supports metadata and metadata is enabled  
%                             datablock with metadata from each grabbed image
%    glvar                   structure to hold status info
%
%grab 'imacount' images from a recording pco.camera 
%into the matlab array image_stack 
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
%if imacount does not exist, it is set to '10'
%
%function workflow
%parameters are checked
%Alignment for the image data is set to LSB
%the size of the images is readout from the camera
%matlab array is build
%allocate buffer(s) in camera SDK 
%PCO_AddBufferExtern and PCO_WaitforBuffer functions are used in a loop
%free previously allocated buffer(s) in camera SDK 
%errorCode, if available glvar, and the image_stack with uint16 image data is returned
%if metadata are enabled, the block with the metadata is cutoff from each image
%and is returned as separate data_stack

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamMatlab.h' ...
                ,'addheader','SC2_common.h' ...
                ,'addheader','SC2_CamExport.h' ...
                ,'alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

% Declaration of internal variables
if(~exist('imacount','var'))
 imacount = 1;   
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

act_trigmode = uint16(10); 
[errorCode,~,act_trigmode] = calllib('PCO_CAM_SDK', 'PCO_GetTriggerMode', out_ptr,act_trigmode);
pco_errdisp('PCO_GetTriggerMode',errorCode);   

act_align = uint16(0); 
[errorCode,~,act_align] = calllib('PCO_CAM_SDK', 'PCO_GetBitAlignment', out_ptr,act_align);
pco_errdisp('PCO_GetBitAlignment',errorCode);   
    
act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

% if(act_recstate==0)
%  errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
%  if(errorCode~=PCO_NOERROR)
%   pco_errdisp('PCO_ArmCamera',errorCode);   
%   ME = MException('PCO_ERROR:ArmCamera','Cannot continue script with not armed camera');
%   subfunc.fh_lasterr(errorCode);
%   throw(ME);   
%  end 
% end 

bitpix=uint16(cam_desc.wDynResDESC);
bytepix=fix(double(bitpix+7)/8);

cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);
[errorCode,~,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
pco_errdisp('PCO_GetCameraType',errorCode);   

interface=uint16(cam_type.wInterfaceType);

pre_add=uint16(0);
if(interface==INTERFACE_CAMERALINK) 
 clpar=uint32(zeros(1,5));
 len=5*4;
 [errorCode,~,clpar] = calllib('PCO_CAM_SDK', 'PCO_GetTransferParameter', out_ptr,clpar,len);
 pco_errdisp('PCO_GetTransferParameter',errorCode);   
 if(bitand(clpar(5),CL_TRANSMIT_ENABLE))
  pre_add=1;   
 end
elseif(interface==INTERFACE_CAMERALINKHS)
 pre_add=1;   
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

act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
pco_errdisp('PCO_GetSizes',errorCode);   

flags=2; %IMAGEPARAMETERS_READ_WHILE_RECORDING;
errorCode = calllib('PCO_CAM_SDK', 'PCO_SetImageParameters', out_ptr,act_xsize,act_ysize,flags,[],0);
if(errorCode)
 pco_errdisp('PCO_CamLinkSetImageParameters',errorCode);   
 return;
end


%limit allocation of memory to 2GByte
if(double(imacount)*double(act_xsize)*double(act_ysize)*bytepix>2000*1024*1024)     
 imacount=uint16(double(2000*1024*1024)/(double(act_xsize)*double(act_ysize)*bytepix));
end

lineadd=0;   
if(metadatasize>0)
 xs=bytepix*double(act_xsize);
 i=floor(metadatasize/xs);
 lineadd=i+1;
end

imasize= bytepix * double(act_ysize+lineadd)*double(act_xsize);   

%only for firewire add always some lines
%to ensure enough memory is allocated for the transfer
if(interface==INTERFACE_FIREWIRE)
  imas= imasize;   
  i=floor(imas/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-imas;
  xs=bytepix*double(act_xsize);
  i=floor(i/xs);
  i=i+1;
  lineadd=lineadd+i;
% disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
end
%disp([int2str(lineadd),' additional line(s) must be allocated ']);

%disp(['number of images to grab: ',int2str(imacount)]);
%disp(['actual recording state:   ',int2str(act_recstate)]);   
if showall==1
 disp(['actual triggermode:       ',int2str(act_trigmode)]);   
 disp(['interface type:           ',int2str(interface)]);
 disp(['actual alignment:         ',int2str(act_align)]);
 disp(['preset capability:        ',int2str(pre_add)]); 
 disp(['imasize is:               ',int2str(imasize)]); 
end

image_stack=zeros(act_xsize,(act_ysize+lineadd),imacount,'uint16');

% if((imasize*imacount)<(1024*1024*512))
%  disp(['allocated memory is ',num2str((imasize*imacount)/(1024*1024),'%.2f'),'MByte'])
% else    
%  disp(['allocated memory is ',num2str((imasize*imacount)/(1024*1024*1024),'%.2f'),'GByte'])
% end

[errorCode,image_stack] = pco_get_image_multi(out_ptr,image_stack,pre_add);

if(errorCode==0)
 if(metadatasize>0)    
  metaline=zeros(metadatasize,imacount,'uint16');
 end
 
 disp('extract info');
 [~,~,count]=size(image_stack);
 if(count~=imacount)
  disp(['Only ',int2str(count),' images grabbed']);
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
 
 disp('remove added lines');
 image_stack=image_stack(:,1:act_ysize,:);
 
 if((act_align==BIT_ALIGNMENT_MSB)&&(bitpix<16))
  s=int16(16-bitpix);
  disp(['bitshift image (>>',num2str(s),') to LSB alignment']);
  s=s*-1;   
  image_stack=bitshift(image_stack,s);
 end 
 
 disp('transpose images');
 image_stack=permute(image_stack,[2 1 3]);

 if(metadatasize>0)
  metadata_stack=metaline;   
 else
  metadata_stack=[];   
 end

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
% close_camera(out_ptr,unload,do_close,cam_open);   
 close_camera(out_ptr,unload,do_close,cam_open);   
end

end


function [errorCode,image_stack] = pco_get_image_multi(out_ptr,image_stack,pre)
%act_xsize,act_ysize,bitpix,interface)

pco_camera_load_defines();
subfunc=pco_camera_subfunction();

try
    
[width,height,imacount]=size(image_stack);
imasize=2*height*width;
%disp(['imacount is: ',num2str(imacount)]); 

act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

act_trigmode = uint16(10); 
[errorCode,~,act_trigmode] = calllib('PCO_CAM_SDK', 'PCO_GetTriggerMode', out_ptr,act_trigmode);
pco_errdisp('PCO_GetTriggerMode',errorCode);   

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

% for n=1:imacount
%   a=im_ptr(n).Value(1,1);
%   disp(['after alloc image ',num2str(n),' Value ',num2str(a)]);
% end 

set=1;
if(pre==1)
 for n=1:bufcount
  errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferExtern',out_ptr,ev_ptr(n),1,0,0,0,im_ptr(set),imasize,status_drv_ptr(set)); %buflist.(var_statusdrv{n})
  if(errorCode~=PCO_NOERROR)
   pco_errdisp('PCO_AddBufferExtern',errorCode);   
   ME = MException('PCO_ERROR:AddBufferExtern','Cannot continue script without added Buffers');
   subfunc.fh_lasterr(errorCode);
   throw(ME);   
  end 
  bufset(n)=set;
%  disp(['set',num2str(set),' statusdrv : ',num2str(status_drv_ptr(set).Value,'%08x')]); 
  set=set+1;
 end
end    


if(act_recstate==0)
 disp('Start Camera and grab images')   
 errorCode = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,1);
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_SetRecordingState',errorCode);   
  ME = MException('PCO_ERROR:SetRecordingState','Cannot continue script with stopped camera');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end
end 

% for n=1:bufcount
%  disp(['Status buf',num2str(n),' StatusDll ',num2str(buflist.(var_statusdll{n}),'%08X')]);
% end

tic;

if(pre==0)
 for n=1:bufcount
  errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferExtern',out_ptr,ev_ptr(n),1,0,0,0,im_ptr(set),imasize,status_drv_ptr(set)); %buflist.(var_statusdrv{n})
  if(errorCode~=PCO_NOERROR)
   pco_errdisp('PCO_AddBufferExtern',errorCode);   
   ME = MException('PCO_ERROR:AddBufferExtern','Cannot continue script without added Buffers');
   subfunc.fh_lasterr(errorCode);
   throw(ME);   
  end 
  bufset(n)=set;
%  disp(['set',num2str(set),' statusdrv : ',num2str(status_drv_ptr(set).Value,'%08x')]); 
  set=set+1;
 end
end    

trigdone=int16(1);    
if(act_trigmode>=2)
 disp('send external trigger pulses within 5 seconds');   
 pause(0.00001);
elseif(act_trigmode==1)
 disp('send first SW trigger');   
 errorCode = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
 pco_errdisp('PCO_ForceTrigger',errorCode);   
end        

image_error=0;
last_ok=0;

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
%first image done trigger next
 if(act_trigmode==1)
  errorCode = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
  pco_errdisp('PCO_ForceTrigger',errorCode);   
 end 

%PCO_WaitforBuffer does return if one or more buffer events are set
%Therefore status of all buffers, which had been setup, must be checked 
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
%     disp(['set ',num2str(set),' buf',num2str(next),' value ',num2str(im_ptr(set).Value(1,1)),' last_ok ',num2str(last_ok)]);
     errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferExtern',out_ptr,ev_ptr(next),1,0,0,0,im_ptr(set),imasize,status_drv_ptr(set));
     pco_errdisp('PCO_AddBufferExtern',errorCode);   
     bufset(next)=set;
     set=set+1;
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
% nr=ima_nr;   
% for next=1:bufcount
%  disp(['Status buf',num2str(next),' StatusDll ',num2str(buflist.(var_statusdll{next}),'%08X') ...
%       ,' StatusDrv bs',num2str(bufset(next)),' ',num2str(status_drv_ptr(bufset(next)).Value,'%08X') ... 
%       ,' bufval ',num2str(im_ptr(bufset(next)).Value(1,1)) ... 
%       ,' StatusDrv ima',num2str(nr),' ',num2str(status_drv_ptr(nr).Value,'%08X')]);
%  nr=nr+1; 
% end


if(act_recstate==0)
 disp('Stop Camera')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 

disp('Get images');   
for n=1:ima_nr
 image_stack(:,:,n)=get(im_ptr(n),'Value');
% a=get(im_ptr(n),'Value');
% disp(num2str(a(1:5,1)));
end 
disp('Get images done ');   

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
