function [filepath, framenum, framepart, filename, sequencer, pcopanda_dbl_image] = build_file_list(files, sequencer, multitiff)
%BUILD_FILE_LIST Build the PIVlab frame list from image files (no GUI needed).
%   [filepath, framenum, framepart, filename, sequencer, pcopanda_dbl_image] = ...
%       import.build_file_list(files, sequencer, multitiff)
%
%   files      cellstr of full image file names (in the order they should be used)
%   sequencer  0 = time resolved (A+B, B+C, ...), 1 = pairwise (A+B, C+D, ...),
%              2 = reference image (A+B, A+C, A+D, ...)
%   multitiff  true if the files are multi-page TIFFs (every page is one frame)
%
%   filepath   2N x 1 cell, file of every frame (odd = A frames, even = B frames)
%   framenum   2N x 1, page (layer) inside the file
%   framepart  2N x 2, first and last image row to use (pco.panda double images)
%   filename   2N x 1 cell, display labels ("A: name", "B: name")
%   sequencer  the sequencing that was actually used (pco.panda double images force pairwise)
%   pcopanda_dbl_image  true if pco.panda double images were detected
%
%   Used by import.loadimgsbutton_Callback (GUI) and pivlab.readImages (API).

files = cellstr(files);
files = files(:);

pcopanda_dbl_image=0;
%check if frames captured by pco panda as double image array.
[~,~,ext] = fileparts(files{1});
if ~strcmpi(ext,'.b16')
    temp_info=imfinfo(files{1});
    if isfield(temp_info,'Software')
        if strncmp (temp_info(1).Software,'PCO_Recorder',10)
            pcopanda_dbl_image=1;
        end
    end
end
if pcopanda_dbl_image==1 && sequencer ~=1
    sequencer=1;
end

if multitiff
    frames_per_image_file=zeros(size(files,1),1);
    for jj=1:size(files,1)
        frames_per_image_file(jj)=size(imfinfo(files{jj}),1);
    end
    loopcntr=sum(frames_per_image_file);
else % single image files.
    loopcntr=size(files,1);
end

if sequencer==1 % AB
    if ~multitiff
        for i=1:loopcntr
            if exist('filepath','var')==0 %first loop
                filepath{1,1}=files{i};
                framenum(1,1)=1;
            else
                filepath{size(filepath,1)+1,1}=files{i}; %#ok<AGROW>
                framenum(size(framenum,1)+1,1)=1;
            end
        end
        if pcopanda_dbl_image %dbl image, aber kein multitiff.
            filepath=cell(0);
            framenum=[];
            framepart=[];
            cntr=1;
            img_height=size(imread(files{1},1),1); %read one file to detect image height to devide it by two later.
            for i=1:size(files,1)
                filepath{cntr,1}=files{i};
                filepath{cntr+1,1}=files{i};
                framenum(cntr,1)=1;
                framenum(cntr+1,1)=1;
                framepart(cntr,1)=1;
                framepart(cntr,2)=img_height/2;
                framepart(cntr+1,1)=img_height/2+1;
                framepart(cntr+1,2)=img_height;
                cntr=cntr+2;
            end
        end
    else % multitiff
        if ~pcopanda_dbl_image
            filepath=cell(0);
            framenum=[];
            cntr=1;
            for i=1:size(files,1)
                for jj=1:frames_per_image_file(i)
                    filepath{cntr,1}=files{i};
                    framenum(cntr,1)=jj;
                    cntr=cntr+1;
                end
            end
        else
            filepath=cell(0);
            framenum=[];
            framepart=[];
            cntr=1;
            img_height=size(imread(files{1},1),1); %read one file to detect image height to devide it by two later.
            for i=1:size(files,1)
                for jj=1:frames_per_image_file(i)
                    filepath{cntr,1}=files{i};
                    filepath{cntr+1,1}=files{i};
                    framenum(cntr,1)=jj;
                    framenum(cntr+1,1)=jj;
                    framepart(cntr,1)=1;
                    framepart(cntr,2)=img_height/2;
                    framepart(cntr+1,1)=img_height/2+1;
                    framepart(cntr+1,2)=img_height;
                    cntr=cntr+2;
                end
            end
        end
    end
elseif sequencer==0 %time-resolved
    if ~multitiff
        for i=1:loopcntr
            if exist('filepath','var')==0 %first loop
                filepath{1,1}=files{i};
                framenum(1,1)=1;
            else
                filepath{size(filepath,1)+1,1}=files{i}; %#ok<AGROW>
                filepath{size(filepath,1)+1,1}=files{i}; %#ok<AGROW>
                framenum(size(framenum,1)+1,1)=1;
                framenum(size(framenum,1)+1,1)=1;
            end
        end
    else % multitiff
        filepath=cell(0);
        framenum=[];
        cntr=1;
        for i=1:size(files,1)
            for jj=1:frames_per_image_file(i)
                if jj == 1 || jj == frames_per_image_file(i)
                    filepath{cntr,1}=files{i};
                    framenum(cntr,1)=jj;
                    cntr=cntr+1;
                else
                    filepath{cntr,1}=files{i};
                    filepath{cntr+1,1}=files{i};
                    framenum(cntr,1)=jj;
                    framenum(cntr+1,1)=jj;
                    cntr=cntr+2;
                end
            end
        end
    end
elseif sequencer == 2 % Reference image style
    if ~multitiff
        for i=1:loopcntr
            if exist('filepath','var')==0 %first loop
                reference_image_i=i;
                filepath=[];
                framenum=[];
            else
                filepath{size(filepath,1)+1,1}=files{reference_image_i}; %#ok<AGROW>
                filepath{size(filepath,1)+1,1}=files{i}; %#ok<AGROW>
                framenum(size(framenum,1)+1,1)=1;
                framenum(size(framenum,1)+1,1)=1;
            end
        end
    else %multitiff
        filepath=cell(0);
        framenum=[];
        cntr=1;
        for i=1:size(files,1)
            for jj=1:frames_per_image_file(i)
                filepath{cntr,1}=files{1};
                filepath{cntr+1,1}=files{i};
                framenum(cntr,1)=1;
                framenum(cntr+1,1)=jj;
                cntr=cntr+2;
            end
        end
    end
end

if ~pcopanda_dbl_image %for non pco files, we also generate this list which tells us which pixels to load from the image file
    [~,~,ext] = fileparts(files{1});
    if strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') %for a tiff file, imread accepts a layer index as additional argument, for other files not, WTF!!!
        img_height=size(imread(files{1},1),1);
    else
        if ~strcmpi(ext,'.b16')
            img_height=size(imread(files{1}),1);
        else
            img_height=size(import.f_readB16(files{1}),1);
        end
    end
    framepart(1,1)=1;
    framepart(1,2)=img_height;
    framepart=repmat(framepart,[size(filepath,1),1]);
end

%% Make error reporting for sequencing easier.
if numel(framenum) ~= numel(filepath)
    disp('Error during sequencing.')
    disp('Please send this debug file to William:')
    disp([pwd filesep 'sequencing_error_report.mat'])
    comp_info = computer; %#ok<NASGU>
    matlab_info=ver; %#ok<NASGU>
    save sequencing_error_report.mat;
end

filename=cell(1);
if loopcntr >= 1
    if size(filepath,1) >1 && mod(size(filepath,1),2)==1
        cutoff=size(filepath,1);
        filepath(cutoff)=[];
        framenum(cutoff)=[];
        framepart(cutoff,:)=[];
    end
    for i=1:size(filepath,1)
        [~,name,ext]=fileparts(filepath{i,1});
        currentname=[name ext];
        if ~multitiff
            if mod(i,2) == 1
                filename{i,1}=['A: ' currentname];
            else
                filename{i,1}=['B: ' currentname];
            end
        else
            if mod(i,2) == 1
                filename{i,1}=['A: ' currentname ', layer: ' num2str(framenum(i))];
            else
                filename{i,1}=['B: ' currentname ', layer: ' num2str(framenum(i))];
            end
        end
    end
end
end
