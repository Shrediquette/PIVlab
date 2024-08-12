function y = lsupdate(option,x,F,DF,S,LStype)
%LSUPDATE Compute lifting scheme update.
%   For a vector X, Y = LSUPDATE('v',X,F,DF,SY) returns 
%   a vector Y which length is SY. X is filtered by the
%   vector F with a delay of DF.
%   
%   For a matrix X, Y = LSUPDATE('r',X,...) computes the "update"
%   of X rowwise, like in the vector option. Y = LSUPDATE('c',X,...)
%   computes the "update" of X columnwise. In that cases, SY is
%   the size of the matrix Y.
%
%   Y = LSUPDATE(...,INT_FLAG) returns integer values (fix). 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-2001.
%   Last Revision: 04-Jun-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

lF = length(F);
sx = size(x);
switch option
  case 'v'
      maxlen = max([length(x),S]);
      y = zeros(1,maxlen);
      if sx(1)>sx(2) , y = y'; end  % column vector
      for j=1:lF
          t = F(j)*x;
          k = DF-j+1;
          if k>0
              t(end+k) = 0; t = t(k+1:end);    
          elseif k<0
              t(1-k:end-k) = t;  t(1:-k) = 0;
          end
          last = min([S,length(t)]);
          y(1:last) = y(1:last)+t(1:last);
      end
      y = y(1:S);
    
  case 'r'
      y = zeros(sx);
      maxCol = max([sx(2),S(2)]);
      y (:,maxCol,:) = 0;
      for j=1:lF
          k = DF-j+1; 
          t = F(j)*x;
          if     k>0 , t(:,end+k,:)= 0; t = t(:,1+k:end,:); 
          elseif k<0 , t(:,1-k:end-k,:) = t; t(:,1:-k,:) = 0;
          end
          last = min([S(2),size(t,2)]);
          y(:,1:last,:) = y(:,1:last,:)+t(:,1:last,:);
      end
      y = y(:,1:S(2),:);

  case 'c'
      y = zeros(sx);
      maxRow = max([sx(1),S(1)]);      
      y(maxRow,:,:) = 0;
      for j=1:lF
          k = DF-j+1; 
          t = F(j)*x;
          if     k>0 , t(end+k,:,:)= 0; t = t(1+k:end,:,:); 
          elseif k<0 , t(1-k:end-k,:,:) = t; t(1:-k,:,:) = 0;
          end
          last = min([S(1),size(t,1)]);
          y(1:last,:,:) = y(1:last,:,:)+t(1:last,:,:);
      end
      y = y(1:S(1),:,:);
end

if ~isempty(LStype) , y = fix(y); end
