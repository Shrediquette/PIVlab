function details = getdetcoef2(C,S,noisedir,level)
%   This function is for internal use only. It may change or be removed in a
%   future release.
%
%   details = getdetcoef2(C,S,noisedir,level);

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

% Obtain all the first-level wavelet coefficients
[H,V,D] = detcoef2('all',C,S,level);
% switch
Ndir = numel(noisedir);

if Ndir == 2
    % Order does not matter so we have nchoosek(3,2) possibilities
    temp_noisedir = cell(1,2);
    
    for i=1:2
        if iscell(noisedir)
            temp_noisedir{i} = char(noisedir{i});
        else
            temp_noisedir{i} = char(noisedir(i));
        end
    end
    
    tf_hv = [isequal(temp_noisedir,{'h','v'}) isequal(temp_noisedir,{'v','h'})]; %#ok<*CLARRSTR>
    tf_hd = [isequal(temp_noisedir,{'h','d'}) isequal(temp_noisedir,{'d','h'})];
    tf_vd = [isequal(temp_noisedir,{'d','v'}) isequal(temp_noisedir,{'v','d'})];
    
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % Check if the image is 2-D.
        if coder.internal.ndims(H) == 2
            % Concatenation operation.
            temp_details = coder.nullcopy(zeros([size(H) 2], 'like', C));
            % Checking if any of the tf_hv is 1 as the order of
            % coefficients does not matter. 
            if any(tf_hv)
                % Assinging the coefficeints one after the other in third
                % dimension.
                temp_details(:, :, 1) = H;
                temp_details(:, :, 2) = V;
            % Checking if any of the tf_hd is 1 as the order of
            % coefficients does not matter. 
            elseif any(tf_hd)
                temp_details(:, :, 1) = H;
                temp_details(:, :, 2) = D; 
            % Checking if any of the tf_vd is 1 as the order of
            % coefficients does not matter. 
            elseif any(tf_vd)
                temp_details(:, :, 1) = V;
                temp_details(:, :, 2) = D;        
            end
        % If the image is 3-D.
        elseif coder.internal.ndims(H) == 3
            % Concatenation operation.
            temp_details = coder.nullcopy(zeros([size(H, 1) size(H, 2) 6], 'like', C));
            % Checking if any of the tf_hv is 1 as the order of
            % coefficients does not matter. 
            if any(tf_hv)
                temp_details(:, :, 1:3) = H;
                temp_details(:, :, 4:6) = V;
            % Checking if any of the tf_hd is 1 as the order of
            % coefficients does not matter. 
            elseif any(tf_hd)
                temp_details(:, :, 1:3) = H;
                temp_details(:, :, 4:6) = D; 
            % Checking if any of the tf_vd is 1 as the order of
            % coefficients does not matter. 
            elseif any(tf_vd)
                temp_details(:, :, 1:3) = V;
                temp_details(:, :, 4:6) = D;        
            end
        end
    else
        temp_details = zeros([size(H) 2]);
        if any(tf_hv)
            temp_details = cat(3,H,V);
        elseif any(tf_hd)
            temp_details = cat(3,H,D);
        elseif any(tf_vd)
            temp_details = cat(3,V,D);
        end
    end
    
elseif Ndir == 1
    switch noisedir
        case "h"
            temp_details = H;
        case "v"
            temp_details = V;
        case "d"
            temp_details = D;
        otherwise
            temp_details = zeros(0,0);
    end
else
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % Check if the image is 2-D.
        if coder.internal.ndims(H) == 2
            % Concatenation operation.
            temp_details = coder.nullcopy(zeros([size(H) 3], 'like', C));
            temp_details(:, :, 1) = H;
            temp_details(:, :, 2) = V;    
            temp_details(:, :, 3) = D; 
        % If the image is 3-D.    
        elseif coder.internal.ndims(H) == 3
            % Concatenation operation.
            temp_details = coder.nullcopy(zeros([size(H, 1) size(H, 2) 9], 'like', C));
            temp_details(:, :, 1:3) = H;
            temp_details(:, :, 4:6) = V;    
            temp_details(:, :, 7:9) = D;    
        end
    else  
        temp_details = cat(3,H,V,D);
    end
end

details = temp_details(:);
