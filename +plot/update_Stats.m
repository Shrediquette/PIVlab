function update_Stats(x,y,u,v,w)
%UPDATE_STATS Mean, min, max and standard deviation of u, v (and w) of the current frame (Statistics panel).
%   plot.update_Stats(x,y,u,v)     2D PIV: the w lines show N/A
%   plot.update_Stats(x,y,u,v,w)   stereo-PIV: w = out-of-plane component [px/frame] (stereo.w_of_frame)
handles=gui.gethand;
if nargin<5
	w=[];
end
calu=gui.retr('calu');calv=gui.retr('calv');
[fac, statistic]=gui.frame_factors(floor(get(handles.fileselector,'value'))); %velocity, or standard deviation / TKE of temporal statistics
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
if strcmp(statistic,'tke')
	unit=[' (' strtrim(unit) ')^2']; %TKE: velocity squared
end
show_component(handles,'u',u*fac.u,unit);
show_component(handles,'v',v*fac.v,unit);
if isempty(w)
	show_component(handles,'w',[],unit);
else
	show_component(handles,'w',w*fac.w,unit); %w is positive along z = x cross y
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
