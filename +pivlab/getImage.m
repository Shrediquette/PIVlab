function img = getImage(imgs, pair, opts)
%GETIMAGE Read one image of an image set, optionally pre-processed like in the PIV analysis.
%   img = pivlab.getImage(imgs, pair) returns the A image of image pair "pair", with the
%   background removed and the pre-processing of pivlab.preprocess applied (if it was called).
%
%   Name=value options
%   Frame          "A" (default) or "B"
%   Preprocessed   true (default): image as it goes into the PIV analysis
%                  false: raw image (camera undistortion only)
%
%   Example
%       imgs = pivlab.preprocess(pivlab.readImages("Example_data/Jet_*.jpg","pairwise"));
%       imshow(pivlab.getImage(imgs, 1))
%
%   See also pivlab.readImages, pivlab.preprocess
arguments
    imgs (1,1) struct
    pair (1,1) {mustBeInteger, mustBePositive}
    opts.Frame (1,1) string {mustBeMember(opts.Frame,["A","B"])} = "A"
    opts.Preprocessed (1,1) logical = true
end
if pair > imgs.pairs
    error('pivlab:getImage:pair','The image set has only %d image pairs.', imgs.pairs);
end
selected = 2*pair - 1 + double(opts.Frame == "B");
if opts.Preprocessed
    img = import.read_frame(imgs, selected, imgs.cam, imgs.background);
    if ~isempty(imgs.preprocess)
        img = piv.prepare_image(img, kernel_settings(imgs.preprocess));
    end
else
    [~, img] = import.read_frame(imgs, selected, imgs.cam, []);
end
end
