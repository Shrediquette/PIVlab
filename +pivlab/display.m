function [fig, ax] = display(res, opts)
%DISPLAY Show a PIV result like the PIVlab GUI: vectors on the particle image or on a colour map.
%   fig = pivlab.display(res) shows the vectors of the first frame on the particle image.
%   fig = pivlab.display(res, Overlay="vorticity") shows the vorticity as a transparent colour
%   map below the vectors, with a colour bar. The map is computed with pivlab.derive if res does
%   not contain it yet (see res.derived).
%
%   Name=value options (defaults like in PIVlab)
%   Frame              frame (image pair) to show, default 1
%   Overlay            "none" or a quantity of pivlab.derive ("vorticity", "magnitude", "u", "v",
%                      "divergence", "qcriterion", "shear", "strain", "direction", "lic",
%                      "correlation", "uncertainty")
%   Background         "image" (particle image, as in PIVlab), "preprocessed" (as used for the
%                      analysis), "black" or "white"
%   EnhanceImage       true/false, contrast stretch of the particle image
%   Colormap           "parula", "hsv", "jet", "hsb", "hot", "cool", "spring", "summer", "autumn",
%                      "winter", "gray", "bone", "copper", "pink", "lines", "plasma"
%   ColormapSteps      number of colours (256, 128, 64, 32, 16, 8, 4, 2)
%   Alpha              opacity of the colour map, 0...1 (default 0.75)
%   ColorLimits        [min max] of the colour map, default: automatic
%   MapInterpolation   "bilinear", "bicubic" or "nearest"
%   ExtrapolateBorder  true/false, extend the colour map to the image border
%   Colorbar           "east" (default), "west", "north", "south" or "none"
%   ColorbarFormat     "compact", "scientific" or "fixed"
%   Vectors            true/false, draw the vectors
%   VectorColor        colour name ("green", "black", ...), RGB triple, or "magnitude"
%                      default: green on the image, black on a colour map
%   InterpolatedColor, SecondPeakColor   colours of interpolated / second-peak vectors
%   VectorScale        "auto" or a factor for the vector length
%   VectorSkip         draw every n-th vector
%   VectorWidth        line width
%   UniformLength      true: all vectors have the same length (direction only)
%   PowerScale         exponent < 1 to compress the vector lengths (e.g. 0.3), [] = off
%   ReferenceVector    "off", "top left", "top right", "bottom left", "bottom right"
%   ReferenceLength    length of the reference vector (in res.units)
%   Subtract           [u v] subtracted from the vectors (e.g. the mean flow, in res.units)
%   ShowMask           true: masked areas in red      MaskTransparency  in percent (default 50)
%   ShowROI            true: draw the region of interest
%   Title              title text, default: the frame name ("" for none)
%   Parent             axes to draw into (default: new figure)
%   Settings           settings struct (uses s.display)
%
%   [fig, ax] = pivlab.display(...) also returns the axes.
%
%   Example
%       pivlab.display(res, Frame=2, Overlay="vorticity", Colormap="jet", VectorSkip=2);
%       exportgraphics(gca, "vorticity.png", Resolution=300)
%
%   See also pivlab.derive, pivlab.temporal
arguments
    res (1,1) struct
    opts.Frame (1,1) {mustBeInteger, mustBePositive} = 1
    opts.Overlay (1,1) string = "none"
    opts.Background (1,1) string {mustBeMember(opts.Background,["image","preprocessed","black","white","raw"])} = "image"
    opts.EnhanceImage = []
    opts.Colormap = []
    opts.ColormapSteps = []
    opts.Alpha (1,1) double = 0.75
    opts.ColorLimits = []
    opts.MapInterpolation = []
    opts.ExtrapolateBorder (1,1) logical = false
    opts.Colorbar (1,1) string = "east"
    opts.ColorbarFormat (1,1) string {mustBeMember(opts.ColorbarFormat,["compact","scientific","fixed"])} = "compact"
    opts.Vectors (1,1) logical = true
    opts.VectorColor = []
    opts.InterpolatedColor = "orange"
    opts.SecondPeakColor = "cyan"
    opts.VectorScale = []
    opts.VectorSkip = []
    opts.VectorWidth (1,1) double = 0.5
    opts.UniformLength (1,1) logical = false
    opts.PowerScale = []
    opts.ReferenceVector (1,1) string = "off"
    opts.ReferenceLength (1,1) double = 1
    opts.Subtract (1,2) double = [0 0]
    opts.ShowMask (1,1) logical = true
    opts.MaskTransparency (1,1) double = 50
    opts.ShowROI (1,1) logical = true
    opts.Title = []
    opts.Parent = []
    opts.Settings struct = struct()
end
[res, edited] = take_user_edits(res);   % values changed by hand in res.u / res.v are shown
if edited.filtered
    res.derived = struct();   % colour maps computed before the change are out of date
end
n = size(res.px.u,3);
fr = opts.Frame;
if fr > n
    error('pivlab:display:frame','res has only %d frame(s).', n);
end
dset = struct('Settings', opts.Settings, 'Colormap', opts.Colormap, 'ColormapSteps', opts.ColormapSteps, ...
    'MapInterpolation', opts.MapInterpolation, 'VectorScale', opts.VectorScale, 'VectorSkip', opts.VectorSkip, ...
    'EnhanceImage', opts.EnhanceImage);
if isempty(fieldnames(opts.Settings))
    dset.Settings = res.settings;
end
d = resolve_options('display', dset);

%% axes
if isempty(opts.Parent)
    fig = figure;
    ax = axes('Parent', fig);
else
    ax = opts.Parent;
    fig = ancestor(ax,'figure');
    cla(ax);
end

%% background image
imgs = res.images;
imsize = imgs.imageSize;
pair = res.pairs(min(fr, numel(res.pairs)));
img = [];
bgmode = opts.Background;
if bgmode == "raw", bgmode = "image"; end
try
    switch bgmode
        case {"image","black","white"}
            img = import.read_frame(imgs, 2*pair-1, imgs.cam, imgs.background);
        case "preprocessed"
            img = pivlab.getImage(imgs, pair);
    end
catch err
    warning('pivlab:display:image','The particle image could not be read (%s). A black background is used.', err.message);
    bgmode = "black";
end
if isempty(img)
    img = zeros(imsize, 'uint8');
end
displ = struct('image',1,'preprocessed',1,'black',2,'white',3);

%% colour map
q = lower(opts.Overlay);
map = [];
if q ~= "none"
    if ~isfield(res.derived, q)
        res = pivlab.derive(res, q, Settings=res.settings);
    end
    grid_map = res.derived.(q)(:,:,fr);
    interp = char(d.MapInterpolation);
    if ismember(q, ["correlation","uncertainty"])
        interp = 'nearest';
    end
    map = plot.rescale_map_core(grid_map, res.px.x, res.px.y, [size(img,1) size(img,2)], q == "direction", ...
        interp, opts.ExtrapolateBorder, roi_of(imgs));
end
mask_img = mask_of(res, fr, [size(img,1) size(img,2)]);
o = struct();
o.alpha = opts.Alpha;
o.displ_image = displ.(bgmode);
o.enhance = logical(d.EnhanceImage);
o.colormap_name = map_display_name(d.Colormap);
o.colormap_steps = d.ColormapSteps;
o.is_lic = q == "lic";
o.autoscale = isempty(opts.ColorLimits);
if ~o.autoscale
    o.map_min = opts.ColorLimits(1);
    o.map_max = opts.ColorLimits(2);
end
o.mask = mask_img;
o.mask_preview = opts.ShowMask && ~isempty(mask_img);
o.render_mask = o.mask_preview && any(mask_img(:));
o.masktransp = opts.MaskTransparency;
o.roirect = roi_of(imgs);
o.colorbar_position = colorbar_name(opts.Colorbar);
o.colorbar_label = quantity_label(q, res);
o.colorbar_format = find(opts.ColorbarFormat == ["compact","scientific","fixed"]);
plot.draw_background(ax, img, map, o);
axis(ax,'image');
set(ax,'ytick',[])
set(ax,'xtick',[])

%% region of interest
if opts.ShowROI && ~isempty(o.roirect)
    r = o.roirect;
    rectangle(ax,'Position',r,'LineWidth',1,'LineStyle','-','edgecolor','b','tag','roiplot')
    rectangle(ax,'Position',r,'LineWidth',1,'LineStyle',':','edgecolor','y','tag','roiplot')
end

%% vectors
if opts.Vectors
    p = res.px;
    if res.smoothed && ~isempty(p.u_smoothed)
        u = p.u_smoothed(:,:,fr); v = p.v_smoothed(:,:,fr);
    else
        u = p.u(:,:,fr); v = p.v(:,:,fr);
    end
    tv = res.typevector(:,:,fr);
    vecskip = d.VectorSkip;
    if isstring(d.VectorScale) || ischar(d.VectorScale)
        vecscale = plot.vector_scale_core(p.x, p.y, u, v, 1, vecskip, []);
    else
        vecscale = plot.vector_scale_core(p.x, p.y, u, v, 0, vecskip, d.VectorScale);
    end
    vc = opts.VectorColor;
    if isempty(vc)
        if isempty(map), vc = "green"; else, vc = "black"; end
    end
    vo = struct();
    vo.interp_color = color_of(opts.InterpolatedColor);
    vo.secondpeak_color = color_of(opts.SecondPeakColor);
    vo.uniform = opts.UniformLength;
    vo.power = ~isempty(opts.PowerScale);
    vo.power_factor = opts.PowerScale;
    vo.vecwidth = opts.VectorWidth;
    vo.masktransp = opts.MaskTransparency;
    vo.ref_position = ref_name(opts.ReferenceVector);
    vo.ref_length = opts.ReferenceLength;
    c = res.calibration;
    vo.calu = c.calu; vo.calv = c.calv; vo.calxy = c.calxy;
    vo.displacement_only = c.displacement_only;
    vo.subtr_u = opts.Subtract(1); vo.subtr_v = opts.Subtract(2);
    vo.colormap_name = o.colormap_name;
    vo.colormap_steps = o.colormap_steps;
    vo.colorbar_position = o.colorbar_position;
    vo.colorbar_format = o.colorbar_format;
    if (isstring(vc) || ischar(vc)) && strcmpi(vc,"magnitude")
        vectorcolor = 'magnitude';
    else
        vectorcolor = color_of(vc);
    end
    plot.draw_vectors(ax, p.x, p.y, u, v, tv, vecskip, vecscale, vectorcolor, vo);
end
set(ax,'YlimMode','manual'); set(ax,'XlimMode','manual')
t = opts.Title;
if isempty(t)
    t = res.frameLabels(min(fr,numel(res.frameLabels)));
end
if strlength(string(t)) > 0
    title(ax, t, 'Interpreter', 'none');
end
end

%% ------------------------------------------------------------------
function r = roi_of(imgs)
r = [];
if isfield(imgs,'preprocess') && ~isempty(imgs.preprocess) && isfield(imgs.preprocess,'Roi')
    r = imgs.preprocess.Roi;
end
end

function m = mask_of(res, fr, sz)
m = [];
imgs = res.images;
if ~isfield(imgs,'mask') || isempty(imgs.mask)
    return
end
if res.isMean(fr) && isfield(res,'sourcePairs')
    pairs = res.sourcePairs{fr};
else
    pairs = res.pairs(fr);
end
acc = [];
for p = pairs(:)'
    mp = {};
    if islogical(imgs.mask)
        mp = imgs.mask;
    elseif iscell(imgs.mask) && numel(imgs.mask) >= p
        mp = imgs.mask{p};
    end
    if isempty(mp)
        b = false(sz);
    elseif islogical(mp) || isnumeric(mp)
        b = logical(mp);
    else
        b = logical(mask.convert_masks_to_binary(sz, mp));
    end
    if isempty(acc), acc = b; else, acc = acc & b; end   % mean frames: masked in all pairs
end
m = acc;
end

function name = map_display_name(name)
names = ["Parula","HSV","Jet","HSB","Hot","Cool","Spring","Summer","Autumn","Winter","Gray","Bone","Copper","Pink","Lines","Plasma"];
k = find(strcmpi(names, string(name)), 1);
if isempty(k)
    error('pivlab:display:colormap','Unknown colormap "%s".', name);
end
name = char(names(k));
end

function c = colorbar_name(s)
switch lower(s)
    case {"none","off"}, c = 'None';
    case {"east","eastoutside"}, c = 'EastOutside';
    case {"west","westoutside"}, c = 'WestOutside';
    case {"north","northoutside"}, c = 'NorthOutside';
    case {"south","southoutside"}, c = 'SouthOutside';
    otherwise, error('pivlab:display:colorbar','Colorbar must be "east", "west", "north", "south" or "none".');
end
end

function r = ref_name(s)
names = ["Off","Top left","Top right","Bottom right","Bottom left"];
k = find(strcmpi(names, s), 1);
if isempty(k)
    error('pivlab:display:reference','ReferenceVector must be "off", "top left", "top right", "bottom right" or "bottom left".');
end
r = char(names(k));
end

function rgb = color_of(c)
if isnumeric(c)
    rgb = double(c(:)');
    return
end
presets = gui.vec_preset_colors();
k = find(strcmpi(presets(:,1), char(c)), 1);
if isempty(k)
    error('pivlab:display:color','Unknown colour "%s". Use an RGB triple or one of: %s.', c, strjoin(presets(:,1)', ', '));
end
rgb = presets{k,2};
end

function label = quantity_label(q, res)
u = res.units;
if u == "px/frame"
    t = "frame"; v = "px/frame";
elseif u == "m/frame"
    t = "frame"; v = "m/frame";
else
    t = "s"; v = "m/s";
end
switch q
    case "vorticity",   label = "Vorticity in 1/" + t;
    case "magnitude",   label = "Magnitude in " + v;
    case "u",           label = "u component in " + v;
    case "v",           label = "v component in " + v;
    case "divergence",  label = "Divergence in 1/" + t;
    case "qcriterion",  label = "Q criterion in 1/" + t + "^2";
    case "shear",       label = "Shear rate (magnitude of the rate-of-strain tensor) in 1/" + t;
    case "strain",      label = "Simple strain rate in 1/" + t;
    case "lic",         label = "Line integral convolution (LIC)";
    case "direction",   label = "Vector direction in degrees";
    case "correlation", label = "Correlation coefficient";
    case "uncertainty", label = "Uncertainty in " + v;
    otherwise,          label = "";
end
if isfield(res,'statistic') && q ~= "none"
    label = upper(res.statistic) + " " + label;
end
label = char(label);
end
