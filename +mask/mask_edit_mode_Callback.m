function mask_edit_mode_Callback(~,~,~)
%changes the display mode of the masks.
%in sliderdisp, the status of the popupmenu is checked, then decides how to plot masks.
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));

