function image_data = imread_wrapper(filename,layernr,rows)
[~,~,ext] = fileparts(filename);
if strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') %for a tiff file, imread accepts a layer index as additional argument, for other files not, WTF!!!
    if isempty(rows)
        image_data=imread(filename,layernr);
    else
        expected_image_size = gui.retr('expected_image_size');
        if ~isempty(expected_image_size)
            %image_data=imread(filename,layernr,'PixelRegion', {rows [1,expected_image_size(2)*5]}); %das sind ja die kolumnen. Denn diese Angabe fehlt beim Aufrug : Man weiß nicht wie breit das bild ist.
            image_data=imread(filename,layernr,'PixelRegion', {rows [1,inf]}); %alle cols die es gibt.
        else
            image_data=imread(filename,layernr);
        end
    end
else
    image_data=imread(filename);
    if ~isempty(rows)
        image_data = image_data (rows(1):rows(2),:,:);
    end
end
%{
if ~isempty(expected_image_size)
    cols=[1,expected_image_size(2)];
else
    cols= [];
end
%}