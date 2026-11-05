function generateMenu
%GENERATEMENU Menu bar of the PIVlab main window.
% Keyboard shortcuts are NOT set with the 'Accelerator' property: that can only do Ctrl+key, and
% Ctrl+key is taken by the operating system and by Matlab's text fields (Ctrl+A, Ctrl+C, Ctrl+V,
% Ctrl+Z). All shortcuts are Ctrl+Shift+key and are handled in gui.key_press, which finds the
% entry by its Tag (gui.run_shortcut). The shortcut is written into the label so that it is still
% visible in the menu; keep label, Tag and gui.key_press in sync, and also
% docs/manual/pages/shortcuts.html.
MainWindow=getappdata(0,'hgui');
%% Menu items
m1 = uimenu(MainWindow,'Label','File');
uimenu(m1,'Label','New session   (Ctrl+Shift+N)','Callback',@import.loadimgs_Callback,'Tag','menu_new_session');
m2 = uimenu(m1,'Label','Load');
uimenu(m2,'Label','Load images','Callback',@load_images_dummy);
uimenu(m2,'Label','Import PIVlab settings','Callback',@import.load_settings_Callback);
uimenu(m2,'Label','Load PIVlab session','Separator','on','Callback',@import.load_session_Callback);
m3 = uimenu(m1,'Label','Save');
uimenu(m3,'Label','Save current PIVlab settings','Callback',@export.save_settings_Callback);
uimenu(m3,'Label','Save PIVlab session','Separator','on','Callback',@export.save_session_Callback);
m14 = uimenu(m1,'Label','Export');
uimenu(m14,'Label','Still image or animation','Callback',@export.pixel_data);
uimenu(m14,'Label','Text file (ASCII)','Callback',@export.ascii_chart_Callback);
uimenu(m14,'Label','MAT file','Callback',@export.matlab_file_Callback);
uimenu(m14,'Label','Tecplot file','Callback',@export.tecplot_file_Callback);
uimenu(m14,'Label','Paraview binary VTK','Callback',@export.paraview_Callback);
uimenu(m14,'Label','All results to Matlab workspace','Callback',@export.write_workspace_Callback);
uimenu(m1,'Label','Preferences','Callback',@gui.preferences_Callback);
m_mode = uimenu(m1,'Label','Mode');
uimenu(m_mode,'Label','Basic','Tag','menu_mode_basic','Callback',@(~,~) gui.request_mode_switch('basic'));
uimenu(m_mode,'Label','Advanced','Tag','menu_mode_advanced','Callback',@(~,~) gui.request_mode_switch('advanced'));
m4 = uimenu(m1,'Label','Exit','Separator','on','Callback',@gui.exitpivlab_Callback);
m51 = uimenu(MainWindow,'Label','Image acquisition');
uimenu(m51,'Label','Capture PIV images','Callback',@acquisition.capture_images_Callback);
m5 = uimenu(MainWindow,'Label','Image settings');
m5_1=uimenu(m5,'Label','Camera calibration (lens / distortion)','Tag','menu_camcalib');
uimenu(m5_1,'Label','Setup / define / generate marker board','Callback',@preproc.cam_marker_setup_Callback);
uimenu(m5_1,'Label','Camera calibration (undistortion)','Callback',@preproc.cam_calibration_Callback);
uimenu(m5_1,'Label','Image rectification / alignment','Callback',@preproc.cam_rectification_Callback);
uimenu(m5,'Label','Image pre-processing / enhancement   (Ctrl+Shift+I)','Callback',@preproc.Uielement_Callback,'Tag','menu_preprocessing');

uimenu(m5,'Label','Define region of interest (ROI)   (Ctrl+Shift+E)','Callback',@roi.img_ROI_Callback,'Tag','menu_roi');
uimenu(m5,'Label','Define masks (exclude regions from analysis)   (Ctrl+Shift+K)','Callback',@mask.img_mask_new_Callback,'Tag','menu_masks');

m6 = uimenu(MainWindow,'Label','Analysis');
uimenu(m6,'Label','PIV settings   (Ctrl+Shift+S)','Callback',@piv.sett_Callback,'Tag','menu_pivsettings');
uimenu(m6,'Label','Stereo-PIV   (Ctrl+Shift+W)','Callback',@stereo.panel_Callback,'Tag','menu_stereopiv');
uimenu(m6,'Label','ANALYZE!   (Ctrl+Shift+A)','Callback',@piv.do_analys_Callback,'Tag','menu_analyze');
m7 = uimenu(MainWindow,'Label','Validation');
uimenu(m7,'Label','Velocity based validation   (Ctrl+Shift+V)','Callback',@validate.vector_val_Callback,'Tag','menu_velvalidation');
uimenu(m7,'Label','Image based validation   (Ctrl+Shift+F)','Callback',@validate.image_val_Callback,'Tag','menu_imgvalidation');
m8 = uimenu(MainWindow,'Label','Spatial calibration (px → mm)');
uimenu(m8,'Label','Calibrate using current or external image   (Ctrl+Shift+Z)','Callback',@calibrate.cal_actual_Callback,'Tag','menu_spatialcalib');
m9 = uimenu(MainWindow,'Label','Plot');
uimenu(m9,'Label','Spatial: Derive parameters / modify data   (Ctrl+Shift+D)','Callback',@plot.derivs_Callback,'Tag','menu_derivespatial');
uimenu(m9,'Label','Temporal: Derive parameters   (Ctrl+Shift+R)','Callback',@plot.temporal_derivs_Callback,'Tag','menu_derivetemporal');
uimenu(m9,'Label','Modify plot appearance   (Ctrl+Shift+M)','Callback',@plot.modif_plot_Callback,'Tag','menu_plotappearance');
uimenu(m9,'Label','Streamlines','Callback',@plot.streamlines_Callback);
uimenu(m9,'Label','Markers / distance / angle   (Ctrl+Shift+T)','Callback',@extract.dist_angle_Callback,'Tag','menu_markers');
uimenu(m9,'Label','Correlation matrices','Callback',@plot.correlation_matrices_Callback,'Tag','menu_corrmatrices');
uimenu(m9,'Label','Second monitor display (experimental)','Separator','on','Callback',@gui.toggle_second_monitor_Callback,'tag','2ndmonitor');
m10 = uimenu(MainWindow,'Label','Extractions');
uimenu(m10,'Label','Parameters from poly-line   (Ctrl+Shift+P)','Callback',@extract.poly_extract_Callback,'Tag','menu_polyline');
uimenu(m10,'Label','Parameters from area   (Ctrl+Shift+Q)','Callback',@extract.area_panel_activation_Callback,'Tag','menu_area');
m11 = uimenu(MainWindow,'Label','Statistics');
uimenu(m11,'Label','Statistics   (Ctrl+Shift+B)','Callback',@plot.statistics_Callback,'Tag','menu_statistics');
m12 = uimenu(MainWindow,'Label','Synthetic particle image generation','Tag','menu_partgen');
uimenu(m12,'Label','Particle image generator   (Ctrl+Shift+G)','Callback',@simulate.part_img_3d_Callback,'Tag','menu_partgen3d');
m13 = uimenu(MainWindow,'Label','Learn!');
uimenu(m13,'Label','Tutorial videos','Callback',@gui.pivlabyoutube_Callback);
uimenu(m13,'Label','Getting started manual   (Ctrl+Shift+H)','Callback',@gui.pivlabhelp_Callback,'Tag','menu_gettingstarted');
uimenu(m13,'Label','PIVlab Manual','Callback',@gui.pivlabmanual_Callback);
uimenu(m13,'Label','List keyboard shortcuts','Callback',@gui.shortcuts_Callback);
uimenu(m13,'Label','Forum','Callback',@misc.Forum_Callback);
uimenu(m13,'Label','Interactive correlation demo','Callback',@misc.correlation_demo_Callback);
uimenu(m13,'Label','About','Callback',@gui.aboutpiv_Callback);
uimenu(m13,'Label','Website','Callback',@misc.Website_Callback);
uimenu(m13,'Label','How to cite PIVlab','Callback',@misc.howtocite_Callback);
menuhandles = findall(getappdata(0,'hgui'),'type','uimenu'); %das soll gemacht werden laut Hilfe
set(menuhandles,'HandleVisibility','off');
disp('-> Menu generated.')

function load_images_dummy(~,~,~) % dummy function that performs two callbacks for loading images.
    import.loadimgs_Callback
    drawnow
    import.loadimgsbutton_Callback([],[],1,[])
