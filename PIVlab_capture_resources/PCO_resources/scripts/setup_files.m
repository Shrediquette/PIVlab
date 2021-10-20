%script: copy correct dll-files

 if(exist('./pco_uint32.m','file'))
  delete('./pco_uint32.m');   
 end 

 if(exist('./pco_uint32err.m','file'))
  delete('./pco_uint32err.m');   
 end 

 if verLessThan('matlab','8.0.0')
  copyfile('./ver_7/pco_uint32.m','./pco_uint32.m');
  copyfile('./ver_7/pco_uint32err.m','./pco_uint32err.m');
 else  
  copyfile('./ver_8/pco_uint32.m','./pco_uint32.m');
  copyfile('./ver_8/pco_uint32err.m','./pco_uint32err.m');
 end 

 
 if(exist('../runtime/include','dir'))
  copyfile('../runtime/include/*.h','./');
 end
 
 pco_camera_create_deffile();

 
 if(strcmp(computer('arch'),'win32'))
     
  if(exist('./sc2_cam.dll','file'))
   delete('./sc2_cam.dll');   
  end 
  if(exist('../runtime/bin/sc2_cam.dll','file'))
   copyfile('../runtime/bin/sc2_cam.dll','./');
  end
  
  if(exist('./sc2_cl_me4.dll','file'))
   delete('./sc2_cl_me4.dll');   
  end 
  if(exist('../runtime/bin/sc2_cl_me4.dll','file'))
   copyfile('../runtime/bin/sc2_cl_me4.dll','./');
  end 

  if(exist('./sc2_cl_nat.dll','file'))
   delete('./sc2_cl_nat.dll');   
  end 
  if(exist('../runtime/bin/sc2_cl_nat.dll','file'))
   copyfile('../runtime/bin/sc2_cl_nat.dll','./');
  end 

  if(exist('./sc2_cl_mtx.dll','file'))
   delete('./sc2_cl_mtx.dll');   
  end 
  if(exist('../runtime/bin/sc2_cl_mtx.dll','file'))
   copyfile('../runtime/bin/sc2_cl_mtx.dll','./');
  end 

  if(exist('./sc2_clhs.dll','file'))
   delete('./sc2_clhs.dll');   
  end 
  if(exist('../runtime/bin/sc2_clhs.dll','file'))
   copyfile('../runtime/bin/sc2_clhs.dll','./');
  end 

  if(exist('./PCO_Recorder.dll','file'))
   delete('./PCO_Recorder.dll');   
  end 
  if(exist('../runtime/bin/PCO_Recorder.dll','file'))
   copyfile('../runtime/bin/PCO_Recorder.dll','./');
  end 
  
  if(exist('./PCO_File.dll','file'))
   delete('./PCO_File.dll');   
  end 
  if(exist('../runtime/bin/PCO_File.dll','file'))
   copyfile('../runtime/bin/PCO_File.dll','./');
  end 

  
 elseif(strcmp(computer('arch'),'win64'))

  if(exist('./sc2_cam.dll','file'))
   delete('./sc2_cam.dll');   
  end 
  if(exist('../runtime/bin64/sc2_cam.dll','file'))
   copyfile('../runtime/bin64/sc2_cam.dll','./');
  end
  
  if(exist('./sc2_cl_me4.dll','file'))
   delete('./sc2_cl_me4.dll');   
  end 
  if(exist('../runtime/bin64/sc2_cl_me4.dll','file'))
   copyfile('../runtime/bin64/sc2_cl_me4.dll','./');
  end 

  if(exist('./sc2_cl_nat.dll','file'))
   delete('./sc2_cl_nat.dll');   
  end 
  if(exist('../runtime/bin64/sc2_cl_nat.dll','file'))
   copyfile('../runtime/bin64/sc2_cl_nat.dll','./');
  end 

  if(exist('./sc2_cl_mtx.dll','file'))
   delete('./sc2_cl_mtx.dll');   
  end 
  if(exist('../runtime/bin64/sc2_cl_mtx.dll','file'))
   copyfile('../runtime/bin64/sc2_cl_mtx.dll','./');
  end 

  if(exist('./sc2_clhs.dll','file'))
   delete('./sc2_clhs.dll');   
  end 
  if(exist('../runtime/bin64/sc2_clhs.dll','file'))
   copyfile('../runtime/bin64/sc2_clhs.dll','./');
  end 

  if(exist('./PCO_Recorder.dll','file'))
   delete('./PCO_Recorder.dll');   
  end 
  if(exist('../runtime/bin64/PCO_Recorder.dll','file'))
   copyfile('../runtime/bin64/PCO_Recorder.dll','./');
  end 
  
  if(exist('./PCO_File.dll','file'))
   delete('./PCO_File.dll');   
  end 
  if(exist('../runtime/bin64/PCO_File.dll','file'))
   copyfile('../runtime/bin64/PCO_File.dll','./');
  end 

 else
  error('This platform is not supported');   
 end 

 