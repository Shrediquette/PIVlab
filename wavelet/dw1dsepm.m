function [out1,out2,out3,out4,out5,out6,out7] = ...
          dw1dsepm(option,win_dw1dtool,in3,in4)
%DW1DSEPM Discrete wavelet 1-D separate mode.
%   [OUT1,OUT2,OUT3,OUT4,OUT5,OUT6,OUT7] = ...
%   DW1DSEPM(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.16.4.10 $  $Date: 2013/07/05 04:29:56 $ 


% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_size   = 2;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6; %#ok<NASGU>
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
tag_a_l_sep = 'AL_Sep';
tag_t_l_sep = 'TL_Sep';
tag_a_r_sep = 'AR_Sep';
tag_t_r_sep = 'TR_Sep';
tag_fra_sep = 'Fra_Sep';
tag_sa_sep  = 'Sa_Sep';
tag_ssa_sep = 'SSa_Sep';
tag_app_sep = 'App_Sep';
tag_sd_sep  = 'Sd_Sep';
tag_ssd_sep = 'SSd_Sep';
tag_det_sep = 'Det_Sep';
tag_img_sep = 'Img_Sep';

children    = get(win_dw1dtool,'Children');
axe_handles = findobj(children,'flat','Type','axes');
uic_handles = findobj(children,'flat','Type','uicontrol');
fra_handles = findobj(uic_handles,'Style','frame');
txt_a_handles = findobj(axe_handles,'Type','text');

switch option
    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean 
        %------------------------------------------------------
        [Level_Anal,Signal_size] = ...
            wmemtool('rmb',win_dw1dtool,n_param_anal,...
                               ind_lev_anal,ind_sig_size);
        old_mode = in3;

        [flg_axe,sa_flg,app_flg,sd_flg,det_flg] = ...
                                dw1dvmod('get_vm',win_dw1dtool,3);
        cfs_flg = flg_axe(3);
        if flg_axe(1)==0 , sa_flg = [0 0]; end
        if flg_axe(2)==0 , sd_flg = [0 0]; end
        lev2    = Level_Anal+2;
        a_flg   = [app_flg , sa_flg];
        d_flg   = [det_flg , sd_flg , cfs_flg];
        vis_str = getonoff([a_flg d_flg]);
        v_app   = vis_str(1:Level_Anal);
        v_s_a   = vis_str{Level_Anal+1};
        v_ss_a  = vis_str{lev2};
        v_det   = vis_str(lev2+1:lev2+Level_Anal);
        v_s_d   = vis_str{2*lev2-1};
        v_ss_d  = vis_str{2*lev2};
        v_cfs   = vis_str{2*lev2+1};

        [axe_left,axe_right,txt_left,txt_right,~,ind_left,ind_right] = ...
                                dw1dsepm('axes',win_dw1dtool,a_flg,d_flg);

        axe_hdl = [axe_left(:)' axe_right(:)'];
        lin_handles = findobj(axe_hdl,'Type','line');
        img_handles = findobj(axe_hdl,'Type','image');
        s_app   = findobj(lin_handles,'Tag',tag_sa_sep);
        ss_app  = findobj(lin_handles,'Tag',tag_ssa_sep);
        app     = findobj(lin_handles,'Tag',tag_app_sep);
        s_det   = findobj(lin_handles,'Tag',tag_sd_sep);
        ss_det  = findobj(lin_handles,'Tag',tag_ssd_sep);
        det     = findobj(lin_handles,'Tag',tag_det_sep);
        img_cfs = findobj(img_handles,'Tag',tag_img_sep);

        xmax = Signal_size;

        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);

        if sa_flg(1)==1
            if sa_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if sa_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_left(Level_Anal+1),'String',txt);
        if sd_flg(1)==1
            if sd_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if sd_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_right(Level_Anal+1),'String',txt);

        if isempty(s_app)
            [x,ymin,ymax] = dw1dfile('sig',win_dw1dtool,1);
            col_s   = wtbutils('colors','sig');
            axe_act = axe_left(Level_Anal+1);
            line('Parent',axe_act,'XData',1:length(x),'YData',x,...
                 'Color',col_s,'Visible',v_s_a,'Tag',tag_sa_sep);
            set(axe_act,             ...
                    'XTickLabelMode','manual', ...
                    'XTickLabel',[],           ...
                    'UserData',Level_Anal+1,   ...
                    'YLim',[ymin ymax]         ...
                    );

            axe_act = axe_right(Level_Anal+1);
            line('Parent',axe_act,'XData',1:length(x),'YData',x,...
                 'Color',col_s,'Visible',v_s_d,'Tag',tag_sd_sep);
            set(axe_act,'YLim',[ymin ymax])
        else
            set(s_app,'Visible',v_s_a);
            set(s_det,'Visible',v_s_d);
        end
        if isempty(ss_app)
            [x,ymin,ymax] = dw1dfile('ssig',win_dw1dtool,1);
            col_ss  = wtbutils('colors','ssig');
            axe_act = axe_left(Level_Anal+1);
            ylim = get(axe_act,'YLim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            line('Parent',axe_act,'XData',1:length(x),'YData',x,...
                 'Color',col_ss,'Visible',v_ss_a,'Tag',tag_ssa_sep);
            set(axe_act, ...
                    'XTickLabelMode','manual', ...
                    'XTickLabel',[],           ...
                    'UserData',Level_Anal+1,   ...
                    'YLim',[ymin ymax]         ...
                    );

            axe_act = axe_right(Level_Anal+1);
            ylim = get(axe_act,'YLim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            line('Parent',axe_act,'XData',1:length(x),'YData',x,...
                 'Color',col_ss,'Visible',v_ss_d,'Tag',tag_ssd_sep);
            set(axe_act,'YLim',[ymin ymax]);
        else
            set(ss_app,'Visible',v_ss_a);
            set(ss_det,'Visible',v_ss_d);
        end
        if isempty(app)
            [x,ymin,ymax] = dw1dfile('app',win_dw1dtool,1:Level_Anal,3);
            app     = zeros(1,Level_Anal);
            col_app = wtbutils('colors','app',Level_Anal);
            for k = Level_Anal:-1:1
                axe_act = axe_left(k);
                app(k) = line('Parent',axe_act,      ...
                              'XData',1:size(x,2), ...
                              'YData',x(k,:),        ...
                              'Color',col_app(k,:),  ...
                              'Visible',v_app{k},    ...
                              'Tag',tag_app_sep,     ...
                              'UserData',k           ...
                              );
                set(axe_act,'YLim',[ymin(k) ymax(k)]);
            end
        else
            for k =1:Level_Anal , set(app(k),'Visible',v_app{k}); end
        end
        if isempty(det)
            [x,set_ylim,ymin,ymax] = ...
                    dw1dfile('det',win_dw1dtool,1:Level_Anal,1);
            det     = zeros(1,Level_Anal);
            col_det = wtbutils('colors','det',Level_Anal);
            for k = Level_Anal:-1:1
                axe_act = axe_right(k);
                det(k)  = line( 'Parent',axe_act,       ...
                                'XData',1:size(x,2),    ...
                                'YData',x(k,:),         ...
                                'Color',col_det(k,:),   ...
                                'Visible',v_det{k},     ...
                                'Tag',tag_det_sep,      ...
                                'UserData',k            ...
                                );
                if set_ylim(k)
                    set(axe_act,'YLim',[ymin(k) ymax(k)]);
                end
            end
        else
            for k =1:Level_Anal , set(det(k),'Visible',v_det{k}); end
        end
        if ismember((Level_Anal+2),ind_right)
            yes_right = 1;
        else
            yes_right = 0;
        end

        ax_hdl = axe_right(Level_Anal+2);
        if yes_right
            [rep,ccfs_vm,~,xlim,nb_cla] = ...                    
                    dw1dmisc('tst_vm',win_dw1dtool,3,ax_hdl,det_flg);
            if rep==1 , delete(img_cfs); img_cfs = []; end
            if isempty(img_cfs)
                [x,xlim1,xlim2,~,~,nb_cla,levs,ccfs_vm] = ...
                                dw1dmisc('col_cfs',win_dw1dtool,...
                                        ccfs_vm,1:Level_Anal,xlim,nb_cla);
                tag = get(ax_hdl,'Tag');
                image( ...
                    flipud(x),         ...
                    'Parent',ax_hdl,   ...
                    'Visible',v_cfs,   ...
                    'Tag',tag_img_sep, ...
                    'UserData',        ...
                    [ccfs_vm,levs,xlim1,xlim2,nb_cla]...
                    );
                ylim = [0.5 Level_Anal+0.5];
                xlim = get(axe_left(Level_Anal+1),'XLim');
                levlab  = flipud(int2str(levs(:)));
                set(ax_hdl,...
                    'YTickLabelMode','manual', ...
                    'YTick',1:length(levs),    ...
                    'YTickLabel',levlab,       ...
                    'Box','on',                ...
                    'UserData',Level_Anal+2,   ...
                    'XLim',xlim,               ...
                    'YLim',ylim,               ...
                    'Layer','top',             ...
                    'Tag',tag                  ...
                    );
            else
                set(img_cfs,'Visible',v_cfs);           
            end
        else
            set(img_cfs,'Visible','off');   
        end
        %------------------------------------------------------------------
        % To avoid to many translation of axes title, we have simplified
        % the following piece of code .InitID = 1 is used only in the
        % case of loaded coefficients.
        %------------------------------
        % opt_act = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_act_option);
        % if strcmp(opt_act,'synt')
        %     ini_str = 'Orig. Synt. Sig.'; InitID = 1;
        % else
        %     ini_str = 'Signal';           InitID = 2;
        % end
        InitID = 2;
        %------------------------------------------------------------------         
        if     strcmp(ss_type,'ss') , InitID = InitID+10;
        elseif strcmp(ss_type,'ds') , InitID = InitID+20;
        elseif strcmp(ss_type,'cs') , InitID = InitID+30;
        end        
        
        t = get(axe_left,'title'); t = cat(1,t{:});set(t,'String','');
        msgID = 1E6 + InitID;
        ind = (1:Level_Anal+1);
        if ~isempty(ind_left)
            m_l = ind_left(1);
            i_l = find(ind~=m_l);
            set(axe_left(m_l),'UserData',m_l);
            for k = i_l
                ax = axe_left(k);
                set(ax,...
                    'XTickLabelMode','manual',...
                    'XTickLabel',[],          ...
                    'UserData',k              ...
                    );
                delete(get(ax,'title'));
            end
            m_l = max(ind_left);
            if ~isempty(m_l)
                if sa_flg(1)==1  , msgID = msgID+1E2; end                
                if sa_flg(2)==1  , msgID = msgID+1E3; end
                if find(app_flg) , msgID = msgID+1E4; end
                titleSTR = '';
                OkTitle = ~isequal(rem(floor(msgID/1E2),1E4),0);
                if OkTitle
                    if rem(fix(msgID/1E3),10)==0
                        msgID = msgID-10*rem(fix(msgID/10),10); 
                    end
                    msgID = ['SepMode_' int2str(msgID)];
                    try %#ok<TRYNC>
                    	titleSTR = getWavMSG(['Wavelet:dw1dRF:' msgID]);
                    end
                end
                wtitle(titleSTR,'Parent',axe_left(m_l));
            end
            set(axe_left(ind_left(1)),'XTickLabelMode','auto');
        end
        
        t = get(axe_right,'title'); t = cat(1,t{:});set(t,'String','');
        msgID = 2E6 + InitID;
        if ~isempty(ind_right)
            m_r = ind_right(1);
            i_r = find([ind Level_Anal+2]~=m_r);
            set(axe_right(m_r),'UserData',m_r);
            for k = i_r
                ax = axe_right(k);
                set(ax, ...
                    'XTickLabelMode','manual',...
                    'XTickLabel',[],          ...
                    'UserData',k              ...
                    );
                delete(get(ax,'title'));
            end
            m_r = max(ind_right);
            if ~isempty(m_r)
                if find(cfs_flg) , msgID = msgID+1E5; end
                if sd_flg(1)==1  , msgID = msgID+1E2; end
                if sd_flg(2)==1  , msgID = msgID+1E3; end
                if find(det_flg) , msgID = msgID+1E4; end
                titleSTR = '';
                OkTitle = ~isequal(rem(floor(msgID/1E2),1E4),0);
                if OkTitle
                    if rem(fix(msgID/1E3),10)==0
                        msgID = msgID-10*rem(fix(msgID/10),10); 
                    end
                    M = fix(msgID/1E4);
                    if rem(M,1E2)==0 , msgID = msgID-1E6; end
                    msgID = ['SepMode_' int2str(msgID)];
                    try %#ok<TRYNC>
                    	titleSTR = getWavMSG(['Wavelet:dw1dRF:' msgID]);
                    end
                end
                wtitle(titleSTR,'Parent',axe_right(m_r));
            end
            set(axe_right(ind_right(1)),'XTickLabelMode','auto');
        end
        
        % Axes attachment.
        %-----------------
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'sep',old_mode);
        if okNew
            set([axe_left(:)' axe_right(:)'],'XLim',[1 xmax]);
            axe_cmd = [axe_left axe_right(1:end-1)];
            others  = axe_right(end);
            dynvtool('init',win_dw1dtool,[],[axe_cmd,others],[],[1 0], ...
                '','','dw1dcoor',...
                [double(win_dw1dtool),double(others),Level_Anal]);
        end

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_left(1));

    case 'axes'
        % in3 = app flags (left)
        %   in3(1:Level_Anal)       = app flags
        %   in3(Level_Anal+1)       = s_app flag
        %   in3(Level_Anal+2)       = ss_app flag
        % in4 = det flags (right)
        %   in4(1:Level_Anal)       = det flags
        %   in4(Level_Anal+1)       = s_app flag
        %   in3(Level_Anal+2)       = ss_det flag
        %   in3(Level_Anal+3)       = cfs flag
        %------------------------------------------------------

        % Get Globals.
        %-------------
        Def_FraBkColor = mextglob('get','Def_FraBkColor');

        % Getting  Analysis parameters.
        %------------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        
        % Getting miscellaneous parameters.
        %----------------------------------
        pos_graph = wmemtool('rmb',win_dw1dtool,n_miscella,ind_graph_area);

        a_flg = in3;
        d_flg = in4;
        nb_a_left  = sum(a_flg(1:Level_Anal))+ ...
                                max(a_flg(Level_Anal+1:Level_Anal+2));
        nb_a_right = sum(d_flg(1:Level_Anal))+ ...
                max(d_flg(Level_Anal+1:Level_Anal+2))+d_flg(Level_Anal+3);
        nb_a_l_tot = Level_Anal+1;
        nb_a_r_tot = Level_Anal+2;

        ind_left = find(a_flg(1:Level_Anal)==1);
        if a_flg(Level_Anal+1)==1 || a_flg(Level_Anal+2)==1
            ind_left = [ind_left Level_Anal+1];     
        end

        ind_right = find(d_flg(1:Level_Anal)==1);
        if d_flg(Level_Anal+1)==1 || d_flg(Level_Anal+2)==1
            ind_right = [ind_right Level_Anal+1];   
        end
        if d_flg(Level_Anal+3)==1
            ind_right = [ind_right Level_Anal+2];   
        end
        out6 = ind_left;
        out7 = ind_right;

        pos_win   = get(win_dw1dtool,'Position');
        win_units = get(win_dw1dtool,'Units');
        bdx = 0.1*pos_win(3);
        bdy = 0.05*pos_win(4);
        ecy = 0.02*pos_win(4);
        if nb_a_left*nb_a_right~=0
            w_left  = (pos_graph(3)-3*bdx)/2;
            x_left  = pos_graph(1)+1.1*bdx;
            w_right = w_left;
            x_right = x_left+w_left+bdx+bdx/5;
        elseif nb_a_left~=0
            w_left  = pos_graph(3)-2*bdx;
            x_left  = pos_graph(1)+1.2*bdx;
        elseif nb_a_right~=0
            w_right = pos_graph(3)-2*bdx;
            x_right = pos_graph(1)+bdx;
        end
        if nb_a_left~=0
            h_axe = (pos_graph(4)-2*bdy-(nb_a_left-1)*ecy)/nb_a_left;
            y_axe = pos_graph(2)+bdy;
            pos_a_left = [x_left y_axe w_left h_axe];
            pos_a_left = pos_a_left(ones(1,nb_a_left),:);
            for k=2:nb_a_left
                y_axe = y_axe+h_axe+ecy;
                pos_a_left(k,2) = y_axe;
            end
        end
        if nb_a_right~=0
            h_axe = (pos_graph(4)-2*bdy-(nb_a_right-1)*ecy)/nb_a_right;
            y_axe = pos_graph(2)+bdy;
            pos_a_right = [x_right y_axe w_right h_axe];
            pos_a_right = pos_a_right(ones(1,nb_a_right),:);
            for k=2:nb_a_right
                y_axe = y_axe+h_axe+ecy;
                pos_a_right(k,2) = y_axe;
            end
        end
        out1 = zeros(1,nb_a_l_tot);
        out3 = zeros(1,nb_a_l_tot);
        out2 = zeros(1,nb_a_r_tot);
        out4 = zeros(1,nb_a_r_tot);
        out1tmp = findobj(axe_handles,'flat','Tag',tag_a_l_sep);
        if ~isempty(out1tmp)
            out2tmp = findobj(axe_handles,'flat','Tag',tag_a_r_sep);
            out3tmp = findobj(txt_a_handles,'Tag',tag_t_l_sep);
            out4tmp = findobj(txt_a_handles,'Tag',tag_t_r_sep);
            for k = 1:nb_a_l_tot
                out1(k) = findobj(out1tmp,'flat','UserData',k);
                out3(k) = findobj(out3tmp,'UserData',k);
            end
            for k = 1:nb_a_r_tot
                out2(k) = findobj(out2tmp,'flat','UserData',k);
                out4(k) = findobj(out4tmp,'UserData',k);
            end
            out5 = findobj(fra_handles,'Tag',tag_fra_sep);
        else
            axeProp = {...
               'Parent',win_dw1dtool,...
               'Units',win_units,    ...
               'Visible','Off',      ...
               'NextPlot','add',     ...
               'Box','On'            ...
               };
            for k = 1:nb_a_l_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                         'XTickLabelMode','manual','XTickLabel',[]}; %#ok<CCAT>
                end
                out1(k) = axes(axeProp{:},'UserData',k,'Tag',tag_a_l_sep);
                if k==Level_Anal+1
                    txt_str = 's/ss';
                else
                    txt_str = ['a' wnsubstr(k)];
                end
                out3(k) = txtinaxe('create',txt_str,out1(k),'l','off','bold',20);
                set(out3(k),'UserData',k,'Tag',tag_t_l_sep);
            end
            for k = 1:nb_a_r_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                               'XTickLabelMode','manual','XTickLabel',[]}; %#ok<CCAT>
                end
                out2(k) = axes(axeProp{:},'UserData',k,'Tag',tag_a_r_sep);
                if k==Level_Anal+2
                    txt_str  = 'cfs';
                    set(out2(k),'YDir','reverse');
                elseif k==Level_Anal+1
                    txt_str = 's/ss';
                else
                    txt_str = ['d' wnsubstr(k)];
                end
                out4(k) = txtinaxe('create',txt_str,out2(k),'r','off','bold',20);
                set(out4(k),'UserData',k,'Tag',tag_t_r_sep);
            end
            w_fra = 0.01*pos_win(3);
            x_fra = pos_graph(1)+(pos_graph(3)-w_fra)/2;
            y_fra = pos_graph(2);
            h_fra = pos_graph(4);
            out5  = uicontrol(...
                            'Parent',win_dw1dtool,                ...
                            'Style','frame',                      ...
                            'Units',win_units,                     ...
                            'Position',[x_fra,y_fra,w_fra,h_fra], ...
                            'Visible','Off',                      ...
                            'BackgroundColor',Def_FraBkColor,     ...
                            'Tag',tag_fra_sep                     ...
                            );
        end
        set(findobj([out1 out2]),'Visible','off');
        if nb_a_left*nb_a_right~=0
            set(out5,'Visible','On');
        else
            set(out5,'Visible','Off');
        end
        fontsize = wmachdep('FontSize','normal',9,max(nb_a_right,nb_a_left));
        for k = 1:nb_a_left
            ind = ind_left(k);
            set(out1(ind),'Position',pos_a_left(k,:),'Visible','On');
            txtinaxe('pos',out3(ind));
            set(out3(ind),'FontSize',fontsize,'Visible','on');
        end
        for k = 1:nb_a_right
            ind = ind_right(k);
            set(out2(ind),'Position',pos_a_right(k,:),'Visible','On');
            txtinaxe('pos',out4(ind));
            set(out4(ind),'FontSize',fontsize,'Visible','on');
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_app = findobj(lin_handles,'Tag',tag_ssa_sep);
        ss_det = findobj(lin_handles,'Tag',tag_ssd_sep);
        delete([ss_app ss_det]);

    case 'clear'
        dynvtool('stop',win_dw1dtool);
        out1 = findobj(axe_handles,'flat','Tag',tag_a_l_sep);
        out2 = findobj(axe_handles,'flat','Tag',tag_a_r_sep);
        out5 = findobj(fra_handles,'Tag',tag_fra_sep);
        delete([out1(:)' out2(:)' out5]);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
        

