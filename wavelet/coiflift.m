function LS = coiflift(wname)
%COIFLIFT Coiflets lifting schemes.
%   LS = COIFLIFT(WNAME) returns the lifting scheme specified
%   by WNAME. The valid values for WNAME are:
%      'coif1', 'coif2'
%
%   A lifting scheme LS is a N x 3 cell array such that:
%     for k = 1:N-1
%       | LS{k,1} is the lifting "type" 'p' (primal) or 'd' (dual).
%       | LS{k,2} is the corresponding lifting filter.
%       | LS{k,3} is the higher degree of the Laurent polynomial
%       |         corresponding to the previous filter LS{k,2}.
%     LS{N,1} is the primal normalization.
%     LS{N,2} is the dual normalization.
%     LS{N,3} is not used.
%
%   For more information about lifting schemes type: lsinfo.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Jun-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

Num = str2num(wname(5:end));
switch Num
    case 1
		%--------------------  Num LS = 7  ----------------------% 
		% Pow MAX = 0 - diff POW = 0
		%---+----+----+----+----+---%
		LS = {...                                                                 
		'd'                        4.6457513110481772                      0   
		'p'                     [ -0.1171567416519999 -0.2057189138840000]  1   
		'd'                     [  7.4686269664352070 -0.6076252184992341] -1  
		'p'                        0.0728756555332089                       2   
		 -1.7186236496830642   -0.5818609561112537                      []    
		};                                                                        

    case 2
		%--------------------  Num LS = 1  ----------------------% 
		% Pow MAX = 0 - diff POW = 0
		%---+----+----+----+----+---%
		LS = {...                                                                 
		'd'                       2.5303036209828274                       0   
		'p'                     [  0.2401406244344829  -0.3418203790296641]  1   
		'd'                     [ -3.1631993897610227 -15.2683787372529950] -1  
		'p'                     [ -0.0057171329709620   0.0646171619180252]  3   
		'd'                     [ 63.9510482479880200 -13.5911725693075900] -3  
		'p'                     [ -0.0005087264425263   0.0018667030862775]  5   
		'd'                        3.7930423341992774                       -5  
		  9.2878701738310099    0.1076673102965570                       []    
		};
        
    otherwise
        error(message('Wavelet:Lifting:InvalidWavNum', Num))
end
