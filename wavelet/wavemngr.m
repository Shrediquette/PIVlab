function varargout = wavemngr(option,varargin)
%WAVEMNGR Wavelet manager.
%   WAVEMNGR is a wavelet manager used to add, delete, restore
%   or read wavelets.
%
%   WAVEMNGR('add',FN,FSN,WT,NUMS,FILE) or
%   WAVEMNGR('add',FN,FSN,WT,NUMS,FILE,B) or
%   WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE) or
%   WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE,B)
%   adds a new wavelet family.
%     FN  = family name (string).
%     FSN = family short name (string).
%
%     WT defines the wavelet type:
%     WT = 1 for orthogonal wavelets.
%     WT = 2 for biorthogonal wavelets.
%     WT = 3 for wavelet with scale function.
%     WT = 4 for wavelet without scale function.
%     WT = 5 for complex wavelet without scale function.
%
%     If the wavelet is a single one, NUMS = ''.
%       For instance: mexh, morl.
%     If the wavelet is part of a finite family of wavelets, NUMS
%       is a string containing a blank separated list of items
%       representing wavelet parameters.
%       For instance: bior, NUMS = '1.1 1.3 ... 4.4 5.5 6.8'.
%     If the wavelet is part of an infinite family of wavelets,
%       NUMS is a string containing a blank separated list of
%       items representing wavelet parameters, terminated by the
%       special sequence **.
%       For instance:
%         db,    NUMS = '1 2 3 4 5 6 7 8 9 10 **'.
%         shan,  NUMS = '1-1.5 1-1 1-0.5 1-0.1 2-3 **'
%     In these last two cases, TYPNUMS specifies the wavelet parameter
%       input format: 'integer' or 'real' or 'string'; the default
%       value is 'integer'.
%       For instance:
%            db,   TYPNUMS = 'integer'
%            bior, TYPNUMS = 'real'
%            shan, TYPNUMS = 'string'
%
%     FILE = MAT-file or MATLAB file name (string).
%
%     B = [lb ub] specifies lower and upper bounds of
%     effective support for wavelets of type = 3, 4 or 5.
%
%   WAVEMNGR('del',N), deletes a wavelet or a wavelet family where
%     N is the wavelet name or the family short name.
%
%   WAVEMNGR('restore') restores the previous
%     wavelets.asc ASCII-file.
%   WAVEMNGR('restore',IN2) restores the initial
%     wavelets.asc ASCII-file.
%
%   OUT1 = WAVEMNGR('read') returns all wavelets family names.
%
%   OUT1 = WAVEMNGR('read',IN2) returns all wavelet names.
%
%   OUT1 = WAVEMNGR('read_asc') returns all wavelets information
%   retrieved from wavelets.asc ASCII-file.

%----------------------
%   INTERNAL OPTIONS.
%----------------------
%   WAVEMNGR('create')
%   creates wavelets.inf MAT-file using wavelets.asc ASCII-file.
%
%   OUT1 = WAVEMNGR('load') or WAVEMNGR('load')
%   loads Wavelets_Info from wavelets.inf matfile,
%   and puts it in the global variable: Wavelets_Info.
%
%   WAVEMNGR('clear') clear the global Wavelets_Info.
%
%   [OUT1,OUT2,OUT3,OUT4,OUT5,OUT6] = WAVEMNGR('indw',W)
%   returns:
%   family indice, number indice,
%   family, number for the wavelet W.
%   OUT5 is the family table of number.
%   OUT6 is a flag for GUI.
%
%   OUT1 = WAVEMNGR('indf',F) returns indice
%   for wavelet family F (short name).
%
%   varargout = wavemngr('fields',varargin) see below.
%
%   OUT1 = WAVEMNGR('read_struct')
%   OUT1 gives all wavelets structures.
%
%   OUT1 = WAVEMNGR('read_struct',NUMS)
%   OUT1 gives the wavelets structures.
%   specified by NUMS.
%
%   OUT1 = WAVEMNGR('tfsn') or WAVEMNGR('tfsn',T)
%   returns shortname-table (of type = T : 'dwt' or 'cwt' or 'owt' or 'ccwt').
%
%   OUT1 = WAVEMNGR('tfn') or out1 = WAVEMNGR('tfn',T)
%   returns name-table (of type = T : 'dwt' or 'cwt' or 'owt' or 'ccwt').
%
%   OUT1 = WAVEMNGR('isbior',W)
%   returns 1 for biorthogonal wavelets.
%
%   [FAM,NUM] = WAVEMNGR('fam_num',W) returns
%   family and number for the wavelet W.
%
%   LEN = WAVEMNGR('length',W) returns the
%   length of the support of the wavelet W.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2021 The MathWorks, Inc.

if nargin > 0
    option = convertStringsToChars(option);
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

Wavelets_Info = getappdata(0,'Wavelets_Info');

%----------------------%
% Wavelets Structures. %
%--------------------------------------------------------%
% Wavelets_Info is a  structure array with size [nb_fam 1]
%
% Wavelet_Struct =
%   struct(...
%     'index'           integer
%     'familyName'      string
%     'familyShortName' string
%     'type'            integer
%     'tabNums'         matrix of string
%     'typNums'         string
%     'file'            string
%     'bounds'          string
%     );
%---------------------------------------------------------%

% Files Names.
%--------------
bin_ini_file = 'wavelets.bin';
asc_ini_file = 'wavelets.ini';
bin_file = 'wavelets.inf';
asc_file = 'wavelets.asc';
sav_file = 'wavelets.prv';

if nargin==0 , option = 'create' ; end

% Miscellaneous Values.
%----------------------
nb_InfoByWave =  7;
% Number of wavelet families
NB_FamInWTB   = 16;
WaveTypePOS   = 1:5;

if isempty(Wavelets_Info)
    switch option
        case {'indw','indf','tfsn','tfn','read','read_struct','type',  ...
                'fields','file','fn','fsn','tabnums','tabNums','typNums', ...
                'bounds'}
            Wavelets_Info = wavemngr('load');
        otherwise
    end
end
switch option
    case 'load'
        if isempty(Wavelets_Info)
            try
                load(bin_file,'-mat')
            catch
                try
                    load(bin_ini_file,'-mat')
                catch
                    clc
                    msg = char(' ',...
                        '---------------------------------------------', ...
                        getWavMSG('Wavelet:moreMSGRF:File_not_found',bin_ini_file), ...
                        getWavMSG('Wavelet:moreMSGRF:Using_rescue'), ...
                        '---------------------------------------------',' ');
                    disp(msg);
                    Wavelets_Info  = wavemngr('rescue');
                end
            end
            setappdata(0,'Wavelets_Info',Wavelets_Info);
        end
        if nargout>0 , varargout{1} = Wavelets_Info; end
        
    case 'clear'
        if isappdata(0,'WTBX_Glob_Info')
            rmappdata(0,'WTBX_Glob_Info');
        end
        if isappdata(0,'Def_WGlob_Struct')
            rmappdata(0,'Def_WGlob_Struct');
        end
        if isappdata(0,'Wavelets_Info') , rmappdata(0,'Wavelets_Info'); end
        
        
    case 'wavelets'
        tfsn = wavemngr('tfsn');
        varargout{1} = deblank(num2cell(tfsn,2));
        
    case 'indw'
        % in2 : wavelet name
        %-------------------
        % out1 = i_fam
        % out2 = i_num
        % out3 = fam
        % out4 = num_str
        % out5 = tabNums
        % out6 = flag '**' (for GUI)
        %---------------------------
        nb_fam = size(Wavelets_Info,1);
        wname  = deblankl(varargin{1});
        % If deblankl() obtains an empty string, then it converts this to a
        % double []. Accordingly, we error if the output of deblankl() is
        % empty.
        if isempty(wname)
            error(message('Wavelet:FunctionInput:EmptyWav'));
        end
        lwna   = length(wname);
        for i_fam=1:nb_fam
            fam = Wavelets_Info(i_fam).familyShortName;
            len = length(fam);
            ok_wave = 0;
            if lwna>=len
                if fam==wname(1:len)
                    tabNums = Wavelets_Info(i_fam).tabNums;
                    for i_num = 1:size(tabNums,1)
                        num_str = noblank(tabNums(i_num,:));
                        if strcmp(num_str,'no') , num_str = '' ; end
                        if strcmp([fam num_str],wname)
                            ok_wave = 1; add_num = 0; break;
                        end
                    end
                    
                    % test for ** number
                    %------------------
                    if ok_wave==0 && strcmp(num_str,'**') && (lwna>len)
                        typNums = Wavelets_Info(i_fam).typNums;
                        num_str = wname(len+1:lwna);
                        switch typNums
                            case 'integer'
                                num = str2num(num_str);
                                if ~isempty(num) && (num==fix(num)) && (0<num)
                                    ok_wave = 1; add_num = 1;
                                end
                                
                            case 'real'
                                num = str2num(num_str);
                                if ~isempty(num)
                                    ok_wave = 1; add_num = 1;
                                end
                                
                            case 'string'
                                ok_wave = 1; add_num = 1;
                        end
                    end
                    
                end
            end
            if ok_wave , break; end
        end
        if ok_wave
            varargout = {i_fam,i_num};
            if nargout<3 , return; end
            varargout = [varargout,{fam,num_str,tabNums,add_num}];
        else
            error(message('Wavelet:FunctionArgVal:Invalid_WavNamVar',wname));
        end
        
    case 'indf'
        fsnCell  = {Wavelets_Info(:).familyShortName}';
        fsnInput = deblankl(varargin{1});
        varargout{1} = find(strcmp(fsnInput,fsnCell)==1);
        
    case 'tfsn'
        fsnCell = {Wavelets_Info(:).familyShortName}';
        varargout{1} = char(fsnCell{:});
        if nargin==2
            wtype = lower(varargin{1});
            if isequal(wtype,'all') , return; end
            tab_type = {Wavelets_Info(:).type}';
            tab_type = cat(1,tab_type{:});
            switch wtype
                case {'dwt'}  , ind = find(tab_type==1 | tab_type==2);
                case {'cwt'}  , ind = find(tab_type>0 & tab_type<5);
                case {'owt'}  , ind = find(tab_type==1);
                case {'ccwt'} , ind = find(tab_type==5);
                case {'666'}
                    ind = [find(tab_type==5) ; find(tab_type>0 & tab_type<5)];
            end
            varargout{1} = varargout{1}(ind,:);
        end
        
    case 'tfn'
        fnCell = {Wavelets_Info(:).familyName}';
        varargout{1} = char(fnCell{:});
        if nargin==2
            wtype = lower(varargin{1});
            if isequal(wtype,'all') , return; end
            tab_type = {Wavelets_Info(:).type}';
            tab_type = cat(1,tab_type{:});
            switch wtype
                case {'dwt'}  , ind = find(tab_type==1 | tab_type==2);
                case {'cwt'}  , ind = find(tab_type>0 & tab_type<5);
                case {'owt'}  , ind = find(tab_type==1);
                case {'ccwt'} , ind = find(tab_type==5);
            end
            varargout{1} = varargout{1}(ind,:);
        end
        
    case 'fields'
        % in2 = {'ind', wavelet index} or
        % in2 = {'fsn', family shortname} or
        % in2 = {'wn' , wavelet name}
        % or
        % in2 = wavelet name
        %----------------------------
        % in3  ... = field(s) name(s)
        %----------------------------
        % out1 ... = field(s) value(s)
        %-----------------------------
        if iscell(varargin{1})
            in_type = varargin{1}{1};
            arg = varargin{1}{2};
        else
            in_type = 'wn';
            arg = varargin{1};
        end
        switch in_type
            case 'ind'
                if isempty(Wavelets_Info)
                    Wavelets_Info = wavemngr('load');
                end
                i_fam = arg;
                
            case 'fsn' , i_fam = wavemngr('indf',arg);
            case 'wn'  , i_fam = wavemngr('indw',arg);
        end
        nb = nargin-2;
        if nb==0
            varargout{1} = Wavelets_Info(i_fam);
            return;
        end
        varargout = cell(1,nb);
        for k=1:nb
            switch varargin{k+1}
                case 'ind'     , field = 'index';
                case 'fn'      , field = 'familyName';
                case 'fsn'     , field = 'familyShortName';
                case 'type'    , field = 'type';
                case 'tabNums' , field = 'tabNums';
                case 'typNums' , field = 'typNums';
                case 'file'    , field = 'file';
                case 'bounds'  , field = 'bounds';
                otherwise      , field = '';
            end
            if ~isempty(field)
                varargout{k} = Wavelets_Info(i_fam).(field);
            else
                varargout{k} = Wavelets_Info(i_fam);
            end
        end
        
    case 'type'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('type');
        
    case 'file'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('file');
        
    case 'fn'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('familyName');
        
    case 'fsn'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('familyShortName');
        
    case {'tabnums','tabNums'}
        i_fam = wavemngr('indf',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('tabNums');
        
    case {'typNums'}
        i_fam = wavemngr('indf',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('typNums');
        
    case 'bounds'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('bounds');
        
    case 'isbior'
        wname = varargin{1};
        if length(wname)>3
            wname = wname(1:4);
            varargout{1} = isequal(wname,'bior') | isequal(wname,'rbio');
        else
            varargout{1} = 0;
        end
        
    case 'fam_num'
        [~,~,varargout{1},varargout{2}] = wavemngr('indw',varargin{1});
        
    case 'length'
        wname = varargin{1};
        [wtype,bounds] = wavemngr('fields',{'wn',wname},'type','bounds');
        switch wtype
            case {1,2}
                Lo_D = wfilters(wname);
                varargout{1} = length(Lo_D);
            case {3,4,5}
                varargout{1} = bounds(2)-bounds(1)+1;
            otherwise
                % It is impossible to have registered wavelets of other
                % type.
        end
        
    case 'create'
        wavemngr('clear')
        beg_fam = 'Family Name : ';
        fid = fopen(asc_file);
        if fid==-1
            fid   = fopen(asc_ini_file);
            winfo = fread(fid);
            fclose(fid);
            fid   = fopen(asc_file,'w');
            fwrite(fid,winfo);
            fclose(fid);
        else
            winfo = fread(fid);
            fclose(fid);
        end
        winfo   = char(winfo');
        str_NL  = findNL('string',winfo);
        lennewl = length(str_NL);
        ind_NL  = strfind(winfo,str_NL);
        first   = strfind(winfo,beg_fam)+length(beg_fam);
        nb_fam  = length(first);
        
        %------------------------------%
        % Building Wavelets Structure. %
        %------------------------------%
        nul = cell(nb_fam,1);
        Wavelets_Info = struct(...
            'index',nul,           ...
            'familyName',nul,      ...
            'familyShortName',nul, ...
            'type',nul,            ...
            'tabNums',nul,         ...
            'typNums',nul,         ...
            'file',nul,            ...
            'bounds',nul           ...
            );
        
        for j = 1:nb_fam
            i_fam   = first(j);
            indexs  = find(ind_NL>i_fam);
            indexs  = ind_NL(indexs(1:nb_InfoByWave));
            fam     = winfo(i_fam:indexs(1)-1);
            sname   = winfo(indexs(1)+lennewl:indexs(2)-1);
            wtype   = winfo(indexs(2)+lennewl:indexs(3)-1);
            nums    = winfo(indexs(3)+lennewl:indexs(4)-1);
            typNums = winfo(indexs(4)+lennewl:indexs(5)-1);
            fname   = winfo(indexs(5)+lennewl:indexs(6)-1);
            bounds  = winfo(indexs(6)+lennewl:indexs(7)-1);
            
            notspace = ~isspace(nums);
            lnot     = length(notspace);
            index1   = find(notspace==1);
            k0       = index1(1);
            k1       = index1(length(index1));
            indnum   = diff(notspace);
            fnum     = find(indnum==1)+1;
            lnum     = find(indnum==-1);
            if k0==1    , fnum = [1 fnum];  end %#ok<AGROW>
            if k1==lnot , lnum = [lnum k1]; end %#ok<AGROW>
            nb_num   = length(fnum);
            tabNums  = '';
            for p = 1:nb_num
                tabNums = char(tabNums,nums(fnum(p):lnum(p)));
            end
            tabNums(1,:) = [];
            
            Wavelets_Info(j).index = j;
            Wavelets_Info(j).familyName = fam;
            Wavelets_Info(j).familyShortName = sname;
            Wavelets_Info(j).type = str2num(wtype);
            Wavelets_Info(j).tabNums = tabNums;
            Wavelets_Info(j).typNums = typNums;
            Wavelets_Info(j).file = fname;
            Wavelets_Info(j).bounds = str2num(bounds);
        end
        try
            save(bin_file,'Wavelets_Info')
        catch %#ok<*CTCH>
            errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Fail_ChangeWave'),'msg');
        end
        
    case 'read'
        nb_fam  = size(Wavelets_Info,1);
        sep_fam = '=';
        sep_fam = sep_fam(:,ones(1,35));
        sep_num = '-';
        sep_num = sep_num(:,ones(1,30));
        varargout{1} = sep_fam;
        tab     = char(9);
        
        families = char(Wavelets_Info(:).familyName);
        tabtab   = tab(ones(1,nb_fam),ones(1,2));
        
        if  nargin==1
            famSName    = char(Wavelets_Info(:).familyShortName);
            famTAB      = [families tabtab famSName];
            varargout{1}= char(varargout{1},famTAB,sep_fam);
        else
            famTAB = [families tabtab];
            for k =1:nb_fam
                sfname = Wavelets_Info(k).familyShortName;
                varargout{1} = char(varargout{1},[famTAB(k,:) sfname]);
                nb     = 0;
                wnames = [];
                tabNums = Wavelets_Info(k).tabNums;
                if size(tabNums,1)>1
                    varargout{1} = char(varargout{1},sep_num);
                end
                for j = 1:size(tabNums,1)
                    num_str = noblank(tabNums(j,:));
                    if ~strcmp(num_str,'no')
                        wnames = [wnames sfname noblank(tabNums(j,:)) tab]; %#ok<AGROW>
                    end
                    if nb<3
                        nb = nb+1;
                    else
                        if ~isempty(wnames)
                            varargout{1} = char(varargout{1},wnames);
                        end
                        nb  = 0;
                        wnames = [];
                    end
                end
                if nb>0 && ~isempty(wnames)
                    varargout{1} = char(varargout{1},wnames);
                end
                varargout{1} = char(varargout{1},sep_fam);
            end
        end
        
    case 'read_asc'
        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        idxNL = find(winfo==10,2,'first');
        if isempty(idxNL)
            idxNL = find(winfo==13,2,'first');
        end
        winfo = winfo(idxNL(2)+1:end);
        varargout{1} = char(winfo');
        
    case 'read_struct'
        if nargin==2
            indfam = varargin{1};
        else
            nb_fam = size(Wavelets_Info,1);
            indfam = 1:nb_fam;
        end

        tmp = Wavelets_Info(indfam);

        if nargout==0
            
            sep_fam = '*';
            sep_fam = sep_fam(:,ones(1,35));
            disp(' '); disp(' '); disp(' ');
            disp(sep_fam);

            for k =1:length(indfam)
                disp(tmp(k));
                disp(sep_fam);
            end
        end

        if nargout>0
            varargout{1} = tmp;
        end
        
    case 'add'
        wavemngr('clear')
        Wavelets_Info = wavemngr('load');
        family_Name = varargin{1};
        if isempty(family_Name)
            err = 1;
            msg = getWavMSG('Wavelet:moreMSGRF:Empty_FN');
        else
            fnIn  = noblank(family_Name);
            tmpCell = {Wavelets_Info(:).familyName}';
            ind   = find(strcmp(fnIn,tmpCell)==1,1);
            err   = ~isempty(ind);
            if err 
                msg = getWavMSG('Wavelet:moreMSGRF:Already_Used_WSName');
            end
        end
        
        if err==0
            family_Short_Name = varargin{2};
            if isempty(family_Short_Name)
                err = 1;
                msg = getWavMSG('Wavelet:moreMSGRF:Empty_FSN');
            else
                fsnIn   = deblankl(family_Short_Name);
                if any(strcmpi(fsnIn,{'amor','morse','bump'}))
                    error(message('Wavelet:moreMSGRF:CWTNameConflict'));
                end
                tmpCell = {Wavelets_Info(:).familyShortName}';
                ind     = find(strcmp(fsnIn,tmpCell)==1,1);
                err     = ~isempty(ind);
                if err
                    msg = getWavMSG('Wavelet:moreMSGRF:Already_Used_WSName');
                end
            end
        end
        
        if err==0
            wavelet_Type = varargin{3};
            if isempty(find(wavelet_Type==WaveTypePOS,1))
                err = 1;
                msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WaveType');
            end
        end
        
        if err==0
            
            if all(isspace(varargin{4}))
                varargin{4} = deblank(varargin{4});
            end
            if isempty(varargin{4})
                wavelet_tabNums = 'no';
                wavelet_typNums = 'no';
            elseif ischar(varargin{4})
                wavelet_tabNums = deblank(varargin{4});
                wavelet_typNums = 'integer';
            elseif iscell(varargin{4})
                wavelet_tabNums = deblank(varargin{4}{1});
                wavelet_typNums = deblank(varargin{4}{2});
                if ischar(wavelet_typNums)
                    switch wavelet_typNums
                        case {'integer','real','string'}
                        otherwise
                            err = 1;
                            msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WavTypeNum');
                    end
                else
                    err = 1;
                    msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WavTypeNum');
                end
                
            else
                err = 1;
                msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WavNum');
            end
        end
        
        if err==0
            wavelet_File = varargin{5};
            if isempty(wavelet_File)
                err = 1;
            elseif strfind(wavelet_File,'.mat')
                
            else
                wavelet_File = deblankl(wavelet_File);
                ind = strfind(wavelet_File,'.m');
                if ind>0 , wavelet_File = wavelet_File(1:ind-1); end
                if isempty(wavelet_File) , err = 1; end
            end
            if err==1
                msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WavFileNam');
            end
        end
        if err==0
            nbArgIN = length(varargin);
            switch wavelet_Type
                case {1,2}
                    if nbArgIN<6 , wavelet_Bounds = '';
                    else
                        wavelet_Bounds = varargin{6};
                    end
                    
                otherwise
                    if nbArgIN<6
                        err = 1;
                        msg = getWavMSG('Wavelet:moreMSGRF:Invalid_ArgNum');
                    else
                        wavelet_Bounds = varargin{6};
                        if length(wavelet_Bounds)~=2,               err = 1;
                        elseif wavelet_Bounds(1)>wavelet_Bounds(2), err = 1;
                        end
                        if err==1
                            msg = getWavMSG('Wavelet:moreMSGRF:Invalid_WavBounds');
                        end
                    end
            end
        end
        if err
            msg = char(getWavMSG('Wavelet:moreMSGRF:AddNewWav_FAILED'),msg);
            errargt(mfilename,msg,'msg');
            return
        end
        
        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        
        Chrline = findNL('char',winfo);
        beg_fam = 'Family Name : ';
        sep_fam = '------------------------';
        
        wavelet_Type = sprintf('%.0f',wavelet_Type);
        if ~isempty(wavelet_Bounds)
            wavelet_Bounds = [num2str(wavelet_Bounds(1)) ' ' ...
                num2str(wavelet_Bounds(2))];
        end
        
        winfo = [winfo(1:end-1);           Chrline;  ...
            abs(beg_fam'); ...
            abs(family_Name(:));       Chrline;  ...
            abs(family_Short_Name(:)); Chrline;  ...
            abs(wavelet_Type(:));      Chrline;  ...
            abs(wavelet_tabNums(:));   Chrline;  ...
            abs(wavelet_typNums(:));   Chrline;  ...
            abs(wavelet_File(:));      Chrline;  ...
            abs(wavelet_Bounds(:));    Chrline;  ...
            abs(sep_fam');             Chrline   ...
            ];
        
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');
        
    case 'del'
        wavemngr('clear')
        Wavelets_Info = wavemngr('load');

        if isempty(varargin{1})
            error(message('Wavelet:moreMSGRF:Empty_FN_or_FSN'));
        end
        
        name = noblank(varargin{1});
        tmpCell = {Wavelets_Info(:).familyName}';
        i_fam = find(strcmp(name,tmpCell)==1);
        if isempty(i_fam)
            tmpCell = {Wavelets_Info(:).familyShortName}';
            i_fam = find(strcmp(name,tmpCell)==1);
        end

        if isempty(i_fam)
            error(message('Wavelet:moreMSGRF:Invalid_FamSName'));
        elseif i_fam<=NB_FamInWTB
            fn  = Wavelets_Info(i_fam).familyName;
            error(message('Wavelet:moreMSGRF:CannotDel_Wave',fn));
        end

        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        
        str_winfo = char(winfo');
        str_NL    = findNL('string',winfo);
        beg_fam   = 'Family Name : ';
        first     = strfind(str_winfo,beg_fam);
        first     = first(i_fam);
        ind_NL    = strfind(str_winfo,str_NL');
        indexs    = find(ind_NL>first);
        indexs    = ind_NL(indexs(1:nb_InfoByWave+1));
        last      = indexs(nb_InfoByWave+1)+length(str_NL)-1;
        
        winfo(first:last) = [];
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');
        
    case 'restore'
        wavemngr('clear')
        if nargin==1
            fid = fopen(sav_file);
            if fid==-1 , fid = fopen(asc_ini_file); end
        else
            fid = fopen(asc_ini_file);
        end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');
        
    case 'rescue'
        famtype = ...
            {...
            1, 'Haar',         'haar',  1;
            2, 'Daubechies',   'db',    1;
            3, 'Symlets',      'sym',   1;
            4, 'Coiflets',     'coif',  1;
            5, 'BiorSplines',  'bior',  2;
            6, 'ReverseBior',  'rbio',  2;
            7, 'Meyer',        'meyr',  3;
            8, 'DMeyer',       'dmey',  1;
            9, 'Gaussian',     'gaus',  4;
            10, 'Mexican_hat',  'mexh',  4;
            11, 'Morlet',       'morl',  4;
            12, 'Complex Gaussian',   'cgau',  5;
            13, 'Shannon',            'shan',  5;
            14, 'Frequency B-Spline', 'fbsp',  5;
            15, 'Complex Morlet',     'cmor',  5;
            16, 'Fejer-Korovkin', 'fk', 1;
            17, 'Best-localized Daubechies', 'bl',1;
            18, 'Morris minimum-bandwidth', 'mb',1;     
            19, 'Beylkin',          'beyl', 1;                
            20, 'Vaidyanathan', 'vaid', 1;
            21 'Han linear-phase moments', 'han', 1;            
            };
        
        nums = ...
            {...
            '';
            '1 2 3 4 5 6 7 8 9 10 **';
            '2 3 4 5 6 7 8 **';
            '1 2 3 4 5';
            '1.1 1.3 1.5 2.2 2.4 2.6 2.8 3.1 3.3 3.5 3.7 3.9 4.4 5.5 6.8';
            '1.1 1.3 1.5 2.2 2.4 2.6 2.8 3.1 3.3 3.5 3.7 3.9 4.4 5.5 6.8';
            '';
            '';
            '1 2 3 4 5 6 7 8';
            '';
            '';
            '1 2 3 4 5 6 7 8';
            '1-1.5 1-1 1-0.5 1-0.1 2-3 **';
            '1-1-1.5 1-1-1 1-1-0.5 2-1-1 2-1-0.5 2-1-0.1 **';
            '1-1.5 1-1 1-0.5 1-1 1-0.5 1-0.1 **';
            '4 6 8 14 18 22';
            '7 9 10';
            '4.2 8.2 8.3 8.4 10.3 12.3 14.3 16.3 18.3 24.3 32.3';
            '';
            '';
            '2.3 3.3 4.5 5.5'
            };
        
        typNums = ...
            {...
            'no';
            'integer';
            'integer';
            'integer';
            'real';
            'real';
            'no';
            'no';
            'integer';
            'no';
            'no';
            'integer';
            'string';
            'string';
            'string';
            'integer'
            'integer';
            'real';
            'no';
            'no';
            'real'
            };
        
        files = ...
            {...
            'dbwavf';
            'dbwavf';
            'symwavf';
            'coifwavf';
            'biorwavf';
            'rbiowavf';
            'meyer';
            'dmey.mat';
            'gauswavf';
            'mexihat';
            'morlet'
            'cgauwavf';
            'shanwavf';
            'fbspwavf';
            'cmorwavf';
            'fejerkorovkin';
            'blscalf';
            'mbscalf';
            'beyl.mat';
            'vaid.mat';
            'hanscalf'
            };
        
        bounds = ...
            {...
            [];
            [];
            [];
            [];
            [];
            [];
            [-8 8];
            [];
            [-5 5];
            [-8 8];
            [-8 8];
            [-5 5];
            [-20 20];
            [-20 20];
            [-8 8];
            [];
            [];
            [];
            [];
            [];
            []
            };
        
        nbfam   = size(famtype,1);
        tabNums = cell(nbfam,1);
        for k = 1:nbfam
            tabNums{k} = '';
            s = deblank(nums{k});
            if ~isempty(s)
                I = find(isspace(s));
                i_beg = 1;
                for j = 1:length(I)
                    i_end = I(j)-1;
                    ss = deblank(s(i_beg:i_end));
                    if ~isempty(ss)
                        tabNums{k} = char(tabNums{k},ss);
                    end
                    i_beg = i_end+2;
                end
                ss = deblank(s(i_beg:end));
                tabNums{k} = char(tabNums{k},ss);
            end
            if isempty(tabNums{k}) , tabNums{k} = 'no'; end
        end
        
        varargout{1} = ...
            struct(...
            'index',           famtype(:,1), ...
            'familyName',      famtype(:,2), ...
            'familyShortName', famtype(:,3), ...
            'type',            famtype(:,4), ...
            'tabNums',         tabNums,      ...
            'typNums',         typNums,      ...
            'file',            files,        ...
            'bounds',          bounds        ...
            );
        
    otherwise
        error(message('Wavelet:moreMSGRF:Unknown_Opt'));
end

%----------------------------------%
% Internal Function(s)             %
%----------------------------------%
function nl = findNL(opt,txt)
%FINDNL Find New Line char or string.

ind10 = find(txt==10,1);
ind13 = find(txt==13,1);
if isempty(ind13) 
    nl = 10;
elseif isempty(ind10)
    nl = 13;
else
    nl = [13;10];
end
if isequal(opt,'string')
    nl = char(nl);
end
if size(txt,2)>1 , nl = nl'; end
%----------------------------------%
function s = noblank(x)
%NOBLANK Removes blanks in a string.

if ~isempty(x)
    s = x(x~=' ' & x~=0);
else
    s = '';
end
%----------------------------------%
