function poolobj = get_or_create_local_pool(cpu_numcore, option_core)
    % Create a local parallel pool
    % default_core: number of cores in the machine 
    % option_core: number of cores specified by user

    poolobj = gcp('nocreate'); % get current pool object
    
    if isempty(poolobj)  % if no pool has been created 
        
        if option_core > cpu_numcore
            warning('on');
            warning('The number of cores %d is larger than %d, setting the number of cores to %d',option_core, cpu_numcore,cpu_numcore);
            option_core = cpu_numcore;
        end
        
        poolobj = parpool('local',option_core);
    end

end