function varargout = wp1dmngr(option,win_wptool,in3,in4,in5,in6,in7)
%WP1DMNGR Wavelet packets 1-D general manager.
%   OUT1 = WP1DMNGR(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

%DDUX
if   ~isempty(option) && strcmpi(option,'deno')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "wp1ddtool_denoise";
    matlab.ddux.internal.logData(dataId,DDUXdata);
elseif ~isempty(option) && strcmpi(option,'comp')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "wp1dtool_compression";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
% Default values.
%----------------
default_nbcolors = 128;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP1D_InfoInit';
ind_filename = 1;
ind_pathname = 2;

% MB1.
%-----
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
ind_act_option = 7;
ind_thr_val    = 8;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
ind_nb_colors = 6;

switch option
    case {'load_sig','import_sig'}
        switch option
            case 'load_sig'
                [sigInfos,Sig_Anal,ok] = utguidiv('load_sig',win_wptool,...
                     'Signal_Mask',getWavMSG('Wavelet:commongui:LoadSig'));
                if ~ok, return; end

            case 'import_sig'
                [sigInfos,Sig_Anal,ok] = wtbximport('wp1d');
                if ~ok, return; end
                if isa(Sig_Anal,'wptree')
                    wp1dmngr('load_dec',win_wptool,Sig_Anal,sigInfos.name);
                    return
                end
                option = 'load_sig';
        end
        wtbxappdata('set',win_wptool,...
            'Anal_Data_Info',{Sig_Anal,sigInfos.name});

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitClean'));
        wp1dutil('clean',win_wptool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,...
                       ind_nb_colors,default_nbcolors);

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddraw('sig',win_wptool,Sig_Anal);

        % Setting enabled values.
        %------------------------
        wp1dutil('Enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case {'load_dec','import_dec'}
        switch option
            case 'load_dec'
                switch nargin
                    case 2
                        % Testing file.
                        %--------------
                        winTitle = getWavMSG('Wavelet:wp1d2dRF:LoadWP1D');
                        fileMask = {...
                            '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
                            '*.*','All Files (*.*)'};
                        [filename,pathname,ok] = ...
                            utguidiv('load_wpdec',win_wptool, ...
                                        fileMask,winTitle,2);
                        if ~ok, return; end

                        % Loading file.
                        %--------------
                        load([pathname filename],'-mat');
                        if ~exist('data_name','var')
                            data_name = 'no name';
                        end
                        if exist('tree_struct','var')
                            WP_Tree = tree_struct; %#ok<NODEF>
                        end

                    case {3,4}
                        WP_Tree = in3;
                        if nargin>3
                            data_name = in4; 
                        else
                            data_name = 'input var';
                        end
                end

            case 'import_dec'
                [ok,S,varName] = wtbximport('decwp1d');  %#ok<ASGLU>
                if ok
                    WP_Tree = S.tree_struct;
                    if isa(WP_Tree,'wptree')
                        order = treeord(WP_Tree);
                        ok = isequal(order,2);
                    else
                        ok = false;
                    end
                end
                if ~ok, return; end
                data_name = S.data_name;
                option = 'load_dec';
        end

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitClean'));
        wp1dutil('clean',win_wptool,option);

        % Getting Analysis parameters.
        %-----------------------------
        [Wave_Name,Ent_Name,Ent_Par,Signal_Size] = ...
                read(WP_Tree,'wavname','entname','entpar','sizes',0);
        Level_Anal  = treedpth(WP_Tree);
        Sig_Name = data_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal,  ...
                       ind_act_option,option,    ...
                       ind_sig_name,Sig_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size, ...
                       ind_ent_anal,Ent_Name,    ...
                       ind_ent_par,Ent_Par       ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );
        % Writing structures.
        %----------------------
        wtbxappdata('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdata('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Computing and Drawing Original Signal.
        %---------------------------------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitCompute'));
        Sig_Anal = wprec(WP_Tree);
        wp1ddraw('sig',win_wptool,Sig_Anal);

        % Decomposition drawing
        %----------------------
        wp1ddraw('anal',win_wptool);

        % Setting enabled values.
        %------------------------
        wp1dutil('Enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'demo'
        % in3 = Sig_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        % in6 = Ent_Name
        % in7 = Ent_Par (optional)
        %--------------------------
        Sig_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;
        Ent_Name    = deblank(in6);
        if nargin==6
            Ent_Par = 0;
        else
            Ent_Par = in7;
        end

        % Loading file.
        %-------------
        filename = [Sig_Name '.mat'];       
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,Sig_Anal,ok] = ...
            utguidiv('load_dem1D',win_wptool,pathname,filename);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitClean'));
        wp1dutil('clean',win_wptool,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal,    ...
                       ind_act_option,option,      ...
                       ind_sig_name,sigInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_sig_size,sigInfos.size, ...
                       ind_ent_anal,Ent_Name,      ...
                       ind_ent_par,Ent_Par         ...
                        );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddraw('sig',win_wptool,Sig_Anal);

        % Calling Analysis.
        %-----------------
        wp1dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutil('Enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                                     '*.mat',getWavMSG('Wavelet:commongui:SaveSS'));
        if ~ok, return; end
        name  = strtok(filename,'.');

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitSave'));

        % Saving Synthesized Signal.
        %---------------------------
        [wname,valTHR] = wmemtool('rmb',win_wptool,n_param_anal, ...
            ind_wav_name,ind_thr_val); %#ok<ASGLU>
        hdl_node = wpssnode('r_synt',win_wptool);
        if ~isempty(hdl_node)
            x = get(hdl_node,'UserData');        %#ok<NASGU>
        else
            WP_Tree = wtbxappdata('get',win_wptool,'WP_Tree');
            x = wprec(WP_Tree); %#ok<NASGU>
        end
        
        try
            saveStr = name;
            eval([saveStr '= x ;']);
        catch %#ok<*CTCH>
            saveStr = 'x';
        end
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        wwaiting('off',win_wptool);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'
         % Testing file.
        %--------------
         fileMask = {...
               '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
               '*.*','All Files (*.*)'};                
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                           fileMask,getWavMSG('Wavelet:wp1d2dRF:SaveWP1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis parameters.
        %-----------------------------
        data_name = wmemtool('rmb',win_wptool,n_param_anal,ind_sig_name); %#ok<NASGU>

        % Reading structures.
        %--------------------
        tree_struct = wtbxappdata('get',win_wptool,'WP_Tree'); %#ok<NASGU>

        % Saving file.
        %--------------
        valTHR = wmemtool('rmb',win_wptool,n_param_anal,ind_thr_val); %#ok<NASGU>
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        saveStr = {'tree_struct','data_name','valTHR'};
        wwaiting('off',win_wptool);
        try
            save([pathname filename],saveStr{:});
        catch
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
        
    case 'exp_wrks'
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitExport'));
        typeEXP = in3;
        switch typeEXP
            case 'sig'
                hdl_node = wpssnode('r_synt',win_wptool);
                if ~isempty(hdl_node)
                    x = get(hdl_node,'UserData');
                else
                    WP_Tree = wtbxappdata('get',win_wptool,'WP_Tree');
                    x = wprec(WP_Tree);
                end
                wtbxexport(x,'name','sig_1D',...
                    'title',getWavMSG('Wavelet:commongui:Str_SS_Abrev'));

            case 'dec'
                [data_name,valTHR] = wmemtool('rmb',win_wptool,...
                        n_param_anal,ind_sig_name,ind_thr_val);
                tree_struct = wtbxappdata('get',win_wptool,'WP_Tree');
                S = struct(...
                    'tree_struct',tree_struct,...
                    'data_name',data_name,'valTHR',valTHR);
                wtbxexport(S,'name','dec_WP1D', ...
                    'title',getWavMSG('Wavelet:commongui:Str_Decomp'));
        end
        wwaiting('off',win_wptool);
        
    case 'anal'
        active_option = wmemtool('rmb',win_wptool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')
            % Cleaning. 
            %----------
            wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitClean'));
            wp1dutil('clean',win_wptool,'load_sig','new_anal');
            wp1dutil('Enable',win_wptool,'load_sig');
        else
            wmemtool('wmb',win_wptool,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Setting Analysis parameters
        %-----------------------------
        [Wave_Name,Level_Anal] = cbanapar('get',win_wptool,'wav','lev');
        [Ent_Name,Ent_Par,err] = utentpar('get',win_wptool,'ent');
        if err>0
            wwaiting('off',win_wptool);
            switch err
              case 1 , msg = getWavMSG('Wavelet:wp1d2dRF:ErrEntPar');
              case 2 , msg = getWavMSG('Wavelet:wp1d2dRF:ErrEntNam');
            end
            errargt(mfilename,msg,'msg');
            utentpar('set',win_wptool);
            return
        end
        wmemtool('wmb',win_wptool,n_param_anal, ...
            ind_wav_name,Wave_Name, ...
            ind_lev_anal,Level_Anal,...
            ind_ent_anal,Ent_Name,  ...
            ind_ent_par,Ent_Par     ...
            );

        % Calling Analysis.
        %------------------
        wp1dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutil('Enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'step2'
        % Begin waiting.
        %---------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Getting  Analysis parameters.
        %------------------------------
        [Sig_Name,Wave_Name,Level_Anal,Ent_Name,Ent_Par] = ...
                wmemtool('rmb',win_wptool,n_param_anal, ...
                               ind_sig_name, ...
                               ind_wav_name,ind_lev_anal, ...
                               ind_ent_anal,ind_ent_par);
        active_option = wmemtool('rmb',win_wptool,n_param_anal,ind_act_option);
        [filename,pathname] = wmemtool('rmb',win_wptool,n_InfoInit, ...
                                             ind_filename,ind_pathname);

        % Computing.
        %-----------   
        switch active_option
            case {'demo','anal'}
                try
                    load([pathname filename],'-mat');
                    Sig_Anal = eval(Sig_Name);
                catch
                    try
                        Anal_Data_Info = ...
                            wtbxappdata('get',win_wptool,'Anal_Data_Info');
                        Sig_Anal = Anal_Data_Info{1};
                    catch
                        [Sig_Anal,ok] = utguidiv('direct_load_sig', ...
                            win_wptool,pathname,filename);
                        if ~ok
                            wwaiting('off',win_wptool);
                            msg = getWavMSG('Wavelet:commongui:ErrLoadFile',filename);
                            nam = getWavMSG('Wavelet:commongui:LoadERROR');
                            errordlg(msg,nam,'modal');
                            return
                        end

                    end
                end

            case 'load_dec'       % second time only for load_dec
                Sig_Anal = get(wp1ddraw('r_orig',win_wptool),'YData');
                WP_Tree  = wtbxappdata('get',win_wptool,'WP_Tree'); %#ok<NASGU>
        end
        WP_Tree = wpdec(Sig_Anal,Level_Anal,Wave_Name,Ent_Name,Ent_Par);

        % Writing structures.
        %----------------------
        wtbxappdata('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdata('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Decomposition drawing
        %----------------------
        wp1ddraw('anal',win_wptool);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'comp'
        mousefrm(win_wptool,'watch');
        drawnow;
        wp1dutil('Enable',win_wptool,option);
        fig = feval('wp1dcomp','create',win_wptool);
        if nargout>0 , varargout{1} = fig; end
        mousefrm(win_wptool,'arrow');
    case 'deno'
        mousefrm(win_wptool,'watch');
        drawnow;
        wp1dutil('Enable',win_wptool,option);
        fig = feval('wp1ddeno','create',win_wptool);
        if nargout>0 , varargout{1} = fig; end        
        mousefrm(win_wptool,'arrow');
    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hdl_line (optional)
        %--------------------------------------
        if in3==1
            % Begin waiting.
            %--------------
            wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitDraw'));

            if strcmp(option,'return_comp')
                namesig = 'cs';
            else
                namesig = 'ds';
            end
            wpssnode('plot',win_wptool,namesig,1,in4,[]);

            % End waiting.
            %-------------
            wwaiting('off',win_wptool);
        end
        wp1dutil('Enable',win_wptool,option);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
