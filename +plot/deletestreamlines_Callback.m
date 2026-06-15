function deletestreamlines_Callback(~, ~, ~)
gui.put('streamlinesX',[]);
gui.put('streamlinesY',[]);
gui.put('streamslice_active',false);
delete(findobj('tag','streamline'));

