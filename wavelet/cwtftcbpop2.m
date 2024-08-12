function cwtftcbpop2(option,activ_POP,caller)
%CWTFTCBPOP2 Callback for the wavelet popupmenu in CWTFTTOOL2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2012.
%   Last Revision: 06-Mar-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

[hObj,hFig] = gcbo;
switch option
    case 'defString'
        parHDL = get(activ_POP,'Parent');
        lst  = deblankl(get(activ_POP,'String'));
        val  = get(activ_POP,'Value');
        ActSTR = deblankl(lst{val});
        item = deblankl(ActSTR);
        if ~strcmp(item,'**') , return; end
        pos = get(activ_POP,'Position');
        uni = get(activ_POP,'Units');
        set(activ_POP,'Visible','off');
        edi_num = uicontrol(...
            'Parent',parHDL,        ...
            'Style','edit',         ...
            'Units',uni,            ...
            'Position',pos,         ...
            'BackgroundColor','w',  ...
            'Interruptible','Off',  ...
            'Visible','on',         ...
            'Userdata',val,         ...
            'String',[]             ...
            );
        cb = @(~,~)cwtftcbpop2('ok_num', activ_POP, caller);
        set(edi_num,'Callback',cb);
        txt = wfindobj(parHDL,'Tag','Txt_WAV_PAR');
        to_Ena_OFF_Edi_Num = wfindobj(hFig,'Enable','on');
        to_Ena_OFF_Edi_Num = setdiff(to_Ena_OFF_Edi_Num,[edi_num;txt]);
        wtbxappdata('set',hFig,'to_Ena_OFF_Edi_Num',to_Ena_OFF_Edi_Num);
        set(to_Ena_OFF_Edi_Num,'Enable','off');
        
    case 'ok_num'
        edi = hObj;
        rmax = 16;
        item = deblankl(get(edi,'String'));
        item(item==',') = '_';
        % Test the input value.
        err = 0; ok = 1; val = 0;
        switch caller
            case 'par'
                inputVal = str2double(item);
                Pop_WAV_NAM = ...
                    findobj(hFig,'Style','popupmenu','Tag','Pop_WAV_NAM');
                WNam = get(Pop_WAV_NAM,{'Value','String'});
                wname = WNam{2}{WNam{1}};
                if ~isnan(inputVal)
                    switch wname
                        case {'morl','morlex','morl0','dog','paul'}
                        case 'shan'
                        case 'dogf'
                    end
                else
                    err = 1;
                    switch wname
                        case {'morl','morlex','morl0','dog','paul'}
                            err = 1;
                        otherwise
                            if ~isempty(item)
                                try
                                    eval(item); err = 0;
                                catch %#ok<CTCH>
                                    err = 1;
                                end
                            end
                    end
                end
                if err
                    val = getDefaultParam(wname);
                    errMSG = getWavMSG('Wavelet:cwtfttool:Inv_Wav_Par');
                    errTIT = getWavMSG('Wavelet:cwtfttool:Def_Wav_Par');
                end
                               
            case 'pow'
                inputVal = str2double(item);
                if ~isnan(inputVal)
                    err = (inputVal<(1+0.01)) || (inputVal>10);
                else
                    err = 1;
                end
                if err
                    val = 1;
                    errMSG = getWavMSG('Wavelet:cwtfttool:Inv_Pow_Val');
                    errTIT = getWavMSG('Wavelet:cwtfttool:Def_Pow_Val');
                end
        end
        if err
            ok = 0;
            wwarndlg(errMSG,errTIT ,'modal');
        end        
        if ~err
            lst  = deblankl(get(activ_POP,'String'));
            r = size(lst,1);
            k = find(strcmp(item,lst));
            if ~isempty(k)
                ok  = 0;
                val = k;
            else
                ok  = 1;
                val = r;
                if r==rmax , r = r-1; end
                lst = [lst(1:r-1);item;lst(r)]; 
            end
        end
        if ok
            % To sort the string.
            %--------------------
            % [~,idx] = sort(str2double(lst));
            % lst = lst(idx);
            % lst{end} = '**';
            % val = find(idx==r);
            set(activ_POP,'String',lst,'Value',val,'Visible','on');
        else
            set(activ_POP,'Value',val,'Visible','on');
        end
        delete(edi)
        to_Ena_OFF_Edi_Num = wtbxappdata('get',hFig,'to_Ena_OFF_Edi_Num');
        set(to_Ena_OFF_Edi_Num,'Enable','On');
end
%--------------------------------------------------------------------------
function val = getDefaultParam(wname)

switch wname
    case {'morl','morlex','morl0'} , val = 6;
    case 'dog'   , val = 1;
    case 'paul'  , val = 1;
end
%--------------------------------------------------------------------------

