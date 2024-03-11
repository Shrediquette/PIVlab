function pco_camera_create_deffile()
 wfid = fopen('pco_camera_def.txt','wt');
 if(wfid == -1 )
  error('Unable to create file: pco_camera_def.txt');
 end

 get_defines('PCO_err.h',wfid); 
 get_defines('sc2_defs.h',wfid); 
 get_defines('sc2_common.h',wfid); 
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
        r = strfind(str,'/');
        if(~isempty(r))
         str = str(1:r(1)-1);
%         disp(['no comment str is     ',str]);
        end
%        disp(['trimmed string str is ',str]);
        s = strfind(str,' ');
        if( ~isempty(s) )
            valid=true;
            pattern=["(",")","|","&","+","-"];
%            disp(['search for ',pattern,' in',str(s(1):end)]);
            p = contains(str(s(1):end),pattern);
            if(p)
             valid=false;
            end 
            
            if(valid==true)
             q = strfind(str,'0x');
             if( isempty(q) )
              str(s(1)) = '=';
              s=strfind(str,'.');              
              if( ~isempty(s) )
               disp('string has . ');
               str=str(1:s(1)-1);
              end
              fprintf(wfid,'%s\n',str);
%              disp(['string is ',str]);
%              eval(str);
              n = n + 1;
             else   
              hstr=str(1:q-1);
              hstr=strtrim(hstr);
              hstr=strcat(hstr,'=');
              numstr=str(q+2:end);
              numstr=strtrim(numstr);
              num=hex2dec(numstr);
              str=strcat(hstr,num2str(num));
              fprintf(wfid,'%s\n',str);
%              disp(['string is ',hstr,' numstr is ',numstr,' num is ',num2str(num)]);
%              eval(str);
              n = n + 1;
             end   
%            else
%             disp('do not use string ');
            end
        end
    end
end
disp(['Number of variables defined in ',hfile,' = ' num2str(n)]);
fclose(fid);

end 