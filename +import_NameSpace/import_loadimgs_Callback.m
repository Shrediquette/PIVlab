function import_loadimgs_Callback(~, ~, ~)
gui_NameSpace.gui_switchui('multip01')
delete(findobj('tag','hinting'))
