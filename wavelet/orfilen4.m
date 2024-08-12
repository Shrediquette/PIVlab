function [LO_D,HI_D,LO_R,HI_R] = orfilen4(beta)
%ORFILEN4 Orthogonal filters of length 4.
%   [LO_D,HI_D,LO_R,HI_R] = ORFILEN4(R) computes the
%   four filters associated with the scaling filter F.
%   The filter F is of length 4 and its coefficients
%   depend on the real R:
%    F = [R*(R-1) , 1-R , 1+R , R*(R+1)] / (sqrt(2)*(1+R^2))
%   
%   The four output filters are:
%     LO_D = decomposition low-pass filter
%     HI_D = decomposition high-pass filter
%     LO_R = reconstruction low-pass filter
%     HI_R = reconstruction high-pass filter.
%
%   N.B.: For R = -1, 0, and 1 the construction degenerates 
%   and gives the Haar filters. For R = -1/sqrt(3), the 
%   filters corresponds to the db2 wavelet filters.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Jun-2000.
%   Last Revision: 07-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if isinf(beta)
    beta = sign(beta)*1E12;
end
gamma = sqrt(2)*(1+beta.^2);
F = zeros(1,4);
F(1) = beta.*(beta-1)./gamma;
F(2) =(1-beta)./gamma;
F(3) =(1+beta)./gamma;
F(4) = beta.*(beta+1)./gamma;
[LO_D,HI_D,LO_R,HI_R] = orthfilt(F);
