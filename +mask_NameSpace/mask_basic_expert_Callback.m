function mask_basic_expert_Callback(~,~,~)
handles=gui_NameSpace.gui_gethand;
modus=get(handles.mask_basic_expert,'Value');
if modus==1 %basic
	set(handles.uipanel25_1,'Visible','on');
	set(handles.uipanel25_9,'Visible','on');
	set(handles.uipanel25_2,'Visible','off');
elseif modus==2 %expert
	set(handles.uipanel25_1,'Visible','off');
	set(handles.uipanel25_9,'Visible','off');
	set(handles.uipanel25_2,'Visible','on');
end
