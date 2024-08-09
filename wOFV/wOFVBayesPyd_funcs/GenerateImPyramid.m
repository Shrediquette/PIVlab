function ImPyramid = GenerateImPyramid(I,PyramidLevels,ImFilt)

ImPyramid{1} = I;

%generate the image pyramid
for iii = 2:PyramidLevels
    % Update the image in the pyramid
    Img = ImPyramid{iii-1};

    if ImFilt.Flag == true
        % Apply a low-pass filter to the images -- Gaussian blurring kernel
        LowPassKernel = [1/16,1/8,1/16;1/8,1/4,1/8;1/16,1/8,1/16];
        FiltImg = conv2(Img,LowPassKernel,'same');
    else
        FiltImg = Img;
    end

    % Interpolate
    [m,n] = size(Img);
    [X,Y] = meshgrid(1:n,1:m);
    X = X + 1/2; Y = Y + 1/2;

    %symmetric BCs
    X(X>n) = n;
    X(X<1) = 1;
    X(Y>m) = m;
    X(Y<1) = 1;

    Temp = interp2(FiltImg,X,Y,'spline');
    ImPyramid{iii} = Temp(1:2:m,1:2:n);
end
