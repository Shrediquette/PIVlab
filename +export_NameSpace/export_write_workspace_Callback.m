function export_write_workspace_Callback(~, ~, ~)
resultslist=gui_NameSpace.gui_retr('resultslist');
if isempty(resultslist)==0
	derived=gui_NameSpace.gui_retr('derived');
	calxy=gui_NameSpace.gui_retr('calxy');
	calu=gui_NameSpace.gui_retr('calu');calv=gui_NameSpace.gui_retr('calv');
	nrframes=size(resultslist,2);
	if size(resultslist,1)< 11
		resultslist{11,nrframes}=[]; %make sure resultslist has cells for all params
	end
	if isempty(derived)==0
		if size(derived,1)<= 10|| size(derived,2) < nrframes
			derived{11,nrframes}=[]; %make sure derived has cells for all params
		end
	else
		derived=cell(11,nrframes);
	end

	if calxy==1 && (calu==1 ||calu==-1)
		units='[px] respectively [px/frame]';
	else
		units='[m] respectively [m/s]';
	end
	%ohne alles: 6 hoch
	%mit filtern: 11 hoch
	%mit smoothed, 11 hoch und inhalt...
	u_original=cell(size(resultslist,2),1);
	v_original=u_original;
	x=u_original;
	y=u_original;
	typevector_original=u_original;
	u_filtered=u_original;
	v_filtered=v_original;
	typevector_filtered=u_original;
	u_smoothed=u_original;
	v_smoothed=u_original;
	vorticity=cell(size(derived,2),1);
	velocity_magnitude=vorticity;
	u_component=vorticity;
	v_component=vorticity;
	divergence=vorticity;
	vortex_locator=vorticity;
	shear_rate=vorticity;
	strain_rate=vorticity;
	LIC=vorticity;
	vectorangle=vorticity;
	correlation_map=vorticity;

	for i=1:nrframes
		[x_cal,y_cal]=calibrate_NameSpace.calibrate_xy (resultslist{1,i},resultslist{2,i});
		x{i,1}=x_cal;
		y{i,1}=y_cal;
		u_original{i,1}=resultslist{3,i}*calu;
		v_original{i,1}=resultslist{4,i}*calv;
		typevector_original{i,1}=resultslist{5,i};
		u_filtered{i,1}=resultslist{7,i}*calu;
		v_filtered{i,1}=resultslist{8,i}*calv;
		typevector_filtered{i,1}=resultslist{9,i};
		u_smoothed{i,1}=resultslist{10,i}*calu;
		v_smoothed{i,1}=resultslist{11,i}*calv;

		vorticity{i,1}=derived{1,i};
		velocity_magnitude{i,1}=derived{2,i};
		u_component{i,1}=derived{3,i};
		v_component{i,1}=derived{4,i};
		divergence{i,1}=derived{5,i};
		vortex_locator{i,1}=derived{6,i};
		shear_rate{i,1}=derived{7,i};
		strain_rate{i,1}=derived{8,i};
		LIC{i,1}=derived{9,i};
		vectorangle{i,1}=derived{10,i};
		correlation_map{i,1}=derived{11,i};
	end

	assignin('base','x',x);
	assignin('base','y',y);
	assignin('base','u_original',u_original);
	assignin('base','v_original',v_original);
	assignin('base','typevector_original',typevector_original);
	assignin('base','u_filtered',u_filtered);
	assignin('base','v_filtered',v_filtered);
	assignin('base','typevector_filtered',typevector_filtered);
	assignin('base','u_smoothed',u_smoothed);
	assignin('base','v_smoothed',v_smoothed);

	assignin('base','vorticity',vorticity);

	assignin('base','velocity_magnitude',velocity_magnitude);
	assignin('base','u_component',u_component);
	assignin('base','v_component',v_component);
	assignin('base','divergence',divergence);
	assignin('base','vortex_locator',vortex_locator);
	assignin('base','shear_rate',shear_rate);
	assignin('base','strain_rate',strain_rate);
	assignin('base','LIC',LIC);
	assignin('base','vectorangle',vectorangle);
	assignin('base','correlation_map',correlation_map);

	assignin('base','calxy',calxy);
	assignin('base','calu',calu);
	assignin('base','calv',calv);
	assignin('base','units',units);


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
end
