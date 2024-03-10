function validate_restore_all_Callback(~, ~, ~)
%clears resultslist at 7,8,9
resultslist=gui_NameSpace.gui_retr('resultslist');

if size(resultslist,1) > 6
	resultslist(7:9,:)={[]};
	if size(resultslist,1) > 9
		resultslist(10:11,:)={[]};
	end
	gui_NameSpace.gui_put('resultslist', resultslist);
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
end
gui_NameSpace.gui_put('manualdeletion',[]);
