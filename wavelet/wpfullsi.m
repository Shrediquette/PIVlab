function wpfullsi(option,win_wptool,in3,in4,in5,in6,~)
%WPFULLSI Manage full size for axes.
%   WPFULLSI(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 18-Jun-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

if strcmp(option,'squish')
    % in3 = lst_handles
    % in4 = text handle
    % in5 = 'beg or 'end'
    % in6 = num full
    % in7 optional (redraw xlab)
    %-----------------------------
    WP_Axe_Cfs = in3(1);
    WP_Axe_Col = in3(2);
    usr = get(in4,'UserData');
    if strcmp(in5,'beg')
        old_pos = usr(1,:);
        new_pos = usr(2,:);
        if in6==4
            pos1 = get(WP_Axe_Cfs,'Position');
            pos2 = get(WP_Axe_Col,'Position');
            old_pos = [pos1(1) pos2(2) pos1(3) pos1(2)-pos2(2)+pos1(4)];
            dx = pos1(1)-pos2(1);
            dw = pos1(3)-pos2(3);
            dy = (pos1(2)-pos2(2)-pos2(4))/2;
            if abs(dx)>eps
                set(WP_Axe_Col,'Position',pos2+[dx 0 dw 0]);
            end
            set(WP_Axe_Cfs,'Position',pos1+[0 -dy 0 dy]);
            delta = [dx dy dw 0];
            set(in4,'UserData',[old_pos;new_pos;delta]);
        elseif in6==1
            sli_Pos  = in3(6); %#ok<NASGU>
            sli_Size = in3(7); %#ok<NASGU>
        end
    else
        new_pos = usr(1,:);
        old_pos = usr(2,:);
    end
    pos = new_pos(3:4)./old_pos(3:4);
    pos = [new_pos(1:2)-old_pos(1:2).*pos pos];
    for k=1:length(in3)
        p = get(in3(k),'position');
        p(1:2) = p(1:2).*pos(3:4)+pos(1:2);
        p(3:4) = p(3:4).*pos(3:4);
        set(in3(k),'position',p);
    end
    if (in6==4) && strcmp(in5,'end')
        delta = usr(3,:);
        dx = delta(1); dy = delta(2); dw = delta(3);
        if abs(dx)>eps
             set(WP_Axe_Col,'Position',get(WP_Axe_Col,'Position')-[dx 0 dw 0]);
        end
        set(WP_Axe_Cfs,'Position',get(WP_Axe_Cfs,'Position')+[0 dy 0 -dy]);                    
    end
    if nargin==7
        if (in6==4) || strcmp(in5,'end')
            xlab   = get(WP_Axe_Cfs,'xlabel');
            strlab = get(xlab,'String');
            wsetxlab(WP_Axe_Cfs,strlab);
            xlab   = get(WP_Axe_Col,'xlabel');
            strlab = get(xlab,'String');
            wsetxlab(WP_Axe_Col,strlab);
        end
    end
    return
end

% MemBloc2 of stored values.
%---------------------------
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
% ind_type_txt  = 3;
% ind_sel_nodes = 4;
ind_gra_area  = 5;
% ind_nb_colors = 6;
% nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_txt_full  = 'Txt_Full';
tag_pus_full  = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

children    = get(win_wptool,'Children');
axe_handles = findobj(children,'flat','Type','axes');
uic_handles = findobj(children,'flat','Type','uicontrol');
pus_full    = zeros(4,1);
for k =1:4
    pus_full(k) = (findobj(uic_handles,'Tag',tag_pus_full(k,:)))';
end
txt_full    = findobj(uic_handles,'Style','text','Tag',tag_txt_full);
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
WP_Axe_Col  = findobj(axe_handles,'flat','Tag',tag_axe_col);
Sli_Pos     = findobj(uic_handles,'Tag',tag_sli_pos);
Sli_Size    = findobj(uic_handles,'Tag',tag_sli_size);

lst_handles = [WP_Axe_Cfs,WP_Axe_Col,WP_Axe_Tree,...
               WP_Axe_Pack,WP_Axe_Sig,Sli_Pos,Sli_Size];

switch option
    case 'full'
        % in3 = btn number. 
        %------------------
        mx = 0.06; my =0.06;
        pos_gra = wmemtool('rmb',win_wptool,n_wp_utils,ind_gra_area);
        pos_gra(1:2) = pos_gra(1:2)+[mx my];
        pos_gra(3:4) = pos_gra(3:4)-2*[mx my];

        % Test begin or end.
        %-------------------
        num = in3;
        btn = pus_full(num);
        act = get(btn,'UserData');
        if act==0
            % begin full size
            %----------------
            col = get(btn,'BackgroundColor');
            old_num = 0;
            for k=1:length(pus_full)
                act_old = get(pus_full(k),'UserData');
                if act_old==1
                    old_num = k;
                    set(pus_full(k),...
                        'BackgroundColor',col,...
                        'String',sprintf('%.0f',k),...
                        'UserData',0);
                    break;
                end
            end
            set(btn,'String',[getWavMSG('Wavelet:commongui:Str_Close') ...
                                ' ' sprintf('%.0f',num)],'UserData',1);
            
            if old_num~=0
               pos_param = get(txt_full,'UserData'); %#ok<NASGU>
               wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',old_num);
            end
            delta = zeros(1,4);
            switch num
                case 1 , pos = get(WP_Axe_Tree,'Position');
                case 2 , pos = get(WP_Axe_Pack,'Position');
                case 3 , pos = get(WP_Axe_Sig,'Position');
                case 4 , pos = get(WP_Axe_Cfs,'Position');
            end
            if num==1
                vis = 'on';
                usr_Pos = get(Sli_Pos,'UserData');
                if isempty(usr_Pos)
                    p_Pos = get(Sli_Pos,'Position');
                    p_Siz = get(Sli_Size,'Position');
                    set(Sli_Pos,'UserData',[p_Pos;p_Siz])
                else
                    p_Pos = usr_Pos(1,:); p_Siz = usr_Pos(2,:);
                end
                p_Pos(4) = p_Pos(4)/2;
                p_Siz(2) = p_Siz(2) + p_Siz(4)/4; 
                p_Siz(4) = p_Siz(4)/2;
                set(Sli_Pos,'Position',p_Pos);
                set(Sli_Size,'Position',p_Siz);
            else
                vis = 'off';
            end
            set([Sli_Pos Sli_Size],'Visible',vis);
            set(txt_full,'UserData',[pos;pos_gra;delta]);
            wpfullsi('squish',win_wptool,lst_handles,txt_full,'beg',num,'xlab');
        else
            % end full size.
            %---------------
            col = get(pus_full(5-num),'BackgroundColor');
            set(btn,'BackgroundColor',col,...
                    'String',sprintf('%.0f',num),...
                    'UserData',0);
            wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',num,'xlab');
            usr_Pos = get(Sli_Pos,'UserData');
            if ~isempty(usr_Pos)
                p_Pos = usr_Pos(1,:); p_Siz = usr_Pos(2,:);
                set(Sli_Pos,'Position',p_Pos);
                set(Sli_Size,'Position',p_Siz);                
            end
            set([Sli_Pos Sli_Size],'Visible','on');
        end

    case 'clean'
        for k=1:length(pus_full)
            act_old = get(pus_full(k),'UserData');
            if act_old==1
                col = get(pus_full(5-k),'BackgroundColor');
                % old_num = k;
                set(pus_full(k),...
                    'BackgroundColor',col,...
                    'String',sprintf('%.0f',k),...
                    'UserData',0);
                wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',k);
                set([Sli_Pos Sli_Size],'Visible','on');  
                break;
            end
        end
end
