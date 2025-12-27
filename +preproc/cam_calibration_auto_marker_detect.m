clc
clearvars
I=imread('D:\PIV Data\charuco-aquarium\PIVlab_snapshot (83).tif');%8,11 white

I=imread('D:\PIV Data\PIV_mit_charuco\charuco imgs\screen_old (7).jpg');%23,24 'black

I=imread('D:\PIV Data\PIV_mit_charuco\panda\PIVlab_snapshot (0).tif');%23,24 'black'

I=imadjust(im2gray(I));

[ids,locs,detectedFamily,rejections] = readArucoMarker(I,'DICT_4X4_1000'); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie


numMarkers = length(ids);


id_pos=nan(numMarkers,3);

for i = 1:numMarkers
  loc = locs(:,:,i);
   
  % Display the marker ID and family
  %disp("Detected marker ID, Family: " + ids(i) + ", " + detectedFamily(i))  
 
  % Insert marker edges
  I = insertShape(I,"polygon",{loc},Opacity=1,ShapeColor="green",LineWidth=4);
 
  % Insert marker corners
  markerRadius = 6;
  numCorners = size(loc,1);
  markerPosition = [loc,repmat(markerRadius,numCorners,1)];
  I = insertShape(I,"FilledCircle",markerPosition,ShapeColor="red",Opacity=1);
   
  % Insert marker IDs
  center = mean(loc);
  I = insertText(I,center,ids(i),FontSize=18,BoxOpacity=1);
  id_pos(i,1)=ids(i);
  id_pos(i,2:3)=center;
end
imshow(I)

id_pos=sortrows(id_pos,1);
x_diff=abs(diff(id_pos(:,2)));

figure;plot(x_diff,'r.')


amount_rows=numel(find((x_diff>(mean(x_diff)+std(x_diff)))))+1

amount_cols=round(numMarkers/(amount_rows/2))


