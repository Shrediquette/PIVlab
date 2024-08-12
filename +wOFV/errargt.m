function [err,fig] = errargt(ndfct,var,type,flagWin) %#ok<INUSD>
%ERRARGT Check function arguments type.
%   ERR = ERRARGT(NDFCT,VAR,TYPE)
%   is equal to 1 if any element of input vector or 
%   matrix VAR (depending on TYPE choice listed below) 
%   is not of type prescribed by input string TYPE.
%   Otherwise ERR = 0.
%
%   If ERR = 1, an error message is displayed in the command
%   window. In the header message, the string NDFCT is
%   displayed. This string contains the name of a function.
%
%   Available options for TYPE are :
%   'int' : strictly positive integers
%   'in0' : positive integers
%   'rel' : integers
%
%   'rep' : strictly positive reals
%   're0' : positive reals
%
%   'str' : string
%
%   'vec' : vector
%   'row' : row vector
%   'col' : column vector
%
%   'dat' : dates   AAAAMMJJHHMNSS
%           with    0 <= AAAA <=9999
%                   1 <= MM <= 12
%                   1 <= JJ <= 31
%                   0 <= HH <= 23
%                   0 <= MN <= 59
%                   0 <= SS <= 59
%
%   'mon' : months  MM
%           with    1 <= MM <= 12
%
%   A special use of ERRARGT is ERR = ERRARGT(NDFCT,VAR,'msg')
%   for which ERR = 1 and the string VAR is the error message.
%
%   See also ERRARGN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 25-Jan-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

[r,c] = size(var);
err = 0;

switch type
    case 'int'
        if (ischar(var) || any(any(var < 1)) || any(any(var ~= fix(var))))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Int_Pos');
        end

    case 'in0'
        if (ischar(var) || any(any(var < 0)) || any(any(var ~= fix(var))))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Int_PosOrZero');
        end

    case 'rel'
        if (ischar(var) ||  any(any(var ~= fix(var))))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Int_Exp');
        end

    case 'rep'
        if (ischar(var) || any(any(var <= 0))) 
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Real_Pos');
        end

    case 're0'
        if (ischar(var) || any(any(var < 0)))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Real_PosOrZero');
        end

    case 'str'
        if any(~ischar(var))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_String_Exp');
        end

    case 'vec'
        if r ~= 1 && c ~= 1
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Vect_Exp');
        end

    case 'row'
        if r ~= 1
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_RowVect_Exp');
        end

    case 'col'
        if c ~= 1
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_ColVect_Exp');
        end

    case 'dat'
        if isempty(var)
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Date_Exp');
        else
            ss = rem(var,100);
            mn = rem(fix(var/100),100);
            hh = rem(fix(var/10000),100);
            jj = rem(fix(var/1000000),100);
            mm = rem(fix(var/100000000),100);
            aa = fix(var/10000000000);
            if any(...
                    ss < 0 | ss > 59 |...
                    mn < 0 | mn > 59 |...
                    hh < 0 | hh > 24 | (hh == 24 & (ss ~= 0 | mn ~= 0)) |...
                    jj < 1 | jj > 31 | ...
                    mm < 1 | mm > 12 | ...
                    aa < 0 | aa > 9999 ...
                    ) 
               err = 1; txt = getWavMSG('Wavelet:commongui:Err_Date_Exp');
            end
        end

    case 'mon'
        if (any(var < 1 | var > 12 | var ~= fix(var)))
            err = 1; txt = getWavMSG('Wavelet:commongui:Err_Month_Exp');
        end

    case 'msg'
        err = 1; txt = var;

    otherwise
        err = 1; txt = getWavMSG('Wavelet:commongui:Err_Undefined');
end
fig = [];
if err == 1
    if size(txt,1) == 1
        msg = [' ' ndfct ' ---> ' txt];
    else
        msg = {[' ' ndfct ' ---> '] ; txt};
    end
    if strcmp(type,'msg')
        txttitle = getWavMSG('Wavelet:commongui:Err_Title');
    else
        txttitle = getWavMSG('Wavelet:commongui:Err_Title_Arg');
    end

    % if GUI is used messages are displayed in a window
    % else the Matlab command window is used.
    %--------------------------------------------------
	st = dbstack;
    % Obtain a char array of calling functions from the stack
    % check if any of the calling functions is a tool. If one of them is a
    % tool, we will using errordlg() to display the error.
    % g1453261
    ToolNames = {'dw1dtool.m','wp1dtool.m','dw2dtool.m', 'wp2dtool.m', ...
        'wvdtool.m', 'wpdtool.m', 'sw1dtool.m','de1dtool.m','re1dtool.m',...
        'cf1dtool.m','sw2dtool.m','cf2dtool.m','wfustool.m',...
        'wmspcatool.m','wmuldentool.m','mdw1dtool.m','wc2dtool.m',...
        'dw3dtool.m','wmp1dtool.m','cwtfttool2.m'};

    callingStack = char(st.file);
    numcalling = size(callingStack,1);
    appcall = false(numcalling,length(ToolNames));
    for rowidx = 1:numcalling
        appcall(rowidx,:) = strcmpi(deblank(callingStack(rowidx,:)),ToolNames);
    end
    
    if nargin<4 
        flagWin = 1; 
    end
    appcall = appcall(:);
    if any(appcall)
        fig = errordlg(msg,txttitle,'modal');
    else
    
        lenmsg = length(msg); len = lenmsg+2;
        star   = '*'; star  = star(:,ones(1,len));
        minus  = '-'; minus = minus(:,ones(1,len));
        disp(' ')
        disp(star);
        disp(txttitle);
        disp(minus);
        if iscell(msg)
            for k =1:length(msg) , disp(msg{k}); end
        else
            disp(msg);
        end
        disp(star);
        disp(' ')
    
    end
end


