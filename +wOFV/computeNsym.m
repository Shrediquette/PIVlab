function [N,Fw,Fw2]=computeNsym(wname,dord,isz,Jmin)

%Compute a regularization matrix M in the physical domain from wavelet
%filters given by wname and for differentiation order dord, and image size 
%isz, Jmin is the minimum scale of the wavelet transform

%QMF's for wavelets
[Lo_D,Hi_D,Lo_R,Hi_R]=wfilters(wname);

%Find wavelet connection coefficients
dim=2*length(Lo_R)-3;
ctol=10^(3*floor(log10(min(abs(Lo_R(Lo_R~=0))))));
etol=1e-2;
Hmat=zeros(dim);
for m=0:dim-1
    for n=0:dim-1
        tmp=0;
        for p=0:length(Lo_R)-1
            idx=m-2*n+p+length(Lo_R)-2;
            if idx>=0 && idx<length(Lo_R)
                tmp=tmp+Lo_R(p+1)*Lo_R(idx+1);
            end
        end
        if abs(tmp)>ctol
            Hmat(n+1,m+1)=tmp;
        end
    end
end

[evec,ev]=eig(Hmat);
ev=diag(ev);

%Find eigenvalue matching the desired order of derivation
evFound=0;
for k=1:length(ev)
    if abs(log2(real(ev(k)))+dord)<etol && abs(imag(ev(k)))<ctol
        evFound=1;
        break
    end
end

%Find eigenvector
if evFound==1
    Jphi=real(evec(:,k));
    
    %If derivation order is odd, force middle value to be exactly zero
    %(should be zero by construction, so any nonzero value is numerical
    %error)
    if mod(dord,2)~=0
        Jphi(ceil(dim/2))=0;
    end
    
    %Apply Beylkin normalization
    nmfac=(((0:dim-1)+2-length(Lo_R)).^dord)';
    Jphi=Jphi/sum(nmfac.*Jphi);
    tmp=prod(1:dord)*(-1)^dord;
    Jphi=Jphi*tmp;
else
    disp('No eigenvalue found!')
end

%Construct the matrix M from Jphi
M=wOFV.computeFsym(Jphi,isz);

%Create reconstruction matrix from filters
%Create matrix from filters
Fw=eye(isz);
for j=log2(isz):-1:Jmin+1
    %Compute transform matrix
    Ftrans=[wOFV.subsampling(eye(2^j),1)*wOFV.computeFsym(wOFV.revvec(nonzeros(Lo_R))...
        ,2^j);circshift(wOFV.subsampling(circshift(eye(2^j),1),1)*...
        wOFV.computeFsym(nonzeros(-wOFV.revvec(Hi_R)),2^j),-1)];
    %Combine with zeros and eyes to make it nxn
    for k=j:log2(isz)-1
        Ftrans=[Ftrans,zeros(2^k);zeros(2^k),eye(2^k)];
    end
    Fw=Ftrans*Fw;
end
if Jmin==0 && isz>1
    Fw(2,:)=-Fw(2,:);
end

%Create decomposition matrix from filters
Fw2=eye(isz);
for j=log2(isz):-1:Jmin+1
    %Compute transform matrix
    Ftrans=[wOFV.subsampling(eye(2^j),1)*wOFV.computeFsym(nonzeros(Lo_D),2^j);...
        circshift(wOFV.subsampling(circshift(eye(2^j),1),1)*wOFV.computeFsym(...
        nonzeros(-Hi_D),2^j),-1)];
    %Combine with zeros and eyes to make it nxn
    for k=j:log2(isz)-1
        Ftrans=[Ftrans,zeros(2^k);zeros(2^k),eye(2^k)];
    end
    Fw2=Ftrans*Fw2;
end
if Jmin==0 && isz>1
    Fw2(2,:)=-Fw2(2,:);
end

N=Fw*M/Fw2;