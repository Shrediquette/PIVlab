function save_mat_all_Callback(~, ~, ~)
%(asks only if the current frame is analysed, like the other "save" buttons)
export.save_current_frame(@(f,n,p) export.mat_file_save(f,n,p,2),'*.mat','Save MATLAB file as...','PIVlab.mat') %option 2 = all frames
