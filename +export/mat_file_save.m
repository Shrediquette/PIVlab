function mat_file_save (currentframe,FileName,PathName,type)
% Saves the results in a MAT file: type 1 = only frame currentframe, type 2 = all frames (one cell
% per frame).
handles=gui.gethand;
include_deriv=get(handles.export_mat_derivatives,'Value');
resultslist=gui.retr('resultslist');
if isempty(resultslist)
	return
end
calxy=gui.retr('calxy');
calu=gui.retr('calu');calv=gui.retr('calv');
unit=export.unit_texts(calu, calxy, gui.retr('displacement_only'), []);
units=['[' unit.length '] respectively [' unit.velocity ']'];
if type==1
	frames=currentframe;
else
	frames=1:size(resultslist,2);
end
stereo_mode=isequal(gui.retr('stereomode'),1); %stereo-PIV: the out-of-plane component w too
[data, w_data]=export.result_cells(resultslist, frames);

if include_deriv
	deriv_ids=[2:9, 11:13]; % skip 10 (LIC)
	deriv_names={'vorticity','velocity_magnitude','u_component','v_component','divergence','q_criterion','shear_rate','strain_rate','vectorangle','correlation_map','uncertainty_map'};
	if stereo_mode
		deriv_ids=[deriv_ids 14];
		deriv_names{end+1}='w_component';
	end
	derived_data=cell(numel(frames),numel(deriv_ids));
	for i=1:numel(frames)
		derived=export.derive_frame(frames(i), deriv_ids);
		derived_data(i,:)=derived(deriv_ids-1,frames(i)).'; %parameter id is in row id-1
	end
	for k=1:numel(deriv_names)
		deriv.(deriv_names{k})=derived_data(:,k);
	end
end

if type == 1 %only one frame: the values instead of cells
	data=first_cells(data);
	if include_deriv
		deriv=first_cells(deriv);
	end
	if stereo_mode
		w_data=first_cells(w_data);
	end
end

information={'The first dimension of the variables is the frame number.';'The variables contain all data that was calculated in the PIVlab GUI.';'If some data was not calculated, the corresponding cell is empty.';'Typevector is 0 for masked vector, 1 for regular vector, 2 for filtered vector';'u_original and v_original are the unmodified velocities from the cross-correlation.';'u_filtered and v_filtered is the above incl. your data validation selection.';'u_smoothed and v_smoothed is the above incl. your smoothing selection.'};
%variables in the order of the file
if include_deriv
	for name={'vorticity','velocity_magnitude','u_component','v_component','divergence','q_criterion','shear_rate','strain_rate'}
		data.(name{1})=deriv.(name{1});
	end
end
data.calxy=calxy;
data.calu=calu;
data.calv=calv;
data.units=units;
data.information=information;
if include_deriv
	for name={'vectorangle','correlation_map','uncertainty_map'}
		data.(name{1})=deriv.(name{1});
	end
end
save(fullfile(PathName,FileName), '-struct', 'data');

if stereo_mode %stereo-PIV: w and the reconstruction
	stereo_vel=gui.retr('stereo_vel');
	stereo_info=struct(); %saved as the variable "stereo" (a variable of this name would hide the package stereo)
	w_away=stereo.w_direction(gui.retr('stereo_calib'),calibrate.w_factor(calu,calv));
	stereo_info.w_sign=['w is positive ' w_away];
	stereo_info.reconstruction_residual_px=stereo_vel.residual; %agreement of the two camera results, per analysed image pair
	stereo_info.light_sheet_z_mm=stereo_vel.sheet_z_mm; %measured light sheet position relative to the board
	stereo_info.mm_per_px=stereo_vel.mm_per_px; %pixel size of the common grid of both cameras
	if type==1 && size(stereo_info.reconstruction_residual_px,3)>=currentframe
		stereo_info.reconstruction_residual_px=stereo_info.reconstruction_residual_px(:,:,currentframe);
	end
	information{end+1,1}=['Stereo-PIV: w_original, w_filtered and w_smoothed are the out-of-plane component (positive ' w_away ', units like u). The struct stereo holds the reconstruction residual, the light sheet position and the pixel size of the common grid.'];
	extra=w_data; %w_original, w_filtered, w_smoothed
	extra.stereo=stereo_info;
	extra.information=information;
	if include_deriv
		extra.w_component=deriv.w_component;
	end
	save(fullfile(PathName,FileName),'-struct','extra','-append');
end

function S=first_cells(S)
%the first cell of every field
S=structfun(@(c) c{1}, S, 'UniformOutput', false);
