classdef pivprogress < handle
    
%   Inspired by the parfor_progress script made by Daniel Terry:
%   https://www.mathworks.com/matlabcentral/fileexchange/53773-parfor-progressbar

% Public properties
properties (SetAccess=protected, GetAccess=public)
    hdl;      % Waitbar figure object handle
    N;        % Total number of iterations expected before completion
end

properties (Dependent, GetAccess=public)
    percent;  % Percentage of completed iterations
end

% Internal properties
properties (SetAccess=protected, GetAccess=protected, Hidden)
    ipcfile;  % Path to temporary file for inter-process communication
    htimer;   % Timer object that checks ipcfile for completed iterations
end

methods
    % Create a new progress bar with N_init iterations before completion.
    function this = pivprogress(N_init, handle)
        % Create a unique inter-process communication file.
        for i=1:10
            f = sprintf('%s%d.txt', mfilename, round(rand*1000));
            this.ipcfile = fullfile(tempdir, f);
            if ~exist(this.ipcfile,'file'), break; end
        end
        if exist(this.ipcfile,'file')
            error('Too many temporary files. Clear out tempdir.');
        end
        % Create a new waitbar 
        this.N = N_init;
        if nargin == 2
            this.hdl = handle;% waitbar(0, varargin{:});
        else
            this.hdl = [];
        end
        % Create timer to periodically update the waitbar in the GUI thread.
        this.htimer = timer( 'ExecutionMode','fixedSpacing', 'Period',0.5, ...
                             'BusyMode','drop', 'Name',mfilename, ...
                             'TimerFcn',@(x,y)this.tupdate);
        start(this.htimer);
    end
    
    function delete(this)
        this.close();
    end
    
    function close(this)
    % Closer the progress bar and clean up internal state.
        % Stop the timer
        if isa(this.htimer,'timer') && isvalid(this.htimer)
            stop(this.htimer);
            pause(0.01);
            delete(this.htimer);
        end
        this.htimer = [];
        % Delete the IPC file.
        if exist(this.ipcfile,'file')
            delete(this.ipcfile);
        end
        this.hdl = [];
    end
    
    function percent = get.percent(this)
    % Calculate the fraction of completed iterations from IPC file.
        if ~exist(this.ipcfile, 'file')
            percent = 0;  % File may not exist before the first iteration
        else
            fid = fopen( this.ipcfile, 'r' );
            percent = sum(fscanf(fid, '%d')) / this.N;
            percent = max(0, min(1,percent) );
            fclose(fid);
        end
    end
    
    function iterate(this, Nitr)
    % Update the progress bar by Nitr iterations (or 1 if not specified).
        if nargin<2,  Nitr = 1;  end
        fid = fopen(this.ipcfile, 'a');
        fprintf(fid, '%d\n', Nitr);
        fclose(fid);
    end
end %public methods

methods (Access=protected, Hidden)
    function tupdate(this)
    % Check the IPC file and update the waitbar with progress.
        if ishandle(this.hdl)
%             waitbar( this.percent, this.wbh, ['Progress: %' num2str(floor(100*this.percent))]);
            set(this.hdl, 'string' , ['Total progress: ' num2str(floor(100*this.percent)) '%']);
            drawnow;
        elseif isempty(this.hdl)
            clc
            disp([num2str(floor(100*this.percent)) ' %']);
        else
            % Kill the timer if the waitbar is closed.
            close(this);
				end
				if exist('cancel_piv','file')
					close(this)
				end
    end
end %private methods

end %classdef
