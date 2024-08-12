function val = wwaitans(fig,quest,default,cancel)
%WWAITANS Wait for an answer to a question.
%   VAL = WWAITANS(FIG,MSG) returns 1 if the answer to
%   question quest is yes and 0 if not.
%
%   VAL = WWAITANS(FIG,MSG,DEF) sets the default answer
%   to "no" (DEF = 2) or "yes" in the other case.
%
%   VAL = WWAITANS(FIG,MSG,DEF,CANCEL) returns 1 
%   if the answer to question quest is yes, 0 if
%   the answer to question quest is no and -1 otherwise.
%
%   A waiting message is displayed in the figure FIG,
%   if FIG is empty or doesn't exist, no message is
%   displayed.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Jul-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<3
    default = 1; cancel = 0;
elseif nargin<4
    if (default~=1) || (default~=2) , default = 1; end 
    cancel = 0;
else
    if (default~=1) || (default~=2) || (default~=3), default = 1; end
    if ~isequal(cancel,0) , cancel = 1; end
end

% Begin waiting.
%---------------
figtit = getWavMSG('Wavelet:commongui:WaitDLGNam');
if iscell(fig)
    figtit = fig{2};
    fig    = fig{1};
    Ok_fig = ishandle(fig);
else
    Ok_fig = ishandle(fig);
    if Ok_fig , figtit = get(fig,'Name'); end
end
if Ok_fig , wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitAns')); end
if cancel 
    answers = { ...
        getWavMSG('Wavelet:commongui:Str_Yes'), ...
        getWavMSG('Wavelet:commongui:Str_No'), ...
        getWavMSG('Wavelet:commongui:Str_Cancel') ...
        };
else
    answers = { ...
        getWavMSG('Wavelet:commongui:Str_Yes'), ...
        getWavMSG('Wavelet:commongui:Str_No')  ...
        };
end
Answer_Quest = questdlg(quest,figtit,answers{:},answers{default});
Answer_Quest = deblankl(Answer_Quest);
ValAns = find(strcmpi(Answer_Quest,answers));
if isempty(ValAns) , ValAns = 2; end
switch ValAns
    case 1 , val =  1;
    case 2 , val =  0;
    otherwise  , val = -1;
end

% End waiting.
%-------------
if Ok_fig , wwaiting('off',fig); end
