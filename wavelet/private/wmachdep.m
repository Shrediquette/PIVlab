function varargout = wmachdep(option,varargin)
%WMACHDEP Machine dependent values.
%   VARARGOUT = WMACHDEP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Feb-1998.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

scrSize = getMonitorSize;
machine = computer;
machine = machine(1:3);
switch option   
    case 'FontSize'
        switch varargin{1}
            case 'normal'
                if     scrSize(4)<600 , siz = 16;
                elseif scrSize(4)<700 , siz = 16;
                elseif scrSize(4)<800 , siz = 20;
                else                    siz = 20;
                end
                if nargin>2
                    % in3 = font threshold or value threshold
                    % in4 = value (optional).
                    %-----------------------------------------
                    if nargin==3
                        siz = min(siz,varargin{2});
                    elseif nargin==4
                        if varargin{3}>varargin{2} , siz = siz-2; end
                    end
                end

            case 'winfo'
                switch machine
                   case {'SOL','SUN'} ,        siz = 12;
                   case {'PCW'}
                       if     scrSize(4)<500 , siz =  8;
                       elseif scrSize(4)<700 , siz =  9;
                       else                    siz = 10;
                       end
                   otherwise ,                 siz = 10;
                end
        end
        CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
        StdScrPixPerInch = 72;
        RatScrPixPerInch = StdScrPixPerInch / CurScrPixPerInch;
        varargout{1}     = max(floor(RatScrPixPerInch*siz),9);
end
