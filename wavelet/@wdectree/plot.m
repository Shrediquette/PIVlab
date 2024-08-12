function varargout = plot(t,varargin)
%PLOT Plot WVTREE object.
%   PLOT(T) plots the WVTREE object T.
%   FIG = PLOT(T) returns the handle of the figure, which
%   contains the tree T.
%   PLOT(T,FIG) plots the tree T in the figure FIG, which
%   already contains a tree.
%
%   PLOT is a graphical tree-management utility. The figure
%   that contains the tree is a GUI tool. It lets you change
%   the Node Label to Depth_Position or Index, and Node Action
%   to Split-Merge or Visualize.
%   The default values are Depth_Position and Visualize.
%
%   You can click the nodes to execute the current Node Action.
%
%   After some split or merge actions you can get the new tree
%   using the handle of the figure, which contains it.
%   You must use the following special syntax:
%       NEWT = PLOT(T,'read',FIG).
%   In fact, the first argument is dummy. Then the most general
%   syntax for this purpose is:
%       NEWT = PLOT(DUMMY,'READ',FIG);
%   where DUMMY is any object parented by an NTREE object.
%
%   DUMMY can be any object constructor name, which returns
%   an object parented by an NTREE object. For example:
%      NEWT = PLOT(ntree,'read',FIG);
%      NEWT = PLOT(dtree,'read',FIG);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Feb-2003.
%   Last Revision 07-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

nbin = length(varargin);
fig_tree = NaN;
switch nbin
  case 0    , option = 'create';
  otherwise
    option = varargin{1};
    if isnumeric(option)
        fig_tree = option;
        option = 'create';
    end
end

switch option
  case 'create'
  case {'length','type'} , fig_tree = varargin{2};  % Added Node Labels
  case 'Reconstruct'     , fig_tree = varargin{2};  % Added Node Action
  otherwise
      if ischar(option)  % Added Node Labels
          fig_tree = varargin{2}; 
      end
end

switch option
  case 'create'
    fig_tree = plot(t.dtree,fig_tree);
    figNum = double(fig_tree);
    
    if nargout>0 , varargout{1} = fig_tree; end
	set(fig_tree,'NumberTitle','Off','Name',...
            getWavMSG('Wavelet:moreMSGRF:WDECTREE_ExtMode',...
                    figNum,get(t,'extMode')));

    % Store the WVTREE.
    %------------------
    plot(dtree,'write',fig_tree,t);

    % Add Node Label menus.
    %----------------------
    plot(ntree,'addNodeLabel',fig_tree,'length');
    plot(ntree,'addNodeLabel',fig_tree,'type');

    % Add Node Action menu.
    %----------------------
    plot(ntree,'addNodeAction',fig_tree,'Reconstruct');

    % Set default Node Label to 'Index'.
    %-----------------------------------
    plot(ntree,'setNodeLabel',fig_tree,'Index');

  case {'length','type'}
    t = plot(ntree,'read',fig_tree);
    if nbin<3
        nodes = allnodes(t);
    else
        nodes = varargin{3};
    end
    n = length(nodes);
    switch option
      case 'length' , labtype = 's';
      case 'type'   , labtype = 't';
    end
    labels = tlabels(t,labtype,nodes);
    err    = ~isequal(n,size(labels,1));
    varargout = {labels,err};

  case 'Reconstruct'
    node = plot(ntree,'getNode',fig_tree);
    if isempty(node) , return; end
    t = plot(ntree,'read',fig_tree);
    axe_vis = plot(ntree,'getValue',fig_tree,'axe_vis');
    mousefrm(fig_tree,'watch')
    x = rnodcoef(t,node);
    if ~isempty(x)
        if min(size(x))<2
            plot(x,'Color','r','Parent',axe_vis);
            lx = length(x);
            if lx> 1 , set(axe_vis,'XLim',[1,lx]); end
        else
            if length(size(x))<3
                NBC = 128;
                Y = wcodemat(x,NBC,'mat',0);
                colormap(pink(NBC))
            else
                [~,P] = ind2depo(4,node);
                if P>0
                    NBC = 255;
                    Y = wcodemat(x,NBC,'mat',0);
                else
                    Y = x;
                end
                Y = uint8(Y);
            end
            image(Y,'Parent',axe_vis);
        end
        endMSG = 'TREE_DataForNode_1';
    else
        delete(get(axe_vis,'Children'))
        endMSG = 'TREE_DataForNode_2';
    end
    ldep = tlabels(t, 'p', node);
    axeTitle = getString(message(['Wavelet:moreMSGRF:' endMSG],node,ldep));
    wtitle(axeTitle,'Parent',axe_vis);
    mousefrm(fig_tree,'arrow')

  otherwise
    try
      nbout = nargout;
      varargout{1:nbout} = plot(dtree,varargin{:});
    catch %#ok<CTCH>
      labels = tlabels(t,varargin{1});
      varargout = {labels,0};
    end
        
end
