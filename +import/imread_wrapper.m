function image_data = imread_wrapper(filename,layernr,rows)
[~,~,ext] = fileparts(filename);
if strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') %for a tiff file, imread accepts a layer index as additional argument, for other files not, WTF!!!
	image_data=imread(filename,layernr);
else
	image_data=imread(filename);
end
if ~isempty(rows)
	image_data = image_data (rows(1):rows(2),:,:);
end