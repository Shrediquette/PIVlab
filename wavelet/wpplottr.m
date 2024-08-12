function wpplottr(option,win_wptool,Ts,in4,in5)
%WPPLOTTR Plot wavelet packets tree.
%   WPPLOTTR(OPTION,WIN_WPTOOL,TREE,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw or Redraw a tree after a node modification (split or merge)
%   win_wptool = handle of the figure which contains the plot.
%   d = depth of the node    : 0 <= d <= depth of the decomposition
%   b = position of the node : 0 <= b <= (ordre^d)-1
%   o = order of the tree (2 ou 4)
%   prof = depth of the tree
%   xnpos = row vector which contains the abscisses of the nodes.
%   table_node = row vector containing nodes indices.
%     table_node(i) =-1   if the node which index is i-1 doesn't exist
%     table_node(i) = i-1 if the node which index is i-1 exists
%     if depth-pos is (d,b) , i = (order^d-1)/(order-1)+b
%   txtstr = matrix which contains the string of the children of the node.
%   txtstr = [] if the nodes is a leaf.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
ind_nb_colors = 6;
nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_axe_t_lin = 'Axe_TreeLines';
tag_txt_in_t  = 'Txt_In_tree';
tag_lin_in_t  = 'Lin_In_tree';

% Handles.
%---------
axe_handles = findobj(get(win_wptool,'Children'),'flat','Type','axes');
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);

% Miscellaneous Values.
%----------------------
[txt_color,line_color,ftn_size] = ...
                wtbutils('wputils','plottree',get(WP_Axe_Tree,'Xcolor'));
order = treeord(Ts);
depth = treedpth(Ts);            
all   = allnodes(Ts);
NB    = (order^(depth+1)-1)/(order-1);
table_node = -ones(1,NB);
table_node(all+1) = all;
[xnpos,ynpos] = xynodpos(table_node,order,depth);

textProp = {...
   'Parent',WP_Axe_Tree,           ...
   'Clipping','on',                ...
   'Color',txt_color,              ...
   'HorizontalAlignment','center', ...
   'VerticalAlignment','middle',   ...
   'FontSize',ftn_size,            ...
   'FontWeight','bold',            ...
   'Tag',tag_txt_in_t              ...
   };

lineProp = {...
   'Parent',WP_Axe_Tree, ...
   'Color',line_color,   ...
   'Tag',tag_lin_in_t    ...
   };

switch option
    case 'first'
        Tree_Lines = zeros(1,NB);
        Tree_Texts = zeros(1,NB);
        i_fath  = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        Tree_Lines(ic) = line(...
                            lineProp{:},...
                            'XData',[xnpos(i_fath) xnpos(ic)],...
                            'YData',ynpos(d,:),            ...
                            'UserData',[i_fath ic]         ...
                        );
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end
        Tree_Texts(1) = text(textProp{:},...
                             'Position',[0 0.1 0],    ...
                             'UserData',table_node(1) ...
                             );
        i_fath  = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    p_child = p+[0:order-1];
                    for k=1:order
                        ic = i_child(k);
                        pt = [xnpos(ic) ynpos(d,2) 0];
                        Tree_Texts(ic) = ...
                            text(textProp{:},              ...
                                 'Position',pt,            ...
                                 'UserData',table_node(ic) ...
                                 );
                    end
                end
                i_child = i_child+order;
            end
        end
        Tree_Type_TxtV = 'p';
        set(WP_Axe_Tree,'Visible','on')

    case 'split_merge'
        node   = in4;
        txtstr = in5;
        [Tree_Lines,Tree_Texts,Tree_Type_TxtV] =...
            wmemtool('rmb',win_wptool,n_wp_utils,...
                           ind_tree_lin,ind_tree_txt,ind_type_txt);
        btndown_fcn = get(Tree_Texts(1),'ButtonDownFcn');
                
        % Create the new tree.
        %---------------------
        node  = depo2ind(order,node);
        [d,b] = ind2depo(order,node);

        % Suppress the descendants of the node.
        %--------------------------------------
        if isempty(txtstr)
            if NB < size(Tree_Texts,2)
                to_del = find(Tree_Texts(NB+1:size(Tree_Texts,2)))+NB;
                delete([Tree_Texts(to_del) Tree_Lines(to_del)]);
                Tree_Texts = Tree_Texts(1:NB);
                Tree_Lines = Tree_Lines(1:NB);
            end
            K = find((table_node==-1) & (Tree_Texts ~= 0));
            K = K(K>1);
            delete([Tree_Texts(K) Tree_Lines(K)]);
            Tree_Texts(K) = zeros(size(K));
            Tree_Lines(K) = zeros(size(K));

        % Create the descendants of the node.
        %------------------------------------
        else
            i_fath  = node+1;
            i_child = (i_fath-1)*order+2+[0:order-1];

            if NB > size(Tree_Lines,2)
                Tree_Texts = [Tree_Texts zeros(1,NB-size(Tree_Texts,2))];
                Tree_Lines = [Tree_Lines zeros(1,NB-size(Tree_Lines,2))];
            end
            for k=1:order
                ic = i_child(k);
                Tree_Lines(ic) = ...
                    line(lineProp{:},...
                         'XData',[xnpos(i_fath) xnpos(ic)],...
                         'YData',ynpos(d+1,:),             ...
                         'UserData',[i_fath ic]            ...
                         );
            end     
            for k=1:order
                ic = i_child(k);
                pt = [xnpos(ic) ynpos(d+1,2) 0];
                Tree_Texts(ic) = ...
                    text(textProp{:}, ...
                         'Position',pt,                 ...
                         'String',deblank(txtstr(k,:)), ...
                         'UserData',table_node(ic),     ...
                         'ButtonDownFcn',btndown_fcn    ...
                         );
            end
        end

        % Plot the new tree.
        %-------------------
        i_fath = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        set(Tree_Texts(ic),'Position',[xnpos(ic) ynpos(d,2) 0]);
                        set(Tree_Lines(ic),...
                              'XData',[xnpos(i_fath) xnpos(ic)], ...
                              'YData',ynpos(d,:));
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end

end
wmemtool('wmb',win_wptool,n_wp_utils,   ...
               ind_tree_lin,Tree_Lines,     ...
               ind_tree_txt,Tree_Texts,     ...
               ind_type_txt,Tree_Type_TxtV  ...
               );

