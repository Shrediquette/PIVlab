function varargout = cbcolmap(option,fig,varargin)
%CBCOLMAP Callbacks for colormap utilities.
%   NBC = CBCOLMAP(OPTION,FIG,VARARGIN)
%   option :
%       'pal' : change the colormap.
%       'bri' : change the brightness.
%       'nbc' : change the number of colors.
%       'set' : sets colormap.
%   FIG = handle of the figure.
%   HDL = handle(s) of used button(s). (IN3 or IN4)
%   NBC = number of colors. (IN4 or IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-98.
%   Last Revision: 01-Oct-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.6.4.14 $  $Date: 2013/10/08 17:02:45 $

if ~ishandle(fig) , fig = gcbf; end

% Default Values.
%----------------
% maxmax_nbcolors = 448;
min_nbcolors = 2;
% def_nbcolors = 128;
% min_bright   = -2;
% max_bright   = 2;
% def_bright   = 0;

% Find Handles.
%--------------
[Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P] = ...
    utcolmap('handles',fig,'act');

option = lower(option);
switch option
    case 'nbc'
        e_or_s = varargin{1};
        if ~ishandle(e_or_s) , e_or_s = gcbo; end
        max_sli = get(Sli_NBC,'Max');
        st = get(e_or_s,'Style');
        if strcmp(st,'edit')
            nbcol = str2num(get(e_or_s,'String'));
            continu = 1;
            if isempty(nbcol)
                continu = 0;
            elseif (nbcol<min_nbcolors)
                continu = 0 ;
            elseif nbcol>max_sli
                nbcol = max_sli;
                set(e_or_s,'String',sprintf('%.0f',nbcol));
            end
            if ~continu
                map = get(fig,'Colormap');
                nbcol = size(map,1);
                set(e_or_s,'String',sprintf('%.0f',nbcol));
                if nargout>0 , varargout{1} = nbcol; end
                return;
            end
            if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',nbcol); end
        elseif strcmp(st,'slider')
            nbcol = round(get(e_or_s,'Value'));
            if ~isempty(Edi_NBC)
                set(Edi_NBC,'String',sprintf('%.0f',nbcol));
            end
        end
        nbcol = cbcolmap('pal',fig,nbcol);
        if nargout>0 , varargout{1} = nbcol; end

    case 'pal'
        map = get(fig,'Colormap');
        if length(varargin)<1 , NBC = size(map,1); else NBC = varargin{1}; end
        val = get(Pop_PAL,'Value');
        name = mextglob('get','Lst_ColorMap');
        SELF_MAP =  val>length(name);
        if ~SELF_MAP , name = deblankl(name{val}); end
        if SELF_MAP
            map = get(Pop_PAL,'UserData');
            nbcol = size(map,1);
            if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',nbcol); end
            if ~isempty(Edi_NBC)
                set(Edi_NBC,'String',sprintf('%.0f',nbcol));
            end
            
        elseif strcmp(name(1:2),'1-')
            name = name(3:end);
            map  = 1-feval(name,NBC);
        else
            map = feval(name,NBC);
        end
        set(fig,'Colormap',map);
        if nargout>0 , varargout{1} = NBC; end

    case 'bri'
        val = 0.5*varargin{1};
        old_Vis = get(fig,'HandleVisibility');
        set(fig,'HandleVisibility','on')
        if ~isequal(get(0,'CurrentFigure'),fig) , figure(fig); end
        brighten(val);
        set(fig,'HandleVisibility',old_Vis)

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = varargin{k};
           argVal  = varargin{k+1};
           switch argType
             case 'pal'
                 names = get(Pop_PAL,'String');
                 NBC   = [];
                 if iscell(argVal)
                     namepal = argVal{1};
                     if length(argVal)>1
                         NBC = argVal{2};
                         if length(argVal)==4
                             % Adding the "self" colormap.
                             %----------------------------
                             % addNam = argVal{3}; For next versions.
                             addNam = getWavMSG('Wavelet:LastMessages:self');
                             udMap  = argVal{4};
                             namesDEF = wtranslate('lstcolormap');
                             if ~isempty(udMap)
                                 if isequal(length(namesDEF),length(names))
                                     names = [names;{addNam}]; 
                                 end
                             else
                                 names = namesDEF;
                             end
                             set(Pop_PAL,'String',names,'UserData',udMap);
                         end
                     end
                 else
                     namepal = argVal;
                 end
                 if iscell(namepal) , namepal = namepal{1}; end

                 % Setting the number of colors.
                 %------------------------------
                 max_sli = get(Sli_NBC,'Max');
                 map     = get(fig,'Colormap');
                 nb_col  = size(map,1);
                 if isempty(NBC) || ~isnumeric(NBC)
                     NBC = nb_col;
                 elseif (NBC<min_nbcolors)
                     NBC = nb_col;
                 end
                 if NBC>max_sli , NBC = max_sli; end

                 % Setting the name of colormap.
                 %------------------------------
                 % namepal = deblankl(namepal);
                 if ~(isempty(namepal) || isequal(namepal,'same'))
                     ind = find(strcmpi(namepal,names));
                     if isempty(ind)
                         lst = wtranslate('ORI_lstcolormap');
                         ind = find(strcmpi(namepal,lst));
                     end
                 else
                     ind = get(Pop_PAL,'Value');
                 end
                 if ~isempty(ind)
                     set(Pop_PAL,'Value',ind);
                     if ~isempty(Edi_NBC)
                         set(Edi_NBC,'String',sprintf('%.0f',NBC));
                     end
                     if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',NBC); end
                     cbcolmap('pal',fig,NBC);
                 end
                 if nargout>0 , varargout{1} = NBC; end
           end
        end

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        varargout = {};
        for k = 1:nbarg
           outType = lower(varargin{k});
           switch outType
             case 'self_pal' , varargout{k} = get(Pop_PAL,'UserData'); %#ok<*AGROW>
             case 'pop_pal'  , varargout{k} = Pop_PAL;
             case 'sli_nbc'  , varargout{k} = Sli_NBC;
             case 'edi_nbc'  , varargout{k} = Edi_NBC;
             case 'btn_bri'  , varargout{k} = [Pus_BRI_M,Pus_BRI_P];
             case 'mapname'  , prop =  get(Pop_PAL,{'String','Value'});
                               varargout{k} = prop{1}{prop{2}};
             case 'nbcolors' , varargout{k} = round(get(Sli_NBC,'Value'));
           end
        end

    case 'enable'
        if ~ishandle(Pus_BRI_M)
            hdl2ena = [Pop_PAL,Sli_NBC,Edi_NBC];
        else
            hdl2ena = [Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P];
        end
        set(hdl2ena,'Enable',varargin{1});

    case 'visible'
        handles = utcolmap('handles',fig,'cell');
        handles = handles(ishandle(handles));
        set(handles,'Visible',varargin{1});

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end
