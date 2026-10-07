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
%% Displacement of every pixel
[x,y] = meshgrid(1:sizex, 1:sizey);
[real_displ_u, real_displ_v] = simulate.flow_field(flow, x, y);
%% Create particle images
set(handles.status_creation,'string','Calculating particles...');drawnow;
[gen_image_1, gen_image_2] = simulate.gui_images(x, y, real_displ_u, real_displ_v, ...
	Particles=str2double(get(handles.part_am,'string')), ...
	SheetThickness=str2double(get(handles.sheetthick,'string')), ...
	OutOfPlane=str2double(get(handles.part_z,'string')), ...
	Diameter=str2double(get(handles.part_size,'string')), ...
	DiameterVariation=str2double(get(handles.part_var,'string')), ...
	Noise=str2double(get(handles.part_noise,'string')));

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
gui.put('gen_image_1',gen_image_1);
gui.put('gen_image_2',gen_image_2);
gui.put('real_displ_u',real_displ_u);
gui.put('real_displ_v',real_displ_v);
end
