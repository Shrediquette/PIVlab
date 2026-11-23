function file_save (currentframe,FileName,PathName,type)
% Writes the vector data of one frame: type 1 = ASCII, 3 = ParaView binary vtk, 4 = Tecplot.
handles=gui.gethand;
resultslist=gui.retr('resultslist');
filename=gui.retr('filename');
calu=gui.retr('calu');
calxy=gui.retr('calxy');
[fac, statistic]=gui.frame_factors(currentframe); %velocity, or standard deviation / TKE of temporal statistics
units=export.unit_texts(calu, calxy, gui.retr('displacement_only'), statistic); %unit texts of the headers
[x,y,u,v,typevector,w]=plot.get_desired_u_and_v(resultslist,2*currentframe-1); %smoothed, else filtered, else original (w: stereo-PIV, else empty)
[x_cal,y_cal]=calibrate.xy (x,y);
u(typevector==0)=NaN;
v(typevector==0)=NaN;
if ~isempty(w)
	w(typevector==0)=NaN;
	w_cal=w*fac.w; %w is positive along z = x cross y
end
subtract_u=gui.retr('subtr_u');
subtract_v=gui.retr('subtr_v');
file=fullfile(PathName,FileName);
frame_info=['FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> ' units.length '): ' num2str(calxy) ', conversion factor uv (px/frame -> ' units.velocity '): ' num2str(calu)];

if type==1 %ascii file
	delimiters={',','\t',' '};
	delimiter=delimiters{get(handles.delimiter, 'value')};
	with_derivatives=get(handles.export_vort, 'Value') == 1;
	headers={};
	if get(handles.addfileinfo, 'value')==1
		headers={['PIVlab, ASCII chart output - ' char(datetime('today'))], frame_info};
	end
	if get(handles.add_header, 'value')==1
		headers{end+1}=column_header(units, delimiter, 'Vector type [-]', with_derivatives, ~isempty(w));
	end
	fid = fopen(file, 'w'); %always a new file (also without headers): the data is appended below
	for k=1:numel(headers)
		fprintf(fid, [headers{k} '\r\n']); %the header is the format: '\t' becomes a tab
	end
	fclose(fid);
	us=u*fac.u-subtract_u;
	vs=v*fac.v-subtract_v;
	if isempty(w)
		wholeLOT=[x_cal(:) y_cal(:) us(:) vs(:) typevector(:)];
	else
		wholeLOT=[x_cal(:) y_cal(:) us(:) vs(:) w_cal(:) typevector(:)]; %x y u v w type ...
	end
	if with_derivatives
		wholeLOT=[wholeLOT derived_columns(currentframe, size(u))];
	end
	dlmwrite(file, wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc'); %#ok<DLMWT>
end %type==1

if type==3 %paraview vtk, without the derived parameters (ParaView computes them itself)
	u=u*fac.u-subtract_u;
	v=v*fac.v-subtract_v;
	nr_of_elements=numel(x_cal);
	fid = fopen(file, 'w');
	%ASCII file header
	fprintf(fid, '# vtk DataFile Version 3.0\n');
	fprintf(fid, ['VTK from PIVlab [' units.value ']\n']);
	fprintf(fid, 'BINARY\n\n');
	fprintf(fid, 'DATASET STRUCTURED_GRID\n');
	fprintf(fid, ['DIMENSIONS ' num2str(size(x_cal,1)) ' ' num2str(size(x_cal,2)) ' ' num2str(size(x_cal,3)) '\n']);
	fprintf(fid, ['POINTS ' num2str(nr_of_elements) ' float\n']);
	%binary x,y,z data
	fwrite(fid, [x_cal(:).';  y_cal(:).'; y_cal(:).'*0],'float','b');
	%ASCII sub header
	fprintf(fid, ['\nPOINT_DATA ' num2str(nr_of_elements) '\n']);
	fprintf(fid, 'VECTORS velocity_vectors float\n');
	%binary u,v,w data
	if isempty(w)
		w_vtk=v(:).'*0; %2D: zero (NaN where v is NaN, as always)
	else
		w_vtk=w_cal(:).'; %stereo-PIV: the out-of-plane component
	end
	fwrite(fid, [u(:).';  v(:).'; w_vtk],'float','b');
	corr_map_raw=result_row(resultslist,12,currentframe);
	if ~isempty(corr_map_raw)
		fprintf(fid,'\nSCALARS correlation_map float 1\n');
		fprintf(fid,'LOOKUP_TABLE default\n');
		fwrite(fid,reshape(corr_map_raw,1,nr_of_elements),'float','b');
	end
	unc_map_raw=result_row(resultslist,15,currentframe);
	if ~isempty(unc_map_raw)
		fprintf(fid,'\nSCALARS uncertainty_map float 1\n');
		fprintf(fid,'LOOKUP_TABLE default\n');
		fwrite(fid,reshape(single(unc_map_raw)*abs(single(calu)),1,nr_of_elements),'float','b');
	end
	fclose(fid);
end %type3

if type==4 %tecplot file (several zones: append header6 again, then the data of the next frame)
	delimiter = ' ';
	with_derivatives=get(handles.export_vort_tec, 'Value') == 1;
	variables={'x','y','u','v'};
	if ~isempty(w)
		variables{end+1}='w'; %stereo-PIV: w right after v
	end
	variables{end+1}='isNaN';
	if with_derivatives
		variables=[variables {'vorticity','magnitude','divergence','Q_criterion','shear_rate','simple_strain','vector_direction','correlation_map','uncertainty_map'}];
	end
	header1=['# PIVlab by W.Th. & E.J.S., TECPLOT output - ' char(datetime('today'))];
	header2=['# ' frame_info];
	header3=['# ' column_header(units, delimiter, 'isNaN?', with_derivatives, ~isempty(w))];
	header4=['TITLE = "PIVlab frame: ' int2str(currentframe) '"'];
	header5=['VARIABLES = ' strjoin(strcat('"', variables, '"'), ', ')];
	header6=['ZONE I=' int2str(size(x_cal,2)) ', J=' int2str(size(x_cal,1)) ', K=1, F=POINT, T="' int2str(currentframe) '"'];
	fid = fopen(file, 'w');
	fprintf(fid, [header1 '\r\n' header2 '\r\n' header3 '\r\n' header4 '\r\n' header5 '\r\n' header6 '\r\n']);
	fclose(fid);

	nanmarker=zeros(size(x));
	nanmarker(isnan(u))=1;
	u(isnan(u))=0; %before the calibration: a missing vector is written as -subtract_u
	v(isnan(v))=0;
	us=u*fac.u-subtract_u;
	vs=v*fac.v-subtract_v;
	if isempty(w)
		wholeLOT=[x_cal(:) y_cal(:) us(:) vs(:) nanmarker(:)];
	else
		w_tec=w_cal;
		w_tec(isnan(w_tec))=0;
		wholeLOT=[x_cal(:) y_cal(:) us(:) vs(:) w_tec(:) nanmarker(:)]; %x y u v w isNaN ...
	end
	if with_derivatives
		D=derived_columns(currentframe, size(u));
		D(isnan(D))=0;
		wholeLOT=[wholeLOT D];
	end
	wholeLOT=sortrows(wholeLOT,2);
	dlmwrite(file, wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc'); %#ok<DLMWT>
end

function D=derived_columns(frame, grid_size)
%The derived parameters of the ASCII and Tecplot exports as columns: vorticity, magnitude,
%divergence, Q criterion, shear rate, simple strain, vector direction, correlation coefficient,
%uncertainty (NaN where a map does not exist).
ids=[2 3 6 7 8 9 11 12 13];
derived=export.derive_frame(frame, ids);
D=cell(1,numel(ids));
for k=1:numel(ids)
	map=derived{ids(k)-1,frame};
	if isempty(map) %correlation or uncertainty map not calculated
		map=NaN(grid_size);
	end
	D{k}=map(:);
end
D=[D{:}];

function header=column_header(units, delimiter, type_column, with_derivatives, with_w)
%Column names of the ASCII and Tecplot exports (x y u v [w] type [derivatives]).
L=units.length; V=units.value; T=units.time;
header=['x [' L ']' delimiter 'y [' L ']' delimiter 'u [' V ']' delimiter 'v [' V ']'];
if with_w
	header=[header delimiter 'w [' V ']']; %stereo-PIV: in the unit of v
end
header=[header delimiter type_column];
if with_derivatives
	header=[header delimiter 'vorticity [1/' T ']' delimiter 'magnitude [' V ']' delimiter 'divergence [1/' T ']' delimiter 'Q criterion [1/' T '^2]' delimiter 'shear rate (magnitude of the rate-of-strain tensor) [1/' T ']' delimiter 'simple strain [1/' T ']' delimiter 'vector direction [degrees]' delimiter 'correlation coefficient [-]' delimiter 'uncertainty [' units.velocity ']'];
end

function data=result_row(resultslist, row, frame)
%resultslist{row,frame}, or [] if the result list has no such row
if size(resultslist,1) >= row
	data=resultslist{row,frame};
else
	data=[];
end
