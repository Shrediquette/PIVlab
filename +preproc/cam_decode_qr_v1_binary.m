function str = cam_decode_qr_v1_binary(payload)

% unpack bits (force double for safety)
bits = zeros(1, numel(payload)*8);
for i = 1:numel(payload)
    bits(8*i-7:8*i) = bitget(payload(i), 8:-1:1);
end
bits = double(bits);

idx = 1;

% --- read fields explicitly ---
F = bin2dec(char(bits(idx:idx+1) + '0')) + 1;
idx = idx + 2;

O = bits(idx);
idx = idx + 1;

R = bin2dec(char(bits(idx:idx+9) + '0')) + 1;
idx = idx + 10;

C = bin2dec(char(bits(idx:idx+9) + '0')) + 1;
idx = idx + 10;

S = bin2dec(char(bits(idx:idx+6) + '0')) + 1;
idx = idx + 7;

M = bin2dec(char(bits(idx:idx+6) + '0')) + 1;

% --- rebuild string ---
str = sprintf('F:%d,O:%c,R:%d,C:%d,S:%d,M:%d', ...
    F, char('b' + O*('w' - 'b')), R, C, S, M);