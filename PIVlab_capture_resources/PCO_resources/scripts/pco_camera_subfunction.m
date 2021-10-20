function [subfunc]=pco_camera_subfunction()
%creating function handles to functions and return handles in structure
%subfunc

 fh_start_camera=@start_camera;
 fh_stop_camera =@stop_camera;
 fh_reset_settings_to_default=@reset_settings_to_default;
 fh_set_exposure_times=@set_exposure_times;
 fh_set_pixelrate=@set_pixelrate;
 fh_set_triggermode=@set_triggermode;
 fh_get_triggermode=@get_triggermode;
 fh_set_transferparameter=@set_transferparameter;
 fh_set_bitalignment=@set_bitalignment;
 fh_get_bitalignment=@get_bitalignment;
 fh_show_frametime=@show_frametime; 
 fh_get_frametime=@get_frametime; 
 fh_enable_timestamp=@enable_timestamp;
 fh_is_binary_timestamp_enabled=@is_binary_timestamp_enabled;
 fh_set_metadata_mode=@set_metadata_mode;
 fh_print_timestamp=@print_timestamp;
 fh_print_timestamp_t=@print_timestamp_t;
 fh_get_timestamp_t=@get_timestamp_t;
 fh_get_timestamp=@get_timestamp;
 fh_get_struct_timestamp=@get_struct_timestamp;
 fh_print_struct_timestamp=@print_struct_timestamp;
 fh_get_struct_metadata=@get_struct_metadata;
 fh_print_meta_timestamp=@print_meta_timestamp;
 fh_print_meta_struct=@print_meta_struct;
 fh_lasterr=@lasterr;
 

 subfunc=struct('fh_start_camera',fh_start_camera,...
                'fh_stop_camera',fh_stop_camera,...
                'fh_reset_settings_to_default',fh_reset_settings_to_default,...
                'fh_set_exposure_times',fh_set_exposure_times,...
                'fh_set_pixelrate',fh_set_pixelrate,...
                'fh_set_triggermode',fh_set_triggermode,...
                'fh_get_triggermode',fh_get_triggermode,...
                'fh_set_transferparameter',fh_set_transferparameter,...
                'fh_set_bitalignment',fh_set_bitalignment,...
                'fh_get_bitalignment',fh_get_bitalignment,...
                'fh_show_frametime',fh_show_frametime,...
                'fh_get_frametime',fh_get_frametime,...
                'fh_enable_timestamp',fh_enable_timestamp,...
                'fh_is_binary_timestamp_enabled',fh_is_binary_timestamp_enabled,...
                'fh_set_metadata_mode',fh_set_metadata_mode,...
                'fh_print_timestamp',fh_print_timestamp,...
                'fh_print_timestamp_t',fh_print_timestamp_t,...
                'fh_get_timestamp_t',fh_get_timestamp_t,...
                'fh_get_timestamp',fh_get_timestamp,...
                'fh_get_struct_timestamp',fh_get_struct_timestamp,...
                'fh_print_struct_timestamp',fh_print_struct_timestamp,...
                'fh_get_struct_metadata',fh_get_struct_metadata,...
                'fh_print_meta_struct',fh_print_meta_struct, ...
                'fh_print_meta_timestamp',fh_print_meta_timestamp, ...
                'fh_lasterr',fh_lasterr);

end

function errorCode = lasterr(err_in)
persistent e;
 if isempty(e)
  e=0;
 end
 
 if(nargin>0)
  e=err_in;   
 end
 errorCode=e;
end

function errorCode = start_camera(out_ptr)

act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=1)
 errorCode = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end


function errorCode = stop_camera(out_ptr)

act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 errorCode = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end


function errorCode = reset_settings_to_default(out_ptr)

errorCode = calllib('PCO_CAM_SDK', 'PCO_ResetSettingsToDefault',out_ptr);
pco_errdisp('PCO_ResetSettingsToDefault',errorCode);   

end

function errorCode = set_exposure_times(out_ptr,exptime,expbase,deltime,delbase)

del_time=uint32(0);
exp_time=uint32(0);
del_base=uint16(0);
exp_base=uint16(0);

[errorCode,~,del_time,exp_time,del_base,exp_base] = calllib('PCO_CAM_SDK', 'PCO_GetDelayExposureTime', out_ptr,del_time,exp_time,del_base,exp_base);
pco_errdisp('PCO_GetDelayExposureTime',errorCode);   

if(exist('exptime','var'))
 exp_time=uint32(exptime);
end

if(exist('expbase','var'))
 exp_base=uint32(expbase);
end

if(exist('deltime','var'))
 del_time=uint32(deltime);
end

if(exist('delbase','var'))
 del_base=uint32(delbase);
end

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', out_ptr,del_time,exp_time,del_base,exp_base);
pco_errdisp('PCO_SetDelayExposureTime',errorCode);   
end

function errorCode = set_pixelrate(out_ptr,Rate)

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);

[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if((Rate~=1)&&(Rate~=2))
 disp('Rate must be 1 or 2 (adapt to 1)');
 Rate=1;
end 
 
%set PixelRate for Sensor
if(cam_desc.dwPixelRateDESC(Rate))
 errorCode = calllib('PCO_CAM_SDK', 'PCO_SetPixelRate', out_ptr,cam_desc.dwPixelRateDESC(Rate));
 pco_errdisp('PCO_SetPixelRate',errorCode);   
end

clear cam_desc;    
end

function errorCode = set_triggermode(out_ptr,triggermode)

errorCode = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,triggermode);
pco_errdisp('PCO_SetTriggerMode',errorCode);   

end


function triggermode = get_triggermode(out_ptr)

triggermode=uint16(0);
[errorCode,~,triggermode] = calllib('PCO_CAM_SDK', 'PCO_GetTriggerMode', out_ptr,triggermode);
pco_errdisp('PCO_SetTriggerMode',errorCode);   
%disp(['actual triggermode is ',int2str(triggermode)]);

end


function errorCode = set_transferparameter(out_ptr)

pco_camera_load_defines();

cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);
[errorCode,~,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
pco_errdisp('PCO_GetCameraType',errorCode);   

if(uint16(cam_type.wInterfaceType)==INTERFACE_CAMERALINK)
 clpar=uint32(zeros(1,5));
%get size of variable clpar
%s=whos('clpar');
%len=s.bytes;
%clear s;
 len=5*4;

 [errorCode,~,clpar] = calllib('PCO_CAM_SDK', 'PCO_GetTransferParameter', out_ptr,clpar,len);
 pco_errdisp('PCO_GetTransferParameter',errorCode);   
% disp('Actual transfer parameter')
% disp(['baudrate:      ',num2str(clpar(1))]);
% disp(['ClockFrequency ',num2str(clpar(2))]);
% disp(['CCline         ',num2str(clpar(3))]);
% disp(['Dataformat     ',num2str(clpar(4),'%08X')]);
% disp(['Transmit       ',num2str(clpar(5),'%08X')]); 

 clpar(1)=115200;
 
 if(uint16(cam_type.wCamType)==CAMERATYPE_PCO_EDGE)
  pixelrate=uint32(0);
  [errorCode,~,pixelrate]  = calllib('PCO_CAM_SDK', 'PCO_GetPixelRate',out_ptr,pixelrate);
  pco_errdisp('PCO_GetPixelRate',errorCode);   

  act_xsize=uint16(0);
  act_ysize=uint16(0);
  max_xsize=uint16(0);
  max_ysize=uint16(0);
  [errorCode,out_ptr,act_xsize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
  pco_errdisp('PCO_GetSizes',errorCode);   

  lut=uint16(0);
  par=uint16(0);
  if((pixelrate<100000000)||(act_xsize<=1920))
%normal use PCO_CL_DATAFORMAT_5x16    
   a=bitand(clpar(4),hex2dec('FF00'));   
   clpar(4)=a+5;   
  else
%fast and high resolution use PCO_CL_DATAFORMAT_5x12L 
   a=bitand(clpar(4),hex2dec('FF00'));   
   clpar(4)=a+9;   
   lut=hex2dec('1612');
  end 
  [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetActiveLookupTable', out_ptr,lut,par);
  pco_errdisp('SetActiveLookupTable',errorCode);

 else
  cam_desc=libstruct('PCO_Description');
  set(cam_desc,'wSize',cam_desc.structsize);
 
  [errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
  pco_errdisp('PCO_GetCameraDescription',errorCode);   

  if((cam_desc.wDynResDESC<=12)&&(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_DATAFORMAT2X12)))
   clpar(4)=CL_FORMAT_2x12;
  end
 end    

 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetTransferParameter', out_ptr,clpar,len);
 pco_errdisp('PCO_SetTransferParameter',errorCode);   

 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
 pco_errdisp('PCO_ArmCamera',errorCode);   
 if(errorCode~=PCO_NOERROR)
  ME = MException('PCO_ERROR:ArmCamera','Cannot continue script with not armed camera');
  lasterr(errorCode);
  throw(ME);   
 end 
% [errorCode,~,clpar] = calllib('PCO_CAM_SDK', 'PCO_GetTransferParameter', out_ptr,clpar,len);
% pco_errdisp('PCO_GetTransferParameter',errorCode);   
%  disp('Actual transfer parameter now')
%  disp(['baudrate:      ',num2str(clpar(1))]);
%  disp(['ClockFrequency ',num2str(clpar(2))]);
%  disp(['CCline         ',num2str(clpar(3))]);
%  disp(['Dataformat     ',num2str(clpar(4),'%08X')]);
%  disp(['Transmit       ',num2str(clpar(5),'%08X')]); 
%  disp(['pixelrate      ',num2str(pixelrate)]);
 end 
end

function errorCode = set_bitalignment(out_ptr,bitalign)

errorCode = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
pco_errdisp('PCO_SetBitAlignment',errorCode);   

end

function bitalign = get_bitalignment(out_ptr)

bitalign=uint16(0);
[errorCode,~,bitalign]= calllib('PCO_CAM_SDK', 'PCO_GetBitAlignment', out_ptr,bitalign);
pco_errdisp('PCO_GetBitAlignment',errorCode);   

end



function waittime_s = show_frametime(out_ptr)

%get time in ms, which is used for one image
dwSec=uint32(0);
dwNanoSec=uint32(0);
[errorCode,~,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
pco_errdisp('PCO_GetCOCRuntime',errorCode);   

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

%fprintf(1,'one frame needs %6.6fs, maximal frequency %6.3fHz',waittime_s,1/waittime_s);
%disp(' ');

end

function waittime_s = get_frametime(out_ptr)

%get time in ms, which is used for one image
dwSec=uint32(0);
dwNanoSec=uint32(0);
[errorCode,~,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
pco_errdisp('PCO_GetCOCRuntime',errorCode);   

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

end



function errorCode = enable_timestamp(out_ptr,Stamp)

if((Stamp~=0)&&(Stamp~=1)&&(Stamp~=2)&&(Stamp~=3))
 disp('Stamp must be 0 or 1 or 2 or 3 (adapt to 0)');
 Stamp=0;
end

errorCode = calllib('PCO_CAM_SDK', 'PCO_SetTimestampMode', out_ptr,Stamp);
pco_errdisp('PCO_SetTimestampMode',errorCode);   

end

function timestamp_bin = is_binary_timestamp_enabled(out_ptr)

pco_camera_load_defines();
timestamp_mode=uint16(0);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 [errorCode,~,timestamp_mode] = calllib('PCO_CAM_SDK', 'PCO_GetTimestampMode', out_ptr,timestamp_mode);
 pco_errdisp('PCO_GetTimestampMode',errorCode);   
end

if((timestamp_mode==1)||(timestamp_mode==2))
 timestamp_bin=true;
else 
 timestamp_bin=false;
end
end

function errorCode = set_metadata_mode(out_ptr,on)

wMetaDataMode=uint16(0);
wMetaDataSize=uint16(0);
wMetaDataVersion=uint16(0);

errorCode = calllib('PCO_CAM_SDK', 'PCO_GetMetaDataMode',out_ptr,wMetaDataMode,wMetaDataSize,wMetaDataVersion);
pco_errdisp('PCO_GetMetaDataMode',errorCode);   

wMetaDataMode=on;
errorCode = calllib('PCO_CAM_SDK', 'PCO_SetMetaDataMode',out_ptr,wMetaDataMode,wMetaDataSize,wMetaDataVersion);
pco_errdisp('PCO_SetMetaDataMode',errorCode);   

end

function [time,b] = print_timestamp_s(ts)

b='';
b=[b,int2str(fix(ts(1)/16)),int2str(bitand(ts(1),15))];
b=[b,int2str(fix(ts(2)/16)),int2str(bitand(ts(2),15))];
b=[b,int2str(fix(ts(3)/16)),int2str(bitand(ts(3),15))];
b=[b,int2str(fix(ts(4)/16)),int2str(bitand(ts(4),15))];

b=[b,' '];
%year
b=[b,int2str(fix(ts(5)/16)),int2str(bitand(ts(5),15))];   
b=[b,int2str(fix(ts(6)/16)),int2str(bitand(ts(6),15))];   
b=[b,'-'];
%month
b=[b,int2str(fix(ts(7)/16)),int2str(bitand(ts(7),15))];   
b=[b,'-'];
%day
b=[b,int2str(fix(ts(8)/16)),int2str(bitand(ts(8),15))];   
b=[b,' '];

%hour   
c=[int2str(fix(ts(9)/16)),int2str(bitand(ts(9),15))];   
b=[b,c,':'];
time=str2double(c)*60*60;
%min   
c=[int2str(fix(ts(10)/16)),int2str(bitand(ts(10),15))];   
b=[b,c,':'];
time=time+(str2double(c)*60);
%sec   
c=[int2str(fix(ts(11)/16)),int2str(bitand(ts(11),15))];   
b=[b,c,'.'];
time=time+str2double(c);
%us   
c=[int2str(fix(ts(12)/16)),int2str(bitand(ts(12),15))];   
b=[b,c];
time=time+(str2double(c)/100);
c=[int2str(fix(ts(13)/16)),int2str(bitand(ts(13),15))];   
b=[b,c];
time=time+(str2double(c)/10000);
c=[int2str(fix(ts(14)/16)),int2str(bitand(ts(14),15))];   
b=[b,c];
time=time+(str2double(c)/1000000);
end


function [txt,time] = print_timestamp(ima,act_align,bitpix)

 ts=double(ima(1:14));
 if(act_align==0)
  ts=fix(ts/(2^double(16-bitpix)));   
 end
 [time,b]=print_timestamp_s(ts);
 if(nargout<1)
  disp(b)
 else
  txt=b;   
 end 
end

function [txt,time] = print_timestamp_t(ima,act_align,bitpix)

 ts=double(ima(1,1:14));
 if(act_align==0)
  ts=fix(ts/(2^double(16-bitpix)));   
 end
 [time,b]=print_timestamp_s(ts);
 if(nargout<1)
  disp(b)
 else
  txt=b;   
 end 
end


function [imanum,timeval] = get_timestamp_t(ima,act_align,bitpix)
 data=ima(1,1:14);
 [imanum,timeval]=get_timestamp(data,act_align,bitpix);
end
 
function [imanum,timeval] = get_timestamp(ima,act_align,bitpix)
 ts=ima(1:14);
 if(act_align==0)
  s=int16(16-bitpix);
  s=s*-1;
  ts=bitshift(ts,s);
 end
 
 imanum=0;
 mul=1;
 for j=4:-1:1
  val= bitshift(ts(j),-4)*10 + bitand(ts(j),15);
  imanum=imanum+val*mul;
  mul=mul*100;
 end 
 
%hour   
 c=double(bitshift(ts(9),-4)*10 + bitand(ts(9),15));   
 timeval=c*60*60;
%min   
 c=double(bitshift(ts(10),-4)*10 + bitand(ts(10),15));   
 timeval=timeval+c*60;
%sec   
 c=double(bitshift(ts(11),-4)*10 + bitand(ts(11),15));   
 timeval=timeval+c;
%us   
 c=double(bitshift(ts(12),-4)*10 + bitand(ts(12),15));   
 timeval=timeval+c/100;
 c=double(bitshift(ts(13),-4)*10 + bitand(ts(13),15));   
 timeval=timeval+c/10000;
 c=double(bitshift(ts(14),-4)*10 + bitand(ts(14),15));   
 timeval=timeval+c/1000000;
end

function str_time = get_struct_timestamp(ima,act_align,bitpix)
 ts=ima(1:14);
 if(act_align==0)
  s=int16(16-bitpix);
  s=s*-1;   
  ts=bitshift(ts,s);
 end

 libtime=libstruct('PCO_TIMESTAMP_STRUCT');
 set(libtime,'wSize',libtime.structsize);
 set(libtime,'dwImgCounter',uint32(2000));
 
 imanum=0;
 mul=1;
 for j=4:-1:1
  val= double(bitshift(ts(j),-4)*10 + bitand(ts(j),15));
  imanum=imanum+val*mul;
  mul=mul*100;
 end 
 set(libtime,'dwImgCounter',uint32(imanum));

 val= double(bitshift(ts(5),-4)*10 + bitand(ts(5),15));
 num=val;
 val= double(bitshift(ts(6),-4)*10 + bitand(ts(6),15));
 num=num+val*100;
 
 set(libtime,'wYear' ,uint16(num));
 set(libtime,'wMonth',uint16(bitshift(ts(7),-4)*10 + bitand(ts(7),15)));
 set(libtime,'wDay'  ,uint16(bitshift(ts(8),-4)*10 + bitand(ts(8),15)));
 
  
 set(libtime,'wHour'  ,uint16(bitshift(ts(9),-4)*10 + bitand(ts(9),15)));
 set(libtime,'wMinute',uint16(bitshift(ts(10),-4)*10 + bitand(ts(10),15)));
 set(libtime,'wSecond',uint16(bitshift(ts(11),-4)*10 + bitand(ts(11),15)));
 
 num=0; 
 mul=1;
 for j=14:-1:12
  val= double(bitshift(ts(j),-4)*10 + bitand(ts(j),15));
  num=num+val*mul;
  mul=mul*100;
 end 
 set(libtime,'dwMicroSeconds',uint32(num));
 
 str_time=get(libtime);
 
 clear libtime;
end

function txt = print_struct_timestamp(str_time)
 b='';
 b=([b,num2str(str_time.dwImgCounter,'%08d')]);
 b=([b,' ',num2str(str_time.wYear,'%04d')]);
 b=([b,'-',num2str(str_time.wMonth,'%02d')]);
 b=([b,'-',num2str(str_time.wDay,'%02d')]);
 b=([b,' ',num2str(str_time.wHour,'%02d')]);
 b=([b,':',num2str(str_time.wMinute,'%02d')]);
 b=([b,':',num2str(str_time.wSecond,'%02d')]);
 b=([b,'.',num2str(str_time.dwMicroSeconds,'%06d')]);
 if(nargout<1)
  disp(b)
 else
  txt=b;   
 end 
end

function [errorCode,metastruct] = get_struct_metadata(ima,metasize)
 errorCode=0;
 meta_txt='';
 pco_camera_load_defines();
 m=typecast(ima(1:metasize),'uint8');
 if((m(1)==0)&&(m(3)==0)&&(m(5)==0)&&(m(7)==0))
  align=BIT_ALIGNMENT_LSB;
 elseif((m(2)==0)&&(m(4)==0)&&(m(6)==0)&&(m(8)==0))
  align=BIT_ALIGNMENT_MSB;
 else
  errorCode=PCO_ERROR_SDKDLL_NOTAVAILABLE | PCO_ERROR_PCO_SDKDLL;
  return;
 end

 if(align==BIT_ALIGNMENT_LSB)
   meta_txt=([meta_txt,'Alignment is LSB',newline]);
  mnz=m;
  mnz(1:2:end) = [];
 else 
  meta_txt=([meta_txt,'Alignment is MSB',newline]);
  mnz=m;
  mnz(2:2:end) = [];
 end
 
 mnz16=typecast(mnz,'uint16');

 msize=mnz16(1);
 version=mnz16(2);
 
 off=1;
 if(((version==1)&&(msize==metasize))||((version==2)&&(msize==metasize)))
  libmeta=libstruct('PCO_METADATA_STRUCT');
  set(libmeta,'wSize',2);
 %set(libmeta,'wSize',libmeta.structsize);
  metastruct=get(libmeta);
  names=fieldnames(metastruct);
  for i = 1:length(names)
%   fprintf('Field %s = %g ', names{i}, ms.(names{i}))
   k=strfind(names{i},'w');
   if(k==1)
    a=mnz(off:off+1);   
    metastruct.(names{i})=typecast(a,'uint16');
    nl=strlength(names{i});
    bl=blanks(32-nl);
    meta_txt=([meta_txt,'meta.',names{i},': ',bl,num2str(metastruct.(names{i})),' ',num2str(metastruct.(names{i}),'%04X'),newline]);
    off=off+2;
   end 
   k=strfind(names{i},'s');
   if(k==1)
    a=mnz(off:off+1);   
    metastruct.(names{i})=typecast(a,'int16');
    nl=strlength(names{i});
    bl=blanks(32-nl);
    meta_txt=([meta_txt,'meta.',names{i},': ',bl,num2str(metastruct.(names{i})),' ',num2str(metastruct.(names{i}),'%04X'),newline]);
    off=off+2;
   end 
   k=strfind(names{i},'dw');
   if(k==1)
    a=mnz(off:off+3);   
    metastruct.(names{i})=typecast(a,'uint32');
    nl=strlength(names{i});
    bl=blanks(32-nl);
    meta_txt=([meta_txt,'meta.',names{i},': ',bl,num2str(metastruct.(names{i})),' ',num2str(metastruct.(names{i}),'%08X'),newline]);
    off=off+4;
   end
   k=strfind(names{i},'b');
   if(k==1)
    k=size(metastruct.(names{i}));
    if(isa(metastruct.(names{i}),'uint8'))
     a=mnz(off:off+k(2)-1);   
     metastruct.(names{i})=a;
     off=off+k(2);
     nl=strlength(names{i});
     bl=blanks(32-nl);
     str=['meta.',names{i},': ',bl];
     for j = 1:k(2)
      str=append(str,[num2str(metastruct.(names{i})(j),'%02X'),' ']);   
     end    
     meta_txt=([meta_txt,str]);   
     res=0;
     mul=1;
     if(strfind(names{i},'BCD'))
      for j = 1:k(2)
       val=double(bitshift(metastruct.(names{i})(j),-4)*10 + bitand(metastruct.(names{i})(j),15));  
       res=res+val*mul;
       mul=mul*100;
      end
      meta_txt=([meta_txt,'BCD calculated: ',num2str(res),newline]);
     end 
    else 
     a=mnz(off);   
     metastruct.(names{i})=a;
     nl=strlength(names{i});
     bl=blanks(32-nl);
     meta_txt=([meta_txt,'meta.',names{i},': ',bl,num2str(metastruct.(names{i})),' ',num2str(metastruct.(names{i}),'%02X'),newline]);
     off=off+1;
     if(strfind(names{i},'BCD'))
      res=bitshift(a,-4)*10 + bitand(a,15);
      meta_txt=([meta_txt,'BCD calculated: ',num2str(res),newline]);
     end     
    end

   end    
  end 
% disp(meta_txt); 
  clear libmeta; 
 else
  errorCode=PCO_ERROR_SDKDLL_NOTAVAILABLE | PCO_ERROR_PCO_SDKDLL;
 end
end

function txt = print_meta_struct(metastruct)
 meta_txt='';
 pco_camera_load_defines();
 names=fieldnames(metastruct);
 for i = 1:length(names)
%   fprintf('Field %s = %g ', names{i}, ms.(names{i}))
  nl=strlength(names{i});
  bl=blanks(32-nl);
  meta_txt=([meta_txt,'meta.',names{i},': ',bl]);
  k=strfind(names{i},'b');
  if(k==1)
   k=size(metastruct.(names{i}));
   res=0;
   mul=1;
   if(strfind(names{i},'BCD'))
    for j = 1:k(1)
     val=double(bitshift(metastruct.(names{i})(j),-4)*10 + bitand(metastruct.(names{i})(j),15));  
     res=res+val*mul;
     mul=mul*100;
    end
    k=strfind(names{i},'IMAGE_COUNTER');
    if(~isempty(k))
     meta_txt=([meta_txt,' ',num2str(res,'%08d'),newline]);
    else 
     nl=strlength(num2str(res));
     bl=blanks(9-nl);
     meta_txt=([meta_txt,bl,num2str(res),newline]);
    end    
   else
    nl=strlength(num2str(metastruct.(names{i})));
    bl=blanks(9-nl);
    meta_txt=([meta_txt,bl,num2str(metastruct.(names{i})),newline]);
   end 
  else
   k=strfind(names{i},'CAMERA_TYPE');
   l=strfind(names{i},'COLOR_PATTERN');
   if((~isempty(k))||(~isempty(l)))
    meta_txt=([meta_txt,'   0x',num2str(metastruct.(names{i}),'%04X'),' (',num2str(metastruct.(names{i})),')',newline]);
   else   
    nl=strlength(num2str(metastruct.(names{i})));
    bl=blanks(9-nl);
    meta_txt=([meta_txt,bl,num2str(metastruct.(names{i})),newline]);
   end
  end 
 end 
 if(nargout<1)
  disp(meta_txt); 
 else
  txt=meta_txt;   
 end 
end

function txt = print_meta_timestamp(metastruct)
 b='';
 res=0;
 mul=1;
 for j = 1:4
  val=double(bitshift(metastruct.bIMAGE_COUNTER_BCD(j),-4)*10 + bitand(metastruct.bIMAGE_COUNTER_BCD(j),15));  
  res=res+val*mul;
  mul=mul*100;
 end 
 b=[b,num2str(res,'%08d')];
 b=[b,' '];
 res=bitshift(metastruct.bIMAGE_TIME_YEAR_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_YEAR_BCD,15);   
 b=[b,'20',num2str(res,'%02d')];
 b=[b,'-'];
 res=bitshift(metastruct.bIMAGE_TIME_MON_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_MON_BCD,15);   
 b=[b,num2str(res,'%02d')];
 b=[b,'-'];
 res=bitshift(metastruct.bIMAGE_TIME_DAY_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_DAY_BCD,15);   
 b=[b,num2str(res,'%02d')];
 b=[b,' '];
 res=bitshift(metastruct.bIMAGE_TIME_HOUR_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_HOUR_BCD,15);   
 b=[b,num2str(res,'%02d')];
 b=[b,':'];
 res=bitshift(metastruct.bIMAGE_TIME_MIN_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_MIN_BCD,15);   
 b=[b,num2str(res,'%02d')];
 b=[b,':'];
 res=bitshift(metastruct.bIMAGE_TIME_SEC_BCD,-4)*10 + bitand(metastruct.bIMAGE_TIME_SEC_BCD,15);   
 b=[b,num2str(res,'%02d')];
 b=[b,'.'];
 res=0;
 mul=1;
 for j = 1:3
  val=double(bitshift(metastruct.bIMAGE_TIME_US_BCD(j),-4)*10 + bitand(metastruct.bIMAGE_TIME_US_BCD(j),15));  
  res=res+val*mul;
  mul=mul*100;
 end 
 b=[b,num2str(res,'%06d')];
 
 if(nargout<1)
  disp(b)
 else
  txt=b;   
 end 
end
