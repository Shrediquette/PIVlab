function pco_error_msgbox
filepath = fileparts(which('PIVlab_GUI.m'));
gui.custom_msgbox('error',getappdata(0,'hgui'),'pco.matlab not found',['pco.matlab extension not found.' newline  'You need to install pco.matlab, and then add that folder to the Matlab search path permanently.' newline newline 'Please follow the instructions in the wiki on github: ' newline newline 'https://github.com/Shrediquette/PIVlab/wiki/Setup-pco-cameras'],'modal');


