function extract_plot_data_area_Callback(~,~,~)
%click on button to extract data
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
[returned_data, returned_header]=extract_NameSpace.extract_plot_data_area(currentframe,1);
