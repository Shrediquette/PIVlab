function [out1,out2,out3,out4,out5,out6] = ...
                  dw1dvmod(option,win_dw1dtool,in3,in4,in5,in6,in7,in8,in9)
%DW1DVMOD Discrete wavelet 1-D view mode manager.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.20.4.8 $

% Subfunction(s): 
%----------------
% SSSTRING.

%--------------------------------------
% mode 1 : scroll mode        = 'scr'
% mode 2 : decomposition mode = 'dec'
% mode 3 : separate mode      = 'sep'
% mode 4 : superimposed mode  = 'sup'
% mode 5 : tree mode          = 'tre'
% mode 6 : cfs mode           = 'cfs'
%--------------------------------------

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
% ind_sig_size   = 2;
% ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
% ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% Default values.
%----------------
max_lev_anal = 12;

% Tag property of objects.
%-------------------------
tag_pop_viewm   = 'View_Mode';
tag_pus_dispopt = 'Pus_Options';
tag_valapp_scr  = 'ValApp_Scr';
tag_txtapp_scr  = 'TxtApp_Scr';
tag_valdet_scr  = 'ValDet_Scr';
tag_txtdet_scr  = 'TxtDet_Scr';
tag_declev      = 'Pop_DecLev';
tag_txtdeclev   = 'Txt_DecLev';

% Handles of tagged objects.
%---------------------------
uic_handles = findobj(win_dw1dtool,'Type','uicontrol');
txt_handles = findobj(uic_handles,'Style','text');
pop_handles = findobj(uic_handles,'Style','popupmenu');
pus_dispopt = findobj(uic_handles,'Tag',tag_pus_dispopt);

% Local MemBloc of stored values.
%---------------------------
ind_scrm_1 =  1;
ind_scrm_2 =  2;
ind_decm_1 =  3;
ind_decm_2 =  4;
ind_sepm_1 =  5;
ind_sepm_2 =  6;
ind_supm_1 =  7;
ind_supm_2 =  8;
ind_trem_1 =  9;
ind_trem_2 = 10;
ind_cfsm_1 = 11;
ind_cfsm_2 = 12;
nb_stored  = 12;

switch option
    case 'ini_vm'
        %*****************************************************************%
        %** OPTION = 'ini_vm' - Default & Current values for every mode **%
        %*****************************************************************%
        % mode 1 : scroll mode        = 'scr'
        % mode 2 : decomposition mode = 'dec'
        % mode 3 : separate mode      = 'sep'
        % mode 4 : superimposed mode  = 'sup'
        % mode 5 : tree mode          = 'tre'
        % mode 6 : cfs  mode          = 'cfs'
        %--------------------------------------
        scrm = [1 1 1 1 0 1 0 0 1 1];
        decm = [1 0 1];
        sepm = [1 1 1 1 0 ones(1,max_lev_anal) 1 0 ones(1,max_lev_anal) 1];
        supm = [1 1 1 1 0 ones(1,max_lev_anal) 0 0 ones(1,max_lev_anal) 1];
        trem = [1 0 1];
        cfsm = [1 1 1 1 0 1 0 0 1 1];
        memB = cell(1,nb_stored);
        memB(ind_scrm_1) = {scrm};
        memB(ind_scrm_2) = {scrm};
        memB(ind_decm_1) = {decm};
        memB(ind_decm_2) = {decm};
        memB(ind_sepm_1) = {sepm};
        memB(ind_sepm_2) = {sepm};
        memB(ind_supm_1) = {supm};
        memB(ind_supm_2) = {supm};
        memB(ind_trem_1) = {trem};
        memB(ind_trem_2) = {trem};
        memB(ind_cfsm_1) = {cfsm};
        memB(ind_cfsm_2) = {cfsm};
        set(pus_dispopt,'UserData',memB);

    case 'set_vm'
        %**************************************************%
        %** OPTION = 'set_vm' - set View Mode Parameters **%
        %**************************************************%
        % mode 1 : scroll mode        = 'scr'
        % mode 2 : decomposition mode = 'dec'
        % mode 3 : separate mode      = 'sep'
        % mode 4 : superimposed mode  = 'sup'
        % mode 5 : tree mode          = 'tre'
        % mode 6 : cfs  mode          = 'cfs'
        %--------------------------------------
        % in3 = mode
        %------------
        switch in3
            case {1,'1','scr'}
                new_vm = [in4 in5 in6 in7 in8 in9];
                index  = ind_scrm_2;

            case {2,'2','dec'}
                new_vm = [in4 in5];
                index  = ind_decm_2;

            case {3,'3','sep'}
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
                plus = ones(1,max_lev_anal-Level_Anal);
                new_vm = [in4 in5 in6 plus in7 in8 plus in9];
                index  = ind_sepm_2;

            case {4,'4','sup'}
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
                plus = ones(1,max_lev_anal-Level_Anal);
                new_vm = [in4 in5 in6 plus in7 in8 plus in9];
                index  = ind_supm_2;

            case {5,'5','tre'}
                new_vm = [in4 in5];
                index  = ind_trem_2;

            case {6,'6','cfs'}
                new_vm = [in4 in5 in6 in7 in8 in9];
                index  = ind_cfsm_2;
        end
        memB = get(pus_dispopt,'UserData');
        old_vm  = memB{index};
        if find(new_vm~=old_vm)
            out1 = 1;
            memB(index) = {new_vm};
            set(pus_dispopt,'UserData',memB);
        else
            out1 = 0;
        end

    case 'get_vm'
        %**************************************************%
        %** OPTION = 'get_vm' - get View Mode Parameters **%
        %**************************************************%
        % mode 1 : scroll mode          = 'scr'
        % mode 2 : decomposition mode   = 'dec'
        % mode 3 : separate mode        = 'sep'
        % mode 4 : superimposed mode    = 'sup
        % mode 5 : tree mode            = 'tre'
        % mode 6 : cfs  mode            = 'cfs'
        %--------------------------------------
        % in3 = mode
        % in4 optional
        % if nargin=4 , initial options
        %------------------------------
        memB = get(pus_dispopt,'UserData');
        if nargin==3 , indplus = 1 ; else indplus = rem(in4,2); end
        switch in3
            case {1,'1','scr'}
                viewm = memB{ind_scrm_1+indplus};
                out1  = viewm(1:3);
                out2  = viewm(4:5);
                out3  = viewm(6);
                out4  = viewm(7:8);
                out5  = viewm(9);
                out6  = viewm(10);

            case {2,'2','dec'}
                viewm = memB{ind_decm_1+indplus};
                out1  = viewm(1:2);
                out2  = viewm(3);

            case {3,'3','sep'}
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
                viewm = memB{ind_sepm_1+indplus};
                out1  = viewm(1:3);
                out2  = viewm(4:5);
                out3  = viewm(6:max_lev_anal+5);
                out3  = out3(1:Level_Anal);
                out4  = viewm(max_lev_anal+6:max_lev_anal+7);
                out5  = viewm(max_lev_anal+8:2*max_lev_anal+7);
                out5  = out5(1:Level_Anal);
                out6  = viewm(2*max_lev_anal+8);

            case {4,'4','sup'}
                Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
                viewm = memB{ind_supm_1+indplus};
                out1  = viewm(1:3);
                out2  = viewm(4:5);
                out3  = viewm(6:max_lev_anal+5);
                out3  = out3(1:Level_Anal);
                out4  = viewm(max_lev_anal+6:max_lev_anal+7);
                out5  = viewm(max_lev_anal+8:2*max_lev_anal+7);
                out5  = out5(1:Level_Anal);
                out6  = viewm(2*max_lev_anal+8);

            case {5,'5','tre'}
                viewm = memB{ind_trem_1+indplus};
                out1  = viewm(1:2);
                out2  = viewm(3);

            case {6,'6','cfs'}
                viewm = memB{ind_cfsm_1+indplus};
                out1  = viewm(1:3);
                out2  = viewm(4:5);
                out3  = viewm(6);
                out4  = viewm(7:8);
                out5  = viewm(9);
                out6  = viewm(10);
        end

    case 'ch_vm'
        %***********************************************%
        %** OPTION = 'ch_vm' - Change Mode  View Mode **%
        %***********************************************%
        % in3 = 1 (optional) - clean
        % in3 = 2 (optional) - clean + redraw (return comp & deno)
        %----------------------------------------------------------
        % Handles of tagged objects.
        %---------------------------
        [btnHeight,ySpacing] = mextglob('get','Def_Btn_Height','Y_Spacing');
        pop_viewm   = findobj(pop_handles,'Tag',tag_pop_viewm);
        pop_app_scr = findobj(pop_handles,'Tag',tag_valapp_scr);
        pop_det_scr = findobj(pop_handles,'Tag',tag_valdet_scr);
        pop_lev_dec = findobj(pop_handles,'Tag',tag_declev);
        txt_app_scr = findobj(txt_handles,'Tag',tag_txtapp_scr);
        txt_det_scr = findobj(txt_handles,'Tag',tag_txtdet_scr);
        txt_lev_dec = findobj(txt_handles,'Tag',tag_txtdeclev);
        hdl_col     = utcolmap('handles',win_dw1dtool,'cell');
        hdl_col     = double(hdl_col(:)');
        
        if nargin==2 , in3 = 0; end
        old_mode = get(pop_viewm,'UserData');
        new_mode = get(pop_viewm,'Value');

        %-------------------------------------------------------------%
        %-- pour deno et comp on ne change que le signal synthetise --%
        %-- sinon oter cette partie                                 --%
        %-------------------------------------------------------------%
        if in3==2
            % Begin waiting.
            %---------------
            wwaiting('msg',win_dw1dtool, ...
                getWavMSG('Wavelet:commongui:WaitCompute'));

            switch new_mode
              case {2,'2','dec',5,'5','tre'}
                  val = dw1dvmod('get_vm',win_dw1dtool,new_mode);
                  ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
                  str_ss  = ssString(ss_type);
                  switch lower(str_ss(1))
                      case 'c' , lab = getWavMSG('Wavelet:dw1dRF:ShowCompSig');
                      case 'd' , lab = getWavMSG('Wavelet:dw1dRF:ShowDenoSig');
                      case 's' , lab = getWavMSG('Wavelet:dw1dRF:ShowSyntSig');
                  end
                  set(pus_dispopt,'Value',val(2),'String',lab);

            end
            switch new_mode
                case {1,'1','scr'} , fname = 'dw1dscrm';
                case {2,'2','dec'} , fname = 'dw1ddecm';
                case {3,'3','sep'} , fname = 'dw1dsepm';
                case {4,'4','sup'} , fname = 'dw1dsupm';
                case {5,'5','tre'} , fname = 'dw1dtrem';
                case {6,'6','cfs'} , fname = 'dw1dcfsm';
            end
            feval(fname,'del_ss',win_dw1dtool);
            % clean_val = -0;    % reset axes history. 
            clean_val = -1;      % preserve axes history.
            feval(fname,'view',win_dw1dtool,clean_val)

            % End waiting.
            %---------------
            wwaiting('off',win_dw1dtool);

            return;
        end
        %-------------------------------------------------------------%

        if (old_mode==new_mode)
            if in3==0
                return ;
            elseif in3==1 || in3==2
                new_mode  = 1;
                set(pop_viewm,'Value',new_mode,'UserData',new_mode);
                clear_val = 0;
            end
        else
            clear_val = new_mode;
            set(pop_viewm,'UserData',new_mode);
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw1dtool, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        % Borders and double borders.
        %----------------------------
        win_units = get(win_dw1dtool,'Units');
        deltay    = btnHeight+4*ySpacing;
        if ~strcmp(win_units,'pixels')
            [~,deltay] = wfigutil('prop_size',win_dw1dtool,1,deltay);
        end
        pos_pop_viewm   = get(pop_viewm,'Position');

        pos_opt = get(pus_dispopt,'Position');
        switch old_mode
            case {1,'1','scr'}
                set([txt_app_scr,txt_det_scr,pop_app_scr,pop_det_scr, ...
                     pus_dispopt],'Visible','off');
                dw1dscrm('clear',win_dw1dtool,clear_val);

            case {2,'2','dec'}
                set([txt_lev_dec,pop_lev_dec,pus_dispopt],'Visible','off');
                set(pus_dispopt,'Style','pushbutton');
                dw1ddecm('clear',win_dw1dtool);
                drawnow;

            case {3,'3','sep'}
                if (new_mode==1) || (new_mode==2)
                    set(pus_dispopt,'Visible','off');
                end
                dw1dsepm('clear',win_dw1dtool);
                drawnow;

            case {4,'4','sup'}
                if (new_mode==1) || (new_mode==2)
                    set(pus_dispopt,'Visible','off');
                end
                dw1dsupm('clear',win_dw1dtool,clear_val);

            case {5,'5','tre'}
                set(pus_dispopt,'Visible','off');
                set(pus_dispopt,'Style','pushbutton');
                dw1dtrem('clear',win_dw1dtool);
                drawnow;

            case {6,'6','cfs'}
                set([txt_app_scr,txt_det_scr,pop_app_scr,pop_det_scr, ...
                     pus_dispopt],'Visible','off');
                dw1dcfsm('clear',win_dw1dtool,clear_val);
        end
        
        if ((new_mode==2) && find(old_mode==[1 3 4 5 6])) || ...
           ((new_mode==5) && find(old_mode==[1 2 3 4 6]))
            val = dw1dvmod('get_vm',win_dw1dtool,new_mode);
            ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
            str_ss  = ssString(ss_type);
            if new_mode==2
                cba_disp = @(~,~)dw1ddecm('ssig', ...
                            win_dw1dtool, ...
                            pus_dispopt);
            else
                cba_disp = @(~,~)dw1dtrem('ssig',...
                            win_dw1dtool, ...
                            pus_dispopt);
            end
            
            switch lower(str_ss(1))
                case 'c' , lab = getWavMSG('Wavelet:dw1dRF:ShowCompSig');
                case 'd' , lab = getWavMSG('Wavelet:dw1dRF:ShowDenoSig');
                case 's' , lab = getWavMSG('Wavelet:dw1dRF:ShowSyntSig');                    
            end
            set(pus_dispopt,'Style','checkbox','Value',val(2),...
                           'String',lab,'Callback',cba_disp);

        elseif ((old_mode==2) && find(new_mode==[1 3 4 5 6])) || ...
               ((old_mode==5) && find(new_mode==[1 2 3 4 6]))
            cba_disp = @(~,~)dw1ddisp('create',win_dw1dtool);
            set(pus_dispopt,...
                           'Style','pushbutton',            ...
                           'String',getWavMSG('Wavelet:dw1dRF:Str_MoreDisp_1D'), ...
                           'Callback',cba_disp);
        end

        switch new_mode
            case {1,'1','scr'}
                pos_txt1   = get(txt_app_scr,'Position');
                pos_opt(2) = pos_txt1(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set([txt_app_scr, txt_det_scr, ...
                     pop_app_scr, pop_det_scr, ...
                     pus_dispopt, hdl_col],    ...
                     'Visible','on');
                drawnow
                if (clear_val==0) && (in3==1) , return; end
                dw1dscrm('view',win_dw1dtool,old_mode);

            case {2,'2','dec'}
                pos_txt1   = get(txt_lev_dec,'Position');
                pos_opt(2) = pos_txt1(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set([txt_lev_dec, pop_lev_dec,pus_dispopt],'Visible','on');
                set(hdl_col,'Visible','off');         
                drawnow
                lev = get(pop_lev_dec,'Value'); 
                dw1ddecm('view',win_dw1dtool,old_mode,lev);

            case {3,'3','sep'}
                pos_opt(2) = pos_pop_viewm(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set([pus_dispopt,hdl_col],'Visible','on');
                drawnow
                dw1dsepm('view',win_dw1dtool,old_mode);

            case {4,'4','sup'}
                pos_opt(2) = pos_pop_viewm(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set([pus_dispopt,hdl_col],'Visible','on');
                drawnow
                dw1dsupm('view',win_dw1dtool,old_mode);

            case {5,'5','tre'}
                pos_txt1   = get(txt_lev_dec,'Position');
                pos_opt(2) = pos_txt1(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set(pus_dispopt,'Visible','on');
                set(hdl_col,'Visible','off');         
                drawnow
                lev = get(pop_lev_dec,'Value');
                dw1dtrem('view',win_dw1dtool,old_mode,lev);

            case {6,'6','cfs'}
                pos_txt1   = get(txt_app_scr,'Position');
                pos_opt(2) = pos_txt1(2)-deltay;
                set(pus_dispopt,'Position',pos_opt);
                set([txt_app_scr, txt_det_scr, ...
                     pop_app_scr, pop_det_scr, ...
                     pus_dispopt],    ...
                     'Visible','on');
                set(hdl_col,'Visible','off');         
                drawnow
                if (clear_val==0) && (in3==1) , return; end
                dw1dcfsm('view',win_dw1dtool,old_mode);
        end

        % End waiting.
        %---------------
        wwaiting('off',win_dw1dtool);

    case 'ss_vm'
        %*******************************************************%
        %** OPTION = 'ss_vm' - set Visibility of synth signal **%
        %*******************************************************%
        % mode 1 : scroll mode        = 'scr'
        % mode 2 : decomposition mode = 'dec'
        % mode 3 : separate mode      = 'sep'
        % mode 4 : superimposed mode  = 'sup'
        % mode 5 : tree mode          = 'tre'
        % mode 6 : cfs  mode          = 'cfs'
        %-----------------------------------------
        % in3 = view_mode (s)
        % in4 = 0 (invisible) or in4 = 1 (visible)
        % in5 = 0 (invisible) or in5 = 1 (visible)
        %------------------------------------------

        if nargin==4 , in5 = in4; end
        memB = get(pus_dispopt,'UserData');
        if find(in3==1)
            viewm            = memB{ind_scrm_2};
            viewm(5)         = in4;
            viewm(8)         = in5;
            memB(ind_scrm_2) = {viewm};
        end

        if find(in3==2)
            viewm            = memB{ind_decm_2};
            viewm(2)         = in4;
            memB(ind_decm_2) = {viewm};
        end

        if find(in3==3)
            viewm                 = memB{ind_sepm_2};
            viewm(5)              = in4;
            viewm(max_lev_anal+7) = in5;
            memB(ind_sepm_2)      = {viewm};
        end

        if find(in3==4)
            viewm                 = memB{ind_supm_2};
            viewm(5)              = in4;
            viewm(max_lev_anal+7) = in5;
            memB(ind_supm_2)      = {viewm};
        end

        if find(in3==5)
            viewm            = memB{ind_trem_2};
            viewm(2)         = in4;
            memB(ind_trem_2) = {viewm};
        end

        if find(in3==6)
            viewm            = memB{ind_cfsm_2};
            viewm(5)         = in4;
            viewm(8)         = in5;
            memB(ind_cfsm_2) = {viewm};
        end

        set(pus_dispopt,'UserData',memB);

    case 'ccfs_vm'
        %*************************************************%
        %** OPTION = 'ccfs_vm' - get coloration options **%
        %*************************************************%
        % mode 1 : scroll mode        = 'scr'
        % mode 2 : decomposition mode = 'dec'
        % mode 3 : separate mode      = 'sep'
        % mode 4 : superimposed mode  = 'sup'
        % mode 5 : tree mode          = 'tre'
        % mode 6 : cfs  mode          = 'cfs'
        %--------------------------------------
        % in3 = mode
        %------------------------------
        memB = get(pus_dispopt,'UserData');
        switch in3
            case {1,'1','scr'}
                viewm = memB{ind_scrm_2};
                out1  = viewm(10);

            case {2,'2','dec'}
                viewm = memB{ind_decm_2};
                out1  = viewm(3);

            case {3,'3','sep'}
                viewm = memB{ind_sepm_2};
                out1  = viewm(2*max_lev_anal+8);

            case {4,'4','sup'}
                viewm = memB{ind_supm_2};
                out1  = viewm(2*max_lev_anal+8);

            case {5,'5','tre'}
                viewm = memB{ind_trem_2};
                out1  = viewm(3);

            case {6,'6','cfs'}
                viewm = memB{ind_cfsm_2};
                out1  = viewm(10);
        end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end


%--------------------------------------
function s = ssString(ss_type)

switch ss_type
    case 'ss', s = 'Synthesized';
    case 'ds', s = 'De-noised';
    case 'cs', s = 'Compressed';
end
%--------------------------------------
