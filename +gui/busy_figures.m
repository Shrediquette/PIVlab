function [figs,axs]=busy_figures
%BUSY_FIGURES Windows that show the busy status strip (gui.busy_hint) and the busy mouse pointer.
%   figs: the PIVlab window and, when it is on, the second monitor display
%   (gui.toggle_second_monitor_Callback). axs: the image axes in these windows (a placeholder when a
%   window has none). With the second monitor display, pivlab_axis is the axis on the second monitor:
%   the PIVlab window still gets its strip over its own image area (original_pivlab_axis).
figs=gobjects(0);
axs=gobjects(0);
hgui=getappdata(0,'hgui');
if isempty(hgui) || ~ishandle(hgui)
	return
end
main_axis=gui.retr('original_pivlab_axis');
if isempty(main_axis) || ~isvalid(main_axis)
	main_axis=gui.retr('pivlab_axis');
end
figs(1)=hgui;
axs(1)=gobjects(1);
if ~isempty(main_axis) && isvalid(main_axis)
	axs(1)=main_axis;
end
second_fig=gui.retr('second_monitor_fig');
second_axis=gui.retr('second_monitor_axis');
if ~isempty(second_fig) && isvalid(second_fig) && ~isempty(second_axis) && isvalid(second_axis)
	figs(2)=second_fig;
	axs(2)=second_axis;
end
