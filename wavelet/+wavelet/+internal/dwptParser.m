classdef dwptParser < handle
%dwptParser is a function for parsing value-only inputs, flags, and
%   name-value pairs for the dwpt and idwpt function. This function is for
%   internal use only. It may be removed in the future.

%   Copyright 2019-2020 The MathWorks, Inc.
%#codegen
    
    properties (Constant,Hidden)
        WaveletNameDefault = 'fk18'
        FullTreeDefault = false
        BoundaryDefault = 'reflect'
    end
    properties (Access = private,Hidden)
        fnName
        LevelDefault
        LowpassTemp
        HighpassTemp
        BoundaryMethod
        Boundary
        SignalType
    end
    properties (Access = public)
        WaveletName
        Lowpass
        Highpass
        DataType
        SignalLength
        FullTree
        NumChannels
        Level = 0;
        isInverse
        BookKeeping
        ExtensionMode
    end
    
    methods
        function this = dwptParser(signalLength,numChannels,signalType,funcType,varargin)
            
            % assign computation-related values
            validStrings = {'dwpt','idwpt'};
            this.fnName = validatestring(funcType,validStrings,'dwptParser','fnName');
            this.isInverse = strcmpi(this.fnName,'idwpt');
            this.SignalLength = signalLength;
            this.SignalType = signalType;
            this.NumChannels = numChannels;      
            
            this.parseInputParams(varargin{:})
                     
            if ~this.isInverse
                % validate input parameters
                validateattributes(this.Level,{'numeric'},...
                    {'nonnan','finite','scalar','positive','integer'},'dwpt','Level');
                validateattributes(this.FullTree,{'logical','numeric'},...
                    {'scalar','nonnan','finite'},'dwpt','FullTree');
                coder.internal.errorIf(this.Level>floor(log2(signalLength)),...
                    'Wavelet:modwt:MRALevel');
            else
                % validate input parameters
                validateattributes(this.BookKeeping,{'numeric'},...
                    {'nonnan','finite','vector','positive','integer'},'idwpt','L');

            end
            
            this.BoundaryMethod = validatestring(this.Boundary,...
                        {'reflection','periodic'},this.fnName,'Boundary');
            if strcmp(this.BoundaryMethod,'reflection')
                this.ExtensionMode = 'sym';
            else
                this.ExtensionMode = 'per';
            end
        end
        % Parse value-only input-------------------------------------------
        function parseInputParams(this,varargin)
            
            L = length(varargin);
            tempInputAll = cell(1,L);
            [tempInputAll{:}] = convertStringsToChars(varargin{:});
            
            if this.isInverse
                this.BookKeeping = tempInputAll{1};
                tempInput = cell(1,L-1);
                [tempInput{:}] = tempInputAll{2:L};
                L = L-1;
            else
                tempInput = tempInputAll;
            end
                       
            if ~isempty(tempInput)
                % assume a wavelet name is first given
                if ischar(tempInput{1}) && ~strncmpi(tempInput{1},'FullTree',2)...
                        && ~strncmpi(tempInput{1},'Level',1) &&...
                        ~strncmpi(tempInput{1},'Boundary',2)
                    this.WaveletName = tempInput{1};
                    [this.LowpassTemp,this.HighpassTemp] = ...
                        this.getFilters(this.WaveletName,'double');
                    indexFlag = 2;
                else
                    indexFlag = 1;
                end

                % check for the first char input rather than wavelet name
                if L < indexFlag
                    nameValuePairs = {};
                else
                    coder.unroll();
                    for indexFirstNVPair = indexFlag:L
                        if ischar(tempInput{indexFirstNVPair})
                            break;
                        end
                    end
                    % if no n-v pair
                    if indexFirstNVPair == L
                        indexFirstNVPair = indexFirstNVPair + 1;
                    end

                    % nonempty value only inputs
                    if indexFlag <= indexFirstNVPair-1
                        if ~isempty(this.WaveletName) % if wavelet is specified
                            coder.internal.error('Wavelet:FunctionInput:InvalidWavFilter');
                        end
                        valueOnlyInputs = cell(1,indexFirstNVPair-indexFlag);
                        [valueOnlyInputs{:}] = tempInput{indexFlag:indexFirstNVPair-1};
                        coder.internal.errorIf((length(valueOnlyInputs)~=2),...
                            'Wavelet:dwpt:InvalidFilterInput');
                        this.LowpassTemp = valueOnlyInputs{1};
                        this.HighpassTemp = valueOnlyInputs{2};
                        
                        % validate filter inputs
                        validateattributes(this.LowpassTemp,{'single','double'},...
                            {'nonempty','finite','nonnan','vector'},this.fnName,'Lowpass filter');
                        validateattributes(this.HighpassTemp,{'single','double'},...
                            {'nonempty','finite','nonnan','vector'},this.fnName,'Highpass filter');
                    end

                    if L-indexFirstNVPair+1 > 0
                        nameValuePairs = cell(1,L-indexFirstNVPair+1);
                        [nameValuePairs{:}] = tempInput{indexFirstNVPair:L};
                    else
                        nameValuePairs = {};
                    end
                end % end if isempty(indexFirstNVPair)
            else
                nameValuePairs = {};
            end
            % check and assign filters
            this.checkFilters();
            
            % check for name-value pairs
            if coder.target('MATLAB')
                this.parseInputsMatlab(nameValuePairs{:});
            else
                this.parseInputsCodegen(nameValuePairs{:});
            end
        end
        % MATLAB ----------------------------------------------------------
        function parseInputsMatlab(this,varargin)
            p = inputParser;
            if(mod(length(varargin),2)~=0)          
                error(message('Wavelet:dwpt:UnpairedNameValue'));
            end
            % parse input                       
            if ~this.isInverse % for DWPT
                addParameter(p,'FullTree',this.FullTreeDefault);
                addParameter(p,'Level',this.LevelDefault);
                addParameter(p,'Boundary',this.BoundaryDefault);
                parse(p,varargin{:});                    
            else
                addParameter(p,'Boundary',this.BoundaryDefault);
                parse(p,varargin{:}); 
            end
            % assign value
            fieldNames = fields(p.Results);
            for ii = 1:length(fields(p.Results))
                this.(fieldNames{ii}) = p.Results.(fieldNames{ii});  
            end
        end
        % Codegen parser----------------------------------------------------------------------
        function parseInputsCodegen(this,varargin)      
           % Codegen parser
           % ParitalMatching true
           poptions = struct( ...
               'CaseSensitivity',false, ...
               'PartialMatching','first', ...
               'StructExpand',false, ...
               'IgnoreNulls',true);
           if ~this.isInverse % for DWPT    
               params = {'FullTree','Level','Boundary'};           
               pstruct = coder.internal.parseParameterInputs(params,poptions,varargin{:});
               this.Level = double(coder.internal.getParameterValue(pstruct.Level,...
                  this.LevelDefault,varargin{:}));
               this.FullTree = coder.internal.getParameterValue(pstruct.FullTree,...
                  this.FullTreeDefault,varargin{:});
           else
               params = {'Boundary'};
               pstruct = coder.internal.parseParameterInputs(params,poptions,varargin{:});
               this.Level = 0;
               this.FullTree = false;
           end
           this.Boundary = coder.internal.getParameterValue(pstruct.Boundary,...
                  this.BoundaryDefault,varargin{:});
        end 
    end % end Methods
    %% wavelet filters related functions
    methods 
        function checkFilters(this)            
        % assign and check wavelet filter coefficients
            if strcmp(this.SignalType,'single') ||...
                isa(this.LowpassTemp,'single') ||...
                isa(this.HighpassTemp,'single')
                this.DataType = 'single';           
            else
                this.DataType = 'double';
            end
            
            assert(coder.internal.isConst(this.DataType));       
            
            if isempty(this.LowpassTemp) && isempty(this.HighpassTemp)
            % all empty then use default
                [this.Lowpass,this.Highpass] = this.getFilters(this.WaveletNameDefault,...
                    this.DataType);
            else
            % all filters are not empty
                this.Lowpass = cast(this.LowpassTemp(:).',this.DataType);
                this.Highpass = cast(this.HighpassTemp(:).',this.DataType);
            end                    

            if ~this.isInverse
                this.LevelDefault = floor(log2(this.SignalLength));
            else
                this.LevelDefault = 0;
            end
        end % end checkFilters
        %-----------------------------------------------------------------
        function [lowpass,highpass] = getFilters(this,wName,dataType)
        % get the filter coefficients
            coder.extrinsic('wfilters'); %We only call it via coder.const extrinsically.
            if coder.target('MATLAB')
                 if this.isInverse
                     [~,~,Lo,Hi] = wfilters(wName);
                 else
                     [Lo,Hi,~,~] = wfilters(wName);
                 end
            else
                 if this.isInverse
                     [~,~,Lo,Hi] = coder.const(@wfilters,wName);
                 else
                     [Lo,Hi,~,~] = coder.const(@wfilters,wName);
                 end
            end
            if strcmp(dataType,'single')
                lowpass = cast(Lo,dataType);
                highpass = cast(Hi,dataType);
            else
               lowpass = Lo;
               highpass = Hi;
            end
        end
    end
    %%
    methods(Static,Hidden=true)
       function props = matlabCodegenNontunableProperties(~)
          props = {'SignalType','DataType','WaveletName','WaveletNameDefault','isInverse','fnName'}; 
       end
    end
end

