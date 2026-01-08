function camera_snapshot_Callback(~,~,~)
handles=gui.gethand;
projectpath=get(handles.ac_project,'String');
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
            snaptxt=text(size_img(2)/2,size_img(1)/2,'SNAPSHOT','BackgroundColor','k','Color','y','tag','captureinfo','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',24,'FontWeight','bold');
            drawnow;
            pause(0.01)
            if exist('snaptxt','var')
                snaptxt.Color='k';snaptxt.BackgroundColor='y';
            end
            drawnow;
            pause(0.01)
            if exist('snaptxt','var')
                snaptxt.Color='y';snaptxt.BackgroundColor='k';
            end
            drawnow;
            pause(0.005)
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