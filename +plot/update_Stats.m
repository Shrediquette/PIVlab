function update_Stats(x,y,u,v,w)
%UPDATE_STATS Mean, min, max and standard deviation of u, v (and w) of the current frame (Statistics panel).
%   plot.update_Stats(x,y,u,v)     2D PIV: the w lines show N/A
%   plot.update_Stats(x,y,u,v,w)   stereo-PIV: w = out-of-plane component [px/frame] (stereo.w_of_frame)
handles=gui.gethand;
if nargin<5
	w=[];
end
calu=gui.retr('calu');calv=gui.retr('calv');
if (calu==1 || calu==-1) && gui.retr('calxy')==1
	unit=' px/frame';
else %calibrated
	displacement_only=gui.retr('displacement_only');
	if ~isempty(displacement_only) && displacement_only == 1
		unit=' m/frame';
	else
		unit=' m/s';
	end
end
show_component(handles,'u',u*calu,unit);
show_component(handles,'v',v*calv,unit);
if isempty(w)
	show_component(handles,'w',[],unit);
else
	show_component(handles,'w',w*abs(calu),unit); %|calu|: an axis flip of x or y does not flip w
end
end

function show_component(handles,component,values,unit)
%Writes mean, min, max and std of one velocity component into its four lines of the panel.
if isempty(values)
	set([handles.(['mean' component]) handles.(['min' component]) handles.(['max' component]) handles.(['std' component])],'String','N/A');
	return
end
values=values(:);
set(handles.(['mean' component]),'String',[num2str(mean(values,'omitnan')) unit]);
set(handles.(['min' component]),'String',[num2str(min(values,[],'omitnan')) unit]);
set(handles.(['max' component]),'String',[num2str(max(values,[],'omitnan')) unit]);
set(handles.(['std' component]),'String',[num2str(std(values,'omitnan')) unit]);
end
