function win_Atom_BtnDown_FCN
%WIN_Atom_BtnDown_FCN ButtonDown function for WMP1DTOOL.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-May-2011.
%   Last Revision: 07-Sep-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

[lin,fig] = gcbo;
if isequal(get(lin,'Type'),'line')
    axe_CFS = gca;
    nbVect = wtbxappdata('get',fig,'MP_nbVect');
    if isempty(nbVect)
        hFig = wtbxappdata('get',fig,'caller_FIG');
    else
        hFig = fig;
    end
    Tag_View = 'WMP_View_One';
    linSIG = wfindobj(hFig,'type','line','Tag','Sig_ANAL');
    LstCPT = wtbxappdata('get',hFig,'LstCPT');
    nbFAM  = length(LstCPT);
    MP_Results = wtbxappdata('get',hFig,'MP_Results');
    [~,~,COEFF,IOPT,qual] = deal(MP_Results{:}); %#ok<NASGU>
    pAx = get(axe_CFS,'Position');
    figCurPt = get(fig,'CurrentPoint');
    xlim   = get(axe_CFS,'XLim');
    rx     = (figCurPt(1)-pAx(1))/pAx(3);
    xPoint = xlim(1)+rx*(xlim(2)-xlim(1));
    ylim   = get(axe_CFS,'YLim');
    ry     = (figCurPt(2)-pAx(2))/pAx(4);
    yPoint = ylim(1)+ry*(ylim(2)-ylim(1));
    xd = get(lin,'XData')-xPoint;
    yd = get(lin,'YData')-yPoint;
    [dx,idxX] = min(abs(xd));
    dy = min(abs(yd));
    [xpix,ypix] = wfigutil('xyprop',fig,1,1);
    tolx = 3*abs(xlim(2)-xlim(1))/(pAx(3)/xpix);
    toly = 3*abs(ylim(2)-ylim(1))/(pAx(4)/ypix);
    if (dx<tolx) && (dy<toly)
        NumFAM = round(nbFAM+1-yPoint+0.25);
        [DICO,nbVect] = wtbxappdata('get',hFig,'MP_Dictionary','MP_nbVect');
        nbval = nbVect(NumFAM);
        deltax = 1/nbval;
        xdd = get(lin,'XData');        
        NumCFS = round(xdd(idxX)/deltax);
        % idxINdico = NumCFS + sum(nbVect(1:NumFAM-1));
        % idxCFS = find(IOPT==idxINdico,1,'first');
        [~,idxCFS] = min(abs(IOPT-xdd(idxX)/deltax - sum(nbVect(1:NumFAM-1))));
        idxINdico = IOPT(idxCFS);
        
        f = wfindobj(0,'Type','figure','Tag',Tag_View);
        if isempty(f)
            f = figure('DefaultAxesFontSize',10,'Tag',Tag_View);
            uicontrol('Style','Pushbutton','Position',[20 10 80 28],...
                'String',getWavMSG('Wavelet:wfigmngr:figMenuClose'),...
                'Callback','close(gcbf)','Parent',f);
        else
            figure(f);
            oldLine = wfindobj(f,'type','Line','Color',[1 0 0]);
            set(oldLine,'Color',[0 0.9 0]);
        end
        plot(COEFF(idxCFS)*DICO(:,idxINdico),'r'); 
        axis tight;
        title(getWavMSG('Wavelet:wmp1dRF:AtomIdent',NumFAM,LstCPT{NumFAM},NumCFS))
        yd = get(linSIG,'Ydata');
        hold on; plot(yd,'b'); axis tight
    end
end
