function [valF,valG]=call_Bayes(Theta,I0,I1,scale,eta,vartheta,Fw,FwInv,Ni,...
    regscheme,Dmat,mask,Grid)

%Creates persistent variables for wavelet optical flow function call 
%(wOFVBayes_min)

persistent I0S I1S scaleS FwS FwInvS NiS regschemeS DmatS maskS etaS varthetaS GridS

if nargin>=2
    I0S=I0;
    I1S=I1;
    scaleS=scale;
    FwS=Fw;
    FwInvS=FwInv;
    NiS=Ni;
    regschemeS=regscheme;
    DmatS=Dmat;
    maskS=mask;
    etaS = eta;
    varthetaS = vartheta;
    GridS = Grid;
    return
end

[valF,valG]=wOFV.Bayes_min(Theta,I0S,I1S,scaleS,etaS,varthetaS,FwS,FwInvS,...
    NiS,regschemeS,DmatS,maskS,GridS);