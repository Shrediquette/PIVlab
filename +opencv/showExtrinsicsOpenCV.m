function showExtrinsicsOpenCV(cameraParams)

R = cameraParams.RotationMatrices;
t = cameraParams.TranslationVectors;
wp = cameraParams.WorldPoints;

numImages = size(R,3);

xmin = min(wp(:,1));
xmax = max(wp(:,1));
ymin = min(wp(:,2));
ymax = max(wp(:,2));

board = [xmin ymin 0;
    xmax ymin 0;
    xmax ymax 0;
    xmin ymax 0]';

camSize = max(xmax-xmin,ymax-ymin)/15;


hold on
axis equal
grid on
view(3)

xlabel("X")
ylabel("Y")
zlabel("Z")

%% Board surface
fill3(board(1,:),board(2,:),board(3,:), ...
    [0.85 0.85 0.85], ...
    FaceAlpha=0.6,EdgeColor="k")

%% Marker centers (WorldPoints)
plot3(wp(:,1),wp(:,2),zeros(size(wp,1),1), ...
    'k.','MarkerSize',15)

%% Board origin
plot3(0,0,0,'ro','MarkerSize',10,'LineWidth',2)

%% Board axes
axisLength = camSize*3;

plot3([0 axisLength],[0 0],[0 0],'r','LineWidth',2) % X axis
plot3([0 0],[0 axisLength],[0 0],'r','LineWidth',2) % Y axis

text(axisLength,0,0,'X','Color','r','FontWeight','bold')
text(0,axisLength,0,'Y','Color','r','FontWeight','bold')

%% Different colors for cameras
colors = lines(numImages);

for i = 1:numImages

    Ri = R(:,:,i);
    ti = t(i,:);

    Rcw = Ri';
    C   = -ti * Rcw;

    plotCamera( ...
        Location=C, ...
        Orientation=Rcw, ...
        Size=camSize, ...
        Color=colors(i,:), ...
        Label=num2str(i), ...
        AxesVisible=true)

end
set(gca,CameraUpVector=[0 -1 0])
%cameratoolbar("SetCoordSys","y")
camproj("perspective")