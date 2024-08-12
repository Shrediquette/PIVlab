function varargout = cbanapar(option,fig,varargin)
%CBANAPAR Callbacks for wavelet analysis parameters.
%   VARARGOUT = CBANAPAR(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-May-98.
%   Last Revision: 12-Dec-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.7.4.17.4.1 $  $Date: 2014/01/04 07:40:05 $

option = lower(option);
switch option
    case 'no_pop'
        pop_liste  = varargin{1};
        [Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev] = utanapar('handles',fig,'pop');
        ind = wcommon(pop_liste,[Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev]);
        pop_liste(ind) = [];
        if nargout>0 , varargout{1} = pop_liste; end

    case 'cba_fam'
        if nargin>3   % VERSION 3: Inputs = (option , fig, eventdata, handles)
            handles = varargin{2};
            Pop_Wav_Fam = handles.Pop_Wav_Fam;
            Pop_Wav_Num = handles.Pop_Wav_Num;
        else          % VERSION 2 & 3: Inputs = (option , fig, [Pop_Wav_Fam, Pop_Wav_Num])
            Pop_Wav_Fam = varargin{1}(1);
            Pop_Wav_Num = varargin{1}(2);
            if ~ishandle(Pop_Wav_Fam) || ~ishandle(Pop_Wav_Num)
                handles = guihandles(gcbf);
                Pop_Wav_Fam = handles.Pop_Wav_Fam;
                Pop_Wav_Num = handles.Pop_Wav_Num;                
            end
        end
        numf = get(Pop_Wav_Fam,'Value');
        strf = get(Pop_Wav_Fam,'String');
        if iscell(strf)
            strf = noblank(strf{numf});
        else
            strf = noblank(strf(numf,:));
        end
        tab  = wavemngr('fields',{'fsn',strf},'tabNums');
        nbNUM = size(tab,1);
        vis = 'on';
        switch  nbNUM
            case 0 , vis = 'off';
            case 1 , if strcmp(noblank(tab(1,:)),'no') , vis = 'off'; end
        end
        if strcmp(vis,'off')
            set(Pop_Wav_Num,'Visible',vis,'String',tab,'Value',1);
        else
            set(Pop_Wav_Num,'String',tab,'Value',1,'Visible',vis);
        end

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        [Txt_Data_NS,Edi_Data_NS,Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev] = ...
                utanapar('handles',fig); 
        for k = 1:2:nbarg
           argType = varargin{k};
           argVal  = varargin{k+1};
           switch argType
             case 'typ'
                set(Txt_Data_NS,'String',[argVal '  (Size)']);

             case 'n_s' 
                siz = argVal{2};
                dim = length(siz);
                n_s = [argVal{1} '  (' ];
                if   dim==1
                  n_s = [n_s,int2str(siz) ')']; 
                else
                  n_s = [n_s,int2str(siz(2)) 'x' int2str(siz(1)) ')']; 
                end
                set(Edi_Data_NS,'String',n_s);                
             case 'nam' , set(Edi_Data_NS,'String',argVal);
             case 'fam' , setProperties(Pop_Wav_Fam,argVal);
             case 'num' , setProperties(Pop_Wav_Num,argVal);
             case 'wav' , setWname(Pop_Wav_Fam,Pop_Wav_Num,argVal);
             case 'lev' , setProperties(Pop_Lev,argVal);
           end
        end

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        [Txt_Data_NS,Edi_Data_NS,Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev] = ...
            utanapar('handles',fig); %#ok<ASGLU>
        for k = 1:nbarg
           outType = varargin{k};
           switch outType
             case 'wav'
                 wf   = get(Pop_Wav_Fam,{'Style','String','Value'});
                 if isequal(wf{1},'edit')
                    fam  = wf{2};
                 else
                    fam  = wf{2}(wf{3},:);
                 end
                 fam = noblank(fam);
                 wf = get(Pop_Wav_Num,{'Style','String','Value'});
                 if ~isequal(wf{1},'edit')
                     strn = wf{2};                    
                     if ~isempty(strn)
                         strn = noblank(strn(wf{3},:));
                         if strcmp(strn,'no') , strn = ''; end
                     else
                         strn = '';
                     end
                else
                    strn = noblank(wf{2});
                    if strcmp(strn,'no') , strn = ''; end
                end                
                varargout{k} = [fam strn]; %#ok<*AGROW>

             case 'lev'
                 levPar = get(Pop_Lev,{'Style','String','Value'});
                 if ~isequal(levPar{1},'edit')
                     levMAX = length(levPar{2});
                     if levPar{3}>levMAX
                         set(Pop_Lev,'Value',levMAX);
                         levPar{3} = levMAX;
                     end
                     varargout{k} = str2num(levPar{2}(levPar{3},:));
                 else
                     varargout{k} = str2num(levPar{2});
                 end
 
             case 'levmax' ,  varargout{k} = size(get(Pop_Lev,'String'),1);
             
             case 'nam'
                varargout{k} = get(Edi_Data_NS,'String');
           end
        end

    case 'enable'
        ena = varargin{1};
        [Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev] = ...
                utanapar('handles',fig,'fam','num','lev');
        handles = double([Pop_Wav_Fam,Pop_Wav_Num,Pop_Lev]);
        handles = handles(handles~=0);
        set(handles(ishandle(handles)),'Enable',ena);

    case 'cba_num'
        switch nargin
            case {3,5}    % VERSION 2 & 3: Inputs = (option , fig, [Pop_Wav_Fam, Pop_Wav_Num])
                Pop_Wav_Fam = varargin{1}(1);
                Pop_Wav_Num = varargin{1}(2);                
                if length(varargin)>1  % varargin{2} NOT USED
                    ena_hdl = handle(varargin{3});
                else
                    ena_hdl = [];
                end
                if ~ishandle(Pop_Wav_Fam) || ~ishandle(Pop_Wav_Num)
                    handles = guihandles(gcbf);
                    Pop_Wav_Fam = handles.Pop_Wav_Fam;
                    Pop_Wav_Num = handles.Pop_Wav_Num;
                end
                
            case 4   % VERSION 3: Inputs = (option , fig, eventdata, handles)
                handles = varargin{2};
                Pop_Wav_Fam = handles.Pop_Wav_Fam;
                Pop_Wav_Num = handles.Pop_Wav_Num;           
        end
        lst  = get(Pop_Wav_Num,'String');
        val  = get(Pop_Wav_Num,'Value');
        if iscell(lst)
            item = deblankl(lst{val});
        else
            item = deblankl(lst(val,:));
        end
        if strcmp(item,'**')
            pos = get(Pop_Wav_Num,'Position');
            uni = get(Pop_Wav_Num,'Units');
            if ~isempty(ena_hdl)
                ena_hdl = findobj(ena_hdl,'flat','Enable','on');
                set(ena_hdl,'Enable','off');
            end
            set(Pop_Wav_Fam,'Enable','off');
            set(Pop_Wav_Num,'Visible','off');
            edi_num = uicontrol(...
                        'Parent',get(Pop_Wav_Num,'Parent'), ...
                        'Style','edit',         ...
                        'Units',uni,            ...
                        'Position',pos,         ...
                        'BackgroundColor','w',  ...
                        'Interruptible','Off',  ...
                        'String',[]             ...
                        );
            hdl_str = [Pop_Wav_Fam;Pop_Wav_Num;edi_num;ena_hdl];
            cba = @(~,~)cbanapar('ok_num', fig, hdl_str );
            set(edi_num,'Callback',cba);
            
            to_Ena_OFF_Edi_Num = wfindobj(fig,'Enable','on');
            to_Ena_OFF_Edi_Num = setdiff(to_Ena_OFF_Edi_Num,edi_num);
            wtbxappdata('set',fig,'to_Ena_OFF_Edi_Num',to_Ena_OFF_Edi_Num);
            set(to_Ena_OFF_Edi_Num,'Enable','Off');

        end

    case 'ok_num'
        Pop_Wav_Fam = varargin{1}(1);
        Pop_Wav_Num = varargin{1}(2);
        edi     = varargin{1}(3);
        if length(varargin{1})>3  
            ena_hdl = varargin{1}(4:end);
        else
            ena_hdl = [];
        end
        rmax  = 16;
        nmax  = 45;
        tmp   = get(Pop_Wav_Fam,{'String','Value'});
        if iscell(tmp{1})
            w_fam = deblankl(tmp{1}{tmp{2}});
        else
            w_fam = deblankl(tmp{1}(tmp{2},:));
        end

        [typNums,w_fileName] ...
            = wavemngr('fields',{'fsn',w_fam}, 'typNums','file');
        [dummy,filename,ext] = fileparts(w_fileName);         %#ok<ASGLU>
      
        item = deblank(get(edi,'String'));        
        err = 0; ok = 1; val = 0;
        switch typNums
          case {'integer','real'}
            if isempty(ext)
               try
                 maxNum = feval(filename);
                 if length(maxNum)==1 , nmax = maxNum; end
               catch %#ok<*CTCH>
               end
            end
            num = str2num(item);
            if isempty(num) || (num<1) || (num>nmax) , err = 1; end
            if ~err
                if isequal(typNums,'integer') , err = num~=fix(num); end
            end          
            if err , ok = 0; val = 1; end
          case 'string'
            try
              bounds = wavemngr('fields',{'fsn',w_fam}, 'bounds');
              nbpoints = 10;
              wname  = [w_fam,item];
              feval(filename,bounds(1),bounds(2),nbpoints,wname);
            catch
              err = 1; ok = 0; val = 1;
            end          
        end
        if ~err
            lst = get(Pop_Wav_Num,'String');
            r = size(lst,1);
            if iscell(lst)
                lst = char(lst{:});
            end
            switch typNums
              case {'integer','real'}
                for k=1:r-1
                    num_k = str2num(lst(k,:));
                    if num==num_k
                      ok  = 0;
                      val = k;
                      break;
                    elseif  num<num_k
                      ok  = 1;
                      val = k;
                      item = getItem(num,typNums);
                      if k==1 , lst_beg = item;
                      else      lst_beg = char(lst(1:k-1,:),item); 
                      end
                      if r<rmax ,    middleLST = lst(k:r-1,:);
                      elseif k<r-1 , middleLST = lst(k:r-2,:);
                      else           middleLST = '';
                      end
                      lst = char(lst_beg,middleLST,lst(r,:));
                      break;
                    end
                end
                if val==0 
                    ok  = 1;
                    val = r;
                    item = getItem(num,typNums);
                    if r==rmax , r = r-1; end
                    lst = char(lst(1:r-1,:),item,lst(r,:)); 
                end

              case 'string'
                TMP = num2cell(lst,2);
                k = find(strncmp(item,TMP,length(item)));
                if ~isempty(k)
                    ok  = 0;
                    val = k;
                else
                    ok  = 1;
                    val = r;
                    if r==rmax , r = r-1; end
                    lst = char(lst(1:r-1,:),item,lst(r,:)); 
                end
            end
        end
        if ok
            set(Pop_Wav_Num,'String',lst,'Value',val,'Visible','on');
        else
            set(Pop_Wav_Num,'Value',val,'Visible','on');
        end
        delete(edi)
        set(Pop_Wav_Fam,'Enable','on');
        if ~isempty(ena_hdl) , set(ena_hdl,'Enable','on'); end
        if err
           wwarndlg(getWavMSG('Wavelet:moreMSGRF:Select_WavNum'), ...
               getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'modal');
        end
        to_Ena_OFF_Edi_Num = wtbxappdata('get',fig,'to_Ena_OFF_Edi_Num');
        set(to_Ena_OFF_Edi_Num,'Enable','On');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end


%---------------------------------------%
% Internal Function(s)                  %
%---------------------------------------%
function s = noblank(x)
if ~isempty(x)
    s = x(x~=' ' & x~=0);
else
    s = '';
end
%---------------------------------------%
function item = getItem(num,typNums)

switch typNums
    case 'integer'
      item = sprintf('%.0f',num);

    case 'real'
      item = sprintf('%.15f',num);
      while item(end)=='0' , item(end) = []; end
      if ~isempty(item) && item(end)=='.'
          item = [item '0'];
      end
end
%---------------------------------------%
function setProperties(h,argVal)

if iscell(argVal)
    set(h,argVal{:});
else
    set(h,'Value',argVal);
end
%----------------------------------------------------------------------%
function varargout = setWname(Pop_Wav_Fam,Pop_Wav_Num,wname)

[i_fam,i_num,wav_fam,num_str,tab_num,add_num] = wavemngr('indw',wname);
tabfam_loc = get(Pop_Wav_Fam,'String');
for k = 1:size(tabfam_loc,1)
    if strcmp(wav_fam,deblank(tabfam_loc(k,:)))
        i_fam_loc = k;
        break
    end
end
lnum = size(tab_num,1);
if lnum==1 && isempty(num_str) , tab_num = ''; end
if add_num
    if lnum==1
        tab_num = num_str;
    else
        tab_num = char(tab_num(1:lnum-1,:),num_str,tab_num(lnum,:));
    end
end
if isempty(tab_num)
    tab_num = 'no'; vis  = 'off';
else
    vis  = 'on';
end

%%% MiMi : BUG MATLAB %%%
tmp = get(Pop_Wav_Fam,'String');
rrr = size(tmp,1);
set(Pop_Wav_Fam,'Value',rrr);
pause(0.01)

set(Pop_Wav_Fam,'Value',i_fam_loc);
set(Pop_Wav_Num,'Visible',vis,'String',tab_num,'Value',i_num);

if nargout>0
    varargout = {wav_fam,tab_num,i_fam,i_num,i_fam_loc};
end
%----------------------------------------------------------------------%

