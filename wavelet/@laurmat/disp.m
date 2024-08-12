function varargout = disp(M,varName)
%DISP Display a Laurent matrix object as text.
%   DISP(M) displays the Laurent matrix M printing 
%   the matrix name (here: M). 
%   DISP(M,VarName) uses "VarName" as matrix name.
%
%   Example:
%      % Create a Laurent matrix
%      Z = laurpoly(1,1);  
%      M = laurmat({1 Z;0 1})
%
%      % Display the Laurent matrix
%      disp(M)
%      disp(M,'Matrix')

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 06-Mai-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1 && isStringScalar(varName)
    varName = convertStringsToChars(varName);
end

if nargin<2 , varName = inputname(1); end

flagHeadSep = false;
headerSTR = [...
    ' Laurent matrix object '
    '======================='
    ];

lenSEP = size(headerSTR,2);

[nbRow,nbCol] = size(M.Matrix);
lenCOLS = zeros(1,nbCol);
lenROWS = zeros(1,nbRow);
coefSTR = cell(nbRow,nbCol);
sizeSTR = cell(nbRow,nbCol);
for i=1:nbRow
    for j=1:nbCol
        coefSTR{i,j} = lpstr(M.Matrix{i,j},30);
        sizeSTR{i,j} = size(coefSTR{i,j});
        if sizeSTR{i,j}(1)>lenROWS(i) , lenROWS(i) = sizeSTR{i,j}(1); end
        if sizeSTR{i,j}(2)>lenCOLS(j) , lenCOLS(j) = sizeSTR{i,j}(2); end
    end
end
Sum_lenCOLS = sum(lenCOLS);

if Sum_lenCOLS<100
    dispSTR  = '';
    for i=1:nbRow
        colSTR = '';
        for j=1:nbCol
            blankSTR = repmat(' ',lenROWS(i),lenCOLS(j));
            tmpSTR = fullSTR(blankSTR,coefSTR{i,j},'cu');
            if j<nbCol , tmpSTR = [tmpSTR , repmat(' ',size(tmpSTR,1),4)]; end
            colSTR = [colSTR , tmpSTR];
        end
        dispSTR = [dispSTR ; colSTR];
        if i<nbRow , dispSTR = [dispSTR ; repmat(' ',3,size(dispSTR,2))]; end
    end
    rows = size(dispSTR,1);
    dispSTR = [repmat('| ',rows,1) , dispSTR , repmat(' |',rows,1)];
    if isempty(varName)
        varNameSTR = '';
    else
        varNameSTR = [' ' , varName ' = '];
    end
    
    lenVAR = length(varNameSTR);
    tmpSTR = fullSTR(repmat(' ',rows,lenVAR),varNameSTR,'cc');
    dispSTR = [tmpSTR , dispSTR];
    
    if size(dispSTR,2)>lenSEP , lenSEP = size(dispSTR,2); end
    if nargout==0
        disp(' ');
        if flagHeadSep
            disp(headerSTR); disp(' ');
        end
        disp(dispSTR);
        if flagHeadSep
            sepSTR = repmat('=',1,lenSEP+2);
            disp(' '); disp(sepSTR); disp(' ');
        end
    else
        varargout{1} = dispSTR;
    end
    
else
    if flagHeadSep
        disp(' '); disp(headerSTR);
    end
    for i=1:nbRow
        for j=1:nbCol
            posSTR = [varName '(' int2str(i) ',' int2str(j) ') = '];
            dispSTR = lpstr(M.Matrix{i,j},60);
            if size(dispSTR,1)==1
                dispSTR = [posSTR dispSTR];
                posSTR  = '';
            else
                posSTR = [posSTR ' ...'];
            end
            len = size(dispSTR,2)+1;
            if len>lenSEP , lenSEP = len; end
            sepSTR  = repmat('-',1,lenSEP);	
            disp(posSTR);
            disp(dispSTR);
            disp(sepSTR);
        end
    end
    if flagHeadSep
        sepSTR  = repmat('=',1,lenSEP+2);	
        disp(sepSTR);
        disp(' ')
    end
end


%------------------------------------------------------------------------%
function Str1 = fullSTR(Str1,Str2,option)

if nargin<3 , option = 'lu'; end
s1 = size(Str1);
s2 = size(Str2);
switch option(1)
    case 'l' , cBEG = 1; cEND = s2(2);
    case 'c' , cBEG = 1+floor((s1(2)-s2(2))/2); cEND = cBEG + s2(2)-1;
end
switch option(2)
    case 'u' , rBEG = 1; rEND = s2(1);
    case 'c' , rBEG = 1+floor((s1(1)-s2(1))/2); rEND = rBEG + s2(1)-1;
end
Str1(rBEG:rEND,cBEG:cEND) = Str2;
%------------------------------------------------------------------------%
