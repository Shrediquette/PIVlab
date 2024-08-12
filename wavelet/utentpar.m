function varargout = utentpar(option,fig,varargin)
%UTENTPAR Utilities for wavelet packets entropy.
%   VARARGOUT = UTENTPAR(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-May-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.9.4.11 $

% Tag property of objects.
%-------------------------
tag_ent_par = 'Fra_EntPar';

switch option
    case 'create'

        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
         Y_Spacing,Def_FraBkColor,Def_EdiBkColor,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Y_Spacing','Def_FraBkColor','Def_EdiBkColor', ...
                'Def_ShadowColor');

        % Positions utilities.
        %---------------------
        bdx = 3;
        dy = Y_Spacing; bdy = 4;        
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        deltaY = (Def_Btn_Height+dy);

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;
        enaVAL  = 'on';
        ent_Nam = 'default';
        ent_Par = 0;

        % Parsing Inputs.
        %----------------        
        nbarg = nargin-2;
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'    , xleft   = varargin{k+1};
              case 'right'   , xright  = varargin{k+1};
              case 'xloc'    , xloc    = varargin{k+1};
              case 'bottom'  , ybottom = varargin{k+1};
              case 'top'     , ytop    = varargin{k+1};
              case 'yloc'    , yloc    = varargin{k+1};
              case 'bkcolor' , bkColor = varargin{k+1};              
              case 'enable'  , enaVAL  = varargin{k+1};
              case 'nam' ,     ent_Nam = lower(deblankl(varargin{k+1}));
              case 'par' ,     ent_Par = varargin{k+1};
              case 'ent'
                ent_Nam = lower(deblankl(varargin{k+1}{1}));
                ent_Par = varargin{k+1}{2};
            end 
        end

        old_units  = get(fig,'Units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end       

        % Setting frame position.
        %------------------------
        w_fra   = mextglob('get','Fra_Width');
        h_fra   = Def_Btn_Height+2*bdy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fr1 = [xleft,ybottom,w_fra,h_fra];
        pos_fr2 = [xleft,ybottom-deltaY,w_fra,h_fra+deltaY];
 
        % Position property of objects.
        %------------------------------
        wBASE = 1.2*Def_Btn_Width;
        while (2.5*wBASE>w_fra) , wBASE = wBASE-0.01; end
        xleft = xleft+bdx;
        ylow  = ybottom+h_fra-Def_Btn_Height-bdy+1;
        pos_txt_ent = [xleft, ylow+d_txt/2, wBASE, Def_Txt_Height];
        xl          = pos_txt_ent(1)+pos_txt_ent(3);
        pos_pop_ent = [xl, ylow, 1.2*wBASE, Def_Btn_Height];
        ylow        = ylow-deltaY;

        pos_txt_par    = pos_txt_ent;
        pos_txt_par(2) = ylow+d_txt/2;
        xl             = pos_txt_par(1)+pos_txt_par(3);
        pos_uic_ent    = [xl, ylow, wBASE, Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_txt_ent = getWavMSG('Wavelet:wp1d2dRF:Str_Entropy');
        str_pop_ent = wtranslate('lstentropy');
        str_txt_par = getWavMSG('Wavelet:wp1d2dRF:Str_EntPar');
        str_uic_ent = '';

        % Create objects.
        %----------------
        comFigProp = {'Parent',fig,'Units',fig_units};
        fra_ent = uicontrol(...
                            comFigProp{:}, ...
                            'Style','frame', ...
                            'Position',pos_fr1, ...
                            'BackgroundColor',bkColor, ...
                            'ForeGroundColor',Def_ShadowColor,...
                            'Tag',tag_ent_par ...
                            );

        txt_ent = uicontrol(...
                            comFigProp{:},                  ...
                            'Style','text',                 ...
                            'HorizontalAlignment','left',   ...
                            'Position',pos_txt_ent,         ...
                            'String',str_txt_ent,           ...
                            'BackgroundColor',Def_FraBkColor...
                            );

        pop_ent = uicontrol(...
                            comFigProp{:},          ...
                            'Style','Popup',        ...
                            'Position',pos_pop_ent, ...
                            'String',str_pop_ent,   ...
                            'Enable',enaVAL         ...
                            );

        txt_par = uicontrol(...
                            comFigProp{:}, ...
                            'Style','text',                 ...
                            'Visible','on',                ...
                            'HorizontalAlignment','left',   ...
                            'Position',pos_txt_par,         ...
                            'String',str_txt_par,           ...
                            'BackgroundColor',Def_FraBkColor...
                            );

        uic_ent = uicontrol(...
                            comFigProp{:},          ...
                            'Style','edit',         ...
                            'Position',pos_uic_ent, ...
                            'Visible','on',        ...
                            'HorizontalAlignment','center', ...
                            'String',str_uic_ent,   ...
                            'Enable',enaVAL,        ...
                            'BackgroundColor',Def_EdiBkColor...
                            );

        % Store data.
        %------------
        pos_fig = get(fig,'Position');
        nor_rat = [pos_fig(3) pos_fig(4) pos_fig(3) pos_fig(4)];
        pos_fr1_Norm = pos_fr1./nor_rat;
        pos_fr2_Norm = pos_fr2./nor_rat;
        ud.handles   = [fra_ent,txt_ent,pop_ent,txt_par,uic_ent];
        ud.positions = [pos_fr1 ; pos_fr2 ; pos_fr1_Norm ; pos_fr2_Norm];
        set(fra_ent,'UserData',ud);
        if ~isequal(old_units,fig_units)
            set([fig;ud.handles],'Units',old_units);
        end       

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelp('add_ContextMenu',fig,ud.handles,'WP_ENTROPY');
		%-------------------------------------

        % Callbacks update.
        %------------------
        cba_pop_ent = @(~,~)utentpar('set', fig);
        set(pop_ent,'Callback',cba_pop_ent);
 
        % Initialize entropy.
        %-------------------
        set([txt_par,uic_ent],'Visible','Off')
        if ~isequal(ent_Nam,'default')
            utentpar('set',fig,'ent',{ent_Nam,ent_Par});
        end
        if nargout>0
            varargout = {get(fra_ent,'Position') , [pos_fr1_Norm ; pos_fr2_Norm]};
        end

    case 'create_copy'
        createArg = varargin{1};
        [varargout{1},varargout{2}] = utentpar('create',fig,createArg{:});
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        ediInActBkColor = mextglob('get','Def_Edi_InActBkColor');
        prop = get(pop_ent,{'Value','String'});
        newProp = {'Style','Edit','BackgroundColor',ediInActBkColor, ...
            'Enable','Inactive','String',prop{2}(prop{1},:)};
        set(pop_ent,newProp{:});
        set(uic_ent,'Enable','inactive','BackgroundColor',ediInActBkColor);

    case 'handles'
        fra = findobj(get(fig,'Children'),'flat','Style','frame',...
                      'Tag',tag_ent_par);
        ud = get(fra,'UserData');
        varargout = num2cell(ud.handles);

        % One more input to get "active" handles.
        if ~isempty(varargin) , varargout = varargout([3 5]); end

    case {'toolPosition','position'}
        fra = findobj(fig,'Style','frame','Tag',tag_ent_par);
        varargout = get(fra,{'Position','Units'});

    case 'set'
        nbarg = length(varargin);
        [fra_ent,~,pop_ent,txt_par,uic_ent] = utentpar('handles',fig);
        if nbarg==0
           val = get(pop_ent,'Value'); 
           lst = wtranslate('ORI_lstentropy');
           ent_Nam = lower(deblankl(lst{val}));
           ent_Par = '';
        end
        for k = 1:2:nbarg
           argType = varargin{k};
           argVal  = varargin{k+1};
           switch argType
             case 'nam' , ent_Nam = lower(deblankl(argVal));
             case 'par' , ent_Par = argVal;
             case 'ent'
               ent_Nam = lower(deblankl(argVal{1}));
               ent_Par = argVal{2};
           end
        end
        num = getNum(ent_Nam);
        switch num
            case {1,4} % {'shannon','logenergy'}
              vis     = 'off';
              str_txt = getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_PAR');
              str_val = '';  

            case {2,5} % {'threshold','sure'}
              vis     = 'on';
              str_txt = getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_THR');
              str_val = num2str(ent_Par);  

            case 3    % 'norm'
              vis     = 'on';
              str_txt = getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_POW');
              str_val = num2str(ent_Par);  

            case 6   % 'user'
              vis     = 'on';
              str_txt = getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_FUN');
              str_val = ent_Par;  
        end
        old_vis = get(txt_par,'Visible');
        if ~isequal(old_vis,vis)
            ud = get(fra_ent,'UserData');
            positions = ud.positions;
            units = get(fig,'Units');
            units = lower(units(1:3));
            if isequal(units,'pix') , dPOS = 0; else dPOS = 2; end 
            switch vis
              case 'off' , pos_fra = positions(1+dPOS,:);
              case 'on'  , pos_fra = positions(2+dPOS,:);
            end
            set(fra_ent,'Position',pos_fra);
        end
        set(pop_ent,'Value',num);        
        set(txt_par,'String',str_txt,'Visible',vis);
        set(uic_ent,'String',str_val,'Visible',vis);

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        val = get(pop_ent,'Value');
        lst = wtranslate('ORI_lstentropy');
        ent_Nam = lower(deblankl(lst{val}));
        ent_Par = deblankl(get(uic_ent,'String'));
        switch ent_Nam
          case {'shannon','logenergy'} , ent_Par = 0; err = 0;

          case {'threshold','norm','sure'}
            err = isempty(abs(ent_Par)) || isnan(str2num(ent_Par));
            if ~err
                 ent_Par = str2num(ent_Par);
                 err = isempty(ent_Par);
                 if ~err
                     switch ent_Nam
                         case 'norm' ,      err = (ent_Par<1);
                         case 'sure' ,      err = (ent_Par<0);
                         case 'threshold' , err = (ent_Par<0);
                     end
                 end
            end

          case 'user'         
            ok = exist(ent_Par); %#ok<EXIST>
            if isempty(ok) || ~ismember(ok,[2 3 5 6])
                err = 2;
            else
                err = 0;
            end

        end
        varargout = {};
        ind = 1;
        for k = 1:nbarg
           outType = varargin{k};
           switch outType
             case 'nam' , varargout{ind} = ent_Nam; ind = ind+1; %#ok<*AGROW>
             case 'par' , varargout{ind} = ent_Par; ind = ind+1;
             case 'ent' 
               varargout{ind} = ent_Nam; ind = ind+1;
               varargout{ind} = ent_Par; ind = ind+1;
             case 'txt'
                switch ent_Nam
                   case {'shannon','logenergy'}
                       varargout{ind} = '';
                   case {'threshold','sure'}
                       varargout{ind} = ...
                           getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_THR');
                   case 'norm'
                       varargout{ind} = ...
                           getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_POW');
                   case 'user'
                       varargout{ind} = ...
                           getWavMSG('Wavelet:wp1d2dRF:WP_EntPar_FUN');
                end
                ind = ind+1;
           end
        end
        varargout{ind} = err; 

    case {'enable','Enable'}
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        set([pop_ent,uic_ent],'Enable',varargin{1});

    case 'clean'
        utentpar('set',fig,'nam','shannon');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end


%--------------------------------
function num = getNum(entNam)

switch entNam
  case 'shannon'  , num = 1;
  case 'threshold', num = 2;
  case 'norm'     , num = 3;
  case 'logenergy', num = 4;
  case 'sure'     , num = 5;
  case 'user'     , num = 6;
end
%--------------------------------
