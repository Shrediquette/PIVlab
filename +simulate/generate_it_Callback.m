function generate_it_Callback(~, ~, ~)
handles=gui.gethand;
sizex = str2double(get(handles.img_sizex,'string'));
sizey = str2double(get(handles.img_sizey,'string'));
flow.imageSize = [sizey sizex];
switch get(handles.flow_sim,'value')
	case 1
		flow.type = 'rankine';
		flow.v0 = str2double(get(handles.rank_displ,'string'));
		flow.R0 = str2double(get(handles.rank_core,'string'));
		flow.c1 = [str2double(get(handles.rankx1,'string')) str2double(get(handles.ranky1,'string'))];
		flow.c2 = [str2double(get(handles.rankx2,'string')) str2double(get(handles.ranky2,'string'))];
		flow.double = get(handles.singledoublerankine,'value') == 2;
	case 2
		flow.type = 'oseen';
		flow.v0 = str2double(get(handles.oseen_displ,'string'));
		flow.t = str2double(get(handles.oseen_time,'string'));
		flow.c1 = [str2double(get(handles.oseenx1,'string')) str2double(get(handles.oseeny1,'string'))];
		flow.c2 = [str2double(get(handles.oseenx2,'string')) str2double(get(handles.oseeny2,'string'))];
		flow.double = get(handles.singledoubleoseen,'value') == 2;
	case 3
		flow.type = 'shift';
		flow.shift = str2double(get(handles.shiftdisplacement,'string'));
	case 4
		flow.type = 'rotation';
		flow.rotation = str2double(get(handles.rotation_displacement,'string'));
	case 5
		flow.type = 'membrane';
end
%% Check the inputs: empty or wrong text gives NaN (crashed deep inside the generator)
particles = str2double(get(handles.part_am,'string'));
sheetthick = str2double(get(handles.sheetthick,'string'));
part_z = str2double(get(handles.part_z,'string'));
part_size = str2double(get(handles.part_size,'string'));
part_var = str2double(get(handles.part_var,'string'));
part_noise = str2double(get(handles.part_noise,'string'));
names = {'Image width','Image height','Number of particles','Sheet thickness','Particle diameter'};
values = [sizex sizey particles sheetthick part_size];
mess = {};
for i = 1:numel(values)
	if ~isfinite(values(i)) || values(i) <= 0
		mess{end+1} = [names{i} ' must be a number > 0']; %#ok<AGROW>
	end
end
if ~all(isfinite([part_z part_var part_noise]))
	mess{end+1} = 'Out-of-plane motion, diameter variation and noise must be numbers';
end
fields = fieldnames(flow);
for i = 1:numel(fields)
	v = flow.(fields{i});
	if isnumeric(v) && ~all(isfinite(v))
		mess{end+1} = 'The flow parameters must be numbers'; %#ok<AGROW>
		break
	end
end
if ~isempty(mess)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Particle image generator',mess,'modal');
	return
end
sizex = round(sizex);
sizey = round(sizey);
flow.imageSize = [sizey sizex];
%% Displacement of every pixel
[x,y] = meshgrid(1:sizex, 1:sizey);
[real_displ_u, real_displ_v] = simulate.flow_field(flow, x, y);
%% Create particle images
set(handles.status_creation,'string','Calculating particles...');drawnow;
[gen_image_1, gen_image_2] = simulate.gui_images(x, y, real_displ_u, real_displ_v, ...
	Particles=particles, SheetThickness=sheetthick, OutOfPlane=part_z, Diameter=part_size, ...
	DiameterVariation=part_var, Noise=part_noise);

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
gui.put('gen_image_1',gen_image_1);
gui.put('gen_image_2',gen_image_2);
gui.put('real_displ_u',real_displ_u);
gui.put('real_displ_v',real_displ_v);
end
