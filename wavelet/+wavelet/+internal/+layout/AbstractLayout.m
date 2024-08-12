classdef AbstractLayout < handle
    %AbstractLayout   Define the AbstractLayout class.

%   Copyright 2016-2020 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Panel;
    end
    
    properties (Access = protected)
        Invalid = true;
        OldPosition;
    end

    properties (Access = protected, Constant)
        CONSTRAINTSTAG = 'Layout_Manager_Constraints';
    end

    properties (Access = protected, Dependent)
        
        PanelPosition;
    end
    
    properties
        PreLayoutCallback;
        PostLayoutCallback;
    end
    
    methods
        
        function this = AbstractLayout(hPanel)
            %AbstractLayout   Construct the AbstractLayout class.
            
            this.Panel = hPanel;
        end
        
        function add(this, h, varargin)
            %ADD   Add the component to the layout manager.
                        
            % Make sure there isn't already a component in the location.
            hOld = getComponent(this, varargin{:});
            if ~isempty(hOld)
                error(message('Wavelet:divGUIRF:gridbagcomponentexists'));
            end
            
            set(h, 'Parent', this.Panel);
        end
        
        function update(this, force)
            %UPDATE   Update the layout.
            
            if nargin < 2
                force = 'noforce';
            end
            
            % When UPDATE is called, we assume the layout is dirty.
            if this.Invalid || strcmpi(force, 'force')
                
                % Nothing to do if the panel is invisible, to avoid multiple updates.
                if strcmpi(get(this.Panel, 'Visible'), 'Off')
                    return;
                end
                
                preCallback = this.PreLayoutCallback;
                if ~isempty(preCallback)
                    try
                        hgfeval(preCallback, this.Panel, []);
                    catch ME
                        
                        % Rethrow the error as a warning.
                        
                    end
                end
                
                layout(this);
                
                postCallback = this.PostLayoutCallback;
                if ~isempty(postCallback)
                    try
                        hgfeval(postCallback, this.Panel, []);
                    catch ME
                        
                    end
                end
                
                % The layout is now clean.
                this.Invalid = false;
            end
        end
        function onVisibleChanged(this, ~, ~)
            if strcmp(this.Panel.Visible, 'on')
                update(this);
            end
        end
    end
    
    methods (Abstract, Access = protected)
        getComponent(this);
        layout(this);
    end
    
    methods
        
        function set.Panel(this, panel)
            
            % This is faster than STRCMPI
            % This should not evaluate to true
            if ~ishghandle(panel) && ...
                    any(strcmp(get(panel, 'type'), {'uipanel', 'figure', 'uicontainer'}))
                error(message('Wavelet:divGUIRF:gridbagpanelproperty'));
            end
            
            % Do this before we create the listeners to avoid accidental firing.
            pos = getpixelposition(panel);
            this.OldPosition = pos(3:4);
            addlistener(panel, 'Visible', 'PostSet', @this.onVisibleChanged);
            set(panel, 'ResizeFcn', @(hsrc, ev) onResize(this));
            
            this.Panel = panel;
            
            function onResize(this)
                
                newPos = this.PanelPosition;
                newPos(1:2) = [];
                
                % Only resize if the panel position (width and height) actually changed.
                if ~all(this.OldPosition == newPos)
                    this.OldPosition = newPos;
                    this.Invalid = true;
                    update(this);
                end
            end
        end
        
        function panelPosition = get.PanelPosition(this)
            hp = this.Panel;
            
            oldResizeFcn = get(hp, 'ResizeFcn');
            set(hp, 'ResizeFcn', '');
            
            panelPosition = getpixelposition(hp);
            
            if ishghandle(hp, 'uipanel')
                % We need to remove the extra spaces taken up by the border
                % which we cannot use.
                panelPosition(3:4) = panelPosition(3:4)-2*get(hp, 'BorderWidth');
            end
            
            set(hp, 'ResizeFcn', oldResizeFcn);
            
        end
    end
    
end

% [EOF]
