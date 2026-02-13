clc
clear all
close all
imaqreset
ImagePath = 'D:\PIV Data\stereotest_optocam2\piv_images'
frame_rate=80
interframe = 300
laser_energy= 75
nr_of_images=100
exposure_time= floor(1/frame_rate*1000*1000-44)/1;
OPTOcam_frames_to_capture = nr_of_images*2;



delete(imaqfind); %clears all previous videoinputs
imaqreset
hwinf = imaqhwinfo;

info = imaqhwinfo(hwinf.InstalledAdaptors{1});
OPTOcam_vid1 = videoinput(info.AdaptorName,info.DeviceInfo(1).DeviceID,'Mono8');
OPTOcam_vid2 = videoinput(info.AdaptorName,info.DeviceInfo(2).DeviceID,'Mono8');


%device throughputlimit für beide kameras machen...

OPTOcam_settings1 = get(OPTOcam_vid1);
OPTOcam_settings1.Source.DeviceLinkThroughputLimitMode = 'off';
OPTOcam_settings1.PreviewFullBitDepth='On';
OPTOcam_vid1.PreviewFullBitDepth='On';
triggerconfig(OPTOcam_vid1, 'hardware');
OPTOcam_settings1.TriggerSource = 'Line2';
OPTOcam_settings1.Source.ExposureMode = 'Timed';
OPTOcam_settings1.Source.TriggerSource ='Line2';
OPTOcam_settings1.Source.TriggerSelector='FrameStart';
OPTOcam_settings1.Source.TriggerMode ='On';
OPTOcam_settings1.Source.LineSelector='Line4';
OPTOcam_settings1.Source.LineSource = 'ExposureActive';
OPTOcam_settings1.Source.LineMode = 'Output';
OPTOcam_settings1.Source.ExposureTime =exposure_time;
OPTOcam_settings1.Source.LineInverter='False';
OPTOcam_settings1.Source.ReverseX = 'True';
OPTOcam_settings1.Source.ReverseY = 'True';

OPTOcam_settings2 = get(OPTOcam_vid2);
OPTOcam_settings2.Source.DeviceLinkThroughputLimitMode = 'off';
OPTOcam_settings2.PreviewFullBitDepth='On';
OPTOcam_vid2.PreviewFullBitDepth='On';
triggerconfig(OPTOcam_vid2, 'hardware');
OPTOcam_settings2.TriggerSource = 'Line2';
OPTOcam_settings2.Source.ExposureMode = 'Timed';
OPTOcam_settings2.Source.TriggerSource ='Line2';
OPTOcam_settings2.Source.TriggerSelector='FrameStart';
OPTOcam_settings2.Source.TriggerMode ='On';
OPTOcam_settings2.Source.LineSelector='Line4';
OPTOcam_settings2.Source.LineSource = 'ExposureActive';
OPTOcam_settings2.Source.LineMode = 'Output';
OPTOcam_settings2.Source.ExposureTime =exposure_time;
OPTOcam_settings2.Source.LineInverter='False';
OPTOcam_settings2.Source.ReverseX = 'True';
OPTOcam_settings2.Source.ReverseY = 'True';


OPTOcam_vid1.FramesPerTrigger = OPTOcam_frames_to_capture;
OPTOcam_vid2.FramesPerTrigger = OPTOcam_frames_to_capture;
flushdata(OPTOcam_vid1);
flushdata(OPTOcam_vid2);
pause(0.5)


start(OPTOcam_vid1);
start(OPTOcam_vid2);

tiledlayout(1,2)
nexttile
prev1=imagesc(rand(1216,1936));axis image
nexttile
prev2=imagesc(rand(1216,1936));axis image

preview(OPTOcam_vid1,prev1);
preview(OPTOcam_vid2,prev2);


pause(0.5)

%% start laser
clear serpo
[~, pin_string,~,frame_time] = PIVlab_calc_oltsync_timings('OPTOcam','',8,frame_rate,0,interframe,laser_energy);
triggerconfig=':0,0:';

send_string=['TALKINGTO:' 'oltSync:00-1a-0c-9e' ':sequence:' int2str(frame_time) triggerconfig pin_string]
serpo=serialport("COM3",9600,'Timeout',2);
configureTerminator(serpo,'CR/LF');

writeline(serpo,send_string);
pause(0.05)
serial_answer=readline(serpo);
% check if sequence is ok. If not --> dont turn laser on
if strcmpi(serial_answer,'Sequence:OK')
    disp('Sequence reported OK')
    pause(0.05)
    send_string=['TALKINGTO:' 'oltSync:00-1a-0c-9e' ':start'];
    writeline(serpo,send_string);
end
if strcmpi(serial_answer,'Sequence:Error')
    disp('Sequence not correct')
end


while OPTOcam_vid1.FramesAcquired < (OPTOcam_frames_to_capture)
    drawnow limitrate
end

stoppreview(OPTOcam_vid1)
stoppreview(OPTOcam_vid2)
stop(OPTOcam_vid1);
stop(OPTOcam_vid2);


%% stop laser
send_string=['TALKINGTO:' 'oltSync:00-1a-0c-9e' ':stop'];
writeline(serpo,send_string);
pause(0.1)
clear serpo

if ~isinf(nr_of_images)
    disp('saving...')
    OPTOcam_data1 = getdata(OPTOcam_vid1,OPTOcam_frames_to_capture);
    OPTOcam_data2 = getdata(OPTOcam_vid2,OPTOcam_frames_to_capture);
    cntr=0;
    for image_save_number=1:2:OPTOcam_frames_to_capture
        imgA_path=fullfile(ImagePath,['CAM1_PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
        imgB_path=fullfile(ImagePath,['CAM1_PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
        imwrite(OPTOcam_data1(:,:,:,image_save_number),imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
        imwrite(OPTOcam_data1(:,:,:,image_save_number+1),imgB_path,'compression','none');

        imgA_path=fullfile(ImagePath,['CAM2_PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
        imgB_path=fullfile(ImagePath,['CAM2_PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
        imwrite(OPTOcam_data2(:,:,:,image_save_number),imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
        imwrite(OPTOcam_data2(:,:,:,image_save_number+1),imgB_path,'compression','none');


        cntr=cntr+1
    end
end
disp('done')
