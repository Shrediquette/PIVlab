function txt_msg = wwaiting(option,fig,in3,in4)
%WWAITING Wait and display a message.
%   OUT1 = WWAITING(OPTION,FIG,IN3)
%   fig is the handle of the figure.
%
%   OPTION = 'on' , 'off'
%
%   OPTION = 'msg'    (display a message)
%    IN3 is a string.
%
%   OPTION = 'create' (create a text for messages)
%   IN3 is optional.
%   IN3 is height of the text (in pixels).
%   OUT1 is the handle of the text.
%
%   OPTION = 'handle'
%   OUT1 is the handle of the text.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.11.4.10 $

% If this is not an open figure, or not a figure, just return.
if ~ishandle(fig) || isempty(findobj(fig, 'flat', 'Type', 'Figure'))
    return;
end

tag_msg = 'Txt_Message';
txt_msg = findobj(fig,'Style','text','Tag',tag_msg);

switch option
    case {'on','off'}
        if ~isempty(txt_msg)
            set(txt_msg,'Visible',option);
        end
        mousefrm(fig,'arrow');
        drawnow;

    case 'msg'
        %  in3 = msg
        %------------------
        if ~isempty(txt_msg)
            if nargin < 4 || ~strcmpi(in4, 'nowatch')
                mousefrm(fig,'watch');
            end
            nblines = size(in3,1);
            if nblines==1
                in3 = char(' ',in3);
            end 
            set(txt_msg,'Visible','On','String',in3);
            drawnow;
        end

    case 'create'
        % in3 = "position"  (optional)
        % in4 = msg         (optional)
        % out1 = txt_msg
        %------------------
        uni = get(fig,'Units');
        pos = get(fig,'Position');
        tmp = get(0,'DefaultUicontrolPosition');
        yl  = 2.75*tmp(4);
        if strcmp(uni(1:3),'pix')
            xl = pos(3);
        elseif strcmp(uni(1:3),'nor')
            xl = 1;
            [~,yl] = wfigutil('prop_size',fig,1,yl);
        end
        if nargin>2
            xl = xl*in3;
            msg = '';
            vis = 'off';
        end
        msgBkColor = mextglob('get','Def_MsgBkColor');
        pos_txt_msg = [0 0 xl yl];
        txt_msg = uicontrol(...
                        'Parent',fig,...
                        'Style','text',...
                        'Units',uni,...
                        'Position',pos_txt_msg,...
                        'Visible',vis,...
                        'String',msg,...
                        'BackgroundColor',msgBkColor, ...
                        'Tag',tag_msg...
                        );
        if strcmpi(vis,'on') , drawnow; end

    case 'handle'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal')); 
end
