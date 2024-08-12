function varargout = plotdt(dt)
%PLOTDT Plot dual-tree or double density dual-tree.
%	PLOTDT(DT) plots the coefficients of the dual-tree or the 
%   double density dual-tree DT built using DDDTREE or DDDTREE2.
%
%   See also DDDTREE, DDDTREE2.

%   Copyright 2013-2020 The MathWorks, Inc.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Jan-2013
%   Last Revision: 11-Mar-2013.

% Check inputs
narginchk(1,1);
if ischar(dt) % In 2D: Callback associated to the popup
    [object,fig] = gcbo;
    if isempty(object) , return; end
    val = get(object,'Value');
    pan = wfindobj(fig,'type','uipanel');
    usr = get(pan,'Userdata');
    usr = cat(1,usr{:});
    idx = find(usr==val);
    set(pan(setdiff(1:length(usr),idx)),'Visible','Off');
    set(pan(idx),'Visible','On');
    return
end

dim = length(fieldnames(dt))-3;
typeTree = dt.type;
Depth = dt.level;
Dp1 = Depth+1;

switch dim
    case 1
        fig = figure('Units','normalized','Position',[0.1 0.1 0.4 0.7], ...
            'Name',upper(typeTree),'Color','w','DefaultAxesFontSize',9);
        idxPlot = 0;
        SZ = size(dt.cfs{1});
        nbCOL = length(SZ)-1;
        for L = 1:Dp1
            C = dt.cfs{L};
            S = size(C);
            nbPlot = length(S)-1;
            for k = 1:nbPlot
                idxPlot = idxPlot+1;
                subplot(Dp1,nbCOL,idxPlot)
                plot(C(:,:,k),'.-r'); axis tight; grid
                if L<Dp1
                    xlab = getWavMSG('Wavelet:dualtree:Level_Dec',L);
                else
                    xlab = getWavMSG('Wavelet:dualtree:Level_Dec_LOW',L-1);
                end
                if nbPlot>1 , xlab = [xlab ' - ' int2str(k)]; end
                xlabel(xlab);
            end
        end
        subplot(Dp1,nbCOL,1)
        tSTR = getWavMSG('Wavelet:dualtree:Type_of_Tree',upper(typeTree));
        title(tSTR,'FontSize',11,'FontWeight','bold')
        
    case 2
        switch typeTree
            case 'dwt' ,     W = 0.15;  H = 0.33;
            case 'realdt' ,  W = 0.26;  H = 0.4;
            case 'cplxdt',   W = 0.3;   H = 0.4;
            case 'realdddt', W = 0.21;  H = 0.56;
            case 'cplxdddt', W = 0.28;  H = 0.56;
            case 'ddt' ,     W = 0.12;  H = 0.6;
        end
        Y = 1-H-0.05;
        X = 0.05;
        axis_Val = 'normal';
        nameSTR = getWavMSG('Wavelet:dualtree:Title_plotDT_2D',...
            upper(typeTree),Depth);        
        fig = figure('Units','normalized','Position',[0.1 0.1 0.6 0.8], ...
            'Menubar','none','Name',nameSTR,'Color','w', ...
            'Colormap',bone(245));
        strPOP = [repmat([getWavMSG('Wavelet:dualtree:Level_STR') ' '],Depth,1) ...
            int2str((1:Depth)')];
        strPOP = char(strPOP,getWavMSG('Wavelet:dualtree:Level_Dec_LOW',Depth));
        pop = uicontrol('Style','PopupMenu','String',strPOP,...
            'Position',[10 8 140,20],'Parent',fig,'Tag','Pop_LEVEL',...
            'Callback',@(~,~)plotdt('pop') );
        
        for L = 1:Depth
            panSTR = getWavMSG('Wavelet:dualtree:Cfs_Of_LEV',L);
            uiPan(L) = uipanel('Parent',fig, ...
                'Units','normalized','Position',[0.05 0.05 0.9 0.9], ...
                'Title',panSTR,'BackgroundColor','w', ...
                'Userdata',L,'Visible','Off');
            C = dt.cfs{L};
            S = size(C);
            if length(S)<4 , S(4) = 1; end
            if length(S)<5 , S(5) = 1; end
            nbCOL = S(4)*S(5);
            nbROW = S(3);
            if nbCOL==1 , nbCOL = nbROW; nbROW = 1; end
            idxPlot = 0;
            for d = 1:S(3)
                for m = 1:S(5)
                    for k = 1:S(4)
                        idxPlot = idxPlot+1;
                        ax = subplot(nbROW,nbCOL,idxPlot,'Parent',uiPan(L));
                        imagesc(C(:,:,d,k,m),'Parent',ax)
                        axis(ax,axis_Val)
                        if S(4)==1
                            if S(5)== 1
                                TITSTR = ['C_{' int2str(d) '}'];
                            else
                                TITSTR = ['C_{' int2str(d) int2str(m) '}'];  
                            end
                        else
                            if S(5)== 1
                                TITSTR = ['C_{' int2str(d) int2str(k) '}'];
                            else
                                TITSTR = ['C_{' int2str(d) int2str(k) int2str(m) '}'];
                            end
                        end
                        title(TITSTR,'Parent',ax);
                    end
                end
            end
%             ax = wfindobj(uiPan(L),'type','axes');
%             pos = get(ax,'Position');
%             if iscell(pos) , pos = cat(1,pos{:}); end
%             minPos = min(pos);
%             for k = 1:length(ax)
%                 pos(k,1:2) = pos(k,1:2)-minPos(1:2)/2;
%                 set(ax(k),'Position',pos(k,:));
%             end
        end
        panSTR = getWavMSG('Wavelet:dualtree:Cfs_Of_LOWPASS',Depth);
        uiPan(Dp1) = uipanel('Parent',fig, ...
            'Units','normalized','Position',[0.05 0.05 0.9 0.9], ...
            'Title',panSTR,'BackgroundColor','w', ...
            'Userdata',Dp1,'Visible','On');
        C = dt.cfs{end};
        S = size(C);
        idxPlot = 0;
        if length(S)<3 , S(3) = 1; end
        if length(S)<4 , S(4) = 1; end
        for m = 1:S(4)
            for k = 1:S(3)
                idxPlot = idxPlot+1;
                ax = subplot(S(4),S(3),idxPlot,'Parent',uiPan(L+1));
                imagesc(C(:,:,k,m),'Parent',ax)
                axis(ax,axis_Val)
                TITSTR = 'C_{';
                if S(3)>1 , TITSTR = [TITSTR int2str(k)]; end %#ok<*AGROW>
                if S(4)>1 , TITSTR = [TITSTR int2str(m)]; end
                TITSTR = [TITSTR '}'];
                title(TITSTR,'Parent',ax)
            end
        end
%         ax = wfindobj(uiPan(Dp1),'type','axes');
%         nbAx = length(ax);
%         pos = get(ax,'Position');
%         if iscell(pos) , pos = cat(1,pos{:}); end
%         if nbAx>1
%             minPos = min(pos);
%             for k = 1:nbAx
%                 pos(k,1:2) = pos(k,1:2)-minPos(1:2)/2;
%                 set(ax(k),'Position',pos(k,:));
%             end
%         end
        
        a = wfindobj(uiPan,'type','axes');
        set(a,'Xtick',[],'Ytick',[],'Box','On')
        set(pop,'Value',Dp1);        
end
if nargout>0 , varargout{1} = fig; end
