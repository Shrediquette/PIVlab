function restore_all_Callback(~, ~, ~)
%clears resultslist at 7,8,9
resultslist=gui.retr('resultslist');

if size(resultslist,1) > 6
	resultslist(7:9,:)={[]};
	if size(resultslist,1) > 9
		resultslist(10:11,:)={[]};
	end
	gui.put('resultslist', resultslist);
	gui.sliderdisp(gui.retr('pivlab_axis'))
end
gui.put('manualdeletion',[]);

