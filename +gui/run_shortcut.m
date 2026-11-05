function run_shortcut(tag)
%RUN_SHORTCUT Run the menu entry or the control with this tag, exactly like a mouse click.
%   gui.run_shortcut(tag)
% Used by the keyboard shortcuts (gui.key_press). Nothing happens when the element does not
% exist, when it is hidden (Basic mode, or a control that only exists in stereo mode) or when
% it is disabled (PIVlab is busy, see gui.toolsavailable). A keyboard shortcut can therefore
% never do more than the mouse can do at the same moment.
hgui = getappdata(0,'hgui');
if isempty(hgui) || ~ishandle(hgui)
	return
end
element = findall(hgui,'Tag',tag); % menus have hidden handles, see gui.generateMenu
if isempty(element)
	return
end
element = element(1);
if strcmp(get(element,'Enable'),'off') || strcmp(get(element,'Visible'),'off')
	return
end
% A menu entry inside a hidden menu cannot be clicked either. Controls are not checked this way:
% they sit in the multip panels, of which only the current one is visible, while their menu
% entry still works.
parent = get(element,'Parent');
while ~isempty(parent) && strcmp(get(parent,'Type'),'uimenu')
	if strcmp(get(parent,'Visible'),'off')
		return
	end
	parent = get(parent,'Parent');
end
callback = get(element,'Callback');
if isempty(callback)
	return
end
feval(callback,element,[]);
