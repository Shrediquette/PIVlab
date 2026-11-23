function write_workspace_Callback(~, ~, ~)
% Export to the MATLAB workspace: the results of all frames (one cell per frame) and the derived
% parameters that were calculated in the GUI.
resultslist=gui.retr('resultslist');
if isempty(resultslist)
	return
end
derived=gui.retr('derived');
calxy=gui.retr('calxy');
calu=gui.retr('calu');calv=gui.retr('calv');
nrframes=size(resultslist,2);
if isempty(derived)
	derived=cell(11,nrframes);
elseif size(derived,1)<= 10|| size(derived,2) < nrframes
	derived{11,nrframes}=[]; %make sure derived has cells for all params
end
unit=export.unit_texts(calu, calxy, gui.retr('displacement_only'), []);
stereo_mode=isequal(gui.retr('stereomode'),1);

[data, w_data]=export.result_cells(resultslist, 1:nrframes);
if stereo_mode %stereo-PIV: the out-of-plane component w (units like u)
	w_data.w_component=cell(nrframes,1);
	if size(derived,1)>=13
		w_data.w_component=derived(13,1:nrframes).';
	end
	for name=fieldnames(w_data).'
		data.(name{1})=w_data.(name{1});
	end
end
%the derived parameters as calculated in the GUI (derived row id-1 of plot.derivative_calc)
derived_names={'vorticity','velocity_magnitude','u_component','v_component','divergence','q_criterion','shear_rate','strain_rate','LIC','vectorangle','correlation_map'};
for k=1:numel(derived_names)
	values=cell(size(derived,2),1);
	values(1:nrframes)=derived(k,1:nrframes);
	data.(derived_names{k})=values;
end
data.uncertainty_map=cell(nrframes,1);
if size(resultslist,1)>=15
	for i=1:nrframes
		data.uncertainty_map{i,1}=resultslist{15,i}*abs(calu);
	end
end
data.calxy=calxy;
data.calu=calu;
data.calv=calv;
data.units=['[' unit.length '] respectively [' unit.velocity ']'];
for name=fieldnames(data).'
	assignin('base',name{1},data.(name{1}));
end

clc
disp('EXPLANATIONS:')
disp(' ')
disp('The first dimension of the variables is the frame number.')
disp('The variables contain all data that was calculated in the PIVlab GUI.')
disp('If some data was not calculated, the corresponding cell is empty.')
disp('Typevector is 0 for masked vector, 1 for regular vector, 2 for filtered vector')
disp(' ')
disp('u_original and v_original are the unmodified velocities from the cross-correlation.')
disp('u_filtered and v_filtered is the above incl. your data validation selection.')
disp('u_smoothed and v_smoothed is the above incl. your smoothing selection.')
if stereo_mode
	disp(['Stereo-PIV: w_original, w_filtered, w_smoothed and w_component are the out-of-plane component (positive ' stereo.w_direction(gui.retr('stereo_calib'),calibrate.w_factor(calu,calv)) ').'])
end
