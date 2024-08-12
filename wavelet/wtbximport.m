function varargout = wtbximport(option,varargin) %#ok<VANUS>
%WTBXIMPORT Import variable from the workspace

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Feb-2007.
%   Last Revision: 04-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2013/08/23 23:45:36 $

    option = lower(option);
    nbOUT = nargout;
   
    switch option
        case {'cfs1d','dec1d','cfs2d','dec2d','decwp1d','decwp2d',...
                'mdec1d','nwav','reg'}
            OUT = ImportVAR_PROC_1(option);
            
        case {'dw1d','dw2d','wp1d','wp2d','1d','2d','1d_im',...
                'wmul','mdw1d','part','mdwt2','3d'}
            OUT = ImportVAR_PROC_2(option);
    end
    varargout(1:nbOUT) = OUT(1:nbOUT);
end  % END wtbximport


%==========================================================================
function argOUT = ImportVAR_PROC_1(option)

    workspace_vars = evalin('base','whos');
    num_of_vars = length(workspace_vars);
    kept_VAR = false(1,num_of_vars);
    switch option
        case 'cfs1d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_cfs1d');
            FN = {'longs','coefs'};

        case 'dec1d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_dec1d');
            FN = {'longs','coefs','data_name','wave_name'};

        case 'cfs2d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_cfs2d');
            FN = {'coefs','sizes'};

        case 'dec2d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_dec2d');
            FN = {'coefs','sizes','wave_name'};

        case 'decwp1d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_decwp1d');
            FN = {'tree_struct','data_name'};

        case 'decwp2d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_decwp2d');
            FN = {'tree_struct','data_name'};

        case 'mdec1d'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_mdec1d');
            FN = {'dirDec','level','wname','dwtFilters','dwtEXTM','dwtShift', ...
                  'dataSize','ca','cd'};

        case 'nwav'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_nwav');
            FN = {'X','Y'};

        case 'reg'
            DlgName = getWavMSG('Wavelet:divGUIRF:Import_DLG_reg');
            FN = {'xdata','ydata'};
    end

    for k=1:num_of_vars
        var_struct = workspace_vars(k);
        true_or_false = strcmpi(var_struct.class,'struct');
        if true_or_false
            input_VAL = evalin('base',sprintf('%s;',var_struct.name));
            kept_VAR(k) = all(isfield(input_VAL,FN));
        end
    end

    workspace_vars = workspace_vars(kept_VAR);
    num_of_vars = length(workspace_vars);

    okVAR = false;
    argOUT = {okVAR,[],[]};
    if num_of_vars>0
        [all_var_names{1:num_of_vars}] = deal(workspace_vars.name);
        [numVAR,okVAR] = listdlg('PromptString',...
               getWavMSG('Wavelet:commongui:Select_to_Import'),...
            'SelectionMode','single', ...
            'OKString',getWavMSG('Wavelet:commongui:Str_OK'), ...
            'CancelString',getWavMSG('Wavelet:commongui:Str_Cancel'), ...            
            'ListString',all_var_names, ...
            'Name',DlgName,'ListSize',[180 100]);
    else
        listdlg('PromptString',getWavMSG('Wavelet:commongui:Select_to_Import'),...
            'SelectionMode','single',...
            'OKString',getWavMSG('Wavelet:commongui:Str_Close'), ...
            'CancelString',getWavMSG('Wavelet:commongui:Str_Cancel'), ...
            'ListString',getWavMSG('Wavelet:commongui:Str_Nodata'), ...
            'Name',DlgName,'ListSize',[180 100]);
        okVAR = false;
    end
    if okVAR
        argOUT{2} = evalin('base',sprintf('%s;',workspace_vars(numVAR).name));
        argOUT{3} = workspace_vars(numVAR).name;
    end
    argOUT{1} = okVAR;
end
%==========================================================================


%==========================================================================
function argOUT = ImportVAR_PROC_2(option)
%  The user may also specify a colormap either by entering a valid MATLAB
%  expression or opening a separate dialog box.
%  
%  The selected image data, colormap data, and their variable names are returned
%  in IMAGE_DATA, CMAP_DATA, IMAGE_VAR_NAME and CMAP_VAR_NAME.  If the user
%  closes the dialog or presses the Cancel button, USER_CANCELED will return
%  TRUE.  Otherwise USER_CANCELED will return FALSE.
%
%  The listed workspace variables are filtered based on the selection in the
%  "Filter" drop-down menu.  The drop-down menu choices are:
%  
%         All           variables that qualify as binary, intensity or truecolor
%         Binary        M-by-N logical variables
%         Indexed       M-by-N variables of *standard types with integer values
%         Intensity     M-by-N variables of *standard types and int16
%         Truecolor     M-by-N-by-3 variables of *standard types and int16
%
%  The *standard supported MATLAB classes (types) for image data are "double",
%  "single", "uint8", "uint16", "int16".  The exceptions are binary images that
%  are logical types and indexed images that do not supported int16 types.

% Check inputs
switch option
    case 'dw1d' ,   data_type = '1d';
    case 'dw2d' ,   data_type = '2d';
    case 'wp1d' ,   data_type = 'wp1d';
    case 'wp2d' ,   data_type = 'wp2d';
    case '1d'   ,   data_type = '1d';
    case '2d'   ,   data_type = '2d';
    case '1d_im' ,  data_type = '1d_im';
    case 'wmul' ,   data_type = 'wmul';
    case 'mdw1d' ,  data_type = 'mdw1d';
    case 'mdwt2' ,  data_type = 'mdwt2';
    case '3d' ,     data_type = '3d';            
    case 'part' ,   data_type = 'part';
    case 'reg' ,    data_type = 'reg';
end
% Initialize 
numPan = 0;
namePan  = '';
% Output variables for function scope
loaded_data = [];
data_name = '';
concatSelect = 'col';
cmap_data = [];
cmap_name = '';
user_canceled = true;

hImportFig = figure(...
    'WindowStyle','modal',...
    'Toolbar','none',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'IntegerHandle','On',...
    'Tag','wtbx_ImportFromWS',...
    'Visible','On',...
    'HandleVisibility','Callback',...
    'Name',getWavMSG('Wavelet:commongui:Lab_Import'),...
    'Resize','On');

fig_height = 360;
fig_width  = 300;
fig_size = [fig_width fig_height];
left_margin = 10;
right_margin = 10;
bottom_margin = 10;
spacing = 5;
default_panel_width = fig_width - left_margin -right_margin;
button_size = [80 25];
b_type = 'none';
% b_type = 'etchedin';
last_selected_value = [];

% Set Figure Position.
%---------------------
old_units = get(0,'Units');
set(0,'Units','Pixels');
screen_size = getMonitorSize;
set(0,'Units', old_units);
lower_left_pos = 0.5 * (screen_size(3:4) - fig_size);
set(hImportFig,'Position',[lower_left_pos fig_size]);

% Get workspace variables and store variable names for
% accessibility in nested functions
workspace_vars = evalin('base','whos');
num_of_vars = length(workspace_vars);
[all_var_names{1:num_of_vars}] = deal(workspace_vars.name);

custom_bottom_margin = fig_height - 50;
custom_top_margin = 10;
IndexedImageOnly = wtbxmngr('get','IndexedImageOnly');

switch data_type
    % var_type_str = {... , 'All (M-by-N, M-by-N-by-3)'}
    % pan_type_str = {... , 'All'};
    case '1d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_1'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_2')};
        pan_type_str = {'1D','2D_Concat'};
        
    case '1d_im'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_3'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_4')};
        pan_type_str = {'1D_Im','2D_Concat'};
                
    case '2d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_5'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_6')};
        pan_type_str = {'2D','RGB'};
        if IndexedImageOnly  
            var_type_str(2) = []; pan_type_str(2) = [];
        end
        
    case 'wp1d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_1'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_2'),... 
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_7')};
        pan_type_str = {'1D','2D_Concat','WPT1D'};
        
    case 'wp2d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_8'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_6'), ...            
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_9')};
        pan_type_str = {'2D','RGB','WPT2D'};
        if IndexedImageOnly
            var_type_str(2) = []; pan_type_str(2) = [];
        end
        
    case 'mdw1d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_8'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_10')};
        pan_type_str = {'2D','Mdwtdec'};
        
    case 'wmul'
        var_type_str = {getWavMSG('Wavelet:moreMSGRF:Import_VAR_11','<')};
        pan_type_str = {'WMUL'};
        
    case 'part'
        var_type_str = {getWavMSG('Wavelet:moreMSGRF:Import_VAR_12')};
        pan_type_str = {'Part'};
        
    case 'mdwt2'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_8'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_13')};
        pan_type_str = {'3D','AllMore'};
 
    case '3d'
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_14'), ...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_13')};
        pan_type_str = {'3D','AllMore'};
        
    otherwise
        var_type_str = {...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_15'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_16'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_17'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_18'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_19'),...
            getWavMSG('Wavelet:moreMSGRF:Import_VAR_20')};
        pan_type_str = ...
            {'All','Binary','Indexed','Intensity','RGB','Decompositions'};
end


num_of_panels = length(pan_type_str);
hFilterPanel = createFilterMenu;
hCMapPanelObjs = [];

custom_bottom_margin = 10;
custom_top_margin = fig_height - custom_bottom_margin - button_size(2);
createButtonPanel;

custom_bottom_margin = custom_bottom_margin + 20 + 2*spacing;
custom_top_margin = 50 + 2*spacing;
display_panels = zeros(1,num_of_panels);
for k = 1:num_of_panels
    display_panels(k) = createImportPanel(pan_type_str{k});
end

% force to run callback after creation to do some filtering
hAllList = findobj(display_panels(1),'Tag','allList');
if ~isempty(get(hAllList,'String')) , listSelected(hAllList,[]); end

set(display_panels(1),'Visible','on');
all_list_boxes = findobj(hImportFig,'Type','uicontrol','Style','listbox');
set(all_list_boxes,'BackgroundColor','white');
set(hImportFig,'Visible','on');
set(wfindobj(hImportFig),'Units','normalized')

% This blocks until the user explicitly closes the tool.
uiwait(hImportFig);

% Outputs
ok_data = ~user_canceled;
switch data_type
    case '1d'
        if ok_data
            loaded_data = double(loaded_data);
            if isequal(numPan,2) , concat2Ddata; end
        end
        sigInfos = get_sigInfos;
        argOUT = {sigInfos,loaded_data,ok_data};        
    
    case '1d_im'
        if ok_data
            if isequal(numPan,2) , concat2Ddata; end
        end        
        sigInfos = get_sigInfos;
        argOUT = {sigInfos,loaded_data,ok_data};
        
    case 'wp1d'
        if ok_data
            switch numPan
                case {3,4}
                otherwise , loaded_data = double(loaded_data);
            end
            if isequal(numPan,2) , concat2Ddata; end
            sigInfos = get_sigInfos;
        else
            sigInfos = [];
        end
        argOUT = {sigInfos,loaded_data,ok_data};
 
    case {'2d','wp2d'}
        if ok_data
            loaded_data = double(loaded_data);
            conv2BW = IndexedImageOnly || (strncmpi(namePan,'Two-Dim',7));            
            if conv2BW && length(size(loaded_data))==3
                loaded_data = ...
                    0.299*loaded_data(:,:,1) + ...
                    0.587*loaded_data(:,:,2) + ...
                    0.114*loaded_data(:,:,3);
            end
        end
        imgInfos = get_imgInfos;
        argOUT = {imgInfos,loaded_data,ok_data};
        
    case 'wmul'
        if size(loaded_data,2)>9 , loaded_data = loaded_data'; end
        argOUT = {loaded_data,data_name,ok_data};
        
    case 'mdw1d'
        argOUT = {loaded_data,data_name,ok_data};

    case 'part'
        argOUT = {loaded_data,data_name,ok_data};

    case 'mdwt2'
        imgInfos = get_imgInfos;
        argOUT = {imgInfos,loaded_data,ok_data};
        
    case '3d'
        imgInfos = get_imgInfos;
        argOUT = {imgInfos,loaded_data,ok_data};
        
    otherwise
        argOUT = {...
            user_canceled,loaded_data,data_name,cmap_data,cmap_name};
end

%--------------------------------------------------------------------------
    function pos = getPanelPos
        % Returns the panel Position based on the custom_bottom_margin
        % and custom_top_margin.  Useful for layout management
        height = fig_height - custom_bottom_margin - custom_top_margin;
        pos = [left_margin, custom_bottom_margin, default_panel_width, height];
    end
%--------------------------------------------------------------------------
    function showPanel(src,evt) %#ok<INUSD>
        % Makes the panel associated with the selected image type visible
        ind = get(src,'Value');
        hRad = findobj(hImportFig,'Tag','Rad_Concat');
        hTxt = findobj(hImportFig,'Tag','Txt_Concat');
        panTag = get(display_panels(ind),'Tag');
        if strcmpi(panTag,'2d_concatPanel')
            vis = 'On'; 
        else 
            vis = 'Off';
        end
        set([hRad;hTxt],'Visible',vis);
        set(display_panels(ind),'Visible','on');
        set(display_panels(ind ~= 1:num_of_panels),'Visible','off');

        % if image is rgb disable the colormap selection button
        is_rgb_panel = (ind == 4);
        disableCmapForRGBVar(is_rgb_panel);
    end % showPanel
%--------------------------------------------------------------------------
    function RadSelect(src,evt) %#ok<INUSD>
        hRad = findobj(hImportFig,'Tag','Rad_Concat');
        idx = find(src==hRad);
        set(hRad(idx),'Value',1);
        set(hRad(3-idx),'Value',0);
        concatSelect = lower(get(hRad(idx),'String'));
    end % radSelect
%--------------------------------------------------------------------------
    function hPanel = createFilterMenu
        % Creates the image type selection panel
        panelPos = getPanelPos;
        hPanel = uipanel('Parent',hImportFig,...
            'Units','Pixels',...
            'Tag','filterPanel',...
            'BorderType',b_type,...
            'Position',panelPos);
        setChildColorToMatchParent(hPanel, hImportFig);
        
        hFilterLabel = uicontrol('Parent',hPanel,...
            'Style','Text',...
            'String',getWavMSG('Wavelet:commongui:Str_Filter'),...
            'HorizontalAlignment','left',...
            'Units','pixels');

        label_extent = get(hFilterLabel,'extent');
        posY = bottom_margin;
        label_position = [left_margin, posY, label_extent(3:4)];
        set(hFilterLabel,'Position',label_position);
        setChildColorToMatchParent(hFilterLabel,hPanel);

        max_width = ...
            panelPos(3)-left_margin-right_margin-label_extent(3)-spacing;
        pmenu_width = min([panelPos(3)-label_extent(3)-left_margin*2,...
            max_width]);

        pmenu_pos = [left_margin + label_extent(3) + spacing,...
            posY,pmenu_width,20];

        hFilterMenu = uicontrol('Parent',hPanel,...
            'Style','popupmenu',...
            'Tag','filterPMenu',...
            'Units','pixels',...
            'Callback',@showPanel,...
            'String',var_type_str,...
            'Position',pmenu_pos);
        setChildColorToMatchParent(hFilterMenu,hPanel);

        if ispc
            % Sets the background color for the popup menu to be white
            % This matches with how the imgetfile dialog looks like
            set(hFilterMenu,'BackgroundColor','white');
        end
        
        posFilter = hPanel.Position;
        xLeft = posFilter(1)+ posFilter(3)/6;
        yLow  = posFilter(2)-15;
        width = 80;
        dy = 2;
        posTxt = [xLeft yLow width 20-2*dy];
        posRad = [xLeft+width+10 yLow 50 20];
        htxtRad = uicontrol('Parent',hImportFig,...
            'Style','text',...
            'Units','pixels',...
            'Visible','Off', ...
            'Position',posTxt, ...
            'HorizontalAlignment','Center',...
            'String',getWavMSG('Wavelet:commongui:Str_Concatenated_by'), ...
            'Tag','Txt_Concat' ...
        );
        setChildColorToMatchParent(htxtRad,hPanel);
        hRad = uicontrol('Parent',hImportFig,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Visible','Off', ...
            'Position',posRad, ...
            'HorizontalAlignment','Center',...
            'Callback',@RadSelect,...
            'Value',1, ...
            'String',getWavMSG('Wavelet:commongui:Str_Import_COL'), ...
            'Tag','Rad_Concat' ...
        );
        setChildColorToMatchParent(hRad,hPanel);
        posRad(1) = posRad(1) + posRad(3) + 5;
        hRad = uicontrol('Parent',hImportFig,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Visible','Off', ...            
            'Position',posRad, ...
            'HorizontalAlignment','Center',...
            'Callback',@RadSelect,... 
            'Value',0, ...            
            'String',getWavMSG('Wavelet:commongui:Str_Import_ROW'),...
            'Tag','Rad_Concat' ...
            );
        setChildColorToMatchParent(hRad,hPanel);
        
    end % createFilterMenu
%--------------------------------------------------------------------------
    function hPanel = createImportPanel(var_type)
        % Panel that displays all qualifying workspace variables
        panelPos = getPanelPos;
        hPanel = uipanel('Parent',hImportFig,...
            'Tag',sprintf('%sPanel',lower(var_type)),...
            'Units','pixels',...
            'BorderType',b_type,...
            'Position',panelPos,...
            'Visible','off');
        setChildColorToMatchParent(hPanel,hImportFig);
        hLabel = uicontrol('Parent',hPanel,...
            'Style','text',...
            'Units','pixels',...
            'HorizontalAlignment','left',...
            'String',getWavMSG('Wavelet:commongui:Str_Variables'));
        setChildColorToMatchParent(hLabel,hPanel);

        label_extent = get(hLabel,'Extent');
        label_posX = left_margin;
        label_posY = panelPos(4) - label_extent(4) - spacing;
        label_width = label_extent(3);
        label_height = label_extent(4);
        label_position = [label_posX label_posY label_width label_height];
        set(hLabel,'Position',label_position);

        cmap_panel_height = 0;
        hVarList = uicontrol('Parent',hPanel,...
            'Style','listbox',...
            'fontname','FixedWidth',...
            'Value',1,...
            'Units','pixels',...
            'Tag',sprintf('%sList',lower(var_type)));
        setChildColorToMatchParent(hVarList,hPanel);
        list_posX = left_margin;
        list_posY = bottom_margin + cmap_panel_height;
        list_width = panelPos(3) - 2*list_posX;
        list_height = panelPos(4) - list_posY - label_height - spacing;
        list_position = [list_posX list_posY list_width list_height];

        set(hVarList,'Position',list_position);
        set(hVarList,'Callback',@listSelected);
        
        varInd = filterWorkspaceVars(workspace_vars,var_type);
        displayVarsInList(workspace_vars(varInd),hVarList);

    end % createImportPanel

    function listSelected(src,evt) %#ok<INUSD>
        % callback for the list boxes
        % we disable the colormap panel controls for an RGB image
        ind = get(src,'Value');
        list_str = get(src,'String');
        if isempty(list_str)
            return
        else
            sel_str = list_str{ind};
            sel_str = strtok(sel_str);
            % get index of specified variable from the list of
            % workspace variables
            var_ind = strcmp(sel_str,all_var_names);

            % get the size off the variable
            tmp_size = workspace_vars(var_ind).size;
            is_rgb_var = (length(tmp_size) == 3 && tmp_size(3) == 3);
            disableCmapForRGBVar(is_rgb_var);
        end

        double_click = strcmp(get(hImportFig,'SelectionType'),'open');
        clicked_same_list_item = last_selected_value == ind;

        if double_click && clicked_same_list_item && getVars
            user_canceled = false;
            close(hImportFig);
        else
            set(hImportFig,'SelectionType','normal');
        end

        last_selected_value = ind;

    end % listSelected

%--------------------------------------------------------------------------
    % panel containing the OK and Cancel buttons
    function createButtonPanel 
        panelPos = getPanelPos;
        hButtonPanel = uipanel('Parent',hImportFig,...
            'Tag','buttonPanel',...
            'Units','pixels',...
            'Position',panelPos,...
            'BorderType',b_type);
         setChildColorToMatchParent(hButtonPanel,hImportFig);

        % add buttons
        button_strs_n_tags = { ...
            getWavMSG('Wavelet:commongui:Str_OK'),'okButton'; ...
            getWavMSG('Wavelet:commongui:Str_Cancel'),'cancelButton'};
        num_of_buttons = length(button_strs_n_tags);
        button_spacing = (panelPos(3)-...
            (num_of_buttons * button_size(1)))/(num_of_buttons+1);
        posX = button_spacing;
        posY = 0;
        buttons = zeros(num_of_buttons,1);

        for n = 1:num_of_buttons
            buttons(n) = uicontrol('Parent',hButtonPanel,...
                'Style','pushbutton',...
                'String',button_strs_n_tags{n,1},...
                'Tag',button_strs_n_tags{n,2});
            setChildColorToMatchParent(buttons(n), hButtonPanel);
            set(buttons(n),'Position',[posX, posY, button_size]);
            set(buttons(n),'Callback',@doButtonPress);
            posX = posX + button_size(1) + button_spacing;
        end

    end % createButtonPanel
%--------------------------------------------------------------------------
    % call back function for the OK and Cancel buttons
    function doButtonPress(src,evt) %#ok<INUSD>
        tag = get(src,'Tag');
        switch tag
            case 'okButton'
                if getVars
                    user_canceled = false;
                    close(hImportFig);
                end

            case 'cancelButton'
                data_name = '';
                cmap_name = '';
                close(hImportFig);
        end
    end % doButtonPress
%--------------------------------------------------------------------------
    function status = getVars

        SUCCESS = true;
        FAILURE = false;
        status  = SUCCESS; %#ok<NASGU>

        % get the listbox in the active display panel
        var_type_menu = findobj(hFilterPanel,'Tag','filterPMenu');
        var_type_ind = get(var_type_menu,'Value');
        hVarList = findobj(display_panels(var_type_ind),'Type','uicontrol',...
            'Style','listbox');
        list_str = get(hVarList,'String');
        is_indexed_image = strcmpi('indexedList',get(hVarList,'Tag'));

        % return if there are no variables listed in current panel
        if isempty(list_str)
            hAllVarList = findobj(display_panels(1),...
                'Type','uicontrol','Style','listbox');
            all_str = get(hAllVarList,'String');
            if isempty(all_str)
                error_str = getWavMSG('Wavelet:commongui:Err_Import_1');
            else
                error_str = getWavMSG('Wavelet:commongui:Err_Import_2');
            end
            errordlg(error_str);
            status = FAILURE;
            return;
        end
        ind = get(hVarList,'Value');
        data_name = strtok(list_str{ind});
        
        if ~isempty(hCMapPanelObjs)
            % see if a colormap string has been specified
            cmap_str = get(hCMapPanelObjs(1),'String');
            colormap_is_specified = ~isempty(cmap_str);
            if colormap_is_specified
                % a colormap was specified and the image is not rgb or 
                % binary check if the variable or function indeed exists
                [cmap_data,eval_passed] = evaluateVariable(cmap_str);
                status = eval_passed;
                if ~eval_passed , return; end
                sz = size(cmap_data);
                if (length(sz) ~= 2 || sz(2) ~= 3)
                    str1 = 'does not qualify as a colormap. ';
                    str2 = 'Consider using the colormap selection tool';
                    error_str = sprintf('%s %s %s',cmap_str,str1, str2);
                    errordlg(error_str);
                    status = FAILURE;
                    return;
                end
                cmap_name = cmap_str;
            elseif is_indexed_image
                % we open an indexed image with no colormap as a grayscale
                % image
                cmap_data = gray(256);
            end
        end
        [loaded_data,eval_passed] = evaluateVariable(data_name);
        status = eval_passed;
        hFilterMenu = findobj(hImportFig,'Tag','filterPMenu');
        numPan  = get(hFilterMenu,'Value');
        lstMenu = get(hFilterMenu,'String');
        namePan = lstMenu{numPan};
        
    end % getVars
%--------------------------------------------------------------------------
    function disableCmapForRGBVar(set_enable_off)
        % disables the colormap panel contents 
        % ("choose colormap" button and edit box)
        % if the input variable name qualifies as an RGB or Binary image.
        if isempty(hCMapPanelObjs) , return; end
        if set_enable_off
            set(hCMapPanelObjs,'Enable','off');
            set(hCMapPanelObjs(1),'BackgroundColor',[0.72 0.72 0.72]);
        else
            set(hCMapPanelObjs,'Enable','on');
            set(hCMapPanelObjs(1),'BackgroundColor','white');
        end

    end % disableCmapForRGBAndBinaryVar
%--------------------------------------------------------------------------
    function varargout = setChildColorToMatchParent(child,parent)
        if strcmp(get(parent,'Type'),'figure')
            background = get(parent,'Color');
        else
            background = get(parent,'BackgroundColor');
        end
        set(child,'BackgroundColor',background);
        if nargout > 0
            varargout{1} = background;
        end
    end % setChildColorToMatchParent
%--------------------------------------------------------------------------
  function concat2Ddata
      switch concatSelect
          case 'col'
              loaded_data = loaded_data(:);
          case 'row'
              loaded_data = loaded_data';
              loaded_data = loaded_data(:)';
      end
  end
%--------------------------------------------------------------------------
  function sigInfos = get_sigInfos
      if ~user_canceled
          sigInfos = struct('pathname','','filename','','filesize',0,...
              'name',data_name,'size',length(loaded_data));
      else
          sigInfos = [];
      end
  end
%--------------------------------------------------------------------------
  function imgInfos = get_imgInfos
      if ~user_canceled
          siz = size(loaded_data);
          siz([1 2]) = siz([2 1]);
          imgInfos = struct('pathname','','filename','','filesize',0,...
              'name',data_name,'true_name',data_name, ...
              'type','mat','self_map',1, ...
              'size',siz);
      else
          imgInfos = [];
      end
  end
%--------------------------------------------------------------------------
end  % wtbxgetvar
%==========================================================================

%==========================================================================
function [out,eval_passed] = evaluateVariable(var_name)
    eval_passed = true;
    try 
        out = evalin('base',sprintf('%s;',var_name));
    catch ME
        out = [];
        eval_passed = false;
        errordlg(ME.message)
        return;
    end
end % evaluateVariable
%==========================================================================


%==========================================================================
function displayVarsInList(ws_vars,hListBox)
%displayVarsInList Displays the workspace variable structure in a list box.
%	displayVarsInList(HLISTBOX, WS_VARS) displays the name, size and class 
%	of thevariables listed in the WS_VARS structure into a listbox with 
%	handle, HLISTBOX.
%
%	displayVarsInList(HLISTBOX,WS_VARS,'name') displays the only name of 
%	the variables listed in WS_VARS into the listbox, HLISTBOX.
    ws_vars = orderfields(ws_vars);
    num_of_vars = length(ws_vars);
    var_str = cell(num_of_vars,1);
    var_names = {ws_vars.name};
    longest_var_name = max(cellfun('length',var_names));
    format1 = sprintf('%%-%ds',longest_var_name+2);
    format2 = sprintf('%%-12s %%-6s');
    format_all = sprintf('%s%s',format1,format2);
    for n = 1:num_of_vars
        if length(ws_vars(n).size) == 3
            formatSize = '%dx%dx%d';
        else
            formatSize = '%dx%d';
        end
        sz_str = sprintf(formatSize,ws_vars(n).size);
        if ws_vars(n).complex
            addStr = 'complex';
        else
            addStr = ws_vars(n).class;
        end
        tmp_str = sprintf(format_all,ws_vars(n).name,sz_str,addStr);
        var_str{n} = sprintf('%s',tmp_str);
    end
    set(hListBox,'String',var_str);
    set(hListBox,'HorizontalAlignment','left');
end % displayVarsInList
%==========================================================================


%==========================================================================
function out = filterWorkspaceVars(ws_vars,filter)
%filterWorkspaceVars Filter workspace variables   
%	OUT = filterWorkspace(WS_VARS FILTER) filters the structure WS_VARS
%	based on FILTER string and returns OUT.
%   WS_VARS contains workspace variables (e.g. WS_VARS = WHOS).  
%   FILTER is astring that can be any of the following values: 
%       'colormap', 'rgb', 'indexed', 'intensity', 'binary', 'all'.  
%   OUT is an array of indices into WS_VARS of variables that match
%	the filter specification.
  
  if ~isstruct(ws_vars)
    error(message('Wavelet:Import:Invalid_Var', mfilename, 'WS_VARS'));
  end
  num_of_vars = length(ws_vars);    
  default_classes = {'double','uint8','uint16','single'};
  out = false(1,num_of_vars);
  
  switch lower(filter)
      case '1d'
          for n = 1:num_of_vars
              if is1D(ws_vars(n),'Re') , out(n) = true; end
          end
          
      case '1d_im'
          for n = 1:num_of_vars
              if is1D(ws_vars(n)) , out(n) = true; end
          end
          
      case '1d_row'
          for n = 1:num_of_vars
              if is1D_Concat(ws_vars(n),'Re','row') , out(n) = true; end
          end

      case '2d_concat'
          for n = 1:num_of_vars
              if is1D_Concat(ws_vars(n),'Re','col') , out(n) = true; end
          end
          
      case '2d'
          for n = 1:num_of_vars
              if is2D(ws_vars(n)) || isRGB(ws_vars(n))
                  out(n) = true; 
              end
          end
          
      case '3d'
          for n = 1:num_of_vars
              if is3D(ws_vars(n)) , out(n) = true; end
          end          

      case 'wpt1d'
          for n = 1:num_of_vars
              if isWPT(ws_vars(n),2) , out(n) = true; end
          end
          
      case 'wpt2d'
          for n = 1:num_of_vars
              if isWPT(ws_vars(n),4) , out(n) = true; end
          end
                    
      case 'wmul'
          for n = 1:num_of_vars
              if isWMUL(ws_vars(n)) , out(n) = true; end
          end
          
      case 'mdwtdec'
          for n = 1:num_of_vars
              if isMultiDEC(ws_vars(n)) , out(n) = true; end
          end
          
      case 'part'
          for n = 1:num_of_vars
              if isPartition(ws_vars(n)) , out(n) = true; end
          end
          
      case 'colormap'
          for n = 1:num_of_vars
              if isColormap(ws_vars(n)) , out(n) = true; end
          end

      case 'rgb'
          for n = 1:num_of_vars
              if isRGB(ws_vars(n)) , out(n) = true; end
          end

      case 'indexed'
          for n = 1:num_of_vars
              if isIndexed(ws_vars(n)) , out(n) = true; end
          end

      case 'intensity'
          for n = 1:num_of_vars
              if isIntensity(ws_vars(n)) , out(n) = true; end
          end

      case 'binary'
          for n = 1:num_of_vars
              if isBinary(ws_vars(n)) , out(n) = true; end
          end

      case 'all'
          for n = 1:num_of_vars
              if isRGB(ws_vars(n)) || isIntensity(ws_vars(n)) || ...
                      isBinary(ws_vars(n)) , out(n) = true; end
          end
          
      case 'allmore'
          for n = 1:num_of_vars
              if isRGB(ws_vars(n)) || isIntensity(ws_vars(n)) || ...
                      isBinary(ws_vars(n)) || isMDWT2(ws_vars(n)) , ...
                      out(n) = true; 
              end
          end
          
  end
  out = find(out==true);
  
  function true_or_false = is1D(var_struct,Attr)
    true_or_false = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2);
    if nargin>1 && isequal(Attr,'Re')
        true_or_false = true_or_false && var_struct.complex==0;
    end
    if ~true_or_false , return; end   
    vs = var_struct.size;
    true_or_false =  length(vs)==2 && min(vs)==1 &&  max(vs)>1;
  end

  function true_or_false = is1D_Concat(var_struct,Attr,direct) %#ok<INUSD>
    true_or_false = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2);
    if ~true_or_false , return; end        
    if isequal(Attr,'Re') , true_or_false = var_struct.complex==0; end
    if ~true_or_false , return; end        
    vs = var_struct.size;    
    true_or_false =  length(vs)==2 && min(vs)>1 &&  max(vs)>1;
  end
  
  function true_or_false = is2D(var_struct)
    true_or_false = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2) && ...
        var_struct.complex==0;
    if ~true_or_false , return; end
    vs = var_struct.size;    
    true_or_false =  length(vs)==2 && min(vs)>1 &&  max(vs)>1;
  end

  function true_or_false = is3D(var_struct)
    true_or_false = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2) && ...
        var_struct.complex==0;
    if ~true_or_false , return; end
    vs = var_struct.size;    
    true_or_false =  length(vs)==3 && min(vs)>4;
  end

  function true_or_false = isWPT(var_struct,order)
    data = evalin('base',sprintf('%s;',var_struct.name));
    true_or_false = isa(data,'wptree') && treeord(data)==order; 
  end

  function true_or_false = isWMUL(var_struct)
    true_or_false = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2) && ...
        var_struct.complex==0;
    if ~true_or_false , return; end
    vs = var_struct.size;    
    true_or_false =  length(vs)==2 && min(vs)>1 &&  max(vs)>1 &&  min(vs)<9;
  end

  function true_or_false = isPartition(var_struct)
    true_or_false = is1D(var_struct,'Re') || is2D(var_struct);
    if true_or_false , return; end
    data = evalin('base',sprintf('%s;',var_struct.name));
    true_or_false = isa(data,'wpartobj');
  end

  function true_or_false = isRGB(var_struct)
    is_M_by_N_by_3 = (length(var_struct.size) == 3 && var_struct.size(end) == 3);
    is_valid_type = any(strcmpi(var_struct.class,[default_classes,'int16']),2);
    true_or_false = is_M_by_N_by_3 && is_valid_type;
  end

  function true_or_false = isMDWT2(var_struct)
    is_M_by_N_by_4 = (length(var_struct.size) == 4 && var_struct.size(3) == 3);
    is_valid_type = any(strcmpi(var_struct.class,[default_classes,'int16']),2);
    true_or_false = is_M_by_N_by_4 && is_valid_type;
  end

  function true_or_false = isColormap(var_struct)
    is_M_by_3 = (length(var_struct.size) == 2 && var_struct.size(end) == 3);
    is_double = strcmpi(var_struct.class,'double');
    true_or_false = is_M_by_3 && is_double;
  end

  function true_or_false = isIndexed(var_struct)
    is_M_by_N = length(var_struct.size) == 2;
    is_float = any(strcmpi(var_struct.class,{'double','single'}),2);
    if is_M_by_N && is_float
      data = evalin('base',sprintf('%s;',var_struct.name));
      is_integer_values = isequal(data,floor(data)) && all(isfinite(data(:)));
      is_all_non_zero = isempty(find(data == 0,1));
      true_or_false = is_integer_values && is_all_non_zero;
    else
      is_valid_type = any(strcmpi(var_struct.class,default_classes),2);
      true_or_false = is_M_by_N && is_valid_type;
    end
  end

  function true_or_false = isIntensity(var_struct)
    is_M_by_N = length(var_struct.size) == 2;
    is_valid_type = ...
        any(strcmpi(var_struct.class,[default_classes,'int16']),2);
    true_or_false = is_M_by_N && is_valid_type;
  end
  
  function true_or_false = isBinary(var_struct)
    is_M_by_N = length(var_struct.size) == 2;
    is_logical  = strcmpi(var_struct.class,'logical');
    true_or_false = is_M_by_N && is_logical;
  end

  function true_or_false = isMultiDEC(var_struct)
    true_or_false = strcmpi(var_struct.class,'struct');
    if true_or_false
        input_VAL = evalin('base',sprintf('%s;',var_struct.name));
        FN    = fieldnames(input_VAL);
        FNdec = {...
            'dirDec';'level';'wname';'dwtFilters';'dwtEXTM'; ...
            'dwtShift';'dataSize';'ca';'cd'};
        true_or_false = isequal(FN,FNdec);
    end
  end

end % filterWorkspaceVars
%==========================================================================
