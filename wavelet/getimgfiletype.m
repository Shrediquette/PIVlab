function imgFileType = getimgfiletype(~)
%GETIMGFILETYPE Getimage file types.
%   imgFileType = GETIMGFILETYPE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Oct-2008.
%   Last Revision: 03-Nov-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<1
    imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;' ...
        '*.jpeg;*.pcx;*.tif;*.tiff;*.gif;*.png;' ...
        '*.ras;*.ppm;*.pgm;*.pbm;'];
else
    imgFileType = {'bmp','jpg','jpeg' ,...
        'pcx','tif','tiff','gif','png',...
        'ras','ppm','pgm','pbm'};
end
