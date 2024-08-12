function varargout = wtranslate(varargin)
%WTRANSLATE Translation of strings for GUI and command line functions.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Nov-2011.
%   Last Revision: 21-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $

nbIN = nargin;
if nbIN<2
    callingSTR = lower(varargin{1});
    if ~strncmpi(callingSTR,'ORI',3)
        switch callingSTR
            case 'manlvl'
                varargout{1} = getWavMSG('Wavelet:LastMessages:ManLVL');
            case 'manglb'
                varargout{1} = getWavMSG('Wavelet:LastMessages:ManGLB');
                
            case 'lstcolormap'
                names = {'pink','cool','gray','hot','jet','bone','copper',...
                    'hsv','prism','one_pink','one_cool','one_gray','one_hot','one_jet', ...
                    'one_bone','autumn','spring','winter','summer'};
                nbMaps = length(names);
                lst = cell(nbMaps,1);
                for k = 1:nbMaps
                    lst{k} = getWavMSG(['Wavelet:LastMessages:' names{k}]);
                end
                varargout{1} = lst;
                
            case 'lstentropy'  % Translated entropies name
                names = {'shannon','threshold','norm', ...
                    'logenergy','sure','user'};
                nbEnt = length(names);
                lst = cell(nbEnt,1);
                for k = 1:nbEnt
                    lst{k} = getWavMSG(['Wavelet:LastMessages:' names{k}]);
                end
                varargout{1} = lst;
                
            case 'mdw1dmode'     % Translated mdw1d visualization modes
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:SupMode'); ...
                    getWavMSG('Wavelet:LastMessages:SepMode'); ...
                    '-------------------';...
                    getWavMSG('Wavelet:LastMessages:DecMode'); ...
                    getWavMSG('Wavelet:LastMessages:DecModeCfs'); ...
                    getWavMSG('Wavelet:LastMessages:StemMode'); ...
                    getWavMSG('Wavelet:LastMessages:StemModeAbs'); ...
                    getWavMSG('Wavelet:LastMessages:StemModeSqr'); ...
                    getWavMSG('Wavelet:LastMessages:StemModeEner'); ...
                    getWavMSG('Wavelet:LastMessages:TreeMode')  ...
                    };
            
            case 'mdw1dmodeini'     % Translated mdw1d visualization modes
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:SupMode'); ...
                    getWavMSG('Wavelet:LastMessages:SepMode')  ...
                    };

            case 'ahc_dist'
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:euclidean'); ...
                    getWavMSG('Wavelet:LastMessages:seuclidean'); ...
                    getWavMSG('Wavelet:LastMessages:cityblock'); ...
                    getWavMSG('Wavelet:LastMessages:mahalanobis'); ...
                    getWavMSG('Wavelet:LastMessages:minkowski'); ...
                    getWavMSG('Wavelet:LastMessages:cosine'); ...
                    getWavMSG('Wavelet:LastMessages:correlation'); ...
                    getWavMSG('Wavelet:LastMessages:spearman'); ...
                    getWavMSG('Wavelet:LastMessages:hamming'); ...
                    getWavMSG('Wavelet:LastMessages:jaccard'); ...
                    getWavMSG('Wavelet:LastMessages:chebychev'); ...
                    '-------------------';  ...
                    getWavMSG('Wavelet:LastMessages:wenergy');  ...
                    getWavMSG('Wavelet:LastMessages:wenergyPER');  ...
                    getWavMSG('Wavelet:LastMessages:userdef')  ...
                    };
                
            case 'ahc_link'
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:single'); ...
                    getWavMSG('Wavelet:LastMessages:complete'); ...
                    getWavMSG('Wavelet:LastMessages:average'); ...
                    getWavMSG('Wavelet:LastMessages:weighted'); ...
                    getWavMSG('Wavelet:LastMessages:centroid'); ...
                    getWavMSG('Wavelet:LastMessages:median'); ...
                    getWavMSG('Wavelet:LastMessages:ward') ...
                    };
                
            case 'kmeans_dist'
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:seuclidean'); ...
                    getWavMSG('Wavelet:LastMessages:cityblock'); ...
                    getWavMSG('Wavelet:LastMessages:cosine'); ...
                    getWavMSG('Wavelet:LastMessages:hamming') ...
                    };
                
            case 'kmeans_link'
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:sample'); ...
                    getWavMSG('Wavelet:LastMessages:uniform'); ...
                    getWavMSG('Wavelet:LastMessages:cluster') ...
                    };
            case 'fus_meth'
                varargout{1} = {...
                    getWavMSG('Wavelet:LastMessages:max'); ...
                    getWavMSG('Wavelet:LastMessages:min'); ...
                    getWavMSG('Wavelet:LastMessages:mean'); ...
                    getWavMSG('Wavelet:LastMessages:rand'); ...
                    getWavMSG('Wavelet:LastMessages:linear'); ...
                    getWavMSG('Wavelet:LastMessages:UD_fusion'); ...
                    getWavMSG('Wavelet:LastMessages:DU_fusion'); ...
                    getWavMSG('Wavelet:LastMessages:LR_fusion'); ...
                    getWavMSG('Wavelet:LastMessages:RL_fusion'); ...
                    getWavMSG('Wavelet:LastMessages:img1'); ...
                    getWavMSG('Wavelet:LastMessages:img2'); ...
                    getWavMSG('Wavelet:LastMessages:userdef')  ...
                    };                
        end
    else
        callingSTR = callingSTR(5:end);
        switch callingSTR
            case 'lstcolormap'   % Original colormap name
                varargout{1} = mextglob('get','Lst_ColorMap');
                
            case 'lstentropy'    % Original entropies name
                varargout{1} = {'shannon','threshold','norm', ...
                    'log energy','sure','user'};
                
            case 'mdw1dmode'     % Original mdw1d visualization modes
                varargout{1} = {'Superimpose Mode';'Separate Mode';...
                    '-------------------';...
                    'Full Dec Mode';'Full Dec Mode (Cfs)';...
                    'Stem Mode';'Stem Mode (Abs)';'Stem Mode (Squared)';...
                    'Stem Mode (Energy Ratio)';'Tree Mode'};
                
            case 'mdw1dmodeini'  % Original mdw1d visualization modes
                varargout{1} = {'Superimpose Mode';'Separate Mode'};

            case 'ahc_dist'
                varargout{1} = {...
                    'euclidean','seuclidean','cityblock','mahalanobis',      ...
                    'minkowski','cosine','correlation','spearman','hamming', ...
                    'jaccard','chebychev','------------------- ',            ...
                    'wenergy','wenergyPER','userdef' ...
                    };
                
            case 'ahc_link'
                varargout{1} = {...
                    'single','complete','average','weighted', ...
                    'centroid','median','ward'};

            case 'kmeans_dist'
                varargout{1} = {'sqeuclidean','cityblock','cosine','hamming'};
                
            case 'kmeans_link'
                varargout{1} = {'sample','uniform','cluster'};  
                
            case 'fus_meth'
                varargout{1} = {'max','min','mean','rand','linear', ...
                    'UD_fusion','DU_fusion','LR_fusion','RL_fusion', ...
                    'img1','img2','userDEF'};
        end
    end
    return
end

callingTool = lower(varargin{1}); 
hObject = varargin{2}; 
uic = wfindobj(hObject,'type','uicontrol');
tag = get(uic,'tag');
pan = wfindobj(hObject,'type','uipanel');
tagPAN = get(pan,'tag');
switch callingTool
    case {...
            'cwtfttool','dw1dview_dorc','dw3dtool', ...
            'wmp1dtool','wmpmoreoncfs','wfbmtool','wfbmstat','wfustool', ...
            'mdw1dtool','mdw1dcomp','mdw1ddeno','mdw1dclus','mdw1dstat', ...
            'wmspcatool','wmuldentool',  ...
            'nwavtool','compwav','wc2dtool', ...
            'showclusters','showparttool','cwtfttool2'  ...
            }
        idx = strcmp(tag,'Tog_View_Axes');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Dynv_ViewAxes'));
        idx = strcmp(tag,'Txt_History');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Dynv_History'));
        idx = strcmp(tag,'Txt_Info');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Dynv_Info'));
        idx = strcmp(tag,'Txt_Center');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:commongui:Dynv_Center'), ...
            getWavMSG('Wavelet:commongui:Dynv_On') ...            
            });
        idx = strcmp(tag,'Txt_Data_NS');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sig'));        
        idx = strcmp(tag,'Pus_CloseWin');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Close'), ...
            'ToolTipString',getWavMSG('Wavelet:commongui:Tip_CloseWin') ...
            );
        idx = strcmp(tag,'Txt_PAL');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_PAL'), ...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_PAL_Tip'));
        idx = strcmp(tag,'Pop_PAL');
        lstMap = wtranslate('lstcolormap');       
        set(uic(idx), ...
            'String',lstMap, ...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_PAL_Tip'));
        idx = strcmp(tag,'Txt_NBC');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_NBC'), ...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_NBC_Tip'));
        idx = strcmp(tag,'Sli_NBC');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:commongui:Str_NBC_Tip'));
        idx = strcmp(tag,'Edi_NBC');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:commongui:Str_NBC_Tip'));
        idx = strcmp(tag,'Txt_BRI');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_BRI'), ...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_BRI_Tip'));
        idx = strcmp(tag,'Pus_BRI_M');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:commongui:Str_BRI_Tip'));
        idx = strcmp(tag,'Pus_BRI_P');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:commongui:Str_BRI_Tip'));
        LstPus = {'XMinus';'XPlus';'YMinus';'YPlus';'XYMinus';'XYPlus'};
        for k = 1:length(LstPus)
            strEnd = LstPus{k};
            tagPus = ['Pus_Zoom' strEnd];
            idx = strcmp(tag,tagPus);
            set(uic(idx),'ToolTipString', ...
                getWavMSG(['Wavelet:commongui:Tip_Zoom' strEnd]));
        end
        idx = strcmp(tag,'Fra_ColPar');
        set(uic(idx),'ToolTipString',...
            getWavMSG('Wavelet:commongui:Lab_CMapSet'));
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % FOR NEXT VERSION OF MODIFICATIONS 
% % ---------------------------------
%     idx = strcmp(tag,'Pop_VisPanMode');
%     if any(idx)
%         NbModes = length(get(uic(idx),'String'));
%         switch NbModes
%             case 2    , StrMODE = wtranslate('mdw1dmodeini');
%             otherwise , StrMODE = wtranslate('mdw1dmode');
%         end
%         set(uic(idx),'String',StrMODE);
%     end
%     idx = strcmp(tag,'Pop_Show_Mode');
%     if any(idx)
%         NbModes = length(get(uic(idx),'String'));
%         switch NbModes
%             case 2    , StrMODE = wtranslate('mdw1dmodeini');
%             otherwise , StrMODE = wtranslate('mdw1dmode');
%         end
%         set(uic(idx),'String',StrMODE);
%     end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch callingTool
    case {'waveletanalyzer','demoguimwin'}
        if isequal(callingTool,'waveletanalyzer')
            msgIdent = 'Wavelet:divGUIRF:WM_Name';
        else
            msgIdent = 'Wavelet:wavedemoMSGRF:WM_GUI_Examples';
        end
        set(hObject,'Name',getWavMSG(msgIdent))
        
        idx = strcmp(tag,'Pus_Close_Win');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Close'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Pus_Close'));
        LstTags = { ... 
            'Pus_DW1D';'Pus_DW2D';'Pus_DW3D';'Pus_WP1D';'Pus_WP2D'; ...
            'Pus_SW1D';'Pus_SW2D';'Pus_CF1D';'Pus_CF2D';'Pus_CW1D';...
            'Pus_CWIM';'Pus_IMGX';'Pus_SIGX';'Pus_REGF';'Pus_EDEN'; ...
            'Pus_NWAV';'Pus_COMP_2D';'Pus_WPDI';'Pus_WVDI';  ...
            'Pus_WFUS';'Pus_WFBM';'Pus_WMP1D';'Pus_CWTFT_1D';...
            'Pus_WMSPCA';'Pus_MUL_ANAL';'Pus_MUL_DEN';'Pus_CWT2D'  ...
            };
        for k=1:length(LstTags)
            tagStr = LstTags{k};
            idx = strcmp(tag,tagStr);
            set(uic(idx), ...
                'String',getWavMSG(['Wavelet:divGUIRF:WM_' tagStr]), ...
                'ToolTipString',getWavMSG(['Wavelet:divGUIRF:Tip_'  tagStr]));
        end
        LstTxts = { ...
            'Txt_One_Dim';'Txt_Two_Dim';'Txt_Spc_1D';'Txt_Spc_2D'; ...
            'Txt_Disp';'Txt_Multi_1D';'Txt_Design';'Txt_DW3D';'Txt_Ext'; ...
            'edit2' ...
            };
        for k=1:length(LstTxts)
            tagStr = LstTxts{k};
            idx = strcmp(tag,tagStr);
            set(uic(idx),'String',getWavMSG(['Wavelet:divGUIRF:WM_' tagStr]));
        end
        
    case 'cwtfttool2'
        set(hObject,'Name',getWavMSG('Wavelet:cwtfttool2:CWTFT2_Name')) 
        idx = strcmp(tag,'Txt_Data_NS');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Image'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Data_NS_Tip'));
        idx = strcmp(tag,'Edi_Data_NS');        
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Data_NS_Tip'));
        idx = strcmp(tag,'Txt_DEF_SCA');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Scales'));
        idx = strcmp(tag,'Txt_WAV_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Txt_SAMP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Sampling'));
        idx = strcmp(tag,'Txt_WAV_PAR');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_WAV_PAR'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:WAV_PAR_Tip'));
        idx = strcmp(tag,'Pus_ANAL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Anal'), ...
            'TooltipString',getWavMSG('Wavelet:cwtfttool2:Pus_ANAL'));        
        idx = strcmp(tag,'Txt_BigTitle');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_BigTitle'));
        idx = strcmp(tag,'Pus_SEL_Scales');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_SelectScales'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Pus_SEL_Scales_Tip') ...
            );            
        idx = strcmp(tag,'Pus_DEF_SCA');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_Define'));
        idx = strcmp(tag,'Txt_DEF_ANG');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_Angles'));        
        idx = strcmp(tag,'Pus_DEF_ANG');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_Define'));        
        idx = strcmp(tag,'Pus_SEL_Angles');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_SelectAngles'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Pus_SEL_Angles_Tip') ...
            );                        
        idx = strcmp(tag,'Pus_DEF_APPLY');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Pus_DEF_CANCEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Pus_DEF_Def');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_Def'));
        idx = strcmp(tag,'Pus_SEL_CLOSE');                
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Close'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Str_Close_Tip') ...
            );
        idx = strcmp(tag,'Pus_SEL_ALL');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_All'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Select_All_Scales') ...
            );
        idx = strcmp(tag,'Pus_SEL_NON');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_None'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Str_None_Tip') ...
            );
        idx = strcmp(tag,'Pus_ShowCfs');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Show_Cfs'));
        idx = strcmp(tag,'Pus_ShowCfs');
        set(uic(idx),'ToolTipString', ...
            [getWavMSG('Wavelet:divGUIRF:CWTFT_Lst_SEL_REC_Tip_1'),'\n',...
             getWavMSG('Wavelet:divGUIRF:CWTFT_Lst_SEL_REC_Tip_2')]);
        idx = strcmp(tag,'Pus_INV');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Pseudo_INV'));
        idx = strcmp(tag,'Pus_StopMOV');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Stop_Movie'));
        idx = strcmp(tag,'Pus_MOVIE');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Movie'));
        idx = strcmp(tag,'Txt_PAN_Sel');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Num_Value'));
        idx = strcmp(tag,'Pop_DEF_SCA');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:cwtfttool:Linear_Def'), ...
            getWavMSG('Wavelet:cwtfttool:Dyadic_Def'), ...            
            getWavMSG('Wavelet:cwtfttool:Str_Manual')} ...            
            ); 
        idx = strcmp(tag,'Pop_DEF_ANG');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool2:Str_Zero'), ...
            getWavMSG('Wavelet:cwtfttool2:Lin_Spaced_Def'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Manual')}  ...            
            );
        idx = strcmp(tag,'Pop_ANG_TYPE');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:cwtfttool2:Lin_Spaced'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Manual')}  ...            
            );
        idx = strcmp(tag,'Pus_DEF_Def');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_Def'));
        idx = strcmp(tag,'Pus_DEF_CANCEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Txt_SCA_INI');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_INI'), ...
           'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_INI_Tip'));
        idx = strcmp(tag,'Edi_SCA_INI');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_INI_Tip'));
        idx = strcmp(tag,'Txt_SCA_SPA');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_SPA'), ...
           'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_SPA_Tip'));
        idx = strcmp(tag,'Edi_SCA_SPA');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_SPA_Tip'));
        idx = strcmp(tag,'Txt_SCA_NB');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_NB'), ...
           'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_NB_Tip'));
        idx = strcmp(tag,'Edi_SCA_NB');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Txt_SCA_NB_Tip'));
        idx = strcmp(tag,'Txt_SCA_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Type'));
        idx = strcmp(tag,'Pus_DEF_APPLY');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Rad_ON');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Rad_ON'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Tip_Rad_ON') ...
            );
        idx = strcmp(tag,'Pop_SCA_TYPE');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool:Str_Power'),...
            getWavMSG('Wavelet:cwtfttool:Str_Linear'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Manual')}  ...            
            );
        idx = strcmp(tag,'Pus_Apply');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Pus_APPLY_Tip'));            
        idx = strcmp(tag,'Txt_Cur_SCA');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Current_SCA'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Current_SCA_Tip'));
        idx = strcmp(tag,'Pop_Cur_SCA');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Current_SCA_Tip'));       
        idx = strcmp(tag,'Txt_Cur_ANG');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Current_ANG'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Current_ANG_Tip'));
        idx = strcmp(tag,'Pop_Cur_ANG');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:cwtfttool2:Current_ANG_Tip'));        
        idx = strcmp(tagPAN,'Pan_Visu');
        set(pan(idx),'Title',getWavMSG('Wavelet:cwtfttool2:Sel_SCA_and_ANG'));
        idx = strcmp(tag,'Pus_SCA_Default');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_Def'));
        idx = strcmp(tag,'Pus_ANG_Default');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_Def'));
        idx = strcmp(tag,'Pus_SCA_Cancel');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Pus_ANG_Cancel');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Pus_SCA_Apply');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Pus_ANG_Apply');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));        
        idx = strcmp(tag,'Txt_ANG_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Type'));
        idx = strcmp(tag,'Txt_SCA_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Type'));
        idx = strcmp(tag,'Txt_UNITS');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Units_Angles'));
        idx = strcmp(tag,'Pop_ANG_Unit');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_Radians'));
        idx = strcmp(tag,'Pus_More_Params');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Txt_More_Params'), ...
            'ToolTipString',getWavMSG('Wavelet:cwtfttool2:WAV_PAR_Tip'));
        idx = strcmp(tag,'Pus_Default_Param');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Default_Params'));
        idx = strcmp(tag,'Pus_EQUA');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Show_Formulae'));
        idx = strcmp(tag,'Pus_Apply_PAR');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Apply_And_Close'));
        idx = strcmp(tag,'Pus_Cancel_Params');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Cancel_And_Close'));
        tab = wfindobj(hObject,'type','uitable','Tag','Tab_Params');
        set(tab,'ColumnName',{...
            getWavMSG('Wavelet:cwtfttool2:NamTabPar_1'), ...
            getWavMSG('Wavelet:cwtfttool2:NamTabPar_2'), ...
            getWavMSG('Wavelet:cwtfttool2:NamTabPar_3')  ...            
            });
        idx = strcmp(tagPAN,'Pan_SEL_SC');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:cwtfttool2:Pan_SEL_Scales')));
        idx = strcmp(tagPAN,'Pan_Visu');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:cwtfttool2:Sel_SCA_and_ANG')));
        idx = strcmp(tagPAN,'Pan_More_ON');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:cwtfttool2:Pan_More_ON')));
        idx = strcmp(tagPAN,'Pan_SEL_SCA_ANG');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:cwtfttool2:Pan_SEL_SCA_ANG')));
        idx = strcmp(tagPAN,'Pan_More_Params');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:cwtfttool2:Txt_More_Params')));
                
    case 'cwtfttool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:CWTFT_Name')) 
        idx = strcmp(tag,'Txt_BigTitle');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_BigTitle'));
        idx = strcmp(tag,'Pus_HLP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_HLP'));
        idx = strcmp(tag,'Pus_MAN_CLOSE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Close'));
        idx = strcmp(tag,'Pus_MAN_DEL');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_MAN_DEL'));
        idx = strcmp(tag,'Pus_MAN_REC');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Synthesize'));
        idx = strcmp(tag,'Edi_MAN_TIT');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Edi_MAN_TIT'));
        idx = strcmp(tag,'Pop_AXE_MAN');
        set(uic(idx),'ToolTipString', ...
            getWavMSG('Wavelet:divGUIRF:CWTFT_Tip_Pop_AXE_MAN'));
        idx = strcmp(tag,'Pus_DEF_MAN');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_MAN'));
        idx = strcmp(tag,'Txt_WAV_PAR');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_WAV_PAR'));
        idx = strcmp(tag,'Txt_SAMP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_SAMP'));
        idx = strcmp(tag,'Txt_DEF_SCA');
        set(uic(idx),'String',getWavMSG('Wavelet:cwtfttool2:Str_Scales'));
        idx = strcmp(tag,'Txt_WAV_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Pus_ANAL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Anal'));
        idx = strcmp(tag,'Rad_ON');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Rad_ON'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Tip_Rad_ON') ...
            );
        idx = strcmp(tag,'Pus_DEF_Def');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_DEF_Def'));
        idx = strcmp(tag,'Pus_DEF_CANCEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Txt_SCA_INI');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_SCA_INI'));
        idx = strcmp(tag,'Txt_SCA_SPA');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_SCA_SPA'));
        idx = strcmp(tag,'Txt_SCA_NB');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_SCA_NB'));
        idx = strcmp(tag,'Txt_SCA_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Type'));
        idx = strcmp(tag,'Pus_DEF_APPLY');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Pus_SEL_REC');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Synthesize'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_SEL_REC_Tip') ...
            );
        idx = strcmp(tag,'Pus_SEL_REC');
        set(uic(idx),'ToolTipString', ...
            [getWavMSG('Wavelet:divGUIRF:CWTFT_Lst_SEL_REC_Tip_1'),'\n',...
             getWavMSG('Wavelet:divGUIRF:CWTFT_Lst_SEL_REC_Tip_2')]);
        idx = strcmp(tag,'Txt_PAN_Sel');                
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_PAN_Sel'));
        idx = strcmp(tag,'Pus_SEL_ALL');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_All'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Str_All_Tip') ...
            );
        idx = strcmp(tag,'Pus_SEL_NON');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_None'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Str_None_Tip') ...
            );
        idx = strcmp(tag,'Pus_SEL_CLOSE');                
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Close'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:CWTFT_Str_Close_Tip') ...
            );
        idx = strcmp(tag,'Txt_SHO_REC');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_SHO_REC'));
        idx = strcmp(tag,'CHK_MAN_REC');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_CHK_MAN_REC'));
        idx = strcmp(tag,'CHK_LST_REC');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_CHK_LST_REC'));
        idx = strcmp(tag,'CHK_ORI_REC');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_CHK_ORI_REC'));
        idx = strcmp(tag,'Pus_MAN_OPEN');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_MAN_OPEN'));
        idx = strcmp(tag,'Pus_LST_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Pus_LST_SEL'));
        idx = strcmp(tag,'Txt_METH_SYNT');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:CWTFT_Txt_METH_SYNT'));
        
        idx = strcmp(tag,'Pop_AXE_MAN');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool:title_Modulus'), ...
            getWavMSG('Wavelet:cwtfttool:title_Angle'), ...
            getWavMSG('Wavelet:cwtfttool:title_RealPart'), ...
            getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart')}  ...            
            );
        idx = strcmp(tag,'Pop_DEF_SCA');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool:Dyadic_Def'), ...
            getWavMSG('Wavelet:cwtfttool:Linear_Def'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Manual')}  ...            
            );
        idx = strcmp(tag,'Pop_SCA_TYPE');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool:Str_Power'),...
            getWavMSG('Wavelet:cwtfttool:Str_Linear'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Manual')}  ...            
            );
        idx = strcmp(tag,'Pop_METH_SYNT');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:cwtfttool:Str_Dyadic'), ...
            getWavMSG('Wavelet:cwtfttool:Str_Linear')}  ...            
            );        
        idx = strcmp(tagPAN,'Pan_REC');
        set(pan(idx),'Title',getWavMSG('Wavelet:divGUIRF:CWTFT_Pan_REC'));
        idx = strcmp(tagPAN,'Pan_SEL_SC');
        set(pan(idx),'Title',getWavMSG('Wavelet:divGUIRF:CWTFT_Pan_SEL_SC'));
    
    case 'wfustool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:WFUS_Name'))        
        idx = strcmp(tag,'Txt_Edi_Det');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Parameter'));
        idx = strcmp(tag,'Txt_Edi_App');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Parameter'));
        idx = strcmp(tag,'Txt_Nod_Act');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:NodAct'));
        idx = strcmp(tag,'Txt_Nod_Lab');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:NodLab'));
        idx = strcmp(tag,'Pop_Nod_Act');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_FUS_NodAct'));
        idx = strcmp(tag,'Pop_Nod_Lab');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_FUS_NodLab'));
        idx = strcmp(tag,'Tog_Inspect');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Inspect_FusTree'));
        idx = strcmp(tag,'Txt_Fus_Params');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:SelFusMet'));
        idx = strcmp(tag,'Pus_Fusion');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Txt_Fus_Det');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Details'));
        idx = strcmp(tag,'Txt_Fus_App');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Approx'));
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Decompose'));
        idx = strcmp(tag,'Txt_Data_NS');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Image_X',1));        
        idx = strcmp(tag,'Txt_Image_2');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Image_X',2));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Level'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        LstMETH = wtranslate('fus_meth');
        idx = strcmp(tag,'Pop_Fus_App');
        set(uic(idx),'String',LstMETH);
        idx = strcmp(tag,'Pop_Fus_Det');
        set(uic(idx),'String',LstMETH);

    case 'nwavtool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:NWAV_Name'))        
        idx = strcmp(tag,'Txt_PolDegree');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_PolDegree'));
        idx = strcmp(tag,'Txt_TwoPatterns');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_TwoPatterns'));
        idx = strcmp(tag,'Chk_Noise');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_Noise'));
        idx = strcmp(tag,'Rad_Super');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Super'));
        idx = strcmp(tag,'Rad_Trans');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Trans'));
        idx = strcmp(tag,'Txt_With');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_With'));
        idx = strcmp(tag,'Chk_Triangle');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_Triangle'));
        idx = strcmp(tag,'Txt_RunSignal');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_RunSignal'));
        idx = strcmp(tag,'Pus_Compare');        
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_Compare'));
        idx = strcmp(tag,'Pus_Run');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_Run'));
        idx = strcmp(tag,'Txt_BoundCond');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_BoundCond'));
        idx = strcmp(tag,'Txt_ApproxMeth');        
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_ApproxMeth'));
        idx = strcmp(tag,'Txt_Interval');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Interval'));
        idx = strcmp(tag,'Pus_Approximate');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_Approximate'));
        idx = strcmp(tag,'Txt_Pattern');        
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Pattern'));
        idx = strcmp(tag,'Txt_UppBound');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_UppBound'));
        idx = strcmp(tag,'Txt_LowBound');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_LowBound'));
        idx = strcmp(tag,'Txt_Support');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Support'));
        idx = strcmp(tag,'Edi_UppBound');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Edi_UppBound_Tip'));
        idx = strcmp(tag,'Edi_LowBound');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Edi_LowBound_Tip'));
        idx = strcmp(tag,'Pop_BoundCond');
        set(uic(idx),'String',{ ...
               getWavMSG('Wavelet:commongui:Str_None'), ...
               getWavMSG('Wavelet:divGUIRF:Str_Continuous'), ...
               getWavMSG('Wavelet:divGUIRF:Str_Differentiable')} ...
               );
        idx = strcmp(tag,'Pop_ApproxMeth');
        set(uic(idx),'String',{ ...
               getWavMSG('Wavelet:divGUIRF:Str_Polynomial'), ...
               getWavMSG('Wavelet:divGUIRF:Str_Orth2Const')} ...
               );

    case 'compwav'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:Nam_Compwav'))   
        idx = strcmp(tag,'Txt_Which');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Which'));
        idx = strcmp(tag,'Rad_Test_Sig');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Test_Sig'));
        idx = strcmp(tag,'Rad_Contours');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Contours'));
        idx = strcmp(tag,'Rad_Images');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Images'));
        idx = strcmp(tag,'Txt_Coefs');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Coefs'));
        idx = strcmp(tag,'Rad_TwoPatterns');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_TwoPatterns'));
        idx = strcmp(tag,'Chk_Noise');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_Noise'));
        idx = strcmp(tag,'Rad_Super');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Super'));
        idx = strcmp(tag,'Rad_Trans');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Rad_Trans'));
        idx = strcmp(tag,'Txt_With');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_With'));
        idx = strcmp(tag,'Chk_Triangle');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_Triangle'));
        idx = strcmp(tag,'Txt_RunSignal');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Running_Signal'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Pus_Run');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_Run'));
        idx = strcmp(tag,'Fra_CFS_Disp');
        set(uic(idx),'ToolTipString',getWavMSG('Wavelet:commongui:Lab_CMapSet'));
        
    case 'wfbmstat'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:FBMStat_Name'))        
        idx = strcmp(tag,'Txt_Order');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Order'));
        idx = strcmp(tag,'Txt_NbBins');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_NbBins'));
        idx = strcmp(tag,'Pus_Statistics');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_show_stat'));
        idx = strcmp(tag,'Chk_Hist');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_HIST'));
        idx = strcmp(tag,'Chk_Stats');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_DesStat'));
        idx = strcmp(tag,'Chk_Auto');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_AutoCorr'));
        idx = strcmp(tag,'Txt_SelAxes');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_SelAxes'));
        idx = strcmp(tag,'Txt_LM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_LM_txt'));
        idx = strcmp(tag,'Txt_L2');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_L2_txt'));
        idx = strcmp(tag,'Txt_L1');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_L1_txt'));
        idx = strcmp(tag,'Txt_Mode');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mode_txt'));
        idx = strcmp(tag,'Txt_Median');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_med_txt'));
        idx = strcmp(tag,'Txt_Max');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_max_txt'));
        idx = strcmp(tag,'Txt_Range');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_range_txt'));
        idx = strcmp(tag,'Txt_Min');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_min_txt'));
        idx = strcmp(tag,'Txt_Mean');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mean_txt'));
        idx = strcmp(tag,'Txt_MeanAbsDev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_madm_txt'));
        idx = strcmp(tag,'Txt_StdDev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_std_txt'));
        idx = strcmp(tag,'Txt_MedAbsDev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mad_txt'));
        
    case 'dw3dtool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:DW3D_Name'))
        idx = strcmp(tag,'Txt_Data_NS');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_DatSiz'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Wav'));
        idx = strcmp(tag,'Txt_Wav_Y');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Wav_Y'));
        idx = strcmp(tag,'Txt_Wav_Z');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Wav_Z'));
        idx = strcmp(tag,'TxT_ExtM');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:TxT_ExtM'));
        idx = strcmp(tag,'Txt_3D_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_3D_DISP'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Lev'));
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Decompose'));
        idx = strcmp(tag,'Txt_LEV_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_LEV_DISP'));
        idx = strcmp(tag,'Txt_Slice_ORIENT');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Slice_ORIENT'));
        idx = strcmp(tag,'Pus_SLICE_MOV');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_SLICE_MOV'));
        idx = strcmp(tag,'Txt_SLICE_Cfs');
        set(uic(idx),'String',...
            getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Cfs','Z','---'));
        idx = strcmp(tag,'Txt_SLICE_Rec');
        set(uic(idx),'String',...
            getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Rec','Z','---'));
        idx = strcmp(tag,'Pop_3D_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_None'));

    case 'wfbmtool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:FBM_Name'))        
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Rad_Value');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_State'));        
        idx = strcmp(tag,'Rad_Random');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_CurState')); 
        idx = strcmp(tag,'text14');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Seed'));
        idx = strcmp(tag,'Pus_Generate');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Generate'));
        idx = strcmp(tag,'Txt_Len');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Length'));
        idx = strcmp(tag,'Pus_Statistics');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_STAT'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Refinement'));
        idx = strcmp(tag,'Txt_FI');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_FI'));
        
    case 'wmp1dtool'
        set(hObject,'Name',getWavMSG('Wavelet:wmp1dRF:NamWinWMP_1D'))
        idx = strcmp(tag,'Pus_RESIDUALS');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_RESIDUALS'));
        idx = strcmp(tag,'Pus_MORE');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_MORE'));
        idx = strcmp(tag,'Txt_Cfs_WMP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Cfs_WMP'));
        idx = strcmp(tag,'Txt_Signal');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Signal'));
        idx = strcmp(tag,'Pus_Approximate');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_Approximate'));
        idx = strcmp(tag,'Rad_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Rad_ALL'));
        idx = strcmp(tag,'Txt_HIGHT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_HIGHT'));
        idx = strcmp(tag,'Txt_WITH');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_WITH'));
        idx = strcmp(tag,'Pus_STOP_ALG');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_STOP_ALG'));
        idx = strcmp(tag,'Txt_ERR_MAX');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_ERR_MAXAbrev'));
        idx = strcmp(tag,'Pus_DEL_CMP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_DEL_CMP'));
        idx = strcmp(tag,'Pus_ADD_CMP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_ADD_CMP'));
        idx = strcmp(tag,'Pus_CLOSE_RECENT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_Close'));
        idx = strcmp(tag,'Pus_Clean_TAB');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_Clean_TAB'));
        idx = strcmp(tag,'Txt_STP_PLOT_2');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_STP_PLOT_2'));
        idx = strcmp(tag,'Pus_END_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_END_DISP'));
        idx = strcmp(tag,'Pus_STOP_PLOT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_STOP_PLOT'));
        idx = strcmp(tag,'Pus_START_PLOT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_START_PLOT'));
        idx = strcmp(tag,'Txt_TYP_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_TYP_DISP'));
        idx = strcmp(tag,'Txt_STP_PLOT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_STP_PLOT'));
        idx = strcmp(tag,'Pus_CLOSE_ADDCPT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_Close'));
        idx = strcmp(tag,'Pus_RECENT_CMP');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_RECENT_CMP'));
        idx = strcmp(tag,'Pus_ADD_In_LST');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_ADD_In_LST'));
        idx = strcmp(tag,'Txt_FAM_DICO');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_FAM_DICO'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Wav'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Lev'));
        idx = strcmp(tag,'Txt_ITER');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_ITER')); 
        idx = strcmp(tag,'Pop_ERR_MAX');        
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_ERR_MAX_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_ERR_MAX_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_ERR_MAX_3'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_ERR_MAX_4')   ...
            });
        idx = strcmp(tag,'Pop_TYP_DISP');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TYP_DISP_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TYP_DISP_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TYP_DISP_3')  ...
            });
        idx = strcmp(tag,'Pop_Type_ALG');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_Type_ALG_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_Type_ALG_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_Type_ALG_3')   ...
            });
        
        idx = strcmp(tagPAN,'Pan_ALG_PAR');
        set(pan(idx),'title',getWavMSG('Wavelet:wmp1dRF:Pan_ALG_PAR'))
        idx = strcmp(tagPAN,'Pan_DISP_PAR');
        set(pan(idx),'title',getWavMSG('Wavelet:wmp1dRF:Pan_DISP_PAR'))
        idx = strcmp(tagPAN,'Pan_DICO');
        set(pan(idx),'title',getWavMSG('Wavelet:wmp1dRF:Pan_DICO'))
        
    case 'wmpmoreoncfs'
        set(hObject,'Name',getWavMSG('Wavelet:wmp1dRF:NamWinMoreWMP_1D'))        
        idx = strcmp(tag,'Txt_PAL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_PAL'));
        idx = strcmp(tag,'Txt_NBC');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_NBC'));
        idx = strcmp(tag,'Txt_BRI');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_BRI'));        
        idx = strcmp(tag,'Edi_Title_CFS');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Edi_Title_CFS'));        
        idx = strcmp(tag,'text52');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:text52'));        
        idx = strcmp(tag,'Txt_ERR_L2');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_ERR_L2'));        
        idx = strcmp(tag,'Txt_Err_L1');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Err_L1'));        
        idx = strcmp(tag,'Txt_Err_MAX');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_Err_MAX'));        
        idx = strcmp(tag,'Txt_QUAL');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_QUAL'));
        idx = strcmp(tag,'Pus_SEL_CPT');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_SEL_CPT'));        
        idx = strcmp(tag,'Pus_ASC');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_ASC'));        
        idx = strcmp(tag,'Pus_DESC');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Pus_DESC'));        
        idx = strcmp(tag,'text50');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:text50'));        
        idx = strcmp(tag,'Txt_MODE_MORE');
        set(uic(idx),'String',getWavMSG('Wavelet:wmp1dRF:Txt_MODE_MORE'));
        idx = strcmp(tag,'Pop_Mode_MORE');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_MODE_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_MODE_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_MODE_3')  ...            
            });
        idx = strcmp(tag,'Pop_SORT_Table');        
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_3'), ...      
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_4'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_5'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SORT_6')   ...            
            });
        table = wfindobj(hObject,'type','uitable');
        set(table,'ColumnName',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_3'), ...      
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_4'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_5'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_TAB_6')   ...            
            });
        idx = strcmp(tag,'Pop_SEL_CPT');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SEL_1'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SEL_2'), ...
            getWavMSG('Wavelet:wmp1dRF:Pop_SEL_3')  ...
            }); 

    case 'dw1dview_dorc'
        idx = strcmp(tag,'Chk_ORI');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:OriSig'));
        
    case 'mdw1dtool'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D'))
        idx = strcmp(tag,'Pop_DIR');
        set(uic(idx),'String',{getWavMSG('Wavelet:LastMessages:columnwise'); ...
            getWavMSG('Wavelet:LastMessages:rowwise')}); 
        idx = strcmp(tag,'Chk_A_Ener');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_A_Ener')); 
        idx = strcmp(tag,'Txt_Max');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Max')); 
        idx = strcmp(tag,'Txt_Mean');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Mean')); 
        idx = strcmp(tag,'Txt_Min');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Min')); 
%         idx = strcmp(tag,'Edi_TIT_PAN_INFO');
%         set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Info_Sel_Data')); 
        idx = strcmp(tag,'Pus_Stats');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Stats')); 
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Decompose')); 
        idx = strcmp(tag,'Pus_Denoise');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Denoise')); 
        idx = strcmp(tag,'Pus_Compress');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Compress')); 
        idx = strcmp(tag,'Pus_CLU_TOOLS');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_CLU_TOOLS')); 
        idx = strcmp(tag,'Txt_Energy');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Energy')); 
        idx = strcmp(tagPAN,'Pan_ENERGY');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Ener_EnerRat')));
        idx = strcmp(tagPAN,'Pan_SEL_INFO');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Info_Sel_Data')));
        
    case 'mdw1dclus'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D_Clus'))
        idx = strcmp(tag,'Rad_AFF_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Signals'));
        idx = strcmp(tag,'Rad_AFF_DAT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Clustered_Data'));
%         idx = strcmp(tag,'Edi_TIT_VM');
%         set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VM'));
        idx = strcmp(tagPAN,'Pan_View_METH');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VM')));        
        idx = strcmp(tag,'Txt_SORT_IDX');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_SORT_IDX'));
        idx = strcmp(tag,'text81');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Plot_Sel'));
%         idx = strcmp(tag,'Edi_TIT_Dendro_Link');
%         set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Edi_TIT_Dendro_Link'));
        idx = strcmp(tagPAN,'Pan_Dendro_LINK');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_Dendro_Link')));                
        idx = strcmp(tag,'Txt_XPos');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_XPos'));
        idx = strcmp(tag,'Txt_XScale');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_XScale'));
        idx = strcmp(tag,'Sli_XScale');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Sli_XScale'));
        idx = strcmp(tag,'Pus_YScale');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_YScale'));
%         idx = strcmp(tag,'Edi_TIT_Dendro_Graph');
%         set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Edi_TIT_Dendro_Graph'));
        idx = strcmp(tagPAN,'Pan_Dendro_VISU');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_Dendro_Graph')));                
        idx = strcmp(tag,'Txt_Dendro_SORT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Dendro_SORT'));
        idx = strcmp(tag,'Pus_Dendro_SORT_Inv');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Dendro_SORT_Inv'));        
        idx = strcmp(tag,'Txt_DEL_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_NON'));        
        idx = strcmp(tag,'Pus_PART_MORE');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_PART_MORE'));
        idx = strcmp(tag,'Pus_PART_STORE');
        idx  = find(idx);
        for k = 1:length(idx)  
            ST = get(uic(idx(k)),'String');
            ST{1} = getWavMSG('Wavelet:mdw1dRF:Pus_PART_STORE');
            set(uic(idx(k)),'String',ST);
        end        
        idx = strcmp(tag,'Pus_PART_SAVE');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_PART_SAVE'));        
        idx = strcmp(tag,'Rad_Rec_CLU');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_Rec_CLU'), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_Rec_CLU_Tip') ...
            );        
        idx = strcmp(tag,'Rad_Res_CLU');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_Res_CLU'), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_Res_CLU_Tip') ...
            ); 
        idx = strcmp(tag,'Rad_Ori_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Original'));        
        idx = strcmp(tag,'Pus_DET_CLU_All_None');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_All'));        
        idx = strcmp(tag,'Txt_APP_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Approximation'));        
        idx = strcmp(tag,'Txt_DET_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Details'));        
        idx = strcmp(tag,'Rad_Cfs_CLU');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Str_Cfs'), ...            
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_Cfs_CLU_Tip'));        
        idx = strcmp(tag,'Rad_Sig_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sig'));        
        idx = strcmp(tag,'Rad_DorC_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Denoised'));
        idx = strcmp(tag,'Txt_CLU_METH');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_CLU_METH'));
        idx = strcmp(tag,'Pop_CLU_METH');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:LastMessages:AHC_Meth'), ...
            getWavMSG('Wavelet:LastMessages:kmeans_Meth')});
        idx = strcmp(tag,'Pop_CLU_DIST');
        StrDIST = wtranslate('ahc_dist');
        set(uic(idx),'String',StrDIST);
        idx = strcmp(tag,'Pop_CLU_LINK');
        StrLINK = wtranslate('ahc_link');
        set(uic(idx),'String',StrLINK);
        idx = strcmp(tag,'Txt_Nb_CLA');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Nb_CLA'));
        idx = strcmp(tag,'Pus_Cluster');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Cluster'));
        idx = strcmp(tag,'Txt_Distance');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Distance'));
        idx = strcmp(tag,'Txt_CLU_LINK');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Linkage'));
        idx = strcmp(tagPAN,'Pan_CLU_Params');
        set(pan(idx),'title',getWavMSG('Wavelet:mdw1dRF:Str_Clustering'));
        idx = strcmp(tagPAN,'Pan_DAT_to_CLU');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Data_to_Cluster')));
        idx = strcmp(tagPAN,'Pan_PART_MNGR');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_PART_MNGR')));            
        idx = strcmp(tag,'Pus_PART_MNGR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Open_PART_MNGR'));
        idx = strcmp(tag,'Pus_REN_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Pus_CUR_DEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Selected'));
        idx = strcmp(tag,'Pus_ALL_DEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_All'));
        idx = strcmp(tag,'Pus_ALL_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_All'));
        idx = strcmp(tag,'Pus_CUR_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Selected'));
        idx = strcmp(tag,'Txt_SEL_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Show_Partitions'));
        idx = strcmp(tag,'Pus_CLU_SHOW');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Show_Clusters'));
        idx = strcmp(tag,'Txt_REN_CLU');
        set(uic(idx),'String', ...
            {getWavMSG('Wavelet:mdw1dRF:Txt_REN_CLU_1'), ...
             getWavMSG('Wavelet:mdw1dRF:Txt_REN_CLU_2')});
        
    case 'mdw1dcomp'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D_Comp'))
        idx = strcmp(tag,'Pop_THR_METH');
        set(uic(idx),'String',{...
            getWavMSG('Wavelet:moreMSGRF:Remove_near_0'); ...
            getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm'); ...
            getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm_SQRT'); ...
            '----------------------------------------'; ...
            getWavMSG('Wavelet:moreMSGRF:Global_THR'); ...
            getWavMSG('Wavelet:LastMessages:EnerRAT'); ...
            getWavMSG('Wavelet:LastMessages:ZeroRAT'); ...
            '----------------------------------------'; ...
            getWavMSG('Wavelet:moreMSGRF:Scarce_high'); ...
            getWavMSG('Wavelet:moreMSGRF:Scarce_medium'); ...
            getWavMSG('Wavelet:moreMSGRF:Scarce_low'); ...
            getWavMSG('Wavelet:LastMessages:Scarce') ...
            });         
        idx = strcmp(tag,'Txt_MAN_LEV');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_LEV')); 
        idx = strcmp(tag,'Txt_MAN_GLB_THR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_GLB_THR')); 
        idx = strcmp(tag,'Txt_N0_PERF');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_N0_PERF')); 
        idx = strcmp(tag,'Txt_L2_PERF');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_L2_PERF')); 
        idx = strcmp(tag,'Txt_MAN_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_SEL')); 
        idx = strcmp(tag,'Pus_MAN_Valid');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_MAN_Valid')); 
        idx = strcmp(tag,'Txt_MAN_THR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_THR')); 
        idx = strcmp(tag,'Rad_NO');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_NO')); 
        idx = strcmp(tag,'Rad_YES');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_YES')); 
        idx = strcmp(tag,'Txt_APP_KEEP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_APP_KEEP')); 
        idx = strcmp(tag,'Pus_ENA_MAN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_ENA_MAN')); 
        idx = strcmp(tag,'Pus_Compute_RESET');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Compute_RESET')); 
        idx = strcmp(tag,'Pus_Compute_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Selected')); 
        idx = strcmp(tag,'Txt_Compute_PAR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Compute_PAR')); 
        idx = strcmp(tag,'Pus_Compute_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Compute_ALL')); 
        idx = strcmp(tag,'Pus_Compress');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_COMP')); 
        idx = strcmp(tag,'Rad_HARD');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Hard')); 
        idx = strcmp(tag,'Rad_SOFT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Soft')); 
        idx = strcmp(tag,'Txt_THR_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_THR_TYPE')); 
        idx = strcmp(tag,'Txt_GLB_PAR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_GLB_PAR')); 
        idx = strcmp(tag,'Txt_THR_METH');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_THR_METH'));
        idx = strcmp(tagPAN,'Pan_Compress');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Str_Thresholding')));
        idx = strcmp(tagPAN,'Pan_MAN_THR');        
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_MAN')));
                
    case 'mdw1ddeno'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D_Deno'))
        idx = strcmp(tag,'Pop_NOI_Struct');
        set(uic(idx),'String',{...
            getWavMSG('Wavelet:commongui:Str_SWNoise'); ...
            getWavMSG('Wavelet:commongui:Str_UWNoise'); ...
            getWavMSG('Wavelet:commongui:Str_NWNoise') ...
            }); 
        idx = strcmp(tag,'Pop_THR_METH');
        set(uic(idx),'String',{...
            getWavMSG('Wavelet:moreMSGRF:Fixed_form'); ...
            getWavMSG('Wavelet:moreMSGRF:Rig_SURE'); ...
            getWavMSG('Wavelet:moreMSGRF:Heur_SURE'); ...
            getWavMSG('Wavelet:moreMSGRF:Minimax'); ...
            '-------------------------------'; ...
            getWavMSG('Wavelet:moreMSGRF:Penal_high'); ...
            getWavMSG('Wavelet:moreMSGRF:Penal_medium'); ...
            getWavMSG('Wavelet:moreMSGRF:Penal_low'); ...
            getWavMSG('Wavelet:LastMessages:Penalize') ...
            });         
        idx = strcmp(tag,'Txt_MAN_LEV');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_LEV')); 
        idx = strcmp(tag,'Pus_MAN_Valid');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_MAN_Valid')); 
        idx = strcmp(tag,'Txt_MAN_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_SEL')); 
        idx = strcmp(tag,'Txt_MAN_THR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MAN_THR')); 
        idx = strcmp(tag,'Rad_NO');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_NO')); 
        idx = strcmp(tag,'Rad_YES');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_YES')); 
        idx = strcmp(tag,'Txt_APP_KEEP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_APP_KEEP'));
        idx = strcmp(tag,'Pus_Compute_RESET');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Compute_RESET')); 
        idx = strcmp(tag,'Pus_Compute_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Selected')); 
        idx = strcmp(tag,'Txt_Compute_THR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Compute_THR')); 
        idx = strcmp(tag,'Rad_HARD');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Hard')); 
        idx = strcmp(tag,'Rad_SOFT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Soft')); 
        idx = strcmp(tag,'Pus_Compute_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Compute_ALL')); 
        idx = strcmp(tag,'Pus_ENA_MAN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_ENA_MAN')); 
        idx = strcmp(tag,'Txt_PAR_METH');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_NoiStruc')); 
        idx = strcmp(tag,'Txt_THR_METH');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_SelThrMet')); 
        idx = strcmp(tag,'Pus_Denoise');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Denoise')); 
        idx = strcmp(tag,'Txt_THR_TYPE');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_THR_TYPE'));
        idx = strcmp(tagPAN,'Pan_Denoise');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Str_Thresholding')));
        idx = strcmp(tagPAN,'Pan_MAN_THR');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_MAN')));
        
    case 'mdw1dstat'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D_Stat'))
        idx = strcmp(tag,'Fra_SEL_DATA');
        set(uic(idx), ...
            'TooltipString',getWavMSG('Wavelet:mdw1dRF:Tip_Edi_TIT_SEL')  ...          
            );        
        idx = strcmp(tagPAN,'Pan_VISU_STATS');
        set(pan(idx),'Title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_STA')));
        idx = strcmp(tag,'Pus_Statistics');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Statistics')); 
        idx = strcmp(tag,'Txt_TOOL_VIEW');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_TOOL_VIEW')); 
        idx = strcmp(tag,'Txt_SORT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sort')); 
        idx = strcmp(tag,'Txt_VAL_max');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Max'));
        idx = strcmp(tag,'Txt_VAL_mean');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mean_txt'));
        idx = strcmp(tag,'Txt_VAL_min');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Min'));
        idx = strcmp(tag,'Txt_VAL_abs_mean_dev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_madm_txt'));
        idx = strcmp(tag,'Txt_VAL_abs_med_dev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mad_txt'));
        idx = strcmp(tag,'Txt_VAL_med');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_med_txt'));
        idx = strcmp(tag,'Txt_VAL_range');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_range_txt'));
        idx = strcmp(tag,'Txt_VAL_std');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Std'));        
        idx = strcmp(tagPAN,'Pan_STA_VAL');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_STA_VAL')));
          
    case 'wmspcatool'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_WMSPCA'))
        idx = strcmp(tag,'Pus_More_ADAP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_More_ADAP'));
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:WMSPCA_Pus_Decompose'));
        idx = strcmp(tag,'Txt_CFS_LEV');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:WMSPCA_Txt_CFS_LEV'));
        idx = strcmp(tag,'Rad_CFS_SIM');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_SIM'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_SIM_Tip'));
        idx = strcmp(tag,'Rad_CFS_ORI');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_ORI'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_ORI_Tip'));
        idx = strcmp(tag,'Chk_Show_SIM');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_Show_SIM'));        
        idx = strcmp(tag,'Pus_Residuals');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Residuals'));
        idx = strcmp(tag,'Pus_Apply');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Apply'));
        idx = strcmp(tag,'Txt_DEF_NPC');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_DEF_NPC'));
        idx = strcmp(tag,'Txt_PCA_Par');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_PCA_Par'));                
        idx = strcmp(tagPAN,'Pan_SIM_PARAM');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Txt_PCA_Par')));                       
        idx = strcmp(tag,'Txt_APP_NPC');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_APP_NPC'));
        idx = strcmp(tag,'Pus_More_PCA');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA'));
        idx = strcmp(tag,'Txt_Nb_FIN_PC');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_Nb_FIN_PC'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Nb_FIN_PC_Tip'));
        idx = strcmp(tag,'Txt_Nb_DEC_PC');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_Nb_DEC_PC'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Nb_DEC_PC_Tip'));
        idx = strcmp(tag,'Pop_Lev');
        set(uic(idx),'ToolTipString', ...
            getWavMSG('Wavelet:commongui:Str_LevOfDec'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Txt_Ext_Mode');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_DWT_Ext_Mode'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode_Tip'));
        idx = strcmp(tag,'Pop_Ext_Mode');                
        set(uic(idx), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode_Tip'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),...
            'String',getWavMSG('Wavelet:commongui:Str_Level'),...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_LevOfDec'));        
        idx = strcmp(tag,'Pus_Close_RES');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Close_RES'));
        idx = strcmp(tag,'Txt_SIG_NUM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sig'));
        idx = strcmp(tag,'Txt_MAX');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Max'));
        idx = strcmp(tag,'Txt_MEAN');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mean_txt'));
        idx = strcmp(tag,'Txt_MIN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Min'));
        idx = strcmp(tag,'Txt_MEAN_DEV');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_madm_txt'));
        idx = strcmp(tag,'Txt_MED_DEV');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mad_txt'));
        idx = strcmp(tag,'Txt_MODE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mode_txt'));
        idx = strcmp(tag,'Txt_MED');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_med_txt'));
        idx = strcmp(tag,'Txt_RANGE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_range_txt'));
        idx = strcmp(tag,'Txt_STD');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_STD_txt'));
        
    case 'wmuldentool'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Nam_WMULDEN'))
        idx = strcmp(tag,'Pus_Residuals');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Residuals'));
        idx = strcmp(tag,'Pus_Denoise');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Denoise'));
        idx = strcmp(tag,'Txt_CFS_LEV');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:WMSPCA_Txt_CFS_LEV'));
        idx = strcmp(tag,'Rad_CFS_DEN');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_DEN'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_DEN_Tip'));
        idx = strcmp(tag,'Rad_CFS_ORI');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_ORI'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Rad_CFS_ORI_Tip'));
        idx = strcmp(tag,'Pus_More_ADAP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_More_Nois_ADAP'));
        idx = strcmp(tag,'Rad_BASE_ADAP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_BASE_ADAP'));
        idx = strcmp(tag,'Rad_BASE_ORI');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_BASE_ORI'));
        idx = strcmp(tag,'Chk_Show_DEN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_Show_DEN'));
        idx = strcmp(tag,'Chk_Show_DEN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_Show_DEN'));
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:WMUL_Decompose'));
        idx = strcmp(tag,'Pop_THR_Meth');
        set(uic(idx),'String',{...
            getWavMSG('Wavelet:moreMSGRF:Fixed_form'); ...
            getWavMSG('Wavelet:moreMSGRF:Rig_SURE'); ...
            getWavMSG('Wavelet:moreMSGRF:Heur_SURE'); ...
            getWavMSG('Wavelet:moreMSGRF:Minimax'); ...
            getWavMSG('Wavelet:moreMSGRF:Penal_high'); ...
            getWavMSG('Wavelet:moreMSGRF:Penal_medium'); ...
            getWavMSG('Wavelet:moreMSGRF:Penal_low') ...
            });         
        idx = strcmp(tag,'Chk_PCA');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Chk_PCA'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Chk_PCA_Tip'));
        idx = strcmp(tag,'Rad_HARD');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Hard'));
        idx = strcmp(tag,'Rad_SOFT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Soft'));
        idx = strcmp(tag,'Txt_THR_Meth');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_SelThr'));
        idx = strcmp(tag,'Pop_Lev');
        set(uic(idx),'ToolTipString', ...
            getWavMSG('Wavelet:commongui:Str_LevOfDec'));
        idx = strcmp(tag,'Txt_Ext_Mode');        
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_DWT_Ext_Mode'),...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode_Tip'));
        idx = strcmp(tag,'Pop_Ext_Mode');                
        set(uic(idx), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode_Tip'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),...
            'String',getWavMSG('Wavelet:commongui:Str_Level'),...
            'ToolTipString',getWavMSG('Wavelet:commongui:Str_LevOfDec'));
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Pus_Close_RES');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_Close_RES'));
        idx = strcmp(tag,'Txt_MIN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Min'));
        idx = strcmp(tag,'Txt_MEAN_DEV');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_madm_txt'));
        idx = strcmp(tag,'Txt_MED_DEV');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mad_txt'));
        idx = strcmp(tag,'Txt_MODE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mode_txt'));
        idx = strcmp(tag,'Txt_MED');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_med_txt'));
        idx = strcmp(tag,'Txt_RANGE');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_range_txt'));
        idx = strcmp(tag,'Txt_STD');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_STD_txt'));
        idx = strcmp(tag,'Txt_MAX');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Max'));
        idx = strcmp(tag,'Txt_MEAN');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_mean_txt'));
        idx = strcmp(tag,'Txt_SIG_NUM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sig'));
        idx = strcmp(tag,'Txt_NPC_FIN');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Nb_PC_FinalPCA'), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Nb_PC_FinalPCA_Tip'));
        idx = strcmp(tag,'Txt_NPC_APP');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_NPC_APP'), ...
            'ToolTipString',getWavMSG('Wavelet:mdw1dRF:Txt_NPC_APP_Tip'));
        idx = strcmp(tag,'Pus_More_PCA');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA'));       
        idx = strcmp(tagPAN,'Pan_BASE_ADAP');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Rad_BASE_ADAP')));
        idx = strcmp(tagPAN,'Pan_RESIDUALS');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:commongui:Str_Residuals')));
        idx = strcmp(tagPAN,'Pan_BASE_ORI');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Rad_BASE_ORI')));
        idx = strcmp(tagPAN,'Pan_RES_STATS');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:commongui:Str_Residuals')));
        idx = strcmp(tagPAN,'Pan_DEN_PARAM');
        set(pan(idx),'title',...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Txt_Den_Par')));
      
    case 'wc2dtool'
        set(hObject,'Name',getWavMSG('Wavelet:divGUIRF:WC2D_Name'))
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Level'));
        idx = strcmp(tag,'Txt_Data_NS');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Image'));        
        idx = strcmp(tag,'Txt_L2_Rat');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_L2_Rat'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_L2_Rat'));
        idx = strcmp(tag,'Txt_psnr');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_psnr'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_psnr'));
        idx = strcmp(tag,'Txt_Fil_Rat');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_Fil_Rat'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_Fil_Rat'));
        idx = strcmp(tag,'Txt_Bit_Pix');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_Bit_Pix'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_Bit_Pix'));
        idx = strcmp(tag,'Txt_maxerr');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_maxerr'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_maxerr'));
        idx = strcmp(tag,'Txt_mse');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_mse'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_mse'));
        idx = strcmp(tag,'Edi_mse');
        set(uic(idx), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_mse'));
        idx = strcmp(tag,'Txt_Nb_Cfs');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_Nb_Cfs'),...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_Nb_Cfs'));
        idx = strcmp(tag,'Edi_Nb_Cfs');
        set(uic(idx), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_Nb_Cfs'));
        idx = strcmp(tag,'Txt_CC');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_CC'));
        idx = strcmp(tag,'Tog_Inspect');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Tog_Inspect'));
        idx = strcmp(tag,'Pus_Decompose');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Decompose'));
        Pan_CMP_PAR = wfindobj(hObject,'type','uipanel','Tag','Pan_CMP_PAR');
        set(Pan_CMP_PAR,'Title',getWavMSG('Wavelet:divGUIRF:WTC_CMP_Par'));
        idx = strcmp(tag,'Pus_Compress');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Compress'));
        idx = strcmp(tag,'Txt_Nb_LOOP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Nb_LOOP'));
        idx = strcmp(tag,'Txt_METHOD');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_METHOD'));
        idx = strcmp(tag,'Txt_Nb_Symb');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Nb_Symb'));
        idx = strcmp(tag,'Txt_Kept_Cfs');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:divGUIRF:Txt_Kept_Cfs'), ...
            'ToolTipString',getWavMSG('Wavelet:divGUIRF:Tip_Txt_Kept_Cfs'));
        idx = strcmp(tag,'Txt_Nb_Symb');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Nb_Symb'));
        idx = strcmp(tag,'Txt_Nb_Symb');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_Nb_Symb'));
        idx = strcmp(tag,'Txt_Thr');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Threshold'));
        idx = strcmp(tag,'Txt_CompRat');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_CompRat'));
        idx = strcmp(tag,'Txt_BPP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Txt_BPP'));
        idx = strcmp(tag,'Pus_END_STP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Pus_END_STP'));
        idx = strcmp(tag,'Pus_NEXT_STP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Str_Next'));
        idx = strcmp(tag,'Chk_StepOnOff');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_StepOnOff'));
        idx = strcmp(tag,'Chk_ALG_STP');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Chk_ALG_STP'));
        idx = strcmp(tag,'Txt_Nod_Act');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:NodAct'));
        idx = strcmp(tag,'Txt_Nod_Lab');
        set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:NodLab'));
        idx = strcmp(tag,'Pop_Nod_Act');
        set(uic(idx),'String',{ ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodAct_1'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodAct_2')  ...
            });
        idx = strcmp(tag,'Pop_Nod_Lab');
        set(uic(idx),'String',{...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_1'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_2'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_3'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_4'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_5'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_6'), ...
            getWavMSG('Wavelet:divGUIRF:WTC_nodLab_7')  ...
            });
end
switch callingTool
    case {'mdw1dtool','mdw1dclus','mdw1dcomp','mdw1ddeno','mdw1dstat'}
        idx = strcmp(tag,'Txt_Wav');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Wavelet'));
        idx = strcmp(tagPAN,'Pan_VISU_SIG');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VISU')));
        idx = strcmp(tagPAN,'Pan_Selected_DATA');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_SEL')));
        idx = strcmp(tag,'Txt_HIG_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_SIG')); 
        idx = strcmp(tag,'Txt_HIG_DEC');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_SIG')); 
        idx = strcmp(tag,'Chk_AFF_MUL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_AFF_MUL'));
        idx = strcmp(tag,'Pus_IMPORT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_IMPORT')); 
        idx = strcmp(tag,'Txt_Lev');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:commongui:Str_Level'), ...
            'TooltipString',getWavMSG('Wavelet:commongui:Str_LevOfDec') ...
            );            
        idx = strcmp(tagPAN,'Pan_VISU_DEC');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VISU_DEC')));
        idx = strcmp(tag,'Chk_DEC_GRID');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_DEC_GRID')); 
        idx = strcmp(tag,'Txt_LST_CFS');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Coefficients')); 
        idx = strcmp(tag,'Txt_LST_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Signals')); 
        idx = strcmp(tag,'Txt_SELECTED');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_SELECTED')); 
        idx = strcmp(tag,'Txt_Ext_Mode');
        set(uic(idx), ...
            'String',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode'), ...
            'TooltipString',getWavMSG('Wavelet:mdw1dRF:Txt_Ext_Mode_Tip')  ...            
            ); 
        idx = strcmp(tag,'Txt_DIR');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_DIR'));
        idx = strcmp(tag,'Pus_AFF_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_ALL')); 
        idx = strcmp(tag,'Pus_AFF_NON');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_NON')); 
        idx = strcmp(tag,'Txt_SORT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sort')); 
        idx = strcmp(tag,'Pus_SORT_Dir');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_SORT_Dir')); 
        idx = strcmp(tag,'Pus_SORT_Inv');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_SORT_Inv')); 
        idx = strcmp(tagPAN,'Pan_LST_DATA');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_LST_DATA')));

    case 'showclusters' 
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:View_Clusters_Name'))                
        idx = strcmp(tag,'Txt_PART_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Selected_OnePART')); 
        idx = strcmp(tag,'Txt_DAT_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Loaded_Data')); 
        idx = strcmp(tag,'Rad_SEE_CLU_DAT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_SEE_CLU_DAT')); 
        idx = strcmp(tag,'Rad_SEE_CLU_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_SEE_CLU_SIG')); 
        idx = strcmp(tag,'Txt_HIG_CLU');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_CLU')); 
        idx = strcmp(tag,'Pus_SIG_OnOff');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_SIG_OnOff'));
        idx = strcmp(tag,'Txt_MEAN_MED');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_MEAN_MED'));
        idx = strcmp(tag,'Pus_glb_STD');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_ON'));
        idx = strcmp(tag,'Pus_MEAN_MED');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_ON'));
        idx = strcmp(tag,'Pus_loc_STD');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_ON'));
        idx = strcmp(tag,'Txt_glb_STD');
        set(uic(idx),'String',...
            {getWavMSG('Wavelet:mdw1dRF:Txt_glb_STD_1'),...
             getWavMSG('Wavelet:mdw1dRF:Txt_glb_STD_2')});
        idx = strcmp(tag,'Txt_loc_STD');
        set(uic(idx),'String',...
            {getWavMSG('Wavelet:mdw1dRF:Txt_loc_STD_1'),...
             getWavMSG('Wavelet:mdw1dRF:Txt_loc_STD_2')});
        idx = strcmp(tagPAN,'Pan_PLOT_SELECT');
        set(pan(idx),'Title',getWavMSG('Wavelet:mdw1dRF:Pan_PLOT_SELECT')); 
        idx = strcmp(tagPAN,'Pan_ON_OFF');
        set(pan(idx),'Title',getWavMSG('Wavelet:mdw1dRF:Pan_ON_OFF'));
        
    case 'showparttool'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Partitions_tool_Name'))                
        idx = strcmp(tag,'Txt_PART_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Selected_OnePART'));
        idx = strcmp(tag,'Txt_DAT_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Loaded_Data'));
        idx = strcmp(tag,'Txt_DAT_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Loaded_Data'));
        idx = strcmp(tag,'Pus_CON_EXE');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Compute_Part'));
        idx = strcmp(tag,'Txt_CON_MTH');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Opt_Method'));
        idx = strcmp(tag,'Pus_CON_SAV');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Store_Part'));
        idx = strcmp(tag,'Pus_CON_DEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Delete_Part'));
        idx = strcmp(tag,'Txt_Nb_CON');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Nb_Part'));
        idx = strcmp(tag,'Rad_SEE_CLU_DAT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rad_SEE_CLU_DAT'));
        idx = strcmp(tag,'Pus_VAL_MOD');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Percent'));
        idx = strcmp(tag,'Txt_PSEL_VIS');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_Plot_Sel'));
        idx = strcmp(tag,'Rad_AFF_DAT');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Clustered_Data'));
        idx = strcmp(tag,'Rad_AFF_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Signals'));
        idx = strcmp(tag,'Txt_HIG_SIG');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_SIG'));
        idx = strcmp(tag,'Chk_AFF_MUL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_AFF_MUL'));
        idx = strcmp(tagPAN,'Pan_VISU_SIG');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VISU')));
        idx = strcmp(tag,'Pus_AFF_NON');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_NON'));      
        idx = strcmp(tag,'Pus_AFF_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_ALL'));
        idx = strcmp(tag,'Edi_TIT_SEL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Edi_TIT_SEL'));
        idx = strcmp(tag,'Txt_HIG_DEC');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_SIG'));
        idx = strcmp(tag,'Edi_TIT_VISU_DEC');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Edi_TIT_VISU_DEC'));
        idx = strcmp(tag,'Chk_DEC_GRID');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Chk_DEC_GRID'));
        idx = strcmp(tag,'Pus_AFF_CLU_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_AFF_CLU_PART'));
        idx = strcmp(tag,'Pus_CON_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_CON_PART'));
        idx = strcmp(tag,'Pus_CLU_SHOW');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_CLU_SHOW'));
        idx = strcmp(tag,'Pus_PART_PERF');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_PART_PERF'));
        idx = strcmp(tag,'Txt_DAT_NAM');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Data'));
        idx = strcmp(tag,'Pus_SORT_Inv');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_SORT_Inv'));
        idx = strcmp(tag,'Pus_SORT_Dir');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Pus_SORT_Dir'));
        idx = strcmp(tag,'Txt_SORT');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Sort'));
        idx = strcmp(tag,'Pus_ALL_IDX');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Show_Sim_Ind'));
        idx = strcmp(tag,'Txt_PAIR_LNK');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_PAIR_LNK'));
        idx = strcmp(tag,'Txt_NB_PAIRS');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_NB_PAIRS'));
        idx = strcmp(tag,'Txt_NP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_NP'));
        idx = strcmp(tag,'Txt_PN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_PN'));
        idx = strcmp(tag,'Txt_NN');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_NN'));
        idx = strcmp(tag,'Txt_PP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_PP'));
        idx = strcmp(tag,'Txt_Renum_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Opt_Cluster_Nb'));
        idx = strcmp(tag,'Txt_SEL_OPER');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Select'));
        idx = strcmp(tag,'Txt_SEL_1');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_SEL_1'));
        idx = strcmp(tag,'Txt_SEL_2');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_SEL_2'));
        idx = strcmp(tagPAN,'Pan_CON_PART');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_CON_PART')));
        idx = strcmp(tagPAN,'Pan_PART_SIM');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_PART_SIM')));
        idx = strcmp(tagPAN,'Pan_PART_LINKS');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_PART_LINKS')));
        idx = strcmp(tagPAN,'Pan_SEL_PART');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Pan_SEL_PART')));
        idx = strcmp(tagPAN,'Pan_Selected_DATA');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Edi_TIT_SEL')));
        
    case {'showpartsimidx','showpartperf'}
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Similarity_Ind'))                        
        idx = strcmp(tag,'Txt_FRM_DISP');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Display_format'));
        idx = strcmp(tag,'Txt_Index');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Str_Index'));
        idx = strcmp(tag,'Pus_ALL');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:ALL_IDX'));
        idx = strcmp(tag,'Pus_Close');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Close'));
        idx = strcmp(tag,'Edi_TIT_GRA_SIM');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Rand_index'));
        idx = strcmp(tag,'Txt_COL_MAP');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_PAL'));
        idx = strcmp(tag,'Txt_HIG_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Txt_HIG_PART'));
        idx = strcmp(tag,'Txt_SEL_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Select_Part'));
        idx = strcmp(tag,'Chk_GRID');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:GRID_OnOff'));
        
    case 'wtbxexport'
        idx = strcmp(tag,'Pus_CAN');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        idx = strcmp(tag,'Pus_OK');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_OK'));
        idx = strcmp(tag,'Txt_LST');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Var_On_Work'));
        idx = strcmp(tag,'text1');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:EnterVarName'));

    case 'mdw1dpartmngr'
        set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Partition_Manager'))                        
        idx = strcmp(tag,'Rad_IDX_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Array_of_Indices'));
        idx = strcmp(tag,'Rad_ALL_PART');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:Full_Partitions'));
        idx = strcmp(tag,'Txt_Select_Part');
        set(uic(idx),'String',getWavMSG('Wavelet:mdw1dRF:List_of_Parts'));
        idx = strcmp(tag,'Pus_Cancel');
        set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Cancel'));
        
    case 'wmspcatoolmopc'
        idx = strcmp(tagPAN,'Pan_APP_PCA');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Nb_PC_DetOrApp')));
        idx = strcmp(tagPAN,'Pan_FIN_PCA');
        set(pan(idx),'title', ...
            formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Nb_PC_FinalPCA')));
end

%--------------------------------------------------------------------------
function S = formatPanTitle(S)

S = sprintf(' %s  ',S);

%--------------------------------------------------------------------------
