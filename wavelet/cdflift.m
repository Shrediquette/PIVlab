function LS = cdflift(wname)
%CDFLIFT Cohen-Daubechies-Feauveau lifting schemes.
%   LS = CDFLIFT(WNAME) returns the lifting scheme specified
%   by WNAME. The valid values for WNAME are:
%    'cdf1.1', 'cdf1.3', 'cdf1.5' - 'cdf2.2', 'cdf2.4', 'cdf2.6'
%    'cdf3.1', 'cdf3.3', 'cdf3.5' - 'cdf4.2', 'cdf4.4', 'cdf4.6'
%    'cdf5.1', 'cdf5.3', 'cdf5.5' - 'cdf6.2', 'cdf6.4', 'cdf6.6'
%
%   A lifting scheme LS is a N x 3 cell array such that:
%     for k = 1:N-1
%       | LS{k,1} is the lifting "type" 'p' (primal) or 'd' (dual).
%       | LS{k,2} is the corresponding lifting filter.
%       | LS{k,3} is the higher degree of the Laurent polynomial
%       |         corresponding to the previous filter LS{k,2}.
%     LS{N,1} is the primal normalization.
%     LS{N,2} is the dual normalization.
%     LS{N,3} is not used.
%
%   For more information about lifting schemes type: lsinfo.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Feb-2000.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

wname = wname(4:end);
kdot = find(wname=='.');
if length(kdot)~=1
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
lw = length(wname);
Nd = str2num(wname(kdot+1:lw));
wname = wname(1:kdot-1);
lw = length(wname);
ab = abs(wname);
ii = lw+1;
while (ii>1) && (47<ab(ii-1)) && (ab(ii-1)<58), ii = ii-1; end
Nr = str2num(wname(ii:lw));

if isempty(find(Nr == [1:5 6],1))
    error(message('Wavelet:Lifting:InvalidWavNum', Nr));
end
switch Nr
  case 1
    if isempty(find(Nd == 1:2:5,1))
    error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',-1,0};
    switch Nd
      case 1 , LS(2,:) = {'p',1/2,0};
      case 3 , LS(2,:) = {'p',[-1 8 1]/16,1};
      case 5 , LS(2,:) = {'p',[3 -22 128 22 -3]/256,2};
    end
    LS(3,:) = {sqrt(2),sqrt(2)/2,[]};   

  case 2
    if isempty(find(Nd == 2:2:6,1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',[-1 -1]/2,1};
    switch Nd
      case 2 , LS(2,:) = {'p',[1 1]/4,0};
      case 4 , LS(2,:) = {'p',[-3 19 19 -3]/64,1};
      case 6 , LS(2,:) = {'p',[5 -39 162 162 -39 5]/512,2};
    end
    LS(3,:) = {sqrt(2),sqrt(2)/2,[]};

  case 3
    if isempty(find(Nd == 1:2:5,1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'p',-1/3,-1;'d',[-3 -9]/8,1};
    switch Nd
      case 1 , LS(end+1,:) = {'p',4/9,0};
      case 3 , LS(end+1,:) = {'p',[-3 16 3]/36,1};
      case 5 , LS(end+1,:) = {'p',[5 -34 128 34 -5]/288,2};
    end
    LS(end+1,:) = {3*sqrt(2)/2,sqrt(2)/3,[]};

  case 4
    if isempty(find(Nd == 2:2:6,1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'p',[-1 -1]/4,0;'d',[-1 -1],1};
    switch Nd
      case 2 , LS(end+1,:) = {'p',[3 3]/16,0};
      case 4 , LS(end+1,:) = {'p',[-5 29 29 -5]/128,1};
      case 6 , LS(end+1,:) = {'p',[35 -265 998 998 -265 35]/4096,2};
    end
    LS(end+1,:) = {2*sqrt(2),sqrt(2)/4,[]};

  case 5
    if isempty(find(Nd == 1:2:5,1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',-1/5,0;'p',[-5 -15]/24,0;'d',[-9 -15]/10,1};
    switch Nd
      case 1 , LS(end+1,:) = {'p',1/3,0};
      case 3 , LS(end+1,:) = {'p',[-5 24 -5]/72,1};
      case 5 , LS(end+1,:) = {'p',[35 -230 768 230 -35]/2304,2};
    end
    LS(end+1,:) = {3*sqrt(2),sqrt(2)/6,[]};

  case 6
    if isempty(find(Nd == 2:2:6,1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',[-1 -1]/6,1;'p',[-9 -9]/16,0;'d',[-4 -4]/3,1};
    switch Nd
      case 2 , LS(end+1,:) = {'p',[5 5]/32,0};
      case 4 , LS(end+1,:) = {'p',[-35 195 195 -35]/1024,1} ;
      case 6 , LS(end+1,:) = {'p',[63 -469 1686 1686 -469 63]/8192,2};
    end
    LS(end+1,:) = {4*sqrt(2),sqrt(2)/8,[]};
end
