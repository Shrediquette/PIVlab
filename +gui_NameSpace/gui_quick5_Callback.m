function gui_quick5_Callback (~,~)
handles=gui_NameSpace.gui_gethand;
set(handles.quick5,'Value',0)
piv_NameSpace.piv_do_analys_Callback
