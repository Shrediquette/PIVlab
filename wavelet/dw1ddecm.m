function [out1,out2] = dw1ddecm(option,win_dw1dtool,in3,in4)
%DW1DDECM Discrete wavelet 1-D full decomposition mode manager.
%   [OUT1,OUT2] = DW1DDECM(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.15.4.10 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
% ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;
% ind_view_mode  =  2;
% ind_savepath   =  3;
% nb4_stored     =  3;

% Tag property of objects.
%-------------------------
tag_declev    = 'Pop_DecLev';
% tag_txtdeclev = 'Txt_DecLev';
tag_axe_dec   = 'Axe_Dec';
tag_txt_dec   = 'Txt_Dec';
tag_s_dec     = 'S_dec';
tag_ss_dec    = 'SS_dec';
tag_a_dec     = 'A_dec';
tag_d_dec     = 'D_dec';

axe_handles   = findobj(get(win_dw1dtool,'Children'),'flat','Type','axes');
txt_a_handles = findobj(axe_handles,'Type','text');

switch option
    case 'ssig'
        % in3 = chk_handle
        %-----------------
        [flg_s_ss,ccfs] = dw1dvmod('get_vm',win_dw1dtool,2);
        val = get(in3,'Value');
        flg_s_ss(2) = val; 
        dw1dvmod('set_vm',win_dw1dtool,2,flg_s_ss,ccfs);
        ss_dec  = findobj(axe_handles,'Tag',tag_ss_dec);
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        num = Level_Anal+2;
        txt_dec = findobj(txt_a_handles,'UserData',num,'Tag',tag_txt_dec);
        if val==0
            set(ss_dec,'Visible','off');
            set(txt_dec,'String','s');      
        else
            set(ss_dec,'Visible','on');
            ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
            set(txt_dec,'String',['s/' ss_type]);   
        end

    case 'dec'
        wwaiting('msg',win_dw1dtool, ...
            getWavMSG('Wavelet:commongui:WaitCompute'));
        pop_handles = findobj(win_dw1dtool,'Style','popupmenu');
        pop = findobj(pop_handles,'Tag',tag_declev);
        lev = get(pop,'Value');
        a_dec = findobj(axe_handles,'Type','line','Tag',tag_a_dec);
        if ~isempty(a_dec) && lev~=get(a_dec,'UserData')
            delete(a_dec); 
            a_dec = []; 
        end
        if isempty(a_dec) , dw1ddecm('view',win_dw1dtool,-1,lev); end
        wwaiting('off',win_dw1dtool);

    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean
        %---------------------------
        % in4 = level (optional)
        %---------------------------
        old_mode = in3;
        [~,Level_Anal,Signal_Size] = ... 
                        wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                ind_wav_name,ind_lev_anal,ind_sig_size);
        if nargin==3 , level = Level_Anal; else level = in4; end
        v_flg   = dw1dvmod('get_vm',win_dw1dtool,2);
        vis_str = getonoff(v_flg);
        v_s     = vis_str{1};
        v_ss    = vis_str{2};

        [axe_hdl,txt_hdl] = dw1ddecm('axes',win_dw1dtool,level);
        lin_handles = findobj(axe_hdl,'Type','line');
        s_dec  = findobj(lin_handles,'Tag',tag_s_dec);
        ss_dec = findobj(lin_handles,'Tag',tag_ss_dec);
        a_dec  = findobj(lin_handles,'Tag',tag_a_dec);
        d_dec  = findobj(lin_handles,'Tag',tag_d_dec);
        if ~isempty(a_dec)
            if level~=get(a_dec,'UserData') , delete(a_dec); a_dec = []; end
        end
        if ~isempty(d_dec)
            usr = get(d_dec,'UserData');
            usr = cat(1,usr{:});
            inv_d = d_dec(usr>level);
            if ~isempty(inv_d) , set(inv_d,'Visible','off'); end
        end

        % nb_axe = level+2;
        ind = [1:level,Level_Anal+1:Level_Anal+2];
        set([axe_hdl(ind) txt_hdl(ind)],'Visible','On');
        ind   = Level_Anal+2;
        axAct = axe_hdl(ind);
        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        if v_flg(1)==1
            if v_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if v_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_hdl(ind),'String',txt);
        if isempty(s_dec)
            [x,ymin,ymax] = dw1dfile('sig',win_dw1dtool,1);
            xmin = 1;  xmax = length(x);
            set(axe_hdl,'XLim',[xmin xmax]);
            axes(axAct); %#ok<*MAXES>
            col = wtbutils('colors','sig');
            line('Parent',axAct,'XData',1:length(x),'YData',x,...
                 'Color',col,'Visible',v_s,'Tag',tag_s_dec);
            set(axAct,'YLim',[ymin ymax],'UserData',ind,'Tag',tag_axe_dec);
        else
            set(s_dec,'Visible',v_s);
        end
        if isempty(ss_dec)
            [x,ymin,ymax] = dw1dfile('ssig',win_dw1dtool,1);
            ylim = get(axAct,'YLim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            axes(axAct);
            col = wtbutils('colors','ssig');
            line('Parent',axAct,'XData',1:length(x),'YData',x,...
                    'Color',col,'Visible',v_ss,'Tag',tag_ss_dec);
            set(axAct,'YLim',[ymin,ymax],'UserData',ind,'Tag',tag_axe_dec);
        else
            set(ss_dec,'Visible',v_ss);
        end
        ind   = Level_Anal+1;
        axAct = axe_hdl(ind);
        if isempty(a_dec)
            [x,ymin,ymax] = dw1dfile('app',win_dw1dtool,level,3);
            col_app = wtbutils('colors','app',Level_Anal);
            line(...
                 'Parent',axAct,       ...
                 'XData',1:length(x),  ...
                 'YData',x,            ...
                 'Color',col_app(level,:),...
                 'UserData',level,'Tag',tag_a_dec);
            set(axAct,'YLim',[ymin ymax],'Tag',tag_axe_dec);
        else
            set(a_dec,'Visible','on');
        end
        set(txt_hdl(ind),'String',['a' wnsubstr(level)]);
        if isempty(d_dec)
            [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,1:Level_Anal,1);
            col_det = wtbutils('colors','det',Level_Anal);
            for k = Level_Anal:-1:1
                axe = axe_hdl(k);
                if k>level , vis = 'off'; else vis = 'on'; end
                line(...
                     'Parent',axe,         ...
                     'XData',1:size(x,2),  ...
                     'YData',x(k,:),       ...
                     'Color',col_det(k,:), ...
                     'UserData',k,         ...
                     'Visible',vis,        ...
                     'Tag',tag_d_dec       ...
                     );
                prop = {'UserData',k,'Tag',tag_axe_dec};
                if set_ylim   
                    prop = ['YLim',[ymin(k) ymax(k)],prop];  %#ok<*AGROW>
                end
                set(axe,prop{:});
            end
        else
            set(d_dec(1:level),'Visible','on');
        end
        set(axe_hdl(2:end),...
                'XTickLabelMode','manual', ...
                'XTickLabel',[]            ...
                );
        axeAct = axe_hdl(end);
        axes(axeAct);
        Sdec = ['s = a' int2str(level)];
        for k =level:-1:1
            Sdec = [Sdec ' + d' int2str(k)]; 
        end
        wtitle(getWavMSG('Wavelet:dw1dRF:DecAtLev',level,Sdec),...
            'Parent',axeAct);

        % Axes attachment.
        %-----------------
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'dec',old_mode);
        if okNew
            set(axe_hdl,'XLim',[1 Signal_Size]);
            dynvtool('init',win_dw1dtool,[],axe_hdl,[],[1 0]);
        end

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_hdl(1));

    case 'axes'
        % in3 = level_view
        %-----------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        if nargin==2 , in3 = Level_Anal; end

        % Axes Positions.
        %----------------
        pos_graph = wmemtool('rmb',win_dw1dtool,n_miscella,ind_graph_area);
        pos_win   = get(win_dw1dtool,'Position');
        win_units = get(win_dw1dtool,'Units');
        nb_axes_tot = Level_Anal+2;
        nb_axes = in3+2;
        [bdXLSPACE,bdXRSPACE] = mextglob('get','bdXLSpacing','bdXRSpacing');
        bdxl = 1.5*bdXLSPACE*pos_win(3);
        bdxr = bdXRSPACE*pos_win(3);
        w_used  = pos_graph(3)-bdxl-bdxr;
        bdy = 0.05*pos_win(4);
        ecy = 0.02*pos_win(4);
        h_used = (pos_graph(4)-2*bdy-(nb_axes-1)*ecy)/nb_axes;
        pos_axe = [bdxl pos_graph(2)+bdy w_used h_used];
        pos_axe = pos_axe(ones(1,nb_axes),:);
        y_axe   = pos_axe(1,2);
        for k=2:nb_axes
            y_axe = y_axe+h_used+ecy;
            pos_axe(k,2) = y_axe;
        end
        out1 = zeros(1,nb_axes_tot);
        out2 = zeros(1,nb_axes_tot);
        out1tmp = findobj(axe_handles,'flat','Tag',tag_axe_dec);
        fontsize = wtbutils('dw1d_DEC_PREFS');
        if ~isempty(out1tmp)
            out2tmp = findobj(txt_a_handles,'Tag',tag_txt_dec);
            for k = 1:nb_axes_tot
                out1(k) = findobj(out1tmp,'flat','UserData',k);
                out2(k) = findobj(out2tmp,'UserData',k);
            end
            set([out1 out2],'Visible','off');
        else
            axeProp = {...
               'Parent',win_dw1dtool,...
               'Units',win_units,    ...
               'Visible','off',      ...
               'NextPlot','add',     ...
               'Box','On',           ...
               'Tag',tag_axe_dec     ...
               };
            for k = 1:nb_axes_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                               'XTickLabelMode','manual','XTickLabel',[]}; %#ok<*CCAT>
                end
                out1(k) = axes(axeProp{:},'UserData',k);
                switch k
                  case nb_axes_tot ,   txt_str = 's/ss';                    
                  case nb_axes_tot-1 , txt_str = 'a';                    
                  otherwise ,          txt_str = ['d' wnsubstr(k)];                   
                end
                out2(k) = txtinaxe('create',...
                    txt_str,out1(k),'l','off','bold',fontsize);
                set(out2(k),'UserData',k,'Tag',tag_txt_dec);
            end
        end
        for k = 1:nb_axes-2
            set(out1(k),'Position',pos_axe(k,:));
            txtinaxe('pos',out2(k));
        end
        ind = nb_axes-2;
        for k = nb_axes_tot-1:nb_axes_tot
            ind = ind+1;
            set(out1(k),'Position',pos_axe(ind,:));
            txtinaxe('pos',out2(k));
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_sig      = findobj(lin_handles,'Tag',tag_ss_dec);
        delete(ss_sig);

    case 'clear'
        dynvtool('stop',win_dw1dtool);
        out1 = wfindobj(axe_handles,'flat','Tag',tag_axe_dec);
        delete(out1);
        
    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
        
