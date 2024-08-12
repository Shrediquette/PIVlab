function Fsym=computeFsym(filt,isz)

%Compute a symmetric filter matrix for performing convolutions

%Index filter such that central value is zero
inds=(0:length(filt)-1)-floor(length(filt)/2);

Fsym=zeros(isz);

for p=1:isz
    for q=1:isz
        Jind=find(inds==p-q);
        if Jind
            Fsym(p,q)=filt(Jind);
        end
    end
end

%Boundaries
%Compute number of side matrices to fill
nside=ceil(floor(length(filt)/2)/isz);

for side=1:nside
    %Left side
    %Re-establish filter indices
    sideind=inds-isz*side;
    sdmat=zeros(isz);
    for p=1:isz
        for q=1:isz
            Jind=find(sideind==p-q);
            if Jind
                sdmat(p,q)=filt(Jind);
            end
        end
    end
    if isz>1
        Fsym(:,2:end)=Fsym(:,2:end)+flip(sdmat(:,2:end),2);
        Fsym(:,end-1)=Fsym(:,end-1)+sdmat(:,1);
    end
    
    %Right side
    %Re-establish filter indices
    sideind=inds+isz*side;
    sdmat=zeros(isz);
    for p=1:isz
        for q=1:isz
            Jind=find(sideind==p-q);
            if Jind
                sdmat(p,q)=filt(Jind);
            end
        end
    end
    if isz>1
        Fsym(:,1:end-1)=Fsym(:,1:end-1)+flip(sdmat(:,1:end-1),2);
        Fsym(:,2)=Fsym(:,2)+sdmat(:,end);
    end
end