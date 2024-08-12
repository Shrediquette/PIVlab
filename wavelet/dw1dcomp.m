function varargout = dw1dcomp(option,varargin)
%DW1DCOMP Discrete wavelet 1-D compression.
%   VARARGOUT = DW1DCOMP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.22.4.17 $

% Default Value(s).
%------------------
def_nbCodeOfColors = 128;

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
% ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
% nb1_stored     = 8;

% MB2.
%-----
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
% nb2_stored    = 2;

% MB1 (local).
%-------------
n_misc_loc = ['MB1_dw1dcomp'];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_cfsMode    = 6;
ind_lin_cfs    = 7;
ind_pop_mod    = 8;
nbLOC_1_stored = 8;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

% Tag property.
%--------------
tag_axetxt_perf = 'Txt_Perf';

if ~isequal(option,'create') , win_compress = varargin{1}; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing','Def_FraBkColor' );

        % Calling figure.
        %----------------
        win_caller = varargin{1};

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:dw1dRF:NamWinCMP_1D');
        [win_compress,pos_win,win_units,~,pos_frame0] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                                {mfilename,'cond'},1,1,0);
        set(win_compress,'UserData',win_caller,'Tag','DW1D_CMP');
        varargout{1} = win_compress;
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_compress,getWavMSG('Wavelet:dw1dRF:HLP_SigComp'),'DW1D_COMP_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_compress,getWavMSG('Wavelet:dw1dRF:HLP_CompProc'),'COMP_PROCEDURE');
		wfighelp('addHelpItem',win_compress,getWavMSG('Wavelet:dw1dRF:HLP_AvailMeth'),'COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_compress,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:CmpSig'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw1dcomp('save_synt',win_compress)  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:Cfs'), ...
            'Position',2,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw1dcomp('save_cfs',win_compress)  ...
            );
        sav_menus(3) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:Dec'), ...
            'Position',3,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw1dcomp('save_dec',win_compress)  ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getWavMSG('Wavelet:commongui:GenerateMATLABCompress'), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('dw1dcomp',win_compress)  ...
            );
        wtbxappdata('set',win_compress,'M_GenCode',m_gen);
                
        % Begin waiting.
        %---------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting Analysis parameters.
        %-----------------------------
        [Sig_Name,Wav_Name,Lev_Anal,Sig_Size] = ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_sig_name,ind_wav_name,...
                               ind_lev_anal,ind_sig_size);
        Wav_Fam  = wavemngr('fam_num',Wav_Name);
        isBior   = wavemngr('isbior',Wav_Fam);
        Sig_Anal = dw1dfile('sig',win_caller);

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        if Lev_Anal>4 , ySpace = dy; else ySpace = 4*dy; end  % high DPI 2*dy
        str_pop_mod = {...
            getWavMSG('Wavelet:dw1dRF:GlbTHR'),...
            getWavMSG('Wavelet:dw1dRF:LevTHR')};

        % Command & Graphic parts (common & global thresholding).
        %========================================================
        comFigProp = {'Parent',win_compress,'Units',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',Lev_Anal}...
                    );

        % Popup for mode.
        %----------------
        w_uic = (3*pos_frame0(3))/4;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-ySpace-h_uic;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        pos_pop_mod = [x_uic, y_uic, w_uic, h_uic];            
        pop_mod = uicontrol(comFigProp{:},...
            'Style','Popup',...
            'Position',pos_pop_mod,...
            'UserData',1,...
            'String',str_pop_mod...
            );
        cba_pop_mod = @(~,~)dw1dcomp('change_mode',win_compress,pop_mod);
        set(pop_mod,'Callback',cba_pop_mod);

        % Global Compression tool.
        %-------------------------
        ytopTHR = pos_pop_mod(2)-ySpace;
        utthrgbl('create',win_compress,'toolOPT','dw1dcomp', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior ...
                 );

        % Adding colormap GUI.
        %---------------------
       [viewType,hdl_cfs] = dw1dvdrv('get_imgcfs',win_caller);
       if isequal(viewType,'image')
            [pop_pal_caller,mapName,nbColors] = ...
             cbcolmap('get',win_caller,'pop_pal','mapName','nbColors');
            utcolmap('create',win_compress, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',0, ...
                     'Enable','on');
            pop_pal_loc = cbcolmap('get',win_compress,'pop_pal');
           set(pop_pal_loc,'UserData',get(pop_pal_caller,'UserData'));
            cbcolmap('set',win_compress,'pal',{mapName,nbColors});
       end

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        bdy     = 0.06*pos_win(4);
        ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);
        fontsize = wmachdep('FontSize','normal',9,Lev_Anal);

        % Axes construction parameters.
        %------------------------------
        w_left     = (w_graph-3*bdx)/2;
        x_left     = bdx;
        w_right    = w_left;
        x_right    = x_left+w_left+5*bdx/4;
        n_axeleft  = Lev_Anal;
        n_axeright = 3;
        ind_left   = n_axeleft;

        % Vertical separation.
        %---------------------
        w_fra = 0.01*pos_win(3);
        x_fra = (w_graph-w_fra)/2;
        uicontrol('Parent',win_compress,...
                  'Style','frame',...
                  'Units',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'BackgroundColor',Def_FraBkColor ...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right  = 2*ecy;
        h_right    =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right    = y_graph+2*bdy/3;
        axe_datas  = zeros(1,n_axeright);
        pos_right  = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes(...
                                'Parent',win_compress,  ...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Box','On' ...
                                ); 
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'Visible','off');

        % Displaying the signal.
        %-----------------------
        hdl_datas = [NaN ; NaN];
        axeAct = axe_datas(3);
        curr_color   = wtbutils('colors','sig');
        hdl_datas(1) = line(...
                           'XData',1:length(Sig_Anal),...
                           'YData',Sig_Anal,...
                           'Color',curr_color,...
                           'Parent',axeAct);
        wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axeAct);
        xlim = [1              Sig_Size];
        ylim = [min(Sig_Anal)  max(Sig_Anal)];
        if xlim(1)==xlim(2) , xlim = xlim+[-0.01 0.01]; end
        if ylim(1)==ylim(2) , ylim = ylim+[-0.01 0.01]; end
        set(axeAct,'XLim',xlim,'YLim',ylim);

        % Displaying original details coefficients.
        %------------------------------------------
        axeAct = axe_datas(2);
        [details,set_ylim,ymin,ymax] = dw1dfile('cfs_beg',win_caller,...
                            (1:Lev_Anal),1); %#ok<ASGLU>
        
        if isequal(viewType,'image')
            flagType = 1;
            cfsMode  = [];
            [nul,i_min] = min(abs(details(:))); %#ok<ASGLU>
            if ~isempty(hdl_cfs)
                col_cfs = flipud(get(hdl_cfs,'CData'));
            else
                col_cfs = wcodemat(details,def_nbCodeOfColors,'row',1);
            end
            col_min = col_cfs(i_min);
            col_cfs = flipud(col_cfs);
            hdl_cfs_ori = image(col_cfs,'Parent',axeAct,'UserData',col_min);
            clear col_cfs
            levlab = int2str((Lev_Anal:-1:1)');
        else
            flagType = -1;
            hdl_stem = copyobj(hdl_cfs,axeAct);
            set(hdl_stem,'Visible','on');
            cfsMode  = get(hdl_stem(1),'UserData');
            levlab = int2str((1:Lev_Anal)');
            hdl_cfs_ori = [];
        end
        set(axeAct,...
              'UserData',hdl_cfs_ori,...
              'XLim',[1 Sig_Size],...
              'YTickLabelMode','manual',...
              'YTick',(1:Lev_Anal),...
              'YTickLabel',levlab,...
              'YLim',[0.5 Lev_Anal+0.5]...
              );
        wtitle(getWavMSG('Wavelet:dw1dRF:OriCfs'),'Parent',axeAct);
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axeAct);
        xylim = get(axeAct,{'XLim','YLim'});
        set(axe_datas(1),'XLim',xylim{1},'YLim',xylim{2});

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            dw1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

       % Displaying perfos & legend.
        %--------------------------
        y_axe = y_graph+2*bdy/3+h_right+ecy_right;
        h_axe = 2*h_right+ecy_right;
        pos_axe_perfo = [x_left y_axe w_left h_axe];
        y_axe = y_graph+h_right/2;
        h_axe = h_right/2;
        pos_axe_legend = [x_left y_axe w_left h_axe];
        utthrgbl('displayPerf',win_compress, ...
                  pos_axe_perfo,pos_axe_legend,thresVALUES,n0SCR,rl2SCR,valTHR);
        [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
        utthrgbl('set',win_compress,'perfo',[perfl2,perf0]);
        drawnow

        % Command & Graphic parts (by Level thresholding).
        %=================================================
        utthrw1d('create',win_compress, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'Visible','off', ...
                 'Enable','on', ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'isbior',isBior,  ...
                 'toolOPT','comp' ...
                 );
             
        % View Compressed Signal in another window.
        %==========================================
        Pus_EST_GBL = utthrgbl('get',win_compress,'pus_est');
        [Pus_EST,Tog_THR] = utthrw1d('get',win_compress,'pus_den','tog_thr');
        pos_Pus_EST_GBL = get(Pus_EST_GBL,'Position');
        pos_Tog_THR = get(Tog_THR,'Position');
        pos_Pus_SigDorC = ...
            [pos_Tog_THR(1) , pos_Pus_EST_GBL(2)-pos_Pus_EST_GBL(4)-1*dy , ...
             pos_Tog_THR(3) , pos_Tog_THR(4)]; %-3*dy high DPI
         
        Pus_SigDorC = uicontrol('Parent',win_compress,...
                  'Style','pushbutton',...
                  'String',getWavMSG('Wavelet:dw1dRF:ViewCS'), ...
                  'Units',win_units,...
                  'Position',pos_Pus_SigDorC, ...
                  'Enable','Off', ...
                  'BackgroundColor',get(Pus_EST,'BackgroundColor'), ...
                  'UserData','Compressed', ...
                  'Tag','Pus_SigDorC' ...
                  );

        cb_Pus_SigDorC = @(~,~)dw1dview_dorc(win_compress);
        set(Pus_SigDorC,'Callback',cb_Pus_SigDorC);
        %==================================================================
        

        % Building axes on the left part.
        %--------------------------------
        comAxeProp = [comFigProp, ...
                      'Visible','Off',...
                      'Box','On'...
                     ];
        ecy_left  = ecy/2;
        h_left    = (h_graph-2*bdy-(n_axeleft-1)*ecy_left)/n_axeleft;
        y_left    = y_graph+bdy;
        axe_left  = zeros(1,n_axeleft);
        pos_left  = [x_left y_left w_left h_left];
        for k = 1:n_axeleft
            if k~=1
                axe_left(k) = axes(comAxeProp{:},'Position',pos_left,...
                                   'XTickLabelMode','manual','XTickLabel',[]); 
            else
                axe_left(k) = axes(comAxeProp{:},'Position',pos_left); 
            end
            pos_left(2) = pos_left(2)+pos_left(4)+ecy_left;
        end
        wtitle(getWavMSG('Wavelet:dw1dRF:OriDetCfs'),'Parent',axe_left(Lev_Anal));
        utthrw1d('set',win_compress,'axes',axe_left);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,Lev_Anal);
        for k = 1:Lev_Anal , maxTHR(k) = max(abs(details(k,:))); end
        valTHR = dw1dcomp('compute_LVL_THR',win_compress,win_caller);
        valTHR = min(valTHR,maxTHR);

        % Displaying details.
        %-------------------
        col_det  = wtbutils('colors','det',Lev_Anal);
        txt_left = zeros(Lev_Anal,1);
        lin_cfs  = zeros(Lev_Anal,1);
        for k = Lev_Anal:-1:1
            axeAct  = axe_left(ind_left);
            axes(axeAct); %#ok<LAXES>
            lin_cfs(k) = line(...
               'Parent',axeAct,...
               'Visible','off', ...
               'XData',1:Sig_Size,...
               'YData',details(k,:),...
               'Color',col_det(k,:));
            txt_left(k) = txtinaxe('create',['d' wnsubstr(k)],...
                             axe_left(k),'left','off','bold',fontsize);
            utthrw1d('plot_dec',win_compress,k, ...
                     {maxTHR(k),valTHR(k),1,Sig_Size,k})

            maxi = max([abs(ymax(k)),abs(ymin(k))]);
            if abs(maxi)<eps , maxi = maxi+0.01; end
            ylim = 1.1*[-maxi maxi];
            set(axe_left(ind_left),'XLim',xlim,'YLim',ylim);
            ind_left = ind_left-1;
        end

        % Initialization of Compression structure.
        %----------------------------------------
        xmin = 1; xmax = Sig_Size;
        utthrw1d('set',win_compress,...
                       'thrstruct',{xmin,xmax,valTHR,lin_cfs},...
                       'intdepthr',[]);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelp('add_ContextMenu',win_compress,pop_mod,'DW1D_COMP_GUI');
		%-------------------------------------

        % Memory blocks update.
        %----------------------
        utthrgbl('set',win_compress,'handleORI',hdl_datas(1));
        utthrw1d('set',win_compress,'handleORI',hdl_datas(1));
        wmemtool('ini',win_compress,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_compress,n_misc_loc,  ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas,  ...
                       ind_cfsMode,cfsMode,      ...
                       ind_lin_cfs,lin_cfs,      ...
                       ind_pop_mod,pop_mod       ...
                       );
        wmemtool('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_datas(1:3) axe_left(1:n_axeleft)];
        axe_act = [];
        axe_cfs = axe_datas(1:2);
        dynvtool('init',win_compress,[],axe_cmd,axe_act,[1 0], ...
            '','','dw1dcoor',...
            [double(win_caller),double(axe_cfs),flagType*Lev_Anal]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_compress);
        
   
        % View Compressed Signal in another window.
        %========================================
        Pus_EST = utthrw1d('get',win_compress,'pus_est');
        pos_Pus_EST = get(Pus_EST,'Position');
        pos_Pus_EST_GBL = get(Pus_EST_GBL,'Position');
        pos_Pus_SigDorC = get(Pus_SigDorC,'Position');
        if Lev_Anal<8 , MUL = 2; else MUL = 0.5; end
        dy = (-pos_Pus_SigDorC(2) + pos_Pus_EST_GBL(2)-pos_Pus_EST_GBL(4))/3;

        pos_Pus_SigDorC_LVL = ...
            [pos_Pus_SigDorC(1) , pos_Pus_EST(2)-pos_Pus_EST(4)-MUL*dy , ...
            pos_Pus_SigDorC(3) , pos_Pus_EST(4)];
        set(Pus_SigDorC,'UserData',[pos_Pus_SigDorC;pos_Pus_SigDorC_LVL]);
        %==================================================================
       
        
        % End waiting.
        %-------------
        set(win_compress,'Visible','On');
        wwaiting('off',win_compress);

    case 'compress'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_compress, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        % Clear & Get Handles.
        %----------------------
        dw1dcomp('clear_GRAPHICS',win_compress);
        [win_caller,pop_mod]  = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_win_caller,ind_pop_mod);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Getting memory blocks.
        %-----------------------
        [Wav_Name,Lev_Anal] = wmemtool('rmb',win_caller,n_param_anal, ...
                                       ind_wav_name,ind_lev_anal);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        isBior = wavemngr('isbior',Wav_Name);

        % Loading the original signal.
        %-----------------------------
        Sig_Anal = dw1dfile('sig',win_caller);

        mode_val = get(pop_mod,'Value');
        switch mode_val
          case 1    % Global thresholding
            valTHR = utthrgbl('get',win_compress,'valthr');
            thrParams = {'gbl',coefs,longs,Wav_Name,Lev_Anal,valTHR,'h',1};
            if isBior
                [xc,cxc,lxc,perf0] = wdencmp(thrParams{:});
                normsig = norm(Sig_Anal);
                perfl2  = 100;
                if normsig>eps , perfl2 = perfl2*(norm(xc)/normsig)^2; end
            else
                [xc,cxc,lxc]   = wdencmp(thrParams{:});
                [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
            end

          case 2    % By level thresholding
            cxc = utthrw1d('den_M2',win_compress,coefs,longs);
            lxc = longs;
            xc  = waverec(cxc,longs,Wav_Name);            
            normsig = norm(Sig_Anal);
            perfl2  = 100;
            if normsig>eps , perfl2 = perfl2*(norm(xc)/normsig)^2; end
            perf0 = 100*(length(find(cxc==0))/length(cxc));
        end

        % Displaying compressed signal.
        %------------------------------
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'YData',xc,'Visible','on');
        else
            curr_color = wtbutils('colors','ssig');
            hdl_comp = line('XData',1:length(xc),...
                            'YData',xc,...
                            'Color',curr_color,...
                            'LineWidth',2,...
                            'Parent',axe_datas(3));
            hdl_datas(2) = hdl_comp;
            wmemtool('wmb',win_compress,n_misc_loc,...
                           ind_hdl_datas,hdl_datas);
            utthrgbl('set',win_compress,'handleTHR',hdl_comp);
            utthrw1d('set',win_compress,'handleTHR',hdl_comp);
        end     

        % Set a text as a super title.
        %-----------------------------
        wtitle(getWavMSG('Wavelet:dw1dRF:OS_CS'),'Parent',axe_datas(3));
        if isBior , msgKey = 'EnerRat';else msgKey = 'RetEner'; end
        SL2  = num2str(perfl2,'%5.2f %%');
        SZer = num2str(perf0,'%5.2f %%');
        wtxttitl(axe_datas(3),...
            getWavMSG(['Wavelet:dw1dRF:' msgKey],SL2,SZer),tag_axetxt_perf);
        if mode_val==2
            utthrw1d('set',win_compress,'perfos',{perfl2,perf0});
        end 

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_compress,n_misc_loc,ind_cfsMode);
        if isempty(cfsMode)
            col_cfs   = wrepcoef(cxc,lxc);
            nz_cfs    = find(col_cfs~=0);
            [nbr,nbc] = size(col_cfs);
            img_cfs   = get(axe_datas(2),'UserData');
            col_min   = get(img_cfs,'UserData');
            cfs_ori   = flipud(get(img_cfs,'CData'));
            col_cfs   = col_min*ones(nbr,nbc);
            col_cfs(nz_cfs) = cfs_ori(nz_cfs);
            image(flipud(col_cfs),'Parent',axe_datas(1));
            levlab = int2str((Lev_Anal:-1:1)');
        else
            dw1dstem(axe_datas(1),cxc,lxc,'mode',cfsMode,'colors','WTBX');
            levlab = int2str((1:Lev_Anal)');
        end

        set(axe_datas(1),...
            'clipping','on',            ...
            'XLim',get(axe_datas(2),'XLim'),...
            'YTickLabelMode','manual',  ...
            'YTick',(1:Lev_Anal),       ...
            'YTickLabel',levlab,        ...
            'YLim',[0.5 Lev_Anal+0.5]   ...
            );

        wtitle(getWavMSG('Wavelet:dw1dRF:ThrCfs'),'Parent',axe_datas(1));
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axe_datas(1));
        set(findobj(axe_datas(1)),'Visible','on');

        % Memory blocks & HG update.
        %---------------------------
        switch mode_val
          case 1
            thrParams = utthrgbl('get',win_compress,'valthr');
          case 2
            thrStruct = utthrw1d('get',win_compress,'thrstruct');
            thrParams = {thrStruct(1:Lev_Anal).thrParams};
        end
        wmemtool('wmb',win_compress,n_thrDATA,ind_value,{xc,cxc,lxc,thrParams});
        dw1dcomp('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'change_mode'
        pop_mod = varargin{2}(1);
        mod_val = get(pop_mod,'Value');
        old_mod = get(pop_mod,'UserData');
        if isequal(mod_val,old_mod) , return; end
        set(pop_mod,'UserData',mod_val);
        dw1dcomp('clear_GRAPHICS',win_compress);
        switch mod_val
          case 1 , visGBL = 'on';  visLVL = 'off';
          case 2 , visGBL = 'off'; visLVL = 'on';
        end
        
        try
            Pus_SigDorC = wfindobj(win_compress,'Tag','Pus_SigDorC');
            set(Pus_SigDorC,'Visible','Off');
            usr = get(Pus_SigDorC,'UserData');
            set(Pus_SigDorC,'Position',usr(mod_val,:));
        catch %#ok<CTCH>
            Pus_SigDorC = [];
        end                        
        
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        viewType = dw1dvdrv('get_imgcfs',win_caller);
        if isequal(viewType,'image')
            visMAP = 'on';
            if mod_val==2
               Lev_Anal = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);
               if Lev_Anal>5 , visMAP = 'off'; else visMAP = 'on'; end
            end
            cbcolmap('Visible',win_compress,visMAP);
        end        
        utthrgbl('visible',win_compress,visGBL);
        utthrw1d('visible',win_compress,visLVL);
        if ~isempty(Pus_SigDorC) , set(Pus_SigDorC,'Visible','On'); end

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth] = utthrgbl('get_GBL_par',win_compress);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        thrFLAGS = 'dw1dcompGBL';
        switch numMeth
          case 1
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngr(thrFLAGS,meth,coefs,longs);
            if nargout==1 , varargout = {valTHR};
            else varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            sig = dw1dfile('sig',win_caller);
            valTHR = wthrmngr(thrFLAGS,meth,sig);
            maxTHR = max(coefs);
            valTHR = min(valTHR,maxTHR);
            varargout = {valTHR};
        end

    case 'update_GBL_meth'
        dw1dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('update_GBL_meth',win_compress,valTHR);

    case 'show_LVL_perfos'
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        lev_anal = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);
        [numMeth,meth,scal,sorh] = utthrw1d('get_LVL_par',win_compress); %#ok<ASGLU>
        valTHR = utthrw1d('get',win_compress,'valTHR');
        [perfl2,perf0] = wscrupd(coefs,longs,lev_anal,valTHR,sorh);      
        utthrw1d('set',win_compress,'perfos',{perfl2,perf0}); 

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa,sorh] = utthrw1d('get_LVL_par',win_compress);
       [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        level = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);

        thrFLAGS = 'dw1dcompLVL';
        switch numMeth
          case {1,2,3,4} , valTHR = wthrmngr(thrFLAGS,meth,coefs,longs,alfa);
          case 5          
            sig = dw1dfile('sig',win_caller);
            valTHR = wthrmngr(thrFLAGS,meth,sig,level);
        end
        [perfl2,perf0] = wscrupd(coefs,longs,level,valTHR,sorh);
        varargout = {valTHR,perfl2,perf0};
        utthrw1d('set',win_compress,'perfos',{perfl2,perf0}); 

    case 'update_LVL_meth'
        dw1dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw1dcomp('compute_LVL_THR',win_compress,win_caller);
        utthrw1d('update_LVL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_compress,n_misc_loc,ind_status);
        if status == 0 , return; end

        % Disable Toggles and Menus.
        %---------------------------
        dw1dcomp('enable_menus',win_compress,'off');

        % Get Handles.
        %-------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Setting the compressed coefs axes invisible.
        %---------------------------------------------
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            vis = get(hdl_comp,'Visible');
            if strcmp(vis,'on')
                txt_perf = findobj(axe_datas(3),'Tag',tag_axetxt_perf);
                if ishandle(txt_perf) , set(txt_perf,'Visible','off'); end
                set(findobj(axe_datas(1)),'Visible','off');
                wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axe_datas(3));
                set(hdl_comp,'Visible','off');
            end
        end
        
    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_compress,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_compress,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);
        utthrgbl('enable_tog_res',win_compress,enaVal);
        utthrw1d('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_compress,n_misc_loc,ind_status,status);

    case 'save_synt'
        win_compress = varargin{1};

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                      '*.mat',getWavMSG('Wavelet:commongui:SaveCmpSig'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        xc = thrDATA{1}; %#ok<NASGU>
        thrParams = thrDATA{4};
        if length(thrParams)==1      % Global Mode
            valTHR = thrParams; %#ok<NASGU>
            thrName = 'valTHR';
        else
            thrName = 'thrParams';  % By Level Mode
        end

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          saveStr = name;
          eval([saveStr '= xc ;']);
        catch %#ok<CTCH>
          saveStr = 'xc';
        end
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr,thrName,'wname');
        catch %#ok<CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_cfs'
        win_compress = varargin{1};

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                        '*.mat',getWavMSG('Wavelet:dw1dRF:Save1DCfs'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveCfs'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        longs = thrDATA{3}; %#ok<NASGU>
        thrParams = thrDATA{4};
        if length(thrParams)==1      % Global Mode
            valTHR = thrParams; %#ok<NASGU>
            thrName = 'valTHR';
        else
            thrName = 'thrParams';  % By Level Mode
        end

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wname'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                                     '*.wa1',getWavMSG('Wavelet:dw1dRF:SaveAnal_1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis parameters.
        %-----------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        [wave_name,data_name] = wmemtool('rmb',win_caller,n_param_anal,  ...
                  ind_wav_name,ind_sig_name); %#ok<ASGLU>

        % Getting Analysis values.
        %-------------------------
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        longs = thrDATA{3}; %#ok<NASGU>
        thrParams = thrDATA{4};
        if length(thrParams)==1      % Global Mode
            valTHR = thrParams; %#ok<NASGU>
            thrName = 'valTHR';
        else
            thrName = 'thrParams';  % By Level Mode
        end

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wave_name','data_name'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
         [status,win_caller] = wmemtool('rmb',win_compress,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_compress,...
                        getWavMSG('Wavelet:commongui:UpdateSS'),2,'cancel');
        end
        switch status
            case 1
              wwaiting('msg',win_compress, ...
                  getWavMSG('Wavelet:commongui:WaitCompute'));
              thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtool('wmb',win_caller,n_param_anal,...
                       ind_ssig_type,'cs',ind_thr_val,valTHR);
              hdl_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_hdl_datas);
              hdl_comp  = hdl_datas(2);
              dw1dmngr('return_comp',win_caller,status,hdl_comp);
              wwaiting('off',win_compress);

            case 0 , dw1dmngr('return_comp',win_caller,status);
        end
        varargout{1} = status;

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
