function [x,y,u,v,typevector, correlation_map] = run_correlation(image_dir, filenames1, filenames2, p, s, nr_of_cores, tform)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    n = length(filenames1);
    x = cell(n,1);
    y = x;
    u = x;
    v = x;
    typevector = x; % typevector will be 1 for regular vectors, 0 for masked areas
    correlation_map = x; % correlation coefficient
    if nr_of_cores > 1
        try
		    local_cluster = parcluster('local'); % single node
		    corenum = local_cluster.NumWorkers; % fix : get the number of cores available
	    catch
		    warning('on');
		    warning('parallel local cluster can not be created, assigning number of cores to 1');
		    nr_of_cores = 1;
        end
    end
    if nr_of_cores > 1
	    if misc.pivparpool('size') < nr_of_cores
		    misc.pivparpool('open', nr_of_cores);
	    end
    
	    parfor i = 1:numel(x)  % index must increment by 1
		    [x{i}, y{i}, u{i}, v{i}, typevector{i},correlation_map{i}] = ...
			    piv.piv_analysis(image_dir, filenames1{i}, filenames2{i},p,s,nr_of_cores,false);
        end
    else % sequential loop
	    for i = 1:numel(x)  % index must increment by 1
		    [x{i}, y{i}, u{i}, v{i}, typevector{i}, correlation_map{i}] = ...
			    piv.piv_analysis(image_dir, filenames1{i}, filenames2{i},p,s,nr_of_cores,false, tform);
            if i == 1
                disp("Processing: ")
            else
                fprintf(repmat('\b', 1, length(progress_string) + 1));
            end
            progress_string = [int2str(i / numel(x) * 100), ' %'];
            disp(progress_string);
        end
    end
end
