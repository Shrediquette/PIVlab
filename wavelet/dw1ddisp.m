function varargout = dw1ddisp(option,win_dw1dtool,in3,in4)
%DW1DDISP Discrete wavelet 1-D display mode options.
%   DW1DDISP(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.23.4.16 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
% ind_sig_size   = 2;
% ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% Tag property of objects.
%-------------------------
tag_pop_viewm   = 'View_Mode';
% tag_pus_dispopt = 'Pus_Options';
tag_valapp_scr  = 'ValApp_Scr';
tag_valdet_scr  = 'ValDet_Scr';
tag_win_disp    = 'DispOpt1D';

% Local Tag property of objects.
%-------------------------------
tag_app_on   = 'Chk_App';
tag_s_app    = 'Chk_SA';
tag_ss_app   = 'Chk_SSA';
tag_app_num  = 'Chk_ANum';
tag_det_on   = 'Chk_Det';
tag_s_det    = 'Chk_SD';
tag_ss_det   = 'Chk_SSD';
tag_det_num  = 'Chk_DNum';
tag_cfs_on   = 'Chk_Cfs';
tag_txt_ccfs = 'Txt_CCfs';
tag_pop_ccfs = 'Pop_CCfs';
tag_app_txt  = 'App_Txt';
tag_app_all  = 'App_All';
tag_app_none = 'App_None';
tag_det_txt  = 'Det_Txt';
tag_det_all  = 'Det_All';
tag_det_none = 'Det_None';

children    = get(win_dw1dtool,'Children');
uic_handles = findobj(children,'flat','Type','uicontrol');
switch option
    case 'chk_sel'
        % in3 = chk_value
        % in4 = 'a' or 'd'
        %------------------
        chk_handles = findobj(uic_handles,'Style','checkbox');
        chk         = findobj(chk_handles,'Tag',in4);
        set(chk,'Value',in3);
        return

    case 'app_on'
        % in3 = num mode
        %------------------
        chk_handles = findobj(uic_handles,'Style','checkbox');
        chk_on  = findobj(chk_handles,'Tag',tag_app_on);
        chk_sa  = findobj(chk_handles,'Tag',tag_s_app);
        chk_ssa = findobj(chk_handles,'Tag',tag_ss_app);
        if in3==4
            pus_handles = findobj(uic_handles,'Style','pushbutton');
            txt_handles = findobj(uic_handles,'Style','text');
            pall    = findobj(pus_handles,'Tag',tag_app_all);
            pnone   = findobj(pus_handles,'Tag',tag_app_none);
            txt     = findobj(txt_handles,'Tag',tag_app_txt);
            chk_app = findobj(chk_handles,'Tag',tag_app_num);
        else
            pall = [];  pnone = [];  txt = [];  chk_app = [];
        end
        if get(chk_on,'Value')==1 , vis = 'on'; else vis = 'off'; end
        set([chk_sa ; chk_ssa ; pall ; pnone ; txt ; chk_app],'Visible',vis);     
        return

    case 'det_on'
        % in3 = num mode
        %------------------
        chk_handles = findobj(uic_handles,'Style','checkbox');
        chk_on  = findobj(chk_handles,'Tag',tag_det_on);
        chk_sd  = findobj(chk_handles,'Tag',tag_s_det);
        chk_ssd = findobj(chk_handles,'Tag',tag_ss_det);
        if in3==4
            pus_handles = findobj(uic_handles,'Style','pushbutton');
            txt_handles = findobj(uic_handles,'Style','text');
            pall    = findobj(pus_handles,'Tag',tag_det_all);
            pnone   = findobj(pus_handles,'Tag',tag_det_none);
            txt     = findobj(txt_handles,'Tag',tag_det_txt);
            chk_det = findobj(chk_handles,'Tag',tag_det_num);
        else
            pall = [];  pnone = [];  txt = [];  chk_det = [];
        end
        if get(chk_on,'Value')==1 , vis = 'on'; else vis = 'off'; end
        set([chk_sd ; chk_ssd ; pall ; pnone ; txt ; chk_det],'Visible',vis);
        return

    case 'cfs_on'
        chk_on = findobj(uic_handles,'Tag',tag_cfs_on);
        txt    = findobj(uic_handles,'Tag',tag_txt_ccfs);
        pop    = findobj(uic_handles,'Tag',tag_pop_ccfs);
        if get(chk_on,'Value')==1 , vis = 'on'; else vis = 'off'; end
        set([txt pop],'Visible',vis);
        return

    case 'ena_pop'
        % in3 = flg_axe
        pop_handles = findobj(uic_handles,'Style','popupmenu');
        pop_app = findobj(pop_handles,'Tag',tag_valapp_scr);
        pop_det = findobj(pop_handles,'Tag',tag_valdet_scr);
        if in3(1)==1 , ena = 'on'; else ena = 'off'; end
        set(pop_app,'Enable',ena);
        if in3(2)==1 , ena = 'on'; else ena = 'off'; end
        set(pop_det,'Enable',ena);
        return
end
        
pop_handles = findobj(uic_handles,'Style','popupmenu');
pop_viewm   = findobj(pop_handles,'Tag',tag_pop_viewm);
num_mode    = get(pop_viewm,'Value');

switch option
    case 'create'
        % Get Globals.
        %-------------
        [...
        Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,X_Spacing,Y_Spacing,...
        ediInActBkColor,Def_FraBkColor,Def_UicFtWeight,uicFonstsize...
        ] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'X_Spacing','Y_Spacing', ...
                'Def_Edi_InActBkColor','Def_FraBkColor', ...
                'Def_UicFtWeight','Def_UicFontSize'      ...
                );

        % Begin waiting.
        %--------------
        mousefrm(win_dw1dtool,'watch');

        win_units = 'pixels';
        [~,~,win_height,win_width] = wfigmngr('figsizes');
        old_units = get(win_dw1dtool,'Units');
        set(win_dw1dtool,'Units','pixels');
        pos_wcall = get(win_dw1dtool,'Position');
        set(win_dw1dtool,'Units',old_units);
        height0 = pos_wcall(4);
        
        % Resizing the Figure.
        %---------------------
        if win_height~=height0 , resize_win = 1; else resize_win = 0; end        
        if resize_win 
            RatScrPixPerInch = wtbxmngr('get','ResizeRatioWTBX_Fig');
            win_height = pos_wcall(4);
            win_width  = win_width*RatScrPixPerInch;
        end

        d_left = 10;
        if pos_wcall(1)<win_width+d_left
            x_left0 = pos_wcall(1)+pos_wcall(3)-win_width;
        else
            x_left0 = pos_wcall(1)-win_width-d_left;
        end
        pos_win = [x_left0 , pos_wcall(2) , win_width , win_height];
        
        win_dw1d_more  = wfindobj('figure','Tag',tag_win_disp);
        fig_name = getWavMSG('Wavelet:dw1dRF:NamWinMoreDisp_1D', ...
            handle2str(win_dw1dtool));
        if ~isempty(win_dw1d_more)
            old_win = get(win_dw1d_more,'UserData');
            if old_win~=win_dw1dtool
                msg = getWavMSG('Wavelet:dw1dRF:KeepNamWinMoreDisp_1D', ...
                        handle2str(old_win));                

                % Test for keeping display options.
                %----------------------------------
                new = wwaitans(old_win,msg,1,'cancel');
                if new==-1 , return; end
                if new==0  , dw1ddisp('cancel',old_win,win_dw1d_more); end

                dw1dutil('Enable',old_win,'end_more_disp');
                figure(win_dw1dtool);  
            end
        end
        dw1dutil('Enable',win_dw1dtool,'more_disp');
        if ~isempty(win_dw1d_more)
            hdl_in  = findobj(win_dw1d_more,'Type','uicontrol');
            delete(hdl_in);
            set(win_dw1d_more,'Name',fig_name,'UserData',win_dw1dtool);
        else
            win_dw1d_more = colordef('new','none');
            set(win_dw1d_more,...
                    'MenuBar','none',...
                    'WindowStyle','normal', ...
                    'DefaultUicontrolBackgroundColor', Def_FraBkColor,...
                    'DefaultUicontrolFontWeight',Def_UicFtWeight,...
                    'DefaultUicontrolFontSize',uicFonstsize,...                    
                    'Visible','on',         ...
                    'Units',win_units,      ...
                    'NumberTitle','off',    ...
                    'Name',fig_name,        ...
                    'Position',pos_win,     ...
                    'Color',Def_FraBkColor, ...
                    'BackingStore','off',   ...
                    'UserData',win_dw1dtool,...
                    'Tag',tag_win_disp      ...
                    );
            wfigmngr('extfig',win_dw1d_more,'ExtFig_More');
            set(win_dw1d_more,'Renderer','painters','RendererMode','auto')
			
			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',win_dw1d_more, ...
				getWavMSG('Wavelet:dw1dRF:Str_MoreDisp_1D'),'DW1D_MOREDISP');
        end
		if nargout>0 , varargout{1} = win_dw1d_more; end

		% Select the figure.   
		%-------------------
        set(win_dw1d_more,'HandleVisibility','on');
        figure(win_dw1d_more);

        % Borders and double borders.
        %----------------------------
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);

        % Position property of objects.
        %------------------------------
        Screen_Size = getMonitorSize;
        hpush = 3*Def_Btn_Height/2;
        if Screen_Size(4)<600
            Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
            if Level_Anal>6 && (num_mode==3 || num_mode==4)
                hpush = Def_Btn_Height;
            end
        end
        wPUS = 1.5*Def_Btn_Width/2;
        x_left0 = 0;
        ylow    = win_height-Def_Btn_Height-dy2;
        pos_txt_mname = [dx2, ylow, win_width-2*dx2,Def_Btn_Height];
        push_width = (win_width-3*dx2)/2;
        xleft      = (win_width-7*push_width/4)/2;
        pos_close  = [xleft, Def_Btn_Height,7*push_width/4, hpush];

        xleft = pos_close(1);
        ylow  = pos_close(2)+pos_close(4)+dy2;
        width = (pos_close(3)-dx2)/2;
        pos_apply  = [ xleft ,  ylow , width , hpush];
        xleft = pos_apply(1)+pos_apply(3)+dx2;
        pos_cancel = [ xleft ,  ylow , width , hpush];

        % String property of objects.
        %----------------------------
        str_mname  = get(pop_viewm,'String');
        str_mname  = [deblank(str_mname{num_mode,:}) '  '  ...
                getWavMSG('Wavelet:moreMSGRF:Str_Options')];
        str_apply  = getWavMSG('Wavelet:commongui:Str_Apply');
        str_cancel = getWavMSG('Wavelet:commongui:Str_Cancel');
        str_close  = getWavMSG('Wavelet:commongui:Str_Close');
        str_cfs_on = getWavMSG('Wavelet:dw1dRF:ShowCfsAxe');

        switch num_mode
            case {1,3,4} 
              str_txt_ccfs = getWavMSG('Wavelet:dw1dRF:Str_ColMod');
              str_pop_ccfs = { ...
                       getWavMSG('Wavelet:LastMessages:ini_lev_abs'); ...
                       getWavMSG('Wavelet:LastMessages:ini_lev');     ...
                       getWavMSG('Wavelet:LastMessages:ini_all_abs'); ...
                       getWavMSG('Wavelet:LastMessages:ini_all');     ...
                       getWavMSG('Wavelet:LastMessages:cur_lev_abs'); ...
                       getWavMSG('Wavelet:LastMessages:cur_lev');     ...
                       getWavMSG('Wavelet:LastMessages:cur_all_abs'); ...
                       getWavMSG('Wavelet:LastMessages:cur_all');     ...
                       };
            case 6
              str_txt_ccfs = getWavMSG('Wavelet:dw1dRF:Str_CfsVal');
              str_pop_ccfs = {...
                    getWavMSG('Wavelet:moreMSGRF:ABS_values'), ...
                    getWavMSG('Wavelet:moreMSGRF:CUR_values') ...
                    };
        end
        opt_act = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_act_option);
        if strcmp(opt_act,'synt')
            str_s_app = getWavMSG('Wavelet:dw1dRF:ShowOriSyntSig');
        else
            str_s_app = getWavMSG('Wavelet:dw1dRF:ShowSig');
        end

        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        switch ss_type
            case 'ss' , str_ss_app = getWavMSG('Wavelet:dw1dRF:ShowSyntSig_2');
            case 'ds' , str_ss_app = getWavMSG('Wavelet:dw1dRF:ShowDenoSig_2');
            case 'cs' , str_ss_app = getWavMSG('Wavelet:dw1dRF:ShowCompSig_2');
        end
        str_s_det  = str_s_app;
        str_ss_det = str_ss_app;
        switch num_mode
            case {1,4,6}
              str_app_on = getWavMSG('Wavelet:dw1dRF:ShowAppAxe');
              str_det_on = getWavMSG('Wavelet:dw1dRF:ShowDetAxe');
            case 3
              str_app_on = getWavMSG('Wavelet:dw1dRF:ShowLeftAxe');
              str_det_on = getWavMSG('Wavelet:dw1dRF:ShowRightAxe');
        end
        if (num_mode==3)
            str_app_txt = getWavMSG('Wavelet:dw1dRF:AppAxes');
            str_det_txt = getWavMSG('Wavelet:dw1dRF:DetAxes');
        elseif (num_mode==4)
            str_app_txt = getWavMSG('Wavelet:dw1dRF:AppLevels');
            str_det_txt = getWavMSG('Wavelet:dw1dRF:DetLevels');
        end
        if (num_mode==3) || (num_mode==4)
            str_app_all  = getWavMSG('Wavelet:commongui:Str_All');
            str_app_none = getWavMSG('Wavelet:commongui:Str_None');
            str_det_all  = getWavMSG('Wavelet:commongui:Str_All');
            str_det_none = getWavMSG('Wavelet:commongui:Str_None');
        end

        % Callback property of objects.
        %------------------------------
        cba_close   = @(~,~)dw1ddisp('close', win_dw1dtool, win_dw1d_more);
        cba_apply   = @(~,~)dw1ddisp('apply', win_dw1dtool , win_dw1d_more);
        cba_cancel  = @(~,~)dw1ddisp('cancel', win_dw1dtool , win_dw1d_more);
        cba_app_on  = @(~,~)dw1ddisp('app_on', win_dw1d_more , num_mode);
        cba_det_on  = @(~,~)dw1ddisp('det_on', win_dw1d_more , num_mode);
        cba_app_all = @(~,~)dw1ddisp('chk_sel', win_dw1d_more, 1, tag_app_num);
        cba_app_none = @(~,~)dw1ddisp('chk_sel', win_dw1d_more, 0, tag_app_num);
        cba_det_all  = @(~,~)dw1ddisp('chk_sel', win_dw1d_more, 1, tag_det_num);
        cba_det_none = @(~,~)dw1ddisp('chk_sel', win_dw1d_more, 0, tag_det_num);
        cba_cfs_on   = @(~,~)dw1ddisp('cfs_on',win_dw1d_more);

        % Properties of HG.
        %------------------
        comFigProp = {'Parent',win_dw1d_more,'Units',win_units};
        comPusProp = [comFigProp,'Style','pushbutton'];
        comChkProp = [comFigProp, ...
           'Style','Checkbox','HorizontalAlignment','left'];
        comTxtProp = [comFigProp, ...
           'Style','Text','BackgroundColor',Def_FraBkColor];

        uicontrol(...
            comFigProp{:},         ...
            'Style','Edit',        ...
            'Enable','Inactive',   ...
            'HorizontalAlignment','center', ...
            'Position',pos_txt_mname,       ...
            'Max',1, ...
            'String',str_mname,             ...
            'BackgroundColor',ediInActBkColor...
            );
        uicontrol(...
            comPusProp{:}, ...
            'Position',pos_apply, ...
            'String',str_apply,   ...
            'Interruptible','On', ...
            'Callback',cba_apply  ...
            );

        uicontrol(...
            comPusProp{:}, ...
            'Position',pos_cancel,...
            'String',str_cancel,  ...
            'Interruptible','On', ...
            'Callback',cba_cancel ...
            );

        uicontrol(...
            comPusProp{:}, ...
            'Position',pos_close,   ...
            'String',str_close,     ...
            'Interruptible','On',   ...
            'TooltipString',getWavMSG('Wavelet:dw1dRF:Str_CloseWin'), ...
            'Callback',cba_close    ...
            );

        % Prevent OS closing (04-Sep-97)
        set(win_dw1d_more,'CloseRequestFcn',cba_close);

        ylow = pos_txt_mname(2);
        widchk = 1.2*Def_Btn_Width/2;
        switch num_mode
            case {1,6}
                %%%%%%%%%%-------- Mode : "Show and Scroll" ------%%%%%%%%%%
                [flg_axe,flg_sa,~,flg_sd,~,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode);
                val_flg = [flg_axe(1) flg_sa flg_axe(2) flg_sd];
                vis_str = getonoff([1 flg_axe([1 1]) 1 flg_axe([2 2])]);
                val_cfs = flg_axe(3);
                if val_cfs==0
                    vis_txt_ccfs = 'off';   vis_pop_ccfs = 'off';
                else
                    vis_txt_ccfs = 'on';    vis_pop_ccfs = 'on';
                end

                % Position property of objects.
                %------------------------------
                ylow       = ylow-Def_Btn_Height-3*dy2;
                wid1       = 2*(Def_Btn_Width+dx2);
                wid2       = 2*Def_Btn_Width+dx2;
                pos_app_on = [2*dx2, ylow, wid1, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height-dy;
                pos_s_app  = [3*dx2, ylow, wid2, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height;
                pos_ss_app = [3*dx2, ylow, wid2, Def_Btn_Height];

                ylow       = ylow-Def_Btn_Height-3*dy2;
                pos_det_on = [2*dx2, ylow, wid1, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height-dy;
                pos_s_det  = [3*dx2, ylow, wid2, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height;
                pos_ss_det = [3*dx2, ylow, wid2, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height-3*dy2;
                pos_cfs_on = [2*dx2, ylow, wid1, Def_Btn_Height];
                ylow       = ylow-Def_Btn_Height-dy2;
                pos_txt_ccfs= [2*dx2, ylow, wid1, Def_Btn_Height];
                ylow        = ylow-Def_Btn_Height;
                pos_pop_ccfs= [2*dx2, ylow, wid1, Def_Btn_Height];

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_app_on,  ...
                    'String',str_app_on,    ...
                    'Visible',vis_str{1},   ...
                    'Value',val_flg(1),     ...
                    'Tag',tag_app_on,       ...
                    'Callback',cba_app_on   ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_app,   ...
                    'String',str_s_app,     ...
                    'Visible',vis_str{2},   ...
                    'Value',val_flg(2),     ...
                    'Tag',tag_s_app         ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_ss_app,  ...
                    'String',str_ss_app,    ...
                    'Visible',vis_str{3},   ...
                    'Value',val_flg(3),     ...
                    'Tag',tag_ss_app        ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_det_on,  ...
                    'String',str_det_on,    ...
                    'Visible',vis_str{4},   ...
                    'Value',val_flg(4),     ...
                    'Tag',tag_det_on,       ...
                    'Callback',cba_det_on   ...
                                   );
                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_det,   ...
                    'String',str_s_det,     ...
                    'Visible',vis_str{5},   ...
                    'Value',val_flg(5),     ...
                    'Tag',tag_s_det ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_ss_det,  ...
                    'String',str_ss_det,    ...
                    'Visible',vis_str{6},   ...
                    'Value',val_flg(6),     ...
                    'Tag',tag_ss_det        ...
                    );
                dw1ddisp('ena_pop',win_dw1dtool,flg_axe(1:2));


            case 2
                %%%%%%%%%%---- Mode : "Full Decomposition" ----%%%%%%%%%%

            case 3
                %%%%%%%%%%---------- Mode : "Separate" --------%%%%%%%%%%
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                                        ind_lev_anal);
                nb_inline = 3;
                nb        = nb_inline+1;

                if Level_Anal > 6
                    btn_height = 4*Def_Btn_Height/5;
                    if Screen_Size(4)<600
                        chk_height = Def_Btn_Height;
                    else
                        chk_height = btn_height;
                    end
                else
                    btn_height = Def_Btn_Height;
                    chk_height = Def_Btn_Height;
                end

                [flg_axe,sa_flg,app_flg,sd_flg,det_flg,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode);
                l_s_flg = flg_axe(1);
                r_s_flg = flg_axe(2);   
                val_cfs = flg_axe(3);
                val_flg = [l_s_flg , sa_flg , r_s_flg , sd_flg];
                vis_str = getonoff([1 l_s_flg l_s_flg 1 r_s_flg r_s_flg ]);
                if val_cfs==0
                    vis_txt_ccfs = 'off'; vis_pop_ccfs = 'off';
                else
                    vis_txt_ccfs = 'on';  vis_pop_ccfs = 'on';
                end

                % Position property of objects.
                %------------------------------
                ylow         = ylow-Def_Btn_Height-3*dy2;
                w_uic        = 2*(Def_Btn_Width+1.5*dx2);
                pos_app_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*Def_Btn_Width+dx2;
                pos_s_app    = [3*dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_ss_app   = [3*dx2, ylow, w_uic, Def_Btn_Height];
                px           = x_left0+(win_width-3*push_width/2)/2;
                ylow         = ylow-3*Def_Btn_Height/2;
                w_uic        = 3*push_width/2;
                pos_app_txt  = [px, ylow+d_txt/2, w_uic, Def_Txt_Height];
                wx           = (win_width-nb*widchk)/(nb+1);
                xbtchk0      = x_left0+Def_Btn_Width/2+3*wx;
                ybtchk0      = pos_app_txt(2)-Def_Btn_Height;
                ylow         = ybtchk0;
                pos_app_all  = [x_left0+wx, ylow, wPUS, btn_height];
                ylow         = ylow-6*btn_height/5;
                pos_app_none = [pos_app_all(1), ylow, wPUS, btn_height];

                wx           = (win_width-nb*widchk)/(nb+1);
                xbtchk       = xbtchk0;
                ybtchk       = ybtchk0;
                pos_chk_app  = zeros(Level_Anal,4);
                for i=1:Level_Anal
                    pos_chk_app(i,:) = [xbtchk ybtchk widchk chk_height];
                    if rem(i,nb_inline)==0
                        xbtchk = xbtchk0;
                        ybtchk = ybtchk-6*btn_height/5;
                    else
                        xbtchk = xbtchk+widchk+wx;
                    end
                end

                mi = min(pos_app_none(2),pos_chk_app(Level_Anal,2));
                ylow         = mi-Def_Btn_Height-2*dy2;
                w_uic        = 2*(Def_Btn_Width+1.5*dx2);
                pos_det_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*Def_Btn_Width+dx2;
                pos_s_det    = [3*dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_ss_det   = [3*dx2, ylow, w_uic, Def_Btn_Height];
                px           = x_left0+(win_width-3*push_width/2)/2;
                ylow         = ylow-3*Def_Btn_Height/2;
                w_uic        = 3*push_width/2;
                pos_det_txt  = [px, ylow+d_txt/2, w_uic, Def_Txt_Height];
                xbtchk0      = x_left0+Def_Btn_Width/2+3*wx;
                ybtchk0      = pos_det_txt(2)-Def_Btn_Height;
                wx           = (win_width-nb*widchk)/(nb+1);
                ylow         = ybtchk0;
                pos_det_all  = [x_left0+wx, ylow, wPUS, btn_height];
                ylow         = ylow-6*btn_height/5;
                pos_det_none = [pos_det_all(1), ylow, wPUS, btn_height];

                wx           = (win_width-nb*widchk)/(nb+1);
                xbtchk       = xbtchk0;
                ybtchk       = ybtchk0;
                pos_chk_det  = zeros(Level_Anal,4);
                for i=1:Level_Anal
                    pos_chk_det(i,:) = ...
                        [xbtchk ybtchk widchk chk_height];
                    if rem(i,nb_inline)==0
                        xbtchk = xbtchk0;
                        ybtchk = ybtchk-6*btn_height/5;
                    else
                        xbtchk = xbtchk+widchk+wx;
                    end
                end

                mi = min(pos_det_none(2),pos_chk_det(Level_Anal,2));
                ylow         = mi-Def_Btn_Height-2*dy2;
                w_uic        = 2*(Def_Btn_Width+1.5*dx2);
                pos_cfs_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*(Def_Btn_Width+dx2);
                pos_txt_ccfs = [2*dx2, ylow+d_txt/2, w_uic, Def_Txt_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_pop_ccfs = [2*dx2, ylow+d_txt/2, w_uic, Def_Btn_Height];

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_app_on,  ...
                    'String',str_app_on,    ...
                    'Visible',vis_str{1},   ...
                    'Value',val_flg(1),     ...
                    'Tag',tag_app_on,       ...
                    'Callback',cba_app_on   ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_app,   ...
                    'String',str_s_app,     ...
                    'Visible',vis_str{2},   ...
                    'Value',val_flg(2),     ...
                    'Tag',tag_s_app         ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Units',win_units,       ...
                    'Position',pos_ss_app,  ...
                    'String',str_ss_app,    ...
                    'Visible',vis_str{3},   ...
                    'Value',val_flg(3),     ...
                    'Tag',tag_ss_app        ...
                    );

                uicontrol(...
                    comTxtProp{:}, ...
                    'Position',pos_app_txt,...
                    'String',str_app_txt,...
                    'HorizontalAlignment','center', ...
                    'Visible','on',...
                    'Tag',tag_app_txt...
                    );
                pus_app_all  = uicontrol(...
                                     comPusProp{:}, ...
                                     'Position',pos_app_all,...
                                     'String',str_app_all,...
                                     'Visible','on',...
                                     'Tag',tag_app_all,...
                                     'Callback',cba_app_all  ...
                                     );
                uicontrol(...
                    comPusProp{:}, ...
                    'Position',pos_app_none,...
                    'String',str_app_none,...
                    'Visible','on',...
                    'Tag',tag_app_none,...
                    'Callback',cba_app_none ...
                    );


                Chk_App_Lst  = zeros(Level_Anal,1);
                for i=1:Level_Anal
                    Chk_App_Lst(i) = uicontrol(...
                                      comChkProp{:},     ...
                                      'Position',pos_chk_app(i,:),...
                                      'Value',app_flg(i),         ...
                                      'String',sprintf('%.0f',i), ...
                                      'Visible','on',             ...
                                      'UserData',i,               ...
                                      'Tag',tag_app_num           ...
                                      );
                end
                set(pus_app_all,'UserData',Chk_App_Lst);

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_det_on,  ...
                    'String',str_det_on,    ...
                    'Visible',vis_str{4},   ...
                    'Value',val_flg(4),     ...
                    'Tag',tag_det_on,       ...
                    'Callback',cba_det_on   ...
                    );
                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_det,   ...
                    'String',str_s_det,     ...
                    'Visible',vis_str{5},   ...
                    'Value',val_flg(5),     ...
                    'Tag',tag_s_det ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_ss_det,  ...
                    'String',str_ss_det,    ...
                    'Visible',vis_str{6},   ...
                    'Value',val_flg(6),     ...
                    'Tag',tag_ss_det        ...
                    );

               uicontrol(...
                   comTxtProp{:}, ...
                   'Position',pos_det_txt,...
                   'String',str_det_txt,...
                   'HorizontalAlignment','center', ...
                   'Visible','on',...
                   'Tag',tag_det_txt...
                   );
                pus_det_all  = uicontrol(...
                                     comPusProp{:}, ...
                                     'Position',pos_det_all,...
                                     'String',str_det_all,...
                                     'Visible','on',...
                                     'Tag',tag_det_all,...
                                     'Callback',cba_det_all  ...
                                     );
                 uicontrol(...
                     comPusProp{:}, ...
                     'Position',pos_det_none,...
                     'String',str_det_none,...
                     'Visible','on',...
                     'Tag',tag_det_none,...
                     'Callback',cba_det_none ...
                     );

                Chk_Det_Lst  = zeros(Level_Anal,1);
                for i=1:Level_Anal
                    Chk_Det_Lst(i) = uicontrol(...
                                    comChkProp{:}, ...
                                    'Position',pos_chk_det(i,:),...
                                    'Value',det_flg(i),         ...
                                    'String',sprintf('%.0f',i), ...
                                    'Visible','on',             ...
                                    'Tag',tag_det_num           ...
                                    );
                end
                set(pus_det_all,'UserData',Chk_Det_Lst);
                drawnow;

            case 4
                %%%%%%%%%%------ Mode : "Superimpose" ----%%%%%%%%%%
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                                        ind_lev_anal);
                nb_inline = 3;
                nb        = nb_inline+1;

                if Level_Anal > 6
                    btn_height = 4*Def_Btn_Height/5;
                    if Screen_Size(4)<600
                        chk_height = Def_Btn_Height;
                    else
                        chk_height = btn_height;
                    end
                else
                    btn_height = Def_Btn_Height;
                    chk_height = Def_Btn_Height;
                end

                [flg_axe,flg_sa,flg_app,flg_sd,flg_det,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode);
                if flg_axe(3)== 0
                    vis_txt_ccfs = 'off'; vis_pop_ccfs = 'off';
                else
                    vis_txt_ccfs = 'on';  vis_pop_ccfs = 'on';
                end
                vis_str = getonoff([1 flg_axe([1 1]) 1 flg_axe([2 2])]);
                val_flg = [flg_axe(1) flg_sa flg_axe(2) flg_sd flg_axe(3)];
                val_app = flg_app;
                val_det = flg_det;
                val_cfs = flg_axe(3);

                % Position property of objects.
                %------------------------------
                ylow         = ylow-Def_Btn_Height-3*dy2;
                w_uic        = 2*(Def_Btn_Width+1.5*dx2);                
                pos_app_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*Def_Btn_Width+dx2;
                pos_s_app    = [3*dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_ss_app   = [3*dx2, ylow, w_uic, Def_Btn_Height];
                px           = x_left0+(win_width-3*push_width/2)/2;
                ylow         = ylow-3*Def_Btn_Height/2;
                w_uic        = 3*push_width/2;
                pos_app_txt  = [px, ylow+d_txt/2, w_uic, Def_Txt_Height];
                wx           = (win_width-nb*widchk)/(nb+1);
                ylow         = ylow-6*btn_height/5;
                pos_app_all  = [x_left0+wx, ylow, wPUS, btn_height];
                ylow         = ylow-6*btn_height/5;
                pos_app_none = [pos_app_all(1), ylow, wPUS, btn_height];
                wx           = (win_width-nb*widchk)/(nb+1);
                xbtchk0      = x_left0+widchk+3*wx;
                ybtchk0      = pos_app_txt(2)-Def_Btn_Height;
                xbtchk       = xbtchk0;
                ybtchk       = ybtchk0;
                pos_chk_app  = zeros(Level_Anal,4);
                for i=1:Level_Anal
                    pos_chk_app(i,:) = ...
                        [xbtchk ybtchk widchk chk_height];
                    if rem(i,nb_inline)==0
                        xbtchk = xbtchk0;
                        ybtchk = ybtchk-6*btn_height/5;
                    else
                        xbtchk = xbtchk+widchk+wx;
                    end
                end

                mi = min(pos_app_none(2),pos_chk_app(Level_Anal,2));
                ylow         = mi-Def_Btn_Height-2*dy2;
                w_uic        = 2*(Def_Btn_Width+1.5*dx2);
                pos_det_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*Def_Btn_Width+dx2;
                pos_s_det    = [3*dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_ss_det   = [3*dx2, ylow, w_uic, Def_Btn_Height];
                px           = x_left0+(win_width-3*push_width/2)/2;
                ylow         = ylow-3*Def_Btn_Height/2;
                w_uic        = 3*push_width/2;
                pos_det_txt  = [px, ylow+d_txt/2, w_uic, Def_Txt_Height];
                wx           = (win_width-nb*widchk)/(nb+1);
                ylow         = ylow-6*btn_height/5;
                pos_det_all  = [x_left0+wx, ylow, wPUS, btn_height];
                ylow         = ylow-6*btn_height/5;
                pos_det_none = [pos_det_all(1), ylow, wPUS, btn_height];
                wx           = (win_width-nb*widchk)/(nb+1);
                xbtchk0      = x_left0+widchk+3*wx;
                ybtchk0      = pos_det_txt(2)-Def_Btn_Height;
                xbtchk       = xbtchk0;
                ybtchk       = ybtchk0;
                pos_chk_det  = zeros(Level_Anal,4);
                for i=1:Level_Anal
                    pos_chk_det(i,:) = ...
                        [xbtchk ybtchk widchk chk_height];
                    if rem(i,nb_inline)==0
                        xbtchk = xbtchk0;
                        ybtchk = ybtchk-6*btn_height/5;
                    else
                        xbtchk = xbtchk+widchk+wx;
                    end
                end

                mi = min(pos_det_none(2),pos_chk_det(Level_Anal,2));
                ylow         = mi-Def_Btn_Height-2*dy2;
                w_uic        = 1.1*2*(Def_Btn_Width+1.5*dx2);
                pos_cfs_on   = [dx2, ylow, w_uic, Def_Btn_Height];
                ylow         = ylow-Def_Btn_Height-dy;
                w_uic        = 2*(Def_Btn_Width+dx2);
                pos_txt_ccfs = [2*dx2, ylow+d_txt/2, w_uic, Def_Txt_Height];
                ylow         = ylow-Def_Btn_Height;
                pos_pop_ccfs = [2*dx2, ylow, w_uic, Def_Btn_Height];
                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_app_on,  ...
                    'String',str_app_on,    ...
                    'Visible',vis_str{1},   ...
                    'Value',val_flg(1),     ...
                    'Tag',tag_app_on,       ...
                    'Callback',cba_app_on   ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_app,   ...
                    'String',str_s_app,     ...
                    'Visible',vis_str{2},   ...
                    'Value',val_flg(2),     ...
                    'Tag',tag_s_app         ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_ss_app,  ...
                    'String',str_ss_app,    ...
                    'Visible',vis_str{3},   ...
                    'Value',val_flg(3),     ...
                    'Tag',tag_ss_app        ...
                    );

                uicontrol(...
                    comTxtProp{:}, ...
                    'Position',pos_app_txt, ...
                    'String',str_app_txt,   ...
                    'Visible',vis_str{3},   ...
                    'Tag',tag_app_txt       ...
                    );
                pus_app_all = uicontrol(...
                                        comPusProp{:}, ...
                                        'Position',pos_app_all, ...
                                        'String',str_app_all,   ...
                                        'Visible',vis_str{3},   ...
                                        'Tag',tag_app_all,      ...
                                        'Callback',cba_app_all  ...
                                        );
                uicontrol(...
                    comPusProp{:}, ...
                    'Position',pos_app_none,...
                    'String',str_app_none,  ...
                    'Visible',vis_str{3},   ...
                    'Tag',tag_app_none,     ...
                    'Callback',cba_app_none ...
                    );


                Chk_App_Lst     = zeros(Level_Anal,1);
                for i=1:Level_Anal
                  Chk_App_Lst(i) = uicontrol(...
                                     comChkProp{:}, ...
                                     'Position',pos_chk_app(i,:),...
                                     'Value',val_app(i),         ...
                                     'String',sprintf('%.0f',i), ...
                                     'Visible',vis_str{3},       ...
                                     'Tag',tag_app_num           ...
                                     );
                end
                set(pus_app_all,'UserData',Chk_App_Lst);

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_det_on,  ...
                    'String',str_det_on,    ...
                    'Visible',vis_str{4},   ...
                    'Value',val_flg(4),     ...
                    'Tag',tag_det_on,       ...
                    'Callback',cba_det_on   ...
                    );
                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_s_det,   ...
                    'String',str_s_det,     ...
                    'Visible',vis_str{5},   ...
                    'Value',val_flg(5),     ...
                    'Tag',tag_s_det         ...
                    );

                uicontrol(...
                    comChkProp{:}, ...
                    'Position',pos_ss_det,  ...
                    'String',str_ss_det,    ...
                    'Visible',vis_str{6},   ...
                    'Value',val_flg(6),     ...
                    'Tag',tag_ss_det        ...
                    );

                uicontrol(...
                    comTxtProp{:}, ...
                    'Position',pos_det_txt, ...
                    'String',str_det_txt,   ...
                    'Visible',vis_str{6},   ...
                    'Tag',tag_det_txt       ...
                    );
                pus_det_all = uicontrol(...
                                        comPusProp{:}, ...
                                        'Position',pos_det_all, ...
                                        'String',str_det_all,   ...
                                        'Visible',vis_str{6},   ...
                                        'Tag',tag_det_all,      ...
                                        'Callback',cba_det_all  ...
                                        );
                uicontrol(...
                    comPusProp{:}, ...
                    'Position',pos_det_none,...
                    'String',str_det_none,  ...
                    'Visible',vis_str{6},   ...
                    'Tag',tag_det_none,     ...
                    'Callback',cba_det_none ...
                    );

                Chk_Det_Lst = zeros(Level_Anal,1);
                for i=1:Level_Anal
                  Chk_Det_Lst(i) = uicontrol(...
                                     comChkProp{:},     ...
                                     'Position',pos_chk_det(i,:),...
                                     'Value',val_det(i),         ...
                                     'String',sprintf('%.0f',i), ...
                                     'Visible',vis_str{6},       ...
                                     'Tag',tag_det_num           ...
                                     );
                end
                set(pus_det_all,'UserData',Chk_Det_Lst);
                drawnow;

            case 5
                %%%%%%%%%%-------- Mode : "Tree Mode" ------%%%%%%%%%%

        end

        if find(num_mode==[1 3 4 6])
            uicontrol(...
                comChkProp{:}, ...
                'Position',pos_cfs_on,  ...
                'String',str_cfs_on,    ...
                'Visible','on',         ...
                'Value',val_cfs,        ...
                'Tag',tag_cfs_on,       ...
                'Callback',cba_cfs_on   ...
                );
            txt_ccfs = uicontrol(...
                                comTxtProp{:}, ...
                                'Position',pos_txt_ccfs,...
                                'Visible',vis_txt_ccfs, ...
                                'String',str_txt_ccfs,  ...
                                'Tag',tag_txt_ccfs      ...
                                );

            pop_ccfs  = uicontrol(...
                                comFigProp{:}, ...
                                'Style','Popup',        ...
                                'Position',pos_pop_ccfs,...
                                'Visible',vis_pop_ccfs, ...
                                'String',str_pop_ccfs,  ...
                                'Value',ccfs_m,         ...
                                'Tag',tag_pop_ccfs      ...
                                );

			% Add Context Sensitive Help (CSHelp).
			%-------------------------------------
			hdl_CSHelp = [txt_ccfs,pop_ccfs];
			wfighelp('add_ContextMenu',win_dw1d_more,hdl_CSHelp,'CW_COLMODE');
			%-------------------------------------
								
        end

        %  Normalization.
        %----------------
        set(findobj(win_dw1d_more,'Units','pixels'),'Units','normalized');
        set(win_dw1d_more,'HandleVisibility','off');

        % End waiting.
        %---------------
        mousefrm(win_dw1dtool,'arrow');

    case 'apply'
        % in3 = win_dw1d_more
        %--------------------
        win_dw1d_more = in3;
        chk_handles   = findobj(win_dw1d_more,'Style','checkbox');
        pus_handles   = findobj(win_dw1d_more,'Style','pushbutton');
        chk_app_on    = findobj(chk_handles,'Tag',tag_app_on);
        chk_s_app     = findobj(chk_handles,'Tag',tag_s_app);
        chk_ss_app    = findobj(chk_handles,'Tag',tag_ss_app);
        chk_det_on    = findobj(chk_handles,'Tag',tag_det_on);
        chk_s_det     = findobj(chk_handles,'Tag',tag_s_det);
        chk_ss_det    = findobj(chk_handles,'Tag',tag_ss_det);
        chk_cfs_on    = findobj(chk_handles,'Tag',tag_cfs_on);
        pop_ccfs      = findobj(win_dw1d_more,'Tag',tag_pop_ccfs);
        flg_axe       = [get(chk_app_on,'Value'),...
                         get(chk_det_on,'Value'),...
                         get(chk_cfs_on,'Value') ...
                         ];
        flg_sa        = [get(chk_s_app,'Value'), get(chk_ss_app,'Value')];
        flg_sd        = [get(chk_s_det,'Value'), get(chk_ss_det,'Value')];
        val_cfs       =  get(pop_ccfs,'Value');

        switch num_mode
            case {1,6}
                dw1dvmod('set_vm',win_dw1dtool,num_mode,...
                                flg_axe,flg_sa,1,flg_sd,1,val_cfs);
                            
                dw1ddisp('ena_pop',win_dw1dtool,flg_axe(1:2));
                
            case {2,5}

            case {3,4}
                pus_app_all = findobj(pus_handles,'Tag',tag_app_all);
                pus_det_all = findobj(pus_handles,'Tag',tag_det_all);
                chk_app_lst = get(pus_app_all,'UserData');
                chk_det_lst = get(pus_det_all,'UserData');
                lev_anal    = length(chk_app_lst);
                flg_app = get(chk_app_lst(1:lev_anal),'Value');
                flg_app = cat(2,flg_app{:});
                flg_det = get(chk_det_lst(1:lev_anal),'Value');
                flg_det = cat(2,flg_det{:});
                dw1dvmod('set_vm',win_dw1dtool,num_mode,...
                              flg_axe,flg_sa,flg_app,flg_sd,flg_det,val_cfs);
                          
        end

        % Begin waiting.
        %--------------
        mousefrm(win_dw1dtool,'watch')

        switch num_mode
            case 1 , fname = 'dw1dscrm';
            case 2 , fname = 'dw1ddecm';
            case 3 , fname = 'dw1dsepm';
            case 4 , fname = 'dw1dsupm';
            case 5 , fname = 'dw1dtrem';
            case 6 , fname = 'dw1dcfsm';
        end
        feval(fname,'view',win_dw1dtool,-1);

        % End waiting.
        %---------------
        mousefrm(win_dw1dtool,'arrow')

        figure(win_dw1d_more)
		if nargout>0 , varargout{1} = win_dw1d_more; end

    case 'cancel'
        % in3 = win_dw1d_more
        %--------------------
        win_dw1d_more = in3;
        chk_handles   = findobj(win_dw1d_more,'Style','checkbox');
        pus_handles   = findobj(win_dw1d_more,'Style','pushbutton');
        chk_app_on    = findobj(chk_handles,'Tag',tag_app_on);
        chk_s_app     = findobj(chk_handles,'Tag',tag_s_app);
        chk_ss_app    = findobj(chk_handles,'Tag',tag_ss_app);
        chk_det_on    = findobj(chk_handles,'Tag',tag_det_on);
        chk_s_det     = findobj(chk_handles,'Tag',tag_s_det);
        chk_ss_det    = findobj(chk_handles,'Tag',tag_ss_det);
        chk_cfs_on    = findobj(chk_handles,'Tag',tag_cfs_on);
        txt_ccfs      = findobj(win_dw1d_more,'Tag',tag_txt_ccfs);
        pop_ccfs      = findobj(win_dw1d_more,'Tag',tag_pop_ccfs);

        switch num_mode
            case {1,6}
                [flg_axe,flg_sa,~,flg_sd,~,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode,0);
                val_flg = [flg_axe(1) flg_sa flg_axe(2) flg_sd];
                vis_str = getonoff([1 flg_axe([1 1]) 1 flg_axe([2 2])]);
                val_cfs = flg_axe(3);

                if val_cfs==0
                  vis_txt_ccfs = 'off'; vis_pop_ccfs = 'off';
                else
                  vis_txt_ccfs = 'on';  vis_pop_ccfs = 'on';
                end


            case {2,5}

            case 3
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                            ind_lev_anal);

                [flg_axe,sa_flg,app_flg,sd_flg,det_flg,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode,0);
                l_s_flg = flg_axe(1);
                r_s_flg = flg_axe(2);   
                val_cfs = flg_axe(3);
                val_flg = [l_s_flg , sa_flg , r_s_flg , sd_flg];
                vis_str = getonoff([1 l_s_flg l_s_flg 1 r_s_flg r_s_flg ]);
                if val_cfs==0
                    vis_txt_ccfs = 'off'; vis_pop_ccfs = 'off';
                else
                    vis_txt_ccfs = 'on';  vis_pop_ccfs = 'on';
                end
                pus_app_all = findobj(pus_handles,'Tag',tag_app_all);
                pus_det_all = findobj(pus_handles,'Tag',tag_det_all);
                chk_app_lst = get(pus_app_all,'UserData');
                chk_det_lst = get(pus_det_all,'UserData');
                for k=1:Level_Anal , set(chk_app_lst(k),'Value',app_flg(k)); end
                for k=1:Level_Anal , set(chk_det_lst(k),'Value',det_flg(k)); end

            case 4
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                                ind_lev_anal);
                [flg_axe,flg_sa,flg_app,flg_sd,flg_det,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,num_mode,0);
                if flg_axe(3)== 0
                    vis_txt_ccfs = 'off';   vis_pop_ccfs = 'off';
                else
                    vis_txt_ccfs = 'on';    vis_pop_ccfs = 'on';
                end
                vis_str = getonoff([1 flg_axe([1 1]) 1 flg_axe([2 2])]);
                val_flg = [1 flg_sa 1 flg_sd flg_axe(3)];
                val_app = flg_app;
                val_det = flg_det;
                val_cfs = flg_axe(3);

                pus_app_all  = findobj(pus_handles,'Tag',tag_app_all);
                pus_app_none = findobj(pus_handles,'Tag',tag_app_none);
                pus_det_all  = findobj(pus_handles,'Tag',tag_det_all);
                pus_det_none = findobj(pus_handles,'Tag',tag_det_none);
                txt_handles  = findobj(win_dw1d_more,'Style','text');
                txt_app_txt  = findobj(txt_handles,'Tag',tag_app_txt);
                txt_det_txt  = findobj(txt_handles,'Tag',tag_det_txt);
                chk_app_lst  = get(pus_app_all,'UserData');
                chk_det_lst  = get(pus_det_all,'UserData');
                for k=1:Level_Anal , set(chk_app_lst(k),'Value',val_app(k)); end
                for k=1:Level_Anal , set(chk_det_lst(k),'Value',val_det(k)); end
                set([txt_app_txt; pus_app_all; pus_app_none; chk_app_lst],...
                                'Visible',vis_str{3});
                set([txt_det_txt; pus_det_all; pus_det_none; chk_det_lst],...
                                'Visible',vis_str{6});

        end
        if find(num_mode==[1 3 4 6])
            set(chk_app_on, 'Visible',vis_str{1},'Value',val_flg(1));
            set(chk_s_app,  'Visible',vis_str{2},'Value',val_flg(2));
            set(chk_ss_app, 'Visible',vis_str{3},'Value',val_flg(3));
            set(chk_det_on, 'Visible',vis_str{4},'Value',val_flg(4));
            set(chk_s_det,  'Visible',vis_str{5},'Value',val_flg(5));
            set(chk_ss_det, 'Visible',vis_str{6},'Value',val_flg(6));
            set(chk_cfs_on, 'Value',val_cfs);
            set(txt_ccfs,'Visible',vis_txt_ccfs);
            set(pop_ccfs,'Visible',vis_pop_ccfs,'Value',ccfs_m);
        end

        % Restore old view mode options
        %-------------------------------
        dw1ddisp('apply',win_dw1dtool,win_dw1d_more);

    case 'close'
        delete(in3);
        dw1dutil('Enable',win_dw1dtool,'end_more_disp');

        % End waiting.
        %---------------
        wwaiting('off',win_dw1dtool);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end


