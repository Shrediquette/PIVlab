function varargout = dw2ddeno(option,varargin)
%DW2DDENO Discrete wavelet 2-D de-noising.
%   VARARGOUT = DW2DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 12-Nov-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.20.4.14.4.1 $ $Date: 2014/01/04 07:40:06 $

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
ind_nbcolors   = 6;
% ind_act_option = 7;
% ind_simg_type  = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.1 and MB2.2.
%-----------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB1 (local).
%-------------
n_misc_loc = 'MB1_dw2ddeno';
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
nbLOC_1_stored = 5;

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
        win_caller = varargin{1};

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:dw2dRF:NamWinDEN_2D');
        [win_denoise,pos_win,win_units,~,pos_frame0] = ...
                 wfigmngr('create',win_name,'',...
                     'ExtFig_CompDeno',{mfilename,'cond'});
        set(win_denoise,'UserData',win_caller,'Tag','DW2DDENO');
        varargout{1} = win_denoise;

		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_denoise,...
            getWavMSG('Wavelet:dw2dRF:HLP_ImgDeno'),'DW2D_DENO_GUI');

		% Add Help Item.
		%---------------
 		wfighelp('addHelpItem',win_denoise, ...
            getWavMSG('Wavelet:dw2dRF:HLP_DenoProc'),'DENO_PROCEDURE');       
		wfighelp('addHelpItem',win_denoise, ...
            getWavMSG('Wavelet:dw2dRF:HLP_AvailMeth'),'COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Den_Img'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2ddeno('save_synt', win_denoise)   ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_Coefficients'),   ...
            'Position',2,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2ddeno('save_cfs', win_denoise)  ...
            );
        sav_menus(3) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_Decomposition'),  ...
            'Position',3,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2ddeno('save_dec', win_denoise)  ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getWavMSG('Wavelet:commongui:GenerateMATLABDenoise'), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('dw2ddeno', win_denoise)  ...
            );
        wtbxappdata('set',win_denoise,'M_GenCode',m_gen);
        

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal] = ...
        wmemtool('rmb',win_caller,n_param_anal, ...
                ind_img_name, ...
                ind_img_size, ...
                ind_wav_name, ...
                ind_lev_anal  ...
                       );

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;

        % To manage colormap tool for truecolor images.
        %----------------------------------------------
        vis_UTCOLMAP = wtbxappdata('get',win_caller,'vis_UTCOLMAP');
        wtbxappdata('set',win_denoise, 'vis_UTCOLMAP',vis_UTCOLMAP);        
        
        % Command part of the window.
        %============================
        comFigProp = {'Parent',win_denoise,'Units',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % denoising tools.
        %-----------------
        ytopTHR = toolPos(2)-4*dy;
        utthrw2d('create',win_denoise, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'Visible','on', ...
                 'enable','on', ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'toolOPT','deno' ...
                 );

        % Adding colormap GUI.
        %---------------------
        briflag = (Lev_Anal<6); 
        if Lev_Anal<9
            pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
            prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
            utcolmap('create',win_denoise, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',briflag, ...
                     'Enable','on');
            pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
            set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                            'UserData',prop_pal{3});
            set(win_denoise,'Colormap',get(win_caller,'Colormap'));
            cbcolmap('Visible',win_denoise,vis_UTCOLMAP);
        end

        % Graphic part of the window.
        %============================
        % Displaying the window title.
        %-----------------------------
        strX = sprintf('%.0f',Img_Size(2));
        strY = sprintf('%.0f',Img_Size(1));
        str_nb_val   = [' (' strX ' x ' strY ')'];
        str_wintitle = getWavMSG('Wavelet:dw2dRF:Str_Win_Title',...
            Img_Name,str_nb_val,Lev_Anal,Wav_Name);
        wfigtitl('String',win_denoise,str_wintitle,'on');
        drawnow

        % Common axes properties.
        %------------------------
        comAxeProp = [...
          comFigProp,    ...
          'Units',win_units,...
          'Box','On',       ...
          'Visible','on'    ...
          ];

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx_l   = 0.10*pos_win(3);
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        w_graph = pos_frame0(1);
        if Lev_Anal<6
            bdy = 0.07*pos_win(4);
            ecy = 0.03*pos_win(4);
            div = 2.5;
        else
            bdy     = 0.06*pos_win(4);
            ecy     = 0.02*pos_win(4);
            div = 3.5;
        end
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;

        % Building axes for original image.
        %----------------------------------
        x_axe           = bdx;
        w_axe           = (w_graph-ecx-3*bdx/2)/2;
        h_axe           = (h_graph-bdy)/div;
        y_axe           = y_graph+h_graph-h_axe-bdy;
        cx_ori          = x_axe+w_axe/2;
        cy_ori          = y_axe+h_axe/2;
        cx_den          = cx_ori+w_axe+ecx;
        cy_den          = cy_ori;
        [w_used,h_used] = wpropimg(Img_Size,w_axe,h_axe,'pixels');
        pos_axe         = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1)    = axes(comAxeProp{:},'Position',pos_axe);
        axe_orig        = axe_datas(1);

        % Displaying original image.
        %---------------------------
        Img_Anal  = get(dw2drwcd('r_orig',win_caller),'CData');
        hdl_datas = [NaN;NaN];
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal, ...
                              'Parent',axe_orig);
        wtitle(getWavMSG('Wavelet:dw2dRF:Ori_Img'),'Parent',axe_orig);

        % Building axes for denoised image.
        %----------------------------------
        pos_axe = [cx_den-w_used/2 cy_den-h_used/2 w_used h_used];
        xylim   = get(axe_orig,{'XLim','YLim'});
        axe_datas(2) = axes(comAxeProp{:},...
                            'Visible','off', ...
                            'Position',pos_axe,'XLim',xylim{1},'YLim',xylim{2});
        axe_deno = axe_datas(2);

        % Building axes for histograms.
        %------------------------------
        x_axe    = bdx;
        y_axe    = y_graph+bdy;
        h_axe    = (h_graph-h_axe-3*bdy-(Lev_Anal-1)*ecy)/Lev_Anal;
        w_axe    = (w_graph-2*ecx-3*bdx/2)/3;
        pos_axe  = [x_axe y_axe w_axe h_axe];
        axe_hist = zeros(3,Lev_Anal);
        for k = 1:Lev_Anal
            pos_axe(1) = bdx_l;
            pos_axe(2) = y_graph+bdy+(k-1)*(h_axe+ecy);
            for direct=1:3
                axe_hist(direct,k) = axes(comAxeProp{:},'Position',pos_axe);
                pos_axe(1) = pos_axe(1)+pos_axe(3)+ecx;
            end
        end
        utthrw2d('set',win_denoise,'axes',axe_hist);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(3,Lev_Anal);
        valTHR = dw2ddeno('compute_LVL_THR',win_denoise,win_caller);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        dirval  = ['h';'d';'v'];
        for d=1:3
            dir = dirval(d);
            for i=Lev_Anal:-1:1
                c   = detcoef2(dir,coefs,sizes,i);
                tmp = max(abs(c(:)));
                if tmp<eps
                    maxTHR(d,i) = 1;
                else
                    maxTHR(d,i) = 1.1*tmp;
                end
            end
        end
        valTHR = min(maxTHR,valTHR);

        % Displaying details coefficients histograms.
        %--------------------------------------------
        dirDef   = 1;
        fontsize = wmachdep('FontSize','normal');
        col_det  = wtbutils('colors','det',Lev_Anal);
        nb_bins  = 50;
        axeXColor = get(win_denoise,'DefaultAxesXColor');        
        for level = 1:Lev_Anal
            for direct=1:3
                axeAct  = axe_hist(direct,level);
                dir     = dirval(direct);
                curr_img   = detcoef2(dir,coefs,sizes,level);
                curr_color = col_det(level,:);
                his        = wgethist(curr_img(:),nb_bins);
                his(2,:)   = his(2,:)/length(curr_img(:));
                wplothis(axeAct,his,curr_color);
                if direct==dirDef
                    txt_hist(direct) = ...
                    txtinaxe('create',['L_' sprintf('%.0f',level)],...
                             axeAct,'left','on',...
                             'bold',fontsize); %#ok<AGROW>
                    set(txt_hist(direct),'Color',axeXColor);
                end
                if level==1
                    xlab = getWavMSG(['Wavelet:dw2dRF:Dir_Det_' dir]);
                    wxlabel(xlab,'Color',axeXColor,'Parent',axeAct);
                end
                thr_val = valTHR(direct,level);
                thr_max = maxTHR(direct,level);
                ylim    = get(axeAct,'YLim');
                utthrw2d('plot_dec',win_denoise,dirDef, ...
                          {thr_max,thr_val,ylim,direct,level,axeAct})
                xmax = 1.1*max([thr_max, max(abs(his(1,:)))]);
                set(axeAct,'XLim',[-xmax xmax]);
                set(findall(axeAct),'Visible','on');
            end
        end
        drawnow

        % Initialization of denoising structure.
        %----------------------------------------
        utthrw2d('set',win_denoise,'valthr',valTHR,'maxthr',maxTHR);

        % Memory blocks update.
        %----------------------
        utthrw2d('set',win_denoise,'handleORI',hdl_datas(1));
        wmemtool('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_denoise,n_misc_loc,   ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas   ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_orig axe_deno];
        axe_act = [];
        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 1],'','','','int');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);
        set(win_denoise,'Visible','On');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'denoise'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Clear & Get Handles.
        %----------------------
        dw2ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        axe_orig = axe_datas(1);
        axe_deno = axe_datas(2);

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Size,Wav_Name,Lev_Anal] = ...
                wmemtool('rmb',win_caller,n_param_anal,...
                               ind_img_size, ...
                               ind_wav_name, ...
                               ind_lev_anal  ...
                               );

        % Getting Analysis values.
        %-------------------------
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);

        % De-noising.
        %------------
        valTHR = utthrw2d('get',win_denoise,'valthr');
        [numMeth,meth,scal,sorh] = utthrw2d('get_LVL_par',win_denoise); %#ok<ASGLU>
        [xc,cxc,lxc] = wdencmp('lvd',coefs,sizes,...
                                      Wav_Name,Lev_Anal,valTHR,sorh);

        % Displaying compressed image.
        %------------------------------
        hdl_deno = hdl_datas(2);
        if ishandle(hdl_deno)
            set(hdl_deno,'CData',wd2uiorui2d('d2uint',xc),'Visible','on');
        else
            hdl_deno = image([1 Img_Size(1)],[1,Img_Size(2)],...
                wd2uiorui2d('d2uint',xc),'Parent',axe_deno);
            hdl_datas(2) = hdl_deno;
            utthrw2d('set',win_denoise,'handleTHR',hdl_deno);
            wmemtool('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        end
        xylim =  get(axe_orig,{'XLim','YLim'});
        set(axe_deno,'XLim',xylim{1},'YLim',xylim{2},'Visible','on');
        wtitle(getWavMSG('Wavelet:commongui:DenoImg'),'Parent',axe_deno);

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value,{xc,cxc,lxc,valTHR});
        dw2ddeno('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa] = utthrw2d('get_LVL_par',win_denoise); %#ok<ASGLU>
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        varargout{1} = wthrmngr('dw2ddenoLVL',meth,coefs,sizes,alfa);
 
    case 'update_LVL_meth'
        dw2ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = dw2ddeno('compute_LVL_THR',win_denoise,win_caller);
        utthrw2d('update_LVL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_denoise,n_misc_loc,ind_status);
        if isempty(status) || isequal(status,0), return; end
 
        % Disable Toggles and Menus.
        %----------------------------
        dw2ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);
        axe_deno = axe_datas(2);

        % Setting compressed axes invisible.
        %-----------------------------------
        set(findobj(axe_deno),'Visible','off');
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_denoise,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);        
        utthrw2d('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

	case 'save_synt'
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Deno_Img'), ...
            win_denoise,X,'wname',wname,'valTHR',valTHR);
        
    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise,'*.mat', ...
                                     getWavMSG('Wavelet:dw2dRF:Save2DCfs'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveCfs'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_param_anal,ind_nbcolors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs  = thrDATA{2}; %#ok<NASGU>
        sizes  = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<*CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise,'*.wa2', ...
                                     getWavMSG('Wavelet:dw2dRF:SaveAnal_2D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [wave_name,data_name,nb_colors] =    ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_nbcolors  ...
                               ); %#ok<ASGLU>
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map) , map = pink(nb_colors); end %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs  = thrDATA{2}; %#ok<NASGU>
        sizes  = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'

        % Returning or not the denoised image in the 2D current analysis.
        %----------------------------------------------------------------
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_denoise,...
                 getWavMSG('Wavelet:commongui:UpdateSI'),2,'cancel');
        end
        switch status
            case 1
                wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));
                thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
                valTHR  = thrDATA{4};
                wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
                hdl_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
                img = hdl_datas(2);
                dw2dmngr('return_deno',win_caller,status,img);
                wwaiting('off',win_denoise);

            case 0
                dw2dmngr('return_deno',win_caller,status);
        end
        varargout{1} = status;

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
