function alpha = getalphafield(I0,I1,v,mask,eta,vartheta,Grid)
%obtain the alpha field

%Motion-compensated image
IwF = wOFV_warpS(I0,v/2,Grid);
IwR=wOFV_warpS(I1,-v/2,Grid);

f1=(IwF-IwR).*mask;

alpha(:,:) = vartheta(:,:).*(eta/2 + sqrt(eta^2/4 +  (f1.^2)./(2*vartheta(:,:))));

end