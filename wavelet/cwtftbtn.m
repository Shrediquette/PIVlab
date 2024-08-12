function varargout = cwtftbtn(option,fig,varargin)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2010.
%   Last Revision: 10-Jun-2013.

%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2013/07/05 04:29:41 $ 

persistent Sel_Box XD YD Mouse_CurPt numBOX 

msel_N = 'n';
msel_E = 'e';
msel_A = 'a';
msel_O = 'o';
%-----------------------------------------------------
% Normal:    Click left mouse button.
% Extend:    Shift-click left mouse button or 
%            click both left and right mouse buttons
% Alternate: Control - click left mouse button or 
%            click right mouse button.
% Open:      Double-click any mouse button.
%-----------------------------------------------------
LW = 2;
EdgeSELECT= [0 1 0];
switch option
    case 'attach'
        Sel_Box  = varargin{1};
        if length(varargin)>1 , LW  = varargin{2}; end
        attach_CtxtMenu(Sel_Box,LW);
        
    case 'setbox'
        val = varargin{1};
        handles = varargin{2};
        switch val
            case 'ini'
                Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
                if ~isempty(Lst_Sel_Box) && ishandle(Lst_Sel_Box{1}(1))
                    return; 
                end
                lineCOL = [1 0 0]; LW = 5;
            case 'all'
                lineCOL = [0 1 0]; LW = 5;
        end
        axPAR = handles.Axe_MAN_SEL;
        CWTS = wtbxappdata('get',fig,'CWTStruct');
        Y1 = CWTS.scales(1); Y2 = CWTS.scales(end);
        nbVAL = size(CWTS.cfs,2);
        AP = wtbxappdata('get',fig,'Pow_Anal_Params');
        dt = AP.sampPer;
        y = [Y1 Y2];
        x = [0 dt*nbVAL];
        dx = x(2)-x(1); x(2) = x(2) + 0.01*dx;
        dy = y(2)-y(1); y(2) = y(2) + 0.01*dy;
        XD = [x(1) x(2) x(2) x(1) x(1)];
        YD = [y(2) y(2) y(1) y(1) y(2)];
        SB = line(...
            'Color',lineCOL,'LineStyle','-','LineWidth',LW, ...
            'XData',XD,'YData',YD,'Parent',axPAR ...
            );
        SB = double(SB);
        switch val
            case 'ini'
                Cell_Of_COLOR = cwtftboxfun;
                idxNotSel = 1;
                FaceColor = Cell_Of_COLOR{idxNotSel,1};
                FaceAlpha = Cell_Of_COLOR{idxNotSel,2};
                EdgeColor = Cell_Of_COLOR{idxNotSel,3};
                set(axPAR,'NextPlot','add');    
                SF = fill(XD,YD,FaceColor,...
                    'FaceAlpha',FaceAlpha,'EdgeColor',EdgeColor, ...
                    'Parent',axPAR);
                SF = double(SF);
                attach_CtxtMenu(SB,5,'ini');
                attach_CtxtMenu(SF,5,'ini');
                wtbxappdata('set',fig,'Sel_Box_CFS',{[SB -1 SF]});
                wtbxappdata('set',fig,'InitBOX',{[SB -1 SF]});
            case 'all'
                attach_CtxtMenu(SB,5);
                wtbxappdata('set',fig,'Sel_Box_CFS',{[SB 0 NaN]});
                varargout{1} = SB;
        end

    case 'getbox' 
        hdl_LINE  = varargin{1}; 
        Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
        if ~isempty(Lst_Sel_Box)
            TAB = cat(1,Lst_Sel_Box{:});
            hdl_BOXES = TAB(:,1);
            numBOX = find(hdl_BOXES==hdl_LINE);
            if isempty(numBOX)
                hdl_FILL  = TAB(:,3);
                numBOX = find(hdl_FILL==hdl_LINE);
            end
        else
            numBOX = NaN;
        end
        varargout = {numBOX,hdl_LINE};
        
    case 'down'
        ax  = varargin{1};
        btn = varargin{2};
        mouSelType = get(fig,'SelectionType');
        MST = mouSelType(1);
        if isequal(MST,msel_A) , return; end
        Axe_Sel = [];
        xycp = get(ax,{'XLim','YLim','CurrentPoint'});
        x = xycp{1}; y = xycp{2}; q = xycp{3}(1,1:2);
        if  prod(x-q(1))<0 && prod(y-q(2))<0 , Axe_Sel = ax; end
        if isempty(Axe_Sel) , return; end
        wtbxappdata('set',fig,'save_WindowButtonUpFcn',...
            get(fig,'WindowButtonUpFcn'));
        
        switch MST
            case msel_N
                set(fig,'Pointer','crosshair','CurrentAxes',Axe_Sel);
                XD = [q(1) q(1) q(1) q(1) q(1)];
                YD = [q(2) q(2) q(2) q(2) q(2)];
                Sel_Box = line(...
                    'Color',EdgeSELECT,'LineStyle','-','LineWidth',LW, ...
                    'XData',XD,'YData',YD  ...
                    );
                attach_CtxtMenu(Sel_Box,LW)                
                Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
                Lst_Sel_Box{end+1} = [double(Sel_Box) 0 NaN];
                wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
                numBOX = length(Lst_Sel_Box);
             
            case {msel_E}
                Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
                if isempty(Lst_Sel_Box) , return; end
                numBOX = NaN;
                nbBOX = length(Lst_Sel_Box);
                for k = nbBOX:-1:1
                    Param_Box = Lst_Sel_Box{k};
                    SB = Param_Box(1);
                    xd = get(SB,'XData'); xd = xd([1,2]);
                    yd = get(SB,'YData'); yd = yd([1,3]);
                    if  prod(xd-q(1))<0 && prod(yd-q(2))<0
                        numBOX = k; break;
                    end
                end
                if isequal(numBOX,1) , return; end
                if ~isnan(numBOX)
                    Sel_Box = SB;
                    hFill   = Lst_Sel_Box{numBOX}(3);
                    Mouse_CurPt = q;
                    if isequal(MST,msel_E) , SelColor = [1 1 0]; end
                    set(Sel_Box,'Color',SelColor,'LineWidth',LW);
                    set(hFill,'EdgeColor',SelColor); 
                end

        end

        cba_move = @(~,~)cwtftbtn('move', fig , ...
            Axe_Sel ,  btn , MST);
        cba_up   = @(~,~)cwtftbtn('up', fig , ...
            Axe_Sel ,  btn , MST);

        WFB_Move_1 = get(fig,'WindowButtonMotionFcn');
        wtbxappdata('set',fig,'save_WindowButtonMotionFcn',WFB_Move_1);
        set(fig,'WindowButtonMotionFcn',cba_move, ...
            'WindowButtonUpFcn',cba_up);
        
    case 'move'
        Axe_Sel = varargin{1};
        % btn  = varargin{2};
        if ~ishandle(Axe_Sel) || isnan(numBOX)
            set(fig,'Pointer','arrow');
            return; 
        end
        MST = varargin{3};
        xycp = get(Axe_Sel,{'XLim','YLim','CurrentPoint'});
        x = xycp{1}; y = xycp{2}; q  = xycp{3}(1,1:2); 
        z1 = x-q(1); 
        N1 = prod(z1)/(norm(z1)*norm(z1));
        z2 = y-q(2); 
        N2 = prod(z2)/(norm(z2)*norm(z2));
        prec = 0.01;
        if N1>prec || N2>prec
            set(fig,'Pointer','arrow');
        elseif isequal(MST,msel_N)
            if ~isempty(Sel_Box) && ishandle(Sel_Box)
                XD(2:3) = q(1);
                YD(3:4) = q(2);
                set(Sel_Box,'XData',XD,'YData',YD);
            end
        elseif isequal(MST,msel_E)
            Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
            Sel_Box     = Lst_Sel_Box{numBOX}(1);
            hFill       = Lst_Sel_Box{numBOX}(3);
            old_q       = Mouse_CurPt;
            xd = get(Sel_Box,'XData');
            yd = get(Sel_Box,'YData');
            d  = q-old_q;
            Mouse_CurPt = q;
            xdNew = xd+d(1); 
            ydNew = yd+d(2);
            Okfill = ishandle(hFill);
            if Okfill
                xf = get(hFill,'XData');
                yf = get(hFill,'YData');
                xfNew = xf+d(1); yfNew = yf+d(2);
            end           
            set(Sel_Box,'XData',xdNew,'YData',ydNew)
            if Okfill , set(hFill,'XData',xfNew,'YData',yfNew); end
        end
        
    case 'up'
        Axe_Sel = varargin{1};
        btn  = varargin{2};
        MST  = varargin{3};
        save_WindowButtonUpFcn = ...
            wtbxappdata('del',fig,'save_WindowButtonUpFcn');
		eval(save_WindowButtonUpFcn);
        WFB_Move_2 = wtbxappdata('get',fig,'save_WindowButtonMotionFcn');
        set(fig,'WindowButtonMotionFcn',WFB_Move_2,...
			    'WindowButtonUpFcn',save_WindowButtonUpFcn);
		set(fig,'Pointer','arrow');
        if isnan(numBOX) || isequal(MST,msel_O) , return; end
        
        Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');        
        if isequal(MST,msel_N)
            Sel_Box = Lst_Sel_Box{end}(1);            
            xd = get(Sel_Box,'XData');
            yd = get(Sel_Box,'YData');
            if isempty(xd) || isempty(yd) , return; end
            xl = get(Axe_Sel,'XLim');
            yl = get(Axe_Sel,'YLim');
            tol = 0.01;
            if abs((max(xd)-min(xd))/(xl(2)-xl(1)))<tol  || ....
               abs((max(yd)-min(yd))/(yl(2)-yl(1)))<tol
                delete(Sel_Box);
                Lst_Sel_Box(end) = [];
                Sel_Box = [];
                wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
            else
                XD = get(Sel_Box,'XData');
                YD = get(Sel_Box,'YData');
                axPAR = get(Sel_Box,'Parent');
                set(axPAR,'NextPlot','add');
                Cell_Of_COLOR = cwtftboxfun;
                idxNotSel = 3;
                FaceColor = Cell_Of_COLOR{idxNotSel,1};
                FaceAlpha = Cell_Of_COLOR{idxNotSel,2};
                EdgeColor = Cell_Of_COLOR{idxNotSel,3};
                Sel_Fill = fill(XD,YD,FaceColor,...
                    'FaceAlpha',FaceAlpha,'EdgeColor',EdgeColor, ...
                    'Parent',axPAR);
                attach_CtxtMenu(Sel_Fill,LW)
                Lst_Sel_Box{end}(2) = 1;
                Lst_Sel_Box{end}(3) = Sel_Fill;
                wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
            end
            if ~isempty(Lst_Sel_Box)
                ena = 'on';
            else
                ena = 'off'; 
            end
            set(btn,'Enable',ena)
            
        elseif isequal(MST,msel_E)
            Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
            Sel_Box = Lst_Sel_Box{numBOX}(1);
            Val_Sel = Lst_Sel_Box{numBOX}(2);
            hFill   = Lst_Sel_Box{numBOX}(3);
            switch Val_Sel
                case -1 , col = [1 0 0];
                case  0 , col = [1 1 1];
                case  1 , col = [0 1 0];
            end
            set(Sel_Box,'Color',col);
            set(hFill,'EdgeColor',col); 
        end
end

%--------------------------------------------------------------------------
function attach_CtxtMenu(Sel_Box,LW,~)

hcmenu = uicontextmenu('Userdata',Sel_Box);
set(Sel_Box,'LineWidth',LW,'UIContextMenu',hcmenu)
uimenu(hcmenu,'Label',getWavMSG('Wavelet:divGUIRF:Str_Select'), ...
    'Callback',@(~,~)cwtftboxfun(1));
uimenu(hcmenu,'Label',getWavMSG('Wavelet:divGUIRF:Str_UnSelect'), ...
    'Callback',@(~,~)cwtftboxfun(2));
if nargin>2 , return; end % Initial Box
uimenu(hcmenu,'Separator','On', ...
    'Label',getWavMSG('Wavelet:divGUIRF:Str_Delete'), ...
    'Callback',@(~,~)cwtftboxfun(3));
%--------------------------------------------------------------------------
