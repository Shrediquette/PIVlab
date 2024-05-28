function plot_data_area_Callback(~,~,~)
%click on button to extract data
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
[returned_data, returned_header]=extract.plot_data_area(currentframe,1);

