function qr = cam_encode_qr (data,sz)
% e.g. 'F:1,O:b,R:23,C:24,S:10,M:7';
% Java imports
if ~any(contains(javaclasspath, 'core-3.5.3.jar'))
    javaaddpath('core-3.5.3.jar')
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