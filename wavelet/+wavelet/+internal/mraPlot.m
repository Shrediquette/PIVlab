classdef mraPlot < handle
%

%   Copyright 2020 The MathWorks, Inc.
    
    
    properties
        % Figure property
        hFig
        % Scrollable gridbag layout
        Layout
        
    end
    
    methods
        function this = mraPlot(data,mratype,td)
            
            % Base figure size on screensize in pixels
            set(0,'units','pixels');
            PixSS = get(0,'screensize');
            ht = round(PixSS(4)*0.58);
            wt = round(PixSS(3)*0.25);
            % Keep figure not visible until we are ready
            this.hFig = figure('Position',[100 100 wt ht],...
                'Tag','MRAFigure','Visible','off');
            movegui(this.hFig,'center');
            % Create scrollableGridBagLayout with figure
            this.Layout = ...
                matlabshared.application.layout.ScrollableGridBagLayout(...,
                this.hFig);
            % If real-valued data call one method
            switch mratype
                case 'RealEWT'
                   this.addPlotsRealEWT(td,data);
                case 'ComplexEWT'
                    this.addPlotsComplexEWT(td,data);
                case 'RealTQWT'
                    this.addPlotsRealTQWT(td,data);
                case 'ComplexTQWT'
                    this.addPlotsComplexTQWT(td,data);
            end
            
            % Clean layout.
            this.Layout.clean();
            
            
            
        end
    end
    
    
    
    methods(Access = private)
        
        function  addPlotsRealEWT(this,td,data)
            Nplots = size(data,2);
            ax = gobjects(Nplots,1);
            
            for ii = 1:Nplots
                ax(ii) = axes('Parent',this.hFig,'Units','Pixels');
                % Minimum height 100 pixels
                this.Layout.add(ax(ii),...
                    ii,1,'Fill','Both','MinimumHeight',100);
                plot(td,data(:,ii),'Parent',ax(ii));
                % First plot gets title.
                if ii == 1
                     ax(ii).Title.String = ...
                        getString(message('Wavelet:ewt:ewtPlotTitle'));
                    ax(ii).YLabel.String = ...
                        getString(message('Wavelet:ewt:ewtSignal'));
                    ax(ii).YLabel.FontSize = 12;
                else
                    ax(ii).YLabel.String = sprintf('MRA %d',ii-1);
                    ax(ii).YLabel.FontSize = 12;
                    
                end
                ax(ii).XLim = [td(1) td(end)];
                if ii ~= Nplots
                    ax(ii).XTick = [];
                end
            end
            % Link X-axes for zooming.
            linkaxes(ax,'x');
            set(ax,'LooseInset',[50 10 10 10]);
            set(this.hFig,'Visible','on');
            
        end
   
            
        
        
        
        function addPlotsComplexEWT(this,td,data)
            Nplots = size(data,2);
            ax = gobjects(Nplots,1);
            for ii = 1:Nplots
                ax(ii) = axes('Parent',this.hFig,'Units','Pixels');
                % Minimum height 100 pixels
                this.Layout.add(ax(ii),...
                    ii,1,'Fill','Both','MinimumHeight',100);
                plot(td,[real(data(:,ii)) imag(data(:,ii))],'Parent',ax(ii));
                 % First plot gets title.
                if ii == 1
                    ax(ii).Title.String = ...
                        getString(message('Wavelet:ewt:ewtPlotTitle'));
                    ax(ii).YLabel.String = ...
                        getString(message('Wavelet:ewt:ewtSignal'));
                    ax(ii).YLabel.FontSize = 12;
                else
                    ax(ii).YLabel.String = sprintf('MRA %d',ii-1);
                    ax(ii).YLabel.FontSize = 12;
                    
                end
                
                ax(ii).XLim = [td(1) td(end)];
                if ii ~= Nplots
                    ax(ii).XTick = [];
                end
            end
             % Link X-axes for zooming.
            linkaxes(ax,'x');
            set(ax,'LooseInset',[50 10 10 10]);
            set(this.hFig,'visible','on');
            
            
        end
        
         function addPlotsRealTQWT(this,td,data)
            data = data.';
            Nplots = size(data,2);
            ax = gobjects(Nplots,1);
            for ii = 1:Nplots
                ax(ii) = axes('Parent',this.hFig,'Units','Pixels');
                % Minimum height 100 pixels
                this.Layout.add(ax(ii),...
                    ii,1,'Fill','Both','MinimumHeight',100);
                plot(td,data(:,ii),'Parent',ax(ii));
                 % First plot gets title.
                if ii == 1
                    ax(ii).Title.String = ...
                        getString(message('Wavelet:tqwt:tqwtPlotTitle'));
                end
                
                if ii == Nplots
                    ax(ii).YLabel.String = ...
                        getString(message('Wavelet:tqwt:tqwtScaling'));
                    ax(ii).YLabel.FontSize = 9;
                else
                    sbstr = ...
                        getString(message('Wavelet:tqwt:Subband'));
                    numstr = sprintf(' %d',ii);
                    ax(ii).YLabel.String = strcat(sbstr,numstr);
                    ax(ii).YLabel.FontSize = 9;
                    
                end
                
                ax(ii).XLim = [td(1) td(end)];
                if ii ~= Nplots
                    ax(ii).XTick = [];
                end
            end
             % Link X-axes for zooming.
            linkaxes(ax,'x');
            set(ax,'LooseInset',[50 10 10 10]);
            set(this.hFig,'visible','on');
            
            
        end
        
         function addPlotsComplexTQWT(this,td,data)
            data = data.';
            Nplots = size(data,2);
            ax = gobjects(Nplots,1);
            for ii = 1:Nplots
                ax(ii) = axes('Parent',this.hFig,'Units','Pixels');
                % Minimum height 100 pixels
                this.Layout.add(ax(ii),...
                    ii,1,'Fill','Both','MinimumHeight',100);
                plot(td,[real(data(:,ii)) imag(data(:,ii))],'Parent',ax(ii));
                 % First plot gets title.
                if ii == 1
                    ax(ii).Title.String = ...
                        getString(message('Wavelet:tqwt:tqwtPlotTitle'));
                end
                
                if ii == Nplots
                    ax(ii).YLabel.String = ...
                        getString(message('Wavelet:tqwt:tqwtScaling'));
                    ax(ii).YLabel.FontSize = 12;
                else
                    ax(ii).YLabel.String = sprintf('Subband %d',ii);
                    ax(ii).YLabel.FontSize = 12;
                    
                end
                
                ax(ii).XLim = [td(1) td(end)];
                if ii ~= Nplots
                    ax(ii).XTick = [];
                end
            end
             % Link X-axes for zooming.
            linkaxes(ax,'x');
            set(ax,'LooseInset',[50 10 10 10]);
            set(this.hFig,'visible','on');
            
            
        end
    end
    
    
    
    
    
    
    
end

