function deletestreamlines_Callback(~, ~, ~)
gui.gui_put('streamlinesX',[]);
gui.gui_put('streamlinesY',[]);
delete(findobj('tag','streamline'));

