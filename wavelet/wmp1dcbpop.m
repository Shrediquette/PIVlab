function wmp1dcbpop(option,actif_OBJ,caller)
%WMP1DCBPOP GUI utility 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Apr-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

[hObj,hFig] = gcbo;
switch option
    case 'edi'
        val  = str2double(get(actif_OBJ,'String'));
        if isnan(val)
            strOBJ = ''; err = 1;
        else
            if val<0 || val>100
                strOBJ = ''; err = 1;
            else
                 err = 0;
                 strOBJ = num2str(val);
            end
        end
        if err , end
        set(actif_OBJ,'String',strOBJ);
        
    case 'defString'
        parHDL = get(actif_OBJ,'Parent');
        lst  = deblankl(get(actif_OBJ,'String'));
        val  = get(actif_OBJ,'Value');
        tag_POP = get(actif_OBJ,'Tag');
        ActSTR = deblankl(lst{val});
        item = deblankl(ActSTR);
        if ~strcmp(item,'**') , return; end
        pos = get(actif_OBJ,'Position');
        uni = get(actif_OBJ,'Units');
        set(actif_OBJ,'Visible','off');
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
        cb = @(~,~)wmp1dcbpop('ok_num',tag_POP, caller);
        set(edi_num,'Callback',cb);
        txt = wfindobj(parHDL,'Tag','Txt_ITER');
        to_Ena_OFF_Edi_Num = wfindobj(hFig,'Enable','on');
        to_Ena_OFF_Edi_Num = setdiff(to_Ena_OFF_Edi_Num,[edi_num;txt]);
        wtbxappdata('set',hFig,'to_Ena_OFF_Edi_Num',to_Ena_OFF_Edi_Num);
        set(to_Ena_OFF_Edi_Num,'Enable','off');
        
    case 'ok_num'
        actif_OBJ = findobj(hFig,'Style','popupmenu','Tag',actif_OBJ);
        edi = hObj;
        rmax = 16;
        item = deblankl(get(edi,'String'));
        item(item==',') = '_';
        % Test the input value.
        err = 0; ok = 1; val = 0;
        switch caller
            case 'par'
                inputVal = str2double(item);
                if isnan(inputVal) || (inputVal<=0) || isinf(inputVal)
                    err = 1;
                    errMSG = getWavMSG('Wavelet:wmp1dRF:PopErrMsg');
                    errTIT = getWavMSG('Wavelet:wmp1dRF:PopErrTit');
                end
        end
        if err
            ok = 0; val = 10;
            wwarndlg(errMSG,errTIT ,'modal');
        end        
        if ~err
            lst  = deblankl(get(actif_OBJ,'String'));
            r = size(lst,1);
            k = find(strcmp(item,lst));
            if ~isempty(k)
                ok  = 0;
                val = k;
            else
                ok  = 1;
                val = r;
                if r==rmax
                    r = r-1;
                    lst = [lst(1:r-1);item;lst(end)]; 
                elseif r>rmax
                    r = r-2;
                    lst = [lst(1:r-1);item;lst(end)]; 
                end
            end
        end
        if ok
            % To sort the string.
            %--------------------
            [~,idx] = sort(str2double(lst));
            lst = lst(idx);
            lst{end} = '**';
            val = find(idx==r);
            set(actif_OBJ,'String',lst,'Value',val,'Visible','on');
        else
            set(actif_OBJ,'Value',val,'Visible','on');
        end
        delete(edi)
        to_Ena_OFF_Edi_Num = wtbxappdata('get',hFig,'to_Ena_OFF_Edi_Num');
        set(to_Ena_OFF_Edi_Num,'Enable','On');
end
