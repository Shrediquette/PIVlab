function [errorCode,ima_stack,metastructs] = pco_sdk_example_stack_EDITED(imacount,exposure_time,triggermode)
%[errorcode,ima_stack] = pco_sdk_example_stack(10,100,0);

%
% set variables and grab images to a Matlab array
%
%   
%
% * Input parameters :
%    imacount                number of images to grab
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    ima_stack               stack with grabbed images  
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab images from a recording pco.dimax camera 
%using functions PCO_AddBufferEx and PCO_WaitforBuffer
%
%function workflow
%open camera
%set variables 
%start camera
%grab images
%stop camera
%close camera
%

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[],'err',0);

if(~exist('imacount','var'))
 imacount = 10;   
end

if(~exist('exposure_time','var'))
 exposure_time = 5;   
end

if(~exist('triggermode','var'))
 triggermode = 0;   
end

pco_camera_load_defines();
subfunc=pco_camera_subfunction();
subfunc.fh_lasterr(0);

[errorCode,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(errorCode~=PCO_NOERROR)
 commandwindow;
 return;
end 


out_ptr=glvar.out_ptr;

try

subfunc.fh_stop_camera(out_ptr);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

%% double image attempt
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', out_ptr,1);
disp('hat double image fehler gemacht geklappt?')
disp(errorCode)

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(out_ptr,TIMESTAMP_MODE_OFF);
end 

subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2);
subfunc.fh_set_triggermode(out_ptr,triggermode);

%if PCO_ArmCamera does fail no images can be grabbed
errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode~=PCO_NOERROR)
 pco_errdisp('PCO_ArmCamera',errorCode);   
 ME = MException('PCO_ERROR:ArmCamera','Cannot continue script with not armed camera');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

subfunc.fh_set_transferparameter(out_ptr);
subfunc.fh_show_frametime(out_ptr);
ts_bin=subfunc.fh_is_binary_timestamp_enabled(out_ptr);

%get images

[errorCode,ima_stack,metadata_stack,glvar]=pco_camera_stack(imacount,glvar);


subfunc.fh_stop_camera(out_ptr);

if(errorCode==0)
 [~,~,count]=size(ima_stack);   
 if(~isempty(metadata_stack))
  libmeta=libstruct('PCO_METADATA_STRUCT');
  [metadatasize,count_m]=size(metadata_stack);   
  metastructs(count_m)=get(libmeta);
  for n=1:count_m
   [errorCode_m,metastructs(n)]=subfunc.fh_get_struct_metadata(metadata_stack(:,n),metadatasize);
   if(errorCode_m)
    pco_errdisp('get_struct_metadata',errorCode_m);
    metadata_stack=[];
    break;
   end
  end
  clear libmeta;
 end

 if(count==1)
  m=max(max(ima_stack(10:end-10,10:end-10)));
  disp(['image done maxvalue: ',int2str(m)]);   
  if(ts_bin)
   txt=subfunc.fh_print_timestamp_t(ima_stack,1,16);
   disp(['Timestamp data of image: ',txt]);
  end
  if(~isempty(metadata_stack))
   txt=subfunc.fh_print_meta_timestamp(metastructs(1));
   disp(['Timestamp of meta (',num2str(1,'%04d'),'):  ',txt]);
   subfunc.fh_print_meta_struct(metastructs(1));
  end 
 else
  disp([int2str(count),' images done']);  
  if((ts_bin)||(~isempty(metadata_stack)))
   reply = input('Show timestamps? Y/N [Y]: ', 's');
   if((isempty(reply))||(reply(1)== 'Y')||(reply(1)== 'y'))
    for n=1:count
     if(ts_bin)
      txt=subfunc.fh_print_timestamp_t(ima_stack(:,:,n),1,16);
      disp(['Timestamp data of image(',num2str(n,'%04d'),'): ',txt]);
     end 
     if(~isempty(metadata_stack))
      txt=subfunc.fh_print_meta_timestamp(metastructs(n));
      disp(['Timestamp data of meta (',num2str(n,'%04d'),'): ',txt]);
     end
    end
   end 
  end
 end 
end 

catch ME
 errorCode=subfunc.fh_lasterr();
 txt=blanks(101);
 txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);

 clearvars -except ME glvar errorCode txt;
  
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

clearvars -except glvar errorCode ima_stack metastructs;

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   


if(exist('metastructs','var'))
 [~,count]=size(metastructs);
 if(count>3)
  subfunc=pco_camera_subfunction();
  n=3;
  txt=subfunc.fh_print_meta_timestamp(metastructs(n));
  disp(['Timestamp of meta(',num2str(n,'%04d'),'):  ',txt]);
  subfunc.fh_print_meta_struct(metastructs(n));
  clearvars subfunc;
 end
end

clearvars glvar;
commandwindow;
end

