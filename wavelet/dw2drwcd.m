function out1 = dw2drwcd(option,fig)
%DW2DRWCD Discrete wavelet 2-D read-write Cdata for image.
%   OUT1 = DW2DRWCD(OPTION,fig)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Tag property of objects.
%-------------------------
tag_axeimgini = 'Axe_ImgIni';
tag_axeimgsyn = 'Axe_ImgSyn';

axe_handles = findobj(get(fig,'Children'),'flat','Type','axes');
switch option
    case 'r_orig'
        %***********************************************%
        %** OPTION = 'r_orig' -  Read Original Image. **%
        %***********************************************%       
        Axe_ImgIni = findobj(axe_handles,'flat','Tag',tag_axeimgini);
        out1       = findobj(Axe_ImgIni,'Type','image');

    case 'r_synt'
        %**************************************************%
        %** OPTION = 'r_synt' -  Read Synthesized Image. **%
        %**************************************************%
        Axe_ImgSyn = findobj(axe_handles,'flat','Tag',tag_axeimgsyn);
        out1       = findobj(Axe_ImgSyn,'Type','image');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
