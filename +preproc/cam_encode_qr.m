function qr = cam_encode_qr (data,sz)
% input is e.g. 'F:1,O:b,R:23,C:24,S:10,M:7';
%convert to save characters and use larger pixels in the QR code:
%data=native2unicode(preproc.cam_encode_qr_v1_binary(data), 'ISO-8859-1');
%try to get encoding decoding to work..

% Java imports
if ~any(contains(javaclasspath, 'QR_gen.jar'))
    javaaddpath(fullfile('+preproc','QR_gen.jar'))
end
import com.google.zxing.*;
import com.google.zxing.common.*;
import com.google.zxing.qrcode.*;
writer = QRCodeWriter();
bitMatrix = writer.encode(data, BarcodeFormat.QR_CODE, sz, sz);
w = bitMatrix.getWidth();
h = bitMatrix.getHeight();
qr = false(h,w);
for y = 1:h
    for x = 1:w
        qr(y,x) = bitMatrix.get(x-1,y-1);
    end
end
qr=~qr;