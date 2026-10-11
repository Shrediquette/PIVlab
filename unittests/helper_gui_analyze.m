function helper_gui_analyze()
%HELPER_GUI_ANALYZE "Analyze all frames" in the PIVlab window, without updating the display.
h = gui.gethand;
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback([], [], []);
drawnow;
end
