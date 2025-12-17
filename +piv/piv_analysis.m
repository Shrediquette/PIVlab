function [x, y, u, v, typevec,corr_map] = piv_analysis(dir, filename1, filename2,...
    preprocess_setting, piv_setting, nr_of_cores, graph, tform)
    % wrapper function to do PIV preprocess and PIV fft for a pair of image

    % INPUT
    %dir: directory containing images
    % filename1: the first image
    % filename2: the second image 
    % preprocess_setting: cell of dimension 10 x 2
    % piv_setting: cell of dimension 13 x 2
    % nr_of_cores: number of cores specified by user
    % graph: bool, whether to display graphical output ( not available
    % for parallel worker)
    % tform: tform2d for unwarping images
    
    % OUTPUT
    % x, y: coordinates of vectors
    % u, v: resulted components of vector field
    % typevec: type vector
    % corr_map: corellation map

    image1 = imread(fullfile(dir, filename1)); % read images
    image2 = imread(fullfile(dir, filename2));
    % If a tform argument exists then apply it to the images
    if nargin == 8
        image1 = dewarp(image1, tform);
        image2 = dewarp(image2, tform);
    end
    image1 = preproc.PIVlab_preproc(image1, preprocess_setting{1:10,2});
    image2 = preproc.PIVlab_preproc(image2, preprocess_setting{1:10,2});
    [x, y, u, v, typevec,corr_map,~] = piv.piv_FFTmulti(...
        image1, image2, piv_setting{1:15,2}...
    ); %actual PIV analysis
        
    if graph && nr_of_cores == 1 % won't run in parallel mode
        imagesc(double(image1)+double(image2));colormap('gray');
        hold on
        quiver(x,y,u,v,'g','AutoScaleFactor', 1.5);
        hold off;
        axis image;
        title(['Raw result ' filename1],'interpreter','none')
        set(gca,'xtick',[],'ytick',[])
        drawnow;
    end


end


function img = dewarp(img, tform)
    % Dewarp images
    [~, ref] = imwarp(imag, tform, 'cubic'); % There may be a prettier way to get the ref object
    ref.ImageSize = size(img); % imwarp normally dramatically scales down the image
    [img, ~] = imwarp(img, tform, 'cubic', 'OutputView', ref);
end