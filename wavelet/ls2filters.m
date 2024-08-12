function varargout = ls2filters(varargin)
%LS2FILTERS Lifting scheme to filters.
%   VARARGOUT = LS2FILTERS(LS,OPTION) returns numerical 
%   filters or Laurent Polynomial filters associated to
%   the Lifting Scheme LS. The type and the number of
%   outputs depend on OPTION.
%   The valid choices for OPTION are: 
%       'a'
%       'a_num' , 'd_num' , 'p_num'
%       'a_lp'  , 'd_lp'  , 'p_lp'
%    where: 
%      - 'a' , 'd' ans 'p' abbreviate "all", "dual" and "primal"
%        respectively.
%      - 'num' abbreviates "numerically".
%      - 'lp'  abbreviates "Laurent Polynomial".
%
%   LS2FILTERS(LS) is equivalent to LS2FILTERS(LS,'d_num').

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Jan-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(1,2);
[varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});
if nargin <2 
    OPTION = 'd_num';
    LS = varargin{1};
else
    LS = varargin{1};
    OPTION = varargin{2};
end 

OPTION = char(lower(OPTION));

begOPT = OPTION(1);
if (begOPT=='a') || (begOPT=='d') 
    [d_Hs,d_Gs,d_Ha,d_Ga] = ls2lp(LS,'d');
    [d_Lo_R,d_Hi_R,d_Lo_D,d_Hi_D] = getNum_Filters(d_Hs,d_Gs,d_Ha,d_Ga);
end

if (begOPT=='a') || (begOPT=='p')
    [p_Hs,p_Gs,p_Ha,p_Ga] = ls2lp(LS,'p');
    [p_Lo_R,p_Hi_R,p_Lo_D,p_Hi_D] = getNum_Filters(p_Hs,p_Gs,p_Ha,p_Ga);
end

switch OPTION
    case 'a'
        varargout = {...
                d_Lo_D,d_Hi_D,d_Lo_R,d_Hi_R, ...
                p_Lo_D,p_Hi_D,p_Lo_R,p_Hi_R, ...
                d_Ha,d_Ga,d_Hs,d_Gs, ...
                p_Ha,p_Ga,p_Hs,p_Gs,  ...
            };
        
    case 'a_lp'
        varargout = {...
                d_Ha,d_Ga,d_Hs,d_Gs, ...
                p_Ha,p_Ga,p_Hs,p_Gs};
                    
    case 'a_num'
        varargout = {...
                d_Lo_D,d_Hi_D,d_Lo_R,d_Hi_R, ...
                p_Lo_D,p_Hi_D,p_Lo_R,p_Hi_R};
        
    case 'd_lp'  , varargout = {d_Ha,d_Ga,d_Hs,d_Gs};
    case 'd_num' , varargout = {d_Lo_D,d_Hi_D,d_Lo_R,d_Hi_R};
    case 'p_lp'  , varargout = {p_Ha,p_Ga,p_Hs,p_Gs};
    case 'p_num' , varargout = {p_Lo_D,p_Hi_D,p_Lo_R,p_Hi_R};
end

%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function [Lo_R,Hi_R,Lo_D,Hi_D] = getNum_Filters(Hs,Gs,Ha,Ga)

[cfsHs,degHs] = get(Hs,'coefs','maxDEG');
[cfsHa,degHa] = get(Ha,'coefs','maxDEG');
[cfsGs,~] = get(Gs,'coefs','maxDEG');
[cfsGa,~] = get(Ga,'coefs','maxDEG');
POW_Hi_R = mod(1-degHs,2);
POW_Hi_D = mod(1-degHa + length(cfsHa),2);
Lo_R = cfsHs;
Lo_D = wrev(cfsHa);
Hi_R = (-1)^POW_Hi_R * cfsGs;
Hi_D = (-1)^POW_Hi_D * wrev(cfsGa);
% Lo_R = get(Hs,'coefs');
% Hi_R = get(Gs,'coefs');
% Lo_D = get(reflect(Ha),'coefs');
% Hi_D = get(reflect(Ga),'coefs');
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
