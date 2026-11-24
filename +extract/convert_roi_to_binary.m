function BW=convert_roi_to_binary(xposition,yposition,extract_type,size_of_image)
if strcmp(extract_type,'extract_poly_area')%polygon:
	BW = poly2mask(xposition,yposition,size_of_image(1),size_of_image(2));
elseif strcmp(extract_type,'extract_rectangle_area')%rectangle:
	bbox=[xposition(1),yposition(1),xposition(2),yposition(2)];
	rectangle_coords = zeros(4, 2, 'like', bbox);
	rectangle_coords(1, 1) = bbox(:, 1);
	rectangle_coords(1, 2) = bbox(:, 2);
	rectangle_coords(2, 1) = bbox(:, 1) + bbox(:, 3);
	rectangle_coords(2, 2) = bbox(:, 2);
	rectangle_coords(3, 1) = bbox(:, 1) + bbox(:, 3);
	rectangle_coords(3, 2) = bbox(:, 2) + bbox(:, 4);
	rectangle_coords(4, 1) = bbox(:, 1);
	rectangle_coords(4, 2) = bbox(:, 2) + bbox(:, 4);
	BW = poly2mask(rectangle_coords(:,1),rectangle_coords(:,2),size_of_image(1),size_of_image(2));
elseif strcmp(extract_type,'extract_circle_area')%circles:
	%the circle as in the circle series (extract.plot_data_area): 360 sides. A polygon with
	%floor(sqrt(2*pi*r)) sides made the area too small (6.5 % at r = 16 px, 3 % at r = 40 px).
	valtable=linspace(0,2*pi,361)';
	BW = poly2mask(sin(valtable)*yposition+xposition(1),cos(valtable)*yposition+xposition(2),size_of_image(1),size_of_image(2));
end

