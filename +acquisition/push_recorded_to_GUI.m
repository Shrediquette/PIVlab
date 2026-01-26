function found_the_data = push_recorded_to_GUI(camera_type,imageamount)
handles=gui.gethand;
projectpath=get(handles.ac_project,'String');
%imageamount=str2double(get(handles.ac_imgamount,'String'));
pathlist={};
pathfilelist={};
file_existing=zeros(imageamount,1);
if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_edge26') %these cameras will from now on save as multitiff, because this is most efficient data type according to pco
    %check if multitiff
    filePattern = fullfile(projectpath, 'PIVlab_pco*.tif');
    direc= dir(filePattern);filenames={};
    [filenames{1:length(direc),1}] = deal(direc.name);
    amount = length(filenames);
    for i=1:1
        pathfilelist{i,1}=fullfile(projectpath,filenames{i});
        pathlist{i,1}=projectpath;
    end
    info = imfinfo(pathfilelist{1});
    i_frames=size(info,1);
    if i_frames > 1
        multitiff=1;
    else
        multitiff=0;
    end
    if isfield(info,'Software')
        if strncmp (info(1).Software,'PCO_Recorder',10)
            dbl_img=1;
            gui.put('pcopanda_dbl_image',dbl_img);
        else
            dbl_img=0;
            gui.put('pcopanda_dbl_image',dbl_img);
        end
    end
else
    multitiff=0;
    dbl_img=0;
    gui.put('pcopanda_dbl_image',dbl_img);
end
gui.put('multitiff',multitiff);
if multitiff==0
    if dbl_img==0
        for i=1:imageamount
            if ~strcmp(camera_type,'chronos')
                pathfileA=fullfile(projectpath,['PIVlab_' sprintf('%4.4d',i-1) '_A.tif']);
                pathfileB=fullfile(projectpath,['PIVlab_' sprintf('%4.4d',i-1) '_B.tif']);
            elseif strcmp(camera_type,'chronos')
                pathfileA=fullfile(projectpath,['frame_' sprintf('%6.6d',2*i-1) '.tiff']);
                pathfileB=fullfile(projectpath,['frame_' sprintf('%6.6d',2*i) '.tiff']);
            end
            pathA=projectpath;
            pathB=projectpath;

            pathfilelist{i*2-1,1}=pathfileA; %#ok<AGROW>
            pathfilelist{i*2,1}=pathfileB; %#ok<AGROW>

            file_existing(i,1) = (isfile(pathfileA) + isfile(pathfileB))/2;

            pathlist{i*2-1,1}=pathA; %#ok<AGROW>
            pathlist{i*2,1}=pathB; %#ok<AGROW>
        end
    else % dbl img = 1 but not multitiff
        filePattern = fullfile(projectpath, 'PIVlab_pco*.tif');
        direc= dir(filePattern);filenames={};
        [filenames{1:length(direc),1}] = deal(direc.name);
        amount = length(filenames);
        for i=1:amount
            pathfilelist{i,1}=fullfile(projectpath,filenames{i});
            pathlist{i,1}=projectpath;
        end
        file_existing=1; %must exist, because generated from drive
    end
else %multitiff = 1
    filePattern = fullfile(projectpath, 'PIVlab_pco*.tif');
    direc= dir(filePattern);filenames={};
    [filenames{1:length(direc),1}] = deal(direc.name);
    amount = length(filenames);
    for i=1:amount
        pathfilelist{i,1}=fullfile(projectpath,filenames{i});
        pathlist{i,1}=projectpath;
    end
    file_existing=1; %must exist, because generated from drive
end
if all(file_existing)
    s = struct('name',pathfilelist,'folder',pathlist,'isdir',0);
    gui.put('sequencer',1);
    gui.put('capturing',0);
    import.loadimgsbutton_Callback([],[],0,s);
    found_the_data=1;
else
    found_the_data=0;
end

%{
if pcopanda_dbl_image %dbl image, aber kein multitiff.
                filepath=cell(0);
                framenum=[];
                framepart=[];
                cntr=1;
                img_height=size(imread(path(1).name,1),1); %read one file to detect image height to devide it by two later.
                for i=1:size(path,1)
                    filepath{cntr,1}=path(i).name;
                    filepath{cntr+1,1}=path(i).name;
                    framenum(cntr,1)=1;
                    framenum(cntr+1,1)=1;
                    framepart(cntr,1)=1;
                    framepart(cntr,2)=img_height/2;
                    framepart(cntr+1,1)=img_height/2+1;
                    framepart(cntr+1,2)=img_height;
                    cntr=cntr+2;
                end
            end
%}