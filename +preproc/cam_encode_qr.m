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
qr = preproc.cam_qr_matrix_v1(uint8(char(data)));
%reduce border slightly...
qr(:,29)=[];
qr(29,:)=[];
qr(1,:)=[];
qr(:,1)=[];
qr=imresize(qr,[sz sz],'nearest','Antialiasing',false); %scale up without losing sharpness
qr=~qr;