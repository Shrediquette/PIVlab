function disp(t)
%DISP Display information of WPTREE object.
%
%   See also GET, READ, SET, WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Get wavelet packet tree information.
[order,depth,tn,wavName,Lo_D,Hi_D,Lo_R,Hi_R,entName,entPar] = get(t,...
	'order','depth','tn', ...
	'wavName','Lo_D','Hi_D','Lo_R','Hi_R', ...
	'entName','entPar' ...
	);
dataSize = read(t,'sizes',0);

headerStr = char(...
	getWavMSG('Wavelet:moreMSGRF:WPTREE_OBJ_Head'), ...
    sprintf('%s','===============================') ...
	);

infoStr = char(...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_Size'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_Order'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_Depth'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_TN'),  ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_Wname'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_LowDecF'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_HigDecF'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_LowRecF'),  ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_HigRecF'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_EntNam'), ...
	getWavMSG('Wavelet:moreMSGRF:Tree_OBJ_EntPar') ...
    );
	
% Setting Strings.
%-----------------
prec = 4;

tn = tn';
nb_tn = length(tn);
lStr = '['; 
if nb_tn>16 , nb_tn = 16; rStr = ' ...]'; else rStr = ']'; end
tnStr = [lStr int2str(tn(1:nb_tn)) rStr];

lf = length(Lo_D);
lStr = '['; lStr = lStr(ones(4,1));
if lf>8 , lf = 8; rStr = ' ...]'; else rStr = ']'; end
rStr = rStr(ones(4,1),:);
F = [Lo_D;Hi_D;Lo_R;Hi_R];
indFirst = 6;
FStr = [infoStr(indFirst:indFirst+3,:) lStr num2str(F(:,1:lf),prec) rStr];
if isnumeric(entPar) , entPar = num2str(entPar,prec); end

addLen = 20;
sep = '-';
sepStr = sep(ones(1,size(infoStr,2)+addLen));	


% Displaying.
%------------
disp(' ')
disp(headerStr);
ind = 1;     disp([infoStr(ind,:) , '[' int2str(dataSize) ']'])
ind = ind+1; disp([infoStr(ind,:) , int2str(order)])
ind = ind+1; disp([infoStr(ind,:) , int2str(depth)])
ind = ind+1; disp([infoStr(ind,:) , tnStr])
disp(sepStr);

ind = ind+1; disp([infoStr(ind,:) , wavName])
disp(FStr)
ind = indFirst+3;
disp(sepStr);

ind = ind+1; disp([infoStr(ind,:) , entName])
ind = ind+1; disp([infoStr(ind,:) , entPar])
disp(sepStr);
disp(' ')
