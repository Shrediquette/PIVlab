function out = flow_simulation_3d(opts)
% Unsteady 3D flows for the particle image generators: a time series of the velocity in a thin
% slab around the plane through the sphere centre / the jet axis.
%   out = simulate.flow_simulation_3d(Type='sphere')
%   out = simulate.flow_simulation_3d(Type='jet', Cells=[160 96 96], Diameter=16, Count=10, Spacing=0.25)
%
% Type 'sphere': wake of a sphere. Inflow at x = 0 (velocity 1; until 15 D/U with a slow sway of
%   3 % that starts the shedding), the sphere centre is Inlet diameters downstream of the inflow.
%   No physical viscosity: it looks like a sphere wake at moderate Reynolds numbers (unsteady,
%   three-dimensional shedding) but has no defined Reynolds number.
% Type 'jet': free round jet (velocity 1) from a nozzle (diameter D) in a wall at x = 0, with a
%   co-flow of 5 % through the wall around it (supplies the entrained fluid). Re = 3000 (explicit
%   viscosity), broadband nozzle perturbations of 1 % (10 modes) and a damping zone (cross flow)
%   in the last 1.5 D before the outflow. Tuned against jet data: potential core about 5 D,
%   centreline velocity on 6 D/x from 7 D on, spreading rate about 0.09; use x < length - 1.5 D.
% Both: outflow at the end of x (p = 0), periodic in y and z; sphere centre / jet axis in the
% middle of y and z. Units in the solver: cells, velocity 1 (free stream / jet).
%
% Method: "Stable Fluids" (Stam 1999) on a staggered (MAC) grid: semi-Lagrangian advection with
% MacCormack correction and limiter (Selle et al. 2008), pressure projection with the open area
% fractions of the faces at the sphere surface (Batty et al. 2007), solved by conjugate
% gradients with an FFT Poisson solver of the domain without obstacle as preconditioner.
% The last result is kept: the same call again returns it at once.
%
% Output (arrays in meshgrid order [y x z snapshot], single):
%   x, y, z   cell centres in diameters; origin: sphere centre / centre of the nozzle exit
%             (z: the planes of the slab)
%   U, V, W   velocity in units of the free stream / jet velocity, 0 inside the sphere
%   t         time of each snapshot in D/U (convective time units)
%   steps, seconds   number of time steps and computing time
%   full      (Full = true) the whole final field: u, v, w [ny nx nz] and the axes x, y, z
arguments
    opts.Type {mustBeMember(opts.Type, {'sphere', 'jet'})} = 'sphere'
    opts.Cells (1,3) double = [128 64 64]   % grid [nx ny nz]
    opts.Diameter (1,1) double = 12         % sphere / nozzle diameter in cells
    opts.Inlet (1,1) double = 2.5           % sphere: distance inflow -> sphere centre in diameters
    opts.Count (1,1) double = 1             % number of snapshots
    opts.Spacing (1,1) double = 0.25        % time between the snapshots in D/U
    opts.SpinUp (1,1) double = 20           % time before the first snapshot in D/U
    opts.SlabCells (1,1) double = 2         % half thickness of the slab in cells
    opts.Full (1,1) logical = false         % also return the whole final field
    opts.Progress = []                      % function handle, called with a status text
end
persistent last_key last_out
key = rmfield(opts, 'Progress');
if isequal(key, last_key)
    out = last_out;
    return
end
if ~isempty(last_key) && ~opts.Full && ~isfield(last_out, 'full') && last_key.Count >= opts.Count
    % the same flow with more snapshots was computed before (e.g. all image pairs, now only the
    % first one for a preview): the first snapshots are the same
    same = key;
    same.Count = last_key.Count;
    if isequal(same, last_key)
        out = last_out;
        out.U = out.U(:, :, :, 1:opts.Count);
        out.V = out.V(:, :, :, 1:opts.Count);
        out.W = out.W(:, :, :, 1:opts.Count);
        out.t = out.t(1:opts.Count);
        return
    end
end
nx = opts.Cells(1);
ny = opts.Cells(2);
nz = opts.Cells(3);
nc = nx * ny * nz;
D = opts.Diameter;
jet = strcmp(opts.Type, 'jet');
cy = ny / 2;
cz = nz / 2;
if jet
    cx = 0;
    nu = D / 3000;            % Re = 3000
    sponge = 1.5 * D;         % damping zone in front of the outflow [cells]
    name = 'Jet';
else
    cx = opts.Inlet * D;
    nu = 0;
    sponge = 0;
    name = 'Sphere';
end

%% time steps: whole steps between the snapshots, CFL number never close to an integer
% (a shift by exactly whole cells per step would not damp grid noise)
[n_spin, cfl_spin] = time_steps(max(opts.SpinUp, 0.1) * D);
[per_snapshot, cfl] = time_steps(opts.Spacing * D);
n_steps = n_spin + (opts.Count - 1) * per_snapshot;

%% open area fractions of the faces (the sphere surface cuts through the cells)
% u(i,j,k): x = i-1 (faces 0..nx), y = j-0.5, z = k-0.5
% v(i,j,k): y = j-1 (between cells j-1 and j, periodic), x and z centred
% w(i,j,k): z = k-1 (between cells k-1 and k, periodic), x and y centred
Nu = (nx + 1) * ny * nz;
Nv = nc;
if jet
    theta = ones(Nu + 2 * nc, 1);
else
    theta_u = face_fraction(0:nx, 0:ny - 1, 0:nz - 1, 1, cx, cy, cz, D / 2);
    theta_v = face_fraction(0:nx - 1, 0:ny - 1, 0:nz - 1, 2, cx, cy, cz, D / 2);
    theta_w = face_fraction(0:nx - 1, 0:ny - 1, 0:nz - 1, 3, cx, cy, cz, D / 2);
    theta = [theta_u(:); theta_v(:); theta_w(:)];
end
inflow_u = false(nx + 1, ny, nz);
inflow_u(1, :, :) = true;
inflow = [inflow_u(:); false(2 * nc, 1)];
theta(inflow) = 1;
theta(theta < 0.05) = 0; % tiny openings would only make the pressure equation stiff
open = theta > 0;
free = open & ~inflow;
if jet
    % inflow plane = nozzle exit: top hat with a tanh shear layer, 5 % co-flow around it
    [JY, JZ] = ndgrid((1:ny) - 0.5 - cy, (1:nz) - 0.5 - cz);
    nozzle_theta = atan2(JZ(:), JY(:));
    nozzle_profile = 0.5 * (1 + tanh((D / 2 - hypot(JY(:), JZ(:))) / max(1, 0.05 * D)));
    clear JY JZ
end

%% divergence matrix (cells x faces) and pressure matrix
[I, J, K] = ndgrid(1:nx, 1:ny, 1:nz);
I = I(:);
J = J(:);
K = K(:);
c = (1:nc)';
east = sub2ind([nx + 1, ny, nz], I + 1, J, K);
west = sub2ind([nx + 1, ny, nz], I, J, K);
north = Nu + sub2ind([nx, ny, nz], I, mod(J, ny) + 1, K);
south = Nu + c;
top = Nu + Nv + sub2ind([nx, ny, nz], I, J, mod(K, nz) + 1);
bottom = Nu + Nv + c;
one = ones(nc, 1);
Div = sparse([c; c; c; c; c; c], [east; west; north; south; top; bottom], [one; -one; one; -one; one; -one], nc, numel(theta));
clear I J K c east west north south top bottom one
fluid = abs(Div) * double(open) > 0; % cells with at least one open face
Div_fluid = Div(fluid, :);
Div_free = Div_fluid(:, free);
Grad_free = Div_free';
A = Div_free * spdiags(theta(free), 0, nnz(free), nnz(free)) * Grad_free;
clear Div

% preconditioner: Poisson solver of the domain without obstacle (x: eigenvectors of the 1D
% operator with inflow = Neumann and outflow = (p = 0); y, z periodic: FFT)
T = 2 * eye(nx) - diag(ones(nx - 1, 1), 1) - diag(ones(nx - 1, 1), -1);
T(1, 1) = 1;
[pre.Vx, lx] = eig(T);
lx = diag(lx);
ly = 2 - 2 * cos(2 * pi * (0:ny - 1) / ny);
lz = 2 - 2 * cos(2 * pi * (0:nz - 1) / nz);
pre.lam = lx + reshape(ly, 1, ny) + reshape(lz, 1, 1, nz);
pre.fluid = reshape(fluid, nx, ny, nz);
pre.n = [nx ny nz];

%% interpolation grids (one periodic ghost layer on each side in y and z)
grid_u = {0:nx, (0:ny + 1) - 0.5, (0:nz + 1) - 0.5};
grid_v = {(1:nx) - 0.5, -1:ny, (0:nz + 1) - 0.5};
grid_w = {(1:nx) - 0.5, (0:ny + 1) - 0.5, -1:nz};
P_u = face_points(0:nx, (1:ny) - 0.5, (1:nz) - 0.5);
P_v = face_points((1:nx) - 0.5, 0:ny - 1, (1:nz) - 0.5);
P_w = face_points((1:nx) - 0.5, (1:ny) - 0.5, 0:nz - 1);

%% cells inside the sphere, damping zone, slab planes
if jet
    inside = false(nx, ny, nz);
else
    [XC, YC, ZC] = ndgrid((1:nx) - 0.5, (1:ny) - 0.5, (1:nz) - 0.5);
    inside = (XC - cx) .^ 2 + (YC - cy) .^ 2 + (ZC - cz) .^ 2 <= (D / 2) ^ 2;
    clear XC YC ZC
end
if sponge > 0 % damping strength over x: 0 before the zone, rising to 1 at the outflow
    damping = min(1, max(0, ((1:nx)' - 0.5 - (nx - sponge)) / sponge)) .^ 2;
end
mid = nz / 2;
slab = mid - opts.SlabCells + 1:mid + opts.SlabCells;
slab = slab(slab >= 1 & slab <= nz);
out.x = ((1:nx) - 0.5 - cx) / D;
out.y = ((1:ny) - 0.5 - cy) / D;
out.z = (slab - 0.5 - cz) / D;
out.U = zeros(ny, nx, numel(slab), opts.Count, 'single');
out.V = out.U;
out.W = out.U;
out.t = zeros(1, opts.Count);

%% initial condition: uniform flow (sphere) or fluid at rest (jet), made divergence free
f = zeros(numel(theta), 1);
if jet
    f(inflow) = 0.05 + 0.95 * nozzle_profile;
else
    f(1:Nu) = 1;
end
f(~open) = 0;
pressure = zeros(nnz(fluid), 1);
[f, pressure] = project(f, theta, open, free, Div_fluid, Grad_free, A, pre, pressure);

%% time steps
tic_start = tic;
t = 0; % time in D/U
n_out = 0;
next_out = n_spin;
for step = 1:n_steps
    if step <= n_spin
        dt = cfl_spin;
    else
        dt = cfl;
    end
    u = reshape(f(1:Nu), nx + 1, ny, nz);
    v = reshape(f(Nu + 1:Nu + Nv), nx, ny, nz);
    w = reshape(f(Nu + Nv + 1:end), nx, ny, nz);

    % 1) advection, viscosity, damping zone
    vel.u = griddedInterpolant(grid_u, pad_yz(u), 'linear', 'nearest');
    vel.v = griddedInterpolant(grid_v, pad_yz(v), 'linear', 'nearest');
    vel.w = griddedInterpolant(grid_w, pad_yz(w), 'linear', 'nearest');
    u = reshape(advect(u, P_u, grid_u, vel, dt, ny, nz), nx + 1, ny, nz);
    v = reshape(advect(v, P_v, grid_v, vel, dt, ny, nz), nx, ny, nz);
    w = reshape(advect(w, P_w, grid_w, vel, dt, ny, nz), nx, ny, nz);
    if nu > 0 % explicit viscosity (stable for nu * dt < 1/6)
        u = u + nu * dt * laplacian(u);
        v = v + nu * dt * laplacian(v);
        w = w + nu * dt * laplacian(w);
    end
    if sponge > 0 % the cross flow fades out towards the outflow (else backflow there disturbs)
        keep = exp(-0.3 * dt * damping);
        v = v .* keep;
        w = w .* keep;
    end

    % 2) inflow
    t = t + dt / D;
    if jet
        % nozzle: 10 modes (azimuthal m = -3..3, St 0.27..0.83), total rms 1 %, like the
        % turbulence of a real nozzle: the shear layer rolls up and the jet becomes turbulent
        m = [0 1 -1 2 -2 0 1 -1 3 -3];
        st = [0.33 0.27 0.41 0.52 0.36 0.71 0.62 0.83 0.47 0.58];
        phase = [0 1.3 2.1 0.7 4.0 5.2 3.3 2.6 1.9 0.4];
        modulation = ones(size(nozzle_theta));
        for k = 1:numel(m)
            modulation = modulation + 0.01 * sqrt(2 / numel(m)) * cos(m(k) * nozzle_theta - 2 * pi * st(k) * t + phase(k));
        end
        f = [u(:); v(:); w(:)];
        f(inflow) = 0.05 + 0.95 * nozzle_profile .* modulation;
    else
        % slow sway that breaks the symmetry and starts the shedding (random noise would be
        % amplified); it fades out between 10 and 15 D/U, the wake then stays unsteady
        sway = 0.03 * min(1, max(0, (15 - t) / 5));
        v(1, :, :) = sway * sin(2 * pi * t / 7.3);
        w(1, :, :) = sway * sin(2 * pi * t / 5.1 + 1);
        f = [u(:); v(:); w(:)];
        f(inflow) = 1;
    end
    f(~open) = 0;

    % 3) pressure projection
    [f, pressure, iterations] = project(f, theta, open, free, Div_fluid, Grad_free, A, pre, pressure);
    if any(isnan(f(1:997:end)))
        error('simulate:flow_simulation_3d:unstable', 'The flow simulation became unstable at step %d.', step);
    end

    % 4) snapshot
    if step == next_out
        n_out = n_out + 1;
        [uc, vc, wc] = cell_centre(reshape(f(1:Nu), nx + 1, ny, nz), reshape(f(Nu + 1:Nu + Nv), nx, ny, nz), ...
            reshape(f(Nu + Nv + 1:end), nx, ny, nz), nx);
        uc(inside) = 0;
        vc(inside) = 0;
        wc(inside) = 0;
        out.U(:, :, :, n_out) = single(permute(uc(:, :, slab), [2 1 3]));
        out.V(:, :, :, n_out) = single(permute(vc(:, :, slab), [2 1 3]));
        out.W(:, :, :, n_out) = single(permute(wc(:, :, slab), [2 1 3]));
        out.t(n_out) = t;
        next_out = next_out + per_snapshot;
    end
    if ~isempty(opts.Progress) && (mod(step, 10) == 0 || step == n_steps)
        opts.Progress(sprintf('%s flow: time step %d of %d (%d CG iterations)', name, step, n_steps, iterations));
    end
end
out.steps = n_steps;
out.seconds = toc(tic_start);
if opts.Full
    [uc, vc, wc] = cell_centre(reshape(f(1:Nu), nx + 1, ny, nz), reshape(f(Nu + 1:Nu + Nv), nx, ny, nz), ...
        reshape(f(Nu + Nv + 1:end), nx, ny, nz), nx);
    uc(inside) = 0;
    vc(inside) = 0;
    wc(inside) = 0;
    out.full.u = permute(uc, [2 1 3]);
    out.full.v = permute(vc, [2 1 3]);
    out.full.w = permute(wc, [2 1 3]);
    out.full.x = out.x;
    out.full.y = out.y;
    out.full.z = ((1:nz) - 0.5 - cz) / D;
end
last_key = key;
last_out = out;
end

function [n, cfl] = time_steps(distance)
% number of time steps for a travel of distance cells at velocity 1, about 1.6 cells per step
% and not close to a whole number of cells
n = max(1, ceil(distance / 1.6));
cfl = distance / n;
if round(cfl) >= 1 && abs(cfl - round(cfl)) < 0.15
    n = n + 1;
    cfl = distance / n;
end
end

function theta = face_fraction(xs, ys, zs, normal, cx, cy, cz, R)
% open area fraction of the faces (outside of the sphere), from 4 x 4 samples per face;
% xs, ys, zs: lower corner coordinates of the faces (along the face normal: its position)
s = 4;
offsets = ((1:s) - 0.5) / s;
[X, Y, Z] = ndgrid(xs, ys, zs);
theta = zeros(size(X));
for a = 1:s
    for b = 1:s
        switch normal
            case 1
                inside = (X - cx) .^ 2 + (Y + offsets(a) - cy) .^ 2 + (Z + offsets(b) - cz) .^ 2 < R ^ 2;
            case 2
                inside = (X + offsets(a) - cx) .^ 2 + (Y - cy) .^ 2 + (Z + offsets(b) - cz) .^ 2 < R ^ 2;
            otherwise
                inside = (X + offsets(a) - cx) .^ 2 + (Y + offsets(b) - cy) .^ 2 + (Z - cz) .^ 2 < R ^ 2;
        end
        theta = theta + ~inside;
    end
end
theta = theta / s ^ 2;
end

function P = face_points(xs, ys, zs)
[X, Y, Z] = ndgrid(xs, ys, zs);
P = [X(:), Y(:), Z(:)];
end

function [f, pressure, iterations] = project(f, theta, open, free, Div_fluid, Grad_free, A, pre, pressure)
% divergence free flux through the open face areas; only the free faces change
rhs = Div_fluid * (theta .* f);
[pressure, iterations] = cg_solve(A, rhs, pressure, pre);
f(free) = f(free) - Grad_free * pressure;
f(~open) = 0;
end

function [x, it] = cg_solve(A, b, x, pre)
% preconditioned conjugate gradients, starting from the pressure of the last time step
tol = 1e-3;
r = b - A * x;
nb = norm(b);
it = 0;
if norm(r) <= tol * nb
    return
end
z = precondition(r, pre);
d = z;
rz = r' * z;
for it = 1:200
    Ad = A * d;
    alpha = rz / (d' * Ad);
    x = x + alpha * d;
    r = r - alpha * Ad;
    if norm(r) <= tol * nb
        break
    end
    z = precondition(r, pre);
    rz_new = r' * z;
    d = z + (rz_new / rz) * d;
    rz = rz_new;
end
end

function z = precondition(r, pre)
% Poisson equation of the domain without obstacle
nx = pre.n(1);
ny = pre.n(2);
nz = pre.n(3);
F = zeros(nx, ny, nz);
F(pre.fluid) = r;
F = reshape(pre.Vx' * reshape(F, nx, []), nx, ny, nz);
F = fft(fft(F, [], 2), [], 3);
F = F ./ pre.lam;
F = real(ifft(ifft(F, [], 3), [], 2));
F = reshape(pre.Vx * reshape(F, nx, []), nx, ny, nz);
z = F(pre.fluid);
end

function q_new = advect(q, P, grid, vel, dt, ny, nz)
% semi-Lagrangian advection of the face values q (at the points P) with MacCormack correction:
% the backward step is traced forward again, half of the error is corrected, and the result is
% limited to the values around the departure point (no new extrema)
[a, b, c] = velocity_at(vel, P(:, 1), P(:, 2), P(:, 3), ny, nz);
% backward (second order)
[a2, b2, c2] = velocity_at(vel, P(:, 1) - 0.5 * dt * a, P(:, 2) - 0.5 * dt * b, P(:, 3) - 0.5 * dt * c, ny, nz);
x = P(:, 1) - dt * a2;
y = mod(P(:, 2) - dt * b2, ny);
z = mod(P(:, 3) - dt * c2, nz);
Q = pad_yz(q);
F = griddedInterpolant(grid, Q, 'linear', 'nearest');
q1 = F(x, y, z);
[low, high] = cell_limits(Q);
corner = lower_corner(size(Q), grid, x, y, z);
q_min = low(corner);
q_max = high(corner);
% forward again from the result
[a3, b3, c3] = velocity_at(vel, P(:, 1) + 0.5 * dt * a, P(:, 2) + 0.5 * dt * b, P(:, 3) + 0.5 * dt * c, ny, nz);
F1 = griddedInterpolant(grid, pad_yz(reshape(q1, size(q))), 'linear', 'nearest');
q2 = F1(P(:, 1) + dt * a3, mod(P(:, 2) + dt * b3, ny), mod(P(:, 3) + dt * c3, nz));
q_new = q1 + 0.5 * (q(:) - q2);
q_new = min(max(q_new, q_min), q_max);
end

function [a, b, c] = velocity_at(vel, x, y, z, ny, nz)
y = mod(y, ny);
z = mod(z, nz);
a = vel.u(x, y, z);
b = vel.v(x, y, z);
c = vel.w(x, y, z);
end

function [low, high] = cell_limits(A)
% smallest and largest of the 8 corner values of each grid cell (stored at its lower corner)
low = min(A, A([2:end end], :, :));
low = min(low, low(:, [2:end end], :));
low = min(low, low(:, :, [2:end end]));
high = max(A, A([2:end end], :, :));
high = max(high, high(:, [2:end end], :));
high = max(high, high(:, :, [2:end end]));
end

function idx = lower_corner(sz, grid, x, y, z)
% linear index of the lower corner of the grid cell that contains the point (grid spacing 1;
% beyond the grid, only in x, the edge cell)
i = min(max(floor(x - grid{1}(1)), 0), sz(1) - 2);
j = min(max(floor(y - grid{2}(1)), 0), sz(2) - 2);
k = min(max(floor(z - grid{3}(1)), 0), sz(3) - 2);
idx = 1 + i + j * sz(1) + k * sz(1) * sz(2);
end

function A = pad_yz(A)
% one periodic ghost layer on each side in y and z
A = cat(2, A(:, end, :), A, A(:, 1, :));
A = cat(3, A(:, :, end), A, A(:, :, 1));
end

function [uc, vc, wc] = cell_centre(u, v, w, nx)
% face velocities -> cell centres
uc = 0.5 * (u(1:nx, :, :) + u(2:nx + 1, :, :));
vc = 0.5 * (v + circshift(v, -1, 2));
wc = 0.5 * (w + circshift(w, -1, 3));
end

function L = laplacian(A)
% 7-point Laplacian (cell size 1): periodic in y and z, zero gradient at the ends of x
L = A([1 1:end - 1], :, :) + A([2:end end], :, :) + circshift(A, 1, 2) + circshift(A, -1, 2) ...
    + circshift(A, 1, 3) + circshift(A, -1, 3) - 6 * A;
end
