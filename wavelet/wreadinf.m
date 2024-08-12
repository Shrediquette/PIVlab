function [out1,fid] = wreadinf(fname,noerr) %#ok<INUSD>
%WREADINF Read ascii files.
%   [TXT,FID] = WREADINF(FNAME,NOERR) or 
%   [TXT,FID] = WREADINF(FNAME)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% For Japanese local, open ja/fname.m if the file exists.

lang = get(0,'Language');
lang = [lang,'  '];   % Guarantee lang has two chars.
langdir = lang(1:2);

path = fileparts(which(fname));

if exist([path,filesep,langdir, filesep, fname],'file') == 2
     fid = fopen([path, filesep,langdir, filesep, fname], 'r');
else
	 fid = fopen(fname,'r');
end

if fid==-1
    if nargin==2 , out1 = ''; return; end
    errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:File_Error'),'msg');
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
info = fread(fid, '*char');
fclose(fid);
info = (abs(info))';

% tabulation
j = find(info==9);
info(j) = 32*ones(size(j));

out1  = [];
if ~isempty(info)
    ind1  = find(info==10);
    ind2  = find(info==13);
    lind1 = length(ind1);
    lind2 = length(ind2);

    if lind1>0
        i_beg = [1,ind1(1:lind1-1)+1];
        if ~isempty(ind2)
            i_end = ind1-2;
        else
            i_end = ind1-1;
        end
        cols  = i_end-i_beg+1;
        nbcol = max(cols);
        out1  = 32*ones(lind1,nbcol);

        for k = 1:lind1
            out1(k,1:cols(k)) = info(i_beg(k):i_end(k));
        end
    elseif lind2>0
        i_beg = [1,ind2(1:lind2-1)+1];
        i_end = ind2-1;
        cols  = i_end-i_beg+1;
        nbcol = max(cols);
        out1  = 32*ones(lind2,nbcol);

        for k = 1:lind2
            out1(k,1:cols(k)) = info(i_beg(k):i_end(k));
        end
    else
        out1 = info;
    end
end
out1  = char(out1);
r = size(out1,1);
ibeg  = find(out1(:,1)=='%', 1 );
if isempty(ibeg) , out1 = []; return; end   
if ibeg==r
    iend = r; 
else
    j = find(out1(:,1)~='%');
    k = find(j>ibeg);
    if isempty(k)
        iend = r;
    else
        iend = min(j(k))-1; 
    end
end
out1 = out1(ibeg:iend,2:end);
