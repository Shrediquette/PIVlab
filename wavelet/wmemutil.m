function [out1,out2] = wmemutil(option,in2,in3,in4)
%WMEMUTIL Memory utilities.
%
%   M = WMEMUTIL('add',M,V) adds V to the memory block M
%   M = WMEMUTIL('add',M,V,IN4) adds V to the memory block M
%
%   [V,M] = WMEMUTIL('get',M)
%   [V,M] = WMEMUTIL('get',M,NUM)
%
%   M = WMEMUTIL('set',M,NUM,V)
%
%   M = WMEMUTIL('def',N) defines a memory block
%   with N empty variables
%
%   I = WMEMUTIL('ind',M,V) get index in M of a block with value V
%
%   I = WMEMUTIL('nbb',M) get nb var block in memory block M.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

switch option
    case 'add'    % add a memory bloc.
        if ischar(in3), in3 = abs(in3); type = 1 ; else type  = 0; end
        if nargin==4
            out1 = [size(in3) type in3(:)' in2];
        else
            out1 = [in2 size(in3) type in3(:)'];
        end

    case 'get'    % get a memory bloc.
        out1 = [];      out2 = [];
        if isempty(in2) , return; end
        if nargin==2 , in3 = 1; end
        count = 0;
        ltot  = length(in2);
        ind   = 1;
        while (count<in3-1) && (ind<ltot)
            ind   = ind+3+prod(in2(ind:ind+1));
            count = count+1;
        end
        if ind<ltot
            ibeg    = ind+3+prod(in2(ind:ind+1));
            if min(in2(ind:ind+1))>0
               out1    = zeros(in2(ind),in2(ind+1));
               out1(:) = in2(ind+3:ibeg-1);
            end
            out2 = in2(ibeg:ltot);
            if in2(ind+2)==1 , out1 = char(out1); end
        end

    case 'set'    % set a memory bloc.
        count = 0;
        ltot  = length(in2);
        ind   = 1;
        while (count<in3-1) && (ind<ltot)
            ind   = ind+3+prod(in2(ind:ind+1));
            count = count+1;
        end
        front = in2(1:ind-1);
        if ind<ltot
            back = in2(3+prod(in2(ind:ind+1))+ind:ltot);
        else
            back = [];
        end
        if ischar(in4), in4 = abs(in4); type = 1 ; else type  = 0; end
        out1 = [front size(in4) type in4(:)' back];

    case 'def'    % define a memory bloc.
        out1 = zeros(1,3*in2);
 
    case 'ind'    % get index.    
        count = 0;
        ok    = 0;
        ltot  = length(in2);
        ind   = 1;
        while (ok==0) && (ind<ltot)
            count = count+1;
            s     = in2(ind:ind+1);
            % type  = in2(ind+2); 
            l     = 3+prod(s);
            if s==size(in3)
                if min(s) >0
                   bloc    = zeros(s(1),s(2));
                   bloc(:) = in2(ind+3:ind+l-1);
                else
                   bloc = [];
                end
                if ischar(in3) , in3 = abs(in3); end
                if in3==bloc , ok = 1; end
            end
            ind = ind+l;
        end
        if ok==1 , out1 = count; else out1 = 0; end

    case 'nbb'    % get nb blocs.
        out1 = 0;
        ltot = length(in2);
        ind  = 1;
        while (ind<ltot)
            out1 = out1+1;
            s    = in2(ind:ind+1);
            l    = 3+prod(s);
            ind  = ind+l;
        end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
