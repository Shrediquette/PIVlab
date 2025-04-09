function file_save (currentframe,FileName,PathName,type)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
derived=gui.retr('derived');
filename=gui.retr('filename');
calu=gui.retr('calu');calv=gui.retr('calv');
calxy=gui.retr('calxy');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	[x_cal,y_cal]=calibrate.xy (x,y);

	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe};
			if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
				typevector=resultslist{5,currentframe};
			end
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe};
			else
				%filter was applied to some other frame than this
				%load unfiltered results
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
		typevector=resultslist{5,currentframe};
	end
end
u(typevector==0)=NaN;
v(typevector==0)=NaN;
subtract_u=gui.retr('subtr_u');
subtract_v=gui.retr('subtr_v');

if type==1 %ascii file
	delimiter=get(handles.delimiter, 'value');
	if delimiter==1
		delimiter=',';
	elseif delimiter==2
		delimiter='\t';
	elseif delimiter==3
		delimiter=' ';
	end
	if get(handles.addfileinfo, 'value')==1
		header1=['PIVlab, ASCII chart output - ' char(datetime('today'))];
		header2=['FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> m): ' num2str(calxy) ', conversion factor uv (px/frame -> m/s): ' num2str(calu)];
	else
		header1=[];
		header2=[];
	end
	if get(handles.add_header, 'value')==1
		if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
			if get(handles.export_vort, 'Value') == 1 %alle derivatives exportieren, nicht kalibriert
				header3=['x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'Vector type [-]' delimiter 'vorticity [1/frame]' delimiter 'magnitude [px/frame]' delimiter 'divergence [1/frame]' delimiter 'Q criterion [1/frame^2]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
			else
				header3=['x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'Vector type [-]'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			end
		else %calibrated
			displacement_only=gui.retr('displacement_only');
			if ~isempty(displacement_only) && displacement_only == 1
				if get(handles.export_vort, 'Value') == 1  %alle derivatives exportieren, kalibriert
					header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/frame]' delimiter 'v [m/frame]' delimiter 'Vector type [-]' delimiter 'vorticity [1/frame]' delimiter 'magnitude [m/frame]' delimiter 'divergence [1/frame]' delimiter 'Q criterion [1/frame^2]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
				else
					header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'Vector type [-]'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
				end
			else
				if get(handles.export_vort, 'Value') == 1  %alle derivatives exportieren, kalibriert
					header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'Vector type [-]' delimiter 'vorticity [1/s]' delimiter 'magnitude [m/s]' delimiter 'divergence [1/s]' delimiter 'Q criterion [1/s^2]' delimiter 'simple shear [1/s]' delimiter 'simple strain [1/s]' delimiter 'vector direction [degrees]'];
				else
					header3=['x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'Vector type [-]'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
				end
			end
		end
	else
		header3=[];
	end
	if isempty(header1)==0
		fid = fopen(fullfile(PathName,FileName), 'w');
		fprintf(fid, [header1 '\r\n']);
		fclose(fid);
	end
	if isempty(header2)==0
		fid = fopen(fullfile(PathName,FileName), 'a');
		fprintf(fid, [header2 '\r\n']);
		fclose(fid);
	end
	if isempty(header3)==0
		fid = fopen(fullfile(PathName,FileName), 'a');
		fprintf(fid, [header3 '\r\n']);
		fclose(fid);
	end
	if get(handles.export_vort, 'Value') == 1 %sollen alle derivatives exportiert werden?
		plot.derivative_calc(currentframe,2,1); %vorticity
		plot.derivative_calc(currentframe,3,1); %magnitude
		%u und v habe ich ja...
		plot.derivative_calc(currentframe,6,1); %divergence
		plot.derivative_calc(currentframe,7,1); %q crit
		plot.derivative_calc(currentframe,8,1); %shear
		plot.derivative_calc(currentframe,9,1); %strain
		plot.derivative_calc(currentframe,11,1); %vectorangle
		derived=gui.retr('derived');
		vort=derived{2-1,currentframe};
		magn=derived{3-1,currentframe};
		div=derived{6-1,currentframe};
		q_criterion=derived{7-1,currentframe};
		shear=derived{8-1,currentframe};
		strain=derived{9-1,currentframe};
		vectorangle=derived{11-1,currentframe};
		%correlation_map=derived{12-1,currentframe};
		%wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv-subtract_u,size(u,1)*size(u,2),1) reshape(v*caluv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(dcev,size(dcev,1)*size(dcev,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(q_criterion,size(q_criterion,1)*size(q_criterion,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
	else %no derivatives.
		%wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv-subtract_u,size(u,1)*size(u,2),1) reshape(v*caluv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1)];
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(typevector,size(typevector,1)*size(typevector,2),1)];
	end
	dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc'); %#ok<DLMWT>
end %type==1

if type==2 %NOT USED ANYMORE matlab file
end

if type==3 %paraview vtk PARAVIEW DATEN OHNE die ganzen derivatives.... Berechnet man doch eh direkt in Paraview.
	u=u*calu-subtract_u;
	v=v*calv-subtract_v;

	nr_of_elements=numel(x_cal);
	fid = fopen(fullfile(PathName,FileName), 'w');
	if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
		info='[px/frame]';
	else
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			info='[m/frame]';
		else
			info='[m/s]';
		end
	end
	%ASCII file header
	fprintf(fid, '# vtk DataFile Version 3.0\n');
	fprintf(fid, ['VTK from PIVlab ' info '\n']);
	fprintf(fid, 'BINARY\n\n');
	fprintf(fid, 'DATASET STRUCTURED_GRID\n');
	fprintf(fid, ['DIMENSIONS ' num2str(size(x_cal,1)) ' ' num2str(size(x_cal,2)) ' ' num2str(size(x_cal,3)) '\n']);
	fprintf(fid, ['POINTS ' num2str(nr_of_elements) ' float\n']);
	fclose(fid);

	%append binary x,y,z data
	fid = fopen(fullfile(PathName,FileName), 'a');
	fwrite(fid, [reshape(x_cal,1,nr_of_elements);  reshape(y_cal,1,nr_of_elements); reshape(y_cal,1,nr_of_elements)*0],'float','b');

	%append another ASCII sub header
	fprintf(fid, ['\nPOINT_DATA ' num2str(nr_of_elements) '\n']);
	fprintf(fid, 'VECTORS velocity_vectors float\n');

	%append binary u,v,w data
	fwrite(fid, [reshape(u,1,nr_of_elements);  reshape(v,1,nr_of_elements); reshape(v,1,nr_of_elements)*0],'float','b');

	fclose(fid);

end %type3

if type==4 %tecplot file
	delimiter = ' ';
	header1=['# PIVlab by W.Th. & E.J.S., TECPLOT output - ' char(datetime('today'))];
	header2=['# FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> m): ' num2str(calxy) ', conversion factor uv (px/frame -> m/s): ' num2str(calu)];
	if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
		if get(handles.export_vort_tec, 'Value') == 1 %alle derivatives exportieren, nicht kalibriert
			header3=['# x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'isNaN?' delimiter 'vorticity [1/frame]' delimiter 'magnitude [px/frame]' delimiter 'divergence [1/frame]' delimiter 'Q criterion [1/frame^2]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN", "vorticity", "magnitude", "divergence", "Q_criterion", "simple_shear", "simple_strain", "vector_direction"';
		else
			header3=['# x [px]' delimiter 'y [px]' delimiter 'u [px/frame]' delimiter 'v [px/frame]' delimiter 'isNaN?'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
			header5= 'VARIABLES = "x", "y", "u", "v", "isNaN"';
		end
	else %calibrated
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			if get(handles.export_vort_tec, 'Value') == 1  %alle derivatives exportieren, kalibriert
				header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'isNaN?' delimiter 'vorticity [1/s]' delimiter 'magnitude [m/s]' delimiter 'divergence [1/s]' delimiter 'Q criterion [1/s^2]' delimiter 'simple shear [1/s]' delimiter 'simple strain [1/s]' delimiter 'vector direction [degrees]'];
				header5= 'VARIABLES = "x", "y", "u", "v", "isNaN", "vorticity", "magnitude", "divergence", "Q_criterion", "simple_shear", "simple_strain", "vector_direction"';
			else
				header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/s]' delimiter 'v [m/s]' delimiter 'isNaN?'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
				header5= 'VARIABLES = "x", "y", "u", "v", "isNaN"';
			end
		else
			if get(handles.export_vort_tec, 'Value') == 1  %alle derivatives exportieren, kalibriert
				header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/frame]' delimiter 'v [m/frame]' delimiter 'isNaN?' delimiter 'vorticity [1/frame]' delimiter 'magnitude [m/frame]' delimiter 'divergence [1/frame]' delimiter 'Q criterion [1/frame^2]' delimiter 'simple shear [1/frame]' delimiter 'simple strain [1/frame]' delimiter 'vector direction [degrees]'];
				header5= 'VARIABLES = "x", "y", "u", "v", "isNaN", "vorticity", "magnitude", "divergence", "Q_criterion", "simple_shear", "simple_strain", "vector_direction"';
			else
				header3=['# x [m]' delimiter 'y [m]' delimiter 'u [m/frame]' delimiter 'v [m/frame]' delimiter 'isNaN?'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
				header5= 'VARIABLES = "x", "y", "u", "v", "isNaN"';
			end
		end
	end
	header4 = ['TITLE = "PIVlab frame: ' int2str(currentframe) '"'];
	header6 = ['ZONE I=' int2str(size(x_cal,2)) ', J=' int2str(size(x_cal,1)) ', K=1, F=POINT, T="' int2str(currentframe) '"'];

	fid = fopen(fullfile(PathName,FileName), 'w');
	fprintf(fid, [header1 '\r\n' header2 '\r\n' header3 '\r\n' header4 '\r\n' header5 '\r\n' header6 '\r\n']);
	fclose(fid);

	if get(handles.export_vort_tec, 'Value') == 1 %sollen alle derivatives exportiert werden?
		plot.derivative_calc(currentframe,2,1); %vorticity
		plot.derivative_calc(currentframe,3,1); %magnitude
		%u und v habe ich ja...
		plot.derivative_calc(currentframe,6,1); %divergence
		plot.derivative_calc(currentframe,7,1); %Q crit
		plot.derivative_calc(currentframe,8,1); %shear
		plot.derivative_calc(currentframe,9,1); %strain
		plot.derivative_calc(currentframe,11,1); %vectorangle
		%derivative_calc(currentframe,12,1); %correlation coefficient
		derived=gui.retr('derived');
		vort=derived{2-1,currentframe};
		magn=derived{3-1,currentframe};
		div=derived{6-1,currentframe};
		q_criterion=derived{7-1,currentframe};
		shear=derived{8-1,currentframe};
		strain=derived{9-1,currentframe};
		vectorangle=derived{11-1,currentframe};
		%correlation_map=derived{12-1,currentframe};
		nanmarker=zeros(size(x));
		nanmarker(isnan(u))=1;
		%Nans mit nullen fÃ¼llen
		u(isnan(u))=0;
		v(isnan(v))=0;
		vort(isnan(vort))=0;
		magn(isnan(magn))=0;
		div(isnan(div))=0;
		q_criterion(isnan(q_criterion))=0;
		shear(isnan(shear))=0;
		strain(isnan(strain))=0;
		vectorangle(isnan(vectorangle))=0;
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(nanmarker,size(v,1)*size(v,2),1) reshape(vort,size(vort,1)*size(vort,2),1) reshape(magn,size(magn,1)*size(magn,2),1) reshape(div,size(div,1)*size(div,2),1) reshape(q_criterion,size(q_criterion,1)*size(q_criterion,2),1) reshape(shear,size(shear,1)*size(shear,2),1) reshape(strain,size(strain,1)*size(strain,2),1) reshape(vectorangle,size(vectorangle,1)*size(vectorangle,2),1)];
	else
		nanmarker=zeros(size(x));
		nanmarker(isnan(u))=1;
		u(isnan(u))=0;
		v(isnan(v))=0;
		wholeLOT=[reshape(x_cal,size(x_cal,1)*size(x_cal,2),1) reshape(y_cal,size(y_cal,1)*size(y_cal,2),1) reshape(u*calu-subtract_u,size(u,1)*size(u,2),1) reshape(v*calv-subtract_v,size(v,1)*size(v,2),1) reshape(nanmarker,size(v,1)*size(v,2),1)];
	end
	wholeLOT=sortrows(wholeLOT,2);

	dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc'); %#ok<DLMWT>
end %fÃ¼r mehrere Zones: einfach header6 nochmal appenden, dann whileLOT fÃ¼r den nÃ¤chsten frame berechnen und appenden etc...

