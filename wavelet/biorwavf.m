function [Rf,Df] = biorwavf(wname)
%BIORWAVF Biorthogonal spline wavelet filters.
%   [RF,DF] = BIORWAVF(W) returns two scaling filters
%   associated with the biorthogonal wavelet specified
%   by the character vector W.
%   W = 'biorNr.Nd' where possible values for Nr and Nd are:
%       Nr = 1  Nd = 1 , 3 or 5
%       Nr = 2  Nd = 2 , 4 , 6 or 8
%       Nr = 3  Nd = 1 , 3 , 5 , 7 or 9
%       Nr = 4  Nd = 4
%       Nr = 5  Nd = 5
%       Nr = 6  Nd = 8
%   The output arguments are filters:
%   RF is the reconstruction filter
%   DF is the decomposition filter
%
%   See also BIORFILT, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
if nargin > 0
    wname = convertStringsToChars(wname);
end

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

if isempty(find(Nr == [1:5 6], 1))
    error(message('Wavelet:Lifting:InvalidWavNum', Nr));
end
switch Nr
  case 1
      if isempty(find(Nd == 1:2:5, 1))
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
  case 2
      if isempty(find(Nd == 2:2:8, 1))
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
  case 3
      if isempty(find(Nd == 1:2:9, 1))
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
  case 4  
      if Nd ~= 4
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
  case 5  
      if Nd ~= 5  
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
  case 6  
      if Nd ~= 8 
          error(message('Wavelet:Lifting:InvalidWavNum', Nd));
      end
end

switch Nr
  case 1
    Rf = 1/2;
    if Nd == 1
       Df = 1/2;
    elseif Nd == 3
       Df = [-1/16 1/16 1/2];
    elseif Nd == 5
       Df = [3/256 -3/256 -11/128 11/128 1/2];
    end
    Rf = [Rf fliplr(Rf)];
    Df = [Df fliplr(Df)];

  case 2
    Rf = [1/4 1/2 1/4];
    if Nd == 2
       Df = [-1/8 1/4];
       Df = [Df 3/4 fliplr(Df)];
    elseif Nd == 4
       Df = [3/128 -3/64 -1/8 19/64];
       Df = [Df 45/64 fliplr(Df)];
    elseif Nd == 6
       Df = [-5/1024 5/512 17/512 -39/512 -123/1024 81/256];
       Df = [Df 175/256 fliplr(Df)];
    elseif Nd == 8
       Df = [35 -70 -300 670 1228 -3126 -3796 10718];
       Df = [Df 22050 fliplr(Df)]/(2^15);
    end

  case 3
    Rf = [1 3]/8;
    if Nd == 1
       Df = [-1 3]/4;
    elseif Nd == 3
       Df = [3 -9 -7 45]/64;
    elseif Nd == 5
       Df = [-5 15 19 -97 -26 350]/512;
    elseif Nd == 7
       Df = [35 -105 -195 865 363 -3489 -307 11025]/(2^14);
    elseif Nd == 9
       Df = [-63 189 469 -1911 -1308 9188 1140 -29676 190 87318]/(2^17);
    end
    Rf = [Rf fliplr(Rf)];
    Df = [Df fliplr(Df)];

  case 4
    if Nd == 4
       Rf = [-.045635881557,-.028771763114,.295635881557];
       Rf = [Rf .557543526229 fliplr(Rf)];
       Df = [.026748757411,-.016864118443,-.078223266529,.266864118443];
       Df = [Df .602949018236 fliplr(Df)];
    end

  case 5
    if Nd == 5
       Rf = [.009515330511,-.001905629356,-.096666153049,...
                                 -.066117805605,.337150822538];
       Rf = [Rf .636046869922 fliplr(Rf)];
       Df = [.028063009296,.005620161515,-.038511714155,.244379838485];
       Df = [Df .520897409718 fliplr(Df)];
    end

  case 6
    if Nd == 8
       Rf = [...
           -0.01020092218704  ...
           -0.01023007081937  0.05566486077996  0.02854447171515  -0.29546393859292 ...
                 ];
       Rf = [Rf -0.53662880179157 fliplr(Rf)];
       Df = [...
            0.00134974786501 -0.00135360470301 -0.01201419666708   0.00843901203981 ...
            0.03516647330654 -0.05463331368252 -0.06650990062484   0.29754790634571 ...
                 ];
       Df = [Df 0.58401575224075 fliplr(Df)];
       % Df = -Df; % === Modification (July 2003) see WAVE2LP ===
    end
end
