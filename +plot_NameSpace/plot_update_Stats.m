function plot_update_Stats(x,y,u,v)
handles=gui_NameSpace.gui_gethand;
calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
calxy=gui_NameSpace.gui_retr('calxy');
x=reshape(x,size(x,1)*size(x,2),1);
y=reshape(y,size(y,1)*size(y,2),1);
u=reshape(u,size(u,1)*size(u,2),1);
v=reshape(v,size(v,1)*size(v,2),1);
if (gui_NameSpace.gui_retr('calu')==1 || gui_NameSpace.gui_retr('calu')==-1) && gui_NameSpace.gui_retr('calxy')==1
	set (handles.meanu,'string', [num2str(mean(u*calu,'omitnan')) ' ± ' num2str(std(u*calu,'omitnan')) ' px/frame'])
	set (handles.meanv,'string', [num2str(mean(v*calv,'omitnan')) ' ± ' num2str(std(v*calv,'omitnan')) ' px/frame'])
	set (handles.maxu,'string', [num2str(max(u*calu,[],'omitnan')) ' px/frame'])
	set (handles.minu,'string', [num2str(min(u*calu,[],'omitnan')) ' px/frame'])
	set (handles.maxv,'string', [num2str(max(v*calv,[],'omitnan')) ' px/frame'])
	set (handles.minv,'string', [num2str(min(v*calv,[],'omitnan')) ' px/frame'])
else
	set (handles.meanu,'string', [num2str(mean(u*calu,'omitnan')) ' ± ' num2str(std(u*calu,'omitnan')) ' m/s'])
	set (handles.meanv,'string', [num2str(mean(v*calv,'omitnan')) ' ± ' num2str(std(v*calv,'omitnan')) ' m/s'])
	set (handles.maxu,'string', [num2str(max(u*calu,[],'omitnan')) ' m/s'])
	set (handles.minu,'string', [num2str(min(u*calu,[],'omitnan')) ' m/s'])
	set (handles.maxv,'string', [num2str(max(v*calv,[],'omitnan')) ' m/s'])
	set (handles.minv,'string', [num2str(min(v*calv,[],'omitnan')) ' m/s'])
end
