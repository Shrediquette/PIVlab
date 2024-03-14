function gui_font_size_change (~,~,magnifier)
objects=findobj('Type','uicontrol');
objects=[objects; findobj('Type','uipanel')];
A=get (objects,'fontsize');
A=cellfun(@(x) x+magnifier, A);

for i=1:size(A,1)
	try
		set(objects(i), 'FontSize',A(i));
	catch
	end
end

