function mask_generator_settings=get_generator_settings()
handles=gui.gui_gethand;

mask_generator_settings.binarize_enable = get(handles.binarize_enable,'Value');
mask_generator_settings.mask_medfilt_enable=get(handles.mask_medfilt_enable,'Value');
mask_generator_settings.median_size=get(handles.median_size,'String');
mask_generator_settings.binarize_threshold=get(handles.binarize_threshold,'String');
mask_generator_settings.mask_imopen_imclose_enable=get(handles.mask_imopen_imclose_enable,'Value');
mask_generator_settings.imopen_imclose_size=get(handles.imopen_imclose_size,'String');
mask_generator_settings.imopen_imclose_selection=get(handles.imopen_imclose_selection,'Value');
mask_generator_settings.mask_imdilate_imerode_enable=get(handles.mask_imdilate_imerode_enable ,'Value');
mask_generator_settings.imdilate_imerode_size=get(handles.imdilate_imerode_size,'String');
mask_generator_settings.imdilate_imerode_selection=get(handles.imdilate_imerode_selection,'Value');
mask_generator_settings.mask_remove_enable=get(handles.mask_remove_enable,'Value');
mask_generator_settings.remove_size=get(handles.remove_size,'String');
mask_generator_settings.mask_fill_enable=get(handles.mask_fill_enable,'Value');

mask_generator_settings.binarize_enable_2 = get(handles.binarize_enable_2,'Value');
mask_generator_settings.mask_medfilt_enable_2=get(handles.mask_medfilt_enable_2,'Value');
mask_generator_settings.median_size_2=get(handles.median_size_2,'String');
mask_generator_settings.binarize_threshold_2=get(handles.binarize_threshold_2,'String');
mask_generator_settings.mask_imopen_imclose_enable_2=get(handles.mask_imopen_imclose_enable_2,'Value');
mask_generator_settings.imopen_imclose_size_2=get(handles.imopen_imclose_size_2,'String');
mask_generator_settings.imopen_imclose_selection_2=get(handles.imopen_imclose_selection_2,'Value');
mask_generator_settings.mask_imdilate_imerode_enable_2=get(handles.mask_imdilate_imerode_enable_2 ,'Value');
mask_generator_settings.imdilate_imerode_size_2=get(handles.imdilate_imerode_size_2,'String');
mask_generator_settings.imdilate_imerode_selection_2=get(handles.imdilate_imerode_selection_2,'Value');
mask_generator_settings.mask_remove_enable_2=get(handles.mask_remove_enable_2,'Value');
mask_generator_settings.remove_size_2=get(handles.remove_size_2,'String');
mask_generator_settings.mask_fill_enable_2=get(handles.mask_fill_enable_2,'Value');

mask_generator_settings.low_contrast_mask_threshold=get(handles.low_contrast_mask_threshold,'String');
mask_generator_settings.low_contrast_mask_enable=get(handles.low_contrast_mask_enable,'Value');
mask_generator_settings.mask_medfilt_enable_3=get(handles.mask_medfilt_enable_3,'Value');
mask_generator_settings.median_size_3=get(handles.median_size_3,'String');
mask_generator_settings.mask_imopen_imclose_enable_3=get(handles.mask_imopen_imclose_enable_3,'Value');
mask_generator_settings.imopen_imclose_size_3=get(handles.imopen_imclose_size_3,'String');
mask_generator_settings.imopen_imclose_selection_3=get(handles.imopen_imclose_selection_3,'Value');
mask_generator_settings.mask_imdilate_imerode_enable_3=get(handles.mask_imdilate_imerode_enable_3 ,'Value');
mask_generator_settings.imdilate_imerode_size_3=get(handles.imdilate_imerode_size_3,'String');
mask_generator_settings.imdilate_imerode_selection_3=get(handles.imdilate_imerode_selection_3,'Value');
mask_generator_settings.mask_remove_enable_3=get(handles.mask_remove_enable_3,'Value');
mask_generator_settings.remove_size_3=get(handles.remove_size_3,'String');
mask_generator_settings.mask_fill_enable_3=get(handles.mask_fill_enable_3,'Value');

