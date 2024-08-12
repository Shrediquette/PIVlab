function sameswfplot(wname,powMAX)
%SAMESWFPLOT Same BSWFUN and WAVEFUN plots.
%   Command line: SAMESWFPLOT(wname,powMAX)
%      SAMESWFPLOT        <==> SAMESWFPLOT('bior1.3',0) 
%      SAMESWFPLOT(wname) <==> SAMESWFPLOT(wname,0)
%
%   See also BSWFUN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Jul-2003.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

switch nargin
    case 0 , powMAX = 0; wname = 'bior1.3'; 
    case 1 , powMAX = 0; 
end
iter = 10;
wavefun(wname,iter,'plot');
[LoD_A,HiD_A,LoR_A,HiR_A] = wfilters(wname);
[Hs,Gs,Ha,Ga,PRCond,AACond] = wave2lp(wname,powMAX); %#ok<ASGLU>
[LoD_B,HiD_B,LoR_B,HiR_B] = lp2filters(Ha,Ga,Hs,Gs);
bswfun(LoD_B,HiD_B,LoR_B,HiR_B,iter,'plot');

sep = '-';
sep = sep(ones(1,75));
disp(sep)
disp(getWavMSG('Wavelet:moreMSGRF:Str_WaveName',wname));
disp('%----+----+----+----%')
disp(['LoD_A: ',sprintf('%9.4f',LoD_A)]);
disp(['HiD_A: ',sprintf('%9.4f',HiD_A)]);
disp(['LoR_A: ',sprintf('%9.4f',LoR_A)]);
disp(['HiR_A: ',sprintf('%9.4f',HiR_A)]);
disp(' ');
disp(['LoD_B: ',sprintf('%9.4f',LoD_B)]);
disp(['HiD_B: ',sprintf('%9.4f',HiD_B)]);
disp(['LoR_B: ',sprintf('%9.4f',LoR_B)]);
disp(['HiR_B: ',sprintf('%9.4f',HiR_B)]);
disp(' ');
disp(sep)
