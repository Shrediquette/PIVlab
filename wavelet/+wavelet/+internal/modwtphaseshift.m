function [cfs,ph,scalph] = modwtphaseshift(Origcfs,Lo,Hi)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% %Example:
%   x = zeros(128,1);
%   x(64) = 1;
%   wt = modwt(x);
%   [~,~,Lo,Hi] = wfilters('sym4');
%   cfs = wavelet.internal.modwtphaseshift(wt,Lo,Hi);
%   tt = array2timetable(cfs.','VariableNames',...
%       {'L1','L2','L3','L4','L5','L6','L7','A7'},'RowTimes',...
%       seconds((1:128)'));
%   stackedplot(tt)
%   title('Time-aligned MODWT Analysis')
%   figure
%   utt = array2timetable(wt.','VariableNames',...
%       {'L1','L2','L3','L4','L5','L6','L7','A7'},'RowTimes',...
%       seconds((1:128)'));
%   stackedplot(utt)
%   title('MODWT Analysis with Delay')

%   Copyright 2022 The MathWorks, Inc.

%#codegen
narginchk(3,3);
L = numel(Lo);
Lo = reshape(Lo,1,L);
Hi = reshape(Hi,1,L);
LoReal = real(Lo);
HiReal = real(Hi);
% Wickerhauser center of energy argument
eScaling = sum((0:L-1).*LoReal.^2);
eScaling = eScaling/norm(LoReal,2)^2;
eWavelet = sum((0:L-1).*HiReal.^2);
eWavelet = eWavelet/norm(HiReal,2)^2;
[Jlev,T,Ch] = size(Origcfs);
jj = 0:Jlev-2;
ph = mod(round(2.^jj*(eScaling+eWavelet)-eScaling),T);
scalph = mod(round((2^Jlev-1)*eScaling),T);
shifts = [ph scalph];
% pagetranspose does not support code generation
cfsP = permute(Origcfs,[2,1,3]);
[Time,Scale] = ndgrid(0:T-1,0:Jlev-1);
shiftMatrix = mod(Time+shifts,T)+1+T*Scale;
pageshifts = 0:Jlev*T:(Ch-1)*Jlev*T;
pageshifts = reshape(pageshifts,1,1,[]);
shiftND = shiftMatrix+pageshifts;
shiftedCFST = cfsP(shiftND);
cfs = ipermute(shiftedCFST,[2 1 3]);
end



