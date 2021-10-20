function pco_camera_create_deffile()
 wfid = fopen('pco_camera_def.txt','wt');
 if(wfid == -1 )
  error('Unable to create file: pco_camera_def.txt');
 end

 get_defines('PCO_err.h',wfid); 
 get_defines('sc2_defs.h',wfid); 
 get_defines('sc2_ml_sdkstructures.h',wfid); 
 get_defines('PCO_Recorder_Defines.h',wfid);
 
 
 fclose(wfid);
end



function get_defines(hfile,wfid)
n = 0;
fid = fopen(hfile);
if( fid == -1 )
    error(['Unable to open file: ' hfile]);
end
while( true )
    tline = fgetl(fid);
    if( tline == -1 )
     break;
    end
    if(numel(tline)<2)
%     disp(['blank line ',tline]);
     continue;
    end        
    if((tline(1)=='/')&&(tline(2)=='/'))
%     disp(['found comment ',tline]);
     continue;
    end 
    d = strfind(tline,'#define ');
    if( ~isempty(d) )
        str = strtrim(tline(d(1)+8:end));
%        disp(['string is ',str]);
        s = strfind(str,' ');
        if( ~isempty(s) )
            p = strfind(str(1:s(1)-1),'(');
            if( isempty(p) )
             q = strfind(str,'0x');
             r = strfind(str,'/');
             if( isempty(q) )
              str(s(1)) = '=';
              if( ~isempty(r) )
               str=str(1:r-1);
              end 
              s=strfind(str,'.');              
              if( ~isempty(s) )
               str=str(1:end-1);
              end
               fprintf(wfid,'%s\n',str);
%              disp(['string is ',str]);
%              eval(str);
               n = n + 1;
             else   
              hstr=str(1:q-1);
              hstr=strtrim(hstr);
              hstr=strcat(hstr,'=');
              if( ~isempty(r) )
               numstr=str(q+2:r-1);
              else
               numstr=str(q+2:end);
              end 
              numstr=strtrim(numstr);
              num=hex2dec(numstr);
              str=strcat(hstr,num2str(num));
              fprintf(wfid,'%s\n',str);
              
%              disp(['string is ',hstr,' numstr is ',numstr,' num is ',num2str(num)]);
              n = n + 1;
             end   
            end
        end
    end
end
disp(['Number of variables defined in ',hfile,' = ' num2str(n)]);
fclose(fid);

end 