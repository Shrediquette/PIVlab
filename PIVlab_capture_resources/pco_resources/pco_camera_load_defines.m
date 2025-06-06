%script: create and load the (error) defines 

 fid = fopen('pco_camera_def.txt','rt');
 if( fid == -1 )
  pco_camera_create_deffile();   
  fid = fopen('pco_camera_def.txt','rt');
  if( fid == -1 )
   error('Unable to create and open file: pco_camera_def.txt');
  end 
 end
 
 while( true )
  tline = fgetl(fid);
  if(tline == -1)
   break;
  end
  tline=strcat(tline,';');
  eval(tline);
 end
 fclose(fid);

