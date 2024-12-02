function [val] = pco_uint32(in_val)
 if(in_val<0)
  i=in_val*-1;
%  disp(['negativ 0x',num2str(e,'%08X')]);   
  val=uint32(i)-1;
  val=bitcmp(val,'uint32');
%  disp(['als uint32 0x',num2str(e1,'%08X')]);   
 else
  val=uint32(in_val);   
 end
end
