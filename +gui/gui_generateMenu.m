function gui_generateMenu
%% Menu items
m1 = uimenu('Label','File');
uimenu(m1,'Label','New session','Callback',@import.import_loadimgs_Callback,'Accelerator','N');
m2 = uimenu(m1,'Label','Load');
uimenu(m2,'Label','Import PIVlab settings','Callback',@import.import_load_settings_Callback);
uimenu(m2,'Label','Load PIVlab session','Separator','on','Callback',@import.import_load_session_Callback);
m3 = uimenu(m1,'Label','Save');
uimenu(m3,'Label','Save current PIVlab settings','Callback',@export.export_save_settings_Callback);
uimenu(m3,'Label','Save PIVlab session','Separator','on','Callback',@export.export_save_session_Callback);
m14 = uimenu(m1,'Label','Export');
uimenu(m14,'Label','Still image or animation','Callback',@export.export_pixel_data);
uimenu(m14,'Label','Text file (ASCII)','Callback',@export.export_ascii_chart_Callback);
uimenu(m14,'Label','MAT file','Callback',@export.export_matlab_file_Callback);
uimenu(m14,'Label','Tecplot file','Callback',@export.export_tecplot_file_Callback);
uimenu(m14,'Label','Paraview binary VTK','Callback',@export.export_paraview_Callback);
uimenu(m14,'Label','All results to Matlab workspace','Callback',@export.export_write_workspace_Callback);
uimenu(m1,'Label','Preferences','Callback',@gui.gui_preferences_Callback);
m4 = uimenu(m1,'Label','Exit','Separator','on','Callback',@gui.gui_exitpivlab_Callback);
m51 = uimenu('Label','Image acquisition');
uimenu(m51,'Label','Capture PIV images','Callback',@acquisition.acquisition_capture_images_Callback);
m5 = uimenu('Label','Image settings');
uimenu(m5,'Label','Define region of interest (ROI)','Callback',@roi_1.roi_img_ROI_Callback,'Accelerator','E');
uimenu(m5,'Label','Define masks to exclude regions from analysis','Callback',@mask.mask_img_mask_new_Callback);
uimenu(m5,'Label','Image pre-processing','Callback',@preproc.preproc_Uielement_Callback,'Accelerator','I');
m6 = uimenu('Label','Analysis');
uimenu(m6,'Label','PIV settings','Callback',@piv.piv_sett_Callback,'Accelerator','S');
uimenu(m6,'Label','ANALYZE!','Callback',@piv.piv_do_analys_Callback,'Accelerator','A');
m7 = uimenu('Label','Calibration');
uimenu(m7,'Label','Calibrate using current or external image','Callback',@calibrate.calibrate_cal_actual_Callback,'Accelerator','Z');
m8 = uimenu('Label','Validation');
uimenu(m8,'Label','Velocity based validation','Callback',@validate.validate_vector_val_Callback,'Accelerator','V');
uimenu(m8,'Label','Image based validation','Callback',@validate.validate_image_val_Callback);
m9 = uimenu('Label','Plot');
uimenu(m9,'Label','Spatial: Derive parameters / modify data','Callback',@plot.plot_derivs_Callback,'Accelerator','D');
uimenu(m9,'Label','Temporal: Derive parameters','Callback',@plot.plot_temporal_derivs_Callback);
uimenu(m9,'Label','Modify plot appearance','Callback',@plot.plot_modif_plot_Callback,'Accelerator','M');
uimenu(m9,'Label','Streamlines','Callback',@plot.plot_streamlines_Callback);
uimenu(m9,'Label','Markers / distance / angle','Callback',@extract.extract_dist_angle_Callback,'Accelerator','T');
m10 = uimenu('Label','Extractions');
uimenu(m10,'Label','Parameters from poly-line','Callback',@extract.extract_poly_extract_Callback,'Accelerator','P');
uimenu(m10,'Label','Parameters from area','Callback',@extract.extract_area_panel_activation_Callback,'Accelerator','Q');
m11 = uimenu('Label','Statistics');
uimenu(m11,'Label','Statistics','Callback',@plot.plot_statistics_Callback,'Accelerator','B');
m12 = uimenu('Label','Synthetic particle image generation');
uimenu(m12,'Label','Settings','Callback',@simulate.simulate_part_img_sett_Callback,'Accelerator','G');
m13 = uimenu('Label','Learn!');
uimenu(m13,'Label','List keyboard shortcuts','Callback',@misc.misc_shortcuts_Callback);
uimenu(m13,'Label','How to cite PIVlab','Callback',@misc.misc_howtocite_Callback);
uimenu(m13,'Label','Forum','Callback',@misc.misc_Forum_Callback);
uimenu(m13,'Label','Tutorial videos','Callback',@gui.gui_pivlabyoutube_Callback);
uimenu(m13,'Label','Getting started manual','Callback',@gui.gui_pivlabhelp_Callback,'Accelerator','H');
uimenu(m13,'Label','About','Callback',@gui.gui_aboutpiv_Callback);
uimenu(m13,'Label','Website','Callback',@misc.misc_Website_Callback);
menuhandles = findall(getappdata(0,'hgui'),'type','uimenu'); %das soll gemacht werden laut Hilfe
set(menuhandles,'HandleVisibility','off');
disp('-> Menu generated.')

