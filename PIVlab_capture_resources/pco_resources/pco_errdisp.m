function pco_errdisp(txt,errorcode)
%if errorcode display error text with errornumber in HEX
%  
err=pco_uint32err(errorcode);
if(err)
 disp([txt,' failed with error 0x',num2str(err,'%08X')]);   
end    
end


%if(errorcode<0)
%disp([txt,' failed with error 0x',num2str(4294967296+errorcode,'%08X')]);   
%elseif(errorcode~=0)
% disp([txt,' failed with error 0x',num2str(errorcode,'%08X')]);   
%end
