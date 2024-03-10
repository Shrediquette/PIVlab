function validate_apply_filter_current_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
gui_NameSpace.gui_put('derived', []); %clear derived parameters if user modifies source data
validate_NameSpace.validate_filtervectors(currentframe)
%put('manualdeletion',[]); %only valid one time, why...? Could work without this line.
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'));
