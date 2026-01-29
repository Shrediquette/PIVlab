function str = cam_decode_qr_v1_binary(txt)
% Decode Base64 QR payload back into structured string

% -------- Base64 decode --------
payload = matlab.net.base64decode(char(txt));
payload = uint8(payload);

% -------- unpack bits --------
bits = zeros(1, numel(payload)*8);
for i = 1:numel(payload)
    bits(8*i-7:8*i) = bitget(payload(i),8:-1:1);
end
bits = double(bits);

idx = 1;

F = bin2dec(char(bits(idx:idx+1)+'0')) + 1; idx = idx+2;
O = bits(idx);                              idx = idx+1;
R = bin2dec(char(bits(idx:idx+9)+'0')) + 1; idx = idx+10;
C = bin2dec(char(bits(idx:idx+9)+'0')) + 1; idx = idx+10;
S = bin2dec(char(bits(idx:idx+6)+'0')) + 1; idx = idx+7;
M = bin2dec(char(bits(idx:idx+6)+'0')) + 1;

str = sprintf('F:%d,O:%c,R:%d,C:%d,S:%d,M:%d', ...
    F, char('b' + O*('w'-'b')), R, C, S, M);

%{
%% testing a single conversion:
string='F:1,O:b,R:10,C:25,S:8,M:6'
payload = preproc.cam_encode_qr_v1_binary(string)
qrString = native2unicode(payload, 'ISO-8859-1')
import com.google.zxing.*;
import com.google.zxing.common.*;
import com.google.zxing.qrcode.*;
writer = QRCodeWriter();
tic
bitMatrix = writer.encode(qrString, BarcodeFormat.QR_CODE, 300, 300);
w = bitMatrix.getWidth();
h = bitMatrix.getHeight();
qr = false(h,w);
for y = 1:h
    for x = 1:w
        qr(y,x) = bitMatrix.get(x-1,y-1);
    end
end
toc
qr=~qr;
string = readBarcode(qr)
payload_rx = uint8(char(string))
decoded = preproc.cam_decode_qr_v1_binary(payload_rx)

%% Testing relevant cases 
% Exhaustive / large-range test (NO QR)

F_vals = 1:3;
O_vals = ['b','w'];
R_vals = 1:25:1000;
C_vals = 1:25:1000;
S_vals = 1:20;
M_vals = 1:15;

cnt = 0;
for F = F_vals
for O = O_vals
for R = R_vals(1:1:end)   % or full range if you want
disp(num2str(R))
for C = C_vals(1:1:end)
for S = S_vals(1:1:end)
for M = M_vals(1:1:end)

    in = sprintf('F:%d,O:%c,R:%d,C:%d,S:%d,M:%d',F,O,R,C,S,M);
    p  = preproc.cam_encode_qr_v1_binary(in);
    out = preproc.cam_decode_qr_v1_binary(p);

    if ~strcmp(in,out)
        error('Binary mismatch: %s -> %s',in,out);
    end

    cnt = cnt+1;
end
end
end
end
end
end
fprintf('Binary-only tests passed: %d\n',cnt);

% QR integration test (small set only)

F_vals = 1:3;
O_vals = ['b','w'];
R_vals = [3:7:40]%[1 23 500 1000];
C_vals = [3:7:40]%[1 24 500 1000];
S_vals = [5:7:30]%[1 10 100];
M_vals = [5:7:30]%[1 7 100];

writer = com.google.zxing.qrcode.QRCodeWriter();

cnt = 0;
for F = F_vals
for O = O_vals
for R = R_vals
for C = C_vals
for S = S_vals
for M = M_vals

    in = sprintf('F:%d,O:%c,R:%d,C:%d,S:%d,M:%d',F,O,R,C,S,M);

    payload = preproc.cam_encode_qr_v1_binary(in);
    qrString = native2unicode(payload,'ISO-8859-1');

    bitMatrix = writer.encode( ...
        qrString, ...
        com.google.zxing.BarcodeFormat.QR_CODE, ...
        29, 29);   % smaller = faster

    w = bitMatrix.getWidth();
    h = bitMatrix.getHeight();
    qr = false(h,w);
    for y = 1:h
        for x = 1:w
            qr(y,x) = bitMatrix.get(x-1,y-1);
        end
    end
    qr = ~qr;

    msg = readBarcode(qr,'QR-CODE');
    payload_rx = uint8(char(msg));
    out = preproc.cam_decode_qr_v1_binary(payload_rx);

    if ~strcmp(in,out)
        error('QR mismatch:\nIN : %s\nOUT: %s',in,out);
    end

    cnt = cnt+1;
end
end
end
disp(num2str(cnt))
end
end
end

fprintf('QR integration tests passed: %d\n',cnt);

%}