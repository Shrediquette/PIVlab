function plot_deletestreamlines_Callback(~, ~, ~)
gui_NameSpace.gui_put('streamlinesX',[]);
gui_NameSpace.gui_put('streamlinesY',[]);
delete(findobj('tag','streamline'));
