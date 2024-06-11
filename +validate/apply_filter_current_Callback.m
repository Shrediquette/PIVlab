function apply_filter_current_Callback(~, ~, ~)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
gui.put('derived', []); %clear derived parameters if user modifies source data
validate.filtervectors(currentframe)
%put('manualdeletion',[]); %only valid one time, why...? Could work without this line.
gui.sliderdisp(gui.retr('pivlab_axis'));

