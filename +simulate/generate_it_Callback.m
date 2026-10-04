function generate_it_Callback(~, ~, ~)
handles=gui.gethand;
num = @(h) str2double(get(h,'string'));
sizex = num(handles.img_sizex);
sizey = num(handles.img_sizey);
p.imageSize = [sizey sizex];
switch get(handles.flow_sim,'value')
	case 1
		type = 'rankine';
		p.v0 = num(handles.rank_displ);
		p.R0 = num(handles.rank_core);
		p.c1 = [num(handles.rankx1) num(handles.ranky1)];
		p.c2 = [num(handles.rankx2) num(handles.ranky2)];
		p.double = get(handles.singledoublerankine,'value') == 2;
	case 2
		type = 'oseen';
		p.v0 = num(handles.oseen_displ);
		p.t = num(handles.oseen_time);
		p.c1 = [num(handles.oseenx1) num(handles.oseeny1)];
		p.c2 = [num(handles.oseenx2) num(handles.oseeny2)];
		p.double = get(handles.singledoubleoseen,'value') == 2;
	case 3
		type = 'shift';
		p.shift = num(handles.shiftdisplacement);
	case 4
		type = 'rotation';
		p.rotation = num(handles.rotationdislacement);
	case 5
		type = 'membrane';
end
%% Create particle images
set(handles.status_creation,'string','Calculating particles...');drawnow;
[gen_image_1, gen_image_2] = simulate.gui_images([sizey sizex], @(x,y,z) simulate.flow_field(type, x, y, p), ...
	Particles=num(handles.part_am), SheetThickness=num(handles.sheetthick), OutOfPlane=num(handles.part_z), ...
	Diameter=num(handles.part_size), DiameterVariation=num(handles.part_var), Noise=num(handles.part_noise));
[x,y] = meshgrid(1:sizex, 1:sizey);
[real_displ_u, real_displ_v] = simulate.flow_field(type, x, y, p);

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
gui.put('gen_image_1',gen_image_1);
gui.put('gen_image_2',gen_image_2);
gui.put('real_displ_u',real_displ_u);
gui.put('real_displ_v',real_displ_v);
end
