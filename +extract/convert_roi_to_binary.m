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
	%the same circle as the circle masks (360 sides, as in the circle series)
	[xi,yi] = mask.circle_outline(xposition(1:2),yposition);
	BW = poly2mask(xi,yi,size_of_image(1),size_of_image(2));
end

