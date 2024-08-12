function varargout = cf1dtool(option,varargin)
%CF1DTOOL Wavelet Coefficients Selection 1-D tool.
%   VARARGOUT = CF1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 0
   iClose = ~isempty(option) && ischar(option) && strcmpi(option,'close');
else
   iClose = false;    
end
% DDUX data logging
if nargin == 0 && ~iClose
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
        "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "cf1dtool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 9;

% Stem parameters.
%-----------------
absMode = 0;
appView = 1;

% Memory Blocs of stored values.
%===============================
% MB0.
%-----
n_membloc0 = 'MB0';
ind_sig    = 1;
ind_coefs  = 2;
ind_longs  = 3;
ind_first  = 4;
ind_last   = 5;
ind_sort   = 6;
ind_By_Lev = 7;
ind_sizes  = 8;  % Dummy
nb0_stored = 8;

% MB1.
%-----
n_param_anal = 'MB1';
ind_sig_name =  1;
ind_sig_size =  2;
ind_wav_name =  3;
ind_lev_anal =  4;
nb1_stored   =  4;

% MB2.
%-----
n_InfoInit   = 'MB2';
ind_filename =  1;
ind_pathname =  2;
nb2_stored   =  2;

% MB3.
%-----
n_synt_sig = 'MB3';
% ind_ssig   =  1;
nb3_stored =  1;

% MB4.
%-----
n_miscella     = 'MB4';
ind_graph_area =  1;
ind_axe_hdl    =  2;
ind_lin_hdl    =  3;
nb4_stored     =  3;

if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
  case {'create','close'} 
  otherwise
    toolATTR = wfigmngr('getValue',win_tool,'ToolATTR');
    hdl_UIC  = toolATTR.hdl_UIC;
    hdl_MEN  = toolATTR.hdl_MEN;
    pus_ana  = hdl_UIC.pus_ana;
    chk_sho  = hdl_UIC.chk_sho;
end
switch option
  case 'create'
    % Get Globals.
    %--------------
    [Def_Btn_Height,Def_Btn_Width,Y_Spacing] = ...
        mextglob('get','Def_Btn_Height','Def_Btn_Width','Y_Spacing');

    % Window initialization.
    %----------------------
    win_title = getWavMSG('Wavelet:divGUIRF:CF1D_Name');
    [win_tool,pos_win,win_units,~,...
        pos_frame0,Pos_Graphic_Area] = ...
           wfigmngr('create',win_title,winAttrb,'ExtFig_Tool_3',mfilename,1,1,0);
    if nargout> 0 , varargout{1} = win_tool; end
	
	% Add Help for Tool.
	%------------------
	wfighelp('addHelpTool',win_tool, ...
        getWavMSG('Wavelet:divGUIRF:CF1D_HLP_Sel'),'CF1D_GUI');
	
    % Menu construction.
    %-------------------
    m_files = wfigmngr('getmenus',win_tool,'file');	
    m_load  = uimenu(m_files, ...
        'Label',getWavMSG('Wavelet:commongui:LoadSig'), ...
        'Position',1, ...
        'Tag','Load', ...
        'Callback',@(~,~)cf1dtool('load', win_tool)  ...
        );
    m_save = uimenu(m_files,...
                    'Label',getWavMSG('Wavelet:commongui:SaveSS'), ...
                    'Position',2,     ...
                    'Enable','Off',   ...
                    'Tag','Save',     ...
                    'Callback',       ...
                    @(~,~)cf1dtool('save', win_tool) ...
                    );
    m_demo = uimenu(m_files,'Label', ...
        getWavMSG('Wavelet:commongui:Lab_Example'),'Position',3);
    uimenu(m_files, ...
        'Label',getWavMSG('Wavelet:commongui:Str_ImpSig'),   ...
        'Position',4,'Separator','On',...
        'Tag','Import', ...
        'Callback',@(~,~)cf1dtool('load', win_tool,'wrks')...
        );
     m_exp_sig = uimenu(m_files, ...
        'Label',getWavMSG('Wavelet:commongui:Str_ExpSig'),   ...
        'Position',5,'Enable','Off','Separator','Off',...
        'Tag','Export', ...
        'Callback',@(~,~)cf1dtool('exp_wrks', win_tool) ...
        );
               
    m_demo_1 = uimenu(m_demo, ...
        'Label',getWavMSG('Wavelet:divGUIRF:BasicSig'), ...
        'Tag','BasicSig');
    m_demo_2 = uimenu(m_demo,'Label', ...
        getWavMSG('Wavelet:divGUIRF:NoisySig'));
    m_demo_3 = uimenu(m_demo, ...
        'Label',getWavMSG('Wavelet:divGUIRF:NoisySig_Mov'), ...
        'Tag','NoisySig_Mov');
	
    % Submenu of test signals.
    %-------------------------
    names = { ...
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_sumsin');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_freqbrk');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_whitnois');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_warma');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_noispol');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_noispol');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wstep');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_nearbrk');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_nearbrk');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_scddvbrk');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_scddvbrk');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wnoislop');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_cnoislop');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_noissin');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_trsin');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wntrsin');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_leleccum');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wcantor');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_vonkoch')
        };

    files = [ 'sumsin  ' ; 'freqbrk ' ; 'whitnois' ; 'warma   ' ; ...
              'noispol ' ; 'noispol ' ; 'wstep   ' ; 'nearbrk ' ; ...
              'nearbrk ' ; 'scddvbrk' ; 'scddvbrk' ; 'wnoislop' ; ...
              'cnoislop' ; 'noissin ' ; 'trsin   ' ; 'wntrsin ' ; ...
              'leleccum' ; 'wcantor ' ; 'vonkoch '                    ];

    waves = ['db3' ; 'db5' ; 'db3' ; 'db3' ; 'db2' ; 'db3' ; 'db2' ; ...
             'db2' ; 'db7' ; 'db1' ; 'db4' ; 'db3' ; 'db3' ; 'db5' ; ...
             'db5' ; 'db5' ; 'db3' ; 'db1' ; 'db1'                      ];

    levels = ['5';'5';'5';'5';'4';'4';'5';'5';'5';'2';'2';'6';'6';'5';...
                    '6';'7';'5';'5';'5'];

    for i=1:size(files,1)
        libel = getWavMSG('Wavelet:divGUIRF:WT_Example', ...
                    waves(i,:),levels(i,:),names{i});
        action = @(~,~)cf1dtool('demo', win_tool, files(i,:) , ...
            waves(i,:), str2double(levels(i,:)));
        uimenu(m_demo_1,'Label',libel,'Callback',action);
    end

    names = {...
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NHeavySin');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NQdchirp');
        getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Nmishmash')
        };
    files      = [ 'noisbloc' ; 'noisbump' ; 'heavysin' ; ...
                   'noisdopp' ; 'noischir' ; 'noismima'      ];
    waves  = ['sym8';'sym4';'sym8';'sym4';'db1 ';'db3 '];
    levels = ['5';'5';'5';'5';'5';'5'];

    for i=1:size(files,1)
        libel = getWavMSG('Wavelet:divGUIRF:WT_Example', ...
                    waves(i,:),levels(i,:),names{i});
        action = @(~,~)cf1dtool('demo', win_tool, files(i,:), ...
            waves(i,:), str2double(levels(i,:)));
        uimenu(m_demo_2,'Label',libel,'Callback',action);
    end

    for i=1:size(files,1)
        libel = getWavMSG('Wavelet:divGUIRF:WT_Example', ...
                    waves(i,:),levels(i,:),names{i});
        action = @(~,~)cf1dtool('demo', win_tool, files(i,:), ...
                               waves(i,:), str2double(levels(i,:)) , ...
                               {'Stepwise'});
        uimenu(m_demo_3,'Label',libel,'Callback',action);
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitInit'));

    % General parameters initialization.
    %-----------------------------------
    dy = Y_Spacing;
 
    % Command part of the window.
    %============================
    % Data, Wavelet and Level parameters.
    %------------------------------------
    xlocINI = pos_frame0([1 3]);
    ytopINI = pos_win(4)-dy;
    toolPos = utanapar('create',win_tool, ...
                  'xloc',xlocINI,'top',ytopINI,...
                  'Enable','off', ...
                  'wtype','dwt'   ...
                  );
 
    w_uic   = 1.5*Def_Btn_Width;
    h_uic   = 1.5*Def_Btn_Height;
    bdx     = (pos_frame0(3)-w_uic)/2;
    x_left  = pos_frame0(1)+bdx;
    y_low   = toolPos(2)-1.5*Def_Btn_Height-2*dy;
    pos_ana = [x_left, y_low, w_uic, h_uic];

    commonProp = {...
        'Parent',win_tool, ...
        'Units',win_units,  ...
        'Enable','off'     ...
        };

    str_ana = getWavMSG('Wavelet:commongui:Str_Anal');
    cba_ana = @(~,~)cf1dtool('anal', win_tool);
    pus_ana = uicontrol(commonProp{:},...
                         'Style','pushbutton', ...
                         'Position',pos_ana,   ...
                         'String',str_ana,     ...
                         'Callback',cba_ana,   ...
                         'Tag','Pus_Anal',...
                         'Interruptible','On'  ...
                         );

    % Create coefficients tool.
    %--------------------------
    ytopCFS = pos_ana(2)-4*dy;
    toolPos = utnbcfs('create',win_tool,...
                      'toolOPT','cf1d',  ...
                      'xloc',xlocINI,'top',ytopCFS);

    % Create show checkbox.
    %----------------------
    w_uic = (3*pos_frame0(3))/4;
    x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
    h_uic = Def_Btn_Height;
    y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
    pos_chk_sho = [x_uic, y_uic, w_uic, h_uic];
    str_chk_sho = getWavMSG('Wavelet:divGUIRF:Show_OriSig');
    chk_sho = uicontrol(commonProp{:},...
                        'Style','checkbox',     ...
                        'Visible','on',         ...
                        'Position',pos_chk_sho, ...
                        'Tag','Chk_Sho',        ...
                        'String',str_chk_sho    ...
                        );

    %  Normalization.
    %----------------
    Pos_Graphic_Area = wfigmngr('normalize',win_tool, ...
        Pos_Graphic_Area,'On');
 
    % Axes construction.
    %------------------
    ax     = zeros(4,1);
    pos_ax = zeros(4,4);
    bdx = 0.05;
     ecy_top = 0.04;
    ecy_bot = 0.04;
    ecy_mid = 0.06;
    w_ax = (Pos_Graphic_Area(3)-3*bdx)/2;
    h_ax = (Pos_Graphic_Area(4)-ecy_top-ecy_mid-ecy_bot)/3;
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+Pos_Graphic_Area(4)-ecy_top-h_ax;
    pos_ax(1,:) = [x_ax y_ax w_ax h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(4,:) = [x_ax y_ax w_ax h_ax];
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+ecy_bot;
    pos_ax(2,:) = [x_ax y_ax w_ax 2*h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(3,:) = [x_ax y_ax w_ax 2*h_ax];
    for k = 1:4
        ax(k) = axes(...
            'Parent',win_tool,      ...
            'Units','normalized',    ...
            'Position',pos_ax(k,:), ...
            'XTick',[],'YTick',[],  ...
            'Box','on',             ...
            'Visible','off'         ...
            );  %#ok<*LAXES>
    end

    % Callbacks update.
    %------------------
    hdl_den = utnbcfs('handles',win_tool);
    utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
    pop_lev = utanapar('handles',win_tool,'lev');
    tmp     = [pop_lev chk_sho];

    cba_pop_lev = @(~,~)cf1dtool('update_level', win_tool , tmp);
    cba_chk_sho = @(~,~)cf1dtool('show_ori_sig', win_tool);
    set(pop_lev,'Callback',cba_pop_lev);
    set(chk_sho,'Callback',cba_chk_sho);

    % Memory for stored values.
    %--------------------------
    hdl_UIC  = struct('pus_ana',pus_ana,'chk_sho',chk_sho);
    hdl_MEN  = struct('m_load',m_load,'m_save',m_save, ...
        'm_demo',m_demo,'m_exp_sig',m_exp_sig);
    toolATTR = struct('hdl_UIC',hdl_UIC,'hdl_MEN',hdl_MEN);
    wfigmngr('storeValue',win_tool,'ToolATTR',toolATTR);
    hdl_STEM = struct(...
                      'Hstems_O',[], ...
                      'H_vert_O',[], ...
                      'H_stem_O',[], ...
                      'H_vert_O_Copy',[], ...
                      'H_stem_O_Copy',[], ...
                      'Hstems_M',[], ...
                      'H_vert_M',[], ...
                      'H_stem_M',[], ...
                      'H_vert_M_Copy',[], ...
                      'H_stem_M_Copy',[]  ...
                      );
    wfigmngr('storeValue',win_tool,'Stems_struct',hdl_STEM);
    wmemtool('ini',win_tool,n_InfoInit,nb0_stored);
    wmemtool('ini',win_tool,n_param_anal,nb1_stored);
    wmemtool('ini',win_tool,n_membloc0,nb2_stored);
    wmemtool('ini',win_tool,n_synt_sig,nb3_stored);
    wmemtool('ini',win_tool,n_miscella,nb4_stored);
    wmemtool('wmb',win_tool,n_miscella,...
                   ind_graph_area,Pos_Graphic_Area,ind_axe_hdl,ax);

    % End waiting.
    %---------------
    wwaiting('off',win_tool);

  case 'load'
    if length(varargin)<2       % LOAD SIGNAL
       [sigInfos,sig_Anal,ok] = ...
            utguidiv('load_sig',win_tool,'Signal_Mask', ...
            getWavMSG('Wavelet:commongui:LoadSig'));
        demoFlag = 0;
    elseif isequal(varargin{2},'wrks')  % LOAD from WORKSPACE
        [sigInfos,sig_Anal,ok] = wtbximport('1d');
        demoFlag = 0;
    else                        % DEMO
        sig_Name = deblank(varargin{2});
        wav_Name = deblank(varargin{3});
        lev_Anal = varargin{4};
        filename = [sig_Name '.mat'];
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,sig_Anal,ok] = ...
            utguidiv('load_dem1D',win_tool,pathname,filename);
        demoFlag = 1;
    end
    if ~ok, return; end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitLoad'));

    % Get Values.
    %------------
    axe_hdl = wmemtool('rmb',win_tool,n_miscella,ind_axe_hdl);

    % Cleaning.
    %----------
    dynvtool('stop',win_tool);
    utnbcfs('clean',win_tool)
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','Off');
    set(axe_hdl(2:end),'Visible','Off');
    children = get(axe_hdl,'Children');
    children = cat(1,children{:});
    if ~isempty(children) , delete(children); end
    set(axe_hdl,'XTick',[],'YTick',[],'Box','on');

    % Setting GUI values.
    %--------------------
    sig_Name = sigInfos.name;
    sig_Size = sigInfos.size;
    sig_Size = max(sig_Size);
    levm     = wmaxlev(sig_Size,'haar');
    levmax   = min(levm,max_lev_anal);
    lev      = min(levmax,5);
    str_lev_data = int2str((1:levmax)');
    if ~demoFlag
        cbanapar('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'lev',{'String',str_lev_data,'Value',lev});
    else
        cbanapar('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'wav',wav_Name, ...
                 'lev',{'String',str_lev_data,'Value',lev_Anal});
        lev = lev_Anal;
    end
    set(chk_sho,'Value',0)
    cf1dtool('position',win_tool,lev,chk_sho);

    % Drawing.
    %---------
    axeAct = axe_hdl(1);
    lsig   = length(sig_Anal);
    wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axeAct);
    col_s = wtbutils('colors','sig');
    lin_hdl(1) = line(...
      'Parent',axeAct,  ...
      'XData',(1:lsig), ...
      'YData',sig_Anal, ...
      'Color',col_s,'Visible','on'...
      );
    ymin = min(sig_Anal);
    ymax = max(sig_Anal);
    dy   = (ymax-ymin)/20;
    set(axeAct,...
        'XLim',[1 lsig],'YLim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto','Visible','on' ...
        );
    axeAct = axe_hdl(4);
    wtitle(getWavMSG('Wavelet:commongui:Str_SynSig'),'Parent',axeAct);
    lin_hdl(2) = line(...
      'Parent',axeAct,  ...
      'XData',(1:lsig), ...
      'YData',sig_Anal, ...
      'Color',col_s,'Visible','off'...
      );
    col_ss = wtbutils('colors','ssig');
    lin_hdl(3) = line(...
      'Parent',axeAct,  ...
      'XData',(1:lsig), ...
      'YData',sig_Anal, ...
      'Color',col_ss,'Visible','off'...
      );
    set(axeAct,...
        'XLim',[1 lsig],'YLim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto'     ...
        );

    % Setting Analysis parameters.
    %-----------------------------
    wmemtool('wmb',win_tool,n_membloc0,ind_sig,sig_Anal);
    wmemtool('wmb',win_tool,n_param_anal, ...
                   ind_sig_name,sigInfos.name,...
                   ind_sig_size,sigInfos.size ...
                   );
    wmemtool('wmb',win_tool,n_InfoInit, ...
                   ind_filename,sigInfos.filename, ...
                   ind_pathname,sigInfos.pathname  ...
                   );

    % Store Values.
    %--------------
    wmemtool('wmb',win_tool,n_miscella,ind_lin_hdl,lin_hdl);

    % Setting enabled values.
    %------------------------
    utnbcfs('set',win_tool,'handleORI',lin_hdl(1),'handleTHR',lin_hdl(3))
    cbanapar('Enable',win_tool,'on');
    set(pus_ana,'Enable','On' );
 
    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'demo'
    cf1dtool('load',varargin{:})
    if length(varargin)>4 
        parDEMO = varargin{5};
    else
        parDEMO = {'Global'};
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));

    % Computing.
    %-----------
    cf1dtool('anal',win_tool);
    pause(1)
    utnbcfs('demo',win_tool,parDEMO);

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'save'
    % Testing file.
    %--------------
    [filename,pathname,ok] = utguidiv('test_save',win_tool, ...
                            '*.mat',getWavMSG('Wavelet:commongui:SaveSS'));
    if ~ok, return; end

    % Begin waiting.
    %--------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitSave'));

    % Getting Synthesized Signal.
    %---------------------------
    wname   = wmemtool('rmb',win_tool,n_param_anal,ind_wav_name); %#ok<NASGU>
    lin_hdl = wmemtool('rmb',win_tool,n_miscella,ind_lin_hdl);
    lin_hdl = lin_hdl(3);
    x     = get(lin_hdl,'YData'); %#ok<NASGU>

    % Saving file.
    %--------------
    [name,ext] = strtok(filename,'.');
    if isempty(ext) || isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    try
      eval([name ' = x ;']);
    catch %#ok<CTCH>
      name = 'x';
    end
    saveStr = {name,'wname'};
    wwaiting('off',win_tool);
    try
      save([pathname filename],saveStr{:});
    catch %#ok<CTCH>
      errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
    end

  case 'exp_wrks'
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitExport'));
    lin_hdl = wmemtool('rmb',win_tool,n_miscella,ind_lin_hdl);
    x = get(lin_hdl(3),'YData');
    wtbxexport(x,'name','sig_1D', ...
        'title',getWavMSG('Wavelet:commongui:Str_Sig'));
    wwaiting('off',win_tool);        
    
  case 'anal'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));
 
    % Reading Analysis Parameters.
    %-----------------------------
    sig_Anal = wmemtool('rmb',win_tool,n_membloc0,ind_sig);
    [wav_Name,lev_Anal] = cbanapar('get',win_tool,'wav','lev');

    % Setting Analysis parameters
    %-----------------------------
    wmemtool('wmb',win_tool,n_param_anal, ...
                   ind_wav_name,wav_Name, ...
                   ind_lev_anal,lev_Anal ...
                   );
    % Get Values.
    %------------
    [axe_hdl,lin_hdl] = wmemtool('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Analyzing.
    %-----------
    [coefs,longs] = wavedec(sig_Anal,lev_Anal,wav_Name);
    [tmp,idxsort] = sort(abs(coefs)); %#ok<ASGLU>
    last  = cumsum(longs(1:end-1));
    first = ones(size(last));
    first(2:end) = last(1:end-1)+1;
    len = length(last);
    idxByLev = cell(1,len);
    for k=1:len
        idxByLev{k} = find((first(k)<=idxsort) & (idxsort<=last(k)));
    end

    % Writing coefficients.
    %----------------------
    wmemtool('wmb',win_tool,n_membloc0,...
             ind_coefs,coefs,ind_longs,longs, ...
             ind_first,first,ind_last,last, ...
             ind_sort,idxsort,ind_By_Lev,idxByLev,...
             ind_sizes,[]);
 
    % Clean axes and reset dynvtool.
    %-------------------------------
    children = get(axe_hdl(2:3),'Children');
    children = children{:};
    if ~isempty(children) , delete(children); end
    set(axe_hdl(2:3),'YTickLabel',[],'YTick',[]);
    dynvtool('ini_his',win_tool,'reset')

    % Plot original decomposition.
    %-----------------------------
    xlim = [1,length(sig_Anal)];
    set(axe_hdl(1:4),'XLim',xlim);
    ax_prop = {'XLim',xlim,'box','on','XtickMode','auto','Visible','On'};
    axeAct = axe_hdl(2);
    Hstems_O = dw1dstem(axeAct,coefs,longs,absMode,appView,'WTBX');
    HS = Hstems_O; HS = HS(ishandle(HS)); set(HS,'MarkerSize',4);
    set(axeAct,ax_prop{:});
    wtitle(getWavMSG('Wavelet:commongui:OriCfs'),'Parent',axeAct);

    % Plot modified decomposition.
    %-----------------------------
    axeAct = axe_hdl(3);
    Hstems_M = dw1dstem(axeAct,coefs,longs,absMode,appView,'WTBX');
    HS = Hstems_M; HS = HS(ishandle(HS)); set(HS,'MarkerSize',4);
    set(axeAct,ax_prop{:});
    wtitle(getWavMSG('Wavelet:commongui:SelCfs'),'Parent',axeAct);

    % Plot signal and synthesized signal.
    %------------------------------------
    axeAct = axe_hdl(4);
    set(axeAct,'Visible','on');
    set(lin_hdl(3),'YData',sig_Anal,'Visible','on');

    % Reset tool coefficients.
    %-------------------------
    utnbcfs('update_NbCfs',win_tool,'anal');
    utnbcfs('update_methode',win_tool,'anal');
    utnbcfs('Enable',win_tool,'anal');
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','On');

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtool('set_Stems_HDL',win_tool,'anal',Hstems_O,Hstems_M);

    % Connect dynvtool.
    %------------------
    params = [double(axe_hdl(2:3)') , -lev_Anal];
    dynvtool('init',win_tool,[],axe_hdl,[],[1 0], ...
            '','','cf1dcoor',params,'cf1dselc',params);

    % End waiting.
    %-------------
    wwaiting('off',win_tool);
        
  case 'apply'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));
 
    % Analysis Parameters.
    %--------------------
    [first,idxsort,idxByLev] = ...
        wmemtool('rmb',win_tool,n_membloc0,ind_first,ind_sort,ind_By_Lev);
    [identMeth,nbkept] = utnbcfs('get',win_tool,'identmeth','nbkept');
    len = length(idxByLev);

    switch identMeth
      case {'Global','ByLevel'}
        [dummy,dim] = max(size(idxByLev{1})); %#ok<ASGLU>
        ind = [];
        switch dim
            case 1
                 for k=1:len
                    ind = [ind ; idxByLev{k}(end-nbkept(k)+1:end)]; %#ok<AGROW>
                 end               
            case 2
                for k=1:len
                    ind = [ind , idxByLev{k}(end-nbkept(k)+1:end)]; %#ok<AGROW>
                end
        end
        idx_Cfs = idxsort(ind);

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtool('plot_NewDec',win_tool,idx_Cfs,identMeth);

        % Construction of the invisible Stems.
        %-------------------------------------
        cf1dtool('set_Stems_HDL',win_tool,'apply',Hstems_M);

      case {'Manual'}
        [H_stem_O,H_stem_O_Copy] = ...
            cf1dtool('get_Stems_HDL',win_tool,'Manual');
        idx_Cfs = [];
        for k=1:len
            y = len+1-k;
            x_stem = get(H_stem_O(y),'XData');
            x_stem_Copy = get(H_stem_O_Copy(y),'XData');
            TF = ismember(x_stem,x_stem_Copy);
            Idx     = find(TF==1);
            idx_Cfs = [idx_Cfs , Idx+first(k)-1]; %#ok<AGROW>
        end

        % Computing & Drawing.
        %---------------------
        cf1dtool('plot_NewDec',win_tool,idx_Cfs,identMeth);
    end 

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'Apply_Movie'
    movieSET = varargin{2};
    if isempty(movieSET)
        cf1dtool('plot_NewDec',win_tool,[],'Stepwise');
        return
    end
    nbInSet = length(movieSET);  
    appFlag = varargin{3};
    popStop = varargin{4};

    % Waiting message.
    %-----------------
    m_File = wfindobj(win_tool,'type','uimenu','tag','figMenuFile');
    btn_Close = wfindobj(win_tool,'style','pushbutton','tag','Pus_Close_Win');
    set([m_File,btn_Close],'Enable','Off');
    if nbInSet>1
        txt_msg = wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));
    end

    % Get Analysis Parameters.
    %-------------------------
    [first,last,idxsort,idxByLev] = ...
        wmemtool('rmb',win_tool,n_membloc0, ...
                       ind_first,ind_last,ind_sort,ind_By_Lev);

    % Computing.
    %-----------
    len = length(last);
    nbKept = zeros(1,len+1);
    switch appFlag
      case 1
        idx_App = idxsort(idxByLev{1});
        App_Len = length(idx_App);
        idxsort(idxByLev{1}) = [];

      case 2
        idx_App = [];
        App_Len = 0;
       
      case 3
        idx_App = [];
        App_Len = 0;       
        idxsort(idxByLev{1}) = [];
    end
    for jj = 1:nbInSet
        nbcfs = movieSET(jj);
        nbcfs  = nbcfs-App_Len;
        if isrow(idx_App) && isrow(idxsort)
            idx_Cfs = cat(2,idx_App,idxsort(end-nbcfs+1:end));
        else
            idx_Cfs = cat(1,idx_App,idxsort(end-nbcfs+1:end));
        end
        %idx_Cfs = [idx_App , idxsort(end-nbcfs+1:end)];
        if nbInSet>1  
            for k=1:len
              dummy  = find((first(k)<=idx_Cfs) & (idx_Cfs<=last(k)));
              nbKept(k) = length(dummy);
            end
            nbKept(end) = sum(nbKept(1:end-1));
            msg2 = [int2str(nbKept(end)) '  = [' int2str(nbKept(1:end-1)) ']'];            
            msg  = {' ',getWavMSG('Wavelet:divGUIRF:NbKeptCfs', msg2)}; 
            set(txt_msg,'String',msg);
        end

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtool('plot_NewDec',win_tool,idx_Cfs,'Stepwise');

        if nbInSet>1  
            % Test for stopping.
            %-------------------
            user = get(popStop,'UserData');
            if isequal(user,1)
               set(popStop,'UserData',[]);
               break
            end
            pause(0.1);
        end
    end

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtool('set_Stems_HDL',win_tool,'apply',Hstems_M);

    % End waiting.
    %-------------
    set([m_File,btn_Close],'Enable','On');
    if nbInSet>1 , wwaiting('off',win_tool); end

  case {'select','unselect'}
     OK_Select = isequal(option,'select');

     % Find Select Box.
     %-----------------
     [X,Y] = mngmbtn('getbox',win_tool);
     xmin = ceil(min(X));
     xmax = floor(max(X));
     ymin = min(Y);
     ymax = max(Y);

     % Get stored Stems.
     %------------------
     [H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy,...
      H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy] = ...
          cf1dtool('get_Stems_HDL',win_tool,'allComponents'); %#ok<ASGLU>
     nb_Stems = length(H_stem_O);

     % Find points.
     %-------------         
     nbKept = utnbcfs('get',win_tool,'nbKept');
     ylow = max(1,floor(ymin));
     ytop = min(ceil(ymax),nb_Stems);
     for y = ylow:ytop
        xy_stem      = get(H_stem_O(y),{'XData','YData'});
        xy_stem_Copy = get(H_stem_O_Copy(y),{'XData','YData'});
        Idx = find(xmin<=xy_stem{1} & xy_stem{1}<=xmax & ...
                   ymin<=xy_stem{2} & xy_stem{2}<=ymax);
        if OK_Select
            Idx = Idx(~ismember(xy_stem{1}(Idx),xy_stem_Copy{1}));
        else
            Idx = find(ismember(xy_stem_Copy{1},xy_stem{1}(Idx)));
        end
        if ~isempty(Idx)
            xy_vert_Copy = get(H_vert_O_Copy(y),{'XData','YData'});
            if OK_Select
                xy_stem_Copy{1} = [xy_stem_Copy{1} , xy_stem{1}(Idx)];
                xy_stem_Copy{2} = [xy_stem_Copy{2} , xy_stem{2}(Idx)];
                tmp = [xy_stem{1}(Idx); xy_stem{1}(Idx) ; xy_stem{1}(Idx)];
                xy_vert_Copy{1} = [xy_vert_Copy{1} , tmp(:)'];
                nbIdx = length(Idx);
                tmp = [y*ones(1,nbIdx); xy_stem{2}(Idx) ; NaN*ones(1,nbIdx)];
                xy_vert_Copy{2} = [xy_vert_Copy{2} , tmp(:)'];
            else
                xy_stem_Copy{1}(Idx) = [];
                xy_stem_Copy{2}(Idx) = [];
                Idx = 3*Idx-4;
                Idx = [Idx,Idx+1,Idx+2]; %#ok<AGROW>
                xy_vert_Copy{1}(Idx) = [];
                xy_vert_Copy{2}(Idx) = [];
            end
            set([H_stem_O_Copy(y),H_stem_M_Copy(y)],...
                'XData',xy_stem_Copy{1},...
                'YData',xy_stem_Copy{2} ...
                );
            set([H_vert_O_Copy(y),H_vert_M_Copy(y)],...
                'XData',xy_vert_Copy{1},...
                'YData',xy_vert_Copy{2} ...
                );        
            nbInd = length(xy_stem_Copy{1})-1;
            nbKept(nb_Stems+1-y) = nbInd;
        end               
     end
     nbKept(end) = sum(nbKept(1:end-1));
     utnbcfs('set',win_tool,'nbKept',nbKept);

  case 'plot_NewDec'
    % Indices of preserved coefficients & Methode.
    %---------------------------------------------
    idx_Cfs  = varargin{2};
    identMeth = varargin{3};
    
    % Get Handles.
    %-------------
    [axe_hdl,lin_hdl] = wmemtool('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Get Analysis Parameters.
    %-------------------------
    wav_Name = wmemtool('rmb',win_tool,n_param_anal,ind_wav_name);
    [coefs,longs] = wmemtool('rmb',win_tool,n_membloc0,ind_coefs,ind_longs);

    % Compute synthesized signal.
    %---------------------------
    Cnew = zeros(size(coefs));
    Cnew(idx_Cfs) = coefs(idx_Cfs);
    SS  = waverec(Cnew,longs,wav_Name);

    % Plot modified decomposition.
    %-----------------------------
    xlim    = get(axe_hdl(1),'XLim');
    ax_prop = {'XLim',xlim,'box','on'};
    axeAct = axe_hdl(3);
    if ~isequal(identMeth,'Manual')
        varargout{1} = dw1dstem(axeAct,Cnew,longs,absMode,appView,'WTBX');
        set(axeAct,ax_prop{:});
        HS = varargout{1}; HS = HS(ishandle(HS)); set(HS,'MarkerSize',4)
    else
        varargout{1} = [];
    end

    % Plot synthesized signal.
    %-------------------------
    axeAct = axe_hdl(4);
    set(lin_hdl(3),'YData',SS);
    cf1dtool('show_ori_sig',win_tool)
    set(axeAct,...
        'XLim',xlim,  ...
        'XtickMode','auto','YtickMode','auto', ...
        'Box','on'  ...
        );
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','On');   

  case 'get_Stems_HDL'
    % Output parameter.
    %------------------
    mode = varargin{2};

    % Get stored Stems.
    %------------------
    hdl_STEM  = wfigmngr('getValue',win_tool,'Stems_struct');
    varargout = struct2cell(hdl_STEM);
    if isequal(mode,'All') , return; end
    
    [...
     Hstems_O,H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
     Hstems_M,H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy  ...
     ] = deal(varargout{:}); %#ok<ASGLU>
     switch mode
       case 'allComponents'
         varargout = {... 
           H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
           H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy};

       case 'Manual'
         varargout = {H_stem_O,H_stem_O_Copy};
     end

  case 'set_Stems_HDL'
    mode = varargin{2};
    axe_hdl  = wmemtool('rmb',win_tool,n_miscella,ind_axe_hdl);
    lev_Anal = wmemtool('rmb',win_tool,n_param_anal,ind_lev_anal);
    nb_STEMS = lev_Anal+1;
    hdl_STEM = wfigmngr('getValue',win_tool,'Stems_struct'); 
    switch mode
      case 'anal'
        Hstems_O = varargin{3};
        Hstems_M = varargin{4};

        % Construction of the invisible duplicated coefficients axes.
        %------------------------------------------------------------
        [H_vert_O,H_stem_O,Hstems_O] = extractSTEMS(Hstems_O);
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);

        % Store values.
        %--------------
        hdl_STEM.Hstems_O = Hstems_O;
        hdl_STEM.H_vert_O = H_vert_O;
        hdl_STEM.H_stem_O = H_stem_O;
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'apply'
        Hstems_M = varargin{3};

        % Modification of Stems.
        %-----------------------
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'reset'
        identMeth = varargin{3};
        hdl_DEL = [hdl_STEM.H_vert_O_Copy,hdl_STEM.H_stem_O_Copy,...
                   hdl_STEM.H_vert_M_Copy,hdl_STEM.H_stem_M_Copy];

        hdl_DEL = hdl_DEL(ishandle(hdl_DEL));
        delete(hdl_DEL)
        if ~isempty(hdl_STEM.Hstems_M)
            HDL_VIS = hdl_STEM.Hstems_M(:,(2:4));
            HDL_VIS = HDL_VIS(ishandle(HDL_VIS(:)));
        else
            HDL_VIS = [];
        end
        switch identMeth
          case {'Global','ByLevel','Stepwise'}
            H_vert_O_Copy = [];  H_stem_O_Copy = [];
            H_vert_M_Copy = [];  H_stem_M_Copy = [];
            if ~isequal(identMeth,'Stepwise')
                vis_VIS = 'On';
            else
                vis_VIS = 'Off';
            end

          case {'Manual'}
            [H_vert_O_Copy,H_stem_O_Copy] = initSTEMS(axe_hdl(2),nb_STEMS);
            [H_vert_M_Copy,H_stem_M_Copy] = initSTEMS(axe_hdl(3),nb_STEMS);
            HDL_Copy = [H_vert_O_Copy(:);H_stem_O_Copy(:);...
                        H_vert_M_Copy(:);H_stem_M_Copy(:)];
            vis_VIS = 'Off';
            set(HDL_Copy,'Visible','On');
        end
        set(HDL_VIS,'Visible',vis_VIS);
        hdl_STEM.H_vert_O_Copy = H_vert_O_Copy;
        hdl_STEM.H_stem_O_Copy = H_stem_O_Copy;
        hdl_STEM.H_vert_M_Copy = H_vert_M_Copy;
        hdl_STEM.H_stem_M_Copy = H_stem_M_Copy;
    end
    wfigmngr('storeValue',win_tool,'Stems_struct',hdl_STEM);

  case 'show_ori_sig'
    lin_hdl = wmemtool('rmb',win_tool,n_miscella,ind_lin_hdl);
    vis = getonoff(get(chk_sho,'Value'));
    set(lin_hdl(2),'Visible',vis);
    if isequal(vis,'on')
        strTitle = getWavMSG('Wavelet:commongui:Str_SS_OS');
    else
        strTitle = getWavMSG('Wavelet:commongui:Str_SynSig');
    end
    wtitle(strTitle,'Parent',get(lin_hdl(2),'Parent'))

  case 'position'
    lev_view = varargin{2};
    chk_sho  = varargin{3};
    set(chk_sho,'Visible','off');
    pos_old  = utnbcfs('get',win_tool,'position');
    utnbcfs('set',win_tool,'position',{1,lev_view})
    pos_new  = utnbcfs('get',win_tool,'position');
    ytrans   = pos_new(2)-pos_old(2);
    pos_chk  = get(chk_sho,'Position');
    pos_chk(2) = pos_chk(2)+ytrans;
    set(chk_sho,'Position',pos_chk,'Visible','on');

  case 'update_level'
    pop_lev = varargin{2}(1);
    chk_sho = varargin{2}(2);
    if ~ishandle(pop_lev)
        handles = guihandles(gcbf);
        pop_lev = handles.Pop_Lev;
        chk_sho = handles.Chk_Sho;
    end
    levmax  = get(pop_lev,'Value');

    % Get Values.
    %------------
    axe_hdl = wmemtool('rmb',win_tool,n_miscella,ind_axe_hdl);
    
    % Clean axes.
    %------------
    children = wfindobj(axe_hdl(2:3),'type','axes','-xor');
    if ~isempty(children) , delete(children); end
    set(axe_hdl(2:3),'Visible','Off','YTickLabel',[],'YTick',[]);

    % Hide synthesized signal.
    %-------------------------
    set(chk_sho,'Value',0);
    set(wfindobj(axe_hdl(4)),'Visible','Off');
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','Off');

    % Reset coefficients tool and dynvtool.
    %--------------------------------------
    utnbcfs('clean',win_tool)
    cf1dtool('position',win_tool,levmax,chk_sho);
    dynvtool('ini_his',win_tool,'reset')

  case 'handles'

  case 'close'
 
  otherwise
    errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
    error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = extractSTEMS(HDL_Stems)

nbrow = 4;
nbcol = length(HDL_Stems)/nbrow;
HDL_Stems = reshape(HDL_Stems(:),nbrow,nbcol)';
H_vert = HDL_Stems(:,2);
H_stem = HDL_Stems(:,3);
varargout = {H_vert,H_stem,HDL_Stems};
%-----------------------------------------------------------------------------%
function varargout = initSTEMS(axe,nbSTEMS)

stemColor = wtbutils('colors','stem');
linProp   = {...
             'Visible','Off',             ...
             'XData',NaN,'YData',NaN,     ...
             'MarkerEdgeColor',stemColor, ...
             'MarkerFaceColor',stemColor  ...
             };
linPropVert = [linProp,'LineStyle','-','Color',stemColor];
linPropStem = [linProp,'LineStyle','none','Marker','o','MarkerSize',3];
linTmpVert = line(linPropVert{:},'Parent',axe);
linTmpStem = line(linPropStem{:},'Parent',axe);
dupli      = ones(nbSTEMS,1);
HDL_vert = copyobj(linTmpVert,axe(dupli));
HDL_stem = copyobj(linTmpStem,axe(dupli));
delete([linTmpVert,linTmpStem]);
varargout = {HDL_vert,HDL_stem};
%-----------------------------------------------------------------------------%
%=============================================================================%
