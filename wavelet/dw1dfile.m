function [out1,out2,out3,out4] = dw1dfile(option,win_dw1dtool,in3,in4)
%DW1DFILE Discrete wavelet 1-D file manager.
%   [OUT1,OUT2,OUT3,OUT4] = DW1DFILE(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 06-Jul-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;
% nb0_stored   =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
% ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
% ind_act_option = 6;
% ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
% nb2_stored    = 2;

% MemBloc3 of stored values.
%---------------------------
n_synt_sig = 'Synt_Sig';
ind_ssig   =  1;
% nb3_stored =  1;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
% ind_graph_area =  1;
% ind_view_mode  =  2;
ind_savepath   =  3;
% nb4_stored     =  3;

% Default values.
%---------------- 
percentYLIM = 0.01;
epsilon = 0.01;
nbMinPt = 20;
Wave_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);

switch option
    case 'anal'
        %******************************************************%
        %** OPTION = 'anal' -  Computing and saving Analysis.**%
        %******************************************************%
        % in3 optional (for 'load_dec' or 'synt' or 'new_anal')
        %------------------------------------------------------
        if nargin==2
            numopt = 1;
        elseif strcmp(in3,'new_anal')
            numopt = 2;
        else
            numopt = 3;
        end     

        % Getting  Analysis parameters.
        %------------------------------
        [Signal_Name,Level_Anal] =   ...
                wmemtool('rmb',win_dw1dtool,n_param_anal,  ...
                               ind_sig_name,ind_lev_anal  ...
                               );
        pathname = wmemtool('rmb',win_dw1dtool,n_InfoInit,ind_pathname);
        filename = wmemtool('rmb',win_dw1dtool,n_InfoInit,ind_filename);
        if numopt<3
            if numopt==1
                try
                    Anal_Data_Info = wtbxappdata('get',win_dw1dtool,...
                        'Anal_Data_Info');
                    Signal_Anal = Anal_Data_Info{1};
                catch %#ok<*CTCH>
                    try
                        load([pathname filename],'-mat');
                        Signal_Anal = eval(Signal_Name);
                        if size(Signal_Anal,1)>1 , Signal_Anal = Signal_Anal'; end
                    catch
                        [Signal_Anal,ok] = ...
                            utguidiv('direct_load_sig',win_dw1dtool,pathname,filename);
                        if ~ok
                            msg = getWavMSG('Wavelet:dw1dRF:ErrFile',filename);
                            wwaiting('off',win_dw1dtool);
                            errordlg(msg,getWavMSG('Wavelet:dw1dRF:LoadSigErr'),'modal');
                            return
                        end
                    end
                end
            else
                Signal_Anal = dw1dfile('sig',win_dw1dtool);
            end
            [coefs,longs] = wavedec(Signal_Anal,Level_Anal,Wave_Name);

            % Writing coefficients.
            %----------------------
            wmemtool('wmb',win_dw1dtool,n_coefs_longs,...
                           ind_coefs,coefs,ind_longs,longs);
        else
            [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                           ind_coefs,ind_longs);
        end

        % Saving.
        %-------
        out1 = wrcoef('a',coefs,longs,Wave_Name,0);
        wmemtool('wmb',win_dw1dtool,n_synt_sig,ind_ssig,out1);
        
    case 'comp_ss'
        %***********************************************************%
        %** OPTION = 'comp_ss' -  Computing and saving Synt. Sig. **%
        %***********************************************************%
        % Used by return_comp & return_deno
        % in3 = hdl_lin
        %------------------------------------
        ssig_rec = get(in3,'YData');
        wmemtool('wmb',win_dw1dtool,n_synt_sig,ind_ssig,ssig_rec);

    case 'app'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
            ind_coefs,ind_longs);
        out1 = wrmcoef('a',coefs,longs,Wave_Name,in3);
        if nargin<4 , return; end
        switch in4
            case 1
                lx = size(out1,2);
                l3 = length(in3);
                bord = getEdgeSize(in3,Wave_Name);
                lrem = lx+1-2*bord;
                out2 = zeros(1,l3);
                out4 = zeros(1,l3);
                out3 = zeros(1,l3);
                for k = 1:l3
                    if lrem(k)>nbMinPt
                        out2(k) = 1;
                        Xidx = bord(k):lrem(k)+bord(k);
                    else
                        Xidx = 1:lx;
                    end
                    [out3(k),out4(k)] = getMinMax(out1(k,Xidx),percentYLIM);
                end

            case 2
                [out2,out3] = getMinMax(out1,percentYLIM);

            case 3
                lx  = size(out1,2);
                l3  = length(in3);
                bord = getEdgeSize(in3,Wave_Name);
                lrem = lx+1-2*bord;
                out2 = zeros(1,l3);
                out3 = zeros(1,l3);
                for k = 1:l3
                    if lrem(k)>nbMinPt
                        Xidx = bord(k):lrem(k)+bord(k);
                    else
                        Xidx = 1:lx;
                    end
                    [out2(k),out3(k)] = getMinMax(out1(k,Xidx),percentYLIM);
                end
        end

    case 'det'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
            ind_coefs,ind_longs);
        out1 = wrmcoef('d',coefs,longs,Wave_Name,in3);
        if nargin<4 , return; end
        if in4==1
            lx = size(out1,2);
            l3 = length(in3);
            bord = getEdgeSize(in3,Wave_Name);
            lrem = lx+1-2*bord;
            out2 = zeros(1,l3);
            out4 = zeros(1,l3);
            out3 = zeros(1,l3);
            for k = 1:l3
                if lrem(k)>nbMinPt
                    out2(k) = 1;
                    Xidx = bord(k):lrem(k)+bord(k);
                else
                    Xidx = 1:lx;
                end
                [out3(k),out4(k)] = ...
                    getMinMax(out1(k,Xidx),percentYLIM);
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'sig'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
            ind_coefs,ind_longs);
        out1 = wrcoef('a',coefs,longs,Wave_Name,0);
        if nargin==3
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'ssig'
        out1 = wmemtool('rmb',win_dw1dtool,n_synt_sig,ind_ssig);
        if nargin==3
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'cfs_beg'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
            ind_coefs,ind_longs);
        cfs_beg = wrepcoef(coefs,longs);
        out1 = cfs_beg(in3,:);
        if nargin<4 , return; end
        if in4==1
            lx = size(out1,2);
            l3 = length(in3);
            bord = getEdgeSize(in3,Wave_Name);
            lrem = lx+1-2*bord;
            out2 = zeros(1,l3);
            out4 = zeros(1,l3);
            out3 = zeros(1,l3);
            for k = 1:l3
                if lrem(k)>nbMinPt
                    out2(k) = 1;
                    Xidx = bord(k):lrem(k)+bord(k);
                else
                    Xidx = 1:lx;
                end
                [out3(k),out4(k)] = ...
                    getMinMax(out1(k,Xidx),percentYLIM);
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end
        
    case 'app_cfs'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        out1 = appcoef(coefs,longs,Wave_Name,in3);
        if nargin<4 , return; end
        if in4==1
            bord = getEdgeSize(in3,Wave_Name);
            lx = size(out1,2);
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                Xidx = (bord:lrem+bord);
                [out3,out4] = getMinMax(out1(Xidx),percentYLIM);
            else
                out2 = 0;
                out3 = -epsilon;
                out4 = epsilon;
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'det_cfs'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        out1 = detcoef(coefs,longs,in3);
        if nargin<4 , return; end
        if in4==1
            bord = getEdgeSize(in3,Wave_Name);
            lx = size(out1,2);
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                Xidx = bord:lrem+bord;
                [out3,out4] = getMinMax(out1(Xidx),percentYLIM);
            else
                out2 = 0;
                out3 = -epsilon;
                out4 = epsilon;
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'del'
        %************************************%
        %** OPTION = 'del' -  Delete files.**%
        %************************************%
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        if ~isempty(pathname)
           try    
               cd(pathname);
           catch
               return;
           end
        end
        wmemtool('wmb',win_dw1dtool,n_miscella,ind_savepath,'');
end


%---------------------------------------------------------------
function [mini,maxi] = getMinMax(val,percent)

[~,dim] = max(size(val));
mini  = min(val,[],dim);
maxi  = max(val,[],dim);
delta = max([maxi-mini,sqrt(eps)]);
mini  = mini-percent*delta;
maxi  = maxi+percent*delta;
%---------------------------------------------------------------
function edgeS = getEdgeSize(lev,wname)

f = wfilters(wname);
edgeS = (2.^(lev+1))+ length(f);
%---------------------------------------------------------------
