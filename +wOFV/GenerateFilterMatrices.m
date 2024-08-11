function GenerateFilterMatrices()
%Compute and store wavelet transform matrices (and their inverses) for 
%future use, along with wavelet-domain regularization matrices N of various
%differentiation orders

%Wavelet
wname='bior6.8';
%Load wavelet filters
[Lo_D,Hi_D,Lo_R,Hi_R]= wOFV.wfilters(wname);

Jmin=0;

%Create and store matrices from size 16^2 to 2048^2
for J=4:11
    isz=2^J;
    
    %Create matrix from filters
    Fw=eye(isz);
    for j=log2(isz):-1:Jmin+1
        %Compute transform matrix
        if mod(length(nonzeros(Lo_D)),2)~=0
            Ftrans=[wOFV.subsampling(eye(2^j),1)*wOFV.computeFsym(nonzeros(Lo_D),...
                2^j);circshift(wOFV.subsampling(circshift(eye(2^j),1),1)*...
                wOFV.computeFsym(nonzeros(-Hi_D),2^j),-1)];
        else
            Ftrans=[wOFV.subsampling(eye(2^j),1)*wOFV.computeFsym(nonzeros(Lo_D),...
                2^j);wOFV.subsampling(eye(2^j),1)*wOFV.computeFsym(nonzeros(-Hi_D)...
                ,2^j)];
        end
        %Combine with zeros and eyes to make it nxn
        for k=j:log2(isz)-1
            Ftrans=[Ftrans,zeros(2^k);zeros(2^k),eye(2^k)];
        end
        Fw=Ftrans*Fw;
    end
    if Jmin==0 && J>0 && mod(length(nonzeros(Lo_D)),2)~=0
        Fw(2,:)=-Fw(2,:);
    end
    
    %Compute inverse numerically
    FwInv=Fw\eye(isz);
    
    %Compute N of various differentiation orders
    N0=wOFV.computeNsym(wname,0,isz,Jmin);
    N1=wOFV.computeNsym(wname,1,isz,Jmin);
    N2=wOFV.computeNsym(wname,2,isz,Jmin);
    N3=wOFV.computeNsym(wname,3,isz,Jmin);
    N4=wOFV.computeNsym(wname,4,isz,Jmin);
    
    %Store
    mkdir(['+wOFV/Filter matrices/' wname '/' num2str(isz) '/'])
    save(['+wOFV/Filter matrices/' wname '/' num2str(isz) ...
        '/Fmats.mat'],'Fw','FwInv','N0','N1','N2','N3','N4')
end
disp('Wavelet filter matrices generated.')