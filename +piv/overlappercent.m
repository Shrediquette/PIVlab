function overlappercent
handles=gui.gethand;
perc=100-str2double(get(handles.pass1_step,'string'))/str2double(get(handles.pass1_size,'string'))*100;
set (handles.steppercentage, 'string', ['= ' int2str(perc) '%']);

