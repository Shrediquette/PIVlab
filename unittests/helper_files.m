function f = helper_files(kind, n)
%HELPER_FILES Example image files of the PIVlab folder (column cell array of full paths).
%   f = helper_files('jet', n)            n pairs Jet_0001A.jpg, Jet_0001B.jpg, ... (grey values)
%   f = helper_files('distortion', n)     n pairs of the fisheye images (strong barrel distortion)
%   f = helper_files('fuerteventura', n)  n colour images (time resolved)
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
            f{2*i-1} = fullfile(data, 'worst_case_distortion', sprintf('PIVlab_%04d_A.jpg', i-1));
            f{2*i}   = fullfile(data, 'worst_case_distortion', sprintf('PIVlab_%04d_B.jpg', i-1));
        end
    case 'fuerteventura'
        f = cell(n, 1);
        for i = 1:n
            f{i} = fullfile(data, sprintf('Fuerteventura_%06d.jpeg', i-1));
        end
    otherwise
        error('helper_files: unknown kind %s', kind);
end
end
