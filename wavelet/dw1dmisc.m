function [out1,out2,out3,out4,out5,out6,out7,out8] = ...
                dw1dmisc(option,win_dw1dtool,in3,in4,in5,in6)
%DW1DMISC Discrete wavelet 1-D miscellaneous utilities.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Default Value(s).
%------------------
def_nbCodeOfColors = 128;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
ind_sig_size   = 2;
% ind_wav_name   = 3;
% ind_lev_anal   = 4;
% ind_axe_ref    = 5;
% ind_act_option = 6;
% ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_longs     = 2;
% nb2_stored    = 2;

switch option
    case 'col_cfs'
        %************************************************%
        %** OPTION = 'col_cfs' - colored coefficients. **%
        %************************************************%
        % in3,...,in8 optional
        % out1 = colored_cfs
        % out2 = xlim1
        % out3 = xlim2
        % out4 = ymax
        % out5 = ymin
        % out6 = nb_cla
        % out7 = levels
        % out8 = ccfs_vm
        %----------------------
        longs = wmemtool('rmb',win_dw1dtool,n_coefs_longs,ind_longs);
        len  = length(longs);
        xmax = longs(len);
        Level_anal= len-2;
        clear coefs longs

        if nargin<6 , nb_cla = def_nbCodeOfColors; else nb_cla = in6; end
        if nargin<5
            xlim1 = 1; xlim2 = xmax;
        else
            in5   = round(in5);
            xlim1 = in5(1); xlim2 = in5(2);
        end 
        if nargin<4 , levels = 1:Level_anal; else levels = in4; end 
        if nargin<3 , ccfs_vm = 1; else ccfs_vm = in3; end    
        if find(ccfs_vm==[1 3 5 7]) , absval = 1; else absval = 0; end
        if find(ccfs_vm==[1 2 5 6]) , levval = 'row'; else levval = 'mat'; end
        if find(ccfs_vm==[1 2 3 4]) , view_m = 'ini'; else view_m = 'cur'; end

        out1 = dw1dfile('cfs_beg',win_dw1dtool,levels);
        out4 = size(out1);
        if out4>1 , out5 = 1; else out5 = 0; end
        out7 = levels;
        if strcmp(view_m,'cur')
            if absval==1 , out1 = abs(out1); end
            if strcmp(levval,'mat')
                cmin = min(min(out1(:,xlim1:xlim2)));
                cmax = max(max(out1(:,xlim1:xlim2)));
                out1(out1<cmin) = cmin;
                out1(out1>cmax) = cmax;
            else
                cmin = min((out1(:,xlim1:xlim2)),[],2);
                cmax = max((out1(:,xlim1:xlim2)),[],2);
                for k=1:length(levels)
                    v = cmin(k);
                    out1(k,out1(k,:)<v) = v;
                    v = cmax(k);
                    out1(k,out1(k,:)>v) = v;
                end
            end
        end
        out2 = xlim1;
        out3 = xlim2;
        out1 = wcodemat(out1,nb_cla,levval,absval);
        out6 = nb_cla;
        out8 = ccfs_vm;

    case 'tst_vm'
        %*****************************************%
        %** OPTION = 'tst_vm' - test view mode. **%
        %*****************************************%
        % in3 = view mode
        % in4 = axe_hdl
        % in5 = flg_lev
        %---------------------------------
        num_mode = in3; 
        axe_hdl  = in4;
        flg_lev  = in5;
        Signal_Size = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_sig_size);
        Signal_Size = max(Signal_Size);
        ccfs_vm  = dw1dvmod('ccfs_vm',win_dw1dtool,num_mode);
        xlim_axe = get(axe_hdl,'XLim');
        if find(ccfs_vm==[5 6 7 8])
            xlim_selbox = mngmbtn('getbox',win_dw1dtool); 
            if ~isempty(xlim_selbox)
                xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
            else
                xlim_selbox = xlim_axe;
            end
            xlim1 = max(1,xlim_selbox(1));
            xlim2 = min(Signal_Size,xlim_selbox(2));
        else
            xlim1 = 1; xlim2 = Signal_Size;
        end
        out1    = 1;
        out2    = ccfs_vm;
        out3    = find(flg_lev);
        out4(1) = xlim1;
        out4(2) = xlim2;
        out5    = def_nbCodeOfColors;
        img     = findobj(axe_hdl,'Type','image');
        if ~isempty(img)
            usr = get(img,'UserData');
            blk = [out2 out3 out4 out5];
            if isequal(usr,blk) , out1 = 0; end
        end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
