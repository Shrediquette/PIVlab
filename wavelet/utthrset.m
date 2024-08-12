function varargout = utthrset(option,in2,in3)
%UTTHRSET Utilities for threshold settings.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-97.
%   Last Revision: 26-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.11.4.16 $  $Date: 2013/09/14 19:39:05 $

% MemBloc of stored values.
%==========================
% MB1.
%-----
n_membloc1  = 'ReturnTHR_Bloc';
ind_ret_fig = 1;
ind_tog_thr = 2;
ind_status  = 3;
% nb1_stored  = 3;

% Same bloc in utthrw1d.
%-----------------------
n_memblocTHR   = 'MB_ThrStruct';
ind_thr_struct = 1;
ind_int_thr    = 2;

% Tag property.
%--------------
tag_figThresh = 'Fig_Thresh';
tag_pus_close = 'Close';

% Tag property (2).
%------------------
tag_lineH_up   = 'LH_u';
tag_lineH_down = 'LH_d';
tag_lineV      = 'LV';

switch option
    case 'init'
        % Handle of Calling Toggle Button.
        %---------------------------------
        switch nargin
          case 1 , tog_thr = gcbo;
          case 2 , tog_thr = in2;
        end
        calling_Fig = get(tog_thr,'Parent');
        oldFig = wfindobj('figure','Tag',tag_figThresh);
        existFig = ~isempty(oldFig);
        if existFig
            existFig = 0;
            for k = 1:length(oldFig)
                oldCall = wmemtool('rmb',oldFig(k),n_membloc1,ind_ret_fig);
                if isequal(oldCall,calling_Fig)
                   existFig = oldFig(k);
                   break
                end
            end
        end

        if existFig == 0
             [den_struct,int_DepThr_Cell] = ...
                 wmemtool('rmb',calling_Fig,n_memblocTHR, ...
                          ind_thr_struct,ind_int_thr);
             nb = size(den_struct,1);
             jj = zeros(nb,1);
             for k = 1:nb
                 jj(k) = ~isempty(den_struct(k).thrParams);
             end
             NB_lev = length(find(jj>0));
             NB_Max_Int = 6;

            % Create window.
            %---------------
            [Def_Txt_Height,Def_Btn_Height,Def_ShadowColor] = ...
                mextglob('get','Def_Txt_Height','Def_Btn_Height', ...
                    'Def_ShadowColor');
            pos_win = get(0,'DefaultFigurePosition');
            pos_win(1) = pos_win(1) - 1.5*pos_win(3)/5;
            pos_win(3) = 7*pos_win(3)/5;
            pos_win(4) = 6*pos_win(4)/5;
            pos_win(2) = pos_win(2)/2;
            leftx = 45;   rightx  = 200;
            topy  = 30;   bottomy = 60;
            bdx   = 30;
            callName = get(calling_Fig,'Name');
            lenName  = length(callName);
            if lenName<36
                strDEB = getWavMSG('Wavelet:commongui:Nam1_IntDepSet',callName);
            else
                strDEB = getWavMSG('Wavelet:commongui:Nam2_IntDepSet',callName);
            end
            lenStrDEB = length(strDEB);
            if lenStrDEB>72 , strDEB = [strDEB(1:72) '...']; end
            strName  = sprintf([strDEB ' (fig. %g)'],double(calling_Fig));
            fig = wfigmngr('init',      ...
                     'Name',strName,    ...
                     'Position',pos_win,...
                     'Visible','Off',   ...
                     'Tag',tag_figThresh...
                     );
            wfigmngr('extfig',fig,'ExtFig_ThrSet')
            ax = wfindobj(fig,'Type','axes');
            set(fig,'WindowButtonMotionFcn',wtmotion(ax));

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',fig,getWavMSG('Wavelet:commongui:HLP_IntDep_Loc'),'IDTS_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',fig,getWavMSG('Wavelet:commongui:HLP_IntDep_Var'),'VARTHR');
	
            set(fig,'Visible','On')
            xprop = (pos_win(3)+bdx-rightx)/pos_win(3);
            pos_dyn_visu = dynvtool('create',fig,xprop,0);
            ylow = pos_dyn_visu(4);
            pos_gra = [0, pos_dyn_visu(4), pos_win(3), pos_win(4)-ylow];

            % Creating axes and uicontrols.
            %==============================
            noINT_DEP = isempty(int_DepThr_Cell);

            % Positions
            %-----------
            d_txt   = (Def_Btn_Height-Def_Txt_Height)/2;
            w_fra   = rightx-bdx;
            x_fra   = pos_gra(3)-w_fra;
            pos_fra = [x_fra 0 w_fra pos_win(4)+5];
            bdx     = 6;
            bdy     = 6;
            h_txt   = Def_Txt_Height;
            h_btn   = Def_Btn_Height;
            w_fra_lev = w_fra-2*bdx;
            x_fra_lev = x_fra+bdx;
            w_pus     = (5*w_fra_lev)/6;
            x_pus     = x_fra_lev+(w_fra_lev-w_pus)/2; 

            h_fra_lev   = h_btn+2*bdy;
            y_fra_lev   = pos_win(4)-h_fra_lev-2*bdy;
            pos_fra_lev = [x_fra_lev y_fra_lev w_fra_lev h_fra_lev];            
            w_uic       = (w_fra_lev-2*bdx)/2;
            x_uic       = x_fra_lev+bdx;
            y_uic       = y_fra_lev+bdy;
            pos_txt_lev = [x_uic, y_uic+d_txt/2, w_uic, h_txt];
            x_uic       = x_uic+w_uic;
            pos_pop_lev = [x_uic, y_uic, w_uic, h_btn];

            y_fra_top   = y_fra_lev-6*bdy;
            w_uic       = w_fra_lev-bdx;
            x_uic       = x_fra_lev+(w_fra_lev-w_uic)/2;
            y_uic       = y_fra_top-h_txt-bdy;
            pos_txt_lim = [x_uic y_uic w_uic h_txt];        
            h_uic       = 1.5*h_btn;
            y_uic       = y_uic-h_uic-2*bdy;
            pos_pus_del = [x_pus, y_uic, w_pus, h_uic];
            y_uic       = y_uic-h_uic-2*bdy;
            pos_pus_pro = [x_pus, y_uic, w_pus, h_uic];
            y_fra_lim   = y_uic-bdy;
            h_fra_lim   = y_fra_top-y_fra_lim;
            pos_fra_lim = [x_fra_lev y_fra_lim w_fra_lev h_fra_lim];

            y_fra_top   = y_fra_lim-6*bdy;
            w_uic       = w_fra_lev-bdx;
            x_uic       = x_fra_lev+(w_fra_lev-w_uic)/2;
            h_def       = 3*h_txt;
            y_uic       = y_fra_top-h_def-bdy;
            pos_txt_def = [x_uic y_uic w_uic h_def];
            w_uic       = (w_fra_lev-2*bdx)/2;
            x_uic       = x_fra_lev+bdx;
            y_uic       = y_uic-h_btn-1*bdy;
            pos_txt_num = [x_uic, y_uic+d_txt/2, w_uic, h_txt];
            x_uic       = x_uic+w_uic;
            pos_pop_num = [x_uic, y_uic, w_uic, h_btn];
            h_uic       = 1.5*h_btn;
            
            if noINT_DEP , y_uic = y_uic-0.5*h_btn; end
            pos_pus_gen = [x_pus, y_uic, w_pus, h_uic];
            y_fra_def   = y_uic-bdy;
            h_fra_def   = y_fra_top-y_fra_def;
            pos_fra_def = [x_fra_lev y_fra_def w_fra_lev h_fra_def];

            y_uic       = h_btn/2;
            pos_close   = [x_pus y_uic w_pus h_uic];

            % Strings
            %--------
            str_txt_lev = getWavMSG('Wavelet:commongui:IntDep_Lev');
            str_levels  = int2str((1:NB_lev)');
            str_txt_lim = getWavMSG('Wavelet:commongui:IntDep_Del');
            str_pus_del = getWavMSG('Wavelet:commongui:Str_Delete');
            tip_pus_pro = getWavMSG('Wavelet:commongui:IntDep_PropInt');
            str_pus_pro = getWavMSG('Wavelet:commongui:IntDep_Propagate');
            str_txt_num = getWavMSG('Wavelet:commongui:Str_Number');
            str_pop_num = int2str((1:NB_Max_Int)');
            str_pus_gen = getWavMSG('Wavelet:commongui:Str_Generate');
            str_close   = getWavMSG('Wavelet:commongui:Str_Close');

            if noINT_DEP
                strBEG = getWavMSG('Wavelet:commongui:Str_Generate');
                strEND = getWavMSG('Wavelet:commongui:IntDep_DefInt');
                str_txt_def = sprintf([strBEG, '\n', strEND]);
                toolTipGEN = getWavMSG('Wavelet:commongui:IntDep_Thr');
                visNum = 'Off'; visGen = 'On';
            else
                str_txt_def = getWavMSG('Wavelet:commongui:IntDep_Thr');
                toolTipGEN  = getWavMSG('Wavelet:commongui:IntDep_SelNInt');
                visNum = 'On'; visGen = 'Off';
            end

            % Create UIC and Axes.
            %---------------------
            commonProp = {'Parent',fig,'Units','pixels'}; 
            uicontrol(...
                commonProp{:},   ...
                'Style','frame', ...
                'ForegroundColor',Def_ShadowColor, ...
                'Position', pos_fra ...
                );

            uicontrol(...
                commonProp{:},  ...
                'Style','frame',...
                'ForegroundColor',Def_ShadowColor, ...                
                'Position', pos_fra_lev ...
                );

            uicontrol(...
                commonProp{:},  ...
                'Style','text', ...
                'HorizontalAlignment','left', ...
                'Position',pos_txt_lev,       ...
                'String',str_txt_lev ...
                );
            
            fra_def  = uicontrol(...
                commonProp{:},  ...
                'Style','frame',...
                'ForegroundColor',Def_ShadowColor, ...                
                'Position', pos_fra_def ...
                );

            pop_lev = uicontrol(...
                commonProp{:},  ...
                'Style','Popup',...
                'Position',pos_pop_lev, ...
                'String',str_levels,    ...
                'UserData',1            ...
                );

            fra_lim  = uicontrol(...
                commonProp{:},  ...
                'Style','frame',...
                'ForegroundColor',Def_ShadowColor, ...                
                'Position', pos_fra_lim ...
                );

            txt_lim = uicontrol(...
                commonProp{:},  ...
                'Style','text', ...
                'HorizontalAlignment','Center', ...
                'Position',pos_txt_lim,       ...
                'String',str_txt_lim ...
                );
            
            pus_pro = uicontrol(...
                commonProp{:},...
                'Style','pushbutton',  ...
                'Position',pos_pus_pro, ...
                'String',str_pus_pro,   ...
                'Enable','On',         ...
                'TooltipString',tip_pus_pro ...
                );

            pus_del = uicontrol(...
                commonProp{:},     ...
                'Style','pushbutton',   ...
                'Position',pos_pus_del, ...
                'String',str_pus_del,   ...
                'Interruptible','on'    ...
                );

            txt_def = uicontrol(...
                commonProp{:},  ...
                'Style','text', ...
                'HorizontalAlignment','Center', ...
                'Max',2,                ...
                'Position',pos_txt_def, ...
                'TooltipString',toolTipGEN,   ...
                'String',str_txt_def ...
                );

            txt_num = uicontrol(...
                commonProp{:},  ...
                'Style','text', ...
                'Visible',visNum, ...
                'HorizontalAlignment','left', ...
                'Position',pos_txt_num,       ...
                'TooltipString',toolTipGEN,...
                'String',str_txt_num ...
                );

            pop_num = uicontrol(...
                commonProp{:},  ...
                'Style','Popup',...
                'Visible',visNum, ...
                'Position',pos_pop_num, ...
                'TooltipString',toolTipGEN,   ...
                'String',str_pop_num    ...
                );

            pus_gen = uicontrol(...
                commonProp{:},          ...
                'Style','pushbutton',   ...
                'Visible',visGen,       ...
                'Position',pos_pus_gen, ...
                'String',str_pus_gen,   ...
                'TooltipString',toolTipGEN,   ...
                'Interruptible','on'    ...
                );

            pus_close = uicontrol(...
                commonProp{:},        ...
                'Style','pushbutton', ...
                'Position',pos_close, ...
                'String',str_close,   ...
                'Interruptible','on', ...
                'Tag',tag_pus_close,  ...
                'UserData',0          ...
                );

            pos_axe = pos_gra+[leftx bottomy -(leftx+rightx) -(bottomy+topy)];
            ax_hdl  = axes(...
                        commonProp{:},     ...
                       'Position',pos_axe, ...
                       'box','on');
            ind_lev = 1;

            % Setting Callback.
            %------------------
            handles = ...
              [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
            if nargout>0
                varargout{1} = handles;
            end
            cb_pop_lev = @(~,~)utthrset('chg_level', handles);
            cb_pus_del = @(~,~)utthrset('del_Delimiters', handles);
            cb_pus_pro = @(~,~)utthrset('propagate', handles);
            cb_pop_num = @(~,~)utthrset('gen_Intervals', handles);
            cb_pus_gen = @(~,~)utthrset('gen_Intervals', handles);
            cb_close   = wfigmngr('attach_close',fig,mfilename,'cond');
            set(pop_lev,'Callback',cb_pop_lev);
            set(pus_del,'Callback',cb_pus_del);
            set(pus_pro,'Callback',cb_pus_pro);
            set(pop_num,'Callback',cb_pop_num);
            set(pus_gen,'Callback',cb_pus_gen);
            set(pus_close,'Callback',cb_close);

            % Waiting Text construction.
            %---------------------------
            wwaiting('create',fig,xprop);

            %  Normalization.
            %----------------
            wfigmngr('normalize',fig,pos_gra);
            pause(0.01)
%             modif_POS = false;
%             pos = get(fig,'Position');
%             if pos(1)<0 || (pos(1)+pos(3)>1)
%                 modif_POS = true;
%                 pos(1) = 0.01;
%                 pos(3) = 1-2*pos(1);
%             end
%             if pos(2)<0 || (pos(2)+pos(4)>1)
%                 modif_POS = true;                
%                 pos(2) = 0.01;
%                 pos(4) = 1-2*pos(2);
%             end
%             if modif_POS , set(fig,'Position',pos'); end
            set(fig,'Visible','on')
        else
          pus_close = wfindobj(existFig,...
                          'Style','pushbutton','Tag',tag_pus_close);
          hgfeval(pus_close.Callback);
          return
        end

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_GENER_VARTHR = [fra_lim,txt_lim,pus_pro,pus_del];
		hdl_MODIF_VARTHR = [fra_def,txt_def,txt_num,pop_num,pus_gen];
		wfighelp('add_ContextMenu',fig,hdl_GENER_VARTHR,'GENER_VARTHR');
		wfighelp('add_ContextMenu',fig,hdl_MODIF_VARTHR,'MODIF_VARTHR');		
		%-------------------------------------

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',fig,n_membloc1,...
                       ind_ret_fig,calling_Fig,ind_tog_thr,tog_thr,...
                       ind_status,0);
        wmemtool('wmb',fig,n_memblocTHR,...
                       ind_thr_struct,den_struct,...
                       ind_int_thr,int_DepThr_Cell ...
                       );

        % Plotting lines.
        %----------------
        plotlines(fig,ax_hdl,den_struct(ind_lev),ind_lev)

    case 'chg_level'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig     = in2(1);
        ax_hdl  = in2(2);
        pop     = in2(3);
        old_lev = get(pop,'UserData');
        new_lev = get(pop,'Value');
        if old_lev==new_lev , return; end
        lHu     = findobj(ax_hdl,'Tag',tag_lineH_up);
        cbthrw1d('upd_thrStruct',fig,lHu);
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        set(pop,'UserData',new_lev)
        plotlines(fig,ax_hdl,thrStruct(new_lev),new_lev);

    case 'del_Delimiters'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig   = in2(1);
        axe   = in2(2);
        % pop_num = in2(6);
        lines = findobj(axe,'Type','line');
        lHu   = findobj(lines,'Tag',tag_lineH_up);
        lHd   = findobj(lines,'Tag',tag_lineH_down);
        lV    = findobj(lines,'Tag',tag_lineV);
        xh    = get(lHu,'XData');
        yh    = get(lHu,'YData');
        xh    = xh([1 length(xh)]);
        yhok  = yh(~isnan(yh));
        yh    = mean(yhok);
        yh    = [yh yh];
        if ~isempty(lV),  delete(lV); end
        set(lHu,'XData',xh,'YData',yh)
        set(lHd,'XData',xh,'YData',-yh)
        cbthrw1d('upd_thrStruct',fig,lHu);

    case 'gen_Intervals'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig     = in2(1);
        ax_hdl  = in2(2);
        pop_lev = in2(3);
        txt_def = in2(4);
        txt_num = in2(5);
        pop_num = in2(6);
        pus_gen = in2(7);
        nb_IntVal = get(pop_num,'Value');

        % Delete previous delimiters.
        %----------------------------
        utthrset('del_Delimiters',in2);

        % Computing Intervals.
        %---------------------
        [thrStruct,int_DepThr_Cell] = wmemtool('rmb',fig,n_memblocTHR,...
                                          ind_thr_struct,ind_int_thr);
        if isempty(int_DepThr_Cell)
            % Compute decomposition and plot.
            %--------------------------------
			uic_ON = findall(fig,'Type','uicontrol','Enable','on');
			set(uic_ON, 'Enable','off');
			uic_MSG = wwaiting('handle',fig);
			set(uic_MSG,'Enable','on');
            msg = getWavMSG('Wavelet:commongui:IntDep_Wait');
            wwaiting('msg',fig,msg);           

            % Extract the detail of order1.
            %------------------------------
            hdl_DET1 = thrStruct(1).hdlLines;
            det   = get(hdl_DET1,'YData');
            xdata = get(hdl_DET1,'XData');

            % Replacing 2% of biggest values of by the mean.
            %-----------------------------------------------
            x = sort(abs(det));
            v2p100 = x(fix(length(x)*0.98));
            det(abs(det)>v2p100) = mean(det);
            lenDet   = length(det);

            % Finding breaking points.
            %-------------------------
            dum = get(pop_num,'String');
            nb_Max_Int = str2num(dum(end,:));
            d = 10;            
            if lenDet>1024
                ratio = ceil(lenDet/1024);
                [Rupt_Pts,nb_Opt_Rupt,Xidx] = ...
                    wvarchg(det(1:ratio:end),nb_Max_Int,d); %#ok<ASGLU>
                Xidx = min(ratio*Xidx,lenDet);
            else
                [Rupt_Pts,nb_Opt_Rupt,Xidx] = wvarchg(det,nb_Max_Int,d);  %#ok<ASGLU>
            end    
            nb_Opt_Int = nb_Opt_Rupt+1;

            % Computing denoising structure.
            %-------------------------------
            Xidx = [zeros(size(Xidx,1),1) Xidx];
            norma = sqrt(2)*thselect(det,'minimaxi');
            % sqrt(2) comes from the fact that if x is a white noise 
            % of variance 1 the reconstructed detail_1 of x is of 
            % variance 1/sqrt(2)            
            int_DepThr = cell(1,nb_Max_Int);
            for nbint = 1:nb_Max_Int
              for j = 1:nbint
                 sig = median(abs(det(Xidx(nbint,j)+1:Xidx(nbint,j+1))))/0.6745;
                 thr = norma*sig;
                 int_DepThr{nbint}(j,:) = ...
                     [Xidx(nbint,j) , Xidx(nbint,j+1), thr];
              end
              int_DepThr{nbint}(1,1) = 1;
              int_DepThr{nbint}(:,[1 2]) = xdata(int_DepThr{nbint}(:,[1 2]));
            end
            int_DepThr_Cell = {int_DepThr,nb_Opt_Int}; 
            wmemtool('wmb',fig,n_memblocTHR,ind_int_thr,int_DepThr_Cell);
            calling_Fig = wmemtool('rmb',fig,n_membloc1,ind_ret_fig);
            wmemtool('wmb',calling_Fig,n_memblocTHR,ind_int_thr,int_DepThr_Cell);            
            viewNUM = 1;

            % End waiting.
            %-------------
            wwaiting('off',fig);
			set(uic_ON,'Enable','on');

        else
            int_DepThr = int_DepThr_Cell{1};
            nb_Opt_Int = int_DepThr_Cell{2};
            viewNUM = isequal(lower(get(pus_gen,'Visible')),'on');
        end
        if viewNUM
            nb_IntVal = nb_Opt_Int;
            str_txt_def = getWavMSG('Wavelet:commongui:IntDep_IntSel');
            toolTipGEN  = getWavMSG('Wavelet:commongui:IntDep_SelNInt');          
            set(pop_num,'Value',nb_IntVal);
            set(pus_gen,'Visible','Off','TooltipString',toolTipGEN);
            set(txt_def,'String',str_txt_def,'TooltipString',toolTipGEN)
            set([txt_num,pop_num],'Visible','On','TooltipString',toolTipGEN);
        end

        intervals = int_DepThr{nb_IntVal};
        for k=1:length(thrStruct)
           if ~isempty(thrStruct(k).thrParams)
               maxTHR = max(abs(get(thrStruct(k).hdlLines,'YData')));
               thrPAR = intervals;
               TMP = min(thrPAR(:,3),maxTHR);
               thrPAR(:,3) = TMP;
               thrStruct(k).thrParams = thrPAR;
           end
        end
        wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);

        % Plotting lines.
        %----------------
        ind_lev = get(pop_lev,'Value');
        plotlines(fig,ax_hdl,thrStruct(ind_lev),ind_lev);



    case 'propagate'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig   = in2(1);
        axe   = in2(2);
        pop   = in2(3);
        lines = findobj(axe,'Type','line');
        lHu   = findobj(lines,'Tag',tag_lineH_up);
        xini  = get(lHu,'XData');
        yini  = get(lHu,'YData');
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        level  = get(pop,'Value');
        strlev = get(pop,'String');
        for k=1:size(strlev,1)
            lev = str2double(strlev(k,:));
            if lev~=level
                oldPar = thrStruct(lev).thrParams;
                [x,y] = getxy(oldPar);
                for j = 1:length(xini)
                    [dummy,ind] = min(x-xini(j)); %#ok<ASGLU>
                    yini(j) = y(ind);
                end
                newPar = getparam(xini,yini);
                thrStruct(lev).thrParams = newPar;
            end
        end
       wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);

    case 'clear_GRAPHICS'
        % called by lines callback
        % do nothing
        %--------------------------

    case 'close'
        fig = in2(1);
        [calling_Fig,tog_thr,status] = ...
            wmemtool('rmb',fig,n_membloc1,ind_ret_fig,ind_tog_thr,ind_status);
        if status
            thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
            status = wwaitans(fig,getWavMSG('Wavelet:commongui:IntDep_UpThr'),2,'cond');
            switch status
              case -1   
              case  0 
              case  1 , utthrw1d('return_SetThr',calling_Fig,thrStruct);
            end            
        end
        if status>-1 , set(tog_thr,'Value',0); end
        varargout{1} = status;

    case 'stop'
        calling_Fig = in2;
        oldFig = wfindobj('figure','Tag',tag_figThresh);
        existFig = ~isempty(oldFig);
        if existFig
            existFig = 0;
            for k = 1:length(oldFig)
                oldCall = wmemtool('rmb',oldFig(k),n_membloc1,ind_ret_fig);
                if isequal(oldCall,calling_Fig)
                   existFig = oldFig(k);
                   break
                end
            end
        end
        if existFig == 0 , return; end
        wmemtool('wmb',existFig,n_membloc1,ind_status,0);
        pus_close = ...
          wfindobj(existFig,'Style','pushbutton','Tag',tag_pus_close);
        hgfeval(pus_close.Callback);

    case 'demo'
        tog_thr = in2;
        nbINT   = in3;
        handles = utthrset('init',tog_thr);
        drawnow;
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig = handles(1);
        figure(fig)
        txt_def = handles(4);
        txt_num = handles(5);        
        pop_num = handles(6);
        pus_gen = handles(7);

		% Generating Intervals.
		%----------------------
        hgfeval(pus_gen.Callback);
		
		% Setting message for waiting.
		%-----------------------------
		uic_ON = findall(fig,'Type','uicontrol','Enable','on');
		uic_MSG = wwaiting('handle',fig);
		set(uic_ON, 'Enable','off');	
		set(uic_MSG,'Enable','on');
		msg = getWavMSG('Wavelet:moreMSGRF:Int_generated');
		wwaiting('msg',fig,msg);

        str_txt_def = getWavMSG('Wavelet:commongui:IntDep_IntSel');
        toolTipGEN  = getWavMSG('Wavelet:commongui:IntDep_SelNInt');
        set(pus_gen,'Visible','Off','TooltipString',toolTipGEN);
        
        %--------------------------------------------------------%
        fra_def = handles(end);
        pos_fra = get(fra_def,'Position');
        pos_num = get(pop_num,'Position');
        deltaH  = pos_num(4)/2;
        set(fra_def,'Position',pos_fra+[0 deltaH 0 -deltaH]);
        drawnow
        %--------------------------------------------------------%
        
        set(txt_def,'String',str_txt_def,'TooltipString',toolTipGEN)
        set([txt_num,pop_num],'Visible','On','TooltipString',toolTipGEN);
        nbINTComp = get(pop_num,'Value');
        if ~isequal(nbINTComp,nbINT)
		    msg = getWavMSG('Wavelet:commongui:SelNbInt');
		    wwaiting('msg',fig,msg);		
            pause(1.5)
            set(pop_num,'Value',nbINT);
            hgfeval(pop_num.Callback);
        end
        pause(3)
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        calling_Fig = wmemtool('rmb',fig,n_membloc1,ind_ret_fig);
        utthrw1d('return_SetThr',calling_Fig,thrStruct);
        delete(fig)
        set(tog_thr,'Value',0);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function param = getparam(x,y)

lx    = length(x);
x_beg = x(1:3:lx);
x_end = x(2:3:lx);
y     = y(1:3:lx);
param = [x_beg(:) , x_end(:) , y(:)];
%-----------------------------------------------------------------------------%
function [x,y] = getxy(arg)

NB_int  = size(arg,1);
if NB_int>1
    x = [arg(:,1:2) NaN*ones(NB_int,1)]';
    x = x(:)';
    l = 3*NB_int-1;
    x = x(1:l);
    y = [arg(:,[3 3]) NaN*ones(NB_int,1)]';
    y = y(:)';
    y = y(1:l);
else
    x = arg(1,1:2); y = arg(1,[3 3]);
end
%-----------------------------------------------------------------------------%
function plotlines(fig,ax_hdl,deno_struct,level)

linesHDL = findobj(ax_hdl,'Type','line');
if ~isempty(linesHDL), delete(linesHDL); end
hdlLineVal  = deno_struct.hdlLines;
[xHOR,yHOR] = getxy(deno_struct.thrParams);
if ~isempty(hdlLineVal)
    xdata = get(hdlLineVal,'XData');
    ydata = get(hdlLineVal,'YData');
    color = get(hdlLineVal,'Color');
    line(...
        'Parent',ax_hdl, ...
        'XData',xdata,   ...
        'YData',ydata,   ...
        'LineStyle','-', ...
        'LineWidth',1,   ...
        'Color',color,   ...
        'Tag','Sig'      ...
        );
    ysigmax = max(abs(ydata));
else
    ysigmax = 1;
end

[lHu,lHd] = cbthrw1d('plotLH',ax_hdl,xHOR,yHOR,level,ysigmax);
ylim  = get(ax_hdl,'YLim');
yVMin = 2*abs(ylim(1));
cbthrw1d('plotLV',[fig ; lHu ; lHd],[xHOR ; yHOR],yVMin);
notNAN = ~isnan(xHOR);
xmin   = min(xHOR(notNAN));
xmax   = max(xHOR(notNAN));
ymax   = 1.05*max([yHOR(notNAN),ysigmax]);
set(ax_hdl,'XLim',[xmin xmax],'YLim',[-ymax ymax])

% Dynvtool Attachment.
%---------------------
% All args to cbthrw1d are handles
dynvtool('init',fig,[],ax_hdl,[],[1 0],...
                '','','',[],'cbthrw1d',[ax_hdl lHu lHd]);
%-----------------------------------------------------------------------------%
%=============================================================================%
