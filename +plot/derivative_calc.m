function derivative_calc (frame,deriv,update,use_smoothed)
% use_smoothed (optional): when true, the velocity is taken directly from the already
% finished smoothed field resultslist{10/11,frame} and the spatial/temporal smoothing is
% skipped. Used by the efficient batch path in apply_deriv_all_Callback so the temporal
% moving average is computed only once (see plot.temporal_smooth_all) instead of being
% recomputed for every frame.
if nargin<4 || isempty(use_smoothed)
	use_smoothed=false;
end
handles=gui.gethand;
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=frame && numel(resultslist{1,frame})>0 %analysis exists
	derived=gui.retr('derived');
	calu=gui.retr('calu');calv=gui.retr('calv');
	calxy=gui.retr('calxy');
	%[currentimage,~]=import.get_img(2*frame-1);
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	%subtrayct mean u
	subtr_u=str2double(get(handles.subtr_u, 'string'));
	if isnan(subtr_u)
		subtr_u=0;set(handles.subtr_u, 'string', '0');
	end
	subtr_v=str2double(get(handles.subtr_v, 'string'));
	if isnan(subtr_v)
		subtr_v=0;set(handles.subtr_v, 'string', '0');
	end
	if use_smoothed && size(resultslist,1)>=11 && ~isempty(resultslist{10,frame}) %batch temporal path: use the finished smoothed field, skip re-smoothing
		u=resultslist{10,frame};
		v=resultslist{11,frame};
	else
	if size(resultslist,1)>6 && numel(resultslist{7,frame})>0 %filtered exists
		u=resultslist{7,frame};
		v=resultslist{8,frame};
		typevector=resultslist{9,frame};
	else
		u=resultslist{3,frame};
		v=resultslist{4,frame};
		typevector=resultslist{5,frame};
	end
	if get(handles.interpol_missing,'value')==1
        if any(any(isnan(u))) || any(any(isnan(v)))
            if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
                drawnow;
                if gui.retr('alreadydisplayed') == 1
                else
                    gui.custom_msgbox('msg',getappdata(0,'hgui'),'NaNs','Your dataset contains NaNs. Missing vectors are interpolated for the calculation of the derived parameters (the vector data itself is not changed).','modal',{'OK'},'OK');
                end
                gui.put('alreadydisplayed',1);
            end
            typevector_original=typevector;
            u(isnan(v))=NaN;
            v(isnan(u))=NaN;
            typevector(isnan(u))=2;
			typevector(typevector_original==0)=0;
			u=misc.inpaint_nans(u,4); %only for the derived parameters: the vector data (resultslist rows 7-9) is not changed
			v=misc.inpaint_nans(v,4);

		end
	else
		if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.tecplot_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
			drawnow;
			if gui.retr('alreadydisplayed') == 1
			else
				gui.custom_msgbox('msg',getappdata(0,'hgui'),'NaNs','Your dataset contains NaNs. Derived parameters will have a lot of missing data. Redo the vector validation with the option to interpolate missing data turned on.','modal',{'OK'},'OK');
			end
			gui.put('alreadydisplayed',1);
		end
	end
	%Data smoothing: 1=None, 2=2D, 3=time (moving average), 4=2D + time.
	%Spatial (2D) smoothing is applied first, then the temporal moving average over the
	%frames. The resulting field is used for the derived quantities below and stored into
	%resultslist{10/11,frame} (the same entries as before, no extra row is created).
	smooth_mode=get(handles.smooth_mode, 'Value');
	S=str2double(get(handles.smooth_param, 'String'));
	if isnan(S) || S<=0
		S=0.2; set(handles.smooth_param, 'String', '0.2');
	end
	if smooth_mode==1 %None
		%careful if more things are added, [] replaced by {[]}
		resultslist{10,frame}=[]; %remove smoothed u
		resultslist{11,frame}=[]; %remove smoothed v
	else
		if smooth_mode==2 || smooth_mode==4 %2D or 2D + time --> spatial smoothing first
			[u,v]=plot.smooth_spatial(u,v,S,get(handles.interpol_missing,'value'));
		end
		if smooth_mode==3 || smooth_mode==4 %time or 2D + time --> temporal moving average over frames
			[u,v]=plot.temporal_smooth(resultslist,frame,u,v);
		end
		resultslist{10,frame}=u; %smoothed u (spatial and/or temporal)
		resultslist{11,frame}=v; %smoothed v
	end
	end %use_smoothed branch

	%The calculation of the derived quantities is shared with the command-line API (pivlab.derive)
	cal.calu=calu; cal.calv=calv; cal.calxy=calxy;
	cal.x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	cal.y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
	copt.subtr_u=subtr_u;
	copt.subtr_v=subtr_v;
	copt.is_tke=false;
	if deriv==3
		ismean=gui.retr('ismean');
		if ~isempty(ismean) && ismean(frame) ==1 % temporal derivative
			%total TKE is a simple sum of the x and y components, not a vector sum
			filename=gui.retr('filename');
			copt.is_tke=strncmpi(filename{frame*2-1},'TKE of frames',13);
		end
	end
	if deriv==10
		copt.lic=@(vx,vy) plot.LIC(vx,vy,frame);
	end
	if deriv==12
		copt.correlation_map=resultslist{12,frame};
	end
	if deriv==13 && size(resultslist,1)>=15
		copt.uncertainty=resultslist{15,frame};
	end
	if deriv>1
		derived{deriv-1,frame}=plot.compute_derived(x,y,u,v,deriv,cal,copt);
	end
	if deriv==13 && isempty(derived{12,frame})
		if update==1 && handles.multip10.Visible == "off" && handles.multip11.Visible == "off" && handles.multip20.Visible == "off" && gui.retr('alreadydisplayed_warning_uncertainty')==0 % not currently in export panel
			gui.custom_msgbox('msg',getappdata(0,'hgui'),'No uncertainty data',...
				['No uncertainty map found for this frame. ' ...
				'Re-analyze with ''Compute uncertainty'' enabled.'],...
				'modal',{'OK'},'OK');
			gui.put('alreadydisplayed_warning_uncertainty',1);
		end
	end

	gui.put('subtr_u', subtr_u);
	gui.put('subtr_v', subtr_v);
	gui.put('resultslist', resultslist);
	gui.put ('derived',derived);
	if update==1
		gui.put('displaywhat', deriv);
	end
end

