function [out1,out2] = mngmbtn(option,fig,varargin)
%MNGMBTN Manage mouse buttons for the dynamical visualization tool.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.13.4.20 $

msel_box  = 'n';
msel_trans = 'e';
msel_txt   = 'a';
msel_open  = 'o';

switch option
    case 'move'
        %**********************************************%
        %** OPTION = 'move' DEPLACEMENT DE LA SOURIS **%
        %**********************************************%
        %   DynV_Axe_Sel    = in3(1);
        %   Edi_PosX   = in3(2); (optional)
        %   Edi_PosY   = in3(3); (optional)
        %   mouseT = in4 (selection type)
        %-----------------------------------------
        if gcbf~=fig , return; end
        DynV_Axe_Sel = varargin{1}(1);
        if ~ishandle(DynV_Axe_Sel)
            return;
        end
        mouseT = varargin{2};
        
        [q,x,y] = waxecp(fig,DynV_Axe_Sel);
        if prod(x-q(1))>0 || prod(y-q(2))>0
            % set(fig,'WindowButtonMotionFcn','wtmotion','WindowButtonUpFcn','');
            set(fig,'Pointer','arrow');
            if ~isequal(mouseT,msel_box) , mngmbtn('delLines',fig,'V_H'); end

        %--- selection d'un rectangle ---%
        elseif isequal(mouseT,msel_box)
            dVTmemB = dynvtool('rmb',fig);
            DynV_Sel_Box = dVTmemB.DynV_Sel_Box;
            if ~isempty(DynV_Sel_Box) && ishandle(DynV_Sel_Box)
                pzbx = get(DynV_Sel_Box,'XData');
                pzby = get(DynV_Sel_Box,'YData');
                set(DynV_Sel_Box,...
                        'XData', [pzbx(1) q(1) q(1) pzbx(1) pzbx(1)],...
                        'YData', [pzby(1) pzby(1) q(2) q(2) pzby(1)]);
            end

        %--- ecriture de la position ---%
        elseif isequal(mouseT,msel_txt)
            dVTmemB = dynvtool('rmb',fig);
            DynV_Line_Hor = dVTmemB.DynV_Line_Hor;
            DynV_Line_Ver = dVTmemB.DynV_Line_Ver;
            if isempty(DynV_Line_Hor) , return; end
            set(DynV_Line_Hor,'YData',[q(2) q(2)]);
            set(DynV_Line_Ver,'XData',[q(1) q(1)]);
            if length(varargin{1})<3 , return; end
            Edi_PosX = varargin{1}(2);
            Edi_PosY = varargin{1}(3);
            mempos_coor = get(Edi_PosX,'UserData');
            fcn_wri   = wmemutil('get',mempos_coor,1);
            param_wri = wmemutil('get',mempos_coor,2);
            if isempty(param_wri)
               [sx,sy] = feval(fcn_wri,q(1),q(2),DynV_Axe_Sel);
            else
               [sx,sy] = feval(fcn_wri,q(1),q(2),DynV_Axe_Sel,param_wri);
            end
            set(Edi_PosX,'String',sx);
            set(Edi_PosY,'String',sy);
        
        %--- gestion des translations ---%
        elseif isequal(mouseT,msel_trans)
            dVTmemB = dynvtool('rmb',fig);
            DynV_Line_Hor = dVTmemB.DynV_Line_Hor;
            DynV_Line_Ver = dVTmemB.DynV_Line_Ver;
            if isempty(DynV_Line_Hor) , return; end
            x1 = get(DynV_Line_Hor,'XData');
            y1 = get(DynV_Line_Hor,'YData');
            rect = get(DynV_Axe_Sel,'Position');
            rx = abs((x1(2)-q(1))/(x(2)-x(1)));
            ry = abs((y1(2)-q(2))/(y(2)-y(1)));
            k  = rect(3)*rx-rect(4)*ry;
            if k>0
                set(DynV_Line_Hor,...
                        'XData',[x1(2) x1(2) x1(2)],...
                        'YData',[y(1)  y1(2) y(2) ] ...
                        );
                set(DynV_Line_Ver,...
                        'XData',[q(1) q(1) q(1)],   ...
                        'YData',[y(1) q(2) y(2)]    ...
                        );
                DynV_Flg_Trans = 1;
            elseif k<0
                set(DynV_Line_Hor,...
                        'XData',[x(1)  x1(2) x(2) ],...
                        'YData',[y1(2) y1(2) y1(2)] ...
                        );
                set(DynV_Line_Ver,...
                        'XData',[x(1) q(1) x(2)],   ...
                        'YData',[q(2) q(2) q(2)]    ...
                        );
                DynV_Flg_Trans = 2;
            else
                DynV_Flg_Trans = 0;
            end
            dVTmemB.flgTrans = DynV_Flg_Trans;
            dynvtool('wmb',fig,dVTmemB);
        end

    case 'down'
        %***************************************************%
        %** OPTION = 'down' UN BOUTON DE LA SOURIS APPUYE **%
        %***************************************************%
        % Check the figure exists and is a figure
        if ~ishandle(fig) || isempty(findobj(fig, 'flat', 'Type', 'Figure'))
            return;
        end

        if gcbf~=fig
            dVTmemB = mngmbtn('delLines',fig,'All');
        else
            dVTmemB = dynvtool('rmb',fig);
        end
        mouse  = get(fig,'SelectionType');
        mouseT = mouse(1);
        
        axe_hdls = dVTmemB.axeInd;
        if isequal(mouseT,msel_txt)
            % DynV_Axe_Act + DynV_Axe_Ind
            axe_hdls = [dVTmemB.axeAct , axe_hdls];

        else    
            % DynV_Axe_Cmd + DynV_Axe_Ind
            axe_hdls = [dVTmemB.axeCmd , axe_hdls];
        end
        axe_hdls = findobj(axe_hdls,'flat','Visible','on');
        par = get(axe_hdls,'Parent');
        if length(par)>1 , par = cat(1,par{:}); end
        idxVis = strcmp('on',get(par,'Visible'));
        axe_hdls = axe_hdls(idxVis);
        DynV_Axe_Sel = [];
        for i=1:length(axe_hdls)
            ax      = axe_hdls(i);
            [q,x,y] = waxecp(fig,ax);
            if  prod(x-q(1))<0 && prod(y-q(2))<0
                DynV_Axe_Sel = ax;
                break;
            end
        end
        dVTmemB.axeSel = DynV_Axe_Sel;
		dynvtool('wmb',fig,dVTmemB);
        dVTmemB = mngmbtn('delLines',fig,'Down',dVTmemB,DynV_Axe_Sel,mouseT);
		if isempty(DynV_Axe_Sel) , return; end

        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
		
        Edi_PosX = dVTmemB.handles.Edi_PosX;
        Edi_PosY = dVTmemB.handles.Edi_PosY;
        DynV_Col_Line = dVTmemB.linColor;

        %--- selection d'un rectangle ---%
        switch mouseT
            case msel_box
                set(fig,'Pointer','crosshair', ...
                        'CurrentAxes',DynV_Axe_Sel);
                if ~isempty(Edi_PosX)
                    set(Edi_PosX,'String','X = ');
                    set(Edi_PosY,'String','Y = ');
                end
                DynV_Sel_Box = line(...
                        'Color',DynV_Col_Line,...
                        'XData',[q(1) q(1) q(1) q(1) q(1)],...
                        'YData',[q(2) q(2) q(2) q(2) q(2)] ...
                        );
                dVTmemB.DynV_Sel_Box = DynV_Sel_Box;

        %--- ecriture de la position ---%
            case msel_txt
                set(fig,'Pointer','crosshair', ...
                        'CurrentAxes',DynV_Axe_Sel);
                DynV_Line_Hor = line(...
                        'Color',DynV_Col_Line,...
                        'XData',[x(1) x(2)],...
                        'YData',[q(2) q(2)] ...
                        );
                DynV_Line_Ver = line(...
                        'Color',DynV_Col_Line,...
                        'XData',[q(1) q(1)],...
                        'YData',[y(1) y(2)] ...
                        );
                dVTmemB.DynV_Line_Hor = DynV_Line_Hor;
                dVTmemB.DynV_Line_Ver = DynV_Line_Ver;

                if ~isempty(Edi_PosX)
                    mempos_coor = get(Edi_PosX,'UserData');
                    fcn_wri   = wmemutil('get',mempos_coor,1);
                    param_wri = wmemutil('get',mempos_coor,2);
                    if isempty(param_wri)
                       [sx,sy] = feval(fcn_wri,q(1),q(2),DynV_Axe_Sel);
                    else
                       [sx,sy] =  ...
                            feval(fcn_wri,q(1),q(2),DynV_Axe_Sel,param_wri);
                    end
					dynvtool('set_BtnOnOff',fig,'On','Info');
                    set(Edi_PosX,'String',sx);
                    set(Edi_PosY,'String',sy);
                end

        %--- gestion des translations ---%
            case msel_trans
                set(fig,'Pointer','crosshair','CurrentAxes',DynV_Axe_Sel);
                if ~isempty(Edi_PosX)
                    set(Edi_PosX,'String','X = ');
                    set(Edi_PosY,'String','Y = ');
                end
                DynV_Line_Hor = line(...
                        'LineStyle','--',...
                        'Color',DynV_Col_Line,...
                        'XData',[x(1) q(1) x(2)],...
                        'YData',[q(2) q(2) q(2)] ...
                        );
                DynV_Line_Ver = line(...
                        'LineStyle','--',...
                        'Color',DynV_Col_Line,...
                        'XData',[q(1) q(1) q(1)],...
                        'YData',[y(1) q(2) y(2)] ...
                        );
                dVTmemB.DynV_Line_Hor = DynV_Line_Hor;
                dVTmemB.DynV_Line_Ver = DynV_Line_Ver;
                dVTmemB.flgTrans = 0;

        %--- open ---%
            case msel_open
              set(fig,'Pointer','arrow');
              mempos_coor = get(Edi_PosX,'UserData');
              fcn_sel = wmemutil('get',mempos_coor,3);
              if ~isempty(fcn_sel)
                  param_sel = wmemutil('get',mempos_coor,4);
                  if isempty(param_sel)
                      [sx,sy] = feval(fcn_sel,q(1),q(2),DynV_Axe_Sel);
                  else
                      [sx,sy] = feval(fcn_sel,q(1),q(2),DynV_Axe_Sel,param_sel);
                  end
                  if ~isempty(sx)
                      DynV_Line_Hor = line(...
                          'Color',DynV_Col_Line,...
                          'XData',[x(1) x(2)],...
                          'YData',[q(2) q(2)] ...
                          );
                      DynV_Line_Ver = line(...
                          'Color',DynV_Col_Line,...
                          'XData',[q(1) q(1)],...
                          'YData',[y(1) y(2)] ...
                          );
                      if ~isempty(Edi_PosX)
                          set(Edi_PosX,'String',sx);
                          set(Edi_PosY,'String',sy);
                      end
                      dVTmemB.DynV_Line_Hor = DynV_Line_Hor;
                      dVTmemB.DynV_Line_Ver = DynV_Line_Ver;
                  end
              end
        end
		handles  = [DynV_Axe_Sel,Edi_PosX,Edi_PosY];

		cba_move = @(~,~)mngmbtn('move',fig, handles, mouseT);
		cba_up   = @(~,~)mngmbtn('up',fig, handles, mouseT);
        
        WFB_Move_1 = get(fig,'WindowButtonMotionFcn');
        wtbxappdata('set',fig,'save_WindowButtonMotionFcn',WFB_Move_1);
        
		set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
		dynvtool('wmb',fig,dVTmemB);

    case 'up'
        %*************************************************%
        %** OPTION = 'up' UN BOUTON DE LA SOURIS APPUYE **%
        %*************************************************%
        %   mouseT = in4 (selection type)
        %-----------------------------------------
        DynV_Axe_Sel = varargin{1}(1);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
		hgfeval(save_WindowButtonUpFcn);
        WFB_Move_2 = wtbxappdata('get',fig,'save_WindowButtonMotionFcn');
        set(fig,'WindowButtonMotionFcn',WFB_Move_2,...
			    'WindowButtonUpFcn',save_WindowButtonUpFcn);

		set(fig,'Pointer','arrow');
        mouseT  = varargin{2};
		if isequal(mouseT,msel_open) ,  return; end
		
        dVTmemB = dynvtool('rmb',fig);

        %--- gestion des translations ---%
        if isequal(mouseT,msel_trans)
            DynV_Line_Hor = dVTmemB.DynV_Line_Hor;
            DynV_Line_Ver = dVTmemB.DynV_Line_Ver;
            DynV_Flg_Trans = dVTmemB.flgTrans;
            if DynV_Flg_Trans==1
                x1 = get(DynV_Line_Hor,'XData');
                x2 = get(DynV_Line_Ver,'XData');
                dx = x2(2)-x1(2);
            elseif DynV_Flg_Trans==2
                y1 = get(DynV_Line_Hor,'YData');
                y2 = get(DynV_Line_Ver,'YData');
                dy = y2(2)-y1(2);
            end
            dVTmemB = mngmbtn('delLines',fig,'V_H',dVTmemB);
            DynV_Axe_Ind = dVTmemB.axeInd;
            if ~isempty(DynV_Axe_Ind) && any(DynV_Axe_Sel==DynV_Axe_Ind)
                DynV_Axe_Act  = DynV_Axe_Sel;
                DynV_XY_Const = [0 0];
            else
                DynV_Axe_Act  = dVTmemB.axeAct;
                DynV_XY_Const = dVTmemB.xyConst;
            end
            if DynV_Flg_Trans==1
                x0 = get(DynV_Axe_Sel,'XLim');
                if DynV_XY_Const(1)~=0
                    set(DynV_Axe_Act,'XLim',x0-dx);
                else
                    set(DynV_Axe_Sel,'XLim',x0-dx);
                end
                dynvtool('put',fig);

            elseif DynV_Flg_Trans==2
                y0 = get(DynV_Axe_Sel,'YLim');
                if DynV_XY_Const(2)~=0
                    set(DynV_Axe_Act,'YLim',y0-dy);
                else
                    set(DynV_Axe_Sel,'YLim',y0-dy);
                end
                dynvtool('put',fig);
            end

        elseif isequal(mouseT,msel_box)
            DynV_Sel_Box = dVTmemB.DynV_Sel_Box;
            if ~ishandle(DynV_Sel_Box) , return; end
            xd = get(DynV_Sel_Box,'XData');
            yd = get(DynV_Sel_Box,'YData');
            if isempty(xd) || isempty(yd) , return; end
            xl = get(DynV_Axe_Sel,'XLim');
            yl = get(DynV_Axe_Sel,'YLim');
            tol = 0.01;
            if abs((max(xd)-min(xd))/(xl(2)-xl(1)))<tol  || ....
               abs((max(yd)-min(yd))/(yl(2)-yl(1)))<tol
                mngmbtn('delLines',fig,'Box',dVTmemB);
			else
				dynvtool('set_BtnOnOff',fig,'On','Zoom');
            end

        end

    case 'getbox'
        %****************************************************%
        %** OPTION = 'getbox' LECTURE DU RECTANGLE DE ZOOM **%
        %****************************************************%
        dVTmemB = dynvtool('rmb',fig);
        DynV_Sel_Box = dVTmemB.DynV_Sel_Box;
        if ~ishandle(DynV_Sel_Box)  
            DynV_Sel_Box = [];
            dVTmemB.DynV_Sel_Box = DynV_Sel_Box;
            dynvtool('wmb',fig,dVTmemB);
        end
        if ~isempty(DynV_Sel_Box)
            out1 = get(DynV_Sel_Box,'XData');
            out2 = get(DynV_Sel_Box,'YData');
            if (min(out1)==max(out1)) || (min(out2)==max(out2))
                mngmbtn('delLines',fig,'Box',dVTmemB);
                out1 = [];
                out2 = [];
            end
        else
            out1 = [];
            out2 = [];
        end

    case 'delLines'
        if nargin<4  
            dVTmemB = dynvtool('rmb',fig);
        else
            dVTmemB = varargin{2};
        end
        linHDL = [];
        switch varargin{1}
          case 'Box' 
            linHDL = dVTmemB.DynV_Sel_Box;
            dVTmemB.DynV_Sel_Box  = [];
			
          case {'V_H','H_V'}
            linHDL = [dVTmemB.DynV_Line_Hor,dVTmemB.DynV_Line_Ver];
            dVTmemB.DynV_Line_Hor = [];
            dVTmemB.DynV_Line_Ver = [];
			
          case {'All','Down'}
            if ~isempty(dVTmemB)
                linHDL = [dVTmemB.DynV_Sel_Box,...
                      dVTmemB.DynV_Line_Hor,dVTmemB.DynV_Line_Ver];
            else
            end
            dVTmemB.DynV_Sel_Box  = [];
            dVTmemB.DynV_Line_Hor = [];
            dVTmemB.DynV_Line_Ver = [];
        end
        delete(linHDL(ishandle(linHDL)));
        dynvtool('wmb',fig,dVTmemB);
	
		if ~isequal(varargin{1},'V_H') && ~isequal(varargin{1},'H_V')
			switch varargin{1}
			case 'All'  
                typCall = 'All';
			case 'Box'  
                typCall = 'Zoom';
			case 'Down'
				
				typCall = 'All';
				
			end
			dynvtool('set_BtnOnOff',fig,'Off',typCall);
		end
        out1 = dVTmemB;

    case 'getLines'
        if nargin<4  
            dVTmemB = dynvtool('rmb',fig);
        else
            dVTmemB = varargin{2};
        end
        switch lower(varargin{1})
          case 'box' , out1  = dVTmemB.DynV_Sel_Box;
          case 'hor' , out1  = dVTmemB.DynV_Line_Hor;
          case 'ver' , out1  = dVTmemB.DynV_Line_Ver;
          case 'all' 
            out1  = [dVTmemB.DynV_Sel_Box,dVTmemB.DynV_Line_Hor,dVTmemB.DynV_Line_Ver];
        end

    case 'cleanXYPos'
        handles = dynvtool('handles',fig);
        Edi_PosX = handles.Edi_PosX;
        Edi_PosY = handles.Edi_PosY;
        set(Edi_PosX,'String','X = ');
        set(Edi_PosY,'String','Y = ');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
