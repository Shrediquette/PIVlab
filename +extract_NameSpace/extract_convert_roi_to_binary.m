function BW=extract_convert_roi_to_binary(xposition,yposition,extract_type,size_of_image)
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
	nsides_that_make_sense = floor(sqrt(2*pi()*yposition));
	pgon = nsidedpoly(nsides_that_make_sense,'Center',xposition,'Radius',yposition);
	BW = poly2mask(pgon.Vertices(:,1),pgon.Vertices(:,2),size_of_image(1),size_of_image(2));
end
