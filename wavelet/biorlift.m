function LS = biorlift(wname)
%BIORLIFT Biorthogonal spline lifting schemes.
%   LS = BIORLIFT(WNAME) returns the lifting scheme specified 
%   by WNAME. The valid values for WNAME are:
%       'bior1.1', 'bior1.3' , 'bior1.5', ...
%       'bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8'
%       'bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7' 
%       'bior3.9', 'bior4.4' , 'bior5.5', 'bior6.8' 
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

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-May-2001.
%   Last Revision: 03-Dec-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

kdot = find(wname=='.');
if length(kdot)~=1
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
lw = length(wname);
Nd = str2num(wname(kdot+1:lw));
wname = wname(1:kdot-1);
lw = length(wname);
ab = abs(wname);
ii = lw+1;
while (ii>1) && (47<ab(ii-1)) && (ab(ii-1)<58), ii = ii-1; end
Nr = str2num(wname(ii:lw));

if isempty(find(Nr == (1:6),1)) 
    error(message('Wavelet:Lifting:InvalidWavNum', Nr));
end
errNAME = false;
switch Nr
  case 1 , if isempty(find(Nd == (1:2:5),1)) , errNAME = true; end
  case 2 , if isempty(find(Nd == (2:2:8),1)) , errNAME = true; end
  case 3 , if isempty(find(Nd == (1:2:9),1)) , errNAME = true; end
  case 4 , if Nd ~= 4 , errNAME = true; end
  case 5 , if Nd ~= 5 , errNAME = true; end
  case 6 , if Nd ~= 8 , errNAME = true; end      
end
if errNAME
    error(message('Wavelet:Lifting:InvalidWavNum', Nd));
end

switch Nr
  case 1
    if isempty(find(Nd == (1:2:5),1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',-1,0};
    switch Nd
      case 1 , LS(2,:) = {'p',1/2,0};
      case 3 , LS(2,:) = {'p',[-1 8 1]/16,1};
      case 5 , LS(2,:) = {'p',[3 -22 128 22 -3]/256,2};
    end
    LS(3,:) = {sqrt(2),sqrt(2)/2,[]};   

  case 2
    if isempty(find(Nd == (2:2:8),1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'d',[-1 -1]/2,1};
    switch Nd
      case 2 , LS(2,:) = {'p',[1 1]/4,0};
      case 4 , LS(2,:) = {'p',[-3 19 19 -3]/64,1};
      case 6 , LS(2,:) = {'p',[5 -39 162 162 -39 5]/512,2};
      case 8 , LS(2,:) = {'p',[-35  335  -1563  5359  5359  -1563  335  -35]/16384 ,3}; 
    end
    LS(3,:) = {sqrt(2),sqrt(2)/2,[]};

  case 3
    if isempty(find(Nd == (1:2:9),1))
        error(message('Wavelet:Lifting:InvalidWavNum', Nd));
    end
    LS = {'p',-1/3,-1;'d',[-3 -9]/8,1};
    switch Nd
      case 1 , LS(3,:) = {'p',4/9,0};
      case 3 , LS(3,:) = {'p',[-3 16 3]/36,1};
      case 5 , LS(3,:) = {'p',[5 -34 128 34 -5]/288,2};
      case 7 , LS(3,:) = {'d' [-35/9216  25/768  -421/3072  -4/9  421/3072  -25/768  35/9216]  4}; 
      case 9 , LS(3,:) = {'d' [7/8192  -185/20729  547/12288  -938/6295  -4/9  938/6295  -547/12288  185/20729  -7/8192]  5};
    end
    LS(4,:) = {3*sqrt(2)/2,sqrt(2)/3,[]};

  case 4
	%--------------------  Num LS = 11  ----------------------% 
	% Pow MAX = 1 - diff POW = 0
	%---+----+----+----+----+---%
	LS = {...                                                                
	'd'                     [ -1.5861343420693648 -1.5861343420693648]  1  
	'p'                     [  1.0796367753628087 -0.0529801185718856]  0  
	'd'                     [ -0.8829110755411875 -0.8829110755411875]  0  
	'p'                     [  0.4435068520511142  1.5761237461483639]  2  
	 -1.1496043988602418   -0.8698644516247808                     []   
	};                                                                       

  case 5
	LS = {...                                                                 
	'd'                     [  4.9932745216378791  4.9932745216378791]  1   
	'p'                     [ -0.1833932736462213 -0.0043674455906250]  0   
	'd'                     [  5.5857862011365809  5.5857862011365809]  0   
	'p'                     [ -3.0949380770116637  0.1732056148062267]  2   
	'd'                     [  0.2900930732401870  0.2900930732401881] -2  
	'p'                      -3.4471695202783086                        3   
	 0.9249619350590361      1.0811255707902991                     []    
	};                                                                        
    
   case 6
	%--------------------  Num LS = 1  ----------------------% 
	% Pow MAX = 1 - diff POW = 0
	%---+----+----+----+----+---%
	LS = {...                                                                                                         
	'p'                     [ -2.6589963611977199  0.9971506910514433]                                          0   
	'd'                     [  0.2735119746851613  0.2735119746851613]                                          0   
	'p'                     [  3.8778221455598287 -3.2686866117960300]                                          2   
	'd'                     [ -0.2865032579680539 -0.2865032579680544]                                         -2  
	'p'                     [ -0.5485941682554034  2.9417675368512870]                                          4   
	'd'                     [  0.0998232169757517 -0.3438132627628235 -0.3438132627531770  0.0998232170102641] -2  
	 0.8685786973079247    1.1513061546402219                                                             []    
	};
    %---------------------------------------
	% LS = {...                                                                                                         
	% 'd'                     [ -0.9971506910514433  2.6589963611977199]                                          [1]   
	% 'p'                     [ -0.2735119746851613 -0.2735119746851613]                                          [1]   
	% 'd'                     [  3.2686866117960300 -3.8778221455598287]                                          [-1]  
	% 'p'                     [  0.2865032579680544  0.2865032579680539]                                          [3]   
	% 'd'                     [ -2.9417675368512870  0.5485941682554034]                                          [-3]  
	% 'p'                     [ -0.0998232170102641  0.3438132627531770  0.3438132627628235 -0.0998232169757517]  [5]   
	% [  1.1513061546402219]  [  0.8685786973079247]                                                              []    
	% };                                                                                                                
    %---------------------------------------
    
end
LS = lsdual(LS);
