classdef GridBagLayout < wavelet.internal.layout.AbstractLayout
    %GridBagLayout - Constructs a GridBagLayout layout manager.
    %   layout.GridBagLayout(H) Constructs a GridBagLayout object to manage
    %   the Handle Graphics object H.  H can be a figure, uicontainer or
    %   uipanel.
    %
    %   GridBagLayout methods:
    %       add            - Add a component to the layout.
    %       clean          - Remove excess spacing.
    %       insert         - Insert a row or column of empty space.
    %       remove         - Remove a component.
    %       setConstraints - Set various spacing constraints.
    %       update         - Force an update.
    %
    %   GridBagLayout public fields:
    %       VerticalGap       - Vertical gap between components.
    %       HorizontalGap     - Horizontal gap between components.
    %       VerticalWeights   - Vertical weights used for spacing.
    %       HorizontalWeights - Horizontal weights used for spacing.
    %       Grid              - Stores all the components in a matrix.
    %       Panel             - Stores the parent of the components.
    %
    %  

%   Copyright 2016-2020 The MathWorks, Inc.
    
    properties
        
        %VerticalGap The vertical gap between widgets.  This is the
        %   uniform gap between the widgets and the widgets and the edges
        %   of the frame.  To specify addition gap for specific widgets use
        %   the IPad or Inset constraints.
        VerticalGap = 0;
        
        %HorizontalGap The horizontal gap between widgets.  This is the
        %   uniform gap between the widgets and the widgets and the edges
        %   of the frame.  To specify addition gap for specific widgets use
        %   the IPad or Inset constraints.
        HorizontalGap = 0;
        
        %VerticalWeights The weights used to calculate where to use extra
        %   pixels among the rows.  The higher the weight for a specific
        %   row results in more extra pixels being given to the widgets in
        %   that row.  This value is always of length equal to size(H.Grid,
        %   1).  If additional rows are added to the Grid a value of 0 will
        %   be added to the end of the weights.  If the Grid is reduced,
        %   extra weights will be discarded.
        VerticalWeights = [];
        
        %HorizontalWeights The weights used to calculate where to use extra
        %   pixels among the columns.  The higher the weight for a specific
        %   column results in more extra pixels being given to the widgets
        %   in that column.  This value is always of length equal to
        %   size(H.Grid, 2).  If additional columns are added to the Grid a
        %   value of 0 will be added to the end of the weights.  If the
        %   Grid is reduced, extra weights will be discarded.
        HorizontalWeights = [];
    end
    
    properties (SetAccess = protected)
        
        %Grid A matrix storing all of the widgets parented to the specified
        %   container.  NaN values are used for empty cells.
        Grid;
    end
    
    methods
        
        function this = GridBagLayout(hPanel, varargin)
            %GridBagLayout   Construct the GridBagLayout class.
            
            this@wavelet.internal.layout.AbstractLayout(hPanel);
            
            for indx = 1:2:length(varargin)
                this.(varargin{indx}) = varargin{indx+1};
            end
        end
        
        function add(this, h, row, col, varargin)
            %add Add a component to the layout manager.
            %   add(H, HCOMP, ROW, COL) Add the HG object HCOMP to the
            %   layout manager H in the row (ROW) and column (COL)
            %   specified.  ROW and COL must be scalars or vectors of
            %   length two.  When specified as a scalar that exact position
            %   in the grid is used.  When specified as a vector of length
            %   two, they are used to determine the limits of the row or
            %   column span, e.g. a single component can be placed over
            %   multiple cells in the grid.
            %
            %   add(H, ..., CONSTRAINT1, VALUE1, etc.) Optional constraints
            %   can be passed as additional arguments.  See setConstraints
            %   for the complete list of constraints.
            %
            %   Children of the managed container are not automatically
            %   added to the layout.  They must be explicitly added via the
            %   add method.
            %
            %   See also setConstraints, remove.
            
            narginchk(4, inf);
            
            add@wavelet.internal.layout.AbstractLayout(this, h, row, col);
            
            g = this.Grid;
            
            g(min(row):max(row), min(col):max(col)) = h;
            
            if ~isappdata(h, this.CONSTRAINTSTAG)
                setappdata(h, this.CONSTRAINTSTAG, wavelet.internal.layout.GridBagConstraints);
            end
            
            % Convert any added zeros to NaN.
            g(g == 0) = NaN;
            
            this.Grid = g;
            
            if nargin > 4
                setConstraints(this, row, col, varargin{:});
            end
        end
        
        function insert(this, type, indx)
            %insert   Insert a row or a column at an index.
            %   insert(H, TYPE, INDX) Insert either a 'row' or 'column'
            %   (TYPE) of NaNs into the Grid at the row or column INDX.
            %
            %   See also add, remove.
            
            g = this.Grid;
            
            [rows cols] = size(g);
            
            switch lower(type)
                case 'row'
                    if indx > rows + 1
                        g = [g; NaN(indx-rows, cols)];
                    else
                        g = [g(1:indx-1,:); NaN(1, cols); g(indx:end,:)];
                    end
                case 'column'
                    if indx > cols + 1
                        g = [g NaN(rows, indx-cols)];
                    else
                        g = [g(:, 1:indx-1) NaN(rows, 1) g(:, indx:end)];
                    end
            end
            
            this.Grid = g;
        end
        
        function remove(this, indx, jndx)
            %remove   Remove the handle from the manager.
            %   remove(H, HCOMP) Removes the specified HG object HCOMP from
            %   the layout manager H.
            %
            %   remove(H, ROW, COL) Removes the object stored in the Grid
            %   at the ROW and COL specified.
            %
            %   See also add, insert.
            
            g = this.Grid;
            
            if nargin == 2
                h = indx;
                
                g(g == h) = NaN;
                
                % Reset the grid and clean up the listeners vector.
                this.Grid = g;
            else
                remove(this, g(indx, jndx));
            end
        end
        
        function clean(this)
            %clean   Remove Trailing rows/columns with only NaN values.
            %
            %   See also add, insert, remove.
            
            g = this.Grid;
            
            [rows cols] = size(g);
            
            % Clean up any extra rows in the grid.
            indx = rows;
            while indx > 0 && all(isnan(g(indx,:)))
                g(indx,:) = [];
                indx      = indx-1;
            end
            
            indx = cols;
            while indx > 0 && all(isnan(g(:,indx)))
                g(:,indx) = [];
                indx      = indx-1;
            end
            
            this.Grid = g;
        end
        
        function setConstraints(this, row, col, varargin)
            %setConstraints   Set the constraints for the specified component.
            %   setConstraints(HLAYOUT, LOCATION, PARAM1, VALUE1, etc.) Set the
            %   constraints for the component in LOCATION.
            %
            %   SETCONSTRAINTS(HLAYOUT, LOCATION, 'default') when the string 'default'
            %   is passed to SETCONSTRAINTS the stored constraints are reset to their
            %   default values.
            %
            %   Parameter Name      Valid Values        Default
            %   MinimumHeight       Positive Numbers    20
            %   MinimumWidth        Positive Numbers    20
            %   PreferredHeight     Positive Numbers    20
            %   PreferredWidth      Positive Numbers    20
            %   MaximumHeight       Positive Numbers    inf
            %   MaximumWidth        Positive Numbers    inf
            %   IPadX               Real Numbers        0
            %   IPadY               Real Numbers        0
            %   LeftInset           Real Numbers        0
            %   RightInset          Real Numbers        0
            %   TopInset            Real Numbers        0
            %   BottomInset         Real Numbers        0
            %   Fill                'None'              'None'
            %                       'Horizontal'
            %                       'Vertical'
            %                       'Both'
            %   Anchor              'Center'            'Center'
            %                       'Northwest'
            %                       'North'
            %                       'Northeast'
            %                       'East'
            %                       'Southeast'
            %                       'South'
            %                       'Southwest'
            %                       'West'
            
            narginchk(3, inf);
            
            % Do not error out if no constraints are passed.
            if nargin < 5
                return;
            end
            
            % Get the component from the subclass.
            hComponent = getComponent(this, row, col);
            
            % Get the old constraints.
            ctag           = this.CONSTRAINTSTAG;
            oldConstraints = getappdata(hComponent, ctag);
            
            if strcmpi(varargin{1}, 'default')
                
                % If the pv pairs is just 'default' remove all constraints.
                if ~isempty(oldConstraints)
                    rmappdata(hComponent, ctag);
                end
            else
                
                % If there are no old constraints, create a new object.
                if isempty(oldConstraints)
                    c = wavelet.internal.layout.GridBagConstraints(varargin{:});
                    setappdata(hComponent, ctag, c);
                else
                    
                    % If there are old constraints, just set the object with the new
                    % constraints, don't throw away any old ones.
                    for indx = 1:2:length(varargin)-1
                        oldConstraints.(varargin{indx}) = varargin{indx+1};
                    end
                end
            end
            
            this.Invalid = true;
            
            % Force a call to update.
            update(this);
        end
    end
    
    methods (Access = protected)
        
        function component = getComponent(this, row, col)
            
            g = this.Grid;
            
            component = [];
            
            if max(row) <= size(g, 1) && max(col) <= size(g, 2)
                for indx = 1:length(row)
                    for jndx = 1:length(col)
                        if ~isnan(g(row(indx), col(jndx)))
                            component = [component; g(row(indx), col(jndx))]; %#ok<AGROW>
                        end
                    end
                end
            end
            component = unique(component);
        end
        
        function [m, n] = getComponentSize(this, indx, jndx)
            %GETCOMPONENTSIZE   Get the componentsize.
            
            g = this.Grid;
            
            h = g(indx, jndx);
            
            if isnan(h)
                m = 0;
                n = 0;
            else
                m = find(g(:, jndx) == h, 1, 'last' ) - indx + 1;
                n = find(g(indx,:) == h, 1, 'last' )  - jndx + 1;
            end
            
            if nargout < 2
                m = [m n];
            end
        end
        
        function layout(this)
            %LAYOUT   Layout the container.
            
            grid = this.Grid;
            if isempty(grid)
                return;
            end
            
            panelpos    = this.PanelPosition;
            ctag        = this.CONSTRAINTSTAG;
            [rows cols] = size(grid);
            
            hg = this.HorizontalGap;
            vg = this.VerticalGap;
            vw = this.VerticalWeights;
            hw = this.HorizontalWeights;
            
            % If all of the weights are zero convert them all to ones so that we can do
            % easier math on them, because 0/sum([0 0 0]) doesn't work.
            if all(hw == 0)
                hw = ones(size(hw));
            end
            if all(vw == 0)
                vw = ones(size(vw));
            end
            
            minheight = zeros(size(grid));
            minwidth  = minheight;
            
            % Get all the heights
            for indx = 1:rows
                for jndx = 1:cols
                    if ishghandle(grid(indx,jndx))
                        
                        [n, m] = getComponentSize(this, indx, jndx);
                        
                        hC = getappdata(grid(indx,jndx), ctag);
                        if isempty(hC)
                            minh = 20;
                            minw = 20;
                        else
                            % Each grid location has a minimum height of the insets +
                            % the minimum dimension of the component.
                            minh = (hC.MinimumHeight+hC.BottomInset+hC.TopInset)/n;
                            minw = (hC.MinimumWidth+hC.LeftInset+hC.RightInset)/m;
                        end
                        
                        % Remove the control from the grid.
                        grid(indx:indx+n-1,jndx:jndx+m-1) = NaN;
                        
                        minheight(indx:indx+n-1,jndx) = minh;
                        minwidth(indx,jndx:jndx+m-1)  = minw;
                    end
                end
            end
            
            % The minimum height for each row is the max of all the minimum heights in
            % each column.  Vice-versa for the minimum width.
            minheight = max(minheight, [], 2);
            minwidth  = max(minwidth,  [], 1);
            
            % Calculate the final widths by determining the number of leftover pixels
            % and dividing them according to the weights property for the given
            % dimension.
            if cols == 1
                
                % If the is just one column, the width is just the panel width minus
                % two horizontal gaps
                widths = panelpos(3)-2*hg;
            else
                
                % Subtract the sum of the minimum widths from the panel width and then
                % one extra horizontal gap so that we have one on each side.
                leftoverwidth  = panelpos(3)-sum(minwidth)-hg*(cols+1);
                widths = minwidth+leftoverwidth*hw/sum(hw);
            end
            
            if rows == 1
                
                % If there is just one row, the height is the panel height minus two
                % vertical gaps.
                heights = panelpos(4)-2*vg;
            else
                
                % Subtract the sum of the minimum heights from the panel height and
                % then one extra vertical gap so that we have one on each side.
                leftoverheight = panelpos(4)-sum(minheight)-vg*(rows+1);
                heights = minheight+leftoverheight*vw/sum(vw);
            end
            
            grid = this.Grid;
            for indx = 1:rows
                for jndx = 1:cols
                    if ishghandle(grid(indx,jndx))
                        
                        [n m] = getComponentSize(this, indx, jndx);
                        
                        % Calculate the grid position given the grids width and height.
                        gridpos = [ ...
                            sum(widths(1:jndx-1))+hg*jndx+1 ...
                            panelpos(4)-sum(heights(1:indx+n-1))-vg*(indx+n-1)+1 ...
                            sum(widths(jndx:jndx+m-1))+hg*(m-1) ...
                            sum(heights(indx:indx+n-1))+vg*(n-1)];
                        
                        if isappdata(grid(indx, jndx), ctag)
                            hC = getappdata(grid(indx, jndx), ctag);
                            
                            % Add the insets to the grid position.
                            gridpos = gridpos + [...
                                hC.LeftInset ...
                                hC.BottomInset ...
                                -hC.LeftInset-hC.RightInset ...
                                -hC.BottomInset-hC.TopInset];
                            
                            % Get the final width and height from the Fill and
                            % Preferred Dimension constraints.
                            pos = gridpos;
                            switch lower(hC.Fill)
                                case 'none'
                                    % Start with an anchor of southwest
                                    if pos(3) > hC.PreferredWidth
                                        pos(3) = hC.PreferredWidth;
                                    end
                                    if pos(4) > hC.PreferredHeight
                                        pos(4) = hC.PreferredHeight;
                                    end
                                case 'horizontal'
                                    if pos(4) > hC.PreferredHeight
                                        pos(4) = hC.PreferredHeight;
                                    end
                                case 'vertical'
                                    % Start with an anchor of southwest
                                    if pos(3) > hC.PreferredWidth
                                        pos(3) = hC.PreferredWidth;
                                    end
                                case 'both'
                                    % This is a no-op, let it fill the whole area.
                            end
                            
                            % Get the x and y from the anchor.
                            switch lower(hC.Anchor)
                                case 'southwest'
                                    % NO OP, already at the origin of the grid area.
                                case 'west'
                                    pos(2) = pos(2)+(gridpos(4)-pos(4))/2;
                                case 'northwest'
                                    pos(2) = pos(2)+gridpos(4)-pos(4);
                                case 'north'
                                    pos(1) = pos(1)+(gridpos(3)-pos(3))/2;
                                    pos(2) = pos(2)+gridpos(4)-pos(4);
                                case 'northeast'
                                    pos(1) = pos(1)+gridpos(3)-pos(3);
                                    pos(2) = pos(2)+gridpos(4)-pos(4);
                                case 'east'
                                    pos(1) = pos(1)+gridpos(3)-pos(3);
                                    pos(2) = pos(2)+(gridpos(4)-pos(4))/2;
                                case 'southeast'
                                    pos(1) = pos(1)+gridpos(3)-pos(3);
                                case 'south'
                                    pos(1) = pos(1)+(gridpos(3)-pos(3))/2;
                                case 'center'
                                    pos(1) = pos(1)+(gridpos(3)-pos(3))/2;
                                    pos(2) = pos(2)+(gridpos(4)-pos(4))/2;
                            end
                        else
                            
                            % Without a constraints object use the defaults of 20/20
                            % 'center' and 'none'.
                            pos = gridpos;
                            if pos(3) > 20
                                pos(3) = 20;
                            end
                            if pos(4) > 20
                                pos(4) = 20;
                            end
                            pos(1) = pos(1)+(gridpos(3)-pos(3))/2;
                            pos(2) = pos(2)+(gridpos(4)-pos(4))/2;
                        end
                        
                        % Make sure that we use 1 pixel for everything.  Avoid errors.
                        pos(pos < 1) = 1;
                        
                        % Set the components new position.
                        if ishghandle(grid(indx, jndx), 'axes') && ...
                                strcmp(get(grid(indx, jndx), 'ActivePositionProperty'), 'outerposition')
                            oldUnits = get(grid(indx, jndx), 'Units');
                            set(grid(indx, jndx), 'Units', 'Pixels', 'OuterPosition', pos);
                            set(grid(indx, jndx), 'Units', oldUnits);
                        else
                            setpixelposition(grid(indx,jndx), pos);
                        end
                        
                        % Remove the control from the grid.
                        grid(indx:indx+n-1,jndx:jndx+m-1) = NaN;
                    end
                end
            end
        end
    end
    
    methods
        
        function hWeights = get.HorizontalWeights(this)
            
            % Trim the weights to match the size of the Grid.  Add zeros if
            % the grid grows.
            hWeights = resizeWeights(this, this.HorizontalWeights, 2);
            
        end
        
        function vWeights = get.VerticalWeights(this)
            
            vWeights = resizeWeights(this, this.VerticalWeights, 1);
            
        end
        
        function set.VerticalGap(this, vGap)
            % This should never get hit 
            if ~isscalar(vGap) || ~isnumeric(vGap) || isnan(vGap) || isinf(vGap)
                error(message('Wavelet:gridbaglayout:gridbagverticalgap'));
            end
            
            this.VerticalGap = vGap;
            this.Invalid = true;
            update(this);
        end
        
        function set.HorizontalGap(this, hGap)
            % This should never get hit 
            if ~isscalar(hGap) || ~isnumeric(hGap) || isnan(hGap) || isinf(hGap)
                error(message('Wavelet:gridbaglayout:gridbaghorizontalgap'));
            end
            
            this.HorizontalGap = hGap;
            this.Invalid = true;
            update(this);
        end
        
        function set.VerticalWeights(this, vWeights)
            % This should never get hit 
            if ~any(isnumeric(vWeights)) || any(isnan(vWeights)) || any(isinf(vWeights))
                error(message('Wavelet:gridbaglayout:gridbagverticalweights'));
            end
            
            this.VerticalWeights = vWeights;
            this.Invalid = true;
            update(this);
        end
        
        function set.HorizontalWeights(this, hWeights)
            % This should never get hit 
            if ~any(isnumeric(hWeights)) || any(isnan(hWeights)) || any(isinf(hWeights))
                error(message('Wavelet:gridbaglayout:gridbaghorizontalweights'));
            end
            
            this.HorizontalWeights = hWeights;
            this.Invalid = true;
            update(this);
        end
        
        function set.Grid(this, grid)
            this.Grid = grid;
            this.Invalid = true;
            update(this);
        end
    end
end

function weights = resizeWeights(this, weights, dimension)

nw = size(this.Grid, dimension);

% Only return a number of weights equal to the width of the grid.
weights = [weights zeros(1, nw-length(weights))];
weights = weights(1:nw);

weights = weights(:);
if dimension == 2
    weights = weights';
end
end

% [EOF]
