function out1 = wimgcode(option,in2,in3,in4,in5,in6)
%WIMGCODE Image coding mode.
%   OUT1 = WIMGCODE(OPTION,IN2,IN3,IN4,IN5,IN6)
              
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Jul-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

switch option
    case 'get'  
		if nargin==1
			out1 = 1;
		else
			out1 = wfigmngr('get_CCM_Menu',in2);
		end
		
    case 'cod'
      % in2 = flag for coding
      % in3 = matrix to encode
      % in4 = number of class
      % in5 = flag absolute value
      % in6 = optional (trunc parameters)
      %   in6(1)   = lev;
      %   in6(2:3) = size init
      %----------------------------------
      if in2==0
          out1 = in3;
      else
          nb = in4;
          out1 = ones(size(in3));
          if in5==1 , in3 = abs(in3); end
          in3  = in3-min(in3(:));
          maxx = max(in3(:));
          if maxx>=sqrt(eps)
              mul  = nb/maxx;
              out1 = reshape(fix(1 + mul*in3),size(in3));
              out1(out1>nb) = nb;
          end
      end
      if ~ismatrix(out1) , out1 = uint8(out1); end
      if nargin==6
          lev = in6(1);
          if lev==0 , return; end
          sx = in6(2:3);
          for k = 1:lev , sx = floor((sx+1)/2); end
          out1 = wkeep2(out1,sx);
      end
end
