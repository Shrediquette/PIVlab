function deletestreamlines_Callback(~, ~, ~)
gui.put('streamlinesX',[]);
gui.put('streamlinesY',[]);
delete(findobj('tag','streamline'));

