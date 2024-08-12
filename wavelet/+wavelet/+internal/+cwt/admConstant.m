function cpsi = admConstant(wavname,morseparams)
% Admissibility constants are not magnitude-squared here because
% we are using a delta distribution as the reconstruction wavelet
% Morlet's single integral formula.
%
% This function is for internal use only, it may change in a future
% release.
%
% Lilly,J.M. & Olhede, S. (2009) Higher-order properties of analytic
% wavelets IEEE Transactions on Signal Processing, 57(1),146-160.

%   Copyright 2017-2021 The MathWorks, Inc.

%# codegen

% The following is needed for code generation
if isempty(morseparams)
    ga = 3;
    be = 20;
else
    ga = morseparams(1);
    be = morseparams(2);
end

cpsi = 1.0;
if isempty(coder.target)

    if strcmpi(wavname,'bump')
        mu = 5;
        sigma = 0.6;
        bumpwav = @(w)abs(2*exp(1)*exp(-1./(1-((w-mu)/sigma).^2)))./w;
        cpsi = integral(bumpwav,mu-sigma,mu+sigma);

    elseif strcmpi(wavname,'morse')
        anorm = wavelet.internal.cwt.morsenormconstant(ga,be);
        cpsi = anorm/ga*gamma(be/ga);  % Lily and Olhede, 2009
        % Equivalent to the following but has better convergence
        % morsewav = @(w)abs(anorm*w.^be.*exp(-w.^ga))./w;
        % cpsi = integral(morsewav,0,Inf);

    elseif strcmpi(wavname,'amor')
        cf = 6;
        morlwav = @(w)abs(2*exp(-(w-cf).^2/2))./w;
        cpsi = integral(morlwav,0,Inf);
    end

else

    if strcmpi(wavname,'bump')
        mu = 5;
        sigma = 0.6;
        bumpwav = @(w)abs(2*exp(1)*exp(-1./(1-((w-mu)/sigma).^2)))./w;
        cpsi = quadgk(bumpwav,mu-sigma,mu+sigma);

    elseif strcmpi(wavname,'morse')
        anorm = wavelet.internal.cwt.morsenormconstant(ga,be);
        cpsi = anorm/ga*gamma(be/ga);  % Lily and Olhede, 2009
        % Equivalent to the following but has better convergence
        % morsewav = @(w)abs(anorm*w.^be.*exp(-w.^ga))./w;
        % cpsi = integral(morsewav,0,Inf);

    elseif strcmpi(wavname,'amor')
        cf = 6;
        morlwav = @(w)abs(2*exp(-(w-cf).^2/2))./w;
        cpsi = quadgk(morlwav,0,Inf);
    end




end






