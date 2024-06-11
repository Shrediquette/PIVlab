function destroyUI
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
MainWindow=getappdata(0,'hgui');
guidata(MainWindow,handles)
controls = findall(MainWindow,'type','uicontrol');
panels = findall(MainWindow,'type','uipanel');
delete(controls)
delete(panels)
disp('-> UI deleted.')

