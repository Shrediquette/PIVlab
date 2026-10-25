function camera_snapshot_Callback(~,~,~)
handles=gui.gethand;
projectpath=get(handles.ac_project,'String');
n_cameras = acquisition.capture_cameras;
if n_cameras > 1 %stereo acquisition: one image per camera in cam1 and cam2
	stereo_snapshot(projectpath,n_cameras);
	return
end
numbi = 0;
imgA_path = fullfile(projectpath, ['PIVlab_snapshot' ,' (',num2str(numbi),')', '.tif']);
while exist(imgA_path, 'file')
    numbi = numbi+1;
    imgA_path = fullfile(projectpath, ['PIVlab_snapshot' ,' (',num2str(numbi),')', '.tif']);
end
current_axis=gui.retr('pivlab_axis');
h1 = findall(current_axis,'Type','image');
if ~isempty(h1)
    img=h1(end).CData;
    size_img=size(img);
    if ~isempty(img)
        try
            snaptxt=text(current_axis,size_img(2)/2,size_img(1)/2,'SNAPSHOT','BackgroundColor','k','Color','y','tag','captureinfo','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',24,'FontWeight','bold');
            drawnow;
            pause(0.05)
            if exist('snaptxt','var')
                snaptxt.Color='k';snaptxt.BackgroundColor='y';
            end
            drawnow;
            pause(0.05)
            if exist('snaptxt','var')
                snaptxt.Color='y';snaptxt.BackgroundColor='k';
            end
            drawnow;
            pause(0.05)
        catch
        end
    end
    if size(size_img)>2
        img=img(:,:,1);
    end
    imwrite(mat2gray(img),imgA_path,'tif','Compression','none');
    try
        sound(audioread(fullfile('+misc','cam_shuttr.mp3')),48000);
    catch
    end
end
delete(findobj('tag','captureinfo'));

function stereo_snapshot(projectpath,n_cameras)
%The latest full frame of each camera (acquisition.show_frame) as "PIVlab_snapshot (n).tif" in cam1 and cam2,
%with the same number n for both cameras. These images can be used as board images for the stereo calibration.
folders = acquisition.capture_folders(projectpath,n_cameras);
frames = cell(1,n_cameras);
current_axis=gui.retr('pivlab_axis');
h1 = findall(current_axis,'Type','image');
for i=1:numel(h1)
	k = getappdata(h1(i),'camera');
	if ~isempty(k) && k <= n_cameras
		frames{k} = getappdata(h1(i),'frame');
		if isempty(frames{k})
			frames{k} = h1(i).CData;
		end
	end
end
for k=1:n_cameras
	if isempty(frames{k})
		return %no image of this camera yet
	end
end
numbi = 0;
free = false;
while ~free
	free = true;
	for k=1:n_cameras
		if exist(fullfile(folders{k}, ['PIVlab_snapshot (' num2str(numbi) ').tif']),'file')
			free = false;
		end
	end
	if ~free
		numbi = numbi+1;
	end
end
xl = get(current_axis,'XLim');
yl = get(current_axis,'YLim');
snaptxt=text(current_axis,mean(xl),mean(yl),'SNAPSHOT','BackgroundColor','k','Color','y','tag','captureinfo','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',24,'FontWeight','bold');
drawnow;
for k=1:n_cameras
	if ~exist(folders{k},'dir')
		mkdir(folders{k});
	end
	imwrite(mat2gray(frames{k}),fullfile(folders{k}, ['PIVlab_snapshot (' num2str(numbi) ').tif']),'tif','Compression','none');
end
snaptxt.Color='k';snaptxt.BackgroundColor='y';
drawnow;
pause(0.05)
try
	sound(audioread(fullfile('+misc','cam_shuttr.mp3')),48000);
catch
end
delete(findobj('tag','captureinfo'));