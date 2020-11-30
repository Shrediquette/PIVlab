% Example script how to use PIVlab from the commandline
% Just run this script to see what it does.
% You can adjust the settings in "s" and "p", specify a mask and a region of interest
clc; clear all

%% Create list of images inside user specified directory
directory='/Users/qmn203/Google Drive/temp/bird-lung-short-process--forward/shortbigA0.7cmf1.0hz40FPS_0004.avi_light/frames/'; %directory containing the images you want to analyze
suffix='*.jpg'; %*.bmp or *.tif or *.jpg or *.tiff or *.jpeg
disp(['Looking for ' suffix ' files in the selected directory.']);
direc = dir([directory,filesep,suffix]); filenames={};
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames); %sort all image files
amount = length(filenames);

%% Standard PIV Settings
s = cell(13,2); % To make it more readable, let's create a "settings table"
%Parameter                          %Setting           %Options
s{1,1}= 'Int. area 1';              s{1,2}=64;         % window size of first pass
s{2,1}= 'Step size 1';              s{2,2}=32;         % step of first pass
s{3,1}= 'Subpix. finder';           s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                     s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
s{5,1}= 'ROI';                      s{5,2}=[];         % Region of interest: [x,y,width,height] in pixels, may be left empty
s{6,1}= 'Nr. of passes';            s{6,2}=2;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';              s{7,2}=32;         % second pass window size
s{8,1}= 'Int. area 3';              s{8,2}=16;         % third pass window size
s{9,1}= 'Int. area 4';              s{9,2}=16;         % fourth pass window size
s{10,1}='Window deformation';       s{10,2}='*linear'; % '*spline' is more accurate, but slower
s{11,1}='Repeated Correlation';     s{11,2}=0;         % 0 or 1 : Repeat the correlation four times and multiply the correlation matrices.
s{12,1}='Disable Autocorrelation';  s{12,2}=0;         % 0 or 1 : Disable Autocorrelation in the first pass. 
s{13,1}='Correlation style';        s{13,2}=0;         % 0 or 1 : Use circular correlation (0) or linear correlation (1). 

%% Standard image preprocessing settings
p = cell(10,1);
%Parameter                       %Setting           %Options
p{1,1}= 'ROI';                   p{1,2}=s{5,2};     % same as in PIV settings
p{2,1}= 'CLAHE';                 p{2,2}=1;          % 1 = enable CLAHE (contrast enhancement), 0 = disable
p{3,1}= 'CLAHE size';            p{3,2}=50;         % CLAHE window size
p{4,1}= 'Highpass';              p{4,2}=0;          % 1 = enable highpass, 0 = disable
p{5,1}= 'Highpass size';         p{5,2}=15;         % highpass size
p{6,1}= 'Clipping';              p{6,2}=0;          % 1 = enable clipping, 0 = disable
p{7,1}= 'Wiener';                p{7,2}=0;          % 1 = enable Wiener2 adaptive denoise filter, 0 = disable
p{8,1}= 'Wiener size';           p{8,2}=3;          % Wiener2 window size
p{9,1}= 'Minimum intensity';     p{9,2}=0.0;        % Minimum intensity of input image (0 = no change) 
p{10,1}='Maximum intensity';     p{10,2}=1.0;       % Maximum intensity on input image (1 = no change)

%% other settings
pairwise = 1; % 0 for [A+B], [B+C], [C+D]... sequencing style, and 1 for [A+B], [C+D], [E+F]... sequencing style

%% PIV analysis loop
if pairwise == 1
    if mod(amount,2) == 1 %Uneven number of images?
        disp('Image folder should contain an even number of images.')
        %remove last image from list
        amount=amount-1;
        filenames(size(filenames,1))=[];
    end

    disp(['Found ' num2str(amount) ' images (' num2str(amount/2) ' image pairs).'])
    x=cell(amount/2,1);
    y=x;
    u=x;
    v=x;
else
    disp(['Found ' num2str(amount) ' images'])
    x=cell(amount-1,1);
    y=x;
    u=x;
    v=x;
end

typevector=x; %typevector will be 1 for regular vectors, 0 for masked areas
cntr=0;
%% Main PIV analysis loop:
for i=1:1+pairwise:amount-1 
    cntr=cntr+1;
    image1=imread(fullfile(directory, filenames{i})); % read images
    image2=imread(fullfile(directory, filenames{i+1}));
    image1 = PIVlab_preproc (image1,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2}); %preprocess images
    image2 = PIVlab_preproc (image2,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2});
    [x{cntr}, y{cntr}, u{cntr}, v{cntr}, typevector{cntr}] = piv_FFTmulti (image1,image2,s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2},s{11,2},s{12,2},s{13,2}); %actual PIV analysis
    
    % Graphical output (disable to improve speed)
    %%{
    imagesc(double(image1)+double(image2));colormap('gray');
    hold on
    quiver(x{cntr},y{cntr},u{cntr},v{cntr},'g','AutoScaleFactor', 1.5);
    hold off;
    axis image;
    title(['Raw result ' filenames{i}],'interpreter','none')
    set(gca,'xtick',[],'ytick',[])
    drawnow;
    
    disp([int2str((i+1)/amount*100) ' %']);
    %%}
end

%% PIV postprocessing loop
% Standard image post processing settings
   
r = cell(6,1);
%Parameter     %Setting                                     %Options
r{1,1}= 'Calibration factor, 1 for uncalibrated data';      r{1,2}=1;                   % Calibration factor for u and v
r{2,1}= 'Valid velocities [u_min; u_max; v_min; v_max]';    r{2,2}=[-50; 50; -50; 50];  % Maximum allowed velocities, for uncalibrated data: maximum displacement in pixels
r{3,1}= 'Stdev check?';                                     r{3,2}=1;                   % 1 = enable global standard deviation test
r{4,1}= 'Stdev threshold';                                  r{4,2}=7;                   % Threshold for the stdev test
r{5,1}= 'Local median check?';                              r{5,2}=1;                   % 1 = enable local median test
r{6,1}= 'Local median threshold';                           r{6,2}=2;                   % Threshold for the local median test

u_filt=cell(size(u));
v_filt=cell(size(v));
typevector_filt=typevector;
for PIVresult=1:size(x,1)
    [u_filt{PIVresult,1},v_filt{PIVresult,1}] = PIVlab_postproc (u{PIVresult,1},v{PIVresult,1}, r{1,2}, r{2,2},r{3,2}, r{4,2},r{5,2},r{6,2});

    typevector_filt{PIVresult,1}(isnan(u_filt{PIVresult,1}))=2;
    typevector_filt{PIVresult,1}(isnan(v_filt{PIVresult,1}))=2;
    typevector_filt{PIVresult,1}(typevector{PIVresult,1}==0)=0; %restores typevector for mask
    
    %% Interpolate missing data (disable if you wish)
    u_filt{PIVresult,1}=inpaint_nans(u_filt{PIVresult,1},4);
    v_filt{PIVresult,1}=inpaint_nans(v_filt{PIVresult,1},4);
end
%% 
save([directory 'PIV_result_' num2str(amount) '_frames.mat']);
    %% 
clearvars -except p s r x y u v typevector directory filenames u_filt v_filt typevector_filt
disp('DONE.')