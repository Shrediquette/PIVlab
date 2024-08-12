function out1 = dw1dmngr(option,win_dw1dtool,in3,in4,in5)
%DW1DMNGR Discrete wavelet 1-D general manager.
%   OUT1 = DW1DMNGR(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

%DDUX
if   ~isempty(option) && strcmpi(option,'deno')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "dw1dtool_denoise";
    matlab.ddux.internal.logData(dataId,DDUXdata);
elseif ~isempty(option) && strcmpi(option,'hist')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "dw1dtool_histogram";
    matlab.ddux.internal.logData(dataId,DDUXdata);
elseif ~isempty(option) && strcmpi(option,'comp')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "dw1dtool_compression";
    matlab.ddux.internal.logData(dataId,DDUXdata);
elseif ~isempty(option) && strcmpi(option,'stat')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "dw1dtool_statistics";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end


% Default values.
%----------------
max_lev_anal = 12;

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
ind_act_option = 6;
% ind_ssig_type  = 7;
ind_thr_val    = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;

%***********************************************%
%** OPTION = 'ini' - Only for precompilation. **%
%***********************************************%
if strcmp(option,'ini') , return; end
%***********************************************%

switch option
    case 'anal'
        active_option = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')

            % Cleaning.
            %----------
            Sig_Anal = dw1dfile('sig',win_dw1dtool);
            wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
            dw1dutil('clean',win_dw1dtool,'load_sig','new_anal');

            % Setting GUI values.
            %--------------------
            dw1dutil('set_gui',win_dw1dtool,'load_sig','new_anal');

            % Drawing.
            %---------
            dw1dvdrv('plot_sig',win_dw1dtool,Sig_Anal);

            % Setting enabled values.
            %------------------------
            dw1dutil('Enable',win_dw1dtool,'load_sig');
        else
            wmemtool('wmb',win_dw1dtool,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_dw1dtool, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        % Setting Analysis parameters
        %-----------------------------
        dw1dutil('set_par',win_dw1dtool,option);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);
        mousefrm(win_dw1dtool,'watch');

        % Computing
        %-----------
        if strcmp(active_option,'load_dec')
            dw1dfile('anal',win_dw1dtool,'new_anal');
        else
            dw1dfile('anal',win_dw1dtool);
        end

        % Drawing.
        %---------
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);
        
        % Add or Delete Save APP-Menu
        %------------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        Add_OR_Del_SaveAPPMenu(win_dw1dtool,Level_Anal);
        
        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);
        mousefrm(win_dw1dtool,'arrow');

    case 'synt'
        active_option = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                        ind_act_option);
        if ~strcmp(active_option,'load_cfs')

            % Cleaning.
            %----------
            wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
            dw1dutil('clean',win_dw1dtool,'load_cfs','new_synt');

            % Setting GUI values.
            %--------------------
            dw1dutil('set_gui',win_dw1dtool,'load_cfs');

            % Drawing.
            %---------
            dw1dvdrv('plot_cfs',win_dw1dtool);

            % Setting enabled values.
            %------------------------
            dw1dutil('Enable',win_dw1dtool,'load_cfs');
        else
            wmemtool('wmb',win_dw1dtool,n_param_anal,ind_act_option,'synt');
        end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));

        % Setting Analysis parameters
        %-----------------------------
        dw1dutil('set_par',win_dw1dtool,option);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Computing
        %-----------
        dw1dfile('anal',win_dw1dtool,'synt');

        % Computing & Drawing.
        %----------------------
        dw1dvdrv('plot_synt',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'stat'
        mousefrm(win_dw1dtool,'watch'); drawnow;
        fig = dw1dstat('create',win_dw1dtool);
        if nargout>0 , out1 = fig; end
        mousefrm(win_dw1dtool,'arrow');
    case 'hist'
        mousefrm(win_dw1dtool,'watch'); drawnow;
        fig = dw1dhist('create',win_dw1dtool);
        if nargout>0 , out1 = fig; end
        mousefrm(win_dw1dtool,'arrow');
    case 'comp'
        mousefrm(win_dw1dtool,'watch'); drawnow;
        dw1dutil('Enable',win_dw1dtool,option);
        fig = dw1dcomp('create',win_dw1dtool);
        if nargout>0 , out1 = fig; end
        mousefrm(win_dw1dtool,'arrow');
    case 'deno'
        mousefrm(win_dw1dtool,'watch'); drawnow;
        dw1dutil('Enable',win_dw1dtool,option);
        fig = dw1ddeno('create',win_dw1dtool);
        if nargout>0 , out1 = fig; end
        mousefrm(win_dw1dtool,'arrow');
    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hld_lin (optional)
        %--------------------------------------
        if in3==1
            % Begin waiting.
            %--------------
            wwaiting('msg',win_dw1dtool, ...
                getWavMSG('Wavelet:commongui:WaitDraw'));

            % Computing
            %-----------
            dw1dfile('comp_ss',win_dw1dtool,in4);

            % Cleaning axes & drawing.
            %------------------------
            dw1dvmod('ss_vm',win_dw1dtool,[1 4 6],1,0);
            dw1dvmod('ss_vm',win_dw1dtool,[2 3 5],1);
            dw1dvmod('ch_vm',win_dw1dtool,2);

            % End waiting.
            %-------------
            wwaiting('off',win_dw1dtool);
        end
        dw1dutil('Enable',win_dw1dtool,option);

    case {'load_sig','import_sig'}
        switch option
            case 'load_sig'
                [sigInfos,Sig_Anal,ok] = ...
                    utguidiv('load_sig',win_dw1dtool,'Signal_Mask',...
                    getWavMSG('Wavelet:commongui:LoadSig'));
                
            case 'import_sig'
                [sigInfos,Sig_Anal,ok] = wtbximport('dw1d');
                if size(Sig_Anal,1)>1 , Sig_Anal = Sig_Anal'; end
                option = 'load_sig';
        end
        if ~ok, return; end
        wtbxappdata('set',win_dw1dtool,...
            'Anal_Data_Info',{Sig_Anal,sigInfos.name});

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
        dw1dutil('clean',win_dw1dtool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option,'');

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,Sig_Anal);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case {'load_cfs','import_cfs'}
        if nargin==2 || isequal(option,'import_cfs')
            switch option
                case 'load_cfs'
                    % Testing file.
                    %--------------
                    [filename,pathname,ok] = utguidiv('load_var',win_dw1dtool,  ...
                        '*.mat',getWavMSG('Wavelet:dw1dRF:Load1DCfs'),...
                        {'coefs','longs'});
                    if ~ok, return; end

                    % Loading file.
                    %--------------
                    load([pathname filename],'-mat');
                    Signal_Name = strtok(filename,'.');
                    
                case 'import_cfs'
                    [ok,S,varName] = wtbximport('cfs1d');
                    if ~ok, return; end
                    filename = ''; pathname = '';
                    coefs = S.coefs;
                    longs = S.longs;
                    Signal_Name = varName;
                    option = 'load_cfs';
            end
            lev = length(longs)-2;
            if lev>max_lev_anal
                wwaiting('off',win_dw1dtool);
                msg = getWavMSG('Wavelet:dw1dRF:LvlTooLarge_msg',max_lev_anal);
                wwarndlg(msg,getWavMSG('Wavelet:dw1dRF:LvlTooLarge_tit'),'block');
                return  
            end
            in3 = '';
        end
        wtbxappdata('del',win_dw1dtool,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
        dw1dutil('clean',win_dw1dtool,option,in3);

        if nargin==2 || isequal(option,'import_cfs')
            % Getting Analysis parameters.
            %-----------------------------
            len         = length(longs);
            Signal_Size = longs(len);
            Level_Anal  = len-2;

            % Setting Analysis parameters
            %-----------------------------
            wmemtool('wmb',win_dw1dtool,n_param_anal,...
                           ind_act_option,option,    ...
                           ind_sig_name,Signal_Name, ...
                           ind_lev_anal,Level_Anal,  ...
                           ind_sig_size,Signal_Size  ...
                           );
            wmemtool('wmb',win_dw1dtool,n_InfoInit,...
                           ind_filename,filename,  ...
                           ind_pathname,pathname   ...
                           );

            % Setting coefs and longs.
            %-------------------------
            wmemtool('wmb',win_dw1dtool,n_coefs_longs, ...
                           ind_coefs,coefs,ind_longs,longs);
        end

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Drawing.
        %---------
        dw1dvdrv('plot_cfs',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case {'load_dec','import_dec'}
        switch option
            case 'load_dec'
                fileMask = {...
                    '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
                    '*.*','All Files (*.*)'};
                [filename,pathname,ok] = utguidiv('load_var',win_dw1dtool, ...
                    fileMask,getWavMSG('Wavelet:dw1dRF:Load1DAnal'),...
                    {'coefs','longs','wave_name','data_name'});
                if ~ok, return; end
                
                % Loading file.
                %--------------
                load([pathname filename],'-mat');
                
            case 'import_dec'
                [ok,S,varName] = wtbximport('dec1d'); 
                if ~ok, return; end
                filename = [];
                pathname = [];
                coefs = S.coefs;
                longs = S.longs;
                data_name = S.data_name;
                wave_name = S.wave_name;
                option = 'load_dec';
        end        
        lev = length(longs)-2;
        if lev>max_lev_anal
            wwaiting('off',win_dw1dtool);
            msg = getWavMSG('Wavelet:dw1dRF:LvlTooLarge_msg',max_lev_anal);
            wwarndlg(msg,getWavMSG('Wavelet:dw1dRF:Load1DAnal'),'block');
            return
        end
        wtbxappdata('del',win_dw1dtool,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
        dw1dutil('clean',win_dw1dtool,option);

        % Getting Analysis parameters.
        %-----------------------------
        len         = length(longs);
        Signal_Size = longs(len);
        Level_Anal  = len-2;
        Signal_Name = data_name;
        Wave_Name   = wave_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal, ...
                       ind_act_option,option,    ...
                       ind_sig_name,Signal_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size  ...
                       );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
                       ind_filename,filename, ...
                       ind_pathname,pathname  ...
                       );

        % Setting coefs and longs.
        %-------------------------
        wmemtool('wmb',win_dw1dtool,n_coefs_longs, ...
                       ind_coefs,coefs,ind_longs,longs);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Computing
        %-----------
        sig_rec = dw1dfile('anal',win_dw1dtool,'load_dec');

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,sig_rec,1);
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);
        
    case 'demo'
        % in3 = Signal_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        %------------------
        Signal_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;

        % Loading file.
        %-------------
        filename = [Signal_Name '.mat'];       
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,Sig_Anal,ok] = ...
            utguidiv('load_dem1D',win_dw1dtool,pathname,filename);
        if ~ok, return; end
        wtbxappdata('del',win_dw1dtool,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitClean'));
        dw1dutil('clean',win_dw1dtool,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,  ...
            ind_act_option,option,      ...
            ind_sig_name,sigInfos.name, ...
            ind_wav_name,Wave_Name,     ...
            ind_lev_anal,Level_Anal,    ...
            ind_sig_size,sigInfos.size  ...
            );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
            ind_filename,sigInfos.filename,  ...
            ind_pathname,sigInfos.pathname   ...
            );

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,Sig_Anal,1);

        % Computing
        %-----------
        dw1dfile('anal',win_dw1dtool);
        
        % Drawing.
        %---------
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('Enable',win_dw1dtool,option);

        % Add or Delete Save APP-Menu
        %------------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        Add_OR_Del_SaveAPPMenu(win_dw1dtool,Level_Anal);
        
        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                                     '*.mat',getWavMSG('Wavelet:commongui:SaveSS'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                     ind_wav_name,ind_thr_val); 
        if length(thrParams)==1
            thrName = 'valTHR';  
            valTHR = thrParams; 
        else
            thrName = 'thrParams';
        end
        x = dw1dfile('ssig',win_dw1dtool); 
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        
        try
          saveStr = name;  
          eval([saveStr '= x ;']);  
        catch %#ok<*CTCH>
          saveStr = 'x';
        end
        wwaiting('off',win_dw1dtool);       
        try
          save([pathname filename],saveStr,thrName,'wname');
        catch          
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_app'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                             '*.mat',getWavMSG('Wavelet:commongui:SaveAS'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        levAPP = get(gcbo,'Position');
        if levAPP<=Level_Anal
            x = dw1dfile('app',win_dw1dtool,levAPP); %#ok<*NASGU>
        else
            x = dw1dfile('app',win_dw1dtool,(1:Level_Anal)); 
        end
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
            saveStr = name;
            eval([saveStr '= x ;']);
        catch
            saveStr = 'x';
        end
        wwaiting('off',win_dw1dtool);       
        try
            save([pathname filename],saveStr);
        catch
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
        
    case 'save_app_cfs'
        % Testing file.
        %--------------
        levAPP = get(gcbo,'Position');
        strTITLE = getWavMSG('Wavelet:dw1dRF:SaveAppCfs',levAPP);
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
            '*.mat',strTITLE);
        if ~ok, return; end
        
        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitSaveCfs'));
        
        % Getting Analysis values.
        %-------------------------
        wname = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name); 
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
            ind_coefs,ind_longs); 
        x = appcoef(coefs,longs,wname,levAPP);
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'x'};
        
        wwaiting('off',win_dw1dtool);
        try
            save([pathname filename],saveStr{:});
        catch
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
        
    case 'save_cfs'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                            '*.mat',getWavMSG('Wavelet:dw1dRF:Save1DCfs'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitSaveCfs'));

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                            ind_wav_name,ind_thr_val);  %#ok<*ASGLU>
        if length(thrParams)==1
            thrName = 'valTHR';
            valTHR = thrParams; 
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wname'};

        wwaiting('off',win_dw1dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
               '*.*','All Files (*.*)'};
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                                     fileMask,getWavMSG('Wavelet:dw1dRF:SaveAnal_1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis parameters.
        %-----------------------------
        [wave_name,data_name,thrParams] = ...
            wmemtool('rmb',win_dw1dtool,n_param_anal, ...
            	ind_wav_name,ind_sig_name,ind_thr_val); 
        if length(thrParams)==1
            thrName = 'valTHR';
            valTHR = thrParams; 
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs); 

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wave_name','data_name'};

        wwaiting('off',win_dw1dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'exp_wrks'
        wwaiting('msg',win_dw1dtool,getWavMSG('Wavelet:commongui:WaitExport'));
        typeEXP = in3;
        switch typeEXP
            case 'sig'
                x = dw1dfile('ssig',win_dw1dtool);
                wtbxexport(x,'name','sig_1D', ...
                    'title',getWavMSG('Wavelet:dw1dRF:Str_SS_Abrev'));
                
            case 'cfs'
                [wname,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                    ind_wav_name,ind_thr_val);
                if length(thrParams)==1
                    thrName = 'valTHR';
                else
                    thrName = 'thrParams';
                end
                [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                    ind_coefs,ind_longs);
                S = struct('coefs',coefs,'longs',longs,thrName,thrParams, ...
                           'wname',wname);
                wtbxexport(S,'name','cfs_1D','title', ...
                    getWavMSG('Wavelet:dw1dRF:Str_sel_cfs'));
                
            case 'dec'
                [wname,data_name,thrParams] = ...
                    wmemtool('rmb',win_dw1dtool,n_param_anal, ...
                                   ind_wav_name,ind_sig_name,ind_thr_val);
                if length(thrParams)==1
                    thrName = 'valTHR';
                else
                    thrName = 'thrParams';
                end
                [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                    ind_coefs,ind_longs);
                S = struct('coefs',coefs,'longs',longs,thrName,thrParams, ...
                        'wave_name',wname,'data_name',data_name);
                wtbxexport(S,'name','dec_1D', ...
                    'title',getWavMSG('Wavelet:dw1dRF:Str_Dec'));
                
            case 'app'
                [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                    ind_coefs,ind_longs);
                [wname,level] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                    ind_wav_name,ind_lev_anal);                
                A = wrmcoef('a',coefs,longs,wname,1:level);
                wtbxexport(A,'name','approximations_1D', ...
                    'title',getWavMSG('Wavelet:dw1dRF:Str_app_sig'));
                
            case 'det'
                [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                    ind_coefs,ind_longs);
                wname = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                    ind_wav_name);                
                D = wrmcoef('d',coefs,longs,wname);
                wtbxexport(D,'name','details_1D', ...
                    'title',getWavMSG('Wavelet:dw1dRF:Str_det_sig'));
        end
        wwaiting('off',win_dw1dtool);       

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end


%--------------------------------------------------------------------------
function Add_OR_Del_SaveAPPMenu(win_tool,Level_Anal)

% Add or Delete Save APP-Menu
%------------------------------
Men_Save_APP = ...
    findobj(win_tool,'Type','uimenu','Tag','Men_Save_APP');
child = get(Men_Save_APP,'Children');
delete(child);

for k = 1:Level_Anal
    uimenu(Men_Save_APP,'Label',getWavMSG('Wavelet:dw1dRF:App',k),...
        'Position',k, ...
        'Callback',@(~,~)dw1dmngr('save_app',win_tool)  ...
        );
end
uimenu(Men_Save_APP,'Label',getWavMSG('Wavelet:dw1dRF:AllApp'), ...
    'Position',Level_Anal+1,'Separator','On', ...
    'Callback',@(~,~)dw1dmngr('save_app',win_tool)  ...
    );
Men_Save_APP_CFS = ...
    findobj(win_tool,'Type','uimenu','Tag','Men_Save_APP_CFS');
child = get(Men_Save_APP_CFS,'Children');
delete(child);
for k = 1:Level_Anal
    uimenu(Men_Save_APP_CFS,'Label',getWavMSG('Wavelet:dw1dRF:CfsOfA',k), ...
        'Position',k, ...
        'Callback',@(~,~)dw1dmngr('save_app_cfs',win_tool)  ...
        );
end
%--------------------------------------------------------------------------
