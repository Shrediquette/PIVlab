function out1 = dw2dhist(option,in2,in3,in4,in5,in6,in7)
%DW2DHIST Discrete wavelet 2-D histograms.
%   OUT1 = DW2DHIST(OPTION,IN2,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.21.4.13 $


% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
% ind_img_t_name = 4;
ind_img_size   = 5;
% ind_nbcolors   = 6;
% ind_act_option = 7;
ind_simg_type  = 8;
% ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.1 & MB2.2
%--------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB3.
%-----
n_miscella      = 'DWAn2d_Miscella';
ind_graph_area  =  1;
% ind_pos_axebig  =  2;
% ind_pos_axeini  =  3;
% ind_pos_axevis  =  4;
% ind_pos_axedec  =  5;
% ind_pos_axesyn  =  6;
% ind_pos_axesel  =  7;
% ind_view_status =  8;
% ind_save_status =  9;
% ind_sel_funct   = 10;
% nb3_stored      = 10;

% Tag property of objects.
%-------------------------
% tag_cmd_frame   = 'Cmd_Frame';
tag_orig_sig    = 'Orig_sig';
tag_synt_sig    = 'Synt_sig';
tag_app_sig     = 'App_sig';
tag_det_sig     = 'Det_sig';
tag_app_txt     = 'App_Txt';
tag_app_all     = 'App_All';
tag_app_none    = 'App_None';
tag_det_txt     = 'Det_Txt';
tag_detdir_val  = 'Detdir_Val';
tag_det_all     = 'Det_All';
tag_det_none    = 'Det_None';
tag_bins_txt    = 'Bins_Txt';
tag_bins_data   = 'Bins_Data';
tag_show_hist   = 'Show_Hist';
tag_status_line = 'Status_Line';
tag_fra_sep     = 'Frame_Separ';

if ~isequal(option,'create') , win_dw2dhist = in2; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
         Pop_Min_Width,X_Spacing,Y_Spacing,           ...
         Def_EdiBkColor,fraBkColor] = mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Pop_Min_Width','X_Spacing','Y_Spacing',           ...
                'Def_EdiBkColor','Def_FraBkColor');

        % Calling figure.
        %----------------
        win_dw2dtool = in2;

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:dw2dRF:NamWinHIST_2D');
        [win_dw2dhist,pos_win,win_units,~,...
             pos_frame0,Pos_Graphic_Area,pus_close] = ...
                 wfigmngr('create',win_name,'','ExtFig_HistStat',mfilename,0); %#ok<ASGLU>
        out1 = win_dw2dhist;

        % Begin waiting.
        %---------------
        set(win_dw2dtool,'Pointer','watch');

        % Getting globals from dw2dtool figure memory block.
        %---------------------------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal] = ...
        wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                       ind_img_name, ...
                       ind_img_size, ...
                       ind_wav_name, ...
                       ind_lev_anal  ...
                       );

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        x_frame0  = pos_frame0(1);
        cmd_width = pos_frame0(3);
        push_width = (cmd_width-4*dx)/2;
        txt_width  = Def_Btn_Width;
        pop_width  = Pop_Min_Width;
        nb_inline   = 3;
        default_bins = 50;

        % Position property of objects.
        %------------------------------
        [chk_height,dy1_chk,dy_chk] = depOfMachine(Def_Btn_Height);
        deltay  = min(dy2,dy1_chk);
        xlocINI        = [x_frame0 cmd_width];
        ybottomINI     = pos_win(4)-3.5*Def_Btn_Height-dy2;

        y_low          = ybottomINI-2*Def_Btn_Height;
        wx             = 7*push_width/4;
        px             = x_frame0+(cmd_width-7*push_width/4)/2;
        pos_orig_sig   = [px , y_low  , wx , chk_height];
        y_low          = y_low-chk_height-dy1_chk;
        pos_synt_sig   = [px , y_low  , wx , chk_height];
        y_low          = y_low-chk_height-dy1_chk;
        pos_app_sig    = [px , y_low  , wx , chk_height];
        y_low          = y_low-chk_height-dy1_chk;
        pos_det_sig    = [px , y_low  , wx , chk_height];

        wx             = 3*push_width/2;
        px             = x_frame0+(cmd_width-wx)/2;
        y_low          = y_low-3*Def_Btn_Height/2;
        pos_app_txt    = [px, y_low, wx, Def_Btn_Height];
        nb             = nb_inline+1;
        x_left         = x_frame0+(cmd_width-nb*txt_width/2)/(nb+1);
        y_low          = y_low-Def_Btn_Height-deltay;
        pos_app_all    = [x_left, y_low, txt_width/2, Def_Btn_Height];
        y_low          = y_low-3*Def_Btn_Height/2;
        pos_app_none   = [x_left, y_low, txt_width/2, Def_Btn_Height];

        y_low          = pos_app_txt(2)-4*Def_Btn_Height;
        pos_det_txt    = [px, y_low, wx, Def_Btn_Height];
        y_low          = pos_det_txt(2)-4*Def_Btn_Height;
        pos_detdir_val = [px, y_low, wx, Def_Btn_Height];

        y_low          = pos_detdir_val(2)-3*Def_Btn_Height/2;
        pos_det_all    = [x_left, y_low, txt_width/2, Def_Btn_Height];
        y_low          = y_low-3*Def_Btn_Height/2;
        pos_det_none   = [x_left, y_low, txt_width/2, Def_Btn_Height];

        px             = x_frame0+(cmd_width-3*pop_width)/2;
        y_low          = pos_det_txt(2)-4*Def_Btn_Height;
        pos_bins_txt   = [px, y_low+d_txt/2, 2*pop_width, Def_Txt_Height];
        px             = pos_bins_txt(1)+pos_bins_txt(3)+dx;
        pos_bins_data  = [px, y_low, pop_width, Def_Btn_Height];
        px             = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low          = y_low-3*Def_Btn_Height;
        pos_show_hist  = [px, y_low, 3*push_width/2, 2*Def_Btn_Height];

        % String property of objects.
        %----------------------------
        s_i = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_simg_type);
        switch s_i
            case 'ss', str_ss = getWavMSG('Wavelet:dw2dRF:Syn_Img');
            case 'ds', str_ss = getWavMSG('Wavelet:dw2dRF:Den_Img');
            case 'cs', str_ss = getWavMSG('Wavelet:dw2dRF:Cmp_Img');
        end
        str_synt_sig    = str_ss;
        str_orig_sig    = getWavMSG('Wavelet:dw2dRF:Ori_Img');
        str_app_sig     = getWavMSG('Wavelet:dw2dRF:Str_app_sig');
        str_det_sig     = getWavMSG('Wavelet:dw2dRF:Str_Detail');
        str_app_txt     = getWavMSG('Wavelet:dw2dRF:App_Levels');
        str_appdet_all  = getWavMSG('Wavelet:commongui:Str_All');
        str_appdet_none = getWavMSG('Wavelet:commongui:Str_None');
        str_det_txt     = getWavMSG('Wavelet:dw2dRF:Det_Levels');
        str_detdir_val = {...
            getWavMSG('Wavelet:dw2dRF:Str_Hor'); ...
            getWavMSG('Wavelet:dw2dRF:Str_Ver'); ...
            getWavMSG('Wavelet:dw2dRF:Str_Dia')  ...
            };
        str_bins_txt    = getWavMSG('Wavelet:dw2dRF:Str_bins_txt');
        str_bins_data   = sprintf('%.0f',default_bins);
        str_show_hist   = getWavMSG('Wavelet:dw2dRF:Str_show_hist');

        % Command part construction of the window.
        %-----------------------------------------
        utanapar('create_copy',win_dw2dhist, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                 );

        chk_orig_sig = uicontrol('Parent',win_dw2dhist,...
                                 'Style','Checkbox',...
                                 'Units',win_units,...
                                 'Position',pos_orig_sig,...
                                 'String',str_orig_sig,...
                                 'Enable','off',...
                                 'UserData',0,...
                                 'Tag',tag_orig_sig...
                                 );
        chk_synt_sig = uicontrol('Parent',win_dw2dhist,...
                                 'Style','Checkbox',...
                                 'Units',win_units,...
                                 'Position',pos_synt_sig,...
                                 'String',str_synt_sig,...
                                 'Enable','off',...
                                 'UserData',0,...
                                 'Tag',tag_synt_sig...
                                 );
        chk_app_sig  = uicontrol('Parent',win_dw2dhist,...
                                 'Style','Checkbox',...
                                 'Units',win_units,...
                                 'Position',pos_app_sig,...
                                 'String',str_app_sig,...
                                 'Enable','off',...
                                 'UserData',0,...
                                 'Tag',tag_app_sig...
                                 );
        chk_det_sig  = uicontrol('Parent',win_dw2dhist,...
                                 'Style','Checkbox',...
                                 'Units',win_units,...
                                 'Position',pos_det_sig,...
                                 'String',str_det_sig,...
                                 'Enable','off',...
                                 'UserData',0,...
                                 'Tag',tag_det_sig...
                                 );

        % Approximations checkboxes construction.

        txt_app_txt  = uicontrol('Parent',win_dw2dhist,...
                                 'Style','Text',...
                                 'Units',win_units,...
                                 'Position',pos_app_txt,...
                                 'String',str_app_txt,...
                                 'BackgroundColor',fraBkColor,...
                                 'Visible','off',...
                                 'Tag',tag_app_txt...
                                 );
        pus_app_all  = uicontrol('Parent',win_dw2dhist,...
                                 'Style','PushButton',...
                                 'Units',win_units,...
                                 'Position',pos_app_all,...
                                 'String',str_appdet_all,...
                                 'Visible','off',...
                                 'Tag',tag_app_all...
                                 );
        pus_app_none = uicontrol('Parent',win_dw2dhist,...
                                 'Style','PushButton',...
                                 'Units',win_units,...
                                 'Position',pos_app_none,...
                                 'String',str_appdet_none,...
                                 'Visible','off',...
                                 'Tag',tag_app_none...
                                 );

        wx          = (cmd_width-nb*txt_width/2)/(nb+1);
        xbtchk0     = x_frame0+txt_width/2+2*wx;
        ybtchk0     = pos_app_txt(2)-Def_Btn_Height-deltay;
        xbtchk      = xbtchk0;
        ybtchk      = ybtchk0;
        Chk_App_Lst = zeros(Lev_Anal,1);
        for i=1:Lev_Anal
            pos_app_i = [xbtchk ybtchk txt_width/2 Def_Btn_Height];
            str_app_i = sprintf('%.0f',i);
            tag_app_i = ['App' sprintf('%.0f',i)];
            chk_app_i = uicontrol('Parent',win_dw2dhist,...
                                  'Style','Checkbox',...
                                  'Units',win_units,...
                                  'Position',pos_app_i,...
                                  'String',str_app_i,...
                                  'Visible','off',...
                                  'Tag',tag_app_i...
                                  );
            Chk_App_Lst(i) = chk_app_i;
            if rem(i,nb_inline)==0
                xbtchk = xbtchk0;
                ybtchk = ybtchk-Def_Btn_Height-dy_chk;
            else
                xbtchk = xbtchk+txt_width/2+wx;
            end
        end

        % Details checkboxes construction.

        txt_det_txt    = uicontrol('Parent',win_dw2dhist,...
                                   'Style','Text',...
                                   'Units',win_units,...
                                   'Position',pos_det_txt,...
                                   'String',str_det_txt,...
                                   'BackgroundColor',fraBkColor,...
                                   'Visible','off',...
                                   'Tag',tag_det_txt...
                                   );
        pop_detdir_val = uicontrol('Parent',win_dw2dhist,...
                                   'Style','Popup',...
                                   'Units',win_units,...
                                   'Position',pos_detdir_val,...
                                   'String',str_detdir_val,...
                                   'Visible','off',...
                                   'Tag',tag_detdir_val...
                                   );
        pus_det_all    = uicontrol('Parent',win_dw2dhist,...
                                   'Style','PushButton',...
                                   'Units',win_units,...
                                   'Position',pos_det_all,...
                                   'String',str_appdet_all,...
                                   'Visible','off',...
                                   'Tag',tag_det_all...
                                   );
        pus_det_none   = uicontrol('Parent',win_dw2dhist,...
                                   'Style','PushButton',...
                                   'Units',win_units,...
                                   'Position',pos_det_none,...
                                   'String',str_appdet_none,...
                                   'Visible','off',...
                                   'Tag',tag_det_none...
                                   );
        ybtchk0     = pos_det_txt(2)-Def_Btn_Height-dy_chk;
        xbtchk      = xbtchk0;
        ybtchk      = ybtchk0;
        Chk_Det_Lst = zeros(Lev_Anal,1);
        for i=1:Lev_Anal
            pos_det_i = [xbtchk ybtchk txt_width/2 Def_Btn_Height];
            str_det_i = sprintf('%.0f',i);
            tag_det_i = ['Det' sprintf('%.0f',i)];
            chk_det_i = uicontrol('Parent',win_dw2dhist,...
                                  'Style','Checkbox',...
                                  'Units',win_units,...
                                  'Position',pos_det_i,...
                                  'String',str_det_i,...
                                  'Visible','off',...
                                  'Tag',tag_det_i...
                                  );
            Chk_Det_Lst(i) = chk_det_i;
            if rem(i,nb_inline)==0
                xbtchk = xbtchk0;
                ybtchk = ybtchk-Def_Btn_Height-dy_chk;
            else
                xbtchk = xbtchk+txt_width/2+wx;
            end
        end

        txt_bins_txt  = uicontrol('Parent',win_dw2dhist,...
                                  'Style','Text',...
                                  'Units',win_units,...
                                  'Position',pos_bins_txt,...
                                  'String',str_bins_txt,...
                                  'BackgroundColor',fraBkColor,...
                                  'Visible','off',...
                                  'Tag',tag_bins_txt...
                                  );
        edi_bins_data = uicontrol('Parent',win_dw2dhist,...
                                  'Style','Edit',...
                                  'Units',win_units,...
                                  'Position',pos_bins_data,...
                                  'String',str_bins_data,...
                                  'BackgroundColor',Def_EdiBkColor,...
                                  'Visible','off',...
                                  'Tag',tag_bins_data...
                                  );
        pus_show_hist = uicontrol('Parent',win_dw2dhist,...
                                  'Style','pushbutton',...
                                  'Units',win_units,...
                                  'Position',pos_show_hist,...
                                  'String',str_show_hist,...
                                  'Interruptible','On',...
                                  'Visible','off',...
                                  'UserData',[],...
                                  'Tag',tag_show_hist...
                                  );
        drawnow

        % Selected box limits.
        %---------------------
        Axe_Ref = findobj(get(win_dw2dtool,'Children'),'flat', ...
                           'Type','axes','Tag','Axe_ImgIni');
        [xlim_selbox, ylim_selbox]= mngmbtn('getbox',win_dw2dtool); 
        if ~isempty(xlim_selbox)
            xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
        else
            xlim_selbox = get(Axe_Ref,'XLim');
        end
        if ~isempty(ylim_selbox)
            ylim_selbox = [min(ylim_selbox) max(ylim_selbox)];
        else
            ylim_selbox = get(Axe_Ref,'YLim');
        end
        xlim_selbox = round(xlim_selbox);
        ylim_selbox = round(ylim_selbox);
        xlim1       = xlim_selbox(1);
        xlim2       = xlim_selbox(2);
        ylim1       = ylim_selbox(1);
        ylim2       = ylim_selbox(2);
        if  xlim1<1,                xlim1 = 1;           end
        if  xlim2>Img_Size(1),      xlim2 = Img_Size(1); end
        if  (xlim2<1) || (xlim1>Img_Size(1)), return,     end
        if  ylim1<1,                ylim1 = 1;           end
        if  ylim2>Img_Size(2),      ylim2 = Img_Size(2); end
        if  (ylim2<1) || (ylim1>Img_Size(2)), return,     end
        selbox = [xlim1 xlim2 ylim1 ylim2];

        % Sets of handles.
        %-----------------
        set1_hdls = [txt_app_txt
                     pus_app_all
                     pus_app_none
                     Chk_App_Lst];
        set2_hdls = [txt_det_txt
                     pop_detdir_val
                     pus_det_all
                     pus_det_none
                     Chk_Det_Lst];
        set3_hdls = [txt_bins_txt
                     edi_bins_data
                     pus_show_hist
                     pus_close];

        % Callbacks update.
        %------------------
        group_hdls    = [set1_hdls;set2_hdls;set3_hdls];

        tmp_obj           = {set1_hdls , ...
                             set2_hdls , ...
                             set3_hdls , ...
                             group_hdls};

        cba_orig_sig  = @(~,~)dw2dhist('select', ...
                              win_dw2dhist , ...
                              chk_orig_sig , ...
                              tmp_obj{:} ...
                              );
        cba_synt_sig  = @(~,~)dw2dhist('select', ...
                              win_dw2dhist , ...
                              chk_synt_sig , ...
                              tmp_obj{:} ...
                              );
        cba_app_sig   = @(~,~)dw2dhist('select', ...
                              win_dw2dhist , ...
                              chk_app_sig , ...
                              tmp_obj{:} ...
                              );
        cba_det_sig   = @(~,~)dw2dhist('select', ...
                              win_dw2dhist , ...
                              chk_det_sig , ...
                              tmp_obj{:} ...
                              );
        cba_bins_data = @(~,~)dw2dhist('update_bins', ...
                              win_dw2dhist , ...
                              edi_bins_data ...
                              );
        cba_app_all   = @(~,~)set(Chk_App_Lst ,'Value',1);
        cba_app_none  = @(~,~)set(Chk_App_Lst ,'Value',0);
        cba_det_all   = @(~,~)set(Chk_Det_Lst ,'Value',1);
        cba_det_none  = @(~,~)set(Chk_Det_Lst ,'Value',0);
        cba_show_hist = @(~,~)dw2dhist('draw', ...
                              win_dw2dhist , ...
                              win_dw2dtool , ...
                              selbox , ...
                              Chk_App_Lst , ...
                              Chk_Det_Lst );

        set(chk_orig_sig,'Callback',cba_orig_sig);
        set(chk_synt_sig,'Callback',cba_synt_sig);
        set(chk_app_sig,'Callback',cba_app_sig);
        set(chk_det_sig,'Callback',cba_det_sig);
        set(pus_app_all,'Callback',cba_app_all);
        set(pus_app_none,'Callback',cba_app_none);
        set(pus_det_all,'Callback',cba_det_all);
        set(pus_det_none,'Callback',cba_det_none);
        set(edi_bins_data,'Callback',cba_bins_data);
        set(pus_show_hist,'Callback',cba_show_hist);

        % Displaying the window title.
        %-----------------------------
        str_wintitle = getWavMSG('Wavelet:dw2dRF:Str_WinTITLE',...
            Img_Name,Img_Size(1),Img_Size(2),Lev_Anal,Wav_Name,...
            selbox(1),selbox(2),selbox(3),selbox(4));
        wfigtitl('String',win_dw2dhist,str_wintitle,'off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_dw2dhist);

		% Initialization with signal histogram (31/08/2000).
		%---------------------------------------------------
		set(chk_orig_sig,'Value',1);
		group_hdls = [set1_hdls;set2_hdls;set3_hdls;];
		dw2dhist('select',win_dw2dhist,chk_orig_sig,...
			     set1_hdls,set2_hdls,set3_hdls,group_hdls);		
		dw2dhist('draw',win_dw2dhist,win_dw2dtool,selbox,Chk_App_Lst,Chk_Det_Lst);

        % End waiting.
        %-------------
        set(win_dw2dtool,'Pointer','arrow');
        set(win_dw2dhist,'Visible','On');
        set([chk_orig_sig chk_synt_sig chk_app_sig chk_det_sig],'Enable','on');        

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_chk_btn = in3;
        set1_hdls   = in4;
        set2_hdls   = in5;
        set3_hdls   = in6;
        group_hdls  = in7;
        group_hdls  = group_hdls(1:end-1);

        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing');

        % Handles of tagged objects.
        %---------------------------
        child        = get(win_dw2dhist,'Children');
        axe_handles  = findobj(child,'flat','Type','axes');
        uic_handles  = findobj(child,'flat','Type','uicontrol');
        chk_handles  = findobj(uic_handles,'flat','Style','checkbox');
        txt_handles  = findobj(uic_handles,'flat','Style','text');
        fra_handles  = findobj(uic_handles,'flat','Style','frame');
        chk_orig_sig = findobj(chk_handles,'Tag',tag_orig_sig);
        chk_synt_sig = findobj(chk_handles,'Tag',tag_synt_sig);
        chk_app_sig  = findobj(chk_handles,'Tag',tag_app_sig);
        chk_det_sig  = findobj(chk_handles,'Tag',tag_det_sig);
        hdl1         = findobj(fra_handles,'Tag',tag_fra_sep);
        hdl2         = findobj(txt_handles,'Tag',tag_status_line);
        hdl3         = axe_handles;

        % Cleaning the graphical part.
        %-----------------------------
        delete([hdl1; hdl2; hdl3]);

        % Get the current selection.
        %---------------------------
        orig_sig = (get(chk_orig_sig,'UserData')~=0);
        synt_sig = (get(chk_synt_sig,'UserData')~=0);
        app_sig  = (get(chk_app_sig,'UserData')~=0);
        det_sig  = (get(chk_det_sig,'UserData')~=0);

        % Get to the current positions.
        %------------------------------
        pos_det_sig    = get(chk_det_sig,'Position');
        pos_app_txt    = get(set1_hdls(1),'Position');
        pos_app_all    = get(set1_hdls(2),'Position');
        pos_app_none   = get(set1_hdls(3),'Position');
        pos_det_txt    = get(set2_hdls(1),'Position');
        pos_detdir_val = get(set2_hdls(2),'Position');
        pos_det_all    = get(set2_hdls(3),'Position');
        pos_det_none   = get(set2_hdls(4),'Position');
        pos_bins_txt   = get(set3_hdls(1),'Position');
        pos_bins_data  = get(set3_hdls(2),'Position');
        pos_show_hist  = get(set3_hdls(3),'Position');
        pos_close      = get(set3_hdls(4),'Position');

        % Redefine height of buttons depending on levels.
        %------------------------------------------------
        levels      = length(set1_hdls)-3;
        nb_inline   = 3;
        hbtn1       = pos_bins_data(4);
        [nul,ypixl] = wfigutil('prop_size',win_dw2dhist,0,1); %#ok<ASGLU>
        deltay      = min(2*Y_Spacing,0.25*Def_Btn_Height)*ypixl;
        nbHsep      = 1.5;
        nbHsepB     = 2;

        % Redraw the command part depending on the current selection.
        %------------------------------------------------------------
        if sel_chk_btn==chk_orig_sig
            if orig_sig
                set(chk_orig_sig,'Value',0,'UserData',0)
                if ~(synt_sig || app_sig || det_sig) 
                    set(group_hdls,'Visible','off');
                end
            else
                set(chk_orig_sig,'Value',1,'UserData',1)
                if ~(synt_sig || app_sig || det_sig)
                    pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set(set3_hdls,'Visible','on');
                end
            end

        elseif sel_chk_btn==chk_synt_sig
            if synt_sig
                set(chk_synt_sig,'Value',0,'UserData',0)
                if ~(orig_sig || app_sig || det_sig) 
                    set(group_hdls,'Visible','off');
                end
            else
                set(chk_synt_sig,'Value',1,'UserData',1)
                if ~(orig_sig || app_sig || det_sig)
                    pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set(set3_hdls,'Visible','on');
                end
            end

        elseif sel_chk_btn==chk_app_sig            
            set(group_hdls,'Visible','off');
            if app_sig
                set(chk_app_sig,'Value',0,'UserData',0)
                if (orig_sig || synt_sig) && ~det_sig
                    pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set(set3_hdls,'Visible','on');

                elseif det_sig
                    pos_det_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_detdir_val(2) = pos_det_txt(2)-3*hbtn1/2;
                    pos_det_all(2)  = pos_detdir_val(2)-3*hbtn1/2;
                    pos_det_none(2) = pos_det_all(2)-3*hbtn1/2;
                    set(set2_hdls(1),'Position',pos_det_txt);
                    set(set2_hdls(2),'Position',pos_detdir_val);
                    set(set2_hdls(3),'Position',pos_det_all);
                    set(set2_hdls(4),'Position',pos_det_none);
                    pos_chk_det     = zeros(levels,4);
                    for i=1:levels
                        j=i+4;
                        k = ceil(i/nb_inline);
                        pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                        pos_chk_det(j,2) = pos_detdir_val(2)-k*(3*hbtn1/2);
                        set(set2_hdls(j),'Position',pos_chk_det(j,:));
                    end
                    pos_last_chk = get(set2_hdls(end),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;  
                    pos_bins_data(2)= pos_bins_txt(2);
                    yl              = pos_close(2)+pos_close(4);
                    dy              = pos_bins_data(2)-yl-pos_show_hist(4);
                    pos_show_hist(2)= yl+dy/2;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set2_hdls;set3_hdls],'Visible','on');
                end
            else
                set(chk_app_sig,'Value',1,'UserData',1)
                if det_sig
                    pos_app_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_app_all(2)  = pos_app_txt(2)-hbtn1-deltay;
                    pos_app_none(2) = pos_app_all(2)-3*hbtn1/2;
                    set(set1_hdls(1),'Position',pos_app_txt);
                    set(set1_hdls(2),'Position',pos_app_all);
                    set(set1_hdls(3),'Position',pos_app_none);
                    pos_last_chk = get(set1_hdls(end),'Position');
                    pos_det_txt(2) = pos_last_chk(2)-max([nbHsepB,3])*hbtn1;  
                    pos_detdir_val(2)= pos_det_txt(2)-hbtn1-deltay;
                    pos_det_all(2)  = pos_detdir_val(2)-3*hbtn1/2;
                    pos_det_none(2) = pos_det_all(2)-3*hbtn1/2;
                    set(set2_hdls(1),'Position',pos_det_txt);
                    set(set2_hdls(2),'Position',pos_detdir_val);
                    set(set2_hdls(3),'Position',pos_det_all);
                    set(set2_hdls(4),'Position',pos_det_none);
                    pos_chk_det     = zeros(levels,4);
                    for i=1:levels
                        j=i+4;
                        k = ceil(i/nb_inline);
                        pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                        pos_chk_det(j,2) = pos_detdir_val(2)-k*1.5*hbtn1;
                        set(set2_hdls(j),'Position',pos_chk_det(j,:));
                    end
                    pos_last_chk = get(set2_hdls(end),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;  
                    pos_bins_data(2)= pos_bins_txt(2);
                    yl              = pos_close(2)+pos_close(4);
                    dy              = pos_bins_data(2)-yl-pos_show_hist(4);
                    pos_show_hist(2)= yl+dy/2;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set1_hdls;set2_hdls;set3_hdls],'Visible','on');
                else
                    pos_app_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_app_all(2)  = pos_app_txt(2)-hbtn1-deltay;
                    pos_app_none(2) = pos_app_all(2)-3*hbtn1/2;
                    set(set1_hdls(1),'Position',pos_app_txt);
                    set(set1_hdls(2),'Position',pos_app_all);
                    set(set1_hdls(3),'Position',pos_app_none);
                    pos_last_chk    = get(set1_hdls(end),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;  
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set1_hdls;set3_hdls],'Visible','on');
                end
            end

        elseif  sel_chk_btn==chk_det_sig
            set(group_hdls,'Visible','off');
            if det_sig
                set(chk_det_sig,'Value',0,'UserData',0)
                if (orig_sig || synt_sig) && ~app_sig
                    pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set(set3_hdls,'Visible','on');
                elseif app_sig
                    pos_app_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_app_all(2)  = pos_app_txt(2)-hbtn1-deltay;
                    pos_app_none(2) = pos_app_all(2)-3*hbtn1/2;
                    set(set1_hdls(1),'Position',pos_app_txt);
                    set(set1_hdls(2),'Position',pos_app_all);
                    set(set1_hdls(3),'Position',pos_app_none);
                    pos_last_chk    = get(set1_hdls(end),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;  
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set1_hdls;set3_hdls],'Visible','on');
                end
            else
                set(chk_det_sig,'Value',1,'UserData',1)
                if app_sig
                    pos_app_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_app_all(2)  = pos_app_txt(2)-hbtn1-deltay;
                    pos_app_none(2) = pos_app_all(2)-3*hbtn1/2;
                    set(set1_hdls(1),'Position',pos_app_txt);
                    set(set1_hdls(2),'Position',pos_app_all);
                    set(set1_hdls(3),'Position',pos_app_none);
                    pos_last_chk = get(set1_hdls(end),'Position');
                    %%% pos_det_txt(2) = pos_last_chk(2)-nbHsepB*hbtn1;      
                    pos_det_txt(2) = pos_last_chk(2)-max([nbHsepB,3])*hbtn1;     
                    pos_detdir_val(2)= pos_det_txt(2)-hbtn1-deltay;
                    pos_det_all(2)  = pos_detdir_val(2)-3*hbtn1/2;
                    pos_det_none(2) = pos_det_all(2)-3*hbtn1/2;
                    set(set2_hdls(1),'Position',pos_det_txt);
                    set(set2_hdls(2),'Position',pos_detdir_val);
                    set(set2_hdls(3),'Position',pos_det_all);
                    set(set2_hdls(4),'Position',pos_det_none);
                    pos_chk_det     = zeros(levels,4);
                    for i=1:levels
                        j=i+4;
                        k=ceil(i/nb_inline);
                        pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                        pos_chk_det(j,2) = pos_detdir_val(2)-k*(3*hbtn1/2);
                        set(set2_hdls(j),'Position',pos_chk_det(j,:));
                    end
                    pos_last_chk    = get(set2_hdls(j),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;                    
                    pos_bins_data(2)= pos_bins_txt(2);
                    yl              = pos_close(2)+pos_close(4);
                    dy              = pos_bins_data(2)-yl-pos_show_hist(4);
                    pos_show_hist(2)= yl+dy/2;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set1_hdls;set2_hdls;set3_hdls],'Visible','on');
                else
                    pos_det_txt(2)  = pos_det_sig(2)-3*hbtn1/2;
                    pos_detdir_val(2) = pos_det_txt(2)-hbtn1-deltay;
                    pos_det_all(2)  = pos_detdir_val(2)-3*hbtn1/2;
                    pos_det_none(2) = pos_det_all(2)-3*hbtn1/2;
                    set(set2_hdls(1),'Position',pos_det_txt);
                    set(set2_hdls(2),'Position',pos_detdir_val);
                    set(set2_hdls(3),'Position',pos_det_all);
                    set(set2_hdls(4),'Position',pos_det_none);
                    pos_chk_det     = zeros(levels,4);
                    for i=1:levels
                        j=i+4;
                        k=ceil(i/nb_inline);
                        pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                        pos_chk_det(j,2) = pos_detdir_val(2)-k*(3*hbtn1/2);
                        set(set2_hdls(j),'Position',pos_chk_det(j,:));
                    end
                    pos_last_chk    = get(set2_hdls(j),'Position');
                    pos_bins_txt(2) = pos_last_chk(2)-max([nbHsep,3])*hbtn1;
                    pos_bins_data(2)= pos_bins_txt(2);
                    pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                    set(set3_hdls(1),'Position',pos_bins_txt);
                    set(set3_hdls(2),'Position',pos_bins_data);
                    set(set3_hdls(3),'Position',pos_show_hist);
                    set([set2_hdls;set3_hdls],'Visible','on');
                end
            end
        end

    case 'draw'
        %*********************************%
        %** OPTION = 'draw' - DRAW AXES **%
        %*********************************%
        win_dw2dtool = in3;
        selbox       = in4;
        Chk_App_Lst  = in5;
        Chk_Det_Lst  = in6;

        % Get Globals.
        %-------------
        [Def_Btn_Height,ediInActBkColor,fraBkColor] = mextglob('get',...
            'Def_Btn_Height','Def_Edi_InActBkColor','Def_FraBkColor');

        % Handles of tagged objects.
        %---------------------------
        child          = get(win_dw2dhist,'Children');
        uic_handles    = findobj(child,'flat','Type','uicontrol');
        chk_handles    = findobj(uic_handles,'Style','checkbox');
        pop_handles    = findobj(uic_handles,'Style','popupmenu');
        pus_handles    = findobj(uic_handles,'Style','pushbutton');
        edi_handles    = findobj(uic_handles,'Style','edit');
        pus_show_hist  = findobj(pus_handles,'Tag',tag_show_hist);
        chk_orig_sig   = findobj(chk_handles,'Tag',tag_orig_sig);
        chk_synt_sig   = findobj(chk_handles,'Tag',tag_synt_sig);
        chk_app_sig    = findobj(chk_handles,'Tag',tag_app_sig);
        chk_det_sig    = findobj(chk_handles,'Tag',tag_det_sig);
        pop_detdir_val = findobj(pop_handles,'Tag',tag_detdir_val);
        edi_bins_data  = findobj(edi_handles,'Tag',tag_bins_data);

        % Handles of tagged objects continuing.
        %-------------------------------------
        txt_handles = findobj(uic_handles,'Style','text');
        fra_handles = findobj(uic_handles,'Style','frame');
        axe_handles = findobj(child,'flat','Type','axes');
        hdl1        = findobj(fra_handles,'Tag',tag_fra_sep);
        hdl2        = findobj(txt_handles,'Tag',tag_status_line);
        hdl3        = axe_handles;

        % Check the bins number.
        %-----------------------
        default_bins    = 50;
        old_params      = get(pus_show_hist,'UserData');
        if ~isempty(old_params) , default_bins = old_params(1); end
        nb_bins = str2double(get(edi_bins_data,'String'));
        if isempty(nb_bins) || nb_bins<2
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end

        % Main parameters selection before drawing.
        %------------------------------------------
        orig_sig = (get(chk_orig_sig,'Value')~=0);
        synt_sig = (get(chk_synt_sig,'Value')~=0);
        app_sig  = (get(chk_app_sig,'Value')~=0);
        det_sig  = (get(chk_det_sig,'Value')~=0);

        % Getting memory blocks.
        %-----------------------
        [Wav_Name,Lev_Anal] =  wmemtool('rmb',win_dw2dtool,n_param_anal, ...
            ind_wav_name, ...
            ind_lev_anal  ...
            );

        % Actives apps and dets lists construction.
        %------------------------------------------
        if app_sig
            tmp = get(Chk_App_Lst(1:Lev_Anal),'Value');
            if ~iscell(tmp) , tmp = {tmp}; end
            app_lst = find(cat(2,tmp{:})~=0);
        else
            app_lst = [];
        end
        if det_sig
            tmp = get(Chk_Det_Lst(1:Lev_Anal),'Value');
            if ~iscell(tmp) , tmp = {tmp}; end
            det_lst = find(cat(2,tmp{:})~=0);
        else
            det_lst = [];
        end
        
        % Direction value for details.
        %-----------------------------
        direction = get(pop_detdir_val,'Value');
        switch direction
            case 1 , direct = 'horizontal ';
            case 2 , direct = 'vertical ';
            case 3 , direct = 'diagonal ';
        end
        
        new_params = [nb_bins orig_sig synt_sig app_sig ...
                      det_sig direction app_lst det_lst  ...
                      ];
        if ~isempty(axe_handles) && isequal(new_params,old_params)
            return;
        end

        % Deseable new selection.
        %-------------------------
        set([chk_handles;pop_handles;pus_handles;edi_bins_data],'Enable','off');

        % Updating parameters.
        %--------------------- 
        set(pus_show_hist,'UserData',new_params);

        % Show the status line.
        %----------------------
        wfigtitl('vis',win_dw2dhist,'on');

        % Waiting message.
        %-----------------
        wwaiting('msg',win_dw2dhist,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Cleaning the graphical part.
        %-----------------------------
        delete([hdl1; hdl2; hdl3]);
        drawnow;

        % Getting memory blocks.
        %-----------------------
        coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
        sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

        % Sort and get length of apps. and dets. lists.
        %----------------------------------------------
        app_lst     = sort(app_lst);
        app_lst_len = length(app_lst);
        det_lst     = sort(det_lst);
        det_lst_len = length(det_lst);

        % General graphical parameters initialization.
        %--------------------------------------------
        win_units       = get(win_dw2dtool,'Units');
        if ~strcmp(win_units,'pixels')
        [nul,btn_height] = ...
            wfigutil('prop_size',win_dw2dhist,1,Def_Btn_Height); %#ok<ASGLU>
        end
        pos_win      = get(win_dw2dtool,'Position');
        bdx          = 0.1*pos_win(3);
        bdy          = 0.05*pos_win(4);
        ecy          = 0.03*pos_win(4);
        pos_graph    = wmemtool('rmb',win_dw2dtool,n_miscella,...
                                     ind_graph_area);
        w_graph      = pos_graph(3);
        pos_graph(2) = pos_graph(2)-btn_height;
        fontsize     = wmachdep('FontSize','normal',9,app_lst_len);

        % Axes construction.
        %-------------------
        n_axeleft  = app_lst_len;
        n_axeright = det_lst_len;
        if orig_sig, n_axeleft = n_axeleft+1; end
        if synt_sig, n_axeleft = n_axeleft+1; end
        if n_axeleft*n_axeright~=0
            w_left  = (w_graph-3*bdx)/2;
            x_left  = pos_graph(1)+bdx;
            w_right = w_left;
            x_right = x_left+w_left+bdx+bdx/5;
            w_fra   = 0.01*pos_win(3);
            x_fra   = pos_graph(1)+(w_graph-w_fra)/2;
            y_fra   = btn_height;
            h_fra   = 1-2*btn_height;
        elseif n_axeleft~=0
            w_left  = w_graph-2*bdx;
            x_left  = pos_graph(1)+bdx;
        elseif n_axeright~=0
            w_right = w_graph-2*bdx;
            x_right = pos_graph(1)+bdx;
        end

        if ~isequal(get(0,'CurrentFigure'),win_dw2dhist)
            figure(win_dw2dhist);
        end

        % Building axes on the left part.
        %--------------------------------
        if n_axeleft~=0
            h_left = (pos_graph(4)-2*bdy-(n_axeleft-1)*ecy)/n_axeleft;
            y_left = pos_graph(2)+bdy;
            axe_left = zeros(1,n_axeleft);
            pos_left = [x_left y_left w_left h_left];
            for k = 1:n_axeleft
                axe_left(k) = axes(...
                                'Parent',win_dw2dhist,...
                                'Units',win_units,...
                                'Position',pos_left,...
                                'Box','On'...
                                );
                pos_left(2) = pos_left(2)+pos_left(4)+ecy;
            end
        end

        % Building axes on the right part.
        %---------------------------------
        if n_axeright~=0
            h_right = (pos_graph(4)-2*bdy-(n_axeright-1)*ecy)/n_axeright;
            y_right = pos_graph(2)+bdy;
            axe_right = zeros(1,n_axeright);
            pos_right = [x_right y_right w_right h_right];
            for k = 1:n_axeright
                axe_right(k) = axes(...
                                'Parent',win_dw2dhist,...
                                'Position',pos_right,...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Box','On'...
                                );
                pos_right(2) = pos_right(2)+pos_right(4)+ecy;
            end
        end

        ind_left  = n_axeleft;
        ind_right = n_axeright;

        % Displaying the image histogram.
        %---------------------------------
        if orig_sig
            curr_img = get(dw2drwcd('r_orig',win_dw2dtool),'CData');
            curr_img = curr_img(selbox(3):selbox(4),selbox(1):selbox(2));
            curr_img = curr_img(:);
            curr_color = wtbutils('colors','sig');
            axeCur = axe_left(ind_left);
            his      = wgethist(curr_img,nb_bins);
            his(2,:) = his(2,:)/length(curr_img);
            wplothis(axeCur,his,curr_color);
            set(axeCur,'Tag','s','UserData',curr_img);
            h = txtinaxe('create','s',axeCur,'left','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_left = ind_left-1;
        end

        % Displaying the synthesized image histogram.
        %---------------------------------------------
        if synt_sig
            curr_img = get(dw2drwcd('r_synt',win_dw2dtool),'CData');
            curr_img = curr_img(selbox(3):selbox(4),selbox(1):selbox(2));
            curr_img = curr_img(:);
            curr_color = wtbutils('colors','ssig');
            axeCur = axe_left(ind_left);
            his      = wgethist(curr_img,nb_bins);
            his(2,:) = his(2,:)/length(curr_img);
            wplothis(axeCur,his,curr_color);
            set(axeCur,'Tag','ss');
            set(axeCur,'UserData',curr_img);
            s_i = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_simg_type);
            if strcmp(s_i,'ss') ||strcmp(s_i,'ds') || strcmp(s_i,'cs')
                str_ss = s_i;
            end
            h = txtinaxe('create',str_ss,axeCur,'left','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_left = ind_left-1;
        end

        % Displaying the approximations histograms.
        %------------------------------------------
        col_app = wtbutils('colors','app',Lev_Anal);
        for k = app_lst_len:-1:1
            level       = app_lst(k);
            ind_coef    = 1;
            curr_img    = appcoef2(coefs,sizes,Wav_Name,level);
            curr_selbox = ceil(selbox./2^level);
            if curr_selbox(2)-curr_selbox(1)<2 || ...
                    curr_selbox(4)-curr_selbox(3)<2
                wwarndlg(getWavMSG('Wavelet:dw2dRF:Not_Enough',level), ...
                    getWavMSG('Wavelet:dw2dRF:NamWinHIST_2D'),'block');
                ind_coef = 0;
            else
                curr_img = curr_img(curr_selbox(3):curr_selbox(4),...
                                    curr_selbox(1):curr_selbox(2));
            end
            curr_img = curr_img(:);
            axeCur = axe_left(ind_left);
            if ind_coef
                curr_color = col_app(level,:);
                his        = wgethist(curr_img,nb_bins);
                his(2,:)   = his(2,:)/length(curr_img);
                wplothis(axeCur,his,curr_color);
                set(axeCur,'UserData',curr_img);
            end
            set(axeCur,'Tag',['a' sprintf('%.0f',level)]);
            h = txtinaxe('create',['a' wnsubstr(level)],...
                          axeCur,'left','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_left = ind_left-1;
        end

        % Displaying the details histograms.
        %-----------------------------------
        col_det = wtbutils('colors','det',Lev_Anal);
        for k = det_lst_len:-1:1
            level = det_lst(k);
            ind_coef = 1;
            curr_img = detcoef2(direct(1),coefs,sizes,level);
            curr_selbox = ceil(selbox./2^level);
            if curr_selbox(2)-curr_selbox(1)<2 || ...
               curr_selbox(4)-curr_selbox(3)<2
                wwarndlg(getWavMSG('Wavelet:dw2dRF:Not_Enough',level), ...
                    getWavMSG('Wavelet:dw2dRF:NamWinHIST_2D'),'block');
                ind_coef = 0;
            else
                curr_img = curr_img(curr_selbox(3):curr_selbox(4),...
                                    curr_selbox(1):curr_selbox(2));
            end
            curr_img = curr_img(:);
            axeCur = axe_right(ind_right);
            if ind_coef
                curr_color = col_det(level,:);
                his        = wgethist(curr_img,nb_bins);
                his(2,:)   = his(2,:)/length(curr_img);
                wplothis(axeCur,his,curr_color);
                set(axeCur,'UserData',curr_img);
            end
            set(axeCur,'Tag',['d' sprintf('%.0f',level)]);
            h = txtinaxe('create',['d' wnsubstr(level)],...
                          axeCur,'right','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_right = ind_right-1;
        end

        % Vertical separation.
        %---------------------
        if n_axeleft*n_axeright~=0
            uicontrol('Parent',win_dw2dhist,...
                      'Style','frame',...
                      'Units',win_units,...
                      'Position',[x_fra,y_fra,w_fra,h_fra],...
                      'Visible','On',...
                      'BackgroundColor',fraBkColor,...
                      'Tag',tag_fra_sep...
                      );
        end

        % Signals type for the status line display.
        %------------------------------------------
        str_sig_type = [];
        if orig_sig
            str_sig_type = [str_sig_type getWavMSG('Wavelet:dw2dRF:Ori_Img')];
        end
        
        if synt_sig
            switch s_i
                case 'ss', str_ss = getWavMSG('Wavelet:dw2dRF:Syn_Img');
                case 'ds', str_ss = getWavMSG('Wavelet:dw2dRF:Den_Img');
                case 'cs', str_ss = getWavMSG('Wavelet:dw2dRF:Cmp_Img');
            end
            str_sig_type = [str_sig_type ' - ' str_ss ];
        end
        
        if (app_sig && ~isempty(app_lst)) || (det_sig && ~isempty(det_lst))
            if app_sig && ~isempty(app_lst) && det_sig && ~isempty(det_lst)
                msgID = ['App_Det_' direct(1) '_Cfs'];
            elseif (app_sig && ~isempty(app_lst)) && (~det_sig || isempty(det_lst))
                msgID = 'Approximation_Cfs';
            elseif (~app_sig || isempty(app_lst)) && (det_sig && ~isempty(det_lst))
                msgID = ['Dir_Det_' direct(1) '_Cfs'];
            end
            str_sig_type = [str_sig_type ' - ' getWavMSG(['Wavelet:dw2dRF:' msgID])];
        end
        
        if ~orig_sig && ~synt_sig         && ...
           (~app_sig || isempty(app_lst)) && ...
           (~det_sig || isempty(det_lst))
            str_sig_type = getWavMSG('Wavelet:commongui:His_NoSel');
        end
        uicontrol('Parent',win_dw2dhist,...
            'Style','edit',...
            'Units',win_units,...
            'Position',[0,0,w_graph,btn_height],...
            'Visible','On',...
            'Enable','Inactive', ...
            'BackgroundColor',ediInActBkColor,...
            'String',str_sig_type,...
            'Tag',tag_status_line...
            );

        % Setting units to normalized.
        %-----------------------------
        set(findobj(win_dw2dhist,'Units','pixels'),'Units','normalized');

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dhist);

        % Enable new selection.
        %-------------------------
        set([chk_handles;pop_handles;pus_handles;edi_bins_data],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bins_data = in3;

        % Handles of tagged objects.
        %---------------------------
        pus_show_hist = findobj(win_dw2dhist,...
                                      'Style','pushbutton',...
                                      'Tag',tag_show_hist...
                                      );
        axes_hdls   = findobj(get(win_dw2dhist,'Children'),'flat','Type','axes');
        Sigtype_hdl = findobj(win_dw2dhist,'Style','text','Tag',tag_status_line);

        if isempty(axes_hdls) , return; end

        % Check the bins number.
        %-----------------------
        default_bins = 50;
        old_params   = get(pus_show_hist,'UserData');
        if ~isempty(old_params) , default_bins = old_params(1); end
        nb_bins = str2double(get(edi_bins_data,'String'));
        if isempty(nb_bins) || nb_bins<2
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Waiting message.
        %-----------------
        set(Sigtype_hdl,'Visible','off');
        wwaiting('msg',win_dw2dhist,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Updating histograms.
        %---------------------
        old_params(1) = nb_bins;
        set(pus_show_hist,'UserData',old_params);
        nb_axes = length(axes_hdls);
        fontsize = wmachdep('FontSize','normal',9,nb_axes);
        for i=1:nb_axes
            curr_axe = axes_hdls(i);
            curr_img = get(curr_axe,'UserData');
            if ~isempty(curr_img)
                curr_child = findobj(get(curr_axe,'Children'),'Type','patch');
                axe_col    = get(curr_child,'FaceColor');
                his        = wgethist(curr_img,nb_bins);
                his(2,:)   = his(2,:)/length(curr_img);
                wplothis(curr_axe,his,axe_col);
                curr_txt   = get(curr_axe,'Tag');
                switch curr_txt(1)
                  case {'a','d'}
                    curr_txt = [curr_txt(1), wnsubstr(curr_txt(2:end))];
                end
                if curr_txt(1)=='d'
                    txtinaxe('create',curr_txt,curr_axe,'right',...
                                    'on','bold',fontsize);
                else
                    txtinaxe('create',curr_txt,curr_axe,'left',...
                                    'on','bold',fontsize);
                end
                set(curr_axe,'UserData',curr_img)
            end
        end

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dhist);
        set(Sigtype_hdl,'Visible','on');

    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

%-------------------------------------------------
function varargout = depOfMachine(varargin)

Def_Btn_Height = varargin{1};
scrSize = getMonitorSize;
if scrSize(4)<700
    chk_height = Def_Btn_Height;
else
    chk_height = 3*Def_Btn_Height/2;
end
dy1_chk = Def_Btn_Height/4;
dy_chk  = Def_Btn_Height/2;
varargout = {chk_height,dy1_chk,dy_chk};
%-------------------------------------------------
