function out1 = wp1ddraw(option,win_wptool,in3)
%WP1DDRAW Wavelet packets 1-D drawing manager. 
%   OUT1 = WP1DDRAW(OPTION,WIN_WPTOOL,IN3)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Nov-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Memory Blocks of stored values.
%================================
% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
% ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_gra_area  = 5;
ind_nb_colors = 6;
% nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_pop_colm  = 'Txt_PopM';
tag_curtree   = 'Pop_CurTree';
tag_nodact    = 'Pop_NodAct';
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_lin_sig   = 'Lin_sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

% Miscellaneous values.
%----------------------
Col_SigIni  = 'r';
children    = get(win_wptool,'Children');
axe_handles = findobj(children,'flat','Type','axes');
uic_handles = findobj(children,'flat','Type','uicontrol');
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
WP_Axe_Col  = findobj(axe_handles,'flat','Tag',tag_axe_col);
WP_Sli_Size = findobj(uic_handles,'Tag',tag_sli_size);
WP_Sli_Pos  = findobj(uic_handles,'Tag',tag_sli_pos);

switch option
    case 'sig'
        % Signal_Anal = in3;
        %-------------------
        set_Sliders_Pos_Size(WP_Sli_Size,WP_Sli_Pos,WP_Axe_Tree);
        set([ WP_Axe_Tree,WP_Axe_Cfs,WP_Axe_Sig,WP_Axe_Pack, ...
              WP_Axe_Col,WP_Sli_Size],'Visible','on');
        set(WP_Axe_Tree,'fontsize',7); %High DPI
          
        xmin = 1;         xmax = length(in3);
        ymin = min(in3);  ymax = max(in3);
        if ymin==ymax , dy = 0.01; else dy = (ymax-ymin)/25; end
        ymin = ymin-dy;   ymax = ymax+dy;
        plot(in3,'Color',Col_SigIni,'Tag',tag_lin_sig,'Parent',WP_Axe_Sig);
        set(WP_Axe_Sig,'XLim',[xmin xmax],'YLim',[ymin ymax],'Tag',tag_axe_sig);
        wtitle(getWavMSG('Wavelet:wp1d2dRF:LenSigAnal',xmax),...
                'Parent',WP_Axe_Sig);
        wtitle(getWavMSG('Wavelet:wp1d2dRF:DecTree'),'Parent',WP_Axe_Tree);
        wtitle(getWavMSG('Wavelet:wp1d2dRF:NodActRes'),'Parent',WP_Axe_Pack);
        set(WP_Axe_Cfs,'XLim',[xmin xmax]);
        wtitle(getWavMSG('Wavelet:wp1d2dRF:ColCfsTN'),'Parent',WP_Axe_Cfs);
        pop_colm = findobj(win_wptool,'Style','popupmenu',...
                                        'Tag',tag_pop_colm);
        col_mode = get(pop_colm,'Value');
        if find(col_mode==[1 2 3 4])
            strlab = getWavMSG('Wavelet:wp1d2dRF:FrqOrdCfs');
        else
            strlab = getWavMSG('Wavelet:wp1d2dRF:DUCf_LRTr');
        end
        wsetxlab(WP_Axe_Cfs,strlab);
        NB_ColorsInPal  = wmemtool('rmb',win_wptool,    ...
                                        n_wp_utils,ind_nb_colors);
        image([0 1],[0 1],(1:NB_ColorsInPal),'Parent',WP_Axe_Col);
        set(WP_Axe_Col,...
                'XTickLabel',[],'YTickLabel',[],...
                'XTick',[],'YTick',[],'Tag',tag_axe_col);
        wsetxlab(WP_Axe_Col,getWavMSG('Wavelet:commongui:ScaColMinMax'));

    case 'anal'
        pop_handles = findobj(uic_handles,'Style','popupmenu');
        pop_curtree = findobj(pop_handles,'Tag',tag_curtree);
        pop_nodact  = findobj(pop_handles,'Tag',tag_nodact);

        % Reading structures.
        %--------------------
        WP_Tree = wtbxappdata('get',win_wptool,'WP_Tree');
        wptreeop('input_tree',win_wptool,WP_Tree);
        depth = treedpth(WP_Tree);
        str_depth = int2str((0:depth)');
        set(pop_curtree,'String',str_depth,'Value',depth+1);
        wtitle(getWavMSG('Wavelet:wp1d2dRF:NodActRes'),'Parent',WP_Axe_Pack);

        % Setting Dynamic Visualization tool.
        %------------------------------------
        dynvtool('init',win_wptool,...
            WP_Axe_Pack,[WP_Axe_Sig,WP_Axe_Cfs],[],[1 0],'','',...
                                          'wp1dcoor',WP_Axe_Cfs);
        wptreeop('nodact',win_wptool,pop_nodact);

    case 'r_orig'
        out1 = findobj(WP_Axe_Sig,'Type','line','Tag',tag_lin_sig);
end


%--------------------------------------------------------------------------
function set_Sliders_Pos_Size(WP_Sli_Size,WP_Sli_Pos,WP_Axe_Tree)

v = get(WP_Sli_Size,'Value');
set(WP_Sli_Size,'UserData',v);
half = 1/((2*v)^(v/4));
if v>1
    old_bound = get(WP_Sli_Pos,'Max');
    old_val   = get(WP_Sli_Pos,'Value');
    new_bound = abs(0.5-half);
    if old_bound ~= 0
        new_val = -new_bound + ...
            (old_val+old_bound)*(new_bound/old_bound);
    else
        new_val = 0;
    end
    delta = 0;
    if new_val>new_bound-delta
        new_val = new_bound-delta;
    elseif new_val<-new_bound+delta
        new_val = -new_bound+delta;
    end
    set(WP_Sli_Pos,'Min',-new_bound,'Max',new_bound,...
        'Value',new_val,'Visible','on');
else
    new_val = 0;
    set(WP_Sli_Pos,'Min',0,'Max',0,'Value',0,'Visible','off');
end
set(WP_Axe_Tree,'XLim',[new_val-half new_val+half]);
%--------------------------------------------------------------------------

