function [out, multitiff] = uipickfiles(varargin)
%neu
%uipickfiles: GUI program to select files and/or folders.
%
% Syntax:
%   files = uipickfiles('PropertyName',PropertyValue,...)
%
% The current folder can be changed by operating in the file navigator:
% double-clicking on a folder in the list or pressing Enter to move further
% down the tree, using the popup menu, clicking the up arrow button or
% pressing Backspace to move up the tree, typing a path in the box to move
% to any folder or right-clicking (control-click on Mac) on the path box to
% revisit a previously-visited folder.  These folders are listed in order
% of when they were last visited (most recent at the top) and the list is
% saved between calls to uipickfiles.  The list can be cleared or its
% maximum length changed with the items at the bottom of the menu.
% (Windows only: To go to a UNC-named resource you will have to type the
% UNC name in the path box, but all such visited resources will be
% remembered and listed along with the mapped drives.)  The items in the
% file navigator can be sorted by name, modification date or size by
% clicking on the headers, though neither date nor size are displayed.  All
% folders have zero size.
%
% Files can be added to the list by double-clicking or selecting files
% (non-contiguous selections are possible with the control key) and
% pressing the Add button.  Control-F will select all the files listed in
% the navigator while control-A will select everything (Command instead of
% Control on the Mac).  Since double-clicking a folder will open it,
% folders can be added only by selecting them and pressing the Add button.
% Files/folders in the list can be removed or re-ordered.  Recall button
% will insert into the Selected Files list whatever files were returned the
% last time uipickfiles was run.  When finished, a press of the Done button
% will return the full paths to the selected items in a cell array,
% structure array or character array.  If the Cancel button or the escape
% key is pressed then zero is returned.
%
% The figure can be moved and resized in the usual way and this position is
% saved and used for subsequent calls to uipickfiles.  The default position
% can be restored by double-clicking in a vacant region of the figure.
%
% The following optional property/value pairs can be specified as arguments
% to control the indicated behavior:
%
%   Property    Value
%   ----------  ----------------------------------------------------------
%   FilterSpec  String to specify starting folder and/or file filter.
%               Ex:  'C:\bin' will start up in that folder.  '*.txt'
%               will list only files ending in '.txt'.  'c:\bin\*.txt' will
%               do both.  Default is to start up in the current folder and
%               list all files.  Can be changed with the GUI.
%
%   REFilter    String containing a regular expression used to filter the
%               file list.  Ex: '\.m$|\.mat$' will list files ending in
%               '.m' and '.mat'.  Default is empty string.  Can be used
%               with FilterSpec and both filters are applied.  Can be
%               changed with the GUI.
%
%   REDirs      Logical flag indicating whether to apply the regular
%               expression filter to folder names.  Default is false which
%               means that all folders are listed.  Can be changed with the
%               GUI.
%
%   Type        Two-column cell array where the first column contains file
%               filters and the second column contains descriptions.  If
%               this property is specified an additional popup menu will
%               appear below the File Filter and selecting an item will put
%               that item into the File Filter.  By default, the first item
%               will be entered into the File Filter.  For example,
%                   { '*.m',   'M-files'   ;
%                     '*.mat', 'MAT-files' }.
%               Can also be a cell vector of file filter strings in which
%               case the descriptions will be the same as the file filters
%               themselves.
%               Must be a cell array even if there is only one entry.
%
%   Prompt      String containing a prompt appearing in the title bar of
%               the figure.  Default is 'Select files'.
%
%   NumFiles    Scalar or vector specifying number of files that must be
%               selected.  A scalar specifies an exact value; a two-element
%               vector can be used to specify a range, [min max].  The
%               function will not return unless the specified number of
%               files have been chosen.  Default is [] which accepts any
%               number of files.
%
%   Append      Cell array of strings, structure array or char array
%               containing a previously returned output from uipickfiles.
%               Used to start up program with some entries in the Selected
%               Files list.  Any included files that no longer exist will
%               not appear.  Default is empty cell array, {}.
%
%   Output      String specifying the data type of the output: 'cell',
%               'struct' or 'char'.  Specifying 'cell' produces a cell
%               array of strings, the strings containing the full paths of
%               the chosen files.  'Struct' returns a structure array like
%               the result of the dir function except that the 'name' field
%               contains a full path instead of just the file name.  'Char'
%               returns a character array of the full paths.  This is most
%               useful when you have just one file and want it in a string
%               instead of a cell array containing just one string.  The
%               default is 'cell'.
%
% All properties and values are case-insensitive and need only be
% unambiguous.  For example,
%
%   files = uipickfiles('num',1,'out','ch')
%
% is valid usage.

% Version: 1.15, 2 March 2012
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})

multitiff=0;
% Define properties and set default values.
prop.filterspec = '*';
prop.refilter = '';
prop.redirs = false;
prop.type = {};
prop.prompt = 'Select files';
prop.numfiles = [];
prop.append = [];
prop.output = 'cell';
i_frames=[];

% Process inputs and set prop fields.
prop = parsepropval(prop,varargin{:});

% Validate FilterSpec property.
if isempty(prop.filterspec)
	prop.filterspec = '*';
end
if ~ischar(prop.filterspec)
	error('FilterSpec property must contain a string.')
end

% Validate REFilter property.
if ~ischar(prop.refilter)
	error('REFilter property must contain a string.')
end

% Validate REDirs property.
if ~isscalar(prop.redirs)
	error('REDirs property must contain a scalar.')
end

% Validate Type property.
if isempty(prop.type)
elseif iscellstr(prop.type) && isscalar(prop.type)
	prop.type = repmat(prop.type(:),1,2);
elseif iscellstr(prop.type) && size(prop.type,2) == 2
else
	error(['Type property must be empty or a cellstr vector or ',...
		'a 2-column cellstr matrix.'])
end

% Validate Prompt property.
if ~ischar(prop.prompt)
	error('Prompt property must contain a string.')
end

% Validate NumFiles property.
if numel(prop.numfiles) > 2 || any(prop.numfiles < 0)
	error('NumFiles must be empty, a scalar or two-element vector.')
end
prop.numfiles = unique(prop.numfiles);
if isequal(prop.numfiles,1)
	numstr = 'Select exactly 1 file.';
elseif length(prop.numfiles) == 1
	numstr = sprintf('Select exactly %d items.',prop.numfiles);
else
	numstr = sprintf('Select %d to %d items.',prop.numfiles);
end

% Validate Append property and initialize pick data.
if isstruct(prop.append) && isfield(prop.append,'name')
	prop.append = {prop.append.name};
elseif ischar(prop.append)
	prop.append = cellstr(prop.append);
end
if isempty(prop.append)
	file_picks = {};
	full_file_picks = {};
	%dir_picks = dir(' ');  % Create empty directory structure.
	dir_picks = repmat(dir(char(127)),0,1);
elseif iscellstr(prop.append) && isvector(prop.append)
	num_items = length(prop.append);
	file_picks = cell(1,num_items);
	full_file_picks = cell(1,num_items);
	dir_fn = fieldnames(dir(' '));
	dir_picks = repmat(cell2struct(cell(length(dir_fn),1),dir_fn(:)),...
		num_items,1);
	for item = 1:num_items
		if exist(prop.append{item},'dir') && ...
				~any(strcmp(full_file_picks,prop.append{item}))
			full_file_picks{item} = prop.append{item};
			[~,fn,ext] = fileparts(prop.append{item});
			file_picks{item} = [fn,ext];
			temp = dir(fullfile(prop.append{item},'..'));
			if ispc || ismac
				thisdir = strcmpi({temp.name},[fn,ext]);
			else
				thisdir = strcmp({temp.name},[fn,ext]);
			end
			dir_picks(item) = temp(thisdir);
			dir_picks(item).name = prop.append{item};
		elseif exist(prop.append{item},'file') && ...
				~any(strcmp(full_file_picks,prop.append{item}))
			full_file_picks{item} = prop.append{item};
			[~,fn,ext] = fileparts(prop.append{item});
			file_picks{item} = [fn,ext];
			dir_picks(item) = dir(prop.append{item});
			dir_picks(item).name = prop.append{item};
		else
			continue
		end
	end
	% Remove items which no longer exist.
	missing = cellfun(@isempty,full_file_picks);
	full_file_picks(missing) = [];
	file_picks(missing) = [];
	dir_picks(missing) = [];
else
	error('Append must be a cell, struct or char array.')
end

% Validate Output property.
legal_outputs = {'cell','struct','char'};
out_idx = find(strncmpi(prop.output,legal_outputs,length(prop.output)));
if length(out_idx) == 1
	prop.output = legal_outputs{out_idx};
else
	error(['Value of ''Output'' property, ''%s'', is illegal or '...
		'ambiguous.'],prop.output)
end


% Set style preference for display of folders.
%   1 => folder icon before and filesep after
%   2 => bullet before and filesep after
%   3 => filesep after only
folder_style_pref = 1;
fsdata = set_folder_style(folder_style_pref);

% Initialize file lists.
if exist(prop.filterspec,'dir')
	current_dir = prop.filterspec;
	filter = '*';
else
	[current_dir,f,e] = fileparts(prop.filterspec);
	filter = [f,e];
end
if isempty(current_dir)
	current_dir = pwd;
end
if isempty(filter)
	filter = '*';
end
re_filter = prop.refilter;
full_filter = fullfile(current_dir,filter);
network_volumes = {};
[path_cell,new_network_vol] = path2cell(current_dir);
if exist(new_network_vol,'dir')
	network_volumes = unique([network_volumes,{new_network_vol}]);
end
fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
	@(x)file_sort(x,[1 0 0]));
filenames = {fdir.name}';
filenames = annotate_file_names(filenames,fdir,fsdata);

% Initialize some data.
show_full_path = false;
nodupes = false;

% Get history preferences and set history.
history = getpref('uipickfiles','history',...
	struct('name',current_dir,'time',now));
default_history_size = 15;
history_size = getpref('uipickfiles','history_size',default_history_size);
history = update_history(history,current_dir,now,history_size);

% Get figure position preference and create figure.
gray = get(0,'DefaultUIControlBackgroundColor');

fig_pos = [0 0 740 580];
fig = figure('Position',fig_pos,...
	'Color',gray,...
	'MenuBar','none',...
	'WindowStyle','modal',...
	'Resize','off',...
	'NumberTitle','off',...
	'Name',prop.prompt,...
	'IntegerHandle','off',...
	'CloseRequestFcn',@cancel,...
	'CreateFcn',{@movegui,'center'},...
	'KeyPressFcn',@keypressmisc,...
	'Visible','off');


% Set system-dependent items.
if ismac
	set(fig,'DefaultUIControlFontName','Lucida Grande')
	set(fig,'DefaultUIControlFontSize',9)
	sort_ctrl_size = 8;
	mod_key = 'command';
	action = 'Control-click';
elseif ispc
	set(fig,'DefaultUIControlFontName','Tahoma')
	set(fig,'DefaultUIControlFontSize',8)
	sort_ctrl_size = 7;
	mod_key = 'control';
	action = 'Right-click';
else
	sort_ctrl_size = get(fig,'DefaultUIControlFontSize') - 1;
	mod_key = 'control';
	action = 'Right-click';
end

% Create uicontrols.
uicontrol('Style','frame',...
	'Position',[255 260 110 70]);
uicontrol('Style','frame',...
	'Position',[275 135 110 100]);

navlist = uicontrol('Style','listbox',...
	'Position',[10 25 250 305],...
	'String',filenames,...
	'Value',[],...
	'Callback',@clicknav,...
	'KeyPressFcn',@keypressnav,...
	'Max',2);

shift_info_txt = uicontrol('Style','text',...
	'Position',[10 5 350 16],...
	'String','Hold shift or ctrl to select multiple entries. CTRL+F selects all.','HorizontalAlignment','left','FontSize',8);


tri_up = repmat([1 1 1 1 0 1 1 1 1;1 1 1 0 0 0 1 1 1;1 1 0 0 0 0 0 1 1;...
	1 0 0 0 0 0 0 0 1],[1 1 3]);
tri_up(tri_up == 1) = NaN;
tri_down = tri_up(end:-1:1,:,:);
tri_null = NaN(4,9,3);
tri_icon = {tri_down,tri_null,tri_up};
sort_state = [1 0 0];
last_sort_state = [1 1 1];
sort_cb = zeros(1,3);
%
sort_cb(1) = uicontrol('Style','checkbox',...
	'Position',[15 331 70 15],...
	'String','Name',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(1),...
	'CData',tri_icon{sort_state(1)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,1});
sort_cb(2) = uicontrol('Style','checkbox',...
	'Position',[85 331 70 15],...
	'String','Date',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(2),...
	'CData',tri_icon{sort_state(2)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,2});
sort_cb(3) = uicontrol('Style','checkbox',...
	'Position',[155 331 70 15],...
	'String','Size',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(3),...
	'CData',tri_icon{sort_state(3)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,3});

pickslist = uicontrol('Style','listbox',...
	'Position',[380 10 350 230],...
	'String',file_picks,...
	'Callback',@clickpicks,...
	'KeyPressFcn',@keypresslist,...
	'Max',2,...
	'Value',[]);

addbut = uicontrol('Style','pushbutton',...
	'Position',[270 275 80 40],...
	'String','Add',...
	'Enable','off',...
	'fontsize',12,...
	'fontweight','bold',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@add);

removebut = uicontrol('Style','pushbutton',...
	'Position',[290 205 80 20],...
	'String','Remove',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@remove);
moveupbut = uicontrol('Style','pushbutton',...
	'Position',[290 175 80 20],...
	'String','Move Up',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@moveup);
movedownbut = uicontrol('Style','pushbutton',...
	'Position',[290 145 80 20],...
	'String','Move Down',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@movedown);

dir_popup = uicontrol('Style','popupmenu',...
	'Position',[10 350 225 20],...
	'String',path_cell,...
	'Value',length(path_cell),...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@dirpopup);

uparrow = [ ...
	'  0     ';
	' 000    ';
	'00000   ';
	'  0     ';
	'  0     ';
	'  0     ';
	'  000000'];
cmap = NaN(128,3);
cmap(double('0'),:) = [0 0 0];
uparrow_im = ind2rgb(double(uparrow),cmap);
up_dir_but = uicontrol('Style','pushbutton',...
	'Position',[240 350 20 20],...
	'CData',uparrow_im,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@dir_up_one,...
	'ToolTip','Go to parent folder','Visible','on');
if length(path_cell) > 1
	set(up_dir_but','Enable','on')
else
	set(up_dir_but','Enable','off')
end



PIVlab_select = uicontrol('Position',[10 480-26+15 250 15],...
	'Style','radiobutton',...
	'String','Time resolved: [A+B], [B+C], [C+D], ...',...
	'Value',1,...
	'HorizontalAlignment','left',...
	'Callback',@PIVlab_select_Callback,'tooltipstring','Image sequencing style');
PIVlab_select2 = uicontrol('Position',[10 465-27+15 250 15],...
	'Style','radiobutton',...
	'String','Pairwise: [A+B], [C+D], [E+F], ...',...
	'Value',0,...
	'HorizontalAlignment','left',...
	'Callback',@PIVlab_select_Callback2,'tooltipstring','Image sequencing style');
PIVlab_select3 = uicontrol('Position',[10 450-28+15 250 15],...
	'Style','radiobutton',...
	'String','Reference: [A+B], [A+C], [A+D], ...',...
	'Value',0,...
	'HorizontalAlignment','left',...
	'Callback',@PIVlab_select_Callback3,'tooltipstring','Image sequencing style');

%load last sequencing style
try
	load ('PIVlab_settings_default.mat','sequencer');
	if sequencer==0
		set(PIVlab_select, 'Value', 1)
		set(PIVlab_select2, 'Value', 0)
		set(PIVlab_select3, 'Value', 0)
	end
	if sequencer==1
		set(PIVlab_select, 'Value', 0)
		set(PIVlab_select2, 'Value', 1)
		set(PIVlab_select3, 'Value', 0)
	end
	if sequencer==2
		set(PIVlab_select, 'Value', 0)
		set(PIVlab_select2, 'Value', 0)
		set(PIVlab_select3, 'Value', 1)
	end
catch
end
hist_cm = uicontextmenu;
pathbox = uicontrol('Style','edit',...
	'Position',[10 375 250 26],...
	'String',current_dir,...
	'HorizontalAlignment','left',...
	'TooltipString',[action,' to display folder history'],...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@change_path,...
	'UIContextMenu',hist_cm);

uicontrol('Style','text',...
	'Position',[10 401 250 16],...
	'String','Current Folder',...
	'HorizontalAlignment','left',...
	'Fontweight','bold',...
	'TooltipString',[action,' to display folder history'],...
	'UIContextMenu',hist_cm);
%
hist_menus = [];
make_history_cm()

uicontrol('Style','text',...
	'Position',[10 550 260 30],...
	'String','Image Import',...
	'HorizontalAlignment','left','Fontsize',15);
uicontrol('Style','text',...
	'Position',[10 550-30+15 160+50 17],...
	'String','Regular Expression Filter',...
	'HorizontalAlignment','left');
uicontrol('Style','text',...
	'Position',[10 500-15 160+50 17],...
	'String','Image sequencing style:',...
	'Fontweight','bold',...
	'HorizontalAlignment','left');

refilter_ed = uicontrol('Style','edit',...
	'Position',[10 525-15 160 26],...
	'String',re_filter,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@setrefilter);

type_value = 1;
type_popup = uicontrol('Style','popupmenu',...
	'Position',[10 422 250 20],...
	'String','',...
	'Value',type_value,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@filter_type_callback,...
	'Visible','off');
if ~isempty(prop.type)
	set(filter_ed,'String',prop.type{type_value,1})
	setfilspec()
	set(type_popup,'String',prop.type(:,2),'Visible','on')
end

viewfullpath = uicontrol('Style','checkbox',...
	'Position',[620 270 230 20],...
	'String','Show full paths',...
	'Value',show_full_path,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@showfullpath);
remove_dupes = uicontrol('Style','checkbox',...
	'Position',[380 270 230 20],...
	'String','Remove duplicates (as per full path)',...
	'Value',nodupes,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@removedupes);
%%{

%%}
uicontrol('Style','text',...
	'Position',[380 240 350 20],...
	'String','Images selected for import',...
	'HorizontalAlignment','left','fontweight','bold');
uicontrol('Style','pushbutton',...
	'Position',[280 70 80 50],...
	'String','Import',...
	'fontsize',12,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@done,'fontweight','bold','foregroundcolor',[0 0.5 0]);
uicontrol('Style','pushbutton',...
	'Position',[280 30 80 30],...
	'String','Cancel',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@cancel);

% If necessary, add warning about number of items to be selected.
num_files_warn = uicontrol('Style','text',...
	'Position',[620 245 100 16],...
	'String',numstr,...
	'ForegroundColor',[0.8 0 0],...
	'HorizontalAlignment','center',...
	'Visible','on');
if ~isempty(prop.numfiles)
	set(num_files_warn,'Visible','on')
end


ah1 = axes('units', 'pixels', 'Position',[388 308 350 270], 'xtick', [],'ytick',[]);
try
	imshow(imread(fullfile('images','pivlab_logo1.jpg')),'parent',ah1,'interpolation','bilinear');
catch
	imshow(zeros(27,35)+0.75,'parent',ah1);
end

%new folder selection
uicontrol('Style','pushbutton',...
	'Position',[263 350 60 20],...
	'String','Browse...',...
	'Enable','on',...
	'Callback',@selectdire,'tooltipstring','Select directory','fontweight','bold');

uicontrol('Style','pushbutton',...
	'Position',[550 245 65 15],...%[380 240 350 20]
	'String','Recall',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@recall,...
	'ToolTip','Add previously selected items');
try
	hgui=getappdata(0,'hgui');
	setappdata(hgui, 'sequencer', 0); %default style
catch
end


%resize()
% Make figure visible and hide handle.
set(fig,'Visible','on')

% Wait until figure is closed.
uiwait(fig)

% Compute desired output.

switch prop.output

	case 'cell'
		out = full_file_picks;
	case 'struct'
		out = dir_picks(:);
	case 'char'
		out = char(full_file_picks);
	case 'cancel'
		out = 0;
end

% Update history preference.
setpref('uipickfiles','history',history)
if ~isempty(full_file_picks) && ~strcmp(prop.output,'cancel')
	setpref('uipickfiles','full_file_picks',full_file_picks)
end

% Update figure position preference.
setpref('uipickfiles','figure_position',fig_pos)


% ----------------- Callback nested functions ----------------

	function add(varargin)
		values = get(navlist,'Value');
		for i = 1:length(values)
			dir_pick = fdir(values(i));
			pick = dir_pick.name;
			pick_full = fullfile(current_dir,pick);
			dir_pick.name = pick_full;
			if ~nodupes || ~any(strcmp(full_file_picks,pick_full))
				file_picks{end + 1} = pick; %#ok<AGROW>
				full_file_picks{end + 1} = pick_full; %#ok<AGROW>
				dir_picks(end + 1) = dir_pick; %#ok<AGROW>

			end
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',[]);
		else
			set(pickslist,'String',file_picks,'Value',[]);
		end
		set([removebut,moveupbut,movedownbut],'Enable','off');
	end

	function remove(varargin)
		values = get(pickslist,'Value');
		file_picks(values) = [];
		full_file_picks(values) = [];
		dir_picks(values) = [];
		top = get(pickslist,'ListboxTop');
		num_above_top = sum(values < top);
		top = top - num_above_top;
		num_picks = length(file_picks);
		new_value = min(min(values) - num_above_top,num_picks);
		if num_picks == 0
			new_value = [];
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',new_value,...
				'ListboxTop',top)
		else
			set(pickslist,'String',file_picks,'Value',new_value,...
				'ListboxTop',top)
		end
	end



	function selectdire(varargin)
		get(pathbox,'String');
		folder_name = uigetdir(get(pathbox,'String'),'Select folder');
		if folder_name ~= 0
			set(pathbox,'String',folder_name);
			change_path();
		end
	end


	function open(varargin)
		values = get(navlist,'Value');
		if fdir(values).isdir
			set(fig,'pointer','watch')
			drawnow
			% Convert 'My Documents' to 'Documents' when necessary.
			if ispc && strcmp(fdir(values).name,'My Documents')
				if isempty(dir(fullfile(current_dir,fdir(values).name)))
					values = find(strcmp({fdir.name},'Documents'));
				end
			end
			current_dir = fullfile(current_dir,fdir(values).name);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			path_cell = path2cell(current_dir);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
			filenames = {fdir.name}';
			filenames = annotate_file_names(filenames,fdir,fsdata);
			set(dir_popup,'String',path_cell,'Value',length(path_cell))
			if length(path_cell) > 1
				set(up_dir_but','Enable','on')
			else
				set(up_dir_but','Enable','off')
			end

			set(pathbox,'String',current_dir)
			set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
			set(addbut,'Enable','off')
			%			set(openbut,'Enable','off')
			set(fig,'pointer','arrow')
		end
	end

	function clicknav(varargin)
		value = get(navlist,'Value');
		nval = length(value);
		dbl_click_fcn = @add;
		switch nval
			case 0
				%set([addbut,openbut],'Enable','off')
			case 1
				set(addbut,'Enable','on');
				if fdir(value).isdir
					%set(openbut,'Enable','on')
					set(addbut,'Enable','off')
					dbl_click_fcn = @open;
				else
					%set(openbut,'Enable','off')
					try
						warning ('off')
						dir_pick = fdir(value(1));
						pick = dir_pick.name;
						pick_full = fullfile(current_dir,pick);
						%dir_pick.name = pick_full;
						if numel(pick)-strfind(pick,'.b16')==3 %b16 is only grayscale
							temp_img=import.f_readB16(pick_full);
							temp_img=imadjust(temp_img/max(temp_img(:)));
							imshow (temp_img,'parent',ah1);
						else
							temp_img=imread(pick_full);
							imshow(imadjust(temp_img,mean(stretchlim(temp_img),2)),'parent',ah1);
							info = imfinfo(pick_full);
							if isfield(info,'Compression')
								i_compression=info(1).Compression;
							elseif isfield(info,'CodingMethod')
								i_compression=info(1).CodingMethod;
							else
								i_compression='Uncompressed';
							end
							dbl_img=[];
							if isfield(info,'Software')
								 if strncmp (info(1).Software,'PCO_Recorder',10)
									dbl_img='dual shutter';
								end
							end
							i_bits=info(1).BitDepth;
							i_frames=size(info,1);
							if i_frames > 1
								framestring = 'layers';
								multitiff=1;
							else
								framestring = 'layer';
								multitiff=0;
							end
							i_filesize=round(info(1).FileSize/1024/1014,1);
							i_width=info(1).Width;
							i_height=info(1).Height;
							delete(findobj('Tag','fileinfo'));
							text('String',{[num2str(i_width) '*' num2str(i_height) ' - ' num2str(i_bits)  ' bit - ' num2str(i_filesize) ' MB' ],[i_compression ' - ' num2str(i_frames) ' ' framestring, ', ' dbl_img]},'Position',[1 1],'parent',ah1,'HorizontalAlignment','left','VerticalAlignment','top','BackgroundColor','k','Color','w','Margin',0.1,'Clipping','on','LineStyle','none','Interpreter','none','FontSize',8,'Tag','fileinfo')
						end
						ylabel('enhanced image display')
					catch
						%keyboard
					end
					warning ('on')
				end
			otherwise
				set(addbut,'Enable','on')
				%set(openbut,'Enable','off')
		end
		if strcmp(get(fig,'SelectionType'),'open')
			dbl_click_fcn();
		end
	end

	function keypressmisc(h,evt) %#ok<INUSL>
		if strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
			% Escape key means Cancel.
			cancel()
		end
	end

	function keypressnav(h,evt) %#ok<INUSL>
		if length(path_cell) > 1 && strcmp(evt.Key,'backspace') && ...
				isequal(evt.Modifier,cell(1,0))
			% Backspace means go to parent folder.
            dir_up_one()
        elseif strcmp(evt.Key,'f') && isequal(evt.Modifier,{mod_key})
            % Control-F (Command-F on Mac) means select all files.
            value = find(~[fdir.isdir]);
            set(navlist,'Value',value)
        elseif strcmp(evt.Key,'rightarrow') && ...
                isequal(evt.Modifier,cell(1,0))
            % Right arrow key means select the file.
            add()
        elseif strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
            % Escape key means Cancel.
            cancel()
        end
    end

	function keypresslist(h,evt) %#ok<INUSL>
		if strcmp(evt.Key,'backspace') && isequal(evt.Modifier,cell(1,0))
			% Backspace means remove item from list.
			remove()
		elseif strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
			% Escape key means Cancel.
			cancel()
		end
	end

	function clickpicks(varargin)
		value = get(pickslist,'Value');
		if isempty(value)
			set([removebut,moveupbut,movedownbut],'Enable','off')
		else
			set(removebut,'Enable','on')
			if min(value) == 1
				set(moveupbut,'Enable','off')
			else
				set(moveupbut,'Enable','on')
			end
			if max(value) == length(file_picks)
				set(movedownbut,'Enable','off')
			else
				set(movedownbut,'Enable','on')
			end
			try
				pick = file_picks(value(1));
				pick_full = fullfile(current_dir,pick{1,1});
				figure(fig)
				if numel(pick)-strfind(pick,'.b16')==3
					temp_img=import.f_readB16(pick_full);
					temp_img=imadjust(temp_img/max(temp_img(:)));
					imshow (temp_img,'parent',ah1);
				else
					temp_img=imread(pick_full);
					imshow (imadjust(temp_img,mean(stretchlim(temp_img),2)),'parent',ah1);
				end
				ylabel('enhanced image display')
			catch
			end
		end
		if strcmp(get(fig,'SelectionType'),'open')
			remove();
		end
	end
%%{
	function recall(varargin)
		if ispref('uipickfiles','full_file_picks')
			ffp = getpref('uipickfiles','full_file_picks');
		else
			ffp = {};
		end
		for i = 1:length(ffp)
			if exist(ffp{i},'dir') && ...
					(~nodupes || ~any(strcmp(full_file_picks,ffp{i})))
				full_file_picks{end + 1} = ffp{i}; %#ok<AGROW>
				[~,fn,ext] = fileparts(ffp{i});
				file_picks{end + 1} = [fn,ext]; %#ok<AGROW>
				temp = dir(fullfile(ffp{i},'..'));
				if ispc || ismac
					thisdir = strcmpi({temp.name},[fn,ext]);
				else
					thisdir = strcmp({temp.name},[fn,ext]);
				end
				dir_picks(end + 1) = temp(thisdir); %#ok<AGROW>
				dir_picks(end).name = ffp{i};
			elseif exist(ffp{i},'file') && ...
					(~nodupes || ~any(strcmp(full_file_picks,ffp{i})))
				full_file_picks{end + 1} = ffp{i}; %#ok<AGROW>
				[~,fn,ext] = fileparts(ffp{i});
				file_picks{end + 1} = [fn,ext]; %#ok<AGROW>
				dir_picks(end + 1) = dir(ffp{i}); %#ok<AGROW>
				dir_picks(end).name = ffp{i};
			end
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',[]);
		else
			set(pickslist,'String',file_picks,'Value',[]);
		end
		set([removebut,moveupbut,movedownbut],'Enable','off');
	end
%%}
	function sort_type(h,evt,cb) %#ok<INUSL>
		if sort_state(cb)
			sort_state(cb) = -sort_state(cb);
			last_sort_state(cb) = sort_state(cb);
		else
			sort_state = zeros(1,3);
			sort_state(cb) = last_sort_state(cb);
		end
		set(sort_cb,{'CData'},tri_icon(sort_state + 2)')

		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
			@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		%set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function dirpopup(varargin)
		value = get(dir_popup,'Value');
		container = path_cell{min(value + 1,length(path_cell))};
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		end
		filenames = {fdir.name}';
		selected = find(strcmp(filenames,container));
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',selected)
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function dir_up_one(varargin)
		value = length(path_cell) - 1;
		container = path_cell{value + 1};
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		end
		filenames = {fdir.name}';
		selected = find(strcmp(filenames,container));
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',selected)
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end
	function PIVlab_select_Callback(varargin)
		set(PIVlab_select2, 'Value', 0)
		set(PIVlab_select3, 'Value', 0)
		set(PIVlab_select,'Value',1)
		sequencer=0;
		try
			save('PIVlab_settings_default.mat','sequencer','-append')
		catch
		end
		hgui=getappdata(0,'hgui');
		setappdata(hgui, 'sequencer', sequencer);

	end
	function PIVlab_select_Callback2(varargin)
		set(PIVlab_select, 'Value', 0)
		set(PIVlab_select3, 'Value', 0)
		set(PIVlab_select2,'Value',1)
		sequencer=1;
		try
			save('PIVlab_settings_default.mat','sequencer','-append')
		catch
		end
		hgui=getappdata(0,'hgui');
		setappdata(hgui, 'sequencer', sequencer);

	end
	function PIVlab_select_Callback3(varargin)
		set(PIVlab_select2, 'Value', 0)
		set(PIVlab_select, 'Value', 0)
		set(PIVlab_select3,'Value',1)
		sequencer=2;
		try
			save('PIVlab_settings_default.mat','sequencer','-append')
		catch
		end
		hgui=getappdata(0,'hgui');
		setappdata(hgui, 'sequencer', sequencer);
	end

	function change_path(varargin)
		set(fig,'pointer','watch')
		drawnow
		proposed_path = get(pathbox,'String');
		% Process any folders named '..'.
		proposed_path_cell = path2cell(proposed_path);
		ddots = strcmp(proposed_path_cell,'..');
		ddots(find(ddots) - 1) = true;
		proposed_path_cell(ddots) = [];
		proposed_path = cell2path(proposed_path_cell);
		% Check for existance of folder.
		if ~exist(proposed_path,'dir')
			set(fig,'pointer','arrow')
			uiwait(errordlg(['Folder "',proposed_path,...
				'" does not exist.'],'','modal'))
			return
		end
		current_dir = proposed_path;
		history = update_history(history,current_dir,now,history_size);
		make_history_cm()
		full_filter = fullfile(current_dir,filter);
		[path_cell,new_network_vol] = path2cell(current_dir);
		if exist(new_network_vol,'dir')
			network_volumes = unique([network_volumes,{new_network_vol}]);
		end
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
			@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		%set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function showfullpath(varargin)
		show_full_path = get(viewfullpath,'Value');
		if show_full_path
			set(pickslist,'String',full_file_picks)
		else
			set(pickslist,'String',file_picks)
		end
	end

	function removedupes(varargin)
		nodupes = get(remove_dupes,'Value');
		if nodupes
			num_picks = length(full_file_picks);
			[~,rev_order] = unique(full_file_picks(end:-1:1));
			order = sort(num_picks + 1 - rev_order);
			full_file_picks = full_file_picks(order);
			file_picks = file_picks(order);
			dir_picks = dir_picks(order);
			if show_full_path
				set(pickslist,'String',full_file_picks,'Value',[])
			else
				set(pickslist,'String',file_picks,'Value',[])
			end
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
	end

	function moveup(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value - 1) = omega(value);
		index(setdiff(omega,value - 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value - 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if min(value) == 1
			set(moveupbut,'Enable','off')
		end
		set(movedownbut,'Enable','on')
	end

	function movedown(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value + 1) = omega(value);
		index(setdiff(omega,value + 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value + 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if max(value) == n
			set(movedownbut,'Enable','off')
		end
		set(moveupbut,'Enable','on')
	end


	function setfilspec(varargin)
		set(fig,'pointer','watch')
		drawnow
		filter = get(filter_ed,'String');
		if isempty(filter)
			filter = '*';
			set(filter_ed,'String',filter)
		end
		% Process file spec if a subdirectory was included.
		[p,f,e] = fileparts(filter);
		if ~isempty(p)
			newpath = fullfile(current_dir,p,'');
			set(pathbox,'String',newpath)
			filter = [f,e];
			if isempty(filter)
				filter = '*';
			end
			set(filter_ed,'String',filter)
			change_path();
		end
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
			@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function setrefilter(varargin)
		set(fig,'pointer','watch')
		drawnow
		re_filter = get(refilter_ed,'String');
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
			@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function filter_type_callback(varargin)
		type_value = get(type_popup,'Value');
		set(filter_ed,'String',prop.type{type_value,1})
		setfilspec()
	end

	function done(varargin)
		% Optional shortcut: click on a file and press 'Done'.
		if isempty(full_file_picks) && strcmp(get(addbut,'Enable'),'on')
			add();
			drawnow;
			pause(0.1);
		end
		numfiles = length(full_file_picks);
		if ~isempty(prop.numfiles)
			if numfiles < prop.numfiles(1)
				msg = {'Too few items selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			elseif numfiles > prop.numfiles(end)
				msg = {'Too many items selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			end
		end
		%%remove directories from list
		for i=numfiles:-1:1
			if isfolder(full_file_picks{i})
				full_file_picks(i)=[];
			end
		end
		%fig_pos = get(fig,'Position');
		hgui=getappdata(0,'hgui');
		setappdata(hgui, 'sequencer', sequencer); %default style
		if exist('i_frames','var') && ~isempty(i_frames)
			%multitiff it has already been checked
			if i_frames > 1
				multitiff=1;
			else
				multitiff=0;
			end
        else % i_frames (nr of layers) has not been checked yet
            pick = file_picks{1};
			if numel(pick)-strfind(pick,'.b16')==3
				multitiff=0;
            else % not b16 image --> check if multilayer
				if size(imfinfo(full_file_picks{1}),1) > 1
					multitiff=1;
				else
					multitiff=0;
				end
			end
		end
		%PIVlab_select_Callback
		delete(fig)
	end

	function cancel(varargin)
		prop.output = 'cancel';
		fig_pos = get(fig,'Position');
		delete(fig)
	end

	function history_cb(varargin)
		set(fig,'pointer','watch')
		drawnow
		current_dir = history(varargin{3}).name;
		history = update_history(history,current_dir,now,history_size);
		make_history_cm()
		full_filter = fullfile(current_dir,filter);
		path_cell = path2cell(current_dir);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
			@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
		set(addbut,'Enable','off')
		%set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function clear_history(varargin)
		history = update_history(history(1),'',[],history_size);
		make_history_cm()
	end

	function set_history_size(varargin)
		result_cell = inputdlg('Number of Recent Folders:','',1,...
			{sprintf('%g',history_size)});
		if isempty(result_cell)
			return
		end
		result = sscanf(result_cell{1},'%f');
		if isempty(result) || result < 1
			return
		end
		history_size = result;
		history = update_history(history,'',[],history_size);
		make_history_cm()
		setpref('uipickfiles','history_size',history_size)
	end

%{
function resize(varargin)
		% Get current figure size.
		P = 'Position';
		pos = get(fig,P);
		w = pos(3); % figure width in pixels
		h = pos(4); % figure height in pixels
		
		% Enforce minimum figure size.
		w = max(w,564);
		h = max(h,443);
		if any(pos(3:4) < [w h])
			pos(3:4) = [w h];
			set(fig,P,pos)
		end
		
		% Change positions of all uicontrols based on the current figure
		% width and height.
		navw_pckw = round([1 1;-350 250]\[w-140;0]);
		navw = navw_pckw(1);
		pckw = navw_pckw(2);
		navp = [10 10 navw h-174];
		pckp = [w-10-pckw 10 pckw h-174];
		set(navlist,P,navp)
		set(pickslist,P,pckp)
		
		set(frame1,P,[navw+5 h-234 110 70])
%		set(openbut,P,[navw+20 h-194 80 20])
		set(addbut,P,[navw+20 h-224 80 20])
		
		frame2y = round((h-234 + 110 - 100)/2);
		set(frame2,P,[w-pckw-115 frame2y 110 100])
		set(removebut,P,[w-pckw-100 frame2y+70 80 20])
		set(moveupbut,P,[w-pckw-100 frame2y+40 80 20])
		set(movedownbut,P,[w-pckw-100 frame2y+10 80 20])
		
		set(done_button,P,[navw+30 80 80 30])
		set(cancel_button,P,[navw+30 30 80 30])
		
		set(sort_cb(1),P,[15 h-163 70 15])
		set(sort_cb(2),P,[85 h-163 70 15])
		set(sort_cb(3),P,[155 h-163 70 15])
		
		set(dir_popup,P,[10 h-144 navw-25 20])
		set(up_dir_but,P,[navw-10 h-144 20 20])
		set(pathbox,P,[10 h-119 navw 26])
		set(label1,P,[10 h-93 navw 16])
		
		set(viewfullpath,P,[pckp(1) h-159 230 20])
		set(remove_dupes,P,[pckp(1) h-134 280 20])
		set(recall_button,P,[w-75 h-159 65 20])
		set(label4,P,[w-10-pckw h-89 pckw 20])
		set(num_files_warn,P,[w-10-pckw h-109 pckw 16])
		
		set(label2,P,[10 h-18 80 17])
		set(label3,P,[100 h-18 160 17])
		set(showallfiles,P,[270 h-42 110 20])
		set(refilterdirs,P,[270 h-64 100 20])
		set(filter_ed,P,[10 h-44 80 26])
		set(refilter_ed,P,[100 h-44 160 26])
		set(type_popup,P,[10 h-72 250 20])
	end
%}
%{
function reset_figure_size(varargin)
		if strcmp(get(fig,'SelectionType'),'open')
			root_units = get(0,'units');
			screen_size = get(0,'ScreenSize');
			set(0,'Units',root_units)
			hw = [740 494];
			pos = [round((screen_size(3:4) - hw - [0 26])/2),hw];
			set(fig,'Position',pos)
			resize()
		end
	end
%}


% ------------------ Other nested functions ------------------

	function make_history_cm
		% Make context menu for history.
		if ~isempty(hist_menus)
			delete(hist_menus)
		end
		num_hist = length(history);
		hist_menus = zeros(1,num_hist+2);
		for i = 1:num_hist
			hist_menus(i) = uimenu(hist_cm,'Label',history(i).name,...
				'Callback',{@history_cb,i});
		end
		hist_menus(num_hist+1) = uimenu(hist_cm,...
			'Label','Clear Menu',...
			'Separator','on',...
			'Callback',@clear_history);
		hist_menus(num_hist+2) = uimenu(hist_cm,'Label',...
			sprintf('Set Number of Recent Folders (%d) ...',history_size),...
			'Callback',@set_history_size);
	end

end


% -------------------- Subfunctions --------------------

function [c,network_vol] = path2cell(p)
% Turns a path string into a cell array of path elements.
if ispc
	p = strrep(p,'/','\');
	c1 = regexp(p,'(^\\\\[^\\]+\\[^\\]+)|(^[A-Za-z]+:)|[^\\]+','match');
	vol = c1{1};
	c = [{'My Computer'};c1(:)];
	if strncmp(vol,'\\',2)
		network_vol = vol;
	else
		network_vol = '';
	end
else
	c = textscan(p,'%s','delimiter','/');
	c = [{filesep};c{1}(2:end)];
	network_vol = '';
end
end

% --------------------

function p = cell2path(c)
% Turns a cell array of path elements into a path string.
if ispc
	p = fullfile(c{2:end},'');
else
	p = fullfile(c{:},'');
end
end

% --------------------

function d = filtered_dir(full_filter,re_filter,filter_both,sort_fcn)
% Like dir, but applies filters and sorting.
p = fileparts(full_filter);
if isempty(p) && full_filter(1) == '/'
	p = '/';
end
if exist(full_filter,'dir')
	dfiles = dir(' ');
else
	dfiles = dir(full_filter);
end
if ~isempty(dfiles)
	dfiles([dfiles.isdir]) = [];
end

ddir = dir(p);
ddir = ddir([ddir.isdir]);
[unused,index0] = sort(lower({ddir.name})); %#ok<ASGLU>
ddir = ddir(index0);
ddir(strcmp({ddir.name},'.') | strcmp({ddir.name},'..')) = [];

% Additional regular expression filter.
if nargin > 1 && ~isempty(re_filter)
	if ispc || ismac
		no_match = cellfun('isempty',regexpi({dfiles.name},re_filter));
	else
		no_match = cellfun('isempty',regexp({dfiles.name},re_filter));
	end
	dfiles(no_match) = [];
end
if filter_both
	if nargin > 1 && ~isempty(re_filter)
		if ispc || ismac
			no_match = cellfun('isempty',regexpi({ddir.name},re_filter));
		else
			no_match = cellfun('isempty',regexp({ddir.name},re_filter));
		end
		ddir(no_match) = [];
	end
end
% Set navigator style:
%	1 => list all folders before all files, case-insensitive sorting
%	2 => mix files and folders, case-insensitive sorting
%	3 => list all folders before all files, case-sensitive sorting
nav_style = 1;
switch nav_style
	case 1
		[unused,index1] = sort_fcn(dfiles); %#ok<ASGLU>
		[unused,index2] = sort_fcn(ddir); %#ok<ASGLU>
		d = [ddir(index2);dfiles(index1)];
	case 2
		d = [dfiles;ddir];
		[unused,index] = sort(lower({d.name})); %#ok<ASGLU>
		d = d(index);
	case 3
		[unused,index1] = sort({dfiles.name}); %#ok<ASGLU>
		[unused,index2] = sort({ddir.name}); %#ok<ASGLU>
		d = [ddir(index2);dfiles(index1)];
end
end

% --------------------

function [files_sorted,index] = file_sort(files,sort_state)
switch find(sort_state)
	case 1
		%[files_sorted,index] = sort(lower({files.name}));
		[files_sorted,index] = natsortfiles(lower({files.name})); %natural file name sorting
		if sort_state(1) < 0
			files_sorted = files_sorted(end:-1:1);
			index = index(end:-1:1);
		end
	case 2
		if sort_state(2) > 0
			[files_sorted,index] = sort([files.datenum]);
		else
			[files_sorted,index] = sort([files.datenum],'descend');
		end
	case 3
		if sort_state(3) > 0
			[files_sorted,index] = sort([files.bytes]);
		else
			[files_sorted,index] = sort([files.bytes],'descend');
		end
end
end

% --------------------

function drives = getdrives(other_drives)
% Returns a cell array of drive names on Windows.
letters = char('A':'Z');
num_letters = length(letters);
drives = cell(1,num_letters);
for i = 1:num_letters
	if exist([letters(i),':\'],'dir')
		drives{i} = [letters(i),':'];
	end
end
drives(cellfun('isempty',drives)) = [];
if nargin > 0 && iscellstr(other_drives) %#ok<ISCLSTR>
	drives = [drives,unique(other_drives)];
end
end

% --------------------

function filenames = annotate_file_names(filenames,dir_listing,fsdata)

% Adds a trailing filesep character to folder names and, optionally,
% prepends a folder icon or bullet symbol.
for i = 1:length(filenames)
	if dir_listing(i).isdir
		filenames{i} = sprintf('%s%s%s%s',fsdata.pre,filenames{i},...
			fsdata.filesep,fsdata.post);
	end
end
end

% --------------------

function history = update_history(history,current_dir,time,history_size)
if ~isempty(current_dir)
	% Insert or move current_dir to the top of the history.
	% If current_dir already appears in the history list, delete it.
	match = strcmp({history.name},current_dir);
	history(match) = [];
	% Prepend history with (current_dir,time).
	history = [struct('name',current_dir,'time',time),history];
end
% Trim history to keep at most <history_size> newest entries.
history = history(1:min(history_size,end));
end

% --------------------

function success = generate_folder_icon(icon_path)
% Black = 1, manila color = 2, transparent = 3.
im = [ ...
	3 3 3 1 1 1 1 3 3 3 3 3;
	3 3 1 2 2 2 2 1 3 3 3 3;
	3 1 1 1 1 1 1 1 1 1 1 3;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 1 1 1 1 1 1 1 1 1 1 1];
cmap = [0 0 0;255 220 130;255 255 255]/255;
fid = fopen(icon_path,'w');
if fid > 0
	fclose(fid);
	imwrite(im,cmap,icon_path,'Transparency',[1 1 0])
end
success = exist(icon_path,'file');
end

% --------------------

function fsdata = set_folder_style(folder_style_pref)
% Set style to preference.
fsdata.style = folder_style_pref;
% If style = 1, check to make sure icon image file exists.  If it doesn't,
% try to create it.  If that fails set style = 2.
if fsdata.style == 1
	icon_path = fullfile(userpath,'uipickfiles_folder_icon.png');
	%icon_path = fullfile(prefdir,'uipickfiles_folder_icon.png');
	if ~exist(icon_path,'file')
		success = generate_folder_icon(icon_path);
		if ~success
			fsdata.style = 2;
		end
	end
end
% Set pre and post fields.
%prevent html use (broken in r2025)
fsdata.style = 3;
if fsdata.style == 1


	icon_url = ['file://localhost/',...
		strrep(strrep(icon_path,':','|'),'\','/')];
	fsdata.pre = sprintf('<HTML><img width=12 height=10 src="%s">&nbsp;',icon_url);
	fsdata.post = '</HTML>';
	%}

elseif fsdata.style == 2
	fsdata.pre = '<HTML><b>&#8226;</b>&nbsp;';
	fsdata.post = '</HTML>';
elseif fsdata.style == 3
	fsdata.pre = '';
	fsdata.post = '';
end
fsdata.filesep = filesep;

end

% --------------------

function prop = parsepropval(prop,varargin)
% Parse property/value pairs and return a structure.
properties = fieldnames(prop);
arg_index = 1;
while arg_index <= length(varargin)
	arg = varargin{arg_index};
	if ischar(arg)
		prop_index = match_property(arg,properties);
		prop.(properties{prop_index}) = varargin{arg_index + 1};
		arg_index = arg_index + 2;
	elseif isstruct(arg)
		arg_fn = fieldnames(arg);
		for i = 1:length(arg_fn)
			prop_index = match_property(arg_fn{i},properties);
			prop.(properties{prop_index}) = arg.(arg_fn{i});
		end
		arg_index = arg_index + 1;
	else
		error(['Properties must be specified by property/value pairs',...
			' or structures.'])
	end
end
end

% --------------------

function prop_index = match_property(arg,properties)
% Utility function for parsepropval.
prop_index = find(strcmpi(arg,properties));
if isempty(prop_index)
	prop_index = find(strncmpi(arg,properties,length(arg)));
end
if length(prop_index) ~= 1
	error('Property ''%s'' does not exist or is ambiguous.',arg)
end
end

function [B,ndx,dbg] = natsort(A,rgx,varargin)
%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:natsort:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
%
chk = '(match|ignore)(case|dia)|(de|a)scend(ing)?|(char|nan|num)[<>](char|nan|num)|%[a-z]+';
%
if nargin<2 || isnumeric(rgx)&&isequal(rgx,[])
	rgx = '\d+';
elseif ischar(rgx)
	assert(ndims(rgx)<3 && size(rgx,1)==1,...
		'SC:natsort:rgx:NotCharVector',...
		'Second input <rgx> character row vector must have size 1xN.') %#ok<ISMAT>
	nsChkRgx(rgx,chk)
else
	rgx = ns1s2c(rgx);
	assert(ischar(rgx),...
		'SC:natsort:rgx:InvalidType',...
		'Second input <rgx> must be a character row vector or a string scalar.')
	nsChkRgx(rgx,chk)
end
%
varargin = cellfun(@ns1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
% Sort direction:
tdd = strcmpi(txt,'descend');
tdx = strcmpi(txt,'ascend')|tdd;
% Character case:
tcm = strcmpi(txt,'matchcase');
tcx = strcmpi(txt,'ignorecase')|tcm;
% Char/num order:
ttn = strcmpi(txt,'num>char')|strcmpi(txt,'char<num');
ttx = strcmpi(txt,'num<char')|strcmpi(txt,'char>num')|ttn;
% NaN/num order:
ton = strcmpi(txt,'num>NaN')|strcmpi(txt,'NaN<num');
tox = strcmpi(txt,'num<NaN')|strcmpi(txt,'NaN>num')|ton;
% SSCANF format:
tsf = ~cellfun('isempty',regexp(txt,'^%([bdiuoxfeg]|l[diuox])$'));
%
nsAssert(txt, tdx, 'SortDirection', 'sort direction')
nsAssert(txt, tcx,  'CaseMatching', 'case sensitivity')
nsAssert(txt, ttx,  'CharNumOrder', 'number-character order')
nsAssert(txt, tox,   'NanNumOrder', 'number-NaN order')
nsAssert(txt, tsf,  'sscanfFormat', 'SSCANF format')
%
ixx = tdx|tcx|ttx|tox|tsf;
if ~all(ixx)
	error('SC:natsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s'],sprintf(' "%s"',txt{~ixx}))
end
%
% SSCANF format:
if any(tsf)
	fmt = txt{tsf};
else
	fmt = '%f';
end
%
xfh = cellfun('isclass',xtx,'function_handle');
assert(nnz(xfh)<2,...
	'SC:natsort:FunctionHandle:Overspecified',...
	'The function handle option may only be specified once.')
assert(all(xfh),...
	'SC:natsort:InvalidOptions',...
	'Optional arguments must be character row vectors, string scalars, or function handles.')
if any(xfh)
	txfh = xtx{xfh};
end
%
%% Identify and Convert Numbers %%
%
[nbr,spl] = regexpi(C(:), rgx, 'match','split', txt{tcx});
%
if numel(nbr)
	V = [nbr{:}];
	if strcmp(fmt,'%b')
		V = regexprep(V,'^0[Bb]','');
		vec = cellfun(@(s)pow2(numel(s)-1:-1:0)*sscanf(s,'%1d'),V);
	else
		vec = sscanf(strrep(sprintf(' %s','0',V{:}),',','.'),fmt);
		vec = vec(2:end); % SSCANF wrong data class bug (R2009b and R2010b)
	end
	assert(numel(vec)==numel(V),...
		'SC:natsort:sscanf:TooManyValues',...
		'The "%s" format must return one value for each input number.',fmt)
else
	vec = [];
end
%
%% Allocate Data %%
%
% Determine lengths:
nmx = numel(C);
lnn = cellfun('length',nbr);
lns = cellfun('length',spl);
mxs = max(lns);
%
% Allocate data:
idn = permute(bsxfun(@le,1:mxs,lnn),[2,1]); % TRANSPOSE lost class bug (R2013b)
ids = permute(bsxfun(@le,1:mxs,lns),[2,1]); % TRANSPOSE lost class bug (R2013b)
arn = zeros(mxs,nmx,class(vec));
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(ids) = [spl{:}];
arn(idn) = vec;
%
%% Debugging Array %%
%
if nargout>2
	dbg = cell(nmx,0);
	for k = 1:nmx
		V = spl{k};
		V(2,:) = [num2cell(arn(idn(:,k),k));{[]}];
		V(cellfun('isempty',V)) = [];
		dbg(k,1:numel(V)) = V;
	end
end
%
%% Sort Matrices %%
%
if ~any(tcm) % ignorecase
	ars = lower(ars);
end
%
if any(ttn) % char<num
	% Determine max character code:
	mxc = 'X';
	tmp = warning('off','all');
	mxc(1) = Inf;
	warning(tmp)
	mxc(mxc==0) = 255; % Octave
	% Append max character code to the split text:
	%ars(idn) = strcat(ars(idn),mxc); % slower than loop
	for ii = reshape(find(idn),1,[])
		ars{ii}(1,end+1) = mxc;
	end
end
%
idn(isnan(arn)) = ~any(ton); % NaN<num
%
if any(xfh) % external text-sorting function
	[~,ndx] = txfh(ars(mxs,:));
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = txfh(ars(ii,ndx));
		ndx = ndx(idx);
	end
elseif any(tdd)
	[~,ndx] = sort(nsGroups(ars(mxs,:)),'descend');
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(nsGroups(ars(ii,ndx)),'descend');
		ndx = ndx(idx);
	end
else
	[~,ndx] = sort(ars(mxs,:)); % ascend
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(ars(ii,ndx)); % ascend
		ndx = ndx(idx);
	end
end
%
%% Outputs %%
%
if ischar(A)
	ndx = ndx(:);
	B = A(ndx,:);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsort
function grp = nsGroups(vec)
% Groups in a cell array of char vectors, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true(1,numel(vec)>0),~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsGroups
function nsChkRgx(rgx,chk)
% Perform some basic sanity-checks on the supplied regular expression.
chk = sprintf('^(%s)$',chk);
assert(isempty(regexpi(rgx,chk,'once')),...
	'SC:natsort:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided input "%s" looks like an optional argument (inputs 3+).'],rgx)
if isempty(regexpi('0',rgx,'once'))
	warning('SC:natsort:rgx:SanityCheck',...
		['Second input <rgx> must be a regular expression that matches numbers.',...
		'\nThe provided regular expression does not match the digit "0", which\n',...
		'may be acceptable (e.g. if literals, quantifiers, or lookarounds are used).'...
		'\nThe provided regular expression: "%s"'],rgx)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsChkRgx
function nsAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsort:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsAssert
function arr = ns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ns1s2c

function [B,ndx,dbg] = natsortfiles(A,rgx,varargin)
%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if isstruct(A)
	assert(isfield(A,'name'),...
		'SC:natsortfiles:A:StructMissingNameField',...
		'If first input <A> is a struct then it must have field <name>.')
	nmx = {A.name};
	assert(all(fnh(nmx)),...
		'SC:natsortfiles:A:NameFieldInvalidType',...
		'First input <A> field <name> must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, nmx, 'UniformOutput',false);
	if isfield(A,'folder')
		fpt(:) = {A.folder};
		assert(all(fnh(fpt)),...
			'SC:natsortfiles:A:FolderFieldInvalidType',...
			'First input <A> field <folder> must contain only character row vectors.')
	end
elseif iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsortfiles:A:CellContentInvalidType',...
		'First input <A> cell array must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, A(:), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
elseif ischar(A)
	assert(ndims(A)<3,...
		'SC:natsortfiles:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	[fpt,fnm,fxt] = cellfun(@fileparts, num2cell(A,2), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
else
	assert(isa(A,'string'),...
		'SC:natsortfiles:A:InvalidType',...
		'First input <A> must be a structure, a cell array, or a string array.');
	[fpt,fnm,fxt] = cellfun(@fileparts, cellstr(A(:)), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
end
%
varargin = cellfun(@nsf1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
trd = strcmpi(txt,'rmdot');
tnx = strcmpi(txt,'noext');
txp = strcmpi(txt,'xpath');
%
nsfAssert(txt, trd, 'rmdot', '"." and ".." folder')
nsfAssert(txt, tnx, 'noext', 'file-extension')
nsfAssert(txt, txp, 'xpath', 'file-path')
%
chk = '(no|rm|x)(dot|ext|path)';
%
if nargin>1
	nsfChkRgx(rgx,chk)
	txt = [{rgx},txt(~(trd|tnx|txp))];
end
%
%% Path and Extension %%
%
% Path separator regular expression:
if ispc()
	psr = '[^/\\]+';
else % Mac & Linux
	psr = '[^/]+';
end
%
if any(trd) % Remove "." and ".." dot directory names
	ddx = strcmp(nmx,'.') | strcmp(nmx,'..');
	fxt(ddx) = [];
	fnm(ddx) = [];
	fpt(ddx) = [];
	nmx(ddx) = [];
end
%
if any(tnx) % No file-extension
	fnm = nmx;
	fxt = [];
end
%
if any(txp) % No file-path
	mat = reshape(fnm,1,[]);
else % Split path into {dir,subdir,subsubdir,...}:
	spl = regexp(fpt(:),psr,'match');
	nmn = 1+cellfun('length',spl(:));
	mxn = max(nmn);
	vec = 1:mxn;
	mat = cell(mxn,numel(nmn));
	mat(:) = {''};
	%mat(mxn,:) = fnm(:); % old behavior
	mat(permute(bsxfun(@eq,vec,nmn),[2,1])) =  fnm(:);  % TRANSPOSE bug loses type (R2013b)
	mat(permute(bsxfun(@lt,vec,nmn),[2,1])) = [spl{:}]; % TRANSPOSE bug loses type (R2013b)
end
%
if numel(fxt) % File-extension
	mat(end+1,:) = fxt(:);
end
%
%% Sort Matrices %%
%
nmr = size(mat,1)*all(size(mat));
dbg = cell(1,nmr);
ndx = 1:numel(fnm);
%
for ii = nmr:-1:1
	if nargout<3 % faster:
		[~,idx] = natsort(mat(ii,ndx),txt{:},xtx{:});
	else % for debugging:
		[~,idx,gbd] = natsort(mat(ii,ndx),txt{:},xtx{:});
		[~,idb] = sort(ndx);
		dbg{ii} = gbd(idb,:);
	end
	ndx = ndx(idx);
end
%
% Return the sorted input array and corresponding indices:
%
if any(trd)
	tmp = find(~ddx);
	ndx = tmp(ndx);
end
%
ndx = ndx(:);
%
if ischar(A)
	B = A(ndx,:);
elseif any(trd)
	xsz = size(A);
	nsd = xsz~=1;
	if nnz(nsd)==1 % vector
		xsz(nsd) = numel(ndx);
		ndx = reshape(ndx,xsz);
	end
	B = A(ndx);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortfiles
function nsfChkRgx(rgx,chk)
chk = sprintf('^(%s)$',chk);
assert(~ischar(rgx)||isempty(regexpi(rgx,chk,'once')),...
	'SC:natsortfiles:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided expression "%s" looks like an optional argument (inputs 3+).'],rgx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfChkRgx
function nsfAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsortfiles:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfAssert
function arr = nsf1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsf1s2c