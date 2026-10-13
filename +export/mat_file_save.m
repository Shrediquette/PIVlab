function mat_file_save (currentframe,FileName,PathName,type)
handles=gui.gethand;
include_deriv=get(handles.export_mat_derivatives,'Value');
resultslist=gui.retr('resultslist');
if isempty(resultslist)==0
	calxy=gui.retr('calxy');
	calu=gui.retr('calu');calv=gui.retr('calv');
	nrframes=size(resultslist,2);

	if size(resultslist,1)< 11
		resultslist{11,nrframes}=[]; %make sure resultslist has cells for all params
	end

	if calxy==1 && (calu==1 ||calu==-1)
		units='[px] respectively [px/frame]';
	else % calibrated
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			units='[m] respectively [m/frame]';
		else
			units='[m] respectively [m/s]';
		end
	end

	u_original=cell(nrframes,1);
	v_original=u_original;
	x=u_original;
	y=u_original;
	typevector_original=u_original;
	u_filtered=u_original;
	v_filtered=v_original;
	typevector_filtered=u_original;
	u_smoothed=u_original;
	v_smoothed=u_original;

	if include_deriv
		vorticity=cell(nrframes,1);
		velocity_magnitude=vorticity;
		u_component=vorticity;
		v_component=vorticity;
		divergence=vorticity;
		q_criterion=vorticity;
		shear_rate=vorticity;
		strain_rate=vorticity;
		vectorangle=vorticity;
		correlation_map=vorticity;
		uncertainty_map=vorticity;
	end

	stereo_mode=isequal(gui.retr('stereomode'),1); %stereo-PIV: the out-of-plane component w too
	if stereo_mode
		w_original=u_original;
		w_filtered=u_original;
		w_smoothed=u_original;
		if include_deriv
			w_component=u_original;
		end
	end

	if type==1
		nrframes=1;
	end

	for i=1:nrframes
		if type==2 %all frames
			currentframe=i;
		end
		[x_cal,y_cal]=calibrate.xy (resultslist{1,currentframe},resultslist{2,currentframe});
		x{i,1}=x_cal;
		y{i,1}=y_cal;

		u_original{i,1}=resultslist{3,currentframe}*calu;
		v_original{i,1}=resultslist{4,currentframe}*calv;
		typevector_original{i,1}=resultslist{5,currentframe};
		u_filtered{i,1}=resultslist{7,currentframe}*calu;
		v_filtered{i,1}=resultslist{8,currentframe}*calv;
		typevector_filtered{i,1}=resultslist{9,currentframe};
		u_smoothed{i,1}=resultslist{10,currentframe}*calu;
		v_smoothed{i,1}=resultslist{11,currentframe}*calv;
		if stereo_mode %w is computed from the validated 2D results of both cameras: original = filtered
			w_original{i,1}=stereo.w_of_frame(currentframe,false,resultslist)*abs(calu);
			w_filtered{i,1}=w_original{i,1};
			if size(resultslist,1)>=17
				w_smoothed{i,1}=resultslist{17,currentframe}*abs(calu);
			end
		end

		if include_deriv
			deriv_list=[2:9, 11:13]; % skip 10 (LIC)
			if stereo_mode
				deriv_list=[deriv_list 14]; %w component
			end
			for deriv_idx=deriv_list
				plot.derivative_calc(currentframe,deriv_idx,1);
			end
			derived=gui.retr('derived');
			vorticity{i,1}=derived{1,currentframe};
			velocity_magnitude{i,1}=derived{2,currentframe};
			u_component{i,1}=derived{3,currentframe};
			v_component{i,1}=derived{4,currentframe};
			divergence{i,1}=derived{5,currentframe};
			q_criterion{i,1}=derived{6,currentframe};
			shear_rate{i,1}=derived{7,currentframe};
			strain_rate{i,1}=derived{8,currentframe};
			vectorangle{i,1}=derived{10,currentframe};
			correlation_map{i,1}=derived{11,currentframe};
			uncertainty_map{i,1}=derived{12,currentframe};
			if stereo_mode
				w_component{i,1}=derived{13,currentframe};
			end
		end
	end

	if type == 1 %nur ein frame
		x=x{i,1};
		y=y{i,1};
		u_original=u_original{i,1};
		v_original=v_original{i,1};
		typevector_original=typevector_original{i,1};
		u_filtered=u_filtered{i,1};
		v_filtered=v_filtered{i,1};
		typevector_filtered=typevector_filtered{i,1};
		u_smoothed=u_smoothed{i,1};
		v_smoothed=v_smoothed{i,1};

		if include_deriv
			vorticity=vorticity{i,1};
			velocity_magnitude=velocity_magnitude{i,1};
			u_component=u_component{i,1};
			v_component=v_component{i,1};
			divergence=divergence{i,1};
			q_criterion=q_criterion{i,1};
			shear_rate=shear_rate{i,1};
			strain_rate=strain_rate{i,1};
			vectorangle=vectorangle{i,1};
			correlation_map=correlation_map{i,1};
			uncertainty_map=uncertainty_map{i,1};
		end
		if stereo_mode
			w_original=w_original{i,1};
			w_filtered=w_filtered{i,1};
			w_smoothed=w_smoothed{i,1};
			if include_deriv
				w_component=w_component{i,1};
			end
		end
	end
end

information={'The first dimension of the variables is the frame number.';'The variables contain all data that was calculated in the PIVlab GUI.';'If some data was not calculated, the corresponding cell is empty.';'Typevector is 0 for masked vector, 1 for regular vector, 2 for filtered vector';'u_original and v_original are the unmodified velocities from the cross-correlation.';'u_filtered and v_filtered is the above incl. your data validation selection.';'u_smoothed and v_smoothed is the above incl. your smoothing selection.'};
if include_deriv
	save(fullfile(PathName,FileName), 'x','y','u_original','v_original','typevector_original','u_filtered','v_filtered','typevector_filtered','u_smoothed','v_smoothed','vorticity','velocity_magnitude','u_component','v_component','divergence','q_criterion','shear_rate','strain_rate','calxy','calu', 'calv','units','information','vectorangle','correlation_map','uncertainty_map');
else
	save(fullfile(PathName,FileName), 'x','y','u_original','v_original','typevector_original','u_filtered','v_filtered','typevector_filtered','u_smoothed','v_smoothed','calxy','calu','calv','units','information');
end

if exist('stereo_mode','var') && stereo_mode %stereo-PIV: w and the reconstruction
	stereo_vel=gui.retr('stereo_vel');
	stereo_info=struct(); %saved as the variable "stereo" (a variable of this name would hide the package stereo)
	w_away=stereo.w_direction(gui.retr('stereo_calib'));
	stereo_info.w_sign=['w is positive ' w_away];
	stereo_info.reconstruction_residual_px=stereo_vel.residual; %agreement of the two camera results, per analysed image pair
	stereo_info.light_sheet_z_mm=stereo_vel.sheet_z_mm; %measured light sheet position relative to the board
	stereo_info.mm_per_px=stereo_vel.mm_per_px; %pixel size of the common grid of both cameras
	if type==1 && size(stereo_info.reconstruction_residual_px,3)>=currentframe
		stereo_info.reconstruction_residual_px=stereo_info.reconstruction_residual_px(:,:,currentframe);
	end
	information{end+1,1}=['Stereo-PIV: w_original, w_filtered and w_smoothed are the out-of-plane component (positive ' w_away ', units like u). The struct stereo holds the reconstruction residual, the light sheet position and the pixel size of the common grid.'];
	extra=struct('w_original',{w_original},'w_filtered',{w_filtered},'w_smoothed',{w_smoothed},'stereo',stereo_info,'information',{information});
	if include_deriv
		extra.w_component=w_component;
	end
	save(fullfile(PathName,FileName),'-struct','extra','-append');
end
