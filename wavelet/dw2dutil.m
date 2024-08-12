function dw2dutil(option,win_dw2dtool,in3,varargin) %#ok<VANUS>
%DW2DUTIL Discrete wavelet 2-D utilities.
%   DW2DUTIL(OPTION,WIN_DW2DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.14.4.9 $ $Date: 2013/07/05 04:30:07 $

% Get Globals.
%-------------
[Def_AxeFontSize, Def_FraBkColor] = ...
    mextglob('get','Def_AxeFontSize','Def_FraBkColor');

% Default values.
%----------------
max_lev_anal = 8;
default_nbcolors = 128;

% Tag property of objects.
%-------------------------
tag_m_exp_wrks = 'm_exp_wrks';
tag_pus_anal   = 'Pus_Anal';
tag_pus_deno   = 'Pus_Deno';
tag_pus_comp   = 'Pus_Comp';
tag_pus_hist   = 'Pus_Hist';
tag_pus_stat   = 'Pus_Stat';
tag_pop_declev = 'Pop_DecLev';
tag_pus_visu   = 'Pus_Visu';
tag_pus_big    = 'Pus_Big';
tag_pus_rec    = 'Pus_Rec';
tag_pop_viewm  = 'Pop_ViewM';
tag_pus_full   = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];

% tag_btnaxeset  = 'Btn_Axe_Set';
tag_axefigutil = 'Axe_FigUtil';
tag_linetree   = 'Tree_lines';
tag_txttree    = 'Tree_txt';
tag_axeimgbig  = 'Axe_ImgBig';
tag_axeimgini  = 'Axe_ImgIni';
tag_axeimgvis  = 'Axe_ImgVis';
tag_axeimgsel  = 'Axe_ImgSel';
tag_axeimgdec  = 'Axe_ImgDec';
tag_axeimgsyn  = 'Axe_ImgSyn';
tag_axeimghdls = 'Img_Handles';
% tag_imgdec     = 'Img_Dec';

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn2d_Par_Anal';
% ind_img_name   = 1;
% ind_wav_name   = 2;
ind_lev_anal   = 3;
% ind_img_t_name = 4;
ind_img_size   = 5;
% ind_nbcolors   = 6;
ind_act_option = 7;
% ind_simg_type  = 8;
% ind_thr_val    = 9;
nb1_stored     = 9;

% MemBloc3 of stored values.
%---------------------------
n_miscella      = 'DWAn2d_Miscella';
ind_graph_area  =  1;
ind_pos_axebig  =  2;
ind_pos_axeini  =  3;
ind_pos_axevis  =  4;
ind_pos_axedec  =  5;
ind_pos_axesyn  =  6;
ind_pos_axesel  =  7;
ind_view_status =  8;
ind_save_status =  9;
% ind_sel_funct   = 10;
% nb3_stored      = 10;

% Miscellaneous values.
%----------------------
square_viewm = 1;
% tree_viewm   = 2;

% View Status
%--------------------------------------------------------%
% 'none' : init
% 's_l*' : square        * = lev_dec (1 --> Level_Anal)
% 'f1l*' : full ini      * = lev_dec (1 --> Level_Anal)
% 'f2l*' : full syn      * = lev_dec (1 --> Level_Anal)
% 'f3l*' : full vis      * = lev_dec (1 --> Level_Anal)
% 'f4l*' : full dec      * = lev_dec (1 --> Level_Anal)
% 'b*l*' : big
%                first   * = index   (1 --> 4*Level_Anal)
%                second  * = lev_dec (1 --> Level_Anal)
% 't_l*' : tree          * = lev_dec (1 --> Level_Anal)
%--------------------------------------------------------%

% Handles of tagged objects.
%---------------------------
children    = get(win_dw2dtool,'Children');
uic_handles = findobj(children,'flat','Type','uicontrol');
axe_handles = findobj(children,'flat','Type','axes');
% txt_handles = findobj(uic_handles,'Style','text');
pop_handles = findobj(uic_handles,'Style','popupmenu');
pus_handles = findobj(uic_handles,'Style','pushbutton');

[m_files,m_save] = wfigmngr('getmenus',win_dw2dtool,'file','save');
m_exp_wrks  = findobj(m_files,'Tag',tag_m_exp_wrks);
m_SAV_EXP   = [m_save,m_exp_wrks];

pus_anal    = findobj(pus_handles,'Tag',tag_pus_anal);
pus_deno    = findobj(pus_handles,'Tag',tag_pus_deno);
pus_comp    = findobj(pus_handles,'Tag',tag_pus_comp);
pus_hist    = findobj(pus_handles,'Tag',tag_pus_hist);
pus_stat    = findobj(pus_handles,'Tag',tag_pus_stat);
pop_declev  = findobj(pop_handles,'Tag',tag_pop_declev);
pus_visu    = findobj(pus_handles,'Tag',tag_pus_visu);
pus_big     = findobj(pus_handles,'Tag',tag_pus_big);
pus_rec     = findobj(pus_handles,'Tag',tag_pus_rec);
pop_viewm   = findobj(pop_handles,'Tag',tag_pop_viewm);
nbPus = size(tag_pus_full,1);
pus_full = zeros(1,nbPus);
for k =1:nbPus
    pus_full(k) = findobj(pus_handles,'Tag',tag_pus_full(k,:));
end

Axe_ImgBig = findobj(axe_handles,'flat','Tag',tag_axeimgbig);
Axe_ImgIni = findobj(axe_handles,'flat','Tag',tag_axeimgini);
Axe_ImgVis = findobj(axe_handles,'flat','Tag',tag_axeimgvis);
Axe_ImgSel = findobj(axe_handles,'flat','Tag',tag_axeimgsel);
Axe_ImgSyn = findobj(axe_handles,'flat','Tag',tag_axeimgsyn);

option = lower(option);
switch option
    case 'clean'
        % in3 = load option
        % in4 optional ('new_synt')
        %---------------------------
        if nargin==3 , init = 1; else init = 0; end
        if init==1
            % in3 = type of loading.
            %-----------------------
            % 'load_img' , 'load_dec'
            % 'load_cfs' , 'demo'    
            %-----------------------
            if strcmp(in3,'load_cfs')
                str_btn = getWavMSG('Wavelet:commongui:Str_Synt');
                cba_btn = @(~,~)dw2dmngr('synthesize', win_dw2dtool );
            else
                str_btn = getWavMSG('Wavelet:commongui:Str_Anal');
                cba_btn = @(~,~)dw2dmngr('analyze', win_dw2dtool);
            end
            set(pus_anal,'String',str_btn,'Callback',cba_btn);
        end

        % Testing first use.
        %--------------------
        active_option = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_act_option);
        if strcmp(active_option,'create') , first = 1; else first = 0; end

        % Cleaning stored values.
        %------------------------
        if init==1 , wmemtool('ini',win_dw2dtool,n_param_anal,nb1_stored); end

        % End of Cleaning when first is true.
        %------------------------------------
        if first , return; end

        % Cleaning axes.
        %---------------
        dw2dimgs('clean',win_dw2dtool);
        wmemtool('wmb',win_dw2dtool,tag_axeimghdls,1,[]);

        Axe_ImgDec = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
        cleanaxe([Axe_ImgIni,Axe_ImgVis,Axe_ImgSyn,...
                  Axe_ImgSel,Axe_ImgBig,Axe_ImgDec(:)']);
        set([Axe_ImgIni,Axe_ImgVis,Axe_ImgSel, ...
             Axe_ImgSyn,Axe_ImgDec,Axe_ImgBig],...
             'Visible','Off');
        bdy = 18;
        wboxtitl('set',Axe_ImgSel,getWavMSG('Wavelet:dw2dRF:Img_SEL'),...
            Def_AxeFontSize,9,18,bdy,'off');

        axe_figutil = findobj(win_dw2dtool,              ...
                                    'Type','axes',       ...
                                    'Tag',tag_axefigutil ...
                                    );
        t_lines     = findobj(axe_figutil,               ...
                                    'Type','line',       ...
                                    'Tag',tag_linetree   ...
                                    );
        t_txt       = findobj(axe_figutil,               ...
                                    'Type','text',       ...
                                    'Tag',tag_txttree    ...
                                    );

        set([t_lines' t_txt'],'Visible','off');
        dw2darro('clean',win_dw2dtool,'off');
        drawnow;

        % Setting enable property of objects.
        %------------------------------------
        set(m_SAV_EXP,'Enable','Off');
        cbanapar('Enable',win_dw2dtool,'off');
        cbcolmap('Enable',win_dw2dtool,'off');
        set([...
             pus_anal,   pus_deno,           ...
             pus_comp,   pus_hist, pus_stat, ...
             pop_declev, pus_big,            ...
             pus_visu,   pus_rec,  pus_big,  ...
             pus_full,   pop_viewm ],...
             'Enable','off'...
             );

        % Cleaning DynVTool.
        %-------------------
        dynvtool('stop',win_dw2dtool);
        if init==1
            % Setting string property of objects.
            %------------------------------------
            str_lev_data    = int2str((1:max_lev_anal)');
            cbanapar('set',win_dw2dtool,...
                'nam','',             ...
                'wav','haar',         ...
                'lev',{'String',str_lev_data,'Value',1})
            set(pop_declev,'String',str_lev_data,'Value',1);
        end

        % Cleaning buttons.
        %------------------
        val = get(pop_viewm,'Value');
        pos = zeros(4,4);
        pos(1,:) = get(pus_full(1),'Position');
        if val~=square_viewm
            pos(1,3) = (3*pos(1,3))/2;
            pos(2,:) = pos(1,:); pos(2,2) = pos(2,2)-pos(2,4);
            pos(3,:) = pos(1,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(3,:);
            pos(4,2) = pos(4,2)-pos(4,4);
            set(pus_full,'Visible','off'); drawnow;
            for num=1:4
                set(pus_full(num),...
                        'Position',pos(num,:),...
                        'BackgroundColor',Def_FraBkColor,...
                        'String',sprintf('%.0f',num),...
                        'UserData',0);
            end
            set(pus_full,'Visible','on'); drawnow;
        else
            for num=1:length(pus_full)
                set(pus_full(num),...
                        'BackgroundColor',Def_FraBkColor,...
                        'String',sprintf('%.0f',num),...               
                        'UserData',0);
            end
        end
        set(pop_viewm,'Value',square_viewm);
        cba_pus_big = @(~,~)dw2dmngr('select', win_dw2dtool, pus_big);
        set(pus_big,...
                'String',getWavMSG('Wavelet:dw2dRF:Str_Big'),  ...
                'BackgroundColor',Def_FraBkColor,...
                'Callback',cba_pus_big);


        % Cleaning miscellaneous parameters.
        %-----------------------------------
        wmemtool('wmb',win_dw2dtool,n_miscella, ...
                       ind_view_status,'none',ind_save_status,'none');
        if init==1
            cbcolmap('set',win_dw2dtool,'pal',{'pink',default_nbcolors})
        end

    case 'clean2'
        % in3 = calling option
        %------------------
        % Cleaning axes.
        %---------------
        dw2dimgs('clean',win_dw2dtool);
        wmemtool('wmb',win_dw2dtool,tag_axeimghdls,1,[]);
        Axe_ImgDec = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
        cleanaxe([Axe_ImgVis,Axe_ImgSyn,Axe_ImgSel,Axe_ImgBig,Axe_ImgDec(:)']);
        set([Axe_ImgVis,Axe_ImgSel,Axe_ImgSyn,Axe_ImgDec,Axe_ImgBig],...
             'Visible','Off');
        wboxtitl('set',Axe_ImgSel,getWavMSG('Wavelet:dw2dRF:Img_SEL'),...
            Def_AxeFontSize,9,18,22,'off');

        axe_figutil = findobj(win_dw2dtool, ...
            'Type','axes',       ...
            'Tag',tag_axefigutil ...
            );
        t_lines     = findobj(axe_figutil, ...
            'Type','line',       ...
            'Tag',tag_linetree   ...
            );
        t_txt       = findobj(axe_figutil, ...
            'Type','text',       ...
            'Tag',tag_txttree    ...
            );

        set([t_lines' t_txt'],'Visible','off');
        dw2darro('clean',win_dw2dtool,'on');
        dw2dutil('pos_axe_init',win_dw2dtool,option);
        drawnow;

        % Cleaning buttons.
        %------------------
        val = get(pop_viewm,'Value');
        pos = zeros(4,4);
        pos(1,:) = get(pus_full(1),'Position');
        if val~=square_viewm
            pos(1,3) = (3*pos(1,3))/2;
            pos(2,:) = pos(1,:); pos(2,2) = pos(2,2)-pos(2,4);
            pos(3,:) = pos(1,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(3,:);
            pos(4,2) = pos(4,2)-pos(4,4);
            set(pus_full,'Visible','off'); drawnow;
            for num=1:4
                set(pus_full(num),...
                        'Position',pos(num,:),...
                        'BackgroundColor',Def_FraBkColor,...
                        'String',sprintf('%.0f',num),...
                        'UserData',0);
            end
            set(pus_full,'Visible','on'); drawnow;
        else
            for num=1:length(pus_full)
                set(pus_full(num),...
                        'BackgroundColor',Def_FraBkColor,...
                        'String',sprintf('%.0f',num),...               
                        'UserData',0);
            end
        end
        set(pop_viewm,'Value',square_viewm);

        % Cleaning miscellaneous parameters.
        %-----------------------------------
        wmemtool('wmb',win_dw2dtool,n_miscella, ...
                       ind_view_status,'none',ind_save_status,'none');

    case 'enable'
        % in3 = calling option.
        %----------------------
        TST_vis_UTCOLMAP_FLAG = false;
        switch in3
            case {'load_img','demo','load_cfs'}
                cbanapar('Enable',win_dw2dtool,'on');
                cbcolmap('Enable',win_dw2dtool,'on');
                set(pus_anal,'Enable','on');
                dw2darro('set_arrow',win_dw2dtool,in3);
                TST_vis_UTCOLMAP_FLAG = true;
        end

        switch in3
            case {'demo','analyze','synthesize'}
                set([pus_deno, pus_comp,   pus_stat,   ...
                    pus_hist, pop_declev,             ...
                    pus_visu, pus_rec,                ...
                    pus_big , pus_full,   pop_viewm], ...
                    'Enable','On'   ...
                    );
                set(m_SAV_EXP,'Enable','on');

            case 'load_dec'
                cbanapar('Enable',win_dw2dtool,'on');
                cbcolmap('Enable',win_dw2dtool,'on');
                set([pus_anal, pus_deno,   pus_comp, pus_stat, ...
                    pus_hist, pop_declev, pus_visu, pus_rec , ...
                    pus_big,  pop_viewm,  pus_full] ,...
                    'Enable','On'   ...
                    );
                dw2darro('set_arrow',win_dw2dtool,in3);
                set(m_SAV_EXP,'Enable','on');
                TST_vis_UTCOLMAP_FLAG = true;

            case {'comp','deno'}
                set([m_files,pus_anal,pus_deno,pus_comp],'Enable','off');

            case {'return_comp','return_deno'}
                set([m_files,pus_anal,pus_deno,pus_comp],'Enable','on');
        end       
                
        % To manage colormap tool for truecolor images
        vis_UTCOLMAP = 'On';
        if TST_vis_UTCOLMAP_FLAG
            img_Size = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_img_size);
            if length(img_Size)>2 , vis_UTCOLMAP = 'Off'; end
            cbcolmap('Visible',win_dw2dtool,vis_UTCOLMAP);
        end
        wtbxappdata('set',win_dw2dtool,'vis_UTCOLMAP',vis_UTCOLMAP);

    case 'pos_axe_init'
        % in3 = calling option.
        %--------------------------

        % Getting Analysis parameters.
        %-----------------------------
        [Image_Size,Level_Anal] = wmemtool('rmb',win_dw2dtool,n_param_anal,...
                                                ind_img_size,ind_lev_anal);
        level       = cbanapar('get',win_dw2dtool,'lev');
        Axe_ImgDec  = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);

        % Getting position parameters.
        %-----------------------------
        pos      = wmemtool('rmb',win_dw2dtool,n_miscella,ind_graph_area);

        % View boundary parameters.
        %--------------------------
        mxbig = 0.83; mybig = 0.83;
        mx    = 0.75; my    = 0.75;

        % Computing axes positions.
        %--------------------------
        cent_one = [ pos(1)+pos(3)/2 , pos(2)+pos(4)/2 ];
        w_pos   = pos(3)*mxbig;         h_pos   = pos(4)*mybig;
        [w_one,h_one] = wpropimg(Image_Size,w_pos,h_pos);

        pos_axebig = [cent_one(1)-w_one/2 ,...
                      cent_one(2)-h_one/2 ,...
                      w_one               ,...
                      h_one];

        NBL = 2; NBC = 2;
        w_theo = pos(3)/NBC;  h_theo = pos(4)/NBL;
        w_pos   = w_theo*mx;  h_pos   = h_theo*my;
        X_cent = pos(1)+(w_theo/2)*(1:2:2*NBC-1);
        Y_cent = pos(2)+(h_theo/2)*(1:2:2*NBL-1);
        [w_used,h_used] = wpropimg(Image_Size,w_pos,h_pos);
        w_u2 = w_used/2;     h_u2 = h_used/2;

        pos_axeini = [X_cent(1)-w_u2,Y_cent(2)-h_u2,w_used,h_used];
        pos_axevis = [X_cent(2)-w_u2,Y_cent(2)-h_u2,w_used,h_used];
        pos_axesyn = [X_cent(1)-w_u2,Y_cent(1)-h_u2,w_used,h_used];
        pos_axesel = [X_cent(2)-w_u2,Y_cent(1)-h_u2,w_used,h_used];
        xl = pos_axesel(1);             yb = pos_axesel(2);
        la = pos_axesel(3)/2;           ha = pos_axesel(4)/2;
        ind = 1;
        for k = 1:max_lev_anal
            pos_axedec(ind:ind+3,1:4) = ...
                    [xl      ,yb     ,la     ,ha;
                     xl+la   ,yb     ,la     ,ha;
                     xl+la   ,yb+ha  ,la     ,ha;
                     xl      ,yb+ha  ,la     ,ha ...
                    ];
            ind = ind+4;
            yb = yb+ha;    la = la/2;     ha = ha/2;
        end

        % Axes visibility.
        %-----------------
        if isempty(Level_Anal) , Level_Anal = level; end 
        max_a = 4*Level_Anal;
        index = 1:max_a;
        rem_4 = rem(index,4);
        if strcmp(in3,'load_img')
            ind_On = [];
        else
            ind_On  = [find(index<max_a & rem_4~=0) , max_a];
        end

        % Setting axes.
        %--------------
        xlim = [1 Image_Size(1)];
        ylim = [1 Image_Size(2)];
        set([Axe_ImgIni,Axe_ImgVis,Axe_ImgSyn,Axe_ImgSel],'Visible','On');
        set(Axe_ImgIni,...
                'Visible','On','Position',pos_axeini, ...
                'XLim',xlim,'YLim',ylim               ...
                );
        set(Axe_ImgVis,...
                'Visible','On','Position',pos_axevis, ...
                'XLim',xlim,'YLim',ylim               ...
                );
        set(Axe_ImgSyn,...
                'Visible','On','Position',pos_axesyn, ...
                'XLim',xlim,'YLim',ylim               ...
                );
        set(Axe_ImgSel,...
                'Visible','on','Position',pos_axesel, ...
                'XLim',xlim,'YLim',ylim...
                );
        for k = 1:4*max_lev_anal
            set(Axe_ImgDec(k),...
                    'Position',pos_axedec(k,:),...
                    'XLim',xlim,'YLim',ylim);
        end
        set(Axe_ImgDec(ind_On),'Visible','On');
        set(Axe_ImgBig,'Position',pos_axebig,'XLim',xlim,'YLim',ylim);

        % Axes Titles.
        %-------------
        if strcmp(in3,'load_cfs')
            wtitle(getWavMSG('Wavelet:dw2dRF:Ini_Img_None'),'Parent',Axe_ImgIni);
        else
            wtitle(getWavMSG('Wavelet:dw2dRF:Ori_Img'),'Parent',Axe_ImgIni);
        end
        wtitle(getWavMSG('Wavelet:dw2dRF:Syn_Img'),'Parent',Axe_ImgSyn);
        wsetxlab(Axe_ImgSel,getWavMSG('Wavelet:dw2dRF:DecAtLev','...'));
        wboxtitl('pos',Axe_ImgSel,'on');

        % Storing axes positions.
        %------------------------
        wmemtool('wmb',win_dw2dtool,n_miscella,   ...
                       ind_pos_axeini,pos_axeini, ...
                       ind_pos_axevis,pos_axevis, ...
                       ind_pos_axesel,pos_axesel, ...
                       ind_pos_axesyn,pos_axesyn, ...
                       ind_pos_axebig,pos_axebig, ...
                       ind_pos_axedec,pos_axedec  ...
                       );

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
