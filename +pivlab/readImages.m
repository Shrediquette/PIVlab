function imgs = readImages(source, sequencing, opts)
%READIMAGES Select the images for a PIV analysis and pair them.
%   imgs = pivlab.readImages(source, sequencing)
%
%   source      file pattern  ("C:\data\*.tif", "Example_data/Jet_*.jpg"),
%               a folder      (all .bmp .jpg .jpeg .png .tif .tiff .b16 images in it),
%               or a list of files (string array or cell array, used in the given order)
%   sequencing  how the images are paired:
%               "pairwise"     A+B, C+D, E+F, ...  (double-frame cameras, file names ending A/B)
%               "timeresolved" A+B, B+C, C+D, ...  (high-speed recordings)
%               "reference"    A+B, A+C, A+D, ...  (every image against the first one)
%
%   Name=value options
%   MultiTiff   true/false, every page of a multi-page TIFF is a frame. Default: detected.
%
%   imgs is a struct describing the image pairs. It contains no pixel data, so it is small
%   even for thousands of images. Pass it to pivlab.preprocess and pivlab.analyze.
%   imgs.pairs is the number of image pairs, pivlab.getImage(imgs, k) reads an image.
%
%   Example
%       imgs = pivlab.readImages("Example_data/Jet_*.jpg", "pairwise");
%
%   See also pivlab.preprocess, pivlab.analyze, pivlab.getImage
arguments
    source {mustBeText}
    sequencing (1,1) string {mustBeMember(sequencing,["pairwise","timeresolved","reference"])}
    opts.MultiTiff = []
end
files = resolve_files(source);
if isempty(files)
    error('pivlab:readImages:noImages','No images found for "%s".', strjoin(string(source),', '));
end
multitiff = opts.MultiTiff;
if isempty(multitiff)
    multitiff = false;
    [~,~,ext] = fileparts(files{1});
    if any(strcmpi(ext,{'.tif','.tiff'}))
        multitiff = numel(imfinfo(files{1})) > 1;
    end
end
sequencer_codes = struct('timeresolved',0,'pairwise',1,'reference',2);
requested = sequencer_codes.(sequencing);
[filepath, framenum, framepart, filename, sequencer, pco] = import.build_file_list(files, requested, multitiff);
if numel(filepath) < 2
    error('pivlab:readImages:tooFewImages','At least two images (one image pair) are needed.');
end
if pco && requested ~= sequencer
    warning('pivlab:readImages:pcoDoubleImage', ...
        'pco.panda double images detected, sequencing was changed to "pairwise".');
end
names = ["timeresolved","pairwise","reference"];

imgs = struct();
imgs.files = string(files);
imgs.sequencing = names(sequencer+1);
imgs.sequencer = sequencer;
imgs.multitiff = logical(multitiff);
imgs.pcopanda_dbl_image = logical(pco);
imgs.filepath = filepath;
imgs.framenum = framenum;
imgs.framepart = framepart;
imgs.filename = filename;
imgs.pairs = numel(filepath)/2;
first = import.read_frame(imgs, 1, [], []);
imgs.imageSize = [size(first,1) size(first,2)];
imgs.cam = import.cam_settings();
imgs.preprocess = [];   % filled by pivlab.preprocess
imgs.background = [];   % filled by pivlab.preprocess
end

function files = resolve_files(source)
source = cellstr(source);
files = {};
exts = {'.bmp','.jpg','.jpeg','.png','.tif','.tiff','.b16'};
for k = 1:numel(source)
    src = source{k};
    if isfolder(src)
        L = dir(src);
        L = L(~[L.isdir]);
        [~,~,e] = cellfun(@fileparts, {L.name}, 'UniformOutput', false);
        L = L(ismember(lower(e), exts));
    else
        L = dir(src);
        L = L(~[L.isdir]);
    end
    if isempty(L)
        continue
    end
    [names,order] = sort({L.name});
    folders = {L(order).folder};
    files = [files, fullfile(folders, names)]; %#ok<AGROW>
end
files = files(:);
end
