function imb_rotation(directory)
% IMB_ROTATION     opens a sequence of dialog boxes guiding user to select
% a series of images that need to be rotated and then performs the rotation.
% The program performs the rotation of a series of raster images in a 
% chosen mode and saves the resulting images in a designated directory.
% 
%   IMB_ROTATION('') starts in the directory the program is installed to
%   IMB_ROTATION(DIRECTORY) starts in the directory DIRECTORY
%
%   PARAMETERS
%   anglemode   may take one of the three values:
%     1 - manually input a fixed angle, 
%     2 - rotation at constant rate: fixed angle * number of steps, 
%     3 - read the angle value from a file
% 
%   suffix   may take the following values:
%     *.bmp or *.tif or *.jpg or *.tiff or *.jpeg
% 
%   phi_file  should point to a specially formatted file: 
%     the file should contain four columns with names "phi,x_c,y_c,dphase" 
%     - vector|value|value|value
% 
%   x_c and y_c   are the desired coordinates of the center of rotation 
%   (optional).

% -------------------------------------------------
% Rotation of images. Processing in batch mode.
% v. 1.2.4
% 2026-11-01. Nick Kozlov
% 
% -------------------------------------------------
% MIT License
% 
% Copyright (c) 2022 Nick Kozlov (KozlovN1 @ github)
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

version = '1.2.4';

%% Init
% init_all; % off by default since v. 1.2.1; uncomment if you need suggesting cleaning the workspace
if  exist('directory','var') == 1 && ischar(directory)
    directory=uigetdir(directory,'Directory containing the images you want to PROCESS');
else
    directory=uigetdir([],'Directory containing the images you want to PROCESS');
end

%% Parameters
% some wizard here
%_select directories_%
if  exist('exportdir','var')==1 && ischar(exportdir)
    exportdir=uigetdir(exportdir,'Where to SAVE the figures files?');
else
    exportdir=uigetdir(directory,'Where to SAVE the figures files?');
end
%_Check the config file_%
if isfile(strcat(directory,filesep,'imb_rotation.conf') )
    conffile = fopen(strcat(directory,filesep,'imb_rotation.conf') );
    fgets(conffile);
    anglemode = fgetl(conffile); % 1 - manually input a fixed angle, 2 - rotation at constant rate: fixed angle * number of steps, 3 - read the angle value from a file
    suffix = fgetl(conffile); % *.bmp or *.tif or *.jpg or *.tiff or *.jpeg
    showfigure = fgetl(conffile);
    if showfigure == '1'
        showfigure = 'yes';
    elseif showfigure == '0'
        showfigure = 'no';
    end
    phi_file = fgetl(conffile); % the file should contain four columns with names "phi,x_c,y_c,dphase" - column vector|value|value|value
    val1 = fgetl(conffile);
    val2 = fgetl(conffile);
    val3 = fgetl(conffile);
    fclose(conffile);
else
    anglemode = '';
    suffix = '';
    showfigure = '';
    phi_file = '';
    val1 = ''; 
    val2 = ''; 
    val3 = '';
end
%_Show the configs_%
prompt = {'Set the mode of rotation: 1, 2 or 3',...
    'Set the image file extension (e.g., *.bmp, *.tif, *.jpg)',...
    'Show figures: yes/no?','If in mode 3, set phi_file name'};
dlgtitle = 'Configuration wizard';
dims = [1 50];
definput = {anglemode, suffix, showfigure, phi_file};
answer = inputdlg(prompt,dlgtitle,dims,definput);
anglemode = str2double(answer{1});
suffix = answer{2};
if answer{3} == "yes" || answer{3} == "YES"
    showfigure = true;
elseif answer{3} == "no" || answer{3} == "NO"
    showfigure = false;
end
if anglemode == 3
    phi_file = answer{4};
else
    clear phi_file
end
%_%

%% Program main body
%_get the list of files_%
direc = dir(strcat(directory,filesep,suffix)); 
filenames={};
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames);
%_%

%_Import data_%
if anglemode == 1
    prompt = {'Set the angle of rotation in degrees',...
        'Set the centre coordinate x_c','Set the centre coordinate y_c'};
    dlgtitle = 'Configure the rotation: MODE 1';
    dims = [1 50];
    definput = {val1, val2, val3};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    phi = str2double(answer{1});
    x_c = str2double(answer{2});
    y_c = str2double(answer{3});
elseif anglemode == 2
    prompt = {'Set the rate of rotation in frames per revolution',...
        'Set the centre coordinate x_c','Set the centre coordinate y_c'};
    dlgtitle = 'Configure the rotation: MODE 2';
    dims = [1 50];
    definput = {val1, val2, val3};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    rate = str2double(answer{1});
    x_c = str2double(answer{2});
    y_c = str2double(answer{3});
elseif anglemode == 3
    T = readtable(strcat(directory,filesep,phi_file));
    phi = T{:,{'phi'}};
    x_c = T{1,{'x_c'}};
    y_c = T{1,{'y_c'}};
    dphase = T{1,{'dphase'}};
else
    msgbox('Wrong value of anglemode', 'Error','error');
end
%_%

%_Set the number of images to process_%
element1 = 1;
element2 = length(filenames);
prompt = {'Start number','End number'};
dlgtitle = 'How many images to process?';
dims = [1 50];
if anglemode == 3
    if dphase < 0
        element1 = 1-dphase;
        element2 = length(filenames);
    elseif dphase > 0
        element1 = 1;
        element2 = length(filenames)-dphase;
    end
end
definput = {num2str(element1),num2str(element2)};
answer = inputdlg(prompt,dlgtitle,dims,definput);
if str2double(answer{1}) >= element1
    Nstart = str2double(answer{1});
else
    disp(strcat('Invalid value; setting it to the default: ',...
        num2str(element1)));
    Nstart = element1;
end
if str2double(answer{2}) <= element2
    Nfiles = str2double(answer{2});
else
    disp(strcat('Invalid value; setting it to the maximum amount of files: ',...
        num2str(element2)));
    Nfiles = element2;
end
%_%

im1={};
im2={};
im = imread(strcat(directory,filesep,filenames{1}));
if isnan(x_c)
    x_c = 0.5*size(im,2);
end
if isnan(y_c)
    y_c = 0.5*size(im,1);
end
if ceil(2*x_c) <= size(im,2)
    ColStart = 1;
    ColEnd = ceil(2*x_c);
else
    msgbox("Column boundary exceeded - reducing.");
    ColStart = 2*round(x_c) - size(im,2); % v. 1b9
    ColEnd = size(im,2); % v. 1b9
end
if ceil(2*y_c) <= size(im,1)
    RowStart = 1;
    RowEnd = ceil(2*y_c);
else
    msgbox("Row boundary exceeded - reducing.");
    RowStart = 2*round(y_c) - size(im,1); % v. 1b9
    RowEnd = size(im,1); % v. 1b9
end
if showfigure == true; cnt = 0; fig = figure; end
for i=Nstart:1:Nfiles
    im = imread(strcat(directory,filesep,filenames{i}));
    im1 = im(RowStart:RowEnd,ColStart:ColEnd,:);
    if anglemode == 1
        im2 = imrotate(im1,phi,'bilinear','loose');
    elseif anglemode == 2
        im2 = imrotate(im1,-(i-Nstart)*360/rate,'bilinear','crop');
    elseif anglemode == 3
        im2 = imrotate(im1,phi(i+dphase)*180/pi,'bilinear','crop');
    end
    switch suffix
        case '*.bmp'
            imwrite(im2,strcat(exportdir,filesep,filenames{i}),'bmp');
        case '*.tif'
            imwrite(im2,strcat(exportdir,filesep,filenames{i}),'tif','Compression','none');
        case '*.tiff'
            imwrite(im2,strcat(exportdir,filesep,filenames{i}),'tif','Compression','none');
        case '*.jpg'
            imwrite(im2,strcat(exportdir,filesep,filenames{i}),'jpg','Quality',100);
        case '*.jpeg'
            imwrite(im2,strcat(exportdir,filesep,filenames{i}),'jpg','Quality',100);
    end
    if showfigure == true
        cnt = cnt+1;
        if Nfiles / cnt <= 100
            figure(fig);
            imshow(im2);
            title(['Saving figures: ' int2str((i)/Nfiles*100) ' %']);
            drawnow;
            cnt = 0;
        end
    end
    clc;
    disp(['Saving rotated images: ' int2str(round(i/Nfiles*100,2)) ' %']);
end

%% Save the parameters last used
[~, scriptname, ~] = fileparts(mfilename('fullpath'));
conffile = fopen(strcat(directory,filesep,'imb_rotation.conf'), 'w');
fprintf(conffile, '%s ', 'The parameters registered on');
fprintf(conffile, '%s ', string(datetime) );
fprintf(conffile, 'by %s v. %s\n', scriptname, version);
fprintf(conffile, '%i\n%s\n%i\n', anglemode, suffix, showfigure);
if anglemode == 3
    fprintf(conffile, '%s\n', phi_file, '', '', '');
else
    fprintf(conffile, '%s\n', '');
end
if anglemode == 1; fprintf(conffile, '%g\n', phi, x_c, y_c); end
if anglemode == 2; fprintf(conffile, '%g\n', rate, x_c, y_c); end
fclose(conffile);
end
