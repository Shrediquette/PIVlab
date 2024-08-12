function out1 = dw1dhist(option,in2,in3,in4,in5,in6,in7,in8)
%DW1DHIST Discrete wavelet 1-D histograms.
%   OUT1 = DW1DHIST(OPTION,IN2,IN3,IN4,IN5,IN6,IN7,IN8)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.20.4.11 $

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
% ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MB2.
%-----
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
% nb2_stored    = 2;

% MB4.
%-----
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area = 1;
% ind_view_mode  = 2;
% ind_savepath   = 3;
% nb4_stored     = 3;

% MB1 (local).
%-------------
n_chk_lev_lst   = 'Chk_Lev_Lst';
ind_Chk_App_Lst = 1;
ind_Chk_Det_Lst = 2;
nbLOC_1_stored  = 2;

% Tag property of objects.
%-------------------------
% tag_cmd_frame = 'Cmd_Frame';
tag_orig_sig  = 'Orig_sig';
tag_synt_sig  = 'Synt_sig';
tag_app_sig   = 'App_sig';
tag_det_sig   = 'Det_sig';
tag_app_txt   = 'App_Txt';
tag_app_all   = 'App_All';
tag_app_none  = 'App_None';
tag_det_txt   = 'Det_Txt';
tag_det_all   = 'Det_All';
tag_det_none  = 'Det_None';
tag_sel_cfs   = 'Sel_Cfs';
tag_sel_rec   = 'Sel_Rec';
tag_bins_txt  = 'Bins_Txt';
tag_bins_data = 'Bins_Data';
tag_show_hist = 'Show_Hist';

% Tag property of objects.
%-------------------------
tag_sephis_fra  = 'Dw1dhist_Level';
tag_sigtype_txt = 'Dw1dhist_Sigtype';

if ~isequal(option,'create') , win_dw1dhist = in2; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,fraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height', ...
                'Def_Btn_Width','Pop_Min_Width',   ...
                'X_Spacing','Y_Spacing','Def_EdiBkColor','Def_FraBkColor' ...
                );
        Def_Btn_Height = Def_Btn_Height; % -1 High DPI correction
        % Calling figure.
        %----------------
        win_dw1dtool = in2;

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:dw1dRF:NamWinHIS_1D');
        [win_dw1dhist,pos_win,win_units,~,...
                pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create',win_name,'','ExtFig_HistStat',mfilename,0); %#ok<ASGLU>
        out1 = win_dw1dhist;

        % Begin waiting.
        %---------------
        set(win_dw1dhist,'Pointer','watch');

        % Getting variables from dw1dtool figure memory block.
        %-----------------------------------------------------
        [Sig_Name,Wav_Name,Lev_Anal,Sig_Size,Axe_Ref] = ...
            wmemtool('rmb',win_dw1dtool,n_param_anal,   ...
                           ind_sig_name,ind_wav_name,   ...
                           ind_lev_anal,ind_sig_size,ind_axe_ref);

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        x_frame0   = pos_frame0(1);
        cmd_width  = pos_frame0(3);
        push_width = (cmd_width-4*dx)/2;  
        txt_width  = Def_Btn_Width;
        pop_width  = Pop_Min_Width;
        nb_inline = 3;
        nb_lines  = max(2,ceil(Lev_Anal/nb_inline))+1;
        [h_sigs,btn_height,chk_height,hshow] = ...
                depOfMachine(Def_Btn_Height,Lev_Anal);
        default_bins    = 30;

        % Position property of objects.
        %------------------------------
        xlocINI    = pos_frame0([1 3]);
        ybottomINI = pos_win(4)-3.5*Def_Btn_Height-dy2;

        % Selection on signals.
        y_low         = ybottomINI-dy2;
        w_uic         = 7*push_width/4;
        px            = x_frame0+(cmd_width-w_uic)/2;
        pos_orig_sig  = [px, y_low-4*h_sigs/3, w_uic, h_sigs];
        y_low         = pos_orig_sig(2)-4*h_sigs/3;
        pos_synt_sig  = [px, y_low , w_uic, h_sigs];
        y_low         = pos_synt_sig(2)-4*h_sigs/3;
        pos_app_sig   = [px, y_low , w_uic, h_sigs];
        y_low         = pos_app_sig(2)-4*h_sigs/3;
        pos_det_sig   = [px, y_low , w_uic, h_sigs];

        px            = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low         = pos_det_sig(2)-btn_height/2-Def_Btn_Height;
        pos_app_txt   = [px , y_low+d_txt/2, 3*push_width/2, Def_Txt_Height];
        nb            = nb_inline+1;
        widchk        = 1.1*txt_width/2;
        wx            = (cmd_width-nb*widchk)/(nb+1);
        y_low         = pos_app_txt(2)-6*btn_height/5;
        pos_app_all   = [x_frame0+wx, y_low, txt_width/2, btn_height];
        y_low         = pos_app_all(2)-6*btn_height/5;
        pos_app_none  = [x_frame0+wx, y_low, txt_width/2, btn_height];

        hx            = nb_lines*(6*btn_height/5)-btn_height/2;
        y_low         = pos_app_txt(2)-d_txt/2-hx;
        pos_det_txt   = [px , y_low+d_txt/2 , 3*push_width/2, Def_Txt_Height];
        y_low         = pos_det_txt(2)-6*btn_height/5;
        pos_det_all   = [x_frame0+wx, y_low, txt_width/2, btn_height];
        y_low         = pos_det_all(2)-6*btn_height/5;
        pos_det_none  = [x_frame0+wx, y_low, txt_width/2, btn_height];

        px            = x_frame0+(cmd_width-5*push_width/4)/2;
        y_low         = pos_det_txt(2)-hx-btn_height/2;
        pos_sel_cfs   = [px, y_low, 5*push_width/4, Def_Btn_Height];
        y_low         = pos_sel_cfs(2)-Def_Btn_Height-dy;
        pos_sel_rec   = [px, y_low, 5*push_width/4, Def_Btn_Height];
        px            = x_frame0+(cmd_width-3*pop_width)/2;

        y_low         = pos_sel_rec(2)-2*Def_Btn_Height;
        pos_bins_txt  = [px, y_low+d_txt/2, 2*pop_width, Def_Txt_Height];
        pos_bins_data = [px+2*pop_width+dx, y_low, pop_width, Def_Btn_Height];
 
        px            = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low         = pos_bins_data(2)-Def_Btn_Height-hshow;
        pos_show_hist = [px, y_low, 3*push_width/2, hshow/3]; % 3*push_width hshow/3 High DPI

        % String property of objects.
        %----------------------------
        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        switch ss_type
            case 'ss', str_ss = getWavMSG('Wavelet:dw1dRF:Str_SS');
            case 'ds', str_ss = getWavMSG('Wavelet:dw1dRF:Str_DS');
            case 'cs', str_ss = getWavMSG('Wavelet:dw1dRF:Str_CS');
        end
        str_synt_sig  = str_ss;
        str_orig_sig  = getWavMSG('Wavelet:commongui:OriSig');
        str_app_sig   = getWavMSG('Wavelet:dw1dRF:Str_app_sig');
        str_det_sig   = getWavMSG('Wavelet:dw1dRF:Str_det_sig');
        str_app_txt   = getWavMSG('Wavelet:dw1dRF:Str_app_txt');
        str_app_all   = getWavMSG('Wavelet:dw1dRF:Str_app_all');
        str_app_none  = getWavMSG('Wavelet:dw1dRF:Str_app_none');
        str_det_txt   = getWavMSG('Wavelet:dw1dRF:Str_det_txt');
        str_det_all   = getWavMSG('Wavelet:dw1dRF:Str_det_all');
        str_det_none  = getWavMSG('Wavelet:dw1dRF:Str_det_none');
        str_sel_cfs   = getWavMSG('Wavelet:dw1dRF:Str_sel_cfs');
        str_sel_rec   = getWavMSG('Wavelet:dw1dRF:Str_sel_rec');
        str_bins_txt  = getWavMSG('Wavelet:dw1dRF:Str_bins_txt');
        str_bins_data = sprintf('%.0f',default_bins);
        str_show_hist = getWavMSG('Wavelet:dw1dRF:Str_show_hist');

        % Command part construction of the window.
        %-----------------------------------------
        if ~isequal(get(0,'CurrentFigure'),win_dw1dhist)
            figure(win_dw1dhist);
        end
        utanapar('create_copy',win_dw1dhist, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                 );

        commonProp = {'Parent',win_dw1dhist,'Units',win_units};
        comChkProp = [commonProp,'Style','Checkbox','Enable','off'];
        chk_orig_sig = uicontrol(comChkProp{:},...
                                 'Position',pos_orig_sig,...
                                 'String',str_orig_sig,...
                                 'UserData',0,...
                                 'Tag',tag_orig_sig...
                                 );
        chk_synt_sig = uicontrol(comChkProp{:},...
                                 'Position',pos_synt_sig,...
                                 'String',str_synt_sig,...
                                 'UserData',0,...
                                 'Tag',tag_synt_sig...
                                 );
        chk_app_sig  = uicontrol(comChkProp{:},...
                                 'Position',pos_app_sig,...
                                 'String',str_app_sig,...
                                 'UserData',0,...
                                 'Tag',tag_app_sig...
                                 );
        chk_det_sig  = uicontrol(comChkProp{:},...
                                 'Position',pos_det_sig,...
                                 'String',str_det_sig,...
                                 'UserData',0,...
                                 'Tag',tag_det_sig...
                                 );
 
        % Approximations checkboxes construction.

        txt_app_txt  = uicontrol(commonProp{:},...
                                 'Style','Text',...
                                 'Position',pos_app_txt,...
                                 'String',str_app_txt,...
                                 'BackgroundColor',fraBkColor,...
                                 'Visible','off',...
                                 'Tag',tag_app_txt...
                                 );
        pus_app_all  = uicontrol(commonProp{:},...
                                 'Style','PushButton',...
                                 'Position',pos_app_all,...
                                 'String',str_app_all,...
                                 'Visible','off',...
                                 'Tag',tag_app_all...
                                 );
        pus_app_none = uicontrol(commonProp{:},...
                                 'Style','PushButton',...
                                 'Position',pos_app_none,...
                                 'String',str_app_none,...
                                 'Visible','off',...
                                 'Tag',tag_app_none...
                                 );
        wx          = (cmd_width-nb*widchk)/(nb+1);
        xbtchk0     = x_frame0+txt_width/2+2*wx;
        ybtchk0     = pos_app_txt(2)-6*btn_height/5;
        xbtchk      = xbtchk0;
        ybtchk      = ybtchk0;
        Chk_App_Lst = gobjects(Lev_Anal,1);
        for i=1:Lev_Anal
            pos_app_i = [xbtchk ybtchk widchk chk_height];
            str_app_i = sprintf('%.0f',i);
            tag_app_i = ['App' str_app_i];
            chk_app_i = uicontrol(commonProp{:},...
                                  'Style','Checkbox',...
                                  'Position',pos_app_i,...
                                  'String',str_app_i,...
                                  'Visible','off',...
                                  'Tag',tag_app_i...
                                  );
            Chk_App_Lst(i) = chk_app_i;
            if rem(i,nb_inline)==0
                xbtchk = xbtchk0;
                ybtchk = ybtchk-6*btn_height/5;
            else
                xbtchk = xbtchk+widchk+wx;
            end
        end

        % Details checkboxes construction.

        txt_det_txt  = uicontrol(commonProp{:},...
                                 'Style','Text',...
                                 'Position',pos_det_txt,...
                                 'String',str_det_txt,...
                                 'BackgroundColor',fraBkColor,...
                                 'Visible','off',...
                                 'Tag',tag_det_txt...
                                 );
        pus_det_all  = uicontrol(commonProp{:},...
                                 'Style','PushButton',...
                                 'Position',pos_det_all,...
                                 'String',str_det_all,...
                                 'Visible','off',...
                                 'Tag',tag_det_all...
                                 );
        pus_det_none = uicontrol(commonProp{:},...
                                 'Style','PushButton',...
                                 'Position',pos_det_none,...
                                 'String',str_det_none,...
                                 'Visible','off',...
                                 'Tag',tag_det_none...
                                 );
        ybtchk0     = pos_det_txt(2)-6*btn_height/5;
        xbtchk      = xbtchk0;
        ybtchk      = ybtchk0;
        Chk_Det_Lst = zeros(Lev_Anal,1);
        for i=1:Lev_Anal
            pos_det_i = [xbtchk ybtchk widchk chk_height];
            str_det_i = sprintf('%.0f',i);
            tag_det_i = ['Det' str_det_i];
            chk_det_i = uicontrol(commonProp{:},...
                                  'Style','Checkbox',...
                                  'Position',pos_det_i,...
                                  'String',str_det_i,...
                                  'Visible','off',...
                                  'Tag',tag_det_i...
                                  );
            Chk_Det_Lst(i) = chk_det_i;
            if rem(i,nb_inline)==0
                xbtchk = xbtchk0;
                ybtchk = ybtchk-6*btn_height/5;
            else
                xbtchk = xbtchk+widchk+wx;
            end
        end

        rad_sel_cfs   = uicontrol(commonProp{:},...
                                  'Style','Radiobutton',...
                                  'Position',pos_sel_cfs,...
                                  'String',str_sel_cfs,...
                                  'Visible','off',...
                                  'Tag',tag_sel_cfs,...
                                  'Value',0);
        rad_sel_rec   = uicontrol(commonProp{:},...
                                  'Style','Radiobutton',...
                                  'Position',pos_sel_rec,...
                                  'String',str_sel_rec,...
                                  'Visible','off',...
                                  'Tag',tag_sel_rec,...
                                  'Value',1);
        txt_bins_txt  = uicontrol(commonProp{:},...
                                  'Style','Text',...
                                  'Position',pos_bins_txt,...
                                  'String',str_bins_txt,...
                                  'BackgroundColor',fraBkColor,...
                                  'Visible','off',...
                                  'Tag',tag_bins_txt...
                                  );
        edi_bins_data = uicontrol(commonProp{:},...
                                  'Style','Edit',...
                                  'Position',pos_bins_data,...
                                  'String',str_bins_data,...
                                  'BackgroundColor',Def_EdiBkColor,...
                                  'Visible','off',...
                                  'Tag',tag_bins_data...
                                  );
        pus_show_hist = uicontrol(commonProp{:},...
                                  'Style','pushbutton',...
                                  'Position',pos_show_hist,...
                                  'String',str_show_hist,...
                                  'Interruptible','On',...
                                  'Visible','off',...
                                  'UserData',[],...
                                  'Tag',tag_show_hist...
                                  );
        drawnow

        % Sets of handles.
        %-----------------
        set1_hdls = [txt_app_txt; pus_app_all; pus_app_none; Chk_App_Lst];
        set2_hdls = [txt_det_txt; pus_det_all; pus_det_none; Chk_Det_Lst];
        set3_hdls = [rad_sel_cfs; rad_sel_rec];
        set4_hdls = [txt_bins_txt; edi_bins_data; pus_show_hist; pus_close];

        % Selected box limits.
        %---------------------
        xlim_selbox = mngmbtn('getbox',win_dw1dtool); 
        if ~isempty(xlim_selbox)
            xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
        else
            xlim_selbox = get(Axe_Ref,'XLim');
        end
        xlim_selbox = round(xlim_selbox);
        xlim1       = xlim_selbox(1);
        xlim2       = xlim_selbox(2);
        if xlim1<1,        xlim1 = 1;        end
        if xlim2>Sig_Size, xlim2 = Sig_Size; end
        if (xlim2<1) || (xlim1>Sig_Size) , return, end
        selbox = [xlim1 xlim2];

        % Callbacks update.
        %------------------
        group_hdls    = [set1_hdls;set2_hdls;set3_hdls;set4_hdls];

        tmp_txt           = {set1_hdls , ...
                             set2_hdls , ...
                             set3_hdls , ...
                             set4_hdls , ...
                             group_hdls};

        cba_orig_sig  = @(~,~)dw1dhist('select', ...
                              win_dw1dhist , ...
                              chk_orig_sig , ...
                              tmp_txt{:} ...
                              );
        cba_synt_sig  = @(~,~)dw1dhist('select', ...
                              win_dw1dhist , ...
                              chk_synt_sig , ...
                              tmp_txt{:} ...
                              );
        cba_app_sig   = @(~,~)dw1dhist('select', ...
                              win_dw1dhist , ...
                              chk_app_sig , ...
                              tmp_txt{:} ...
                              );
        cba_det_sig   = @(~,~)dw1dhist('select', ...
                              win_dw1dhist , ...
                              chk_det_sig , ...
                              tmp_txt{:} ...
                              );
        cba_bins_data = @(~,~)dw1dhist('update_bins', ...
                              win_dw1dhist , ...
                              edi_bins_data ...
                              );
        cba_app_all   = @(~,~)set(Chk_App_Lst,'Value',1);
        cba_app_none  = @(~,~)set(Chk_App_Lst,'Value',0);
        cba_det_all   = @(~,~)set(Chk_Det_Lst,'Value',1);
        cba_det_none  = @(~,~)set(Chk_Det_Lst,'Value',0);

        cba_sel_rec = @(~,~)toggleValue(rad_sel_rec, rad_sel_cfs);
        cba_sel_cfs = @(~,~)toggleValue(rad_sel_cfs, rad_sel_rec);
        cba_show_hist = @(~,~)dw1dhist('draw', ...
                              win_dw1dhist, ...
                              win_dw1dtool, ...
                              selbox);

        set(chk_orig_sig,'Callback',cba_orig_sig);
        set(chk_synt_sig,'Callback',cba_synt_sig);
        set(chk_app_sig,'Callback',cba_app_sig);
        set(chk_det_sig,'Callback',cba_det_sig);
        set(pus_app_all,'Callback',cba_app_all);
        set(pus_app_none,'Callback',cba_app_none);
        set(pus_det_all,'Callback',cba_det_all);
        set(pus_det_none,'Callback',cba_det_none);
        set(rad_sel_rec,'Callback',cba_sel_rec);
        set(rad_sel_cfs,'Callback',cba_sel_cfs);
        set(edi_bins_data,'Callback',cba_bins_data);
        set(pus_show_hist,'Callback',cba_show_hist);

        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_dw1dhist,n_chk_lev_lst,nbLOC_1_stored);
        wmemtool('wmb',win_dw1dhist,n_chk_lev_lst,...
                       ind_Chk_App_Lst,Chk_App_Lst,ind_Chk_Det_Lst,Chk_Det_Lst);

        % Displaying the window title.
        %-----------------------------
        str_wintitle = getWavMSG('Wavelet:dw1dRF:Dw1dHS_Title', ...
                Sig_Name,Sig_Size,Lev_Anal,Wav_Name,selbox(1),selbox(2));
        wfigtitl('String',win_dw1dhist,str_wintitle,'off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_dw1dhist);

		% Initialization with signal histogram (31/08/2000).
		%---------------------------------------------------
		set(chk_orig_sig,'Value',1);
		group_hdls = [set1_hdls;set2_hdls;set3_hdls;set4_hdls];
		dw1dhist('select',win_dw1dhist,chk_orig_sig,...
			     set1_hdls,set2_hdls,set3_hdls,set4_hdls,group_hdls);		
		dw1dhist('draw',win_dw1dhist,win_dw1dtool,selbox);
        set(win_dw1dhist,'Visible','On');
		
		% End waiting.
        %-------------
        set(win_dw1dhist,'Pointer','arrow');
        set([chk_orig_sig chk_synt_sig chk_app_sig chk_det_sig],'Enable','on');

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_chk_btn = in3;
        set1_hdls   = in4;
        set2_hdls   = in5;
        set3_hdls   = in6;
        set4_hdls   = in7;
        group_hdls  = in8;
        group_hdls  = group_hdls(1:end-1);

        % Handles of tagged objects.
        %---------------------------
        uic_handles  = findobj(win_dw1dhist,'Type','uicontrol');
        chk_handles  = findobj(uic_handles,'Style','checkbox');
        txt_handles  = findobj(uic_handles,'Style','text');
        fra_handles  = findobj(uic_handles,'Style','frame');
        axe_handles  = findobj(get(win_dw1dhist,'Children'),'flat','Type','axes');
        chk_orig_sig = findobj(chk_handles,'Tag',tag_orig_sig);
        chk_synt_sig = findobj(chk_handles,'Tag',tag_synt_sig);
        chk_app_sig  = findobj(chk_handles,'Tag',tag_app_sig);
        chk_det_sig  = findobj(chk_handles,'Tag',tag_det_sig);
        hdl1         = findobj(fra_handles,'Tag',tag_sephis_fra);
        hdl2         = findobj(txt_handles,'Tag',tag_sigtype_txt);
        hdl3         = findobj(axe_handles,'flat','Visible','on');

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
        pos_det_sig   = get(chk_det_sig,'Position');
        pos_app_txt   = get(set1_hdls(1),'Position');
        pos_app_all   = get(set1_hdls(2),'Position');
        pos_app_none  = get(set1_hdls(3),'Position');
        pos_det_txt   = get(set2_hdls(1),'Position');
        pos_det_all   = get(set2_hdls(2),'Position');
        pos_det_none  = get(set2_hdls(3),'Position');
        pos_sel_cfs   = get(set3_hdls(1),'Position');
        pos_sel_rec   = get(set3_hdls(2),'Position');
        pos_bins_txt  = get(set4_hdls(1),'Position');
        pos_bins_data = get(set4_hdls(2),'Position');
        pos_show_hist = get(set4_hdls(3),'Position');
        pos_close     = get(set4_hdls(4),'Position');

        % Redefine height of buttons depending on levels.
        %------------------------------------------------
        levels    = length(set1_hdls)-3;
        nb_inline = 3;
        nbl       = max(2,ceil(levels/nb_inline))+1;
        hbtn1     = pos_bins_data(4);
        hbtn2     = hbtn1;
        hbtn3     = hbtn1;
        if levels>6, hbtn2 = 4*hbtn2/5; end
        if levels>9, hbtn3 = hbtn2/2;   end

        % Redraw the command part depending on the current selection.
        %------------------------------------------------------------
        dy3 = 0.75*hbtn1;
        switch sel_chk_btn
            case chk_orig_sig
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
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set(set4_hdls,'Visible','on');
                    end
                end

            case chk_synt_sig
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
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set(set4_hdls,'Visible','on');
                    end
                end

            case chk_app_sig
                set(group_hdls,'Visible','off');
                if app_sig
                    set(chk_app_sig,'Value',0,'UserData',0)
                    if (orig_sig || synt_sig) && ~det_sig
                        pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set(set4_hdls,'Visible','on');

                    elseif det_sig
                        pos_det_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_det_all(2)  = pos_det_txt(2)-6*hbtn2/5;
                        pos_det_none(2) = pos_det_all(2)-6*hbtn2/5;
                        set(set2_hdls(1),'Position',pos_det_txt);
                        set(set2_hdls(2),'Position',pos_det_all);
                        set(set2_hdls(3),'Position',pos_det_none);
                        pos_chk_det     = zeros(levels,4);
                        for i=1:levels
                            j=i+3;
                            k=ceil(i/nb_inline);
                            pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                            pos_chk_det(j,2) = pos_det_txt(2)-k*(6*hbtn2/5);
                            set(set2_hdls(j),'Position',pos_chk_det(j,:));
                        end

                        pos_sel_cfs(2)  = pos_det_txt(2)-nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-hbtn1-hbtn3;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-2*hbtn1-hbtn3;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set([set2_hdls;set3_hdls;set4_hdls],'Visible','on');
                    end
                else
                    set(chk_app_sig,'Value',1,'UserData',1)
                    if det_sig
                        pos_app_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_app_all(2)  = pos_app_txt(2)-6*hbtn2/5;
                        pos_app_none(2) = pos_app_all(2)-6*hbtn2/5;
                        set(set1_hdls(1),'Position',pos_app_txt);
                        set(set1_hdls(2),'Position',pos_app_all);
                        set(set1_hdls(3),'Position',pos_app_none);

                        pos_det_txt(2)  = pos_app_txt(2)-nbl*(6*hbtn2/5)-dy3;
                        pos_det_all(2)  = pos_det_txt(2)-6*hbtn2/5;
                        pos_det_none(2) = pos_det_all(2)-6*hbtn2/5;
                        set(set2_hdls(1),'Position',pos_det_txt);
                        set(set2_hdls(2),'Position',pos_det_all);
                        set(set2_hdls(3),'Position',pos_det_none);
                        pos_chk_det     = zeros(levels,4);
                        for i=1:levels
                            j=i+3;
                            k=ceil(i/nb_inline);
                            pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                            pos_chk_det(j,2) = pos_det_txt(2)-k*(6*hbtn2/5);
                            set(set2_hdls(j),'Position',pos_chk_det(j,:));
                        end

                        pos_sel_cfs(2)  = pos_det_txt(2)-nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-hbtn1-hbtn3;
                        pos_bins_data(2)= pos_bins_txt(2);
                        yl              = pos_close(2)+pos_close(4);
                        dy              = pos_bins_data(2)-yl-pos_show_hist(4);
                        pos_show_hist(2)= yl+dy/2;

                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set([set1_hdls;set2_hdls;set3_hdls;set4_hdls],'Visible','on');
                    else
                        pos_app_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_app_all(2)  = pos_app_txt(2)-6*hbtn2/5;
                        pos_app_none(2) = pos_app_all(2)-6*hbtn2/5;
                        set(set1_hdls(1),'Position',pos_app_txt);
                        set(set1_hdls(2),'Position',pos_app_all);
                        set(set1_hdls(3),'Position',pos_app_none);

                        pos_sel_cfs(2)  = pos_app_txt(2)...
                                        -nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-2*hbtn1;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set([set1_hdls;set3_hdls;set4_hdls],'Visible','on');
                    end
                end

            case chk_det_sig
                set(group_hdls,'Visible','off');
                if det_sig
                    set(chk_det_sig,'Value',0,'UserData',0)
                    if (orig_sig || synt_sig) && ~app_sig
                        pos_bins_txt(2) = pos_det_sig(2)-2*hbtn1;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set(set4_hdls,'Visible','on');
                    elseif app_sig
                        pos_app_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_app_all(2)  = pos_app_txt(2)-6*hbtn2/5;
                        pos_app_none(2) = pos_app_all(2)-6*hbtn2/5;
                        set(set1_hdls(1),'Position',pos_app_txt);
                        set(set1_hdls(2),'Position',pos_app_all);
                        set(set1_hdls(3),'Position',pos_app_none);

                        pos_sel_cfs(2)  = pos_app_txt(2)-nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-2*hbtn1;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set([set1_hdls;set3_hdls;set4_hdls],'Visible','on');
                    end
                else
                    set(chk_det_sig,'Value',1,'UserData',1)
                    if app_sig
                        pos_app_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_app_all(2)  = pos_app_txt(2)-6*hbtn2/5;
                        pos_app_none(2) = pos_app_all(2)-6*hbtn2/5;
                        set(set1_hdls(1),'Position',pos_app_txt);
                        set(set1_hdls(2),'Position',pos_app_all);
                        set(set1_hdls(3),'Position',pos_app_none);

                        pos_det_txt(2)  = pos_app_txt(2)-nbl*(6*hbtn2/5)-dy3;
                        pos_det_all(2)  = pos_det_txt(2)-6*hbtn2/5;
                        pos_det_none(2) = pos_det_all(2)-6*hbtn2/5;
                        set(set2_hdls(1),'Position',pos_det_txt);
                        set(set2_hdls(2),'Position',pos_det_all);
                        set(set2_hdls(3),'Position',pos_det_none);
                        pos_chk_det     = zeros(levels,4);
                        for i=1:levels
                            j=i+3;
                            k=ceil(i/nb_inline);
                            pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                            pos_chk_det(j,2) = pos_det_txt(2)-k*(6*hbtn2/5);
                            set(set2_hdls(j),'Position',pos_chk_det(j,:));
                        end

                        pos_sel_cfs(2)  = pos_det_txt(2)-nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-hbtn1-hbtn3;
                        pos_bins_data(2)= pos_bins_txt(2);
                        yl              = pos_close(2)+pos_close(4);
                        dy              = pos_bins_data(2)-yl-pos_show_hist(4);                 
                        pos_show_hist(2)= yl+dy/2;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);

                        set([set1_hdls;set2_hdls;set3_hdls;set4_hdls],'Visible','on');
                    else
                        pos_det_txt(2)  = pos_det_sig(2)-3*hbtn2/2;
                        pos_det_all(2)  = pos_det_txt(2)-6*hbtn2/5;
                        pos_det_none(2) = pos_det_all(2)-6*hbtn2/5;
                        set(set2_hdls(1),'Position',pos_det_txt);
                        set(set2_hdls(2),'Position',pos_det_all);
                        set(set2_hdls(3),'Position',pos_det_none);
                        pos_chk_det     = zeros(levels,4);
                        for i=1:levels
                            j=i+3;
                            k=ceil(i/nb_inline);
                            pos_chk_det(j,:) = get(set2_hdls(j),'Position');
                            pos_chk_det(j,2) = pos_det_txt(2)-k*(6*hbtn2/5);
                            set(set2_hdls(j),'Position',pos_chk_det(j,:));
                        end

                        pos_sel_cfs(2)  = pos_det_txt(2)-nbl*(6*hbtn2/5)-hbtn2/2;
                        pos_sel_rec(2)  = pos_sel_cfs(2)-3*hbtn1/2;
                        set(set3_hdls(1),'Position',pos_sel_cfs);
                        set(set3_hdls(2),'Position',pos_sel_rec);

                        pos_bins_txt(2) = pos_sel_rec(2)-2*hbtn1;
                        pos_bins_data(2)= pos_bins_txt(2);
                        pos_show_hist(2)= pos_bins_data(2)-3*hbtn1;
                        set(set4_hdls(1),'Position',pos_bins_txt);
                        set(set4_hdls(2),'Position',pos_bins_data);
                        set(set4_hdls(3),'Position',pos_show_hist);
                        set([set2_hdls;set3_hdls;set4_hdls],'Visible','on');
                    end
                end
        end

    case 'draw'
        %*********************************%
        %** OPTION = 'draw' - DRAW AXES **%
        %*********************************%
        win_dw1dtool = in3;
        selbox_orig  = in4;

        % Get Globals.
        %-------------
        [Def_Btn_Height,ediInActBkColor,fraBkColor] = mextglob('get',...
            'Def_Btn_Height','Def_Edi_InActBkColor','Def_FraBkColor');

        % Handles of tagged objects.
        %---------------------------
        uic_handles   = findobj(win_dw1dhist,'Type','uicontrol');
        chk_handles   = findobj(uic_handles,'Style','checkbox');
        rad_handles   = findobj(uic_handles,'Style','radiobutton');
        pus_handles   = findobj(uic_handles,'Style','pushbutton');
        pus_show_hist = findobj(pus_handles,...
                                      'Style','pushbutton',...
                                      'Tag',tag_show_hist...
                                      );
        txt_handles   = findobj(uic_handles,'Style','text');
        fra_handles   = findobj(uic_handles,'Style','frame');
        axe_handles   = findobj(get(win_dw1dhist,'Children'),'flat','Type','axes');
        hdl1          = findobj(fra_handles,'Tag',tag_sephis_fra);
        hdl2          = findobj(txt_handles,'Tag',tag_sigtype_txt);
        hdl3          = findobj(axe_handles,'flat','Visible','on');

        % Handles of tagged objects continuing.
        %-------------------------------------
        chk_orig_sig  = findobj(chk_handles,'Tag',tag_orig_sig);
        chk_synt_sig  = findobj(chk_handles,'Tag',tag_synt_sig);
        chk_app_sig   = findobj(chk_handles,'Tag',tag_app_sig);
        chk_det_sig   = findobj(chk_handles,'Tag',tag_det_sig);
        rad_sel_cfs   = findobj(win_dw1dhist,'Style','radiobutton',...
                                      'Tag',tag_sel_cfs);
        edi_bins_data = findobj(win_dw1dhist,'Style','edit',...
                                      'Tag',tag_bins_data);

        % Check the bins number.
        %-----------------------
        default_bins    = 30;
        old_params      = get(pus_show_hist,'UserData');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = str2num(get(edi_bins_data,'String'));
        if isempty(nb_bins) || nb_bins<2
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end

        % Getting memory blocks.
        %-----------------------
        Lev_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        [Chk_App_Lst,Chk_Det_Lst] = wmemtool('rmb',win_dw1dhist,n_chk_lev_lst,...
                                        ind_Chk_App_Lst,ind_Chk_Det_Lst);

        % Main parameters selection before drawing.
        %------------------------------------------
        sel_cfs  = (get(rad_sel_cfs,'Value')~=0);
        orig_sig = (get(chk_orig_sig,'Value')~=0);
        synt_sig = (get(chk_synt_sig,'Value')~=0);
        app_sig  = (get(chk_app_sig,'Value')~=0);
        det_sig  = (get(chk_det_sig,'Value')~=0);

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
        new_params = [nb_bins sel_cfs orig_sig synt_sig ...
                      app_sig det_sig app_lst det_lst   ...
                      ];
        if ~isempty(hdl3) && isequal(new_params,old_params) , return; end

        % Deseable new selection.
        %-------------------------
        set([chk_handles;pus_handles;rad_handles],'Enable','off');

        % Updating parameters.
        %--------------------- 
        set(pus_show_hist,'UserData',new_params);

        % Show the status line.
        %----------------------
        wfigtitl('vis',win_dw1dhist,'on');

        % Waiting message.
        %-----------------
        set(win_dw1dhist,'Pointer','watch');
 
        % Cleaning the graphical part.
        %-----------------------------
        delete([hdl1; hdl2; hdl3]);
        drawnow;
        
        % Getting memory blocks continuing.
        %----------------------------------
        Wav_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);
        [coefs,longs]   = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                                ind_coefs,ind_longs);

        % Sort and get length of apps. and dets. lists.
        %----------------------------------------------
        app_lst     = sort(app_lst);
        app_lst_len = length(app_lst);
        det_lst     = sort(det_lst);
        det_lst_len = length(det_lst);

        % General graphical parameters initialization.
        %--------------------------------------------
        win_units  = get(win_dw1dtool,'Units');
        btn_height = Def_Btn_Height;
        if ~strcmp(win_units,'pixels')
            [nul,btn_height] = wfigutil('prop_size',win_dw1dhist,1,btn_height); %#ok<ASGLU>
        end
        pos_win      = get(win_dw1dtool,'Position');
        bdx          = 0.1*pos_win(3);
        bdy          = 0.05*pos_win(4);
        ecy          = 0.03*pos_win(4);
        pos_graph    = wmemtool('rmb',win_dw1dtool,n_miscella,...
                                     ind_graph_area);
        % h_graph      = pos_graph(4);
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

        if ~isequal(get(0,'CurrentFigure'),win_dw1dhist)
            figure(win_dw1dhist);
        end

        % Building axes on the left part.
        %--------------------------------
        comAxeProp = {...
           'Parent',win_dw1dhist,...
           'Units',win_units,...
           'Box','On'...
           };
        if n_axeleft~=0
            h_left = (pos_graph(4)-2*bdy-(n_axeleft-1)*ecy)/n_axeleft;
            y_left = pos_graph(2)+bdy;
            axe_left = zeros(1,n_axeleft);
            pos_left = [x_left y_left w_left h_left];
            for k = 1:n_axeleft
                axe_left(k) = axes(comAxeProp{:},'Position',pos_left);
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
                axe_right(k) = axes(comAxeProp{:},'Position',pos_right);
                pos_right(2) = pos_right(2)+pos_right(4)+ecy;
            end
        end

        ind_left  = n_axeleft;
        ind_right = n_axeright;

        % Definition of the complete selection box.
        %-----------------------------------------
        selbox_orig = selbox_orig(1):selbox_orig(2);

        % Displaying the signal histogram.
        %---------------------------------
        if orig_sig
            curr_sig   = dw1dfile('sig',win_dw1dtool);
            curr_sig   = curr_sig(selbox_orig);
            curr_color = wtbutils('colors','sig');
            axeCur     = axe_left(ind_left);
            his      = wgethist(curr_sig,nb_bins);
            his(2,:) = his(2,:)/length(curr_sig);
            wplothis(axeCur,his,curr_color);
            set(axeCur,'Tag','s');
            set(axeCur,'UserData',curr_sig);
            h = txtinaxe('create','s',axeCur,'left','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_left = ind_left-1;
        end

        % Displaying the synthesized signal histogram.
        %---------------------------------------------
        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                        ind_ssig_type);
        if     strcmp(ss_type,'ss') , str_ss = getWavMSG('Wavelet:commongui:His_SS');
        elseif strcmp(ss_type,'ds') , str_ss = getWavMSG('Wavelet:commongui:His_DS');
        elseif strcmp(ss_type,'cs') , str_ss = getWavMSG('Wavelet:commongui:His_CS');
        end

        if synt_sig
            curr_sig   = dw1dfile('ssig',win_dw1dtool);
            curr_sig   = curr_sig(selbox_orig);
            curr_color = wtbutils('colors','ssig');
            axeCur     = axe_left(ind_left);
            his      = wgethist(curr_sig,nb_bins);
            his(2,:) = his(2,:)/length(curr_sig);
            wplothis(axeCur,his,curr_color);
            set(axeCur,'Tag','ss');
            h = txtinaxe('create',ss_type,axeCur,'left', ...
                'on','bold',fontsize);
            set(h,'Units',win_units);
            set(axeCur,'UserData',curr_sig);
            ind_left = ind_left-1;
        end

        % Displaying the approximations histograms.
        %------------------------------------------
        col_app = wtbutils('colors','app',Lev_Anal);
        if app_lst_len~=0 && ~sel_cfs
            rec_apps = dw1dfile('app',win_dw1dtool,1:Lev_Anal);
        end
        for k = app_lst_len:-1:1
            level = app_lst(k);
            ind_coef = 1;
            if sel_cfs
                curr_sig   = appcoef(coefs,longs,Wav_Name,level);
                selbox_cfs = selbox_orig;
                min_box    = ceil(min(selbox_cfs)/2^level);
                max_box    = ceil(max(selbox_cfs)/2^level);
                selbox_cfs = min_box:max_box;
                if length(selbox_cfs)>2
                    curr_sig = curr_sig(selbox_cfs);
                else
                    wwarndlg(...
                       getWavMSG('Wavelet:dw1dRF:WarnHis_1D_msgA',level), ...
                       getWavMSG('Wavelet:dw1dRF:WarnHis_1D_tit'),'block');
                    ind_coef = 0;
                end
            else
                curr_sig = rec_apps(level,:);
                curr_sig = curr_sig(selbox_orig);
            end
            axeCur = axe_left(ind_left);
            if ind_coef
                curr_color = col_app(level,:);
                his        = wgethist(curr_sig,nb_bins);
                his(2,:)   = his(2,:)/length(curr_sig);
                wplothis(axeCur,his,curr_color);
                set(axeCur,'UserData',curr_sig);
            end
            set(axe_left(ind_left),'Tag',['a' sprintf('%.0f',level)]);
            h = txtinaxe('create',['a' wnsubstr(level)],...
                                    axeCur,'left','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_left = ind_left-1;
        end

        % Displaying the details histograms.
        %-----------------------------------
        col_det = wtbutils('colors','det',Lev_Anal);
        if det_lst_len~=0 && ~sel_cfs
            rec_dets = dw1dfile('det',win_dw1dtool,1:Lev_Anal);
        end
        for k = det_lst_len:-1:1
            level = det_lst(k);
            ind_coef = 1;
            if sel_cfs
                curr_sig   = detcoef(coefs,longs,level);
                selbox_cfs = selbox_orig;
                min_box    = ceil(min(selbox_cfs)/2^level);
                max_box    = ceil(max(selbox_cfs)/2^level);
                selbox_cfs = min_box:max_box;
                if length(selbox_cfs)>2
                    curr_sig = curr_sig(selbox_cfs);
                else
                    wwarndlg(...
                       getWavMSG('Wavelet:dw1dRF:WarnHis_1D_msgD',level), ...
                       getWavMSG('Wavelet:dw1dRF:WarnHis_1D_tit'),'block');
                    ind_coef = 0;
                end
            else
                curr_sig = rec_dets(level,:);
                curr_sig = curr_sig(selbox_orig);
            end
            axeCur = axe_right(ind_right);
            if ind_coef
                curr_color = col_det(level,:);
                his        = wgethist(curr_sig,nb_bins);
                his(2,:)   = his(2,:)/length(curr_sig);
                wplothis(axeCur,his,curr_color);
                set(axeCur,'UserData',curr_sig);
            end
            set(axe_right(ind_right),'Tag',['d' sprintf('%.0f',level)]);
            h = txtinaxe('create',['d' wnsubstr(level)],...
                                    axeCur,'right','on','bold',fontsize);
            set(h,'Units',win_units);
            ind_right = ind_right-1;
        end

        % Vertical separation.
        %---------------------
        if n_axeleft*n_axeright~=0
            uicontrol(...
                    'Parent',win_dw1dhist, ...
                    'Style','frame',...
                    'Units',win_units,...
                    'Position',[x_fra,y_fra,w_fra,h_fra],...
                    'Visible','On',...
                    'BackgroundColor',fraBkColor,...
                    'Tag',tag_sephis_fra...
                    );
        end

        % Signals type for the status line display.
        %------------------------------------------
        msgSTR = [];
        if orig_sig
            msgSTR = getWavMSG('Wavelet:commongui:His_OS');
        end
        if synt_sig
            msgSTR = [msgSTR ' - ' str_ss];
        end
        if (app_sig && ~isempty(app_lst)) || (det_sig && ~isempty(det_lst))
            if ~sel_cfs
                if app_sig && ~isempty(app_lst) && det_sig && ~isempty(det_lst)
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_RecAD')];
                elseif (app_sig && ~isempty(app_lst)) && (~det_sig || isempty(det_lst))
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_RecA')];
                elseif (~app_sig || isempty(app_lst)) && (det_sig && ~isempty(det_lst))
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_RecD')];
                end
            else
                if app_sig && ~isempty(app_lst) && det_sig && ~isempty(det_lst)
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_ADCfs')];
                elseif (app_sig && ~isempty(app_lst)) && (~det_sig || isempty(det_lst))
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_ACfs')];
                elseif (~app_sig || isempty(app_lst)) && (det_sig && ~isempty(det_lst))
                    msgSTR = [msgSTR ' - '  getWavMSG('Wavelet:commongui:His_DCfs')];
                end
            end
        end
        if ~orig_sig && ~synt_sig         && ...
           (~app_sig || isempty(app_lst)) && ...
           (~det_sig || isempty(det_lst))
            msgSTR = getWavMSG('Wavelet:commongui:His_NoSel');
        end
        uicontrol(...
            'Parent',win_dw1dhist, ...
            'Style','edit',...
            'Units',win_units,...
            'Position',[0,0,w_graph,btn_height],...
            'Visible','On',...
            'Enable','Inactive', ...
            'BackgroundColor',ediInActBkColor,...
            'String',msgSTR,...
            'Tag',tag_sigtype_txt...
            );

        % Setting units to normalized.
        %-----------------------------
        set(findobj(win_dw1dhist,'Units','pixels'),'Units','normalized');

        % End waiting.
        %-------------
        set(win_dw1dhist,'Pointer','arrow');
        % wwaiting('off',win_dw1dhist);

        % Enable new selection.
        %-------------------------
        set([chk_handles;pus_handles;rad_handles],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bins_data   = in3;

        % Handles of tagged objects.
        %---------------------------
        axes_hdls = findobj(get(win_dw1dhist,'Children'),'flat','Type','axes');
        if isempty(axes_hdls) , return; end
        uic = findobj(get(win_dw1dhist,'Children'),'flat','Type','uicontrol');
        pus_show_hist = findobj(uic,'Style','pushbutton',...
                                    'Tag',tag_show_hist...
                                    );
        Sigtype_hdl = findobj(uic,'Style','text','Tag',tag_sigtype_txt);

        % Check the bins number.
        %-----------------------
        default_bins = 30;
        old_params   = get(pus_show_hist,'UserData');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = str2num(get(edi_bins_data,'String'));
        if isempty(nb_bins)
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        elseif nb_bins<2
            nb_bins = default_bins;
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Waiting message.
        %-----------------
        set(Sigtype_hdl,'Visible','off');
        set(win_dw1dhist,'Pointer','watch');

        % Updating histograms.
        %---------------------
        old_params(1) = nb_bins;
        set(pus_show_hist,'UserData',old_params);

        nb_axes  = length(axes_hdls);
        fontsize = wmachdep('FontSize','normal',9,nb_axes);
        for i=1:nb_axes
            curr_axe = axes_hdls(i);
            curr_sig = get(curr_axe,'UserData');
            if ~isempty(curr_sig)
                curr_child = findobj(get(curr_axe,'Children'),'Type','patch');
                axe_col    = get(curr_child,'FaceColor');
                his        = wgethist(curr_sig,nb_bins);
                his(2,:)   = his(2,:)/length(curr_sig);
                wplothis(curr_axe,his,axe_col);
                curr_txt   = get(curr_axe,'Tag');
                switch curr_txt(1)
                  case {'a','d'}
                    curr_txt = [curr_txt(1), wnsubstr(curr_txt(2:end))];
                end
                if curr_txt(1)=='d', side = 'right'; else side = 'left'; end
                txtinaxe('create',curr_txt,curr_axe,side,'on','bold',fontsize);
                set(curr_axe,'UserData',curr_sig)
            end
        end

        % End waiting.
        %-------------
        set(win_dw1dhist,'Pointer','arrow');
        set(Sigtype_hdl,'Visible','on');

    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%-------------------------------------------------
function varargout = depOfMachine(varargin)

Def_Btn_Height = varargin{1};
Lev_Anal       = varargin{2};
scrSize = getMonitorSize;
if scrSize(4) <= 700
    h_sigs = Def_Btn_Height;
else
    if (Lev_Anal>9)
        h_sigs = 5*Def_Btn_Height/4;
    else
        h_sigs = 3*Def_Btn_Height/2;
    end
end

if Lev_Anal>6
    btn_height = 4*Def_Btn_Height/5;
    if scrSize(4)<600
        chk_height = Def_Btn_Height;
    else
        chk_height = btn_height;
    end
else
    btn_height = Def_Btn_Height;
    chk_height = Def_Btn_Height;
end

hshow = 2*Def_Btn_Height;
if  (Lev_Anal>9)
    if (scrSize(4)<600)
       hshow = Def_Btn_Height;
    else
       hshow = 1.5*Def_Btn_Height;
    end
end

varargout = {h_sigs,btn_height,chk_height,hshow};
%-------------------------------------------------

function toggleValue(setOn, setOff)
setOn.Value = 1;
setOff.Value = 0;
