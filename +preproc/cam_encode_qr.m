function qr = cam_encode_qr (data,sz)
% input is e.g. 'F:1,O:b,R:23,C:24,S:10,M:7';
%convert to save characters and use larger pixels in the QR code:
data = preproc.cam_encode_qr_v1_binary(data);
data = native2unicode(data, 'ISO-8859-1');
% Java imports
if ~any(contains(javaclasspath, 'QR_gen.jar'))
    javaaddpath(fullfile('+preproc','QR_gen.jar'))
end
import com.google.zxing.*;
import com.google.zxing.common.*;
import com.google.zxing.qrcode.*;
writer = QRCodeWriter();
%encoder runs way faster when using the minimum size of v1 QR code (29 x 29 pixels). Then scale up to desired size.
bitMatrix = writer.encode(data, BarcodeFormat.QR_CODE, 29, 29);
w = bitMatrix.getWidth();
h = bitMatrix.getHeight();
qr = false(h,w);
for y = 1:h
    for x = 1:w
        qr(y,x) = bitMatrix.get(x-1,y-1);
    end
end
qr(:,29)=[];
qr(29,:)=[];
qr(1,:)=[];
qr(:,1)=[];
qr=imresize(qr,[sz sz],'nearest','Antialiasing',false); %scale up without losing sharpness
qr=~qr;