function overlappercent
handles=gui.gethand;
perc=100-str2double(get(handles.step,'string'))/str2double(get(handles.intarea,'string'))*100;
set (handles.steppercentage, 'string', ['= ' int2str(perc) '%']);

