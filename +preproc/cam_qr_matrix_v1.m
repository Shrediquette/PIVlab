function qr = cam_qr_matrix_v1(bytes)
% Pure MATLAB QR code encoder, replaces the zxing Java library (MATLAB
% Runtime R2026b and newer ships without Java).
% Encodes up to 17 bytes as a version 1 QR code (21 x 21 modules), byte
% mode, error correction level L. Mask selection uses the same penalty
% rules as zxing, so the result equals
% zxing QRCodeWriter.encode(data, BarcodeFormat.QR_CODE, 29, 29).
% Output: 29 x 29 logical, true = dark module, 4 module quiet zone.

bytes = double(uint8(bytes(:)'));
n_data = 19; % data codewords of version 1-L
n_ec = 7;    % error correction codewords of version 1-L
if numel(bytes) > 17
	error('QR payload too long for a version 1 code (max. 17 bytes).')
end

%% Data bit stream: byte mode indicator, character count, data, terminator, padding
bits = [0 1 0 0, bitget(numel(bytes),8:-1:1), bytes2bits(bytes)];
capacity = n_data * 8;
bits = [bits zeros(1, min(4, capacity - numel(bits)))];
bits = [bits zeros(1, mod(-numel(bits), 8))];
codewords = reshape(bits, 8, []).' * (2.^(7:-1:0)).';
codewords = codewords.';
pad = repmat([236 17], 1, n_data);
codewords = [codewords pad(1:n_data - numel(codewords))];

%% Reed-Solomon error correction, GF(256) with primitive polynomial 0x11D
[gf_exp, gf_log] = gf_tables;
gen = 1;
for i = 0:n_ec-1 % generator polynomial = prod(x - alpha^i)
	gen = [gen 0]; %#ok<AGROW>
	gen(2:end) = bitxor(gen(2:end), gf_mul(gen(1:end-1), gf_exp(i+1), gf_exp, gf_log));
end
remainder = [codewords zeros(1, n_ec)];
for i = 1:n_data
	c = remainder(i);
	if c ~= 0
		remainder(i:i+n_ec) = bitxor(remainder(i:i+n_ec), gf_mul(gen, c, gf_exp, gf_log));
	end
end
data_bits = bytes2bits([codewords remainder(end-n_ec+1:end)]);

%% Function patterns (-1 = empty, 0 = light, 1 = dark)
sz = 21;
base = -ones(sz);
finder = ones(7);
finder(2:6,2:6) = 0;
finder(3:5,3:5) = 1;
base(1:7,1:7) = finder;
base(1:7,15:21) = finder;
base(15:21,1:7) = finder;
base(8,1:8) = 0; base(1:8,8) = 0;    % separators
base(8,14:21) = 0; base(1:8,14) = 0;
base(14,1:8) = 0; base(14:21,8) = 0;
for i = 8:12                         % timing patterns
	base(7,i+1) = mod(i+1,2);
	base(i+1,7) = mod(i+1,2);
end
base(14,9) = 1;                      % dark module

%% Try all 8 masks, keep the first one with the lowest penalty (as zxing does)
best_penalty = inf;
for mask = 0:7
	M = build_matrix(base, data_bits, mask);
	penalty = mask_penalty(M);
	if penalty < best_penalty
		best_penalty = penalty;
		best = M;
	end
end

qr = false(sz + 8);
qr(5:end-4,5:end-4) = best == 1;
end

function bits = bytes2bits(bytes)
n = numel(bytes);
bits = double(reshape(bitget(repmat(uint8(bytes),8,1), repmat((8:-1:1)',1,n)), 1, []));
end

function [gf_exp, gf_log] = gf_tables
gf_exp = zeros(1,255);
x = 1;
for i = 1:255
	gf_exp(i) = x;
	x = x * 2;
	if x >= 256
		x = bitxor(x, 285);
	end
end
gf_log = zeros(1,256);
gf_log(gf_exp + 1) = 0:254;
end

function p = gf_mul(a, b, gf_exp, gf_log)
% element-wise multiplication in GF(256)
p = gf_exp(mod(gf_log(a+1) + gf_log(b+1), 255) + 1) .* (a ~= 0 & b ~= 0);
end

function M = build_matrix(M, data_bits, mask)
sz = size(M,1);
% format information: EC level L (01), mask, BCH(15,5) code, XOR mask 0x5412
type_info = bitor(bitshift(1,3), mask);
bch = bitshift(type_info, 10);
while floor(log2(bch)) >= 10
	bch = bitxor(bch, bitshift(1335, floor(log2(bch)) - 10)); % 1335 = 0x537
end
format_bits = bitxor(bitor(bitshift(type_info,10), bch), 21522); % 21522 = 0x5412
coords = [8 0; 8 1; 8 2; 8 3; 8 4; 8 5; 8 7; 8 8; 7 8; 5 8; 4 8; 3 8; 2 8; 1 8; 0 8]; % [x y], bit 0 first
for i = 0:14
	bit = bitget(format_bits, i+1);
	M(coords(i+1,2)+1, coords(i+1,1)+1) = bit;
	if i < 8
		M(9, sz-i) = bit;
	else
		M(sz-7+(i-8)+1, 9) = bit;
	end
end
% data bits in two-column zigzag from the bottom right, skipping the vertical timing pattern
bit_index = 1;
direction = -1;
x = sz - 1;
y = sz - 1;
while x > 0
	if x == 6
		x = x - 1;
	end
	while y >= 0 && y < sz
		for i = 0:1
			xx = x - i;
			if M(y+1, xx+1) ~= -1
				continue
			end
			if bit_index <= numel(data_bits)
				bit = data_bits(bit_index);
				bit_index = bit_index + 1;
			else
				bit = 0;
			end
			if mask_bit(mask, xx, y)
				bit = 1 - bit;
			end
			M(y+1, xx+1) = bit;
		end
		y = y + direction;
	end
	direction = -direction;
	y = y + direction;
	x = x - 2;
end
end

function m = mask_bit(mask, x, y)
switch mask
	case 0
		m = mod(y + x, 2) == 0;
	case 1
		m = mod(y, 2) == 0;
	case 2
		m = mod(x, 3) == 0;
	case 3
		m = mod(y + x, 3) == 0;
	case 4
		m = mod(floor(y/2) + floor(x/3), 2) == 0;
	case 5
		m = mod(y*x, 2) + mod(y*x, 3) == 0;
	case 6
		m = mod(mod(y*x, 2) + mod(y*x, 3), 2) == 0;
	case 7
		m = mod(mod(y*x, 3) + mod(y + x, 2), 2) == 0;
end
end

function penalty = mask_penalty(M)
penalty = penalty_runs(M) + penalty_runs(M.') + penalty_blocks(M) + ...
	penalty_finder_like(M) + penalty_finder_like(M.') + penalty_balance(M);
end

function penalty = penalty_runs(M)
% rule 1: 3 + (n - 5) for each run of n >= 5 equal modules in a row
penalty = 0;
for r = 1:size(M,1)
	run_starts = [1 find(diff(M(r,:)) ~= 0) + 1 size(M,2) + 1];
	runs = diff(run_starts);
	penalty = penalty + sum(runs(runs >= 5) - 2);
end
end

function penalty = penalty_blocks(M)
% rule 2: 3 for each 2 x 2 block of equal modules
same = M(1:end-1,1:end-1) == M(2:end,1:end-1) & M(1:end-1,1:end-1) == M(1:end-1,2:end) & M(1:end-1,1:end-1) == M(2:end,2:end);
penalty = 3 * sum(same(:));
end

function penalty = penalty_finder_like(M)
% rule 3: 40 for each 1:1:3:1:1 pattern with 4 light modules on one side
% (as in zxing, the 4 light modules must lie inside the symbol)
pattern = [1 0 1 1 1 0 1];
n = size(M,2);
count = 0;
for r = 1:size(M,1)
	row = M(r,:);
	for x = 1:n-6
		if isequal(row(x:x+6), pattern) && ((x > 4 && all(row(x-4:x-1) == 0)) || (x + 10 <= n && all(row(x+7:x+10) == 0)))
			count = count + 1;
		end
	end
end
penalty = 40 * count;
end

function penalty = penalty_balance(M)
% rule 4: 10 for each full 5 % deviation of the dark share from 50 %
total = numel(M);
penalty = 10 * floor(abs(2 * sum(M(:) == 1) - total) * 10 / total);
end
