function correlation_matrices_calculate(~, ~, ~)
% "Retrieve correlation matrices": analyses the current image pair like "Analyze current frame"
% (piv.analyze_pair, same settings) and keeps the correlation matrices of all passes for gui.veclick.
% Stereo-PIV: the images of the camera that is shown (rectified, disparity-corrected after the stereo
% calibration); the camera is stored with the matrices.
handles=gui.gethand;
ok=gui.checksettings;
if ok==1
	resultslist=gui.retr('resultslist');
	if ~isempty(resultslist)
		if get(handles.algorithm_selection,'Value')~=1  %fft only
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Not available','Correlation matrices are only available for the ''Multipass FFT window deformation'' algorithm','modal');
			return
		end
		selected=2*floor(get(handles.fileselector, 'value'))-1;
		ismean=gui.retr('ismean');
		currentwasmean=0;
		if size(ismean,1)>=(selected+1)/2
			if ismean((selected+1)/2,1) ==1
				currentwasmean=1;
			end
		end
		if currentwasmean==1
			%result of a temporal operation (mean, sum, ...): no image pair
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Not possible','This frame contains the result of a temporal operation (e.g. a mean), not an image pair: there are no correlation matrices.','modal');
			return
		end
		set(handles.progress, 'string' , ['Frame progress: 0%']);
		set(handles.Settings_Apply_current, 'string' , ['Please wait...']);
		gui.toolsavailable(0,'Getting correlation matrices...');drawnow;
		handles=gui.gethand;
		tic;
		[image1,~]=import.get_img(selected);
		[image2,~]=import.get_img(selected+1);
		current_mask_nr=floor(get(handles.fileselector, 'value'));
		masks_in_frame=gui.retr('masks_in_frame');
		if numel(masks_in_frame)<current_mask_nr
			mask_positions=cell(0);
		else
			mask_positions=masks_in_frame{current_mask_nr};
		end
		preproc.Autolimit_Callback %updates the displayed intensity limits
		s = piv.settings_from_gui(handles);
		s.do_correlation_matrices = 1;
		s.compute_uncertainty = 0;
		try
			r = piv.analyze_pair(image1, image2, mask_positions, s);
		catch ME
			disp(getReport(ME))
			%no result: stop here
			gui.toolsavailable(1);
			set(handles.progress, 'string' , ['Frame progress: 0%']);
			set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Correlation matrices failed',{'The correlation matrices could not be calculated:' ME.message '' 'Details are shown in the Command Window.'},'modal');
			return
		end
		gui.toolsavailable(1);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		set(handles.overall, 'string' , ['Total progress: 100%'])
		set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
		time1frame=toc;
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(time1frame*100)/100) ' s']);
		set(handles.messagetext, 'String','');
		% put correlation matrices and information to gui
		correlation_matrices_data.size = size(r.x);
		correlation_matrices_data.passes = s.passes;
		correlation_matrices_data.frame = selected;
		correlation_matrices_data.correlation_matrices = r.correlation_matrices;
		correlation_matrices_data.all_xy_tables = r.all_xy_tables;
		correlation_matrices_data.camera = 0; % 2D
		if isequal(gui.retr('stereomode'), 1)
			correlation_matrices_data.camera = gui.retr('stereo_active_camera');
		end
		gui.put('correlation_matrices_data',correlation_matrices_data);
	else
		gui.custom_msgbox('error',getappdata(0,'hgui'),'No results yet','You need to analyze the current frame before retrieving correlation matrices.','modal');
	end
end
