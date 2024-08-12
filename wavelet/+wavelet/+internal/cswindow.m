function g = cswindow(winname,bw,Lbins)
%   This function is for internal use only. It may be changed or removed
%   in a future release.
%
%   g = cswindow(winname,bw,Lbins);
%   winname is the window name. Supported windows are:
%   "hann", "hamming", "itersine", "blackmanharris", and "barlett"
%   bw are the window bandwidths rounded to integer values.
%   Note that in the CQT, these are compactly supported windows in
%   frequencies. See references for details. The windows are defined on
%   the unit frequency grid (-1/2,1/2).  The definitions differ slightly
%   from those used in the Signal Processing Toolbox functions, hann(),
%   because a number of those are defined on a different interval. They are
%   equivalent if you make the intervals equivalent.

%   Copyright 2017-2020 The MathWorks, Inc.

%   Lbins is the number of frequency bins constructed from the original
%   logarithmically spaced frequency grid. This is used here only to
%   designate the DC bin and the Nyquist bins which used "plateau"
%   frequency windows.

%   References:
%   Holighaus, N., Doerfler, M., Velasco, G.A., & Grill,T.
%   (2013) "A framework for invertible real-time constant-Q transforms",
%   IEEE Transactions on Audio, Speech, and Language Processing, 21, 4,
%   pp. 775-785.
%
%   Velasco, G.A., Holighaus, N., Doerfler, M., & Grill, Thomas. (2011)
%   "Constructing an invertible constant-Q transform with nonstationary
%   Gabor frames", Proceedings of the 14th International Conference on
%   Digital Audio Effects (DAFx-11), Paris, France.

%#codegen

isMATLAB = isempty(coder.target);

if isStringScalar(winname)
    winname = convertStringToChars(winname);
end

nWin = numel(bw);
g = cell(nWin,1);

switch winname
    case 'hann'
        
        if isMATLAB
            winfun = @(L)winhann(L);
            g = arrayfun(winfun,bw,'uniformoutput',false);
        else
            % Code to replace 'arrayfun' function since code generation
            % does not support the 'false' value of 'UniformOutput' option
            for ii = 1:nWin
                g{ii} = winhann(bw(ii));
            end
        end
        
        %   The DC and Nyquist windows
        %   Setup "Tukey" window for 0- and Nyquist-frequency
        %   Algorithm for computing the plateau windows centered at DC
        %   and Nyquist is due to Holinghaus and Velasco
        if bw(1) > bw(2)
            g{1} = ones(bw(1),1,'like',bw);
            g{1}((floor(bw(1)/2)-floor(bw(2)/2)+1):(floor(bw(1)/2)+...
                ceil(bw(2)/2))) = winhann(bw(2));
            
        end
        
        if bw(Lbins+2) > bw(Lbins+3)
            g{Lbins+2} = ones(bw(Lbins+2),1,'like',bw);
            g{Lbins+2}((floor(bw(Lbins+2)/2)-floor(bw(Lbins+3)/2)+1):(floor(bw(Lbins+2)/2)+...
                ceil(bw(Lbins+3)/2))) = winhann(bw(Lbins+3));
            
        end
        
    case 'hamming'
        
        if isMATLAB
            winfun = @(L)winhamming(L);
            g = arrayfun(winfun,bw,'uniformoutput',false);
        else
            % Code to replace 'arrayfun' function since code generation
            % does not support the 'false' value of 'UniformOutput' option
            for ii = 1:nWin
                g{ii} = winhamming(bw(ii));
            end
        end
        
        %   The DC and Nyquist windows
        %   Setup "Tukey" window for 0- and Nyquist-frequency
        %   Algorithm for computing the plateau windows centered at DC
        %   and Nyquist is due to Holinghaus and Velasco
        if bw(1) > bw(2)
            g{1} = ones(bw(1),1,'like',bw);
            g{1}((floor(bw(1)/2)-floor(bw(2)/2)+1):(floor(bw(1)/2)+...
                ceil(bw(2)/2))) = winhann(bw(2));
            
        end
        
        if bw(Lbins+2) > bw(Lbins+3)
            g{Lbins+2} = ones(bw(Lbins+2),1,'like',bw);
            g{Lbins+2}((floor(bw(Lbins+2)/2)-floor(bw(Lbins+3)/2)+1):(floor(bw(Lbins+2)/2)+...
                ceil(bw(Lbins+3)/2))) = winhann(bw(Lbins+3));
            
        end
        
    case 'itersine'
        
        if isMATLAB
            winfun = @(L)winitersine(L);
            g = arrayfun(winfun,bw,'uniformoutput',false);
        else
            % Code to replace 'arrayfun' function since code generation
            % does not support the 'false' value of 'UniformOutput' option
            for ii = 1:nWin
                g{ii} = winitersine(bw(ii));
            end
        end
        
        %   The DC and Nyquist windows
        %   Setup "Tukey" window for 0- and Nyquist-frequency
        %   Algorithm for computing the plateau windows centered at DC
        %   and Nyquist is due to Holinghaus and Velasco
        if bw(1) > bw(2)
            g{1} = ones(bw(1),1,'like',bw);
            g{1}((floor(bw(1)/2)-floor(bw(2)/2)+1):(floor(bw(1)/2)+...
                ceil(bw(2)/2))) = winhann(bw(2));
            
        end
        
        if bw(Lbins+2) > bw(Lbins+3)
            g{Lbins+2} = ones(bw(Lbins+2),1,'like',bw);
            g{Lbins+2}((floor(bw(Lbins+2)/2)-floor(bw(Lbins+3)/2)+1):(floor(bw(Lbins+2)/2)+...
                ceil(bw(Lbins+3)/2))) = winhann(bw(Lbins+3));
            
        end
        
    case 'blackmanharris'
        
        if isMATLAB
            winfun = @(L)winblackmanharris(L);
            g = arrayfun(winfun,bw,'uniformoutput',false);
        else
            % Code to replace 'arrayfun' function since code generation
            % does not support the 'false' value of 'UniformOutput' option
            for ii = 1:nWin
                g{ii} = winblackmanharris(bw(ii));
            end
        end
        
        %   The DC and Nyquist windows
        %   Setup "Tukey" window for 0- and Nyquist-frequency
        %   Algorithm for computing the plateau windows centered at DC
        %   and Nyquist is due to Holinghaus and Velasco
        if bw(1) > bw(2)
            g{1} = ones(bw(1),1,'like',bw);
            g{1}((floor(bw(1)/2)-floor(bw(2)/2)+1):(floor(bw(1)/2)+...
                ceil(bw(2)/2))) = winhann(bw(2));
            
        end
        
        if bw(Lbins+2) > bw(Lbins+3)
            g{Lbins+2} = ones(bw(Lbins+2),1,'like',bw);
            g{Lbins+2}((floor(bw(Lbins+2)/2)-floor(bw(Lbins+3)/2)+1):(floor(bw(Lbins+2)/2)+...
                ceil(bw(Lbins+3)/2))) = winhann(bw(Lbins+3));
            
        end
        
    case 'bartlett'
        
        if isMATLAB
            winfun = @(L)wintriang(L);
            g = arrayfun(winfun,bw,'uniformoutput',false);
        else
            % Code to replace 'arrayfun' function since code generation
            % does not support the 'false' value of 'UniformOutput' option
            for ii = 1:nWin
                g{ii} = wintriang(bw(ii));
            end
        end
        
        %   The DC and Nyquist windows
        %   Setup "Tukey" window for 0- and Nyquist-frequency
        %   Algorithm for computing the plateau windows centered at DC
        %   and Nyquist is due to Holinghaus and Velasco
        if bw(1) > bw(2)
            g{1} = ones(bw(1),1,'like',bw);
            g{1}((floor(bw(1)/2)-floor(bw(2)/2)+1):(floor(bw(1)/2)+...
                ceil(bw(2)/2))) = winhann(bw(2));
            
        end
        
        if bw(Lbins+2) > bw(Lbins+3)
            g{Lbins+2} = ones(bw(Lbins+2),1,'like',bw);
            g{Lbins+2}((floor(bw(Lbins+2)/2)-floor(bw(Lbins+3)/2)+1):(floor(bw(Lbins+2)/2)+...
                ceil(bw(Lbins+3)/2))) = winhann(bw(Lbins+3));
            
        end
        
    otherwise
        
        coder.internal.error('Wavelet:FunctionInput:UnsupportedWindow',winname);
        
end


function g = winhann(L)

if mod(L,2) == 0
    xi = [0:1/L:0.5-1/L,-0.5:1/L:-1/L];
    xi = xi(:);
else
    xi = [0:1/L:0.5-0.5/L,-0.5+0.5/L:1/L:-1/L];
    xi = xi(:);
end

g = 0.5+0.5*cos(2*pi*xi);
g = g.*(abs(xi)<0.5);


function g = winhamming(L)

if mod(L,2) == 0
    xi = [0:1/L:0.5-1/L,-0.5:1/L:-1/L];
    xi = xi(:);
else
    xi = [0:1/L:0.5-0.5/L,-0.5+0.5/L:1/L:-1/L];
    xi = xi(:);
end

g = 0.54+0.46*cos(2*pi*xi);
g = g.*(abs(xi)<0.5);


function g = winitersine(L)
if mod(L,2) == 0
    xi = [0:1/L:0.5-1/L,-0.5:1/L:-1/L];
    xi = xi(:);
else
    xi = [0:1/L:0.5-0.5/L,-0.5+0.5/L:1/L:-1/L];
    xi = xi(:);
end

g = sin(pi/2*cos(pi*xi).^2);
g = g.*(abs(xi)<0.5);


function g = winblackmanharris(L)

if mod(L,2) == 0
    xi = [0:1/L:0.5-1/L,-0.5:1/L:-1/L];
    xi = xi(:);
else
    xi = [0:1/L:0.5-0.5/L,-0.5+0.5/L:1/L:-1/L];
    xi = xi(:);
end

g = 0.35875 + 0.48829*cos(2*pi*xi) + 0.14128*cos(4*pi*xi) + ...
    0.01168*cos(6*pi*xi);
g = g.*(abs(xi)<0.5);


function g = wintriang(L)

if mod(L,2) == 0
    xi = [0:1/L:0.5-1/L,-0.5:1/L:-1/L];
    xi = xi(:);
else
    xi = [0:1/L:0.5-0.5/L,-0.5+0.5/L:1/L:-1/L];
    xi = xi(:);
end

g = 1-2*abs(xi);
g = g.*(abs(xi)< 0.5);



