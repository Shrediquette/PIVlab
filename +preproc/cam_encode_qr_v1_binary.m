function txt = cam_encode_qr_v1_binary(str)
% Encode structured string into Base64 text for QR codes
% Safe for MATLAB readBarcode

% -------- parse --------
t = regexp(str, ...
 'F:(\d+),O:([bw]),R:(\d+),C:(\d+),S:(\d+),M:(\d+)', ...
 'tokens','once');
assert(~isempty(t),'Invalid format');

F = uint8(str2double(t{1}) - 1);     % 1–3   -> 0–2   (2 bits)
O = uint8(t{2} == 'w');              % b/w   -> 0/1   (1 bit)
R = uint16(str2double(t{3}) - 1);    % 1–1000-> 0–999 (10 bits)
C = uint16(str2double(t{4}) - 1);    % 10 bits
S = uint8(str2double(t{5}) - 1);     % 1–100 -> 0–99  (7 bits)
M = uint8(str2double(t{6}) - 1);     % 7 bits

% -------- bit-pack (37 bits total) --------
bits = double([ ...
    bitget(F,2:-1:1), ...
    O, ...
    bitget(R,10:-1:1), ...
    bitget(C,10:-1:1), ...
    bitget(S,7:-1:1), ...
    bitget(M,7:-1:1) ]);

% pad to full bytes
bits = [bits zeros(1, mod(8 - mod(numel(bits),8),8))];

% bits -> bytes
n = numel(bits)/8;
payload = uint8(zeros(1,n));
for i = 1:n
    payload(i) = uint8(bits(8*i-7:8*i) * (2.^(7:-1:0)).');
end

% -------- Base64 armoring (QR-safe) --------
txt = matlab.net.base64encode(payload);