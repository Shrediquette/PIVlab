function no_dongle_msgbox
gui.custom_msgbox('error',getappdata(0,'hgui'),'No connection',['No connection to the PIVlab-SimpleSync found.' sprintf('\n') 'Is the USB dongle connected?'],'modal');


