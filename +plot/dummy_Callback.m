function dummy_Callback(~, ~, ~)
filepath=gui.retr('filepath');
if size(filepath,1) > 1
	gui.sliderdisp(gui.retr('pivlab_axis'))
end
gui.MainWindow_ResizeFcn(gcf)

