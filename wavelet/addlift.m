function LSN = addlift(LS,varargin)
%ADDLIFT Add primal or dual lifting steps.
%   LSN = ADDLIFT(LS,ELS) returns the new lifting
%   scheme LSN obtained by appending the elementary
%   lifting step ELS to the lifting scheme LS.
%   
%   LSN = ADDLIFT(LS,ELS,'begin') prepends the specified 
%   elementary lifting step.
% 
% 	ELS is either a cell array (see LSINFO) which format is: 
%        {TYPEVAL, COEFS, MAX_DEG}  
% 	or a structure (see LIFTFILT) which format is:
%         struct('type',TYPEVAL,'value',LPVAL) 
% 	with LPVAL = laurpoly(COEFS, MAX_DEG)
%
%   ADDLIFT(LS,ELS,'end') is equivalent to ADDLIFT(LS,ELS).
%
% 	If ELS is a sequence of elementary lifting steps, stored 
% 	in a cell array or an array of structures, then each of
% 	the elementary lifting steps is added to LS.
%
%   For more information about lifting schemes type: lsinfo.
%   
%   Examples:
%      LS = liftwave('db1')
%      els = { 'p', [-1 2 -1]/4 , 1 };
%      LSend = addlift(LS,els)
%      LSbeg = addlift(LS,els,'begin')
%      displs(LSend)
%      displs(LSbeg)
%      twoels(1) = struct('type','p','value',laurpoly([1 -1]/8,0));
%      twoels(2) = struct('type','p','value',laurpoly([1 -1]/8,1));
%      LStwo = addlift(LS,twoels)
%      displs(LStwo)
%
%   See also LIFTFILT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-May-2001.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(2,3);

% Convert any strings in the structure array
[LS] = wavelet.internal.wconvertStringsToChars(LS);
[varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});

ELS = varargin{1};

if numel(varargin) == 2
    loc = varargin{2};
end

if nargin<3 ,loc = 'end'; end
loc = lower(loc(1:3));
structMODE = isstruct(ELS);
if structMODE
    switch loc
        case 'end' 
            LSN =  LS(1:end-1,:);
            for k = 1:length(ELS)
                [C,D] = get(ELS(k).value,'coefs','maxDEG');
                one_els = {ELS(k).type,C,D};
                LSN = [LSN ; one_els]; %#ok<*AGROW>
            end
            LSN = [ LSN ; LS(end,:) ];
            
        case 'beg' 
            LSN =  LS;
            for k = 1:length(ELS)
                [C,D] = get(ELS(k).value,'coefs','maxDEG');
                one_els = {ELS(k).type,C,D};
                LSN = [one_els ; LSN];
            end
    end
    return
end

cellMODE = ~(isequal(ELS{1,1},'p') || isequal(ELS{1,1},'d'));
if ~cellMODE
    switch loc
        case 'end' 
            LSN = [ LS(1:end-1,:) ; ELS ; LS(end,:) ];
        case 'beg'   
            LSN = [ ELS ; LS ];         
    end    
else
    switch loc
        case 'end' 
            LSN =  LS(1:end-1,:);
            for k = 1:length(ELS)
                LSN = [ LSN ; ELS{k}];
            end
            LSN = [ LSN ; LS(end,:) ];
            
        case 'beg' 
            LSN =  LS;
            for k = 1:length(ELS)
                LSN = [ ELS{k} ; LSN ];
            end
    end
end
