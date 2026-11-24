function tests = test_core_mask_shapes
%TEST_CORE_MASK_SHAPES Masks of the PIV analysis from their shapes (mask.convert_masks_to_binary, no GUI):
%   the area and position of circle, rectangle and polygon masks against the exact geometry.
%   Run with: results = runtests('unittests/test_core_mask_shapes.m')
tests = functiontests(localfunctions);
end

function test_circle_area_and_position(testCase)
sz = [400 500];
[X, Y] = meshgrid(1:sz(2), 1:sz(1));
for r = [5 16 40 80 150]
    c = [251.3 198.7];
    m = mask.convert_masks_to_binary(sz, {'ROI_object_circle', [c r]});
    % pixels along the outline are in or out: up to a quarter pixel per pixel of the circumference
    % (the former polygon with floor(sqrt(2*pi*r)) sides was about twice as far off at every radius)
    testCase.verifyEqual(nnz(m), pi * r^2, 'AbsTol', 0.25 * 2 * pi * r, sprintf('area of a circle with r = %g px', r));
    inside = hypot(X - c(1), Y - c(2));
    testCase.verifyTrue(all(m(inside < r - 1)), sprintf('r = %g: pixels inside the circle are masked', r));
    testCase.verifyFalse(any(m(inside > r + 1)), sprintf('r = %g: pixels outside the circle are not masked', r));
    testCase.verifyEqual([mean(X(m)) mean(Y(m))], c, 'AbsTol', 0.6, sprintf('r = %g: centre of the circle', r));
end
end

function test_circle_same_as_extraction_area(testCase)
% a circle mask and a circle area of the extraction cover the same pixels
sz = [300 400];
c = [180.5 140.2];
r = 37;
m = mask.convert_masks_to_binary(sz, {'ROI_object_circle', [c r]});
a = extract.convert_roi_to_binary(c, r, 'extract_circle_area', sz);
testCase.verifyEqual(m, a);
end

function test_rectangle_and_polygon(testCase)
sz = [300 400];
m = mask.convert_masks_to_binary(sz, {'ROI_object_rectangle', [50 60 120 80]});
testCase.verifyEqual(nnz(m), 120 * 80, 'area of the rectangle');
P = [100 50; 300 70; 250 250; 80 200];
m = mask.convert_masks_to_binary(sz, {'ROI_object_polygon', P});
testCase.verifyEqual(nnz(m), polyarea(P(:,1), P(:,2)), 'RelTol', 0.01, 'area of the polygon');
end

function test_overlapping_shapes(testCase)
% masks that overlap: as before, a pixel covered by an even number of shapes is not masked
sz = [200 200];
both = {'ROI_object_rectangle', [20 20 100 100]; 'ROI_object_circle', [120 120 40]};
m = mask.convert_masks_to_binary(sz, both);
r = mask.convert_masks_to_binary(sz, both(1,:));
c = mask.convert_masks_to_binary(sz, both(2,:));
testCase.verifyEqual(m, xor(r, c));
end
