function [imdeform, repeat, do_pad]=piv_CorrQuality(~,~)
handles=gui_NameSpace.gui_gethand;
quali = get(handles.CorrQuality,'Value');
if quali==1 % normal quality
	imdeform='*linear';
	repeat = 0;
	do_pad = 0;
end
if quali==2 % high quality
	imdeform='*spline';
	repeat = 0;
	do_pad = 1;
end
if quali==3 % ultra quality
	imdeform='*spline';
	repeat = 1;
	do_pad = 1;
end
