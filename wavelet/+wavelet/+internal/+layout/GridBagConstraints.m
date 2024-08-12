classdef GridBagConstraints < handle
    %GridBagConstraints   Define the GridBagConstraints class.

%   Copyright 2016-2020 The MathWorks, Inc.

    properties

        MinimumWidth = 20;
        MinimumHeight = 20;
        PreferredWidth;
        PreferredHeight;
        MaximumWidth = inf;
        MaximumHeight = inf;
        IPadX = 0;
        IPadY = 0;
        LeftInset = 0;
        RightInset = 0;
        TopInset = 0;
        BottomInset = 0;
        Fill = 'None';
        Anchor = 'Center';
    end

    methods

        function this = GridBagConstraints(varargin)
            %GridBagConstraints   Construct the GridBagConstraints class.
            
            for indx = 1:2:length(varargin)-1
                this.(varargin{indx}) = varargin{indx+1};
            end
        end
    end

    methods
        
        function minWidth = get.MinimumWidth(this)
            maxWidth = this.MaximumWidth;
            
            minWidth = this.MinimumWidth;
            
            if minWidth > maxWidth
                minWidth = maxWidth;
            end
        end
        
        function minHeight = get.MinimumHeight(this)
            maxHeight = this.MaximumHeight;
            
            minHeight = this.MinimumHeight;
            
            if minHeight > maxHeight
                minHeight = maxHeight;
            end
        end

        function preferredWidth = get.PreferredWidth(this)
            mw = this.MinimumWidth;
            
            preferredWidth = this.PreferredWidth;
            
            % If the preferred width hasn't been set, or it is less than the minimum
            % width, just use the minimum width.
            if isempty(preferredWidth)
                preferredWidth = mw;
            elseif preferredWidth < mw
                preferredWidth = mw;
            end
        end
        function preferredHeight = get.PreferredHeight(this)
            mh = this.MinimumHeight;
            
            preferredHeight = this.PreferredHeight;
            
            % If the preferred width hasn't been set, or it is less than the minimum
            % width, just use the minimum width.
            if isempty(preferredHeight)
                preferredHeight = mh;
            elseif preferredHeight < mh
                preferredHeight = mh;
            end
        end
        function set.Fill(this, fill)
            fills = {'None', ...
                'Horizontal', ...
                'Vertical', ...
                'Both'};
            fIndex = find(strcmpi(fill, fills));
            if length(fIndex) == 1
                this.Fill = fills{fIndex};
            else
                error(message('Wavelet:divGUIRF:gridbaginvalidfill'));
            end
        end
        function set.Anchor(this, anchor)
            
            anchors = {'Center', ...
                'Northwest', ...
                'North', ...
                'Northeast', ...
                'East', ...
                'Southeast', ...
                'South', ...
                'Southwest', ...
                'West'};
            aIndex = find(strcmpi(anchor, anchors));
            if length(aIndex) == 1
                this.Anchor = anchors{aIndex};
            else
                error(message('Wavelet:divGUIRF:gridbaginvalidanchor'));
            end
        end
    end
end

% [EOF]
