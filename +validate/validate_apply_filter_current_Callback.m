function validate_apply_filter_current_Callback(~, ~, ~)
handles=gui.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
gui.gui_put('derived', []); %clear derived parameters if user modifies source data
validate.validate_filtervectors(currentframe)
%put('manualdeletion',[]); %only valid one time, why...? Could work without this line.
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));

