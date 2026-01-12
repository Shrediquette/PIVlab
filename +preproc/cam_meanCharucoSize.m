function [avg_vert,avg_horiz] = cam_meanCharucoSize(tmp_img,markerFamily,checkerSize,markerSize)
%Measures the size of the Aruco markers, then uses the ratio of markersize
%and checkersize to calculate the size of the checkers.
[~,locs] = readArucoMarker(tmp_img,markerFamily,'WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',4,'SquarenessTolerance',0.03); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie
N = size(locs,3);
width  = zeros(N,1);
height = zeros(N,1);
for k = 1:N
    P = locs(:,:,k);   % 4-by-2
    d12 = hypot(P(2,1)-P(1,1), P(2,2)-P(1,2));
    d23 = hypot(P(3,1)-P(2,1), P(3,2)-P(2,2));
    d34 = hypot(P(4,1)-P(3,1), P(4,2)-P(3,2));
    d41 = hypot(P(1,1)-P(4,1), P(1,2)-P(4,2));
    width(k)  = mean([d12 d34]);   % marker size in x (px)
    height(k) = mean([d23 d41]);   % marker size in y (px)
end
% --- width ---
mu_w = mean(width);
sd_w = std(width);
width(width > mu_w+sd_w) = nan;
width(width < mu_w-sd_w) = nan;

% --- height ---
mu_h = mean(height);
sd_h = std(height);
height(height > mu_h+sd_h) = nan;
height(height < mu_h-sd_h) = nan;

avg_vert=mean(height,'omitnan')*checkerSize/markerSize;
avg_horiz=mean(width,'omitnan')*checkerSize/markerSize;

%das ist die Größe der ARUCO marker... nicht der Schachbrettkaros...