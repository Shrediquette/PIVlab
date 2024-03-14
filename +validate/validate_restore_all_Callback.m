function validate_restore_all_Callback(~, ~, ~)
%clears resultslist at 7,8,9
resultslist=gui.gui_retr('resultslist');

if size(resultslist,1) > 6
	resultslist(7:9,:)={[]};
	if size(resultslist,1) > 9
		resultslist(10:11,:)={[]};
	end
	gui.gui_put('resultslist', resultslist);
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
end
gui.gui_put('manualdeletion',[]);

