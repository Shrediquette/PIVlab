function varargout = wmemtool(option,varargin)
%WMEMTOOL Manage memory tool.
%
% GENERAL BUFFER OPTIONS
%-----------------------
%   'handle' , 'create' , 'close', 'empty' ,
%   'put', 'get', 'del', 'find'.
%  
%   HDL = WMEMTOOL('handle')
%   HDL = WMEMTOOL('create')
%   WMEMTOOL('close')
%   WMEMTOOL('empty')
%   WMEMTOOL('put',NAME,VAL) or wmemtool('put',NAME,VAL,STRINFO)
%   creates if buffer is not found.
%
%   VAL = WMEMTOOL('get',NAME,STRINFO)
%   returns [] if variable named "NAME" is not found.
%
%   WMEMTOOL('del',NAME,VAL) or WMEMTOOL('del',NAME,VAL,STRINFO)
%
%   REP = WMEMTOOL('find') returns 1 if buffer exists else
%   0 is returned.
%
%  BUFFER IN A FIGURE OPTIONS
%----------------------------
%   T = WMEMTOOL('ini',FIG,BLOCNAME,NBVAL)
%   T = WMEMTOOL('hmb',FIG,BLOCNAME)
%   T is the handle of the text which contains the MemBloc.
%
%   WMEMTOOL('wmb',FIG,BLOCNAME,IND1,V1,...,IND12,V12),
%   [V1,..V12] = WMEMTOOL('rmb',FIG,BLOCNAME,IND1,...,IND12),
%   with : Vj = jth value and INDj = jth index in the MemBloc.
%
%   WMEMTOOL('dmb',FIG,BLOCNAME) deletes the MemBloc.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision 04-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.14.4.7 $

% Tag for GENERAL BUFFER.
%------------------------
tag_fig_mem = 'Fig_Mem_Buffer';
tag_axe_mem = 'Axe_Mem_Buffer';

% Show Buffers.
%--------------
old_show = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

option = option(1:3);

%-----------------------------%
%                             %
%  BUFFER IN A FIGURE OPTIONS %
%                             %
%-----------------------------%

switch option
    case 'rmb'
        %******************************************%
        %** OPTION = 'rmb' - reading in MemBloc. **%
        %******************************************%
        % win_handle = in2
        % bloc_name  = in3
        % if nargin>3
        %    in(k+3) index and out(k) value.
        %-----------------------------------
        varargout{1} = [];
        fig = varargin{1};
        [okFig,axe_mem] = bufferInFig(fig,tag_axe_mem);
        if okFig && ~isempty(axe_mem)
            t = findobj(axe_mem,'Type','text','Tag',varargin{2});
            if ~isempty(t)
                bloc = get(t,'UserData');
                if length(varargin{3})>1
                    indices = varargin{3};
                else
                    indices = cat(1,varargin{3:end});
                end
                varargout = bloc(indices);
            end
        else
            nbout = nargout;
            varargout = cell(1,nbout);
        end

    case 'wmb'
        %******************************************%
        %** OPTION = 'wmb' - writing in MemBloc. **%
        %******************************************%
        % win_handle = in2
        % bloc_name  = in3
        %    in(2k+2) index and in(2k+3) value
        %
        % out(1) = text handle.
        %--------------------------------------
        fig = varargin{1};
        [okFig,axe_mem] = bufferInFig(fig,tag_axe_mem);
        if okFig
            if ~isempty(axe_mem)
                t = findobj(axe_mem,'Type','text','Tag',varargin{2});
                ok_bloc = ~isempty(t);
            else
                ok_bloc = 0;
            end
            if ~ok_bloc
                nbval = fix((length(varargin)-2)/2);
                if nbval<0 , nbval = 0; end
                t = wmemtool('ini',fig,varargin{2},nbval);
            end
            bloc    = get(t,'UserData');
            indvar  = 3:2:length(varargin)-1;
            indices = cat(1,varargin{indvar});
            bloc(indices) = varargin(indvar+1);
            set(t,'UserData',bloc);
            varargout{1} = t;
        else
            varargout{1} = [];
        end

    case 'hmb'
        %*****************************************%
        %** OPTION = 'hmb' - handle of MemBloc. **%
        %*****************************************%
        % win_handle = in2
        % bloc_name  = in3
        %------------------
        fig = varargin{1};
        [okFig,axe_mem] = bufferInFig(fig,tag_axe_mem);
        if okFig && ~isempty(axe_mem)
            varargout{1} = findobj(axe_mem,'Type','text','Tag',varargin{2});
        else
            varargout{1} = [];
        end

    case 'ini'
        %******************************************%
        %** OPTION = 'ini' - creating a MemBloc. **%
        %******************************************%
        % win_handle = in2
        % bloc_name  = in3
        % nbval = in4
        %-------------------
        fig = varargin{1};
        [okFig,axe_mem] = bufferInFig(fig,tag_axe_mem);
        if okFig 
            if isempty(axe_mem)
                axe_mem = axes(...
                               'Parent',fig,                   ...
                               'HandleVisibility','off',       ...
                               'Visible','off',                ...
                               'Position',[-1 -1 0.001 0.001], ...
                               'Tag',tag_axe_mem               ...
                               );
            end
            t = findobj(axe_mem,'Type','text','Tag',varargin{2});
            if isempty(t)
                t = text('Parent',axe_mem,'Visible','off','Tag',varargin{2});
            end
            set(t,'UserData',cell(1,varargin{3}));
            varargout{1} = t;
        else
            varargout{1} = [];
        end

    case 'dmb'
        %***********************%
        %** OPTION = 'dmb' -  **%
        %***********************%
        % fig = in2             %
        % bloc_name = in3 , ... %
        %-----------------------%
        fig = varargin{1};
        [okFig,axe_mem] = bufferInFig(fig,tag_axe_mem);
        if okFig && ~isempty(axe_mem)
            t = [];
            txt_handles = findobj(axe_mem,'Type','text');
            if ~isempty(txt_handles)
                for k = 2:length(varargin)
                    t = [t;findobj(txt_handles,'Tag',varargin{k})]; %#ok<AGROW>
                end
            end
            if ~isempty(t) , delete(t); end
        end

%------------------------%
%                        %
% GENERAL BUFFER OPTIONS %
%                        %
%------------------------%
    case 'han'
        %***************************************************%
        %** OPTION = 'handle' - get handle of fig buffer  **%
        %***************************************************%
        varargout{1} = findobj(0,'Type','figure','Tag',tag_fig_mem);

    case 'cre'
        %********************************************%
        %** OPTION = 'create' - create fig buffer  **%
        %********************************************%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if isempty(fig)
            fig = colordef('new','none');
            set(fig,'HandleVisibility','Off','Tag',tag_fig_mem);
        end
        varargout{1} = fig;

    case 'put'
        %************************%
        %** OPTION = 'put' -   **%
        %************************%
        %------------------------------------
        % bloc_name = in2
        % bloc_set:  k = 1 , ...
        %   in(2k+1) index and in(2k+2) value
        %------------------------------------
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if isempty(fig) , fig = wmemtool('create'); end
        varargout{1} = wmemtool('wmb',fig,varargin{:});
        varargout{2} = fig;

    case 'get'
        %************************%
        %** OPTION = 'get' -   **%
        %************************%
        %------------------------------%
        % name = in2                   %
        % in3 optional string value    %
        %------------------------------%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if ~isempty(fig)
            [varargout{1:length(varargin)-1}] = wmemtool('rmb',fig,varargin{:});
        else
            varargout{1} = [] ;
        end

    case 'del'
        %*************************%
        %** OPTION = 'del' -    **%
        %*************************%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if ~isempty(fig), wmemtool('dmb',fig,varargin{:}); end
        
    case 'emp'
        %**************************%
        %** OPTION = 'empty' -   **%
        %**************************%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if ~isempty(fig) , delete(findobj(fig,'Type','text')); end

    case 'fin'
        %************************%
        %** OPTION = 'find' -  **%
        %************************%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        varargout{1} = 1-isempty(fig);

    case 'clo'
        %******************************************%
        %** OPTION = 'close' - close fig buffer  **%
        %******************************************%
        fig = findobj(0,'Type','figure','Tag',tag_fig_mem);
        if ~isempty(fig)
            Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
            Str_No =  getWavMSG('Wavelet:commongui:Str_No');
            Str_Can =  getWavMSG('Wavelet:commongui:Str_Cancel');
            answer = questdlg(...
                            getWavMSG('Wavelet:moreMSGRF:Del_GLB_Buffer'),...
                            getWavMSG('Wavelet:moreMSGRF:Main_MEM_BUF'), ...
                            Str_Yes,Str_No,Str_Can,Str_No);
            if strcmp(answer,Str_Yes), delete(fig); end
        end

    otherwise
        %********************%
        %** UNKNOWN OPTION **%
        %********************%
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Hide Buffers.
%--------------
set(0,'ShowHiddenHandles',old_show);


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function  [okFig,axe] = bufferInFig(fig,tagAxe)
% bufferInFig returns the handle of the axes Buffer

okFig = ishandle(fig);
if ~okFig , axe = []; return; end
axe = findobj(get(fig,'Children'),'flat','Type','axes','Tag',tagAxe);
%-----------------------------------------------------------------------------%
%=============================================================================%
