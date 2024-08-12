function scalf = hanscalf(wname)
%   HANSCALF Han real orthogonal scaling filters with sum and linear-phase
%   moments
%   SCALF = HANSCALF(WNAME) returns the Han real-valued orthogonal scaling
%   filter with a specified number of sum rules and linear-phase moments. 
%   These filters are characterized by their order of sum rules, linear-phase
%   moments, and phase.
%   The following table lists valid options for WNAME along with other
%   filter specifications.
%
%   WNAME       SR  LP  VAR         FSEP        Length
%   "han2.3"    2   3   0.465       0.8156      6
%   "han3.3"    3   3   0.426       0.8540      8
%   "han4.5"    4   5   0.488       0.8563      10
%   "han5.5"    5   5   0.530       0.8867      14
%
%   SR denotes the order of sum rules, LP denotes the number of
%   linear-phase moments, VAR gives the normalized variance of the
%   filter impulse response, and FSEP provides the frequency separation
%   between the scaling and wavelet filter. Frequency separation is a
%   number between 0 and 1, where 0 indicates the filters are perfectly
%   matched and 1 indicates they are perfectly separated in frequency.
%   As a point of reference, the Haar ("db1") wavelet filter has the
%   smallest normalized variance of all wavelet filters with 0.25 and poorest
%   frequency separation with 0.666. An example of a scaling and wavelet
%   filter pair with a relatively large frequency separation is the
%   Fejer-Korovkin ("fk22") 22-coefficient filter with a value of 0.9522.
%
%   % Example:
%   %   Obtain the Han scaling filter with five sum rules and five 
%   %   linear-phase moments equal to 5. Obtain the analysis and synthesis
%   %   filters corresponding to scaling filter. Check the orthogonality of
%   %   of the synthesis filter pair.
%   a = hanscalf("han5.5");
%   [LoD,HiD,LoR,HiR] = orthfilt(a);
%   [tf,checks] = isorthwfb(LoR,HiR);
%
%   See also symwavf, dbwavf, modwt, modwpt, wavedec, dwpt

% Han, Bin. "Framelets and Wavelets: Algorithms, Analysis, and Applications."
% Cham, Switzerland: Birkhäuser, 2017, pp. 92-98.

%   Copyright 2021 The MathWorks, Inc.

%#codegen
narginchk(1,1);
validateattributes(wname,{'char','string'},{'scalartext'},...
    'hanscalf','wname');
coder.internal.errorIf(~any(strcmpi(wname,{'han2.3','han3.3',...
    'han4.5','han5.5'})), ...
    'Wavelet:scalingfilters:InvalidHanOFilter');
coder.varsize('a');

switch lower(wname)

    case 'han2.3'
        a = [1.602192704310000e-01
            5.272807295690000e-01
            4.295614591380000e-01
            -5.456145913800000e-02
            -8.978072956900000e-02
            2.728072956900000e-02];

    case 'han3.3'

        a = [-5.19199321177e-2
            -2.34375e-2
            3.43259796353e-1
            5.703125e-1
            2.19240203647e-1
            -7.03125e-2
            -1.05800678823e-2
            2.34375e-2];

    case 'han4.5'

        a = [-2.869100938340000e-02
            6.485705677480000e-02
            4.320766874130000e-01
            5.308243227340000e-01
            1.060285996960000e-01
            -1.205370917580000e-01
            -6.592001184650000e-03
            2.610421112900000e-02
            -2.822276541160000e-03
            -1.248498879720000e-03];


    case 'han5.5'

        a = [8.60958590718e-3
            5.79321131234e-3
            -6.22088657733e-2
            -2.95163986742e-2
            3.18619290259e-1
            5.60683823686e-1
            2.69169778554e-1
            -6.34355342487e-2
            -3.87802080904e-2
            3.4469477687e-2
            4.96073290597e-3
            -8.544921875e-3
            -3.70313762630e-4
            5.50342112533e-4];
    otherwise
        % Just so coder knows a is assigned on all paths, this should never
        % be hit.
        a = [1.602192704310000e-01
            5.272807295690000e-01
            4.295614591380000e-01
            -5.456145913800000e-02
            -8.978072956900000e-02
            2.728072956900000e-02];

end

scalf = a(:)';

end



