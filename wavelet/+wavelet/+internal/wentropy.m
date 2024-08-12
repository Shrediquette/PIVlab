function ent = wentropy(x,t_ent,in3)
%WENTROPY Entropy (wavelet packet).
%   E = WENTROPY(X,T,P) returns the entropy E of the
%   vector or matrix X. 
%   In both cases, output E is a real number.
%
%   T is a string containing the type of entropy:
%     T = 'shannon', 'threshold', 'norm',
%         'log energy' (or 'logenergy'), 'sure', 'user'.
%   or
%     T = FunName (which is any other string except those
%         previous Entropy Type Name listed above).
%         FunName is the MATLAB file name of your own
%         entropy function. 
%
%   P is an optional parameter depending on the value of T:
%     If T = 'shannon' or 'log energy', P is not used.
%     If T = 'threshold' or 'sure', P is the threshold
%     and must be a positive number.
%     If T = 'norm', P is the power and must be such that 1 <= P.
%     If T = 'user', P is a string containing the MATLAB file name
%     of your own entropy function, with a single input X.
%     If T = FunName, P is an optional parameter with no constraints.     
%
%   E = WENTROPY(X,T) is equivalent to E = WENTROPY(X,T,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 16-Aug-2012.
%   Copyright 1995-2022 The MathWorks, Inc.

% Check arguments.
if nargin > 1 && isStringScalar(t_ent)
    t_ent = convertStringsToChars(t_ent);
end

if nargin > 2 && isStringScalar(in3)
    in3 = convertStringsToChars(in3);
end

narginchk(2,3);
x = double(x(:));
switch t_ent
    case 'shannon'       % in3 not used.
      x = x(x~=0).^2;
      ent = -sum(x.*log(eps+x));

    case 'threshold'     % in3 is the threshold.
      if nargin==2 || isempty(in3) || ischar(in3) || in3<0 , errStop; end
      x = abs(x);
      ent = sum(x > in3);

    case 'sure'          % in3 is the threshold.
      if nargin==2 || isempty(in3) || ischar(in3) || in3<0 , errStop; end
      n = length(x);
      x2 = x.^2; t2 = in3.^2;
      xgt =  sum(x2 > t2); xlt = n - xgt;
      ent = n - (2*xlt) + (t2*xgt) + sum(x2.*(x2 <= t2));

    case 'norm'          % in3 = p , ent = (lp_norm)^p.
      if nargin==2 || isempty(in3) || ischar(in3) || in3<1 , errStop; end
      x = abs(x);
      ent = sum(x.^in3);

    case {'energy','log energy','logenergy'}     % in3 not used.
      x = x(x~=0).^2;
      ent = sum(log(x));

    case 'user'  % in3 = '<function>' , user entropy.
      if nargin==2 || isempty(in3) || ~ischar(in3) , errStop; end
      ent = feval(in3,x);

    otherwise
      %-----------------------------------------------------------%  
      % Bug & Generalization: temporary Patch (M.M. 20 June 2001) %
      % For user defined entropy.                                 %
      %-----------------------------------------------------------%        
      try
          k = find(t_ent=='&');
          entFunct = t_ent(k+1:end);
          ent = feval(entFunct,x);
      catch %#ok<*CTCH>
          try
              if nargin==2 
                  ent = feval(t_ent,x);
              else
                  ent = feval(t_ent,x,in3);
              end
          catch
              errStop;
          end
      end
end

prec = 1.0E-10;
if abs(ent)<prec , ent = 0; end

% Internal Function
function errStop
errargt(mfilename,...
    getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'),'msg');
error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
