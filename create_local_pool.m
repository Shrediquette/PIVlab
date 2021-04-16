function create_local_pool(default_core, option_core)
    % Create a local parallel pool
    % default_core: number of cores in the machine 
    % option_core: number of cores specified by user

    poolobj = gcp('nocreate'); % get current pool object
    
    if isempty(poolobj)  % if no pool has been created 
        parpool('local',min(default_core,option_core))
    end

end