function varargout = wp1dstat(option,varargin)
%WP1DSTAT Wavelet packets 1-D statistics.
%   VARARGOUT = WP1DSTAT(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.17.4.12 $

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
% ind_act_option = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_gra_area  = 5;
% ind_nb_colors = 6;
% nb2_stored    = 6;

% MB1. (Local Bloc)
%--------------------
n_misc_loc = 'WPStat1D_Misc';
ind_curr_sig   = 1;
ind_curr_color = 2;
nbLOC_1_stored = 2;

% Tag properties.
%----------------
tag_sel_cfs    = 'Sel_Cfs';
tag_sel_rec    = 'Sel_Rec';
tag_txt_bin    = 'Bins_Txt';
tag_edi_bin    = 'Bins_Data';
tag_ax_signal  = 'Ax_Signal';
tag_ax_hist    = 'Ax_Hist';
tag_ax_cumhist = 'Ax_Cumhist';
tag_pus_sta    = 'Show_Stat';

if ~isequal(option,'create') , win_stats = varargin{1}; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,Def_FraBkColor] =  ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Pop_Min_Width', ...
                'X_Spacing','Y_Spacing', 'Def_EdiBkColor','Def_FraBkColor');

        % Calling figure and node.
        %-------------------------
        win_caller     = varargin{1};
        node           = varargin{2};

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:wp1d2dRF:NamWinStatWP_1D');
        [win_stats,pos_win,win_units,~,...
                pos_frame0,Pos_Graphic_Area] = ...
                    wfigmngr('create',win_name,'','ExtFig_HistStat',mfilename,0);
        if nargout>0 , varargout{1} = win_stats; end

        % Begin waiting.
        %---------------
        set(win_stats,'Pointer','watch');

        % Getting variables from wp1dtool figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');        
        depth   = treedpth(WP_Tree);
        [Sig_Name,Sig_Size,Wave_Name,Ent_Nam,Ent_Par] = ...
                wmemtool('rmb',win_caller,n_param_anal,   ...
                               ind_sig_name,ind_sig_size, ...
                               ind_wav_name,ind_ent_anal,ind_ent_par);

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = Def_Btn_Height-Def_Txt_Height;
        gra_width = Pos_Graphic_Area(3);
        push_width = (pos_frame0(3)-4*dx)/2;
        pop_width  = Pop_Min_Width;
        default_bins = 30;

        % Position property of objects.
        %------------------------------
        xlocINI     = pos_frame0([1 3]);
        ybottomINI  = pos_win(4)-3.5*Def_Btn_Height-dy2;
        ybottomENT  = ybottomINI-(Def_Btn_Height+dy2)-dy;
        y_low       = ybottomENT-4*Def_Btn_Height;
        px          = pos_frame0(1)+(pos_frame0(3)-5*push_width/4)/2;
        pos_sel_cfs = [px, y_low, 5*push_width/4, 3*Def_Btn_Height/2];
        y_low       = y_low-3*Def_Btn_Height;
        pos_sel_rec = [px, y_low, 5*push_width/4, 3*Def_Btn_Height/2];
        px          = pos_frame0(1)+(pos_frame0(3)-3*pop_width)/2;
        y_low       = y_low-3*Def_Btn_Height;
        pos_txt_bin = [px, y_low+d_txt/2, 2*pop_width, Def_Txt_Height];
        px          = pos_txt_bin(1)+pos_txt_bin(3)+dx;
        pos_edi_bin = [px, y_low, pop_width, Def_Btn_Height];
        px          = pos_frame0(1)+(pos_frame0(3)-3*push_width/2)/2;
        y_low       = pos_edi_bin(2)-3*Def_Btn_Height;
        pos_pus_sta = [px, y_low, 3*push_width/2, 2*Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_sel_cfs = getWavMSG('Wavelet:commongui:Str_Coefficients');
        str_sel_rec = getWavMSG('Wavelet:commongui:Str_Recons');
        str_txt_bin = getWavMSG('Wavelet:commongui:Str_NbBins');
        str_edi_bin = sprintf('%.0f',default_bins);
        str_pus_sta = getWavMSG('Wavelet:commongui:Str_show_stat');

        % Command part construction of the window.
        %-----------------------------------------
        if ~isequal(get(0,'CurrentFigure'),win_stats) , figure(win_stats); end

        utanapar('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Sig_Name,Sig_Size},'wav',Wave_Name,'lev',depth} ...
                 );

        utentpar('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomENT,...
                  'ent',{Ent_Nam,Ent_Par}} ...
                 );

        rad_cfs = uicontrol('Parent',win_stats,...
                            'Style','Radiobutton',...
                            'Units',win_units,...
                            'Position',pos_sel_cfs,...
                            'String',str_sel_cfs,...
                            'Tag',tag_sel_cfs,...
                            'UserData',0,...
                            'Value',0);
        rad_rec = uicontrol('Parent',win_stats,...
                            'Style','Radiobutton',...
                            'Units',win_units,...
                            'Position',pos_sel_rec,...
                            'String',str_sel_rec,...
                            'Tag',tag_sel_rec,...
                            'UserData',1,...
                            'Value',1);
        uicontrol('Parent',win_stats,...
                            'Style','text',...
                            'Units',win_units,...
                            'Position',pos_txt_bin,...
                            'String',str_txt_bin,...
                            'BackgroundColor',Def_FraBkColor,...
                            'Tag',tag_txt_bin...
                            );
        edi_bin = uicontrol('Parent',win_stats,...
                            'Style','Edit',...
                            'Units',win_units,...
                            'Position',pos_edi_bin,...
                            'String',str_edi_bin,...
                            'BackgroundColor',Def_EdiBkColor,...
                            'Tag',tag_edi_bin...
                            );
        pus_sta = uicontrol('Parent',win_stats,...
                            'Style','pushbutton',...
                            'Units',win_units,...
                            'Position',pos_pus_sta,...
                            'String',str_pus_sta,...
                            'UserData',[],...
                            'Tag',tag_pus_sta...
                            );

        % Frame Stats. construction.
        %---------------------------
        [infos_hdls,h_frame1] = utstats('create',win_stats,...
                                        'xloc',Pos_Graphic_Area([1,3]), ...
                                        'bottom',dy2);

        % Callbacks update.
        %------------------
        cba_sel_rec = @(~,~)wp1dstat('select', ...
                            win_stats , ...
                            rad_rec , ...
                            infos_hdls ...
                            );
        cba_sel_cfs = @(~,~)wp1dstat('select', ...
                            win_stats , ...
                            rad_cfs , ...
                            infos_hdls ...
                            );
        cba_edi_bin = @(~,~)wp1dstat('update_bins', ...
                            win_stats , ...
                            edi_bin ...
                            );
        cba_pus_sta = @(~,~)wp1dstat('draw',  ...
                            win_stats ,     ...
                            win_caller , ...
                            infos_hdls , ...
                            node ...
                            );

        set(rad_rec,'Callback',cba_sel_rec);
        set(rad_cfs,'Callback',cba_sel_cfs);
        set(edi_bin,'Callback',cba_edi_bin);
        set(pus_sta,'Callback',cba_pus_sta);

        % Axes construction.
        %-------------------
        xspace         = gra_width/10;
        yspace         = pos_frame0(4)/10;
        axe_height     = (pos_frame0(4)-Def_Btn_Height-h_frame1-4*dy)/2-yspace;
        axe_width      = gra_width-2*xspace;
        half_width     = axe_width/2-xspace/2;
        pos_ax_signal  = [xspace h_frame1+2*dy2+axe_height+4*yspace/3 ...
                                axe_width axe_height];
        pos_ax_hist    = [xspace h_frame1+2*dy2+yspace/3 ...
                                half_width axe_height];
        pos_ax_cumhist = [2*xspace+half_width h_frame1+2*dy2+yspace/3 ...
                                half_width axe_height];

        commonProp = {...
           'Parent',win_stats,...
           'Units',win_units,...
           'Visible','Off',...
           'box','on',...
           'NextPlot','Replace' ...
           };
        axes(commonProp{:},'Position',pos_ax_signal,'Tag',tag_ax_signal);
        axes(commonProp{:},'Position',pos_ax_hist,'Tag',tag_ax_hist);
        axes(commonProp{:},'Position',pos_ax_cumhist,'Tag',tag_ax_cumhist);

        % Displaying the window title.
        %-----------------------------
        str_par = utentpar('get',win_stats,'txt');
        if ~isempty(str_par)
            str_par = [' (' lower(str_par) ' = ',num2str(Ent_Par),')'];
        end
        str_wintitle = getWavMSG('Wavelet:wp1d2dRF:Str_StatWinTit',...
            Sig_Name,depth,Wave_Name,Ent_Nam,str_par);
        wfigtitl('String',win_stats,str_wintitle,'off');
        
        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_stats);
        set(win_stats,'Visible','On');

        % Computing statistics for the node.
        %-----------------------------------
		wp1dstat('draw',win_stats,win_caller,infos_hdls,node);
		
        % End waiting.
        %-------------
        set(win_stats,'Pointer','arrow');

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_rad_btn = varargin{2};
        infos_hdls  = varargin{3};

        % Set to the current selection.
        %------------------------------
        rad_handles = findobj(win_stats,'Style','radiobutton');
        old_rad     = findobj(rad_handles,'UserData',1);
        set(rad_handles,'Value',0,'UserData',0);
        set(sel_rad_btn,'Value',1,'UserData',1)
        if old_rad==sel_rad_btn , return; end

        % Reset all.
        %-----------
        set(infos_hdls,'Visible','off');
        axe_handles = findobj(get(win_stats,'Children'),'flat','Type','axes');
        axe_signal  = findobj(axe_handles,'flat','Tag',tag_ax_signal);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(findobj([axe_signal,axe_hist,axe_cumhist]),'Visible','off');
        drawnow

    case 'draw'
        %*********************************%
        %** OPTION = 'draw' - DRAW AXES **%
        %*********************************%
        win_caller = varargin{2};
        infos_hdls = varargin{3};
        node       = varargin{4};

        % Handles of tagged objects.
        %---------------------------
        children    = get(win_stats,'Children');
        axe_handles = findobj(children,'flat','Type','axes');
        uic_handles = findobj(children,'flat','Type','uicontrol');
        pus_sta     = findobj(uic_handles,'Style','pushbutton','Tag',tag_pus_sta);
        axe_signal  = findobj(axe_handles,'flat','Tag',tag_ax_signal);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        rad_handles = findobj(uic_handles,'Style','radiobutton');
        edi_handles = findobj(uic_handles,'Style','edit');
        rad_cfs     = findobj(rad_handles,'Tag',tag_sel_cfs);
        edi_bin     = findobj(edi_handles,'Tag',tag_edi_bin);

        % Main parameters selection before drawing.
        %------------------------------------------
        sel_cfs = (get(rad_cfs,'Value')~=0);

        % Check the bins number.
        %-----------------------
        default_bins = 30;
        old_params   = get(pus_sta,'UserData');
        if ~isempty(old_params) , default_bins = old_params(1); end
        nb_bins = str2double(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        new_params = [nb_bins , sel_cfs , node];
        if ~isempty(old_params) && isequal(new_params,old_params)
            if strcmpi(get(axe_hist,'Visible'),'on'), return , end
        end

        % Deseable new selection.
        %-------------------------
        set([edi_bin;rad_handles],'Enable','off');

        % Updating parameters.
        %--------------------- 
        set(pus_sta,'UserData',new_params);

        % Show the status line.
        %----------------------
        wfigtitl('vis',win_stats,'on');

        % Cleaning the graphical part.
        %-----------------------------
        set(infos_hdls,'Visible','off');

        % Waiting message.
        %-----------------
        wwaiting('msg',win_stats,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Cleaning the graphical part continuing.
        %----------------------------------------
        set(findobj([axe_signal,axe_hist,axe_cumhist]),'Visible','off');
        drawnow

        % Parameters initialization.
        %---------------------------
        if node>-1

            % Getting memory blocks.
            %-----------------------
            WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
            order = treeord(WP_Tree);
            depth = treedpth(WP_Tree);            

            % Current signal construction.
            %-----------------------------
            if sel_cfs
                curr_sig  = wpcoef(WP_Tree,node);
            else
                curr_sig  = wprcoef(WP_Tree,node);
            end
            if length(curr_sig)<3
                wwarndlg(getWavMSG('Wavelet:commongui:Not_Enough',depth),...
                         getWavMSG('Wavelet:wp1d2dRF:NamWinStatWP_1D'),'modal');
                wwaiting('off',win_stats);
                return;
            end
            
            if sel_cfs
                msgID = 'Cfs';
            else
                msgID = 'Rec';
            end
            Tree_Type_TxtV  = wmemtool('rmb',win_caller,n_wp_utils,ind_type_txt);
            [level,pos]     = ind2depo(order,node);
            if strcmp(Tree_Type_TxtV,'i')
                ind     = depo2ind(order,node);
                str_pck = getWavMSG(['Wavelet:wp1d2dRF:Pack_' msgID '_1'],ind);
            else
                str_pck = getWavMSG(['Wavelet:wp1d2dRF:Pack_' msgID '_2'],level,pos);
            end
            if pos==0
                if level==0
                    curr_color = wtbutils('colors','sig');
                    str_title  = [str_pck '  <==>  ' ...
                            getWavMSG('Wavelet:commongui:OriSig')];
                else
                    col_app    = wtbutils('colors','app',depth);
                    curr_color = col_app(level,:);
                    str_title  = [str_pck '  <==>  ' ...
                            getWavMSG('Wavelet:commongui:App',level)];
                end
            else
                col_det    = wtbutils('colors','det',depth);
                curr_color = col_det(level,:);
                str_title  = str_pck;
            end
        else
            curr_sig = get(wpssnode('r_synt',win_caller),'UserData');
            curr_color = wtbutils('colors','wp1d','hist');
            if node==-1
                str_title = getWavMSG('Wavelet:commongui:CompSig');
            elseif node==-2
                str_title = getWavMSG('Wavelet:commongui:DenoSig');
            end
        end

        % Displaying the signal.
        %-----------------------
        xaxis = [1              length(curr_sig)];
        yaxis = [min(curr_sig)  max(curr_sig)];
        if xaxis(1)==xaxis(2)
            xaxis = xaxis+[-0.01 0.01];
        end
        if yaxis(1)==yaxis(2)
            yaxis = yaxis+[-0.01 0.01];
        end
        plot(curr_sig,'Color',curr_color,'Parent',axe_signal);
        set(axe_signal,'Visible','on','XLim',xaxis,'YLim',yaxis,...
                'Tag',tag_ax_signal);
        wtitle(str_title,'Parent',axe_signal);

        % Displaying histogram.
        %----------------------
        his       = wgethist(curr_sig,nb_bins);
        [xx,imod] = max(his(2,:)); %#ok<ASGLU>
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(curr_sig);
        wplothis(axe_hist,his,curr_color);
        wtitle(getWavMSG('Wavelet:commongui:Str_Hist'),'Parent',axe_hist);

        % Displaying cumulated histogram.
        %--------------------------------
        for i=6:4:length(his(2,:))
            his(2,i)   = his(2,i)+his(2,i-4);
            his(2,i+1) = his(2,i);
        end
        wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
        wtitle(getWavMSG('Wavelet:commongui:Str_CumHist'),'Parent',axe_cumhist);

        % Displaying statistics.
        %-----------------------
        mean_val     = mean(curr_sig);
        max_val      = max(curr_sig);
        min_val      = min(curr_sig);
        range_val    = max_val-min_val;
        std_val      = std(curr_sig);
        med_val      = median(curr_sig);
        L1_val    = norm(curr_sig,1);
        L2_val    = norm(curr_sig,2);
        LM_val    = norm(curr_sig,Inf);        
        utstats('display',win_stats, ...
            [mean_val; med_val ; mode_val;  ...
             max_val ; min_val ; range_val; ...
             std_val ; median(abs(curr_sig-med_val)); ...
             mean(abs(curr_sig-mean_val)); ...
             L1_val ; L2_val ; LM_val]);

        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_stats,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_stats,n_misc_loc, ...
                       ind_curr_sig,curr_sig,    ...
                       ind_curr_color,curr_color ...
                       );

        % End waiting.
        %-------------
        wwaiting('off',win_stats);

        % Setting infos visible.
        %-----------------------
        set(infos_hdls,'Visible','on');

        % Enable new selection.
        %-------------------------
        set([edi_bin;rad_handles],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bin = varargin{2};

        % Handles of tagged objects.
        %---------------------------
        children    = get(win_stats,'Children');
        axe_handles = findobj(children,'flat','Type','axes');
        uic_handles = findobj(children,'flat','Type','uicontrol');
        pus_sta     = findobj(uic_handles,...
                                        'Style','pushbutton',...
                                        'Tag',tag_pus_sta...
                                        );
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Return if no current display.
        %------------------------------
        if strcmpi(get(axe_hist,'Visible'),'off'), return, end

        % Check the bins number.
        %-----------------------
        default_bins = 30;
        old_params   = get(pus_sta,'UserData');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = str2num(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Getting memory blocks.
        %-----------------------
        [curr_sig,curr_color] = wmemtool('rmb',win_stats,n_misc_loc,...
                                               ind_curr_sig,ind_curr_color);

        % Updating histograms.
        %---------------------
        if ~isempty(curr_sig)
            old_params(1) = nb_bins;
            set(pus_sta,'UserData',old_params);
            his      = wgethist(curr_sig,nb_bins);
            his(2,:) = his(2,:)/length(curr_sig);
            wplothis(axe_hist,his,curr_color);
            wtitle(getWavMSG('Wavelet:commongui:Str_Hist'),'Parent',axe_hist);
            for i=6:4:length(his(2,:))
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
            wtitle(getWavMSG('Wavelet:commongui:Str_CumHist'), ...
                'Parent',axe_cumhist);
        end

    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
