function plot_dummy_Callback(~, ~, ~)
filepath=gui.gui_retr('filepath');
if size(filepath,1) > 1
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
end
gui.gui_MainWindow_ResizeFcn(gcf)

