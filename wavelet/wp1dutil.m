function wp1dutil(option,win_wptool,in3,in4)
%WP1DUTIL Wavelet packets 1-D utilities.
%   WP1DUTIL(OPTION,WIN_WPTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.12.4.9 $ $Date: 2013/07/05 04:30:51 $

% Default values.
%----------------
max_lev_anal = 12;

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
ind_act_option = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
% ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
% ind_nb_colors = 6;
% nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_m_exp_wrks = 'm_exp_wrks';
tag_pus_anal  = 'Pus_Anal';
tag_pus_deno  = 'Pus_Deno';
tag_pus_comp  = 'Pus_Comp';
tag_pus_btree = 'Pus_Btree';
tag_pus_blev  = 'Pus_Blev';
tag_inittree  = 'Pus_InitTree';
tag_wavtree   = 'Pus_WavTree';
tag_curtree   = 'Pop_CurTree';
tag_nodlab    = 'Pop_NodLab';
tag_nodact    = 'Pop_NodAct';
tag_nodsel    = 'Pus_NodSel';
% tag_txt_full  = 'Txt_Full';
tag_pus_full  = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
tag_pop_colm  = 'Txt_PopM';
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

% Miscellaneous values.
%----------------------
children    = get(win_wptool,'Children');
axe_handles = findobj(children,'flat','Type','axes');
uic_handles = findobj(children,'flat','Type','uicontrol');
pop_handles = findobj(uic_handles,'Style','popupmenu');
pus_handles = findobj(uic_handles,'Style','pushbutton');
[m_files,m_save] = wfigmngr('getmenus',win_wptool,'file','save');
m_exp_wrks  = findobj(m_files,'Tag',tag_m_exp_wrks);
m_SAV_EXP   = [m_save,m_exp_wrks];

pus_anal     = findobj(pus_handles,'Tag',tag_pus_anal);
pus_deno     = findobj(pus_handles,'Tag',tag_pus_deno);
pus_comp     = findobj(pus_handles,'Tag',tag_pus_comp);
pus_inittree = findobj(pus_handles,'Tag',tag_inittree);
pus_wavtree  = findobj(pus_handles,'Tag',tag_wavtree);
pus_btree    = findobj(pus_handles,'Tag',tag_pus_btree);
pus_blev     = findobj(pus_handles,'Tag',tag_pus_blev);
pop_curtree  = findobj(pop_handles,'Tag',tag_curtree);
pop_nodlab   = findobj(pop_handles,'Tag',tag_nodlab);
pop_nodact   = findobj(pop_handles,'Tag',tag_nodact);

nbPUS = size(tag_pus_full,1);
pus_full = zeros(1,nbPUS);
for k =1:nbPUS
    pus_full(k) = (findobj(pus_handles,'Tag',tag_pus_full(k,:)))';
end
pop_colm    = findobj(pop_handles,'Tag',tag_pop_colm);
pus_nodsel  = findobj(pus_handles,'Tag',tag_nodsel);

WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
WP_Axe_Col  = findobj(axe_handles,'flat','Tag',tag_axe_col);

option = lower(option);
switch option
    case 'clean'
        % in3 = type of loading.
        %-----------------------
        % 'load_sig' , 'load_dec' , 'demo'
        %----------------------------------
        if nargin<4 , in4 = ''; end

        str_btn = getWavMSG('Wavelet:commongui:Str_Anal');
        cba_btn = @(~,~)wp1dmngr('anal', win_wptool);
        set(pus_anal,'String',str_btn,'Callback',cba_btn);

        % Testing first use.
        %-------------------
        active_option = wmemtool('rmb',win_wptool,n_param_anal, ...
                                                        ind_act_option);
        if isempty(active_option)
            first = 1;
        else
            first = 0;
        end

        % End of Cleaning when first is true.
        %------------------------------------
        if first , return; end

        % Setting enable property of objects.
        %------------------------------------
        set(m_SAV_EXP,'Enable','Off');
        cbanapar('Enable',win_wptool,'off');
        utentpar('Enable',win_wptool,'off');
        set([pus_anal,     pus_deno,       pus_comp,    ...
             pus_inittree, pus_wavtree,                 ...
             pus_btree,    pus_blev,       pop_curtree, ...
             pop_nodlab,   pop_nodact,     pus_nodsel,  ...
             pus_full,     pop_colm                     ...
             ],...
                'Enable','off'...
                );

        % Cleaning DynVTool.
        %-------------------
        dynvtool('stop',win_wptool);

        % Cleaning Axes.
        %--------------
        wpfullsi('clean',win_wptool);

        axe_hld = [WP_Axe_Tree,WP_Axe_Cfs,WP_Axe_Pack];
        if ~strcmp(in4,'new_anal')
            axe_hld = [axe_hld , WP_Axe_Sig, WP_Axe_Col];
            cleanaxe(axe_hld);
        else
            xlab    = get(WP_Axe_Cfs,'xlabel');
            strxlab = get(xlab,'String');
            titl    = get(WP_Axe_Cfs,'title');
            strtitl = get(titl,'String');
            cleanaxe(axe_hld);       
            wtitle(strtitl,'Parent',WP_Axe_Cfs,'Visible','on');
            wxlabel(strxlab,'Parent',WP_Axe_Cfs,'Visible','off')
        end
        wmemtool('wmb',win_wptool,n_wp_utils,...
                        ind_tree_lin,[],ind_tree_txt,[],ind_sel_nodes,[]);
        % Cleaning GUI.
        %--------------
        set(pop_nodlab,'Value',1,'UserData',1);
        set(pop_nodact,'Value',1,'UserData',1);
        if ~strcmp(in4,'new_anal')
            str_lev_data = int2str((1:max_lev_anal)');
            cbanapar('set',win_wptool,...
                'nam','',             ...
                'wav','haar',         ...
                'lev',{'String',str_lev_data,'Value',1});
            utentpar('clean',win_wptool);
        end

    case 'set_gui'
        % in3 = calling option.
        %----------------------
        switch in3
            case 'load_sig'
                [Sig_Name,Sig_Size] = ...
                        wmemtool('rmb',win_wptool,n_param_anal,...
                                        ind_sig_name,ind_sig_size);
                Sig_Size  = max(Sig_Size);
                levm      = wmaxlev(Sig_Size,'haar');
                levmax    = min(levm,max_lev_anal);
                str_lev_data = int2str((1:levmax)');
                cbanapar('set',win_wptool,...
                    'n_s',{Sig_Name,Sig_Size},  ...
                    'lev',{'String',str_lev_data,'Value',min(levmax,3)});

            case {'demo','load_dec'}
                [Sig_Name,Sig_Size,Wav_Name,Lev_Anal,...
                        Ent_Name,Ent_Par] = ...
                        wmemtool('rmb',win_wptool,n_param_anal,   ...
                                       ind_sig_name,ind_sig_size, ...
                                       ind_wav_name,ind_lev_anal, ...
                                       ind_ent_anal,ind_ent_par);
                Sig_Size  = max(Sig_Size);
                levm   = fix(log(Sig_Size)/log(2))-1;
                levmax = min(levm,max_lev_anal);
                str_lev_data = int2str((1:levmax)');
                cbanapar('set',win_wptool,...
                    'n_s',{Sig_Name,Sig_Size}, ...
                    'wav',Wav_Name, ...
                    'lev',{'String',str_lev_data,'Value',Lev_Anal});
                utentpar('set',win_wptool,'ent',{Ent_Name,Ent_Par});

            case 'anal'

         end
        switch in3
            case {'load_sig','demo','load_dec'}
                pos_g = wmemtool('rmb',win_wptool,n_wp_utils,ind_gra_area);
                [nul, nul, nul, nul, pos_sli_size, pos_sli_pos] = ...
                                wpposaxe(win_wptool,1,pos_g); %#ok<ASGLU>
                sli_handles    = findobj(uic_handles,'Style','slider');
                WP_Slider_Size = findobj(sli_handles,'Tag',tag_sli_size);
                WP_Slider_Pos  = findobj(sli_handles,'Tag',tag_sli_pos);
                set(WP_Slider_Size,'Position',pos_sli_size);
                set(WP_Slider_Pos,'Position',pos_sli_pos);
        end

    case 'enable'
        % in3 = calling option.
        %----------------------
        switch in3
            case {'load_sig','demo','load_dec'}
                cbanapar('Enable',win_wptool,'on');
                utentpar('Enable',win_wptool,'on');
                set(pus_anal,'Enable','On');
        end
        switch in3
            case {'demo','load_dec','anal','synt'}
                cbcolmap('Enable',win_wptool,'on');
                set([pus_deno,    pus_comp,     pus_btree,   ...
                     pus_blev,    pus_inittree, pus_wavtree, ...
                     pop_curtree, pop_nodlab,   pop_nodact,  ...
                     pus_nodsel,  pus_full,     pop_colm     ...
                     ],      ...
                     'Enable','on'...
                     );
                set(m_SAV_EXP,'Enable','on');

            case {'comp','deno'}
                set([m_files, pus_anal, pus_deno, pus_comp],'Enable','off');

            case {'return_comp','return_deno'}
                set([m_files, pus_anal, pus_deno, pus_comp],'Enable','on');
        end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
