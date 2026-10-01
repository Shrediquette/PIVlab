function api_display_vs_gui(basedir, outdir)
%API_DISPLAY_VS_GUI Draw the display_variants scenario with pivlab.display and compare the
%graphics objects with the GUI reference.
root = fileparts(fileparts(fileparts(mfilename('fullpath')))); % PIVlab folder of this repository
cd(root); addpath(root);
if ~exist(outdir,'dir'), mkdir(outdir); end
B = load(fullfile(basedir,'display_variants.mat'));
files = cell(4,1);
for i = 1:2
    files{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    files{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
rng(1);
m = cell(1,3);
m{1} = {'ROI_object_rectangle',[25+randi(8) 25+randi(8) 40 35]};
m{2} = {'ROI_object_polygon',[120 90;155 95;150 130;115 125]};
m{3} = cell(0);
imgs = pivlab.readImages(files, "pairwise");
imgs = pivlab.preprocess(imgs, 'Roi',[20 20 300 220], 'Mask',m);
res = pivlab.analyze(imgs, 'Passes',2, 'PassSizes',[32 32 32]);
res = pivlab.filter(res, 'StdevThreshold',7, 'LocalMedianThreshold',3);
res = pivlab.derive(res, "vorticity");

common = {'Overlay',"vorticity", 'Colorbar',"none", 'VectorScale',5, 'ShowMask',true, 'Title',""};
V = {
    'default',        {}
    'cmap_hsv',       {'Colormap',"hsv"}
    'cmap_hsb',       {'Colormap',"hsb"}
    'cmap_gray',      {'Colormap',"gray"}
    'cmap_plasma',    {'Colormap',"plasma"}
    'cmap_steps',     {'ColormapSteps',16}
    'opacity50',      {'Alpha',0.5}
    'cbar_south',     {'Colorbar',"south"}
    'cbar_north',     {'Colorbar',"north"}
    'cbar_west',      {'Colorbar',"west"}
    'bg_black',       {'Background',"black"}
    'bg_white',       {'Background',"white"}
    'enhance',        {'EnhanceImage',true}
    'manual_scale',   {'ColorLimits',[-0.5 0.5]}
    'nth2',           {'VectorSkip',2}
    'vecwidth',       {'VectorWidth',2}
    'uniform',        {'UniformLength',true}
    'power',          {'PowerScale',0.5}
    'derivcolor',     {'VectorColor',"orange"}
    'refvec',         {'ReferenceVector',"top left"}
    'maskpreview',    {'ShowMask',true}
    };
allok = true;
fig = figure('Units','pixels','Position',[20 40 1600 1000]);
for k = 1:size(V,1)
    clf(fig); ax = axes(fig);
    args = [common V{k,2}];
    pivlab.display(res, args{:}, 'Parent',ax);
    drawnow;
    A = axis_snapshot(ax);
    ok = compare_snap(V{k,1}, A, B.ax.(V{k,1}));
    allok = allok && ok;
    exportgraphics(ax, fullfile(outdir, ['api_' V{k,1} '.png']));
end
% vectors only, colours
cv = {'vec_color1', {'VectorColor',"green"}; 'vec_color2', {'VectorColor',"cyan"}; 'vec_color11', {'VectorColor',"magnitude"}; ...
      'vec_magnitude_cbar', {'VectorColor',"magnitude", 'Colorbar',"east"}};
for k = 1:size(cv,1)
    if ~isfield(B.ax, cv{k,1}), fprintf('  (no GUI reference %s)\n', cv{k,1}); continue; end
    clf(fig); ax = axes(fig);
    args = [{'Colorbar',"none", 'VectorScale',5, 'ShowMask',true, 'Title',""} cv{k,2}];
    pivlab.display(res, args{:}, 'Parent',ax);
    drawnow;
    A = axis_snapshot(ax);
    ok = compare_snap(cv{k,1}, A, B.ax.(cv{k,1}));
    allok = allok && ok;
    exportgraphics(ax, fullfile(outdir, ['api_' cv{k,1} '.png']));
end
if allok
    fprintf('API_DISPLAY_VS_GUI: ALL IDENTICAL\n');
else
    fprintf('API_DISPLAY_VS_GUI: DIFFERENCES FOUND\n');
end
end

function ok = compare_snap(name, A, G)
ca = relevant(A.children); cg = relevant(G.children);
ok = true;
msgs = {};
if numel(ca) ~= numel(cg)
    ok = false;
    msgs{end+1} = sprintf('%d vs %d objects (API: %s | GUI: %s)', numel(ca), numel(cg), types(ca), types(cg));
else
    for i = 1:numel(ca)
        f = intersect(fieldnames(ca{i}), {'Type','CData','AlphaData','XData','YData','UData','VData','Color','LineWidth','String','Position','Tag'});
        for j = 1:numel(f)
            if ~isequaln(ca{i}.(f{j}), cg{i}.(f{j}))
                ok = false;
                msgs{end+1} = sprintf('object %d (%s) %s differs', i, ca{i}.Type, f{j}); %#ok<AGROW>
            end
        end
    end
end
for f = {'CLim','fig_colormap','ax_colormap'}
    if ~isequaln(A.(f{1}), G.(f{1}))
        ok = false; msgs{end+1} = [f{1} ' differs']; %#ok<AGROW>
    end
end
cba = A.colorbars; cbg = G.colorbars;
if numel(cba) ~= numel(cbg)
    ok = false; msgs{end+1} = sprintf('%d vs %d colorbars', numel(cba), numel(cbg));
else
    for i = 1:numel(cba)
        for f = {'Location','Ticks','TickLabels','Label','Limits'}
            if ~isequaln(cba{i}.(f{1}), cbg{i}.(f{1}))
                ok = false; msgs{end+1} = ['colorbar ' f{1} ' differs']; %#ok<AGROW>
            end
        end
    end
end
if ok
    fprintf('  same  %s\n', name);
else
    fprintf('  DIFF  %s: %s\n', name, strjoin(msgs, '; '));
end
end

function c = relevant(ch)
% graphics objects that both the GUI and the API draw (not the GUI-only interactive objects)
keep = false(size(ch));
for i = 1:numel(ch)
    t = ch{i}.Type;
    tag = '';
    if isfield(ch{i},'Tag'), tag = ch{i}.Tag; end
    keep(i) = any(strcmp(t, {'image','quiver','scatter','line','rectangle','text'})) && ~strcmp(tag,'derivhint');
end
c = ch(keep);
end

function s = types(c)
s = strjoin(cellfun(@(x) x.Type, c, 'UniformOutput', false), ',');
end

function G = axis_snapshot(ax)
fig = ancestor(ax,'figure');
G = struct();
G.XLim = get(ax,'XLim'); G.YLim = get(ax,'YLim'); G.CLim = get(ax,'CLim');
G.ax_colormap = colormap(ax); G.fig_colormap = get(fig,'Colormap');
ch = allchild(ax);
items = cell(numel(ch),1);
props = {'CData','AlphaData','AlphaDataMapping','CDataMapping','XData','YData','ZData','UData','VData','Color', ...
    'LineWidth','Marker','MarkerSize','String','Position','Tag','Visible','FaceColor','EdgeColor','LineStyle','FontSize','BackgroundColor'};
for k = 1:numel(ch)
    it = struct('Type',get(ch(k),'Type'));
    for p = props
        if isprop(ch(k),p{1})
            v = get(ch(k),p{1});
            if isa(v,'matlab.lang.OnOffSwitchState'), v = char(v); end
            it.(p{1}) = v;
        end
    end
    items{k} = it;
end
G.children = items;
cb = findall(fig,'Type','colorbar');
cbs = cell(numel(cb),1);
for k = 1:numel(cb)
    cbs{k} = struct('Location',cb(k).Location,'Ticks',cb(k).Ticks,'TickLabels',{cb(k).TickLabels}, ...
        'Label',cb(k).Label.String,'Limits',cb(k).Limits,'Tag',cb(k).Tag,'Colormap',colormap(cb(k)));
end
G.colorbars = cbs;
end



