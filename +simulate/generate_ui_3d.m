function generate_ui_3d(MainWindow, default, margin, panelwidth, panelheightpanels, Figure_Size)
% Panel "3D particle image generator" (multip31) of the PIVlab window, called by gui.generateUI.
% Every edit field and popup menu is a setting (group tools of gui.default_settings).
t = default.tools;
P = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels], ...
    'title','3D particle image generator', 'Tag','multip31','fontweight','bold');
pp = get(P, 'Position');
w = pp(3);
pos = @(parent, x, y, width, height) [x+margin parent(4)-height-margin-y width-margin*2 height];
cb = @simulate.setting_3d_Callback;

uicontrol(P,'Style','text','String','Settings:','Units','characters','HorizontalAlignment','left','Position',pos(pp,0,0,w/3,1.5));
uicontrol(P,'Style','popupmenu','String',{'Cameras, lens and light sheet','Flow, particles and output'},'Units','characters', ...
    'Position',pos(pp,w/3,0,w*2/3,1.5),'Tag','sim3d_page','Callback',cb,'UserData','not_a_setting', ...
    'TooltipString','The settings are on two pages');

%% page 1: cameras, lens, light sheet
y_page = 1.5 + margin/2;
h_page = 27;
page1 = uipanel(P,'Units','characters','Position',pos(pp,0,y_page,w,h_page),'BorderType','none','Tag','sim3d_page1');
p1 = get(page1,'Position');
p1(1:2) = 0;

cams = uipanel(page1,'Units','characters','Position',pos(p1,-margin,0,w,16),'title','Cameras','fontweight','bold');
pc = get(cams,'Position');
wc = pc(3);
y = 0;
uicontrol(cams,'Style','text','String','Cameras:','Units','characters','HorizontalAlignment','left','Position',pos(pc,0,y,wc*0.4,1.5));
uicontrol(cams,'Style','popupmenu','String',{'1 camera','2 cameras (stereo)'},'Value',t.sim3d_ncams,'Units','characters', ...
    'Position',pos(pc,wc*0.4,y,wc*0.6,1.5),'Tag','sim3d_ncams','Callback',cb,'TooltipString','One camera (e.g. to test the rectification) or two cameras (stereo-PIV)');
y = y + 1.5 + margin/4;
row_edits(cams, pc, y, 'Sensor size [px]:', {'sim3d_sizex','sim3d_sizey'}, [t.sim3d_sizex t.sim3d_sizey], ...
    {'Image width in pixels','Image height in pixels'});
y = y + 1;
row_edits(cams, pc, y, 'Pixel size [µm]:', {'sim3d_pitch'}, t.sim3d_pitch, {'Size of a sensor pixel (pixel pitch)'});
y = y + 1;
row_edits(cams, pc, y, 'Lens focal length [mm]:', {'sim3d_focal'}, t.sim3d_focal, {'Focal length of the lens of both cameras'});
y = y + 1 + margin/4;
uicontrol(cams,'Style','text','String','Camera 1','Units','characters','HorizontalAlignment','center','Position',pos(pc,wc*0.4,y,wc*0.3,1),'ForegroundColor',stereo.camera_colors(1));
uicontrol(cams,'Style','text','String','Camera 2','Units','characters','HorizontalAlignment','center','Position',pos(pc,wc*0.7,y,wc*0.3,1),'ForegroundColor',stereo.camera_colors(2),'Tag','sim3d_cam2_title');
y = y + 1;
pos_tip = 'Position of the camera in board coordinates [mm]: origin = first inner corner of the board, x right, y down, z into the board (the cameras are usually at z < 0). Drag the camera in the 3D preview to move it.';
aim_tip = 'Point on the board (z = 0) that the camera looks at [mm]. Drag the diamond in the 3D preview to move it.';
dist_tip = 'Radial lens distortion (MATLAB / OpenCV model, normalized image coordinates): k1 < 0 barrel, k1 > 0 pincushion, 0 = none. The 3D preview shows the resulting distortion in pixels at the image corners.';
labels = {'Position x [mm]:','Position y [mm]:','Position z [mm]:','Aim at x [mm]:','Aim at y [mm]:','Distortion k1:','Distortion k2:'};
fields = {'x','y','z','ax','ay','k1','k2'};
tips = {pos_tip,pos_tip,pos_tip,aim_tip,aim_tip,dist_tip,dist_tip};
for r = 1:numel(fields)
    tags = {['sim3d_c1' fields{r}], ['sim3d_c2' fields{r}]};
    row_edits(cams, pc, y, labels{r}, tags, [t.(tags{1}) t.(tags{2})], tips([r r]));
    y = y + 1;
end

sheet = uipanel(page1,'Units','characters','Position',pos(p1,-margin,16+margin/4,w,7),'title','Light sheet (relative to the board)','fontweight','bold');
ps = get(sheet,'Position');
y = 0;
row_edits(sheet, ps, y, 'Offset from the board [mm]:', {'sim3d_sheet_offset'}, t.sim3d_sheet_offset, ...
    {'Distance of the light sheet centre plane from the board at the aim points, positive towards camera 1. The stereo calibration uses the board, the disparity correction has to find this offset.'});
y = y + 1;
row_edits(sheet, ps, y, 'Rotation about x [°]:', {'sim3d_sheet_tiltx'}, t.sim3d_sheet_tiltx, {'Rotation of the light sheet against the board about the board x axis'});
y = y + 1;
row_edits(sheet, ps, y, 'Rotation about y [°]:', {'sim3d_sheet_tilty'}, t.sim3d_sheet_tilty, {'Rotation of the light sheet against the board about the board y axis'});
y = y + 1;
row_edits(sheet, ps, y, 'Thickness [mm]:', {'sim3d_sheet_thick'}, t.sim3d_sheet_thick, {'Thickness of the light sheet (e^-2 intensity)'});

uicontrol(page1,'Style','text','String','Board: N/A','Units','characters','HorizontalAlignment','left', ...
    'Position',pos(p1,-margin,23+margin/2,w,3),'Tag','sim3d_boardinfo', ...
    'TooltipString','The ChArUco board of "Image settings -> Camera calibration -> Setup / define / generate marker board"');

%% page 2: flow, particles, output
page2 = uipanel(P,'Units','characters','Position',pos(pp,0,y_page,w,h_page),'BorderType','none','Tag','sim3d_page2','Visible','off');
p2 = get(page2,'Position');
p2(1:2) = 0;
[~, flow_labels] = simulate.flow_types_3d;
flow = uipanel(page2,'Units','characters','Position',pos(p2,-margin,0,w,7.5),'title','Flow','fontweight','bold');
pf = get(flow,'Position');
uicontrol(flow,'Style','popupmenu','String',flow_labels,'Value',t.sim3d_flow,'Units','characters','Position',pos(pf,0,0,pf(3),1.5), ...
    'Tag','sim3d_flow','Callback',cb,'TooltipString',['Flow in the light sheet, centred in the overlap of the camera views. ' ...
    'The same flow is used for all image pairs, except for the sphere wake: a 3D flow simulation (takes about a minute), ' ...
    'every image pair is a later moment of the flow.']);
y = 1.5 + margin/4;
row_edits(flow, pf, y, 'In-plane displacement [mm]:', {'sim3d_displ'}, t.sim3d_displ, ...
    {'Maximum in-plane displacement between image A and B (sphere wake: displacement of the free stream)'}, 'sim3d_displ_text');
y = y + 1;
row_edits(flow, pf, y, 'Vortex core radius [mm]:', {'sim3d_radius'}, t.sim3d_radius, {'Radius of the vortex core (and of the jet)'}, 'sim3d_radius_text');
overlay_edit(flow, pf, y, 'sim3d_sphere_d', t.sim3d_sphere_d, ['Diameter of the sphere. Its centre is in the light sheet, ' ...
    'near the left edge of the camera views; the flow goes from left to right (+x).']);
y = y + 1;
row_edits(flow, pf, y, 'Out-of-plane displacement [mm]:', {'sim3d_w'}, t.sim3d_w, ...
    {'Displacement perpendicular to the light sheet: peak of the jet in the vortex core, or constant for the other flows'}, 'sim3d_w_text');
overlay_edit(flow, pf, y, 'sim3d_sphere_dt', t.sim3d_sphere_dt, ['Time between two image pairs in D/U: the free stream ' ...
    'travels this many sphere diameters. A vortex is shed about every 5 D/U: 0.25 gives a time-resolved series, ' ...
    '5 or more nearly independent snapshots (longer computation).']);

part = uipanel(page2,'Units','characters','Position',pos(p2,-margin,7.5+margin/4,w,6.5),'title','Particles','fontweight','bold');
pq = get(part,'Position');
y = 0;
row_edits(part, pq, y, 'Particles per pixel:', {'sim3d_ppp'}, t.sim3d_ppp, {'Particle image density (particles per pixel, ppp) in each camera image'});
y = y + 1;
row_edits(part, pq, y, 'Particle diameter [px]:', {'sim3d_psize'}, t.sim3d_psize, {'Mean particle image diameter'});
y = y + 1;
row_edits(part, pq, y, 'Random size [px]:', {'sim3d_pvar'}, t.sim3d_pvar, {'Particle image diameter variation'});
y = y + 1;
row_edits(part, pq, y, 'Noise:', {'sim3d_noise'}, t.sim3d_noise, {'Simulated image sensor noise (variance of Gaussian noise)'});

out = uipanel(page2,'Units','characters','Position',pos(p2,-margin,14+margin/2,w,4.5),'title','Output','fontweight','bold');
po = get(out,'Position');
row_edits(out, po, 0, 'Image pairs per camera:', {'sim3d_pairs'}, t.sim3d_pairs, {'Number of particle image pairs of each camera'});
row_edits(out, po, 1, 'Calibration images:', {'sim3d_ncalib'}, t.sim3d_ncalib, {'Images of the board in random positions per camera, for the lens calibration'});

uicontrol(page2,'Style','text','Units','characters','HorizontalAlignment','left','Position',pos(p2,-margin,19+margin,w,7), ...
    'String',['Per camera: particle image pairs, calibration images, the board in the light sheet and the true lens. ' ...
    'Plus ground_truth.mat (U, V, W) and README.txt.']);

%% always visible
y = y_page + h_page + margin/2;
uicontrol(P,'Style','pushbutton','String','Show 3D preview','Units','characters','Position',pos(pp,0,y,w,1.5), ...
    'Callback',@simulate.preview_3d_Callback,'Tag','sim3d_preview', ...
    'TooltipString','Board, light sheet and cameras in 3D, and what the cameras see. Move the cameras with the mouse.');
y = y + 1.5 + margin/4;
uicontrol(P,'Style','pushbutton','String','Generate images...','Units','characters','Position',pos(pp,0,y,w,1.5), ...
    'Callback',@simulate.generate_3d_Callback,'Tag','sim3d_generate', ...
    'TooltipString','Select an output folder and generate all images and the ground truth');
y = y + 1.5 + margin/4;
uicontrol(P,'Style','text','String','','Units','characters','HorizontalAlignment','left','Position',pos(pp,0,y,w,6),'Tag','sim3d_status');
end

function overlay_edit(parent, pp, y, tag, value, tip)
% an edit field at the place of the edit field of a row (only one of the two is visible,
% depending on the flow type: gui.update_dependent_controls)
w = pp(3);
margin = gui.retr('margin');
uicontrol(parent,'Style','edit','String',gui.setting_text(value),'Units','characters', ...
    'Position',[w*2/3+margin pp(4)-1-margin-y w/3-margin*2 1],'Tag',tag,'Callback',@simulate.setting_3d_Callback, ...
    'TooltipString',tip,'Visible','off');
end

function row_edits(parent, pp, y, label, tags, values, tips, label_tag)
% a text and one or two edit fields (columns of camera 1 and camera 2)
w = pp(3);
margin = gui.retr('margin');
pos = @(x, width) [x+margin pp(4)-1-margin-y width-margin*2 1];
args = {};
if nargin >= 8
    args = {'Tag', label_tag};
end
if isscalar(tags)
    uicontrol(parent,'Style','text','String',label,'Units','characters','HorizontalAlignment','left','Position',pos(0,w*2/3),args{:});
    uicontrol(parent,'Style','edit','String',gui.setting_text(values(1)),'Units','characters','Position',pos(w*2/3,w/3), ...
        'Tag',tags{1},'Callback',@simulate.setting_3d_Callback,'TooltipString',tips{1});
    return
end
uicontrol(parent,'Style','text','String',label,'Units','characters','HorizontalAlignment','left','Position',pos(0,w*0.4),args{:});
for k = 1:2
    uicontrol(parent,'Style','edit','String',gui.setting_text(values(k)),'Units','characters','Position',pos(w*(0.1+0.3*k),w*0.3), ...
        'Tag',tags{k},'Callback',@simulate.setting_3d_Callback,'TooltipString',tips{k});
end
end
