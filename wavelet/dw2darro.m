function dw2darro(option,win_dw2dtool,in3,in4)
%DW2DARRO Discrete wavelet 2-D arrows.
%   DW2DARRO(OPTION,WIN_DW2DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

% Tag property of objects.
%-------------------------
tag_axearrow  = 'Axe_Arrow';
tag_axeimgini = 'Axe_ImgIni';
tag_axeimgvis = 'Axe_ImgVis';
tag_axeimgsel = 'Axe_ImgSel';
% tag_axeimgdec = 'Axe_ImgDec';
tag_axeimgsyn = 'Axe_ImgSyn';
tag_arrow     = 'Wave_Arrow';

axe_handles = findobj(get(win_dw2dtool,'Children'),'flat','Type','axes');
arrow_hdls  = findobj(axe_handles,'Tag',tag_arrow);

if isequal(option,'ini_arrow') || isequal(option,'set_arrow')
    dw2d_PREFS = wtbutils('dw2d_PREFS');
    Col_BoxTitleSel = dw2d_PREFS.Col_BoxTitleSel;
    Col_ArrowFrm    = dw2d_PREFS.Col_ArrowFrm;
    Col_ArrowTxt    = dw2d_PREFS.Col_ArrowTxt;
end

switch option
    case 'ini_arrow'
        fontsize = wmachdep('FontSize','normal',20);
        axe_arrow = axes(...
            'Parent',win_dw2dtool,    ...
            'Position',[0 0 1 1],     ...
            'XLim',[0 1],'YLim',[0 1],...
            'NextPlot','Add',         ...
            'Visible','off',          ...
            'Tag',tag_axearrow        ...
            );
        ar0 = wavarrow('ini',axe_arrow,2,Col_ArrowFrm);
        set(ar0,'UserData','a0');
        ar1 = wavarrow('ini',axe_arrow,2,Col_ArrowFrm);
        set(ar1,'UserData','a1');
        commonProp = {...
            'Parent',axe_arrow,             ...
            'Units','normalized',           ...
            'Visible','off',                ...
            'HorizontalAlignment','center', ...
            'FontSize',fontsize,            ...
            'FontWeight','bold',            ...
            'Color',Col_ArrowTxt,           ...
            'Tag',tag_arrow                 ...
            };
        locProp = [commonProp {'String','dwt','UserData','t0'}];
        text(locProp{:});
        ar2 = wavarrow('ini',axe_arrow,2,Col_BoxTitleSel);
        set(ar2,'UserData','a2');
        ar3 = wavarrow('ini',axe_arrow,2,Col_ArrowFrm);
        set(ar3,'UserData','a3');
        locProp = [commonProp {'String','idwt','UserData','t31'}];
        text(locProp{:});
        locProp = [commonProp {'String','','UserData','t32'}];
        text(locProp{:});

    case 'vis_arrow'
        % in3 = 'on' or 'off'
        % in4 optional (return_deno or return_comp)
        %------------------------------------------             
        txt = get(findobj(arrow_hdls,'UserData','t0'),'String');
        if strcmp(txt,'dwt')
            ar = findobj(arrow_hdls,'UserData','a1');
        else
            ar = findobj(arrow_hdls,'UserData','a0');
        end
        arrow_hdls = arrow_hdls(arrow_hdls~=ar);
        if nargin==4
            txt = findobj(arrow_hdls,'UserData','t32');
            set(txt,'String',in4);
        end             
        set(arrow_hdls,'Visible',in3);

    case 'clean'
        % in3 = 'on' or 'off'
        %--------------------          
        txt = get(findobj(arrow_hdls,'UserData','t0'),'String');
        if strcmp(txt,'dwt')
            ar = findobj(arrow_hdls,'UserData','a1');
        else
            ar = findobj(arrow_hdls,'UserData','a0');
        end
        arrow_hdls = arrow_hdls(arrow_hdls~=ar);
        txt = findobj(arrow_hdls,'UserData','t32');
        set(txt,'String','');
        set(arrow_hdls,'Visible',in3);

    case 'set_arrow'
        % in3 calling option
        %-------------------
        Axe_ImgIni = findobj(axe_handles,'flat','Tag',tag_axeimgini);
        Axe_ImgSel = findobj(axe_handles,'flat','Tag',tag_axeimgsel);
        Axe_ImgVis = findobj(axe_handles,'flat','Tag',tag_axeimgvis);
        Axe_ImgSyn = findobj(axe_handles,'flat','Tag',tag_axeimgsyn);
        ar0 = findobj(arrow_hdls,'UserData','a0');
        ar1 = findobj(arrow_hdls,'UserData','a1');
        ar2 = findobj(arrow_hdls,'UserData','a2');
        ar3 = findobj(arrow_hdls,'UserData','a3');
        t0  = findobj(arrow_hdls,'UserData','t0');
        t31 = findobj(arrow_hdls,'UserData','t31');
        t32 = findobj(arrow_hdls,'UserData','t32');

        pini = get(Axe_ImgIni,'Position');
        psel = get(Axe_ImgSel,'Position');
        pvis = get(Axe_ImgVis,'Position');
        psyn = get(Axe_ImgSyn,'Position');
        [bdx,bdy] = wfigutil('prop_size',win_dw2dtool,15,15);
        mul = 1/6;
        xini = pini(1)+pini(3);
        yini = pini(2);
        xsel = psel(1)-bdx;
        ysel = psel(2)+psel(4)+bdy;
        dx = xsel-xini;
        dy = yini-ysel;
        pt1 = [xini+mul*dx yini-mul*dy];
        pt2 = [xsel-mul*dx ysel+mul*dy];
        wavarrow('set',ar0,pt1,pt2,0.6,2,Col_ArrowFrm,'off');
        wavarrow('set',ar1,pt2,pt1,0.6,2,Col_ArrowFrm,'off');
        if strcmp(in3,'load_cfs')
            ar00 = ar1;
            txt = 'idwt';
        else
            ar00 = ar0;
            txt = 'dwt';
        end 
        set(t0,'Position',[xini+dx/2 yini-dy/2],'String',txt);

        xvis = pvis(1)+pvis(3)/2;
        yvis = pvis(2);
        ysel = psel(2)+psel(4)+bdy+bdy/2;
        dy   = yvis-ysel;
        wavarrow('set',ar2,[xvis ysel+mul*dy],[xvis yvis-mul*dy], ...
                                0.6,2,Col_BoxTitleSel,'off');

        xsyn = psyn(1)+psyn(3);
        ysyn = psyn(2)+psyn(4)/2;
        dx   = xsel-xsyn;
        wavarrow('set',ar3,[xsel-mul*dx ysyn],[xsyn+mul*dx ysyn], ...
                                0.6,2,Col_ArrowFrm,'off');
        set(t31,'Position',[xsel-dx/2 ysyn+0.025],'String','idwt');
        set(t32,'Position',[xsel-dx/2 ysyn-0.02],'String','');
        set([ar00 ar2 ar3 t0 t31],'Visible','on');

    case 'del_arrow'
        delete(arrow_hdls)

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%=================================================================%
function out1 = wavarrow(option,in2,in3,in4,in5,in6,in7,in8)
%WAVARROW Draw arrows and texts for dw2dtool.
%   out1 = wavarrow(option,in2,in3,in4,in5,in6,in7,in8)

tag_arrow = 'Wave_Arrow';
opt     = option(1:3);

switch opt
    case 'ini'
      axe     = in2;
      width   = in3;
      color   = in4;
      out1 = line(...
              'Parent',axe,...
              'XData',[0 0],'YData',[1 1],...
              'LineWidth',width,'Color',color,...
              'Visible','off','Tag',tag_arrow);

    case 'set'
      arrow   = in2;
      start   = in3;
      stop    = in4;
      scale   = in5;
      width   = in6;
      color   = in7;
      if nargin < 8 
          vis = 'on'; 
      else
          vis = in8;
      end
      %g1718249
      if all(stop == start) || any(~isfinite([start, stop]))
          return; 
      end
      xdif = stop(1) - start(1);
      ydif = stop(2) - start(2);
      if      xdif~=0 
          theta = atan(ydif/xdif);
      elseif  ydif>0  
          theta = pi/2;
      elseif  ydif<0  
          theta = -pi/2;
      end
      if(xdif>=0) , scale = -scale; end
      xx = [  start(1), stop(1),                                      ...
              (stop(1)+0.02*scale*cos(theta+pi/6)),NaN,stop(1),       ...
              (stop(1)+0.02*scale*cos(theta-pi/6))]';
      yy = [  start(2), stop(2),                                      ...
              (stop(2)+0.02*scale*sin(theta+pi/6)),NaN,stop(2),       ...
              (stop(2)+0.02*scale*sin(theta-pi/6))]';
      set(arrow,'XData',xx,'YData',yy,'LineWidth',width,'Color',color,...
                              'Visible',vis,'Tag',tag_arrow);

    
    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
%=================================================================%
