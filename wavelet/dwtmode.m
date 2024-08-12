function varargout = dwtmode(option,varargin)
%DWTMODE Discrete wavelet transform extension mode.
%   DWTMODE sets the signal or image extension mode for
%   discrete wavelet and wavelet packet transforms.
%   The extension modes represent different ways of handling
%   the problem of border distortion in the analysis.
%
%   DWTMODE or DWTMODE('status') display the current mode.
%   ST = DWTMODE or ST = DWTMODE('status') display and
%   return the current mode.
%   ST = DWTMODE('status','nodisp') returns the current mode
%   and does not display the text.
%
%   DWTMODE('sym') or DWTMODE('symh') sets the DWT mode to 
%   symmetric-padding (half-point): boundary value symmetric
%   replication - default mode.
%
%   DWTMODE('symw') sets the DWT mode to symmetric-padding
%   (whole-point): boundary value symmetric replication.
%
%   DWTMODE('asym') or DWTMODE('asymh') sets the DWT mode to 
%   antisymmetric-padding (half-point): boundary value 
%   antisymmetric replication.
%
%   DWTMODE('asymw') sets the DWT mode to antisymmetric-padding
%   (whole-point): boundary value antisymmetric replication.
%
%   DWTMODE('zpd') sets the DWT mode to zero-padding
%
%   DWTMODE('spd') or DWTMODE('sp1') sets the DWT mode 
%      to smooth-padding of order 1 (first derivative
%      interpolation at the edges).
%
%   DWTMODE('sp0') sets the DWT mode to smooth-padding
%      of order 0 (constant extension at the edges). 
%
%   DWTMODE('ppd') sets the DWT mode to periodic-padding
%      (periodic extension at the edges).
%
%   The DWT associated with these eight modes is slightly  
%   redundant. But IDWT ensures a perfect reconstruction for any
%   of the five previous modes whatever is the extension mode 
%   used for DWT.
%
%   DWTMODE('per') sets the DWT mode to periodization.
%        
%   This mode produces the smallest length wavelet decomposition.
%   But, the extension mode used for IDWT must be the same to
%   ensure a perfect reconstruction.
%   Using this mode, DWT and DWT2 produce the same results as 
%   the obsolete functions DWTPER and DWTPER2, respectively.
%
%   All functions and GUI tools that use the DWT (1-D & 2-D) or
%   Wavelet Packet (1-D & 2-D) use the specified DWT extension mode.
%
%   DWTMODE updates a global variable allowing the use of these
%   six signal extensions. The extension mode should only 
%   be changed using this function. Avoid changing the global 
%   variable directly.
%
%   --------------------------------------------------------------
%   The default mode is loaded from the file DWTMODE.DEF
%   if it exists. If not, the file DWTMODE.CFG 
%   (in the "toolbox/wavelet/wavelet" directory) is used.
%   DWTMODE('save',mode) saves "mode" as new default mode
%   in the file DWTMODE.DEF (all the files named DWTMODE.DEF 
%   are deleted before saving).
%   DWTMODE('save') is equivalent to DWTMODE('save',currentMode).
%   --------------------------------------------------------------
%
%   See also DWT, DWT2 ,IDWT, IDWT2, WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Internal options: 'load', 'save', 'get', 'set', 'clear'
 
if nargin > 0
    option = convertStringsToChars(option);
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin==0 , option = 'status'; else option = lower(option); end
DWT_Attribute = getappdata(0,'DWT_Attribute');
switch option
    case 'load'
        if exist('dwtmode.def','file')
            load('dwtmode.def','-mat');
            DWT_Attribute = dwt_default_Attrb;   %#ok<NODEF>
        elseif exist('dwtmode.cfg','file')
            load('dwtmode.cfg','-mat');
            DWT_Attribute = dwt_default_Attrb; %#ok<NODEF>
        else
            DWT_Attribute = ...
                struct('extMode','sym','shift1D',0,'shift2D',[0,0]);
        end
        setappdata(0,'DWT_Attribute',DWT_Attribute);
        if nargout>0 , varargout{1} = DWT_Attribute; end

    case 'save'
        if nargin<2
            if isempty(DWT_Attribute), DWT_Attribute = dwtmode('load'); end
            extM = DWT_Attribute.extMode;
        else
            extM = varargin{1};
        end
        if isequal(extM,'zpd')  || ...
           isequal(extM,'sym')  || isequal(extM,'symh')  || ...
           isequal(extM,'asym') || isequal(extM,'asymh') || ...
           isequal(extM,'symw') || isequal(extM,'asymw') || ...
           isequal(extM,'sp0')  || isequal(extM,'spd')   || ...
           isequal(extM,'sp1')  || isequal(extM,'ppd')   || isequal(extM,'per')

            try
              extM = trueExtName(extM);  
              dwt_default_Attrb = ...
                       struct('extMode',extM, 'shift1D',0,'shift2D',[0,0]);  %#ok<NASGU>
              namefileSave = 'dwtmode.def';
              s = which(namefileSave,'-all');
              try delete(s{:}); catch , end %#ok<CTCH>
              save(namefileSave,'dwt_default_Attrb');
              msg = char(...
                  getWavMSG('Wavelet:moreMSGRF:DWTMode_SaveInFile',namefileSave),...
                            getWavMSG('Wavelet:moreMSGRF:DWTMode_Default',extM)); 
              msgval = 1;
            catch %#ok<CTCH>
              msg = getWavMSG('Wavelet:moreMSGRF:DWTMode_SaveFail');
              msgval = 2;
            end
        else
           msg = getWavMSG('Wavelet:moreMSGRF:DWTMode_Invalid');
           msgval = 2;
        end
        if isequal(get(0,'UserData'),'testWTBX') , msgval = 3; end
        switch msgval
          case 1 , wwarndlg(msg,getWavMSG('Wavelet:moreMSGRF:DWTMode_SaveStr'),'modal');
          case 2 , errordlg(msg,getWavMSG('Wavelet:moreMSGRF:DWTMode_SaveStr'),'modal');
          case 3 , sep = repmat('-',1,size(msg,2)+2);
                   disp(char(sep,msg,sep)); 
        end

    case 'set'
        for k = 1:2:nargin-1
            switch varargin{k}
              case {'extMode','mode'} 
                  extM = trueExtName(varargin{k+1});
                  DWT_Attribute.extMode = extM;
              case 'shift1D' , DWT_Attribute.shift1D = mod(varargin{k+1},2);
              case 'shift2D' , DWT_Attribute.shift2D = mod(varargin{k+1},2);
              otherwise 
                  errargt(mfilename,'Invalid field name','msg');
                  error(message('Wavelet:FunctionArgVal:Invalid_Input'));
            end
        end
        setappdata(0,'DWT_Attribute',DWT_Attribute)

    case 'get'
        if isempty(DWT_Attribute) , DWT_Attribute = dwtmode('load'); end
        switch nargout
            case 1 , varargout = {DWT_Attribute};
            case 2 , varargout = {...
                        DWT_Attribute.extMode , ...
                        DWT_Attribute.shift1D};
            case 3 , varargout = {...
                        DWT_Attribute.extMode , ...
                        DWT_Attribute.shift1D , ...
                        DWT_Attribute.shift2D};
        end
        
    case 'clear'
        if isappdata(0,'DWT_Attribute') , rmappdata(0,'DWT_Attribute'); end

    case {'zpd','sym','symh','symw','asym','asymh','asymw',...
          'sp0','spd','sp1','ppd','per','status'}
        % Check arguments.
        nbIn  = nargin;
        nbOut = nargout;
        if nbIn > 2
            error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
        elseif nbOut > 1
            error(message('Wavelet:FunctionOutput:TooMany_ArgNum'));
        end
        if isempty(DWT_Attribute) , DWT_Attribute = dwtmode('load'); end
        option = trueExtName(option);
        if ~isequal(option,'status') && ~isequal(DWT_Attribute.extMode,option)
            DWT_Attribute.extMode = option;
            setappdata(0,'DWT_Attribute',DWT_Attribute);
            numMsg = 1;
        else
            numMsg = 2;
        end
        if nbIn<2 , dispMessage(numMsg,DWT_Attribute.extMode); end
        if nbOut==1 , varargout{1} = DWT_Attribute.extMode; end

    otherwise
        errargt(mfilename, ...
            getWavMSG('Wavelet:moreMSGRF:DWTMode_Unknown'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end


%----------------------------------------------------------------------------%
% Internal Function(s)
%----------------------------------------------------------------------------%
function dispMessage(num,mode)
if num<2
    S = getWavMSG('Wavelet:moreMSGRF:DWTMode_WARNING');
    lenS = length(S);
    sep = repmat('!',1,lenS);
    disp(' '); disp(sep); disp(S);disp(sep);
end
% Display Extension Mode.
switch mode
    case 'zpd' ,            Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_ZPD');
    case {'sym','symh'} ,   Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_SYMH');
    case 'symw' ,           Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_SYMW');
    case {'asym','asymh'} , Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_ASYMH');
    case 'asymw' ,          Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_ASYMW');
    case 'sp0' ,            Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_SP0');
    case {'spd','sp1'} ,    Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_SP1');
    case 'ppd' ,            Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_PPD');
    case 'per' ,            Name = getWavMSG('Wavelet:moreMSGRF:DWTMode_PER');
end
msg = getWavMSG('Wavelet:moreMSGRF:DWTMode_NAME_INI',Name);

n = length(msg)+8;
c = '*';
s = c(ones(1,n));
msg = char(' ',s,[c c '  ' msg '  ' c c],s,' '); 
disp(msg);
%----------------------------------------------------------------------------%
function output = trueExtName(input)
switch input
    case {'sp1','spd'}  , output = 'spd';
    case {'sym','symh'} , output = 'sym';
    case {'asym','asymh'} , output = 'asym';
    otherwise , output = input;
end
%----------------------------------------------------------------------------%
