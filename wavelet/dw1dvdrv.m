function varargout = dw1dvdrv(option,win_dw1dtool,in3,in4)
%DW1DVDRV Discrete wavelet 1-D view mode driver.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

%--------------------
% option :
%  'default'
%  'plot_sig'
%  'plot_cfs'
%  'plot_anal'
%  'plot_synt'
%  'get_imgcfs
%  'test_mode'
%--------------------

%--------------------------------------
% mode 1 : scroll mode        = 'scr'
% mode 2 : decomposition mode = 'dec'
% mode 3 : separate mode      = 'sep'
% mode 4 : superimposed mode  = 'sup'
% mode 5 : tree mode          = 'tre'
% mode 6 : cfs mode           = 'cfs'
%--------------------------------------

% Tag property of objects.
%-------------------------
tag_pop_viewm = 'View_Mode';
tag_Def_DispM = 'Default_DispM';
tag_img_cfs   = 'Img_Cfs';
tag_img_sep   = 'Img_Sep';
tag_axecfsCfs = 'Axe_CfsCfs';
tag_stem      = 'Stems';

if strcmp(option,'default')
    % in3 = tab menu
    % in4 = num menu
    %----------------
    set(in3,'Checked','Off','Tag','');
    set(in3(in4),'Checked','On','Tag',tag_Def_DispM);
    return;
end

men = findobj(win_dw1dtool,'Type','uimenu','Tag',tag_Def_DispM);
DW1D_Display_Mode = get(men,'UserData');
if isempty(DW1D_Display_Mode) , DW1D_Display_Mode = 1; end
pop_viewm = findobj(get(win_dw1dtool,'Children'),'flat','Tag',tag_pop_viewm);

switch option
   case 'plot_sig'
       % in3 = Signal Anal
       % in4 = view_sig (optional)
       %--------------------------
       vsig = (nargin==3) | (DW1D_Display_Mode==1);
       dw1dscrm('plot_sig',win_dw1dtool,in3,DW1D_Display_Mode,vsig);

   case 'plot_cfs'
       dw1dscrm('plot_cfs',win_dw1dtool,DW1D_Display_Mode);

   case 'plot_anal'
       if DW1D_Display_Mode==1
           dw1dscrm('plot_anal',win_dw1dtool);
       else
           set(pop_viewm,'Value',DW1D_Display_Mode);
           dw1dvmod('ch_vm',win_dw1dtool,1);
       end

   case 'plot_synt'
       if DW1D_Display_Mode==1
           dw1dscrm('plot_synt',win_dw1dtool);
       else
           set(pop_viewm,'Value',DW1D_Display_Mode);
           dw1dvmod('ch_vm',win_dw1dtool,1);
       end

   case 'get_imgcfs'
        view_m_orig  = get(pop_viewm,'Value');
        switch view_m_orig
          case {1,4}
            varargout = {'image' , findobj(win_dw1dtool,'Tag',tag_img_cfs)};
          case {2,5}
            varargout = {'image' , []};
          case 3
            varargout = {'image' , findobj(win_dw1dtool,'Tag',tag_img_sep)};
          case 6
            hdl = get(findobj(win_dw1dtool,'Tag',tag_axecfsCfs),'Children');
            varargout = {'stem' , findobj(hdl,'Tag',tag_stem)};
          otherwise
            varargout = {'image' , []};
        end

   case 'test_mode'
       % in3 = 'actual mode'.
       % in4 = test value:
       %   old_mode or 0 (clean).
       %-------------------------
       switch in3
         case {1,'1','scr'}
             if find(in4==[0 2 3 5 6]) , varargout{1} = 1;
             elseif in4==4 , varargout{1} = 2;
             else varargout{1} = 0;
             end

         case {2,'2','dec'} ,  varargout{1} = any(in4==[0 1 3 4 5 6]);

         case {3,'3','sep'} ,  varargout{1} = any(in4==[0 1 2 4 5 6]);

         case {4,'4','sup'}
             if find(in4==[0 2 3 5 6]) , varargout{1} = 1;
             elseif in4==1 , varargout{1} = 2;
             else varargout{1} = 0;
             end

         case {5,'5','tre'} ,  varargout{1} = any(in4==[0 1 2 3 4 6]);

         case {6,'6','cfs'} ,  varargout{1} = any(in4==[0 1 2 3 4 5]);
       end
end
