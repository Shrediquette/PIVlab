function size = pivparpool(cmd,core)
% parpool size: pivparpool('size')
% parpool close: pivparpool('close')
% parpool open: pivparpool('open', 2)

if nargin < 1
	error('Requires at least one input argument')
end
if nargin == 1
    if verLessThan('matlab', '8.2')
        if strcmp(cmd,'size')
            size = matlabpool('size');
        elseif strcmp(cmd,'close')
            matlabpool close;
        else
            error('Wrong input arguments.')
        end
    else
        poolobj = gcp('nocreate');
        if strcmp(cmd,'size')
            if isempty(poolobj) 
                size = 0;
            else
                size = poolobj.NumWorkers;
            end
        elseif strcmp(cmd,'close')
            delete(poolobj);
        else
            error('Wrong input arguments.')
        end
    end
elseif nargin == 2
    if verLessThan('matlab', '8.2')
        if strcmp(cmd,'open')
            matlabpool('open','local',core);
        else
            error('Wrong input arguments.')
        end
    else
        if strcmp(cmd,'open')
            parpool('local',core);
        else
            error('Wrong input arguments.')
        end
    end
elseif nargin > 2
	error('Too many input arguments.')
end