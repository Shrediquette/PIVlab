function [err] = pco_uint32err(error_code)
 if(error_code<0)
  e=error_code*-1;
  err=uint32(e)-1;
  err=bitcmp(err,'uint32');
 else
  err=uint32(error_code);   
 end
end
