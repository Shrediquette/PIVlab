
function payload = cam_encode_qr_v1_binary(str)
% Encodes 'F:1,O:b,R:23,C:24,S:10,M:7' into 5 bytes

t = regexp(str, ...
 'F:(\d+),O:([bw]),R:(\d+),C:(\d+),S:(\d+),M:(\d+)', ...
 'tokens','once');
assert(~isempty(t),'Invalid format');

F = uint8(str2double(t{1}) - 1);     % 1–3 → 0–2
O = uint8(t{2} == 'w');              % b=0, w=1
R = uint16(str2double(t{3}) - 1);    % 1–1000 → 0–999
C = uint16(str2double(t{4}) - 1);
S = uint8(str2double(t{5}) - 1);     % 1–100 → 0–99
M = uint8(str2double(t{6}) - 1);

bits = double([ ...
    bitget(F,2:-1:1), ...
    O, ...
    bitget(R,10:-1:1), ...
    bitget(C,10:-1:1), ...
    bitget(S,7:-1:1), ...
    bitget(M,7:-1:1) ]);


% pad to full bytes
bits = [bits zeros(1, mod(8 - mod(numel(bits),8),8))];

payload = uint8(zeros(1,numel(bits)/8));
for i = 1:numel(payload)
payload(i) = uint8(bits(8*i-7:8*i) * (2.^(7:-1:0)).');
end

