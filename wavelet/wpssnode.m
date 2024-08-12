function out1 = wpssnode(option,win_wptool,in3,in4,in5,in6)
%WPSSNODE Plot wavelet packets synthesized node.
%   OUT1 = WPSSNODE(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Nov-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Image Coding Value.
%-------------------
codemat_v = wimgcode('get');

% Tag property of objects.
%-------------------------
tag_nodact    = 'Pop_NodAct';
tag_ss_node   = 'SS_Node';
tag_ss_obj    = 'SS_Obj';
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_pack  = 'Axe_Pack';

axe_handles   = findobj(get(win_wptool,'Children'),'flat','Type','axes');
WP_Axe_Tree   = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Pack   = findobj(axe_handles,'flat','Tag',tag_axe_pack);
SS_text       = findobj(WP_Axe_Tree,'Tag',tag_ss_node);
SS_Obj        = findobj(WP_Axe_Pack,'Tag',tag_ss_obj);

% Miscellaneous Values.
%-------------------------
[txt_color,pack_color,ftn_size] = ...
        wtbutils('wputils','ss_node',get(WP_Axe_Tree,'Xcolor'));

switch option 
    case 'plot'
        % in3 = type ('cs' or 'ds')
        % in4 = dim
        % in5 = handle (line or image)
        % in6 = NB_Col (useful only  for dim = 2)
        %-----------------------------------------
        if (nargin<6) || isempty(in6) , in6 = 128; end
        % axes(WP_Axe_Tree)
        if ~isempty(SS_Obj)
            delete(SS_Obj);
            hdl = get(WP_Axe_Pack,'title');
            col = get(WP_Axe_Pack,'Xcolor');
            set(hdl,'String',getWavMSG('Wavelet:wp1d2dRF:NodActRes'),'Color',col);
        end
        str_txt = ['(' in3 ')'];
        if isempty(SS_text)
            btndown_fcn  = @(~,~)wpssnode('cba', win_wptool, in4, in6);
            SS_text = text(...
                           'Clipping','on',                ...
                           'String', str_txt,              ...
                           'Position',[0.25 0.1 0],        ...
                           'Color',txt_color,              ...
                           'HorizontalAlignment','center', ...
                           'VerticalAlignment','middle',   ...
                           'FontSize',ftn_size,            ...
                           'FontWeight','bold',            ...
                           'ButtonDownFcn',btndown_fcn,    ...
                           'Parent',WP_Axe_Tree,           ...
                           'Tag',tag_ss_node               ...
                           );
        else
            set(SS_text,'String',str_txt);
        end
        if in4==1
            set(SS_text,'UserData',get(in5,'YData'));
        elseif in4==2
            set(SS_text,'UserData',get(in5,'CData'));
        end

    case 'cba'
        pop_act = findobj(win_wptool,'Tag',tag_nodact);
        v       = get(pop_act,'Value');
        switch v
            case 1 , wpssnode('vis',win_wptool,in3,in4);
            case 6 , wpssnode('stat',win_wptool,in3);
        end

    case 'vis'
        % in3 = dim
        % in4 = NB_Col (useful only  for dim = 2)
        %---------------------------------------

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,getWavMSG('Wavelet:commongui:WaitCompute'));

        dim     = in3;
        NB_Col  = in4;
        if isempty(NB_Col) , NB_Col = 128; end
        ssig_rec = get(SS_text,'UserData');
        siz      = size(ssig_rec);
        type_ss  = get(SS_text,'String');
        if strfind(type_ss,'cs')
            if dim==1 , str_txt = getWavMSG('Wavelet:commongui:CompSig');
            else        str_txt = getWavMSG('Wavelet:commongui:CompImg');
            end
        else
            if dim==1 , str_txt = getWavMSG('Wavelet:commongui:DenoSig');
            else        str_txt = getWavMSG('Wavelet:commongui:DenoImg');
            end
        end
        delete(get(WP_Axe_Pack,'Children'));
        dynvtool('ini_his',win_wptool,1)
        title_Color = mextglob('get','Def_TxtColor');
        if dim==1
            xmax = max(siz);
            if xmax==1 , xmax = 1+0.01; end
            ymin = min(ssig_rec);   ymax = max(ssig_rec);
            if ymin==ymax , ymin = ymin-0.01; ymax = ymax+0.01; end
            plot(ssig_rec,'Parent',WP_Axe_Pack,...
                 'Color',pack_color,'Tag',tag_ss_obj);
            set(WP_Axe_Pack,'XLim',[1 xmax],'YLim',...
                    [ymin ymax],'Tag',tag_axe_pack);
            wtitle(str_txt,'Parent',WP_Axe_Pack,...
                   'FontSize',ftn_size,'Color',title_Color);
        else
            im = wimgcode('cod',0,ssig_rec,NB_Col,codemat_v);
            image('CData',im,'Tag',tag_ss_obj,'Parent',WP_Axe_Pack);
            wtitle(str_txt,'Parent',WP_Axe_Pack,...
                   'FontSize',ftn_size,'Color',title_Color);

            set(WP_Axe_Pack,'Tag',tag_axe_pack,    ...
                            'Layer','top',         ...
                            'XLim',[1 size(im,2)], ...
                            'YLim',[1 size(im,1)], ...
                            'YDir','Reverse'       ...
                            );
        end
        dynvtool('put',win_wptool)
        % axes(WP_Axe_Tree);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'stat'
        dim = in3;
        type_ss = get(SS_text,'String');
        if strfind(type_ss,'cs') , node = -1; else node = -2; end
        switch dim
          case 1 , feval('wp1dstat','create',win_wptool,node);
          case 2 , feval('wp2dstat','create',win_wptool,node);
        end

    case 'r_synt'
        out1 = SS_text;

    case 'del'
        delete(SS_text);
        if ~isempty(SS_Obj)
            delete(SS_Obj);
            hdl = get(WP_Axe_Pack,'title');
            col = get(WP_Axe_Pack,'Xcolor');
            set(hdl,'String',getWavMSG('Wavelet:wp1d2dRF:NodActRes'),'Color',col);
        end
end
