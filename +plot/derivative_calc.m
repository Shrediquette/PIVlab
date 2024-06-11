function derivative_calc (frame,deriv,update)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=frame && numel(resultslist{1,frame})>0 %analysis exists
	filenames=gui.retr('filenames');
	filepath=gui.retr('filepath');
	derived=gui.retr('derived');
	calu=gui.retr('calu');calv=gui.retr('calv');
	calxy=gui.retr('calxy');
	[currentimage,~]=import.get_img(2*frame-1);
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
					msgbox('Your dataset contains NaNs. A vector interpolation will be performed automatically to interpolate missing vectors.', 'modal')
					uiwait
				end
				gui.put('alreadydisplayed',1);
			end
			typevector_original=typevector;
			u(isnan(v))=NaN;
			v(isnan(u))=NaN;
			typevector(isnan(u))=2;
			typevector(typevector_original==0)=0;
			u=inpaint_nans(u,4);
			v=inpaint_nans(v,4);
			resultslist{7, frame} = u;
			resultslist{8, frame} = v;
			resultslist{9, frame} = typevector;

		end
	else
		if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.tecplot_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
			drawnow;
			if gui.retr('alreadydisplayed') == 1
			else
				msgbox('Your dataset contains NaNs. Derived parameters will have a lot of missing data. Redo the vector validation with the option to interpolate missing data turned on.', 'modal')
				uiwait
			end
			gui.put('alreadydisplayed',1);
		end
	end
	if get(handles.smooth, 'Value') == 1
		smoothfactor=floor(get(handles.smoothstr, 'Value'));
		try

			u = smoothn(u,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
			v = smoothn(v,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
			%clc
			%disp ('Using smoothn.m from Damien Garcia for data smoothing.')
			%disp (['Input smoothing parameter S for smoothn is: ' num2str(smoothfactor/10)])
			%disp ('see the documentation here: https://de.mathworks.com/matlabcentral/fileexchange/25634-smoothn')

		catch
			h=fspecial('gaussian',smoothfactor+2,(smoothfactor+2)/7);
			u=imfilter(u,h,'replicate');
			v=imfilter(v,h,'replicate');
			%clc
			%disp ('Using Gaussian kernel for data smoothing (your Matlab version is pretty old btw...).')
		end
		resultslist{10,frame}=u; %smoothed u
		resultslist{11,frame}=v; %smoothed v
	else
		%careful if more things are added, [] replaced by {[]}
		resultslist{10,frame}=[]; %remove smoothed u
		resultslist{11,frame}=[]; %remove smoothed v
	end

	%The direction of the coordinate system influences derivatives with gradients.
	x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top

	if x_axis_direction==1
		x_adjusted=x;
	else
		x_adjusted=fliplr(x);
	end

	if y_axis_direction==1
		y_adjusted=y;
	else
		y_adjusted=flipud(y);
	end


	if deriv==1 %vectors only
		%do nothing
		%disp('vectors')
	end
	if deriv==2 %vorticity
		[curlz,~]= curl(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		derived{1,frame}=-curlz;
		%disp('vorticity')
	end
	if deriv==3 %magnitude
		%andersrum, (u*caluv)-subtr_u
		derived{2,frame}=sqrt((u*calu-subtr_u).^2+(v*calv-subtr_v).^2);
		%disp('magnitude')
	end
	if deriv==4
		derived{3,frame}=u*calu-subtr_u;
		%disp('u')
	end
	if deriv==5
		derived{4,frame}=v*calv-subtr_v;
		%disp('v')
	end
	if deriv==6
		derived{5,frame}=divergence(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('divergence')
	end
	if deriv==7
		derived{6,frame}=plot.dcev(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('dcev')
	end
	if deriv==8
		derived{7,frame}=plot.shear(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('shear')
	end
	if deriv==9
		derived{8,frame}=plot.strain(x_adjusted*calxy,y_adjusted*calxy,u*calu,v*calv);
		%disp('strain')
	end
	if deriv==10
		%{
        A=rescale_maps(LIC(v*caluv-subtr_v,u*caluv-subtr_u,frame),0);
        [curlz,cav]= curl(x*calxy,y*calxy,u*caluv,v*caluv);
        B= rescale_maps(curlz,0);
        
        C=B-min(min(B));
        C=C/max(max(C));
        RGB_B = ind2rgb(uint8(C*255),colormap('jet'));
        RGB_A = ind2rgb(uint8(A*255),colormap('gray'));
		%}
		%EDITED for williams visualization
		%Original:
		derived{9,frame}=plot.LIC(v*calv-subtr_v,u*calu-subtr_u,frame);
		%disp('LIC')
	end
	if deriv==11
		try
			derived{10,frame}=atan2d(v*calv-subtr_v,u*calu-subtr_u);
		catch
			derived{10,frame}=v*0;
			beep;
			disp('This operation is not supported in your Matlab version. Sorry...');
		end
		%disp('angle')

	end
	if deriv==12
		derived{11,frame}=resultslist{12,frame}; % correlation map
		%disp('corrmap')
	end

	gui.put('subtr_u', subtr_u);
	gui.put('subtr_v', subtr_v);
	gui.put('resultslist', resultslist);
	gui.put ('derived',derived);
	if update==1
		gui.put('displaywhat', deriv);
	end
end

