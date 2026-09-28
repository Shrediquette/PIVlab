function qr = cam_encode_qr (data,sz)
% input is e.g. 'F:1,O:b,R:23,C:24,S:10,M:7';
%convert to save characters and use larger pixels in the QR code:
try
	data = preproc.cam_encode_qr_v1_binary(data);
catch
	disp('could not encode')
	qr=[];
	return
end
%v1 QR code incl. quiet zone (29 x 29 pixels, true = dark). Then scale up to desired size.
%readBarcode (zxing-cpp 1.0) misses a finder pattern when the data modules form a
%finder-like pattern that is scanned before it (~0.15 % of codes). Then use the
%mask with the next lowest penalty, until the code reads in all 4 orientations.
bytes = uint8(char(data));
[qr, mask_order] = preproc.cam_qr_matrix_v1(bytes);
for mask = mask_order
	candidate = preproc.cam_qr_matrix_v1(bytes, mask);
	if qr_readable(candidate, data)
		qr = candidate;
		break
	end
end
%reduce border slightly...
qr(:,29)=[];
qr(29,:)=[];
qr(1,:)=[];
qr(:,1)=[];
qr=imresize(qr,[sz sz],'nearest','Antialiasing',false); %scale up without losing sharpness
qr=~qr;

function ok = qr_readable(qr, data)
img = uint8(~kron(qr, true(8))) * 255; %8 pixels per module, white background
try
	ok = true;
	for k = 0:3
		msg = readBarcode(rot90(img, k), 'QR-CODE');
		if ~strcmp(msg, data)
			ok = false;
			return
		end
	end
catch
	ok = true; %readBarcode not available (Computer Vision Toolbox missing): keep the best mask
end