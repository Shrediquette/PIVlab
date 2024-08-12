function wfighelp(option,varargin)
%WFIGHELP Wavelet Toolbox Utilities for Help system functions and menus
%   WFIGHELP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Dec-2000.
%   Last Revision 26-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.10.4.11 $ $Date: 2013/09/14 19:39:06 $

switch option
	case 'set'
        hdl_HelpMenu = varargin{1};
        win_type = varargin{2};
        switch win_type
            case {'ExtFig_Demos'}
                Demosflag = 0;
                
            otherwise
                Demosflag = 1;
        end
		setMenu(hdl_HelpMenu,Demosflag);
		
	case 'addHelpTool'
        fig  = varargin{1};
		label   = varargin{2};
		idxHelp = varargin{3};
		ud.idxHelp = idxHelp;
		m_help = wfigmngr('getmenus',fig,'help');
		uimenu(m_help, ...
			'Label',label, ...
			'Position',1,  ...
			'Callback',@cb_Help_Tool, ...
			'UserData',ud ...
			);
		
	case 'addHelpItem'
        fig  = varargin{1};
		label   = varargin{2};
		idxHelp = varargin{3};
		ud.idxHelp = idxHelp;
		m_help = wfigmngr('getmenus',fig,'help');
		m_child = findall(m_help,'Type','uimenu','Parent',m_help);
		m_item  = findobj(m_child,'Tag','Item_Help');
		if isempty(m_item)
			m_wtbx  = findobj(m_child,'Tag','WTBX_Help');
			m_wthis = findobj(m_child,'Tag','WhatThis_Help');
			if ~isempty(m_wthis)
				pos = get(m_wthis,'Position')+1;
			else
				pos = get(m_wtbx,'Position')+1;			
			end
			sep = 'On';
		else
			pos = get(m_item,'Position');
			if iscell(pos) , pos = cat(1,pos{:}); end
			pos = max(pos)+1;
			sep = 'Off';			
		end
		uimenu(m_help,...
			'Label',label,'Position',pos, ...
			'Separator',sep,'Tag','Item_Help', ...
			'Callback',@cb_Help_Tool,'UserData',ud);

	case 'add_ContextMenu'
		add_ContextMenu(varargin{:});
        
    case 'launch_Help'
        launch_Help(varargin{:});
end


%=======================================================================%
% This Internal function built the "uiContextMenus" associated to
% several handle grahics in the Wavelet Toolbox GUI. 
% ------------------------------------------------------------------
% Here is where all the handle-to-help relationships are constructed
% ==================================================================
% Each relationship is set up as follows:
%
%      add_ContextMenu(hFig,[vector_of_UI_handles],tagString);
%
% where tagStr corresponds to the link used in the doc map file.
% ------------------------------------------------------------------
function add_ContextMenu(hFig,hItem,tagStr)
% Add a "What's This?" context menu.

hc = uicontextmenu('Parent',hFig);
uimenu('Label',getWavMSG('Wavelet:divGUIRF:Str_Whats_This'),...
	'Callback',@HelpGeneral,...
	'Parent',hc,...
	'Tag',['WT?' tagStr]);
hItem = hItem(ishandle(hItem));
if ~isempty(hItem) , set(hItem,'uicontextmenu',hc); end
% ------------------------------------------------------------------
%=======================================================================%


%=======================================================================%
%---------------------------------------------------------------------%
function setMenu(h,Demosflag)

WhatIsflag = false;

sub = findall(h,'Type','uimenu','Parent',h);
delete(sub); sub = [];

idx = 1;
sub(idx) = uimenu(h, ...
	'Label',getWavMSG('Wavelet:wfigmngr:fM_HLP'), ...
	'Position',idx, ...
    'Separator','Off', ...
	'Tag','WTBX_Help', ...
	'CallBack',@cb_Help_Product ...
	);

if WhatIsflag
	idx = idx+1;
	sub(idx)= uimenu(h, ...
		'Label', getWavMSG('Wavelet:wfigmngr:fM_HLP_WT'), ...
		'Position',idx, ...		
		'Separator','On', ...
	    'Tag','WhatThis_Help', ...
		'CallBack',@cb_HelpWhatsThis ...
		);
end
if Demosflag
	idx = idx+1;
	sub(idx)= uimenu(h, ...
		'Label', getWavMSG('Wavelet:wfigmngr:fM_HLP_DEM'), ...
		'Position',idx, ...		
		'Separator','On', ...
		'CallBack',@cb_Help_Demos ...
		);
end
idx = idx+1;
sub(idx)= uimenu(h, ...
	'Label', getWavMSG('Wavelet:wfigmngr:fM_HLP_About'), ...
	'Position',idx, ...		
	'Separator','On', ...
	'CallBack',@cb_Help_About ...
	); %#ok<NASGU>
%---------------------------------------------------------------------%
function cb_Help_Tool(hco,~)

ud = get(hco,'UserData');
helpItem = ud.idxHelp;
bring_up_help_window(gcbf, helpItem);
%---------------------------------------------------------------------%
function cb_Help_Product(~,~)

doc wavelet;  % Or helpview([docroot '\toolbox\wavelet'])
%---------------------------------------------------------------------%
function cb_HelpWhatsThis(~,~)
% HelpWhatsThis_cb Get "What's This?" help
%   This mimics the context-menu help selection, but allows
%   cursor-selection of the help topic

hFig = waveletFigNumber(gcbf);
tog = wfindobj(hFig,'type','uitoggletool');
state = get(tog,'State');
ind = find(strcmp(state,'on'),1);
if ~isempty(ind)
    for k = 1:4
        set(tog(ind),'State','off')
        pause(0.1)
        set(tog(ind),'State','on')
        pause(0.1)        
    end
    beep; 
    return; 
end
cshelp(hFig); %#ok<*FOBS>

%---------------------------------------------------------------------%
% --------------------------------------------------------------
% General Context Sensitive Help (CSH) system rules:
%  - context menus that launch the "What's This?" item have their
%    tag set to 'WT?...', where the '...' is the "keyword" for the
%    help lookup system.
% --------------------------------------------------------------
function figHelpFcn(~,~)
% figHelpFcn Figure Help function called from either
% the menu-based "What's This?" function, or the toolbar icon.

hFig  = gcbf;
hOver = gco;  % handle to object under pointer

% Dispatch to context help.
hc = get(hOver,'uicontextmenu');
hm = get(hc,'Children');  % menu(s) pointed to by context menu

% Multiple entries (children) of context-menu may be present
% Tag is a string, but we may get a cell-array of strings if
% multiple context menus are present:
% Find 'What's This?' help entry
tag = get(hm,'Tag');
helpIdx = find(strncmp(tag,'WT?',3));
if ~isempty(helpIdx)
    % in case there were accidentally multiple 'WT?' entries,
    % take the first (and hopefully, the only) index.
    if iscell(tag)
	    tag = tag{helpIdx(1)};
    end
	HelpGeneral([],[],tag);
end

set(handle(hFig),'cshelpmode','off');
%---------------------------------------------------------------------%
function cb_Help_Demos(~,~)

demo toolbox wavelet
%---------------------------------------------------------------------%
function cb_Help_About(~,~)

tlbx = ver('wavelet');
tlbx = tlbx(end);
s1 = getWavMSG('Wavelet:divGUIRF:Str_VerWTBX',tlbx.Name,tlbx.Version);
s2 = getWavMSG('Wavelet:divGUIRF:Str_Copyright',datestr(tlbx.Date, 10));
str_vers = char(s1,s2);
CreateStruct.WindowStyle = 'replace';
CreateStruct.Interpreter = 'tex';
Title    = getWavMSG('Wavelet:divGUIRF:Str_WTBX');
NB       = 64;
IconData = ((1:NB)'*(1:NB))/NB;
IconCMap = jet(NB);
try %#ok<TRYNC>
  load('wtbxicon.mat')
  IconData = IconData+11*X;
end
msgbox(str_vers,Title,'custom',IconData,IconCMap,CreateStruct);
%---------------------------------------------------------------------%
function launch_Help(hFig,tag)

bring_up_help_window(hFig,tag)
%---------------------------------------------------------------------%
function HelpGeneral(~,~,tag)
% HelpGeneral Bring up the help corresponding to the tag string.

hFig = gcbf;
hco  = gcbo;
if nargin<3, tag = get(hco,'Tag'); end

% Check for legal tag string
if ~ischar(tag)
   helpError(hFig,getWavMSG('Wavelet:divGUIRF:Err_CSHelp'));
   return
end

% Remove 'WT?' prefix;
if strncmp(tag,'WT?',3)
    tag(1:3) = '';
else
    msg = getWavMSG('Wavelet:divGUIRF:Msg_CSHelp');
    helpError(hFig,msg);
    return
end

% Intercept general tags and map them to specific tags in the doc.
doclink = tag_mapping(hFig,tag);
bring_up_help_window(hFig,doclink);
%---------------------------------------------------------------------%
function tag = tag_mapping(~,tag)
% Intercept general tags to differentiate as appropriate, if 
% necessary, otherwise, return the input tag string.

switch tag
	case 'dummy'   % tag = FUNCTION(hFig,tag);
end
%---------------------------------------------------------------------%
function bring_up_help_window(hFig,tag) %#ok<INUSD> 
% Attempt to bring up helpview
% Provide appropriate error messages on failure

callHelpViewer(tag);    

%---------------------------------------------------------------------%
function helpError(~,msg)
% Generate a modal dialog box to display errors while trying to 
% obtain help

errordlg(msg,getWavMSG('Wavelet:moreMSGRF:HLP_WinTitle'),'modal');
%---------------------------------------------------------------------%
function callHelpViewer(helpItem)

helpview(fullfile(docroot,'toolbox','wavelet','wavelet.map'),helpItem);
%---------------------------------------------------------------------%
%=======================================================================%
