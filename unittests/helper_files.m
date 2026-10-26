function f = helper_files(kind, n)
%HELPER_FILES Example image files of the PIVlab folder (column cell array of full paths).
%   f = helper_files('jet', n)          n pairs Jet_0001A.jpg, Jet_0001B.jpg, ... (grey values, n <= 5)
%   f = helper_files('distortion', n)   n pairs of the fisheye example (strong barrel distortion, n <= 5):
%                                       Example_data/sphere_wake_distorted/particle_images
%   f = helper_files('colour', n)       n colour images (time resolved): the jet images (A, B, A, ...)
%                                       tinted and saved as RGB jpg in tempdir (no colour example in
%                                       Example_data)
data = fullfile(helper_root(), 'Example_data');
switch kind
    case 'jet'
        f = cell(2*n, 1);
        for i = 1:n
            f{2*i-1} = fullfile(data, sprintf('Jet_%04dA.jpg', i));
            f{2*i}   = fullfile(data, sprintf('Jet_%04dB.jpg', i));
        end
    case 'distortion'
        f = cell(2*n, 1);
        for i = 1:n
            f{2*i-1} = fullfile(data, 'sphere_wake_distorted', 'particle_images', sprintf('cam1_%04d_A.jpg', i));
            f{2*i}   = fullfile(data, 'sphere_wake_distorted', 'particle_images', sprintf('cam1_%04d_B.jpg', i));
        end
    case 'colour'
        grey = helper_files('jet', ceil(n / 2));
        folder = fullfile(tempdir, 'PIVlab_test_colour_images');
        if ~isfolder(folder)
            mkdir(folder);
        end
        tint = cat(3, 1, 0.8, 0.55); % reddish: the three channels differ
        f = cell(n, 1);
        for i = 1:n
            f{i} = fullfile(folder, sprintf('colour_%06d.jpg', i - 1));
            if ~isfile(f{i})
                I = im2double(imread(grey{i}));
                imwrite(I .* tint, f{i}, 'Quality', 95);
            end
        end
    otherwise
        error('helper_files: unknown kind %s', kind);
end
end
