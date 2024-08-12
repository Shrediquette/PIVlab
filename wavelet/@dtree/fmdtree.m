function varargout = fmdtree(option,t,varargin)
%FMDTREE Field manager for DTREE object.
%   VARARGOUT = FMDTREE(OPT,T,VARARGIN)
%
%   For dtree object implementation see the
%   Class Constructor DTREE.
%
% Utilities:
%===========
%   If T is the tree, I a column vector containing nodes indices
%   C a vector containing columns indices and V a matrix which
%   contains all-nodes infos:
%
%   V = FMDTREE('an_read',T) is equivalent to V = GET(T,'allNI')
%   V = FMDTREE('an_read',T,I)
%   V = FMDTREE('an_read',T,I,C)
%   V = FMDTREE('an_read',T,'all',C)
%
%   T = FMDTREE('an_write',T,V) is equivalent to T = SET(T,'allNI',V)
%   T = FMDTREE('an_write',T,V,'add')
%   T = FMDTREE('an_write',T,V,I)
%   T = FMDTREE('an_write',T,V,'add',C)
%   T = FMDTREE('an_write',T,V,I,C)
%
%   T = FMDTREE('an_del',T,I) suppress all-nodes infos.
%   I is a vector which contains nodes indices.
%

% INTERNAL OPTIONS:
%===============================================================
% OPT = 'setinit', set initial data.
% OPT = 'getinit', get initial data.
%---------------------------------------------------------------
% allNI - All nodes Info: Array(nbnode,3+nbinfo_by_node)
%   allNI(:,1)     = node index.
%   allNI(:,2:3)   = size of node data.
%   allNI(:,4:end) = depends of Class.
%
%   'an_del'   - all nodes infos: delete.
%   'an_write' - all nodes infos: write.
%   'an_read'  - all nodes infos: read.
%---------------------------------------------------------------
% terNI - Terminal nodes Info: CellArray(1,2)
%   c{1} = Array(nbternod,2)  <--- sizes
%   c{2} = Array(1,:)         <--- infos
%
%   'tn_beglensiz' - terminal nodes infos: begin-length-size.
%   'tn_write'     - terminal nodes infos: write.
%   'tn_read'      - terminal nodes infos: read.
%===============================================================

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

nbin = length(varargin);
switch option
   %==========% BEG INIT %==========%
    case 'setinit'
      % nargin = 3
      %    in3 = initial root data
      %
      % nargin = 4  EXPAND TREE
      %    in3 = initial root info.
      %    in4 = flag ('expand')
      %------------------------------
      [order,depth] = get(t,'order','depth');
      switch order
         case 0    , nbn = 0;
         case 1    , nbn = depth;
         otherwise , nbn = (order^(depth+1)-1)/(order-1);
      end
      if nargin<4
          rootsize = size(varargin{1});
          t.terNI = {rootsize , varargin{1}(:)'};
          t.allNI = [(0:nbn-1)',[rootsize ; zeros(nbn-1,length(rootsize))]];

      elseif ~isempty(varargin{1})
          tmp = NaN*ones(nbn,length(varargin{1}));
          tmp(1,:) = varargin{1};
          t.allNI  = [t.allNI , tmp];
      end
      varargout{1} = t;

    case 'getinit'
      rootsize = t.terNI{1}(1,:);
      varargout{1} = reshape(t.terNI{2},rootsize);
   %==========% END INIT %==========%


   %==========% BEG ALL NODES INFO %==========%
    case 'an_del'
      % in3 = node indices.
      % out1 = new tree.
      %--------------------
      nodes = t.allNI(:,1);
      idx = gidxsint(nodes,varargin{1});
      t.allNI(idx,:) = [];
      varargout{1} = t;

    case 'an_write'
      % nargin = 3
      %    in3 = new value (first column = indices)
      % nargin = 4
      %    in3 = inserted value
      %    if   in4 = 'add' , add value.
      % nargin = 5
      %    in3 = inserted value
      %    in4 = nodes indices.
      %    if   in4 = 'all' , all nodes.
      %    in5 = columns.
      % out1 = new tree
      %---------------------------------------------
      switch nargin
          case 3
              t.allNI = varargin{1};

          case 4
              if isequal(varargin{2},'add')
                 t.allNI = [t.allNI;varargin{1}];
              else
                 i_nodes = gidxsint(t.allNI(:,1),varargin{2});
                 t.allNI(i_nodes,:) = varargin{1};
              end

          case 5
              if ischar(varargin{2})   % all nodes
                 i_nodes = (1:size(t.allNI,1))';
              else
                 i_nodes = gidxsint(t.allNI(:,1),varargin{2});
              end
              t.allNI(i_nodes,varargin{3}) = varargin{1};

      end
      varargout{1}  = t;

    case 'an_read'
      % if nargin = 2
      %     reads all Tabinfos.
      % if nargin = 3
      %     in3 = nodes indices in tree structure.
      % if nargin = 4
      %     in3 = nodes indices in tree structure.
      %     or
      %     in3 = 'all' (all rows)
      %     in4 = columns indices of allNI.
      % out1 = infos (first column = indices)
      %--------------------------------------------
      switch nargin
          case 2
              varargout{1} = t.allNI;

          case 3
              i_nodes = gidxsint(t.allNI(:,1),varargin{1});
              varargout{1} = t.allNI(i_nodes,:);

          case 4
              if ischar(varargin{1})   % all nodes
                 i_nodes = (1:size(t.allNI,1))';
              else
                 i_nodes = gidxsint(t.allNI(:,1),varargin{1});
              end
              varargout{1} = t.allNI(i_nodes,varargin{2});

      end
   %==========% END ALL NODES INFO %==========%


   %==========% BEG TERMINAL NODES INFO %==========%
    case 'tn_beglensiz'
      % in3 = indice(s) in tree structure
      %-----------------------------------
      indices = varargin{1};
      nb      = length(indices);
      beg     = zeros(nb,1);
      sizes   = t.terNI{1};
      for k=1:nb
          % attention prod([])=1
          if indices(k) ~= 1
              beg(k) = sum(prod(sizes(1:indices(k)-1,:),2));
          end
      end
      varargout{1} = beg+1;
      varargout{2} = prod(sizes(indices,:),2);
      varargout{3} = sizes(indices,:);

    case 'tn_write'
      % nargin = 3
      %    in3 = new data
      % nargin = 4
      %    in3 = new sizes
      %    in4 = new data
      % nargin = 5
      %    in3 = replaced indice(s) in tree structure.
      %      if len(in3)>1 , replace brother nodes...
      %    in4 = inserted sizes.
      %    in5 = inserted data.
      % out1 = new tree
      %-----------------------------------------------
      switch nargin
        case 3 , t.terNI = {size(varargin{1}),varargin{1}(:)'};
        case 4 , t.terNI = {varargin{1},varargin{2}(:)'};

        case 5
          old = varargin{1};
          nbr = length(old);
          
          % Compute begin and length.
          sizes = t.terNI{1};
          if old(1) ~= 1
              beg = sum(prod(sizes(1:old(1)-1,:),2)) + 1;
          else
              beg = 1;
          end
          len = sum(prod(sizes(old,:),2));
          
          % Modification of sizes.
          tmp = t.terNI{1};
          tmp = [tmp(1:old(1)-1,:) ; varargin{2} ; tmp(old(nbr)+1:end,:)];
          t.terNI{1} = tmp;
          
          % Modification of data.
          tmp = t.terNI{2};
          insertDATA = varargin{3}(:)';
          tmp = [tmp(1,1:beg-1) , insertDATA , tmp(1,beg+len:end)];
          t.terNI{2} = tmp;
          
      end
      varargout{1} = t;

    case 'tn_read'
      % in3 = 'sizes'
      %     out1 = matrix of sizes of terminal nodes data.
      %     in4 = indices in tree structure (optional)
      % in3 = 'databloc'
      %     out1 = row vector containing compacted nodes data.
      % in3 = 'data'
      %     in4 = indices in tree structure
      %     out1 = Cell Array containing nodes data
      %------------------------------------------------------------
      if nbin<1 , rmode = 'databloc'; else rmode = varargin{1}; end
      switch rmode
          case 'sizes'
              if nargin==3 || isequal(varargin{2},'all')
                  varargout{1} = t.terNI{1};
              else
                  varargout{1} = t.terNI{1}(varargin{2},:);
              end

          case 'databloc'
              varargout{1} = t.terNI{2};

          case 'data'
              sizes   = t.terNI{1};
              cfs     = t.terNI{2};
              indices = varargin{2};
              nbnodes = length(indices);
              sizDATA = sizes(indices,:);
              beg     = zeros(nbnodes,1);
              len     = prod(sizDATA,2);
              for k=1:nbnodes
                  % attention prod([])=1
                  if indices(k) ~= 1
                      beg(k) = sum(prod(sizes(1:indices(k)-1,:),2));
                  end
              end
              beg = beg + 1;
              lim = beg + len - 1;
              for k=1:nbnodes
                  if beg(k)<=lim(k)
                      varargout{1}{k} = zeros(sizDATA(k,:));
                      varargout{1}{k}(:) = cfs(beg(k):lim(k));
                  else
                      varargout{1}{k} = [];
                  end
              end

      end
   %==========% END TERMINAL NODES INFO %==========%

   otherwise
      error(message('Wavelet:FunctionArgVal:Unknown_Opt')); 

end
