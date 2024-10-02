function xy=mmstream2(x,y,u,v,x0,y0,mark,step)
%MMSTREAM2 Improved 2D Streamlines.
% XY = MMSTREAM2(X,Y,U,V,X0,Y0,Mark,Step) computes streamlines from gradient
% data in matrices U and V.
%
% X and Y can be vectors defining the coordinate axes data where U(i,j) and
% V(i,j) coincide with the coordinates axes points X(j) and Y(i).
% Alternatively, X and Y can be 2D plaid matrices as produced by MESHGRID.
%
% X0 and Y0 are equal length vectors defining coordinates that mark the
% Start, End, or a point On individual streamlines as denoted by the input
% Mark which is 'Start', 'End' or 'On'. If empty or not given Mark='Start'.
%
% Step identifies the normalized step size used. If empty or not given,
% Step = 0.1, i.e., 1/10 of a cell. 0.01 <= Step <= 0.5
%
% XY is a cell array containing streamline data points. XY{k}(:,1) contains
% the x-axis data and XY{k}(:,2) contains the y-axis data for the k-th
% streamline.
%
% Improvements over MATLAB's STREAM2:
% Will find closed streamlines.
% Will selectively go downstream, upstream, or both directions from a point.
% Uses a more accurate integration routine.
% X and Y need not linearly spaced.
%
% STREAMLINE(XY) plots the streamlines on the current axes.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2005-06-21
% Revised 2005-08-31, 2007-07-03, 2008-07-29

if nargin<8 || isempty(step)                        % parse input arguments
    step=0.1;
end
if nargin<7 || isempty(mark)
    mark='start';
end
if nargin<6
    error('At Least Six Input Arguments are Required.')
end
if ~isnumeric(step) || numel(step)>1 || step<0.01 || step>0.5
    error('Step Must be a Scalar Between 0.01 and 0.5')
end
if ~ischar(mark) || ~any(lower(mark(1))=='seo')
    error('Mark Must be ''Start'', ''End'', or ''On''')
end
mark=lower(mark(1));
if any(size(u)~=size(v))
    error('U and V Must be the Same Size.')
end
if ndims(u)~=2 || min(size(u))<2
    error('U and V Must be 2D and at Least 2-by-2.')
end
if all(size(x)==size(y)) && min(size(x))>1 % x and y are plaid
    xx=x;                  % save plaid
    yy=y;
    x=x(1,:)';             % create axes vectors
    y=y(:,1);
else                                       % x and y are axes vectors
    x=x(:);                % save axes vectors
    y=y(:);
    [xx,yy]=meshgrid(x,y); % create plaid
end
if any(abs(diff(x))<eps) || any(abs(diff(y))<eps)
    error('X and Y Must Not Have Consecutive Equal Values.')
end
Nx=length(x);
Ny=length(y);
if Nx~=size(u,2)
    error('X Must Have as Many Elements or Columns as U and V Have Columns.')
end
if Ny~=size(u,1)
    error('Y Must Have as Many Elements or Rows as U and V Have Rows.')
end
x0=x0(:);
y0=y0(:);
N0=length(x0);
if N0~=length(y0)
    error('X0 and Y0 Must Contain the Same Number of Elements.')
end

xy=cell(1,N0); % create cells for output

for k=1:N0 % find streamlines given [x0, y0] pairs
    
    if x0(k)<min(x) || x0(k)>max(x) ||...
            y0(k)<min(y) || y0(k)>max(y)   % point is outside map
        continue
    end
    % figure out what cell [x0,y0] is in
    [idx,idx]=min(abs(x0(k)-xx(:))+abs(y0(k)-yy(:)));
    [i,j]=ind2sub(size(u),idx);
    if j==1
        jlim=[j j+1];
    elseif j==Nx
        jlim=[j-1 j];
    elseif abs(x0(k)-x(j-1))<abs(x0(k)-x(j+1))
        jlim=[j-1 j];
    else
        jlim=[j j+1];
    end
    if i==1
        ilim=[i i+1];
    elseif i==Ny
        ilim=[i-1 i];
    elseif abs(y0(k)-y(i-1))<abs(y0(k)-y(i+1))
        ilim=[i-1 i];
    else
        ilim=[i i+1];
    end
    switch mark
        case 's'
            xy{k}=local_getstream(x,y,u,v,ilim,jlim,x0(k),y0(k),step);
        case 'e'
            xy{k}=local_getstream(x,y,-u,-v,ilim,jlim,x0(k),y0(k),step);
            xy{k}=xy{k}(end:-1:1,:); % make stream flow downhillm
        case 'o'
            [xy{k},ic]=local_getstream(x,y,u,v,ilim,jlim,x0(k),y0(k),step);
            if ~ic % go other direction only if streamline is not closed
                xye=local_getstream(x,y,-u,-v,ilim,jlim,x0(k),y0(k),step);
                xy{k}=[xye(end:-1:2,:);xy{k}]; % make stream flows downhill
            end
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [xy,ic]=local_getstream(x,y,u,v,ilim,jlim,x0,y0,step)
% move from cell to cell gathering a streamline
% xy is a double array
% ic is true if streamline is closed

ic=false;    % logical variable that is true if streamline is closed
xy0=[x0 y0]; % hold starting point so that closed streamlines can be found

xy=zeros(1000,2); % allocate storage
k=1; % pointer to next index to store data

loop2=tic;
while true
    if toc(loop2)>0.1
        disp('Streamline timeout')
        xy(k-1:end,:)=[]; % throw away unused storage
        break
    end
    xlim=x(jlim);
    ylim=y(ilim);
    ulim=u(ilim,jlim);
    vlim=v(ilim,jlim);
    
    [dxy,ii,jj]=local_cellstream(xlim,ylim,ulim,vlim,x0,y0,xy0,step);
    np=size(dxy,1);
    if k+np-1>size(xy,1);   % allocate more storage if needed
        xy=[xy;zeros(500,2)];%#ok
    end
    xy(k:k+np-1,:)=dxy; % poke data into storage array
    k=k+np;             % update pointer
    jlim=jlim+jj;
    ilim=ilim+ii;
    if jlim(1)<1 || jlim(2)>length(x) || ...
            ilim(1)<1 || ilim(2)>length(y)
        xy(k-1:end,:)=[]; % throw away unused storage
        break
    elseif (ii==0 && jj==0) || np==0
        xy(k:end,:)=[]; % throw away unused storage
        ic=isequal(xy(end,:),xy0);
        break
    end
    x0=dxy(end,1);
    y0=dxy(end,2);
end
%--------------------------------------------------------------------------
function [xy,ii,jj]=local_cellstream(xlim,ylim,ulim,vlim,x0,y0,xy0,step)

% starting at the point [sx, sy] create a streamline until the edge of the
% cell given by xlim and ylim is reached.
%
% xlim = [x1 x2]                ylim = [y1 y2]
%
% ulim = [u(x1,y1) u(x2,y1)     vlim = [v(x1,y1) v(x2,y1)
%         u(x1,y2) u(x2,y2)];           v(x1,y2) v(x2,y2)];

xymin=[xlim(1) ylim(1)]; % [x1 y1]
xymax=[xlim(2) ylim(2)]; % [x2 y2]
xybox=xymax-xymin;       % [x2-x1 y2-y1]
uv=[ulim(:) vlim(:)]';   % [u(x1,y1) u(x1,y2) u(x2,y1) u(x2,y2);
%  v(x1,y1) v(x1,y2) v(x2,y1) v(x2,y2)];
tol=1e-4;
N=round(3/step);
xy=zeros(N,2); % preallocate memory for result
cstep=1.5*step;% step size for closed streamline detection

k=1;
xy(k,:)=[x0 y0]; % first point
ii=0;            % next cell in x
jj=0;            % and y direction

%william mod:
loop1=tic;
while true
    if toc(loop1)>0.1
        xy(k+1:end,:)=[];
        disp('anderer')
        disp('Streamline timeout')
        break
    end
    abk=(xy(k,:)-xymin)./xybox; % normalized current position [alpha beta]
    % compute slopes at current point
    uvk=((1-abk(1))*( (1-abk(2))*uv(:,1) + abk(2)*uv(:,2)) + ...
        abk(1) *( (1-abk(2))*uv(:,3) + abk(2)*uv(:,4)))';      % [uk vk]
    
    if k>1 && max(abs(uvk))<tol  % at minimum, this stream stops
        xy(k+1:end,:)=[];
        break
    end
    
    h=min(step*abs(xybox)./(max(abs(uvk),tol)));       % allowable step size
    
    xy(k+1,:)=xy(k,:) + h*uvk;                    % Forward Euler Prediction
    
    abi=(xy(k+1,:)-xymin)./xybox;        % normalized position at next point
    uvi=((1-abi(1))*( (1-abi(2))*uv(:,1) + abi(2)*uv(:,2)) + ...
        abi(1) *( (1-abi(2))*uv(:,3) + abi(2)*uv(:,4)))';      % [ui vi]
    
    xy(k+1,:)=xy(k,:) + h*(uvk + uvi)/2;       % Trapezoidal Rule Correction
    k=k+1;
    
    if k>2 && norm((xy(k,:)-xy(k-2,:))./xybox,inf)<step/2% stuck inside cell
        xy(k-2:end,:)=[];
        break
    elseif k>2 && norm((xy(k,:)-xy0)./xybox,inf)<=cstep   % closed streamline
        xy(k,:)=xy0; % close the streamline
        xy(k+1:end,:)=[];
        break
    elseif k==N+1                                        % stuck inside cell
        break
    else                                       % check if moved outside cell
        
        jj=sign(xybox(1))*(-(xy(k,1)<xlim(1)) + (xy(k,1)>xlim(2)));
        ii=sign(xybox(2))*(-(xy(k,2)<ylim(1)) + (xy(k,2)>ylim(2)));
        if jj~=0 || ii~=0                                % point to next cell
            xy(k+1:end,:)=[];
            break
        end
    end
end