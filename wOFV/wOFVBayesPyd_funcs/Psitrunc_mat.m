function Psi=Psitrunc_mat(f,Fw)

%Performs a separable wavelet transform on f, which is either the 2D matrix
%or its transform, which is truncated, using the matrix multiplication 
%method with some speedup by exploiting null scales. Fw is the matrix of 
%either the forward or inverse wavelet transform, appropriately sized
%depending on what f is

Psi=Fw*f*Fw';