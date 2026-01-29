function [detectionOK, qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,loc] = cam_get_charuco_info_from_QRcode (img)
detectionOK = 0;
qr_markerFamily=[];
qr_originCheckerColor=[];
qr_patternDims=[];
qr_checkerSize=[];
qr_markerSize=[];
[msg,~,loc]=readBarcode(img,'QR-CODE'); % will only return the first detected Barcode
msg = uint8(char(msg));
msg = preproc.cam_decode_qr_v1_binary(msg);
if ~isempty(msg)
    if contains(msg,'F') && contains(msg,'O') && contains(msg,'R') && contains(msg,'C') && contains(msg,'S') && contains(msg,'M') && contains(msg,',') && contains(msg,':')
        %String is e.g.: F:1,O:b,R:123,C:345,S:800,M:100
        C = strsplit(msg,',');
        if size(C,2) == 6
            detectionOK = 1;
            qr_markerFamily=str2double(C{1}(3:end));
            if qr_markerFamily == 1
                qr_markerFamily = 'DICT_4X4_1000';
            else
                qr_markerFamily = 'not supported';
            end
            qr_originCheckerColor = C{2}(3:end);
            if strcmp (qr_originCheckerColor,'b')
                qr_originCheckerColor = 'Black';
            elseif strcmp (qr_originCheckerColor,'w')
                qr_originCheckerColor = 'White';
            else
                qr_originCheckerColor = 'unknown';
            end
            qr_patternDims(1)=str2double(C{3}(3:end));
            qr_patternDims(2)=str2double(C{4}(3:end));
            qr_checkerSize=str2double(C{5}(3:end));
            qr_markerSize=str2double(C{6}(3:end));
        end
    end
end