function second_monitor_CloseRequestFcn
% Called when the second-monitor figure is closed (by the user or
% programmatically). Restores pivlab_axis to the original axis and cleans
% up state. Does NOT call delete() on the figure — that is handled by the
% caller (toggle_second_monitor_Callback or MainWindow_CloseRequestFcn).

gui.second_monitor_disable;
