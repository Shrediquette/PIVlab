function res = new_result(R, imgs, s)
%NEW_RESULT Build the API result struct from a cell array of piv.analyze_pair results.
%   The data is stored in pixel units in res.px (like PIVlab does internally); res.x, res.y,
%   res.u, res.v, ... are the same data in the current units (see refresh_units).
n = numel(R);
x = R{1}.x; y = R{1}.y;
sz = size(x);
u = zeros([sz n], 'like', R{1}.u);
v = u;
typevector = zeros([sz n], 'like', R{1}.typevector);
correlation_map = zeros([sz n], 'like', R{1}.correlation_map);
has2 = ~isempty(R{1}.u2);
hasU = ~isempty(R{1}.umap);
u2 = []; v2 = []; unc = [];
if has2, u2 = zeros([sz n], 'like', R{1}.u2); v2 = u2; end
if hasU, unc = zeros([sz n], 'like', R{1}.umap); end
for i = 1:n
    if ~isequal(size(R{i}.u), sz)
        error('pivlab:analyze:size','Pair %d gives a vector field of a different size. All images must have the same size.', i);
    end
    u(:,:,i) = R{i}.u;
    v(:,:,i) = R{i}.v;
    typevector(:,:,i) = R{i}.typevector;
    correlation_map(:,:,i) = R{i}.correlation_map;
    if has2, u2(:,:,i) = R{i}.u2; v2(:,:,i) = R{i}.v2; end
    if hasU, unc(:,:,i) = R{i}.umap; end
end
res = struct();
res.x = []; res.y = []; res.u = []; res.v = [];
res.typevector = typevector;
res.u_raw = []; res.v_raw = [];
res.typevector_raw = typevector;
res.correlation_map = correlation_map;
res.uncertainty = [];
res.units = "px/frame";
res.calibration = uncalibrated();
res.filtered = false;
res.smoothed = false;
res.derived = struct();
res.frameLabels = strings(n,1);
res.isMean = false(n,1);
res.pairs = 1:n;
res.px = struct('x',x,'y',y,'u',u,'v',v,'u_raw',u,'v_raw',v,'u2',u2,'v2',v2, ...
    'u_smoothed',[],'v_smoothed',[],'uncertainty',unc);
res.images = imgs;
res.settings = s;
res = refresh_units(res);
end

function c = uncalibrated()
c = struct('calxy',1,'calu',1,'calv',1,'offset_x_true',0,'offset_y_true',0, ...
    'x_axis_direction',1,'y_axis_direction',1,'realdist',1,'time_inp',1,'pointscali',[], ...
    'displacement_only',false);
end
