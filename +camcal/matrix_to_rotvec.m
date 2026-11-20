function rvec = matrix_to_rotvec(R)
%MATRIX_TO_ROTVEC Rotation vector (Rodrigues, OpenCV convention) from a rotation matrix.
%   rvec = camcal.matrix_to_rotvec(R)   rvec is a 1x3 row vector.
%   R is first made orthonormal (closest rotation matrix).

[U, ~, V] = svd(R);
R = U * V';
if det(R) < 0
	R = -R;
end

c = (trace(R) - 1) / 2;
c = min(max(c, -1), 1);
theta = acos(c);
v = [R(3,2) - R(2,3); R(1,3) - R(3,1); R(2,1) - R(1,2)];

if theta < 1e-8
	rvec = (v / 2)';
	return
end

if pi - theta < 1e-4
	% close to 180 degrees: the axis follows from the diagonal of (R + I) / 2
	B = (R + eye(3)) / 2;
	k = sqrt(max(diag(B), 0));
	if k(1) > 1e-6
		k(2) = sign_or_one(B(1,2)) * k(2);
		k(3) = sign_or_one(B(1,3)) * k(3);
	elseif k(2) > 1e-6
		k(3) = sign_or_one(B(2,3)) * k(3);
	end
	k = k / norm(k);
	% keep the axis sign consistent with the antisymmetric part where it is still defined
	if dot(k, v) < 0
		k = -k;
	end
	rvec = (theta * k)';
	return
end

rvec = (theta / (2 * sin(theta)) * v)';
end

function s = sign_or_one(x)
if x < 0
	s = -1;
else
	s = 1;
end
end
