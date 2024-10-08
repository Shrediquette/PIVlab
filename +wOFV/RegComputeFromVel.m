function fr = RegComputeFromVel(V,Fw,Ni,scale)



%transform to the theta domain
Theta=cat(3,wOFV.Psitrunc_mat(V(:,:,1),Fw(1:2^scale,:)),wOFV.Psitrunc_mat(V(:,:,2),Fw(1:2^scale,:)));

%compute the regularization functional value
gdr=wOFV.Reg(Theta,Ni(1:2^scale,1:2^scale,:),'visc');
fr=.5*Theta(:)'*gdr;

