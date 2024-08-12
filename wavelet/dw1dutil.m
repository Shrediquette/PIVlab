function dw1dutil(option,win_dw1dtool,in3,in4)
%DW1DUTIL Discrete wavelet 1-D utilities.
%   DW1DUTIL(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.15.4.11 $ $Date: 2013/07/05 04:30:01 $

% Default values.
%----------------
max_lev_anal = 12;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% Tag property of objects.
%-------------------------
tag_m_exp_wrks  = 'm_exp_wrks';
tag_pus_anal    = 'Pus_Anal';
tag_pus_deno    = 'Pus_Deno';
tag_pus_comp    = 'Pus_Comp';
tag_pus_hist    = 'Pus_Hist';
tag_pus_stat    = 'Pus_Stat';
tag_pop_viewm   = 'View_Mode';
tag_pus_dispopt = 'Pus_Options';
tag_valapp_scr  = 'ValApp_Scr';
tag_valdet_scr  = 'ValDet_Scr';
tag_declev      = 'Pop_DecLev';

% Handles of tagged objects.
%---------------------------
children    = get(win_dw1dtool,'Children');

option = lower(option);
switch option
    case {'clean','enable','set_gui'}
        % Handles of tagged objects.
        %---------------------------
        [m_files,m_save] = wfigmngr('getmenus',win_dw1dtool,'file','save');        
        m_exp_wrks  = findobj(m_files,'Tag',tag_m_exp_wrks);
        m_SAV_EXP   = [m_save,m_exp_wrks];
        uic_handles = findobj(children,'flat','Type','uicontrol');
        pop_handles = findobj(uic_handles,'Style','popupmenu');
        pus_handles = findobj(uic_handles,'Style','pushbutton');
        pus_dispopt = findobj(uic_handles,'Tag',tag_pus_dispopt);
        pus_anal    = findobj(pus_handles,'Tag',tag_pus_anal);
        pus_deno    = findobj(pus_handles,'Tag',tag_pus_deno);
        pus_comp    = findobj(pus_handles,'Tag',tag_pus_comp);
        pus_hist    = findobj(pus_handles,'Tag',tag_pus_hist);
        pus_stat    = findobj(pus_handles,'Tag',tag_pus_stat);
        pop_viewm   = findobj(pop_handles,'Tag',tag_pop_viewm);
        pop_app_scr = findobj(pop_handles,'Tag',tag_valapp_scr);
        pop_det_scr = findobj(pop_handles,'Tag',tag_valdet_scr);
        pop_lev_dec = findobj(pop_handles,'Tag',tag_declev);
end

switch option
    case 'set_par'

        % Reading Analysis Parameters.
        %----------------------------
        [Wave_Name,Level_Anal] = cbanapar('get',win_dw1dtool,'wav','lev');

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal, ...
            ind_wav_name,Wave_Name, ...
            ind_lev_anal,Level_Anal ...
            );

    case 'clean'
        % in3 = type of loading.
        %-----------------------
        % 'load_sig' , 'load_dec'
        % 'load_cfs' , 'demo'    
        %-----------------------
        if nargin<4 , in4 = ''; end
        switch in3
            case {'load_cfs','synt'}
                str_btn = getWavMSG('Wavelet:commongui:Str_Synt');
                cba_btn = @(~,~)dw1dmngr('synt',win_dw1dtool);

            otherwise        
                str_btn = getWavMSG('Wavelet:commongui:Str_Anal');
                cba_btn = @(~,~)dw1dmngr('anal',win_dw1dtool);
        end
        set(pus_anal,'String',str_btn,'Callback',cba_btn);

        % Writing Synthesized Signal Type.
        %----------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_ssig_type,'ss');

        % Cleaning files.
        %----------------
        dw1dfile('del',win_dw1dtool);

        % Testing first use.
        %-------------------
        active_option = wmemtool('rmb',win_dw1dtool,n_param_anal, ...
                                       ind_act_option);
        if isempty(active_option) , first = 1; else first = 0; end

        % End of Cleaning when first is true.
        %------------------------------------
        if first , return; end

        cba_disp = @(~,~)dw1ddisp('create',win_dw1dtool);
        set(pus_dispopt,...
            'Style','pushbutton',            ...
            'String',getWavMSG('Wavelet:dw1dRF:Str_DISPOPT'), ...
            'Callback',cba_disp);

        % Setting enable property of objects.
        %------------------------------------
        set(m_SAV_EXP,'Enable','Off');
        cbanapar('Enable',win_dw1dtool,'off');
        set([ pus_anal,    pus_deno,                ...
              pus_comp,    pus_hist,    pus_stat,   ...
              pop_viewm,   pus_dispopt,             ...
              pop_lev_dec, pop_app_scr, pop_det_scr ...
              ],...
              'Enable','off'...
              );
        cbcolmap('Enable',win_dw1dtool,'off')

        % Cleaning DynVTool.
        %-------------------
        dynvtool('stop',win_dw1dtool);

        % Cleaning GUI.
        %--------------
        dw1dvmod('ch_vm',win_dw1dtool,1);
        switch in4
            case {'new_anal','new_synt'}
                set([pop_lev_dec,pop_app_scr,pop_det_scr],'Value',1);

            otherwise
                str_lev_data = int2str((1:max_lev_anal)');
                cbanapar('set',win_dw1dtool,...
                    'nam','',             ...
                    'wav','haar',         ...
                    'lev',{'String',str_lev_data,'Value',1})
                set([pop_lev_dec,pop_app_scr,pop_det_scr], ...
                            'String',str_lev_data,'Value',1);
        end

    case 'set_gui'
        % in3 = calling option.
        % in4  : optional (new_anal or new_synt).
        %-----------------------------------------
        if nargin<4 , in4 = ''; end
        switch in3
            case 'load_sig'
                [Sig_Name,Sig_Size] = ...
                        wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                       ind_sig_name,ind_sig_size);
                Sig_Size = max(Sig_Size);
                levm     = wmaxlev(Sig_Size,'haar');
                levmax   = min(levm,max_lev_anal);
                if isempty(in4)
                    lev = min(levmax,5);
                    str_lev_data = int2str((1:levmax)');
                    cbanapar('set',win_dw1dtool,...
                             'n_s',{Sig_Name,Sig_Size},    ...
                             'lev',{'String',str_lev_data,'Value',lev});
                    set([pop_lev_dec,pop_app_scr,pop_det_scr], ...
                                'String',str_lev_data);
                end

            case {'demo','load_dec'}
                [Sig_Name,Sig_Size,Wave_Name,Level_Anal] =    ...
                        wmemtool('rmb',win_dw1dtool,n_param_anal,  ...
                                       ind_sig_name,ind_sig_size, ...
                                       ind_wav_name,ind_lev_anal);
                Sig_Size = max(Sig_Size);
                levm     = wmaxlev(Sig_Size,'haar');
                if levm<Level_Anal , levm = Level_Anal; end
                levmax = min(levm,max_lev_anal);
                str_lev_data = int2str((1:levmax)');
                cbanapar('set',win_dw1dtool,...
                    'n_s',{Sig_Name,Sig_Size},...
                    'wav',Wave_Name,      ...
                    'lev',{'String',str_lev_data,'Value',Level_Anal});
                levels = int2str((1:Level_Anal)');
                set(pop_lev_dec,'String',levels,'Value',Level_Anal);
                set([pop_app_scr,pop_det_scr],'String',levels,'Value',1);
                dw1dvmod('ini_vm',win_dw1dtool);

            case 'load_cfs'
                [Sig_Name,Sig_Size,Level_Anal] =    ...
                        wmemtool('rmb',win_dw1dtool,n_param_anal,   ...
                                        ind_sig_name,ind_sig_size,  ...
                                        ind_lev_anal);
                levels  = int2str((1:Level_Anal)');
                cbanapar('set',win_dw1dtool,...
                    'n_s',{Sig_Name,Sig_Size},...
                    'lev',{'String',int2str(Level_Anal)});
                set(pop_lev_dec,'String',levels,'Value',Level_Anal);
                set([pop_app_scr,pop_det_scr],'String',levels,'Value',1);
                dw1dvmod('ini_vm',win_dw1dtool);

            case 'synt'
                Level_Anal = wmemtool('rmb',win_dw1dtool,...
                    n_param_anal,ind_lev_anal);
                set(pop_lev_dec,'Value',Level_Anal);
                set([pop_app_scr,pop_det_scr],'Value',1);
                dw1dvmod('ini_vm',win_dw1dtool);

            case 'anal'
                Level_Anal = wmemtool('rmb',win_dw1dtool,...
                    n_param_anal,ind_lev_anal);
                levels = int2str((1:Level_Anal)');
                set(pop_lev_dec,'String',levels,'Value',Level_Anal);
                set([pop_app_scr,pop_det_scr],'String',levels,'Value',1);
                dw1dvmod('ini_vm',win_dw1dtool);
        end

    case 'enable'
        % in3 = calling option.
        %----------------------
        switch in3
            case 'load_sig'
                cbcolmap('Enable',win_dw1dtool,'off')
                cbanapar('Enable',win_dw1dtool,'on');
                set(pus_anal,'Enable','On' );

            case 'load_cfs'
                cbcolmap('Enable',win_dw1dtool,'off')
                cbanapar('Enable',win_dw1dtool,'on');
                set(pus_anal,'Enable','On' );

            case {'demo','load_dec'}
                cbcolmap('Enable',win_dw1dtool,'on')
                cbanapar('Enable',win_dw1dtool,'on');
                set([pus_anal,                              ...
                     pus_deno,    pus_comp,    pus_hist,    ...
                     pus_stat,    pop_viewm,   pus_dispopt, ...
                     pop_app_scr, pop_det_scr, pop_lev_dec  ...
                     ],      ...
                     'Enable','On'   ...
                     );
                set(m_SAV_EXP,'Enable','on');

            case {'anal','synt'}
                cbcolmap('Enable',win_dw1dtool,'on')
                set([pus_deno,    pus_comp,     pus_hist,    ...
                     pus_stat,    pop_viewm,    pus_dispopt, ...
                     pop_app_scr, pop_det_scr,  pop_lev_dec  ...
                     ],...
                     'Enable','on'...
                     );
                set(m_SAV_EXP,'Enable','on');

            case {'comp','deno'}
                set([m_files , pus_anal , pus_deno , pus_comp],'Enable','off');

            case {'return_comp','return_deno'}
                set([m_files , pus_anal , pus_deno , pus_comp],'Enable','on');

            case {'more_disp','end_more_disp'}
                hdldynV = dynvtool('handles',win_dw1dtool);
                btnZaxe = hdldynV.Tog_View_Axes;
                if isequal(in3,'more_disp') , ena = 'off'; else ena = 'on'; end				
				if isequal(in3,'more_disp') , set(btnZaxe,'Enable','Off'); end				
                cbanapar('Enable',win_dw1dtool,ena);
                set([pus_anal,  pus_deno,    pus_comp, ...
                     pop_viewm, pus_dispopt, btnZaxe], ...
                     'Enable',ena ...
                     );
                lst_subm = get(m_files,'Children');
                pos_subm = get(lst_subm,'Position');
                pos_subm = cat(1,pos_subm{:});
                set(lst_subm(pos_subm<8),'Enable',ena);
				if isequal(in3,'end_more_disp')
					dynvtool('dynvzaxe_BtnOnOff',win_dw1dtool);
				end
        end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
