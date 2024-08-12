function varargout = dw1ddeno(option,varargin)
%DW1DDENO Wavelet 1-D de-noising.
%   VARARGOUT = DW1DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 21-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.19.4.16 $

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
n_misc_loc = ['MB1_' 'dw1ddeno'];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
% ind_hdl_datas  = 5;
ind_cfsMode    = 6;
ind_lin_cfs    = 7;
nbLOC_1_stored = 7;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

if ~isequal(option,'create') , win_denoise = varargin{1}; end
switch option
    case 'create'

        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing','Def_FraBkColor');

        % Calling figure.
        %----------------
        win_caller     = varargin{1};

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:dw1dRF:NamWinDEN_1D');
        [win_denoise,pos_win,win_units,~,pos_frame0] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                       {mfilename,'cond'},1,1,0);
        set(win_denoise,'UserData',win_caller,'Tag','DW1D_DEN');
        varargout{1} = win_denoise;
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_denoise,getWavMSG('Wavelet:dw1dRF:HLP_SigDeno'),'DW1D_DENO_GUI');

		% Add Help Item.
		%----------------
 		wfighelp('addHelpItem',win_denoise,getWavMSG('Wavelet:dw1dRF:HLP_DenoProc'),'COMP_DENO_METHODS');       
		wfighelp('addHelpItem',win_denoise,getWavMSG('Wavelet:dw1dRF:HLP_AvailMeth'),'COMP_DENO_METHODS');
   		wfighelp('addHelpItem',win_denoise,getWavMSG('Wavelet:dw1dRF:HLP_VarThr'),'COMP_DENO_METHODS');
        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:DenSig'),...
            'Position',1,                    ...
            'Enable','Off',                  ...
            'Callback',                      ...
            @(src,evt)dw1ddeno('save_synt',win_denoise)  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:Cfs'),  ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(src,evt)dw1ddeno('save_cfs',win_denoise)  ...
            );
        sav_menus(3) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw1dRF:Dec'), ...
            'Position',3,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(src,evt)dw1ddeno('save_dec',win_denoise)  ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABDenoise')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(src,evt)wsaveprocess('dw1ddeno',win_denoise)  ...
            );
        wtbxappdata('set',win_denoise,'M_GenCode',m_gen);
        

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting variables from dw1dtool figure memory block.
        %-----------------------------------------------------
        [Sig_Name,Wav_Name,Lev_Anal,Sig_Size] = ...
                        wmemtool('rmb',win_caller,n_param_anal, ...
                                ind_sig_name,ind_wav_name,      ...
                                ind_lev_anal,ind_sig_size);

        % Parameters initialization.
        %---------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        
        % Position property of objects.
        %------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;

        % Data, Wavelet and Level parameters.
        %------------------------------------
        toolPos = utanapar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % Threshold tool.
        %----------------
        ytopTHR = toolPos(2)-4*dy;
        utthrw1d('create',win_denoise, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'caller',mfilename, ...
                 'toolOPT','deno' ...
                 );
        
        % View Denoised Signal in another window.
        %========================================
        [Pus_EST,Tog_THR] = utthrw1d('get',win_denoise,'pus_den','tog_thr');
        pos_Pus_EST = get(Pus_EST,'Position');
        pos_Tog_THR = get(Tog_THR,'Position');
        
        % High DPI correction -3*dy to -5*dy
        pos_Pus_SigDorC = ...
            [pos_Tog_THR(1) , pos_Pus_EST(2)-pos_Pus_EST(4)-5*dy , ...
             pos_Tog_THR(3) , pos_Tog_THR(4)];
         
        Pus_SigDorC = uicontrol('Parent',win_denoise,...
                  'Style','pushbutton',...
                  'String',getWavMSG('Wavelet:dw1dRF:ViewDS'), ...
                  'Units',win_units,...
                  'Position',pos_Pus_SigDorC, ...
                  'Enable','Off', ...
                  'BackgroundColor',get(Pus_EST,'BackgroundColor'), ...
                  'UserData','Denoised', ...
                  'Tag','Pus_SigDorC' ...
                  );

        cb_Pus_SigDorC = @(src,evt)dw1dview_dorc(win_denoise);
        set(Pus_SigDorC,'Callback',cb_Pus_SigDorC);
        %==================================================================

        % Adding colormap GUI.
        %---------------------
        viewType = dw1dvdrv('get_imgcfs',win_caller);
        if isequal(viewType,'image') && (Lev_Anal<8)
            [pop_pal_caller,mapName,nbColors] = ...
                cbcolmap('get',win_caller,'pop_pal','mapName','nbColors');
            utcolmap('create',win_denoise, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',0, ...
                     'enable','on');
            pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
            set(pop_pal_loc,'UserData',get(pop_pal_caller,'UserData'));
            cbcolmap('set',win_denoise,'pal',{mapName,nbColors});
        end

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx      = 0.08*pos_win(3);
        bdy      = 0.06*pos_win(4);
        ecy      = 0.03*pos_win(4);
        y_graph  = 2*Def_Btn_Height+dy;
        h_graph  = pos_frame0(4)-y_graph;
        w_graph  = pos_frame0(1);
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
        uicontrol('Parent',win_denoise,...
                  'Style','frame',...
                  'Units',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'BackgroundColor',Def_FraBkColor ...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right = y_graph+bdy;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes(...
                'Parent',win_denoise, ...
                'Units',win_units,     ...
                'Position',pos_right,  ...
                'Box','On'             ...
                ); 
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'Visible','off');

        % Displaying the signal.
        %-----------------------
        sig = dw1dfile('sig',win_caller,1);
        axeAct = axe_datas(3);
        curr_color = wtbutils('colors','sig');
        lin_sig = line(...
                       'XData',1:length(sig),...
                       'YData',sig,...
                       'Color',curr_color,...
                       'Parent',axeAct);
        wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axeAct);
        xlim = [1         Sig_Size];
        ylim = [min(sig)  max(sig)];
        if xlim(1)==xlim(2) , xlim = xlim+0.01*[-1 1]; end
        if ylim(1)==ylim(2) , ylim = ylim+0.01*[-1 1]; end
        set(axeAct,'XLim',xlim,'YLim',ylim);
        utthrw1d('set',win_denoise,'handleORI',lin_sig);

        % Displaying original details coefficients.
        %------------------------------------------
        axeAct = axe_datas(2);
        [viewType,hdl_cfs] = dw1dvdrv('get_imgcfs',win_caller);
        [details,set_ylim,ymin,ymax] = dw1dfile('cfs_beg',win_caller,...
                            (1:Lev_Anal),1); %#ok<ASGLU>
        
        if isequal(viewType,'image')
            flagType = 1;
            cfsMode  = [];
            set(win_denoise,'Colormap',get(win_caller,'Colormap'));
            [nul,i_min] = min(abs(details(:))); %#ok<ASGLU>
            if ~isempty(hdl_cfs)
                col_cfs = flipud(get(hdl_cfs,'CData'));
            else
                col_cfs = wcodemat(details,def_nbCodeOfColors,'row',1);
            end
            col_min = col_cfs(i_min);
            col_cfs = flipud(col_cfs);
            cfs_ori = image(col_cfs,'Parent',axeAct,'UserData',col_min);
            clear col_cfs
            levlab = int2str((Lev_Anal:-1:1)');
        else
            flagType = -1;
            hdl_stem = copyobj(hdl_cfs,axeAct);
            set(hdl_stem,'Visible','on');
            cfsMode = get(hdl_stem(1),'UserData');
            levlab  = int2str((1:Lev_Anal)');
            cfs_ori = '';
        end
        set(axeAct,...
              'UserData',cfs_ori,       ...
              'XLim',[1 Sig_Size],      ...
              'YTickLabelMode','manual',...
              'YTick',(1:Lev_Anal),     ...
              'YTickLabel',levlab,      ...
              'YLim',[0.5 Lev_Anal+0.5] ...
              );

        wtitle(getWavMSG('Wavelet:dw1dRF:OriCfs'),'Parent',axeAct);
        wylabel(getWavMSG('Wavelet:dw1dRF:LevNum'),'Parent',axeAct);

        xylim = get(axeAct,{'XLim','YLim'});        
        set(axe_datas(1),'XLim',xylim{1},'YLim',xylim{2});

        % Building axes on the left part.
        %--------------------------------
        ecy_left = ecy/2;
        h_left   = (h_graph-2*bdy-(n_axeleft-1)*ecy_left)/n_axeleft;
        y_left   = y_graph+0.75*bdy;

        axe_left = zeros(1,n_axeleft);
        txt_left = zeros(1,n_axeleft);
        pos_left = [x_left y_left w_left h_left];
        commonProp = {...
           'Parent',win_denoise,...
           'Units',win_units,...
           'Box','On'...
           };
        for k = 1:n_axeleft
            if k~=1
                axe_left(k) = axes(commonProp{:}, ...
                                  'Position',pos_left,...
                                  'XTickLabelMode','manual','XTickLabel',[]); 
            else
                axe_left(k) = axes(commonProp{:},'Position',pos_left); 
            end
            pos_left(2) = pos_left(2)+pos_left(4)+ecy_left;

            txt_left(k) = txtinaxe('create',['d' wnsubstr(k)],...
                                    axe_left(k),'left',...
                                    'on','bold',fontsize);
        end
        utthrw1d('set',win_denoise,'axes',axe_left);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,Lev_Anal);
        for k = 1:Lev_Anal , maxTHR(k) = max(abs(details(k,:))); end
        valTHR = dw1ddeno('compute_LVL_THR',win_denoise,win_caller);
        valTHR = min(valTHR,maxTHR);

        % Displaying details.
        %-------------------
        col_det = wtbutils('colors','det',Lev_Anal);
        lin_cfs = zeros(Lev_Anal,1);
        for k = Lev_Anal:-1:1
            axeAct  = axe_left(ind_left);
            lin_cfs(k) = line(...
                             'Parent',axeAct,...
                             'XData',1:Sig_Size,...
                             'YData',details(k,:),...
                             'Color',col_det(k,:));
            utthrw1d('plot_dec',win_denoise,k, ...
                     {maxTHR(k),valTHR(k),1,Sig_Size,k})
            maxi = max([abs(ymax(k)),abs(ymin(k))]);
            if abs(maxi)<eps , maxi = maxi+0.01; end
            ylim = 1.1*[-maxi maxi];
            set(axe_left(ind_left),'XLim',xlim,'YLim',ylim);
            ind_left = ind_left-1;
        end
        axeAct = axe_left(Lev_Anal);
        wtitle(getWavMSG('Wavelet:dw1dRF:OriDetCfs'),'Parent',axeAct);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_datas(1:3) axe_left(1:n_axeleft)];
        axe_act = [];
        axe_cfs = axe_datas(1:2);
        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 0], ...
                        '','','dw1dcoor',...
                        [double(win_caller),double(axe_cfs),...
                        flagType*Lev_Anal]);

        % Initialization of  Denoising structure.
        %----------------------------------------
        xmin = 1; xmax = Sig_Size;
        utthrw1d('set',win_denoise,...
                       'thrstruct',{xmin,xmax,valTHR,lin_cfs},...
                       'intdepthr',[]);


        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_denoise,n_misc_loc,    ...
                       ind_sav_menus,sav_menus,   ...
                       ind_status,0,              ...
                       ind_win_caller,win_caller, ...
                       ind_axe_datas,axe_datas,   ...
                       ind_cfsMode,cfsMode,       ...
                       ind_lin_cfs,lin_cfs        ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);

        % End waiting.
        %-------------
        utthrw1d('Enable',win_denoise,'on',(1:Lev_Anal));
        set(win_denoise,'Visible','On');
        wwaiting('off',win_denoise);

    case 'denoise'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        % Clear & Get Handles.
        %----------------------
        dw1ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Getting memory blocks.
        %-----------------------
        [Wav_Name,Lev_Anal] = wmemtool('rmb',win_caller,n_param_anal, ...
                                       ind_wav_name,ind_lev_anal);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs, ...
                                       ind_coefs,ind_longs);


        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        cxc = utthrw1d('den_M2',win_denoise,coefs,longs);
        lxc = longs;
        xc  = waverec(cxc,longs,Wav_Name);

        % Displaying denoised signal.
        %----------------------------
        lin_den = utthrw1d('get',win_denoise,'handleTHR');
        if ishandle(lin_den)
            set(lin_den,'YData',xc,'Visible','on');
        else
            curr_color = wtbutils('colors','ssig');
            lin_den = line(...
                           'Parent',axe_datas(3), ...
                           'XData',1:length(xc),  ...
                           'YData',xc,            ...
                           'Color',curr_color,    ...
                           'LineWidth',2          ...
                           );
            utthrw1d('set',win_denoise,'handleTHR',lin_den);
        end     
        wtitle(getWavMSG('Wavelet:dw1dRF:OS_DS'),'Parent',axe_datas(3));

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_denoise,n_misc_loc,ind_cfsMode);
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

        % Memory blocks update.
        %----------------------
        thrStruct = utthrw1d('get',win_denoise,'thrstruct');
        thrParams = {thrStruct(1:Lev_Anal).thrParams};
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value,{xc,cxc,lxc,thrParams});
        dw1ddeno('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa] = utthrw1d('get_LVL_par',win_denoise); %#ok<ASGLU>
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        varargout{1} = wthrmngr('dw1ddenoLVL',meth,coefs,longs,alfa);

    case 'update_LVL_meth'
        dw1ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = dw1ddeno('compute_LVL_THR',win_denoise,win_caller);
        utthrw1d('update_LVL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_denoise,n_misc_loc,ind_status);
        if status == 0 , return; end

        % Disable Toggle and Menus.
        %--------------------------
        dw1ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        lin_den = utthrw1d('get',win_denoise,'handleTHR');
        if ~isempty(lin_den)
           vis = get(lin_den,'Visible');
           if strcmp(vis,'on')
               set(findobj(axe_datas(1)),'Visible','off');
               wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axe_datas(3));
               set(lin_den,'Visible','off');
           end
        end

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_denoise,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);        
        utthrw1d('enable_tog_res',win_denoise,enaVal);     
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

    case 'save_synt'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                       '*.mat',getWavMSG('Wavelet:commongui:SaveDenSig'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        xc = thrDATA{1}; %#ok<NASGU>
        thrParams = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          saveStr = name;
          eval([saveStr '= xc ;']);
        catch %#ok<*CTCH>
          saveStr = 'xc';
        end
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr,'thrParams','wname');
        catch          
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                            '*.mat',getWavMSG('Wavelet:dw1dRF:Save1DCfs'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveCfs'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        longs = thrDATA{3}; %#ok<NASGU>
        thrParams = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs','thrParams','wname'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch          
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.wa1',getWavMSG('Wavelet:dw1dRF:SaveAnal_1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [wave_name,data_name] = wmemtool('rmb',win_caller,n_param_anal, ...
                            ind_wav_name,ind_sig_name); %#ok<ASGLU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        longs = thrDATA{3}; %#ok<NASGU>
        thrParams = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs','thrParams','wave_name','data_name'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch          
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if isempty(status) , status = 0; end
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_denoise,...
                         getWavMSG('Wavelet:commongui:UpdateSS'),2,'cond');
        end
        switch status
          case 1
            wwaiting('msg',win_denoise, ...
                getWavMSG('Wavelet:commongui:WaitCompute'));
            thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
            valTHR  = thrDATA{4};
            lin_den = utthrw1d('get',win_denoise,'handleTHR');
            wmemtool('wmb',win_caller,n_param_anal,...
                     ind_ssig_type,'ds',ind_thr_val,valTHR);
            dw1dmngr('return_deno',win_caller,status,lin_den);
            wwaiting('off',win_denoise);

          case 0 , dw1dmngr('return_deno',win_caller,status);
        end
        varargout{1} = status;

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
