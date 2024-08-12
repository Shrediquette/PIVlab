function varargout = cf1dselc(x,y,axe,in4)
%CF1DSELC Callbacks coefficients 1-D selection box.
%   VARARGOUT = CF1DSELC(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 12-Apr-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% in4 = [coefs_axes , -level_anal]
%----------------------------------
varargout   = {[],[]};
coefs_axes  = in4(1:end-1);
axe_coefs_O = coefs_axes(1);
axe_coefs_M = coefs_axes(2);
fig         = get(axe_coefs_O,'Parent');
identMeth    = utnbcfs('get',fig,'identMeth');
if ~isequal(identMeth,'Manual'), return, end
if ~isequal(axe,axe_coefs_O) && ~isequal(axe,axe_coefs_M), return, end

level_anal = in4(end);
abslevel   = abs(level_anal);
z          = round(y);
if     (z<1) || (z>abslevel+1) , val = 0; 
elseif (z<=abslevel)          , val = 1; % Detail
else                            val = 2; % Approximation
end
if val<1, return; end
[H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy,...
 H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy] = ...
     cf1dtool('get_Stems_HDL',fig,'allComponents'); %#ok<*ASGLU>

if find(axe==axe_coefs_O)
     xy_stem = get(H_stem_O(z),{'XData','YData'});
     tol = abs(xy_stem{1}(end)-xy_stem{1}(1))/(4*length(xy_stem{1}));
     [ecart,Idx] = min(abs(xy_stem{1}-x));
     if isnan(ecart) ||  ecart>tol , return; end

     % Test for many points
     ii = find(abs(xy_stem{1}-x)==ecart);
     if length(ii)>1
         [dummy,jj] = min(abs(xy_stem{2}(ii)-y));
         Idx = ii(jj);
     end

     xy_stem_Copy = get(H_stem_O_Copy(z),{'XData','YData'});
     [ecart,Ind] = min(abs(xy_stem_Copy{2}-xy_stem{2}(Idx)));
     xy_vert_Copy = get(H_vert_O_Copy(z),{'XData','YData'});
     tol = eps;
     if ~isnan(ecart) && ecart<tol
        xy_stem_Copy{1}(Ind) = [];
        xy_stem_Copy{2}(Ind) = [];
        Ind = 3*Ind-4;
        xy_vert_Copy{1}((Ind:Ind+2)) = [];
        xy_vert_Copy{2}((Ind:Ind+2)) = [];
        
        % Update kept coefs.
        %-------------------                                    
        nbKept = utnbcfs('get',fig,'nbKept');
        if z == abslevel+1
           nbKept(1) = nbKept(1) - 1;
        else
           nbKept(abslevel+2-z) = nbKept(abslevel+2-z) - 1;
        end
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);
        
     else
        xy_stem_Copy{1} = [xy_stem_Copy{1} , xy_stem{1}(Idx)];
        xy_stem_Copy{2} = [xy_stem_Copy{2} , xy_stem{2}(Idx)];
        xy_vert_Copy{1} = [xy_vert_Copy{1} , ...
                           xy_stem{1}(Idx) , xy_stem{1}(Idx) , xy_stem{1}(Idx)];
        xy_vert_Copy{2} = [xy_vert_Copy{2} , ...
                                        z  , xy_stem{2}(Idx) ,             NaN];

        % Update kept coefs.
        %-------------------                                    
        nbKept = utnbcfs('get',fig,'nbKept');
        if z == abslevel+1
           nbKept(1) = nbKept(1) + 1;
        else
           nbKept(abslevel+2-z) = nbKept(abslevel+2-z) + 1;
        end
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);
     end

elseif find(axe==axe_coefs_M)
     % xy_stem = get(H_stem_M(z),{'XData','YData'});
     xy_stem = get(H_stem_M_Copy(z),{'XData','YData'});
     tol = abs(xy_stem{1}(end)-xy_stem{1}(1))/(4*length(xy_stem{1}));

     if isequal(tol,0)
         dummy = get(H_stem_O(z),'XData');
         tol = abs(dummy(end)-dummy(1))/(4*length(dummy));
         tol = max(tol,sqrt(eps));
     end
     [ecart,Idx] = min(abs(xy_stem{1}-x));
     if isnan(ecart) ||  ecart>tol , return; end

     % Test for many points
     ii = find(abs(xy_stem{1}-x)==ecart);
     if length(ii)>1
         [dummy,jj] = min(abs(xy_stem{2}(ii)-y));
         Idx = ii(jj);
     end

     xy_stem_Copy = get(H_stem_M_Copy(z),{'XData','YData'});
     [ecart,Ind]  = min(abs(xy_stem_Copy{2}-xy_stem{2}(Idx)));
     xy_vert_Copy = get(H_vert_M_Copy(z),{'XData','YData'});
     tol = eps;
     if ~isnan(ecart) && ecart<tol
        xy_stem_Copy{1}(Ind) = [];
        xy_stem_Copy{2}(Ind) = [];
        Ind = 3*Ind-4;
        xy_vert_Copy{1}((Ind:Ind+2)) = [];
        xy_vert_Copy{2}((Ind:Ind+2)) = [];
        
        % Update kept coefs.
        %-------------------                                    
        nbKept = utnbcfs('get',fig,'nbKept');
        if z == abslevel+1
           nbKept(1) = nbKept(1) - 1;
        else
           nbKept(abslevel+2-z) = nbKept(abslevel+2-z) - 1;
        end
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);
     end                 
else
     return
end
set([H_stem_O_Copy(z),H_stem_M_Copy(z)],...
    'XData',xy_stem_Copy{1},...
    'YData',xy_stem_Copy{2} ...
    );
set([H_vert_O_Copy(z),H_vert_M_Copy(z)],...
    'XData',xy_vert_Copy{1},...
    'YData',xy_vert_Copy{2} ...
    );
