function out1 = dw1dcfsm(option,win_dw1dtool,in3,in4,in5)
%DW1DCFSM Discrete wavelet 1-D show and scroll (stemcfs) mode manager.
%   OUT1 = DW1DCFSM(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.10.4.11 $  $Date: 2013/07/05 04:29:48 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
ind_sig_size   = 2;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs  = 'Coefs_and_Longs';
ind_coefs      = 1;
ind_longs      = 2;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;

% Tag property of objects.
%-------------------------
tag_valapp_scr = 'ValApp_Scr';
tag_valdet_scr = 'ValDet_Scr';
tag_axeappCfs  = 'Axe_AppCfs';
tag_axedetCfs  = 'Axe_DetCfs';
tag_axecfsCfs  = 'Axe_CfsCfs';
tag_s_inapp    = 'Sig_in_App';
tag_ss_inapp   = 'SSig_in_App';
tag_s_indet    = 'Sig_in_Det';
tag_ss_indet   = 'SSig_in_Det';
tag_app        = 'App';
tag_det        = 'Det';
tag_stem       = 'Stems';

children    = get(win_dw1dtool,'Children');
axe_handles = findobj(children,'flat','Type','axes');
uic_handles = findobj(children,'flat','Type','uicontrol');
pop_handles = findobj(uic_handles,'Style','popupmenu');
axe_app_ini = findobj(axe_handles,'flat','Tag',tag_axeappCfs);
axe_det_ini = findobj(axe_handles,'flat','Tag',tag_axedetCfs);
axe_cfs_ini = findobj(axe_handles,'flat','Tag',tag_axecfsCfs);

switch option
    case 'app'
        pop = findobj(pop_handles,'Tag',tag_valapp_scr);
        num = get(pop,'Value');
        old = findobj(axe_app_ini,'Tag',tag_app);
        if ~isempty(old)
            hdl_line = findobj(old,'UserData',num);
            if ~isempty(hdl_line)
                old(old==hdl_line) = [];
                try delete(old); catch , end
                return
            end
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw1dtool,...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        try delete(old); catch , end %#ok<*CTCH>
        x = dw1dfile('app',win_dw1dtool,num);
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                                ind_lev_anal);
        col_app = wtbutils('colors','app',Level_Anal);
        line('Parent',axe_app_ini,'XData',1:length(x),'YData',x,...
                'Color',col_app(num,:),'Tag',tag_app,'UserData',num);
        wtitle(getWavMSG('Wavelet:dw1dRF:Sig_App',num),'Parent',axe_app_ini);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'det'
        pop = findobj(pop_handles,'Tag',tag_valdet_scr);
        num = get(pop,'Value');
        old = findobj(axe_det_ini,'Tag',tag_det);
        if ~isempty(old)
            hdl_line = findobj(old,'UserData',num);
            if ~isempty(hdl_line)
                old(old==hdl_line) = [];
                try delete(old); catch , end
                return
            end
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw1dtool, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        try delete(old); catch , end
        ll = findobj(axe_det_ini,'Type','line','Visible','On');
        if isempty(ll)
            [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,num,1);
        else
            set_ylim = 0;
            x = dw1dfile('det',win_dw1dtool,num);
        end
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        col_det = wtbutils('colors','det',Level_Anal);
        line('Parent',axe_det_ini,'XData',1:length(x),'YData',x,...
                'Color',col_det(num,:),'Tag',tag_det,'UserData',num);
        if set_ylim , set(axe_det_ini,'YLim',[ymin,ymax]); end
        wtitle(getWavMSG('Wavelet:dw1dRF:Det',num),'Parent',axe_det_ini);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'plot_sig'
        % in3 = signal
        % in4 = display mode
        % in5 = sig  visibility  
        %----------------------
        if      nargin==3 , in4 = 6; in5 = 1;
        elseif  nargin==4 , in5 = 1; 
        end
        if in4==6 , v = 1; else v = 0; end
        axe_hdl = dw1dcfsm('axes',win_dw1dtool,[1 1 1],1);
        vsig = getonoff(in5);
        set(axe_hdl(1),'Visible',vsig);
        set(axe_hdl(2:3),'Visible',getonoff(v));

        % Drawing.
        %---------
        axeAct = axe_hdl(1);
        wtitle(getWavMSG('Wavelet:commongui:LoadedSig'),'Parent',axeAct);
        col_s  = wtbutils('colors','sig');
        line('Parent',axeAct,'XData',1:length(in3),'YData',in3,...
                'Color',col_s,'Visible',vsig,'Tag',tag_s_inapp);

        axeAct = axe_hdl(2);
        xmin = 1;               xmax = length(in3);
        ymin = min(in3)-eps;    ymax = max(in3)+eps;
        line('Parent',axeAct,'XData',xmin:xmax,'YData',in3,...
                'Color',col_s,'Visible','Off','Tag',tag_s_indet);
        set(axe_hdl(1:3),'XLim',[xmin xmax],'YLim',[ymin ymax]);

    case 'plot_anal'
        lin_handles     = findobj(axe_handles,'Type','line');
        ss_in_app       = findobj(lin_handles,'Tag',tag_ss_inapp);
        if isempty(ss_in_app)
                col_ss  = wtbutils('colors','ssig');
                ss_rec  = dw1dfile('ssig',win_dw1dtool);
                line(...
                        'Parent',axe_app_ini, ...
                        'XData',1:length(ss_rec),'YData',ss_rec, ...
                        'ZData',2*ones(size(ss_rec)),...
                        'Color',col_ss,'Visible','Off','Tag',tag_ss_inapp);

                line(...
                        'Parent',axe_det_ini, ...
                        'XData',1:length(ss_rec),'YData',ss_rec, ...
                        'ZData',2*ones(size(ss_rec)), ...
                        'Color',col_ss,'Visible','Off','Tag',tag_ss_indet);

                clear ss_rec
        end

        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        [app_rec,~,ymin,ymax] = dw1dfile('app',win_dw1dtool,1,1);
        ylim = get(axe_app_ini,'YLim');
        if ylim(1)<ymin , ymin = ylim(1); end
        if ylim(2)>ymax , ymax = ylim(2); end
        col_app = wtbutils('colors','app',Level_Anal);
        line(...
            'Parent',axe_app_ini,...
            'XData',1:length(app_rec),'YData',app_rec,...
            'Color',col_app(1,:),'Tag',tag_app,'UserData',1);
        wtitle(getWavMSG('Wavelet:dw1dRF:SigAppLev1'),'Parent',axe_app_ini)
        set(axe_app_ini,'YLim',[ymin,ymax]);
        clear app_rec

        [det_rec,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,1,1);
        col_det = wtbutils('colors','det',Level_Anal);
        line(...
            'Parent',axe_det_ini,...
            'XData',1:length(det_rec),'YData',det_rec,...
            'Color',col_det(1,:),'Tag',tag_det,'UserData',1);
        if set_ylim , set(axe_det_ini,'YLim',[ymin,ymax]); end
        wtitle(getWavMSG('Wavelet:dw1dRF:DetLev1'),'Parent',axe_det_ini)
        clear det_rec

        levlab = flipud(int2str((1:Level_Anal)'));
        set(axe_cfs_ini,'YTickLabelMode','manual',...
                        'YTick',1:Level_Anal, ...
                        'YTickLabel',levlab,      ...
                        'Tag',tag_axecfsCfs       ...
                        );
        wtitle(getWavMSG('Wavelet:dw1dRF:DetCfs'),'Parent',axe_cfs_ini);
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axe_cfs_ini)
        clear dec_cfs

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_app_ini);

        % Axes attachment.
        %-----------------
        dw1dcfsm('dynv',win_dw1dtool);

    case 'plot_cfs'
        % in3 = display mode
        %------------------
        % if nargin==2 , in3 = 1; end
        % if in3==6 , v = 1; else v = 0; end
        v = 0;  % force l'affichage des coefficients

        axe_hdl = dw1dcfsm('axes',win_dw1dtool,[1 v 1],1);
        set(axe_hdl(2),'Visible',getonoff(v));
        set(axe_hdl(1,3),'Visible','On');

        Signal_Size = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_sig_size);
        xmin = 1;       xmax = Signal_Size;
        
        if v
            set(axe_hdl(1:3),'XLim',[xmin xmax]); %#ok<UNRCH>
        else
            [coefs,longs]   = wmemtool('rmb',win_dw1dtool,...
                                            n_coefs_longs,ind_coefs,ind_longs);
            coefs = coefs(longs(1)+1:end);
            longs = longs(2:end-1);
            nbd   = length(longs);
            ymin = min(coefs);
            ymax = max(coefs);
            if ymin==ymax , dy = 0.001; else dy = (ymax-ymin)/20; end
            ymin = ymin-dy; ymax = ymax+dy;
            axe_act = axe_hdl(1);
            set(axe_act,'XLim',[1 length(coefs)],'YLim',[ymin ymax]);
            wtitle(getWavMSG('Wavelet:dw1dRF:LoadDetCol',nbd),'Parent',axe_act); 
            line('Parent',axe_act,'XData',1:length(coefs),'YData',coefs, ...
                 'Color',wtbutils('colors','coefs'));
            x = 0;
            linCOL = wtbutils('colors','dw1d','sepcfs');
            for k = 1:nbd-1
                x = x+longs(k);
                line('Parent',axe_act,'XData',[x x],'YData',[ymin ymax], ...
                     'Color',linCOL);
            end
            drawnow
            set(axe_hdl(2:3),'XLim',[xmin xmax]);
        end
        axe_act = axe_hdl(3);
        [~,~,~,~,~,~,levs] = dw1dmisc('col_cfs',win_dw1dtool);
        levlab  = flipud(int2str(levs(:)));
        ta3 = getWavMSG('Wavelet:dw1dRF:LoadDetCol');
        wtitle(ta3,'Parent',axe_act);
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axe_act)
        set(axe_act,'YTickLabelMode','manual',   ...
                        'YTick',1:length(levs),  ...
                        'YTickLabel',levlab,     ...
                        'Tag',tag_axecfsCfs      ...
                        );
        if v==0
            set(axe_hdl(1),'XLim',[1 length(coefs)],'YLim',[ymin ymax]);
        end

    case 'plot_synt'
        % Getting  Synthesis parameters.
        %------------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);

        % Computing Decomposition.
        %-------------------------
        col_s   = wtbutils('colors','sig');
        col_ss  = wtbutils('colors','ssig');
        col_app = wtbutils('colors','app',Level_Anal);
        col_det = wtbutils('colors','det',Level_Anal);

        delete(get(axe_app_ini,'Children'));
        axe_hdl = dw1dcfsm('axes',win_dw1dtool,[1 1 1],0);
        set(axe_hdl,'Visible','On');

        sig_rec = dw1dfile('sig',win_dw1dtool);
        line(...
                'Parent',axe_app_ini,...
                'XData',1:length(sig_rec),'YData',sig_rec,...
                'Color',col_s,'Tag',tag_s_inapp);
        line(...
                'Parent',axe_app_ini,...
                'XData',1:length(sig_rec),'YData',sig_rec,'ZData',2*ones(size(sig_rec)),...
                'Color',col_ss,'Visible','Off','Tag',tag_ss_inapp);

        app_rec = dw1dfile('app',win_dw1dtool,1);
        line(...
                'Parent',axe_app_ini,...
                'XData',1:length(app_rec),'YData',app_rec,...
                'Color',col_app(1,:),'Tag',tag_app,'UserData',1);
        wtitle(getWavMSG('Wavelet:dw1dRF:OSSig_AppLev1'),'Parent',axe_app_ini)
        clear app_rec
        [det_rec,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,1,1);
        line(...
                'Parent',axe_det_ini,...
                'XData',1:length(sig_rec),'YData',sig_rec,...
                'Color',col_s,'Visible','Off','Tag',tag_s_indet);
        line(...
                'Parent',axe_det_ini,...
                'XData',1:length(sig_rec),'YData',sig_rec,'ZData',2*ones(size(sig_rec)),...
                'Color',col_ss,'Visible','Off','Tag',tag_ss_indet);

        line(...
                'Parent',axe_det_ini,...
                'XData',1:length(det_rec),'YData',det_rec,...
                'Color',col_det(1,:),'Tag',tag_det,'UserData',1);
        if set_ylim , set(axe_det_ini,'YLim',[ymin ymax]); end
        wtitle(getWavMSG('Wavelet:dw1dRF:DetLev1'),'Parent',axe_det_ini)

        wtitle(getWavMSG('Wavelet:dw1dRF:DetCfs'),'Parent',axe_cfs_ini);
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axe_cfs_ini);

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_app_ini);

        % Axes attachment.
        %-----------------
        dw1dcfsm('dynv',win_dw1dtool);

    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean
        %-------------------------
        old_mode = in3;
        [flg_axe,flg_sa,flg_app,flg_sd,flg_det,abscfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,6);
        v_flg = [flg_sa , flg_app , flg_sd , flg_det , flg_axe(3)];
        if flg_axe(1)== 0 , v_flg(1:3) = zeros(1,3); end
        if flg_axe(2)== 0 , v_flg(4:6) = zeros(1,3); end
        if flg_axe(3)== 0 , v_flg(7)   = 0; end

        pop_app   = findobj(pop_handles,'Tag',tag_valapp_scr);
        lev_a     = get(pop_app,'Value');
        pop_det   = findobj(pop_handles,'Tag',tag_valdet_scr);
        lev_d     = get(pop_det,'Value');

        vis_str   = getonoff(v_flg);
        v_s_app   = vis_str{1};
        v_ss_app  = vis_str{2};
        v_app     = vis_str{3};
        v_s_det   = vis_str{4};
        v_ss_det  = vis_str{5};
        v_det     = vis_str{6};
        v_cfs     = vis_str{7};

        axe_hdl     = dw1dcfsm('axes',win_dw1dtool,flg_axe);
        lin_handles = findobj(axe_hdl,'Type','line');
        s_in_app    = findobj(lin_handles,'Tag',tag_s_inapp);
        s_in_det    = findobj(lin_handles,'Tag',tag_s_indet);
        app         = findobj(lin_handles,'Tag',tag_app,'UserData',lev_a);
        ss_in_app   = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_in_det   = findobj(lin_handles,'Tag',tag_ss_indet);
        det         = findobj(lin_handles,'Tag',tag_det,'UserData',lev_d);

        [opt_act,Level_Anal,ss_type] = ...
                wmemtool('rmb',win_dw1dtool,n_param_anal,...
                          ind_act_option,ind_lev_anal,ind_ssig_type);
        if      strcmp(ss_type,'ss'), str_ss = 'SS';
        elseif  strcmp(ss_type,'ds'), str_ss = 'DS';
        elseif  strcmp(ss_type,'cs'), str_ss = 'CS';
        end

        if strcmp(opt_act,'synt')
            ini_str = 'OSS';
        else
            ini_str = 'Sig';
        end
        if v_flg(1)==1
            if v_flg(2)==1
                msgKey = [ini_str '_' str_ss '_App']; 
            else    
                msgKey = [ini_str  '_App'];     
            end
        else
            if v_flg(2)==1
                msgKey = [str_ss  '_App'];      
            else    
                msgKey = 'App';   
            end
        end
        wtitle(getWavMSG(['Wavelet:dw1dRF:' msgKey],lev_a),'Parent',axe_hdl(1));

        if v_flg(4)==1
            if v_flg(5)==1
                msgKey = [ini_str '_' str_ss '_Det']; 
            else    
                msgKey = [ini_str '_Det'];     
            end
        else
            if v_flg(5)==1
                msgKey = [str_ss '_Det'];      
            else    
                msgKey = 'Det';   
            end
        end
        wtitle(getWavMSG(['Wavelet:dw1dRF:' msgKey],lev_d),'Parent',axe_hdl(2));

        if isempty(s_in_app)
            x = dw1dfile('sig',win_dw1dtool);
            xmin = 1;               xmax = length(x);
            ymin = min(x)-eps;      ymax = max(x)+eps;
            set(axe_hdl(1:3),'XLim',[xmin xmax]);
            col_s = wtbutils('colors','sig');
            line(...
                'Parent',axe_hdl(1),...
                'XData',xmin:xmax,'YData',x,...
                'Color',col_s,'Visible',v_s_app,'Tag',tag_s_inapp);
            line(...
                'Parent',axe_hdl(2),...
                'XData',xmin:xmax,'YData',x,...
                'Color',col_s,'Visible',v_s_det,'Tag',tag_s_indet);
        else
            set(s_in_app,'Visible',v_s_app);
            set(s_in_det,'Visible',v_s_det);
        end
        if isempty(ss_in_app)
            x = dw1dfile('ssig',win_dw1dtool);
            col_ss  = wtbutils('colors','ssig');
            line(...
                'Parent',axe_hdl(1),...
                'XData',1:length(x),'YData',x,'ZData',2*ones(size(x)),...
                'Color',col_ss,'Visible',v_ss_app,'Tag',tag_ss_inapp);
            line(...
                'Parent',axe_hdl(2),...
                'XData',1:length(x),'YData',x,'ZData',2*ones(size(x)),...
                'Color',col_ss,'Visible',v_ss_det,'Tag',tag_ss_indet);
        else
            set(ss_in_app,'Visible',v_ss_app);
            set(ss_in_det,'Visible',v_ss_det);
        end
        if isempty(app)
            x = dw1dfile('app',win_dw1dtool,lev_a);
            col_app = wtbutils('colors','app',Level_Anal);
            line(...
                'Parent',axe_hdl(1),...
                'XData',1:length(x),'YData',x,...
                'Color',col_app(lev_a,:),'Visible',v_app, ...
                'Tag',tag_app,'UserData',lev_a);
        else
            set(app,'Visible',v_app);
        end

        if isempty(det)
            ll = findobj([s_in_det,ss_in_det], 'Visible','on');
            if isempty(ll)
                [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,lev_d,1);
            else
                set_ylim = 0;
                x = dw1dfile('det',win_dw1dtool,lev_d);
            end
            col_det = wtbutils('colors','det',Level_Anal);
            line(...
                'Parent',axe_hdl(2),...
                'XData',1:length(x),'YData',x,...
                'Color',col_det(lev_d,:),'Visible',v_det, ...
                'Tag',tag_det,'UserData',lev_d);
            if set_ylim , set(axe_hdl(2),'YLim',[ymin,ymax]); end
        else
            set(det,'Visible',v_det);
        end

        axe_act = axe_hdl(3);
        abscfs_m = rem(abscfs_m,2);
        hdl_stem = findobj(axe_act,'Tag',tag_stem);
        if isempty(hdl_stem)
            okStem = 1;
        else
            old_abscfs_m = get(hdl_stem(1),'UserData');
            okStem = ~isequal(old_abscfs_m,abscfs_m);
        end
        if okStem
            [coefs,longs] = wmemtool('rmb',win_dw1dtool,...
                                       n_coefs_longs,ind_coefs,ind_longs);
            hdl_stem = dw1dstem(axe_act,coefs,longs,...
                                'mode',abscfs_m,'colors','WTBX');
            hdl_stem = hdl_stem(ishandle(hdl_stem));
            set(hdl_stem,'UserData',abscfs_m,'Tag',tag_stem);
        end
        set(hdl_stem,'Visible',v_cfs);
        levlab = int2str((1:Level_Anal)');
        set(axe_act,...
                'clipping','on',            ...
                'YTickLabelMode','manual',  ...
                'YTick',1:Level_Anal,     ...
                'YTickLabel',levlab,        ...
                'YLim',[0.5 Level_Anal+0.5],...
                'Visible',v_cfs,            ...
                'Tag',tag_axecfsCfs         ...
                );
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axe_act);
        wtitle(getWavMSG('Wavelet:dw1dRF:DetCfs'),'Parent',axe_act);

        % Axes attachment.
        %-----------------
        dw1dcfsm('dynv',win_dw1dtool,old_mode);

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_hdl(1));

    case 'dynv'
        % in3 = -1 : same mode
        % in3 =  0 : clean 
        %--------------------
        % Axes attachment.
        %-----------------
        if nargin==2 , in3 = 0; end
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'cfs',in3);
        if okNew
            dynvtool('get',win_dw1dtool,0,'force');
            Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                                ind_lev_anal);
            dynvtool('init',win_dw1dtool,...
                      [],[axe_app_ini axe_det_ini,axe_cfs_ini],[],[1 0], ...
                      '','','dw1dcoor',...
                  [double(win_dw1dtool),double(axe_cfs_ini),-Level_Anal]);
        end

    case 'axes'
        % in3 flag for axes visibility
        % in4 flag for clearing axes
        % in4 = 1 , clear axes.
        %---------------------------
        switch nargin
            case 2 , flg_axe = [1 1 1]; clear_axes = 1;
            case 3 , flg_axe = in3;     clear_axes = 0;
            case 4 , flg_axe = in3;     clear_axes = in4;
        end

        % Axes Positions.
        %----------------
        nb_axes = sum(flg_axe);
        pos_graph = wmemtool('rmb',win_dw1dtool,n_miscella,ind_graph_area);
        pos_win = get(win_dw1dtool,'Position');
        bdx     = 0.06*pos_win(3);
        bdy     = 0.08*pos_win(4);
        bdy0    = 0.04*pos_win(4);
        bdy1    = 0.04*pos_win(4);
        bdy2    = 0.06*pos_win(4);
        %--------------------- Scale of Colors Axes ----------------------%
        h_col   = 0.02*pos_win(4);
        w_col   = pos_graph(3)/3;
        x_col   = pos_graph(1)+w_col;
        y_col   = pos_graph(2)+bdy0;
        pos_ax      = zeros(4,4);
        pos_ax(4,:) = [x_col , y_col , w_col , h_col];
        %-----------------------------------------------------------------%
        if nb_axes==0 , nb_axes = 3 ;end
        xleft = pos_graph(1)+bdx;
        width = pos_graph(3)-2*bdx;
        hy = pos_graph(4)-(nb_axes-1)*bdy-bdy0-bdy2;
        if flg_axe(3)==1
            ylow        = y_col+h_col+bdy1;
            height      = (hy-bdy1-h_col)/nb_axes;
            pos_ax(3,:) = [xleft , ylow , width , height];
            ylow = ylow+height+bdy;

        else
            ylow = pos_graph(2)+bdy0;
            height  = hy/nb_axes;
        end
        if flg_axe(2)==1
            pos_ax(2,:) = [xleft , ylow , width , height];
            ylow = ylow+height+bdy;
        end

        if flg_axe(1)==1
            pos_ax(1,:) = [xleft , ylow , width , height];      
        end
        axe_hdl = findobj(axe_handles,'flat','Tag',tag_axeappCfs);
        if ~isempty(axe_hdl)
            out1(1) = axe_hdl;
            out1(2) = findobj(axe_handles,'flat','Tag',tag_axedetCfs);
            out1(3) = findobj(axe_handles,'flat','Tag',tag_axecfsCfs);
            if clear_axes , cleanaxe(out1) ; end             
        else
            if ~isequal(get(0,'CurrentFigure'),win_dw1dtool)
                figure(win_dw1dtool);
            end
            win_units = get(win_dw1dtool,'Units');
            out1(1) = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','Off',        ...
                        'box','on',             ...
                        'NextPlot','Add',       ...
                        'Tag',tag_axeappCfs     ...
                        );
            out1(2) = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','Off',        ...
                        'box','on',             ...
                        'NextPlot','Add',       ...
                        'Tag',tag_axedetCfs     ...
                        );
            out1(3) = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','Off',        ...
                        'box','on',             ...
                        'NextPlot','Add',       ...
                        'Tag',tag_axecfsCfs     ...
                        );
        end
        flg_vis = flg_axe;
        for k =1:3
            if flg_vis(k)==0
                h = findobj(out1(k));
                set(h,'Visible','off');
            else
                set(out1(k),'Visible','on','Position',pos_ax(k,:));
            end
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_app      = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_det      = findobj(lin_handles,'Tag',tag_ss_indet);
        delete([ss_app ss_det]);

    case 'clear'
        % in3 = 0 : clean 
        %--------------------
        % new_mode = in3;
        dynvtool('stop',win_dw1dtool);
        out1 = findobj([axe_app_ini,axe_det_ini,axe_cfs_ini]);
        delete(out1);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
