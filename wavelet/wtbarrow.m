function HDL = wtbarrow(option,varargin)
%WTBARROW Create Arrows.
%
%  example:
%       hdl = wtbarrow('create');
%       set(gca,'XLim',[0,1],'YLim',[0,1]);
%       pause
%       hdl = wtbarrow('create','Rotation',pi/2,'Scale',[0.5 0.5],'Color','b');
%       set(gca,'XLim',[-2,2],'YLim',[-2,2]);
%       pause
%       hdl = wtbarrow('create','Translate',[1,0],'Rotation',pi/4,'Scale',[0.5 0.5],'Color','y');

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Feb-2003.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<1 , option = 'create'; end

% Defaults.
%------------
sca = ones(1,2);        
rot = 0;
tra = zeros(1,2);  

nbarg  = length(varargin);
switch option
    case {'create','createBIS','createTER'}
        % ------------------------------------------
        % Arrow construction.
        % ------------------------------------------
        %          x             H = HArrow
        %     <------------> <------->
        %                    =             ^
        %                    ===           |  W = WArrow
        %                    ====          v
        %     ====================      ^
        %     ======================    |
        %     ========================  |  2*E
        %     ======================    |
        %     ====================      v
        %                    ====
        %                    ===
        %                    =
        % ALFA is the angle of the arrow head
        % or W = WArrow.
        % Z = E + W;
        % ------------------------------------------
        
        % defaults.
        %----------
        axe = gca;
        vis = 'On';
        col = [1 0 0]; 
       %-------------
        alf = pi/4;
        W   = NaN;
        xP1 = 3/4;
        H   = 1/4;
        E   = 1/8;
        %-----------
        xP2 = 2*xP1;
        %------------          
        for k = 1:2:nbarg
            argType = varargin{k};
            argVal  = varargin{k+1};
            argType = lower(argType(1:3));
            switch argType
                case 'axe' , axe = argVal;
                case 'vis' , vis = argVal;
                case 'col' , col = argVal; 
                %------------------------
                case 'alf' , alf = argVal;
                case 'xp1' , xP1 = argVal;
                case 'xp2' , xP2 = argVal;    
                case 'har' , H   = argVal;
                case 'war' , W   = argVal;                    
                case 'wid' , E   = argVal;
                case 'hy1'  ,HY1 = argVal;
                %------------------------       
                case 'sca' , sca = argVal;        
                case 'rot' , rot = argVal;
                case 'tra' , tra = argVal;
            end
        end
        if isnan(W)
            Z =  tan(alf)*H;
            W = max(Z-E,0);
        end
        Z  = E + W;
        switch option
            case 'create'
                ArrowData = [...
                  0  xP1  xP1 xP1+H xP1 xP1 0  0; ...
                 -E  -E   -Z     0   Z   E  E -E ...
                    ];
            case 'createBIS'
                V  = HY1-H;
                y1 = -(E+HY1);
                y2 = y1+V;
                Xd = [0 2*E  2*E  xP1-E  xP1-E  xP1+E  xP1+E  xP2-E  xP2-E  xP2-Z  xP2   xP2+E+W  xP2+E  xP2+E  0   0];
                Yd = [y1 y1  -E    -E     y1      y1     -E    -E     y2      y2    y1      y2      y1+V   E    E  y1];
                ArrowData = [Xd ; Yd];
                
            case 'createTER'
                V  = HY1-H;
                y1 = -(E+HY1);
                y2 = y1+V;
                Xd = [0 2*E  2*E  xP1-E  xP1-E  xP1+E  xP1+E  xP2-E  xP2-E  xP2-Z  xP2   xP2+E+W  xP2+E  xP2+E  0   0];
                Yd = [y1 y1  -E    -E     y1      y1     -E    -E     y2      y2    y1      y2      y1+V   E    E  y1];
                N = 10;
                xx = linspace(2*E,xP1-E,N);
                t  = linspace(0,1,10);
                yy = y1 +  HY1*4*t.*(1-t);
                Xd = [Xd(1:2) xx Xd(5:end)];
                Yd = [Yd(1:2) yy Yd(5:end)];
                ArrowData = [Xd ; Yd];
              
        end
        %-------------------------------------------
        if ~(isequal(sca,ones(2,1)) || isequal(sca,ones(1,2)))
            MSca = [sca(1) 0 ; 0 sca(2)];
            ArrowData = MSca*ArrowData;
        end
        if ~isequal(rot,0)
            MRot = [cos(rot) sin(rot) ; -sin(rot) cos(rot)];
            ArrowData = MRot*ArrowData;
        end
        if ~(isequal(tra,zeros(2,1)) || isequal(tra,zeros(1,2)))
            VTra = [tra(1) ; tra(2)]; 
            ArrowData = ArrowData + VTra(:,ones(1,size(ArrowData,2)));
        end
        HDL = patch( ...
            'Parent',axe,...
            'XData',ArrowData(1,:),'YData',ArrowData(2,:),...
            'FaceColor',col,'Visible',vis);

    case {'special_1'}       
        % defaults.
        %----------
        axe = gca;
        vis = 'On';
        col = [1 0 0]; 
        %-------------
        alf = pi/4;
        W   = NaN;
        H   = 1/4;
        E   = 1/8;
        %-----------
        Xd = [1 2 3];
        Yd = [1 2 3];
        %------------          
        for k = 1:2:nbarg
            argType = varargin{k};
            argVal  = varargin{k+1};
            Large = min([3,length(argType)]);
            argType = lower(argType(1:Large));
            switch argType
                case 'axe' , axe = argVal;
                case 'vis' , vis = argVal;
                case 'col' , col = argVal; 
                %------------------------
                case 'xva' , Xd  = argVal;
                case 'yva' , Yd  = argVal;    
                case 'alf' , alf = argVal;
                case 'har' , H   = argVal;
                case 'war' , W   = argVal;                    
                case 'wid' , E   = argVal;
                %------------------------       
                case 'sca' , sca = argVal;        
                case 'rot' , rot = argVal;
                case 'tra' , tra = argVal;
            end
        end
        if isnan(W)
            Z =  tan(alf)*H;
            W = max(Z-E,0);
        end
        Ex = E;
        Ey = E;
        x1 = Xd(1); x2 = Xd(2); x3 = Xd(3);
        y1 = Yd(1); y2 = Yd(2); y3 = Yd(3);
        XY = zeros(2,20);
        XY(:,1)  = [x1-Ex ; y1];  
        XY(:,2)  = [x1+Ex ; y1]; 
        XY(:,3)  = [x1+Ex ; y2];  
        XY(:,4)  = [x2-Ex ; y2]; 
        XY(:,5)  = [x2-Ex ; y1];  
        XY(:,6)  = [x2+Ex ; y1]; 
        XY(:,7)  = [x2+Ex ; y2+2*Ey];
        XY(:,8)  = [(x1+x2)/2 + Ex ; y2+2*Ey]; 
        XY(:,9)  = [(x1+x2)/2 + Ex ; y3];
        XY(:,10) = [x3-Ex ; y3]; 
        XY(:,11) = [x3-Ex ; y1+H];
        XY(:,12) = [x3-Ex-W ; y1+H];
        XY(:,13) = [x3 ; y1];
        XY(:,14) = [x3+Ex+W ; y1+H];
        XY(:,15) = [x3+Ex ; y1+H];
        XY(:,16) = [x3+Ex ; y3+2*Ey];
        XY(:,17) = [(x1+x2)/2 - Ex ; y3+2*Ey];
        XY(:,18) = [(x1+x2)/2 - Ex ; y2+2*Ey];
        XY(:,19) = [x1-Ex ; y2+2*Ey];
        XY(:,20) = XY(:,1);
        %-------------------------------------------
        if ~(isequal(sca,ones(2,1)) || isequal(sca,ones(1,2)))
            MSca = [sca(1) 0 ; 0 sca(2)];
            XY = MSca*XY;
        end
        if ~isequal(rot,0)
            MRot = [cos(rot) sin(rot) ; -sin(rot) cos(rot)];
            XY = MRot*XY;
        end
        if ~(isequal(tra,zeros(2,1)) || isequal(tra,zeros(1,2)))
            VTra = [tra(1) ; tra(2)]; 
            XY = XY + VTra(:,ones(1,size(XY,2)));
        end
        HDL = patch( ...
            'Parent',axe,...
            'XData',XY(1,:),'YData',XY(2,:),...
            'FaceColor',col,'Visible',vis);
        
        
    case 'set'
        HDL = varargin{1};
        ArrowData = [get(HDL,'XData')' ; get(HDL,'YData')'];
        vis = get(HDL,'Visible');
        col = get(HDL,'FaceColor');
        for k = 2:2:nbarg
            argType = varargin{k};
            argVal  = varargin{k+1};
            argType = lower(argType(1:3));
            switch argType
                case 'vis' , vis = argVal;
                case 'col' , col = argVal; 
                case 'sca' , sca = argVal;        
                case 'rot' , rot = argVal;
                case 'tra' , tra = argVal;
            end
        end
        if ~(isequal(sca,ones(2,1)) || isequal(sca,ones(1,2)))
            MSca = [sca(1) 0 ; 0 sca(2)];
            ArrowData = MSca*ArrowData;
        end
        if ~isequal(rot,0)
            MRot = [cos(rot) sin(rot) ; -sin(rot) cos(rot)];
            ArrowData = MRot*ArrowData;
        end
        if ~(isequal(tra,zeros(2,1)) || isequal(tra,zeros(1,2)))
            VTra = [tra(1) ; tra(2)]; 
            ArrowData = ArrowData + VTra(:,ones(1,size(ArrowData,2)));
        end
        set(HDL, ...
            'XData',ArrowData(1,:),'YData',ArrowData(2,:), ...
            'FaceColor',col,'Visible',vis);
end

