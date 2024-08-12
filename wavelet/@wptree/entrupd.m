function t = entrupd(t,ent,in3)
%ENTRUPD Entropy update (wavelet packet tree).
%   T = ENTRUPD(T,ENT) or  T = ENTRUPD(T,ENT,PAR) 
%   updates the entropy of wavelet packet tree T 
%   using the entropy function ENT with optional
%   parameter PAR (see WENTROPY for more information).
%
%   See also WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==2
    par = 0;
else
    par = in3;
end
if isStringScalar(ent)
    ent = convertStringsToChars(ent);
end

if nargin > 2 && isStringScalar(in3)
    in3 = convertStringsToChars(in3);
end


if strcmpi(ent,'user')
    if ~ischar(par)
        error(message('Wavelet:FunctionArgVal:Invalid_EntNam'));
    end
end

% Keep tree nodes.
nods      = read(t,'an');
ent_nods  = zeros(size(nods));
ento_nods = NaN;
ento_nods = ento_nods(ones(size(nods)));

% Update entropy.
for i = 1:length(nods)
    % read or reconstruct packet coefficients.
    if istnode(t,nods(i))
        coefs = read(t,'data',nods(i));
    else
        coefs = wpcoef(t,nods(i));
    end
    % compute entropy.
    ent_nods(i) = wentropy(coefs,ent,par);
end

% Update data structure.
t = write(t, ...
          'entname',ent,        ...
          'entpar',par,         ...
          'ent',ent_nods,nods,  ...
          'ento',ento_nods,nods ...
          );
