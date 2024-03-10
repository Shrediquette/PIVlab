function plot_dummy_Callback(~, ~, ~)
filepath=gui_NameSpace.gui_retr('filepath');
if size(filepath,1) > 1
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
end
gui_NameSpace.gui_MainWindow_ResizeFcn(gcf)
