function [max_possible_images] = PIVlab_capture_max_possible_images(ROI,frame_nr_display,bitmode)
if bitmode>8
	bitmode=16; %even if data from camera is only 10 or 12 bit, the datatype it will be stored in is uint16.
end
[~,systemview] = memory;
mem_free=systemview.PhysicalMemory.Available/1024^3;
ram_reserve=0.5; %how much RAM (in GB) is needed for Matlab operations not including image capture. This is a guessed number that probably depends on computer, Matlab version etc.
%                                                          twice the RAM is needed to use getdata
max_possible_images=floor((mem_free-ram_reserve) / (ROI(3)*ROI(4)*bitmode/8/1024^3 *2) /2); %max possible double images
