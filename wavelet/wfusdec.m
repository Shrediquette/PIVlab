function [Dfus,Tfus] = wfusdec(D1,D2,AfusMeth,DfusMeth)
%WFUSDEC Fusion of two wavelet decompositions.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Jan-2003.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin==3 , DfusMeth = AfusMeth; end

okTREE = false;
if isa(D1,'wdectree') && isa(D2,'wdectree')
    okTREE = true;
    Tfus = D1;
    tn = leaves(D1);
    D1 = read(D1,'data',tn);
    tn = leaves(D2);
    D2 = read(D2,'data',tn);
end
if iscell(D1) && iscell(D2)
    nbCell = length(D1);
    Dfus   = cell(size(D1));
    Dfus{1} = wfusmat(D1{1},D2{1},AfusMeth);
    for k=2:nbCell
        Dfus{k} = wfusmat(D1{k},D2{k},DfusMeth);
    end
    if okTREE
        Tfus = write(Tfus,'data',Dfus);
        Dfus = rnodcoef(Tfus);
    end
else
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
