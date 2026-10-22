function histdraw_Callback(~, ~, ~)
% Histogram of the current frame (Statistics panel). Stereo-PIV: "velocity magnitude" is the 3D
% magnitude, item 5 "w velocity" is the out-of-plane component, and "sub-pixels" uses the 2D result
% of the camera that is shown (peak locking happens in the 2D analysis of each camera).
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	x=resultslist{1,currentframe};
	y=resultslist{2,currentframe};
	typevector=resultslist{5,currentframe};
	smoothed=false;
	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
			u=resultslist{10,currentframe};
			v=resultslist{11,currentframe};
			typevector=resultslist{9,currentframe}; %von smoothed
			smoothed=true;
		else
			u=resultslist{7,currentframe};
			if size(u,1)>1
				v=resultslist{8,currentframe};
				typevector=resultslist{9,currentframe}; %von smoothed
			else
				u=resultslist{3,currentframe};
				v=resultslist{4,currentframe};
				typevector=resultslist{5,currentframe};
			end
		end
	else
		u=resultslist{3,currentframe};
		v=resultslist{4,currentframe};
	end
	ismean=gui.retr('ismean');
	if    numel(ismean)>=currentframe %ismean can be shorter than the frame list
		if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
			typevector=resultslist{5,currentframe};
		end
	end
	w=stereo.w_of_frame(currentframe,smoothed); %stereo-PIV, [] in 2D

	u(typevector==0)=nan;
	v(typevector==0)=nan;
	if ~isempty(w)
		w(typevector==0)=nan;
	end

	calu=gui.retr('calu');calv=gui.retr('calv');
	calxy=gui.retr('calxy');
	x=reshape(x,size(x,1)*size(x,2),1);
	y=reshape(y,size(y,1)*size(y,2),1);
	u=reshape(u,size(u,1)*size(u,2),1);
	v=reshape(v,size(v,1)*size(v,2),1);
	w=reshape(w,numel(w),1);
	choice_plot=get(handles.hist_select,'value');
	current=get(handles.hist_select,'string');
	current=current{choice_plot};
	if choice_plot==4 && ~isempty(w) %stereo-PIV: sub-pixels of the 2D result of the shown camera
		[u,v]=camera_displacements(currentframe);
		if isempty(u)
			gui.custom_msgbox('msg',getappdata(0,'hgui'),'Sub-pixel histogram',...
				['The sub-pixel histogram uses the 2D result of the camera that is shown. ' ...
				'This frame has no 2D result of the camera (for example a mean frame).'],...
				'modal',{'OK'},'OK');
			return
		end
		current=[current ' camera ' int2str(gui.retr('stereo_active_camera'))];
	end
	h=figure;
	screensize=get( 0, 'ScreenSize' );
	rect = [screensize(3)/4-300, screensize(4)/2-250, 600, 500];
	set(h,'position', rect);
	set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Histogram ' current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
	nrofbins=str2double(get(handles.nrofbins, 'string'));
	if choice_plot==1
		[n, xout]=hist(u*calu-gui.retr('subtr_u'),nrofbins); %#ok<*HIST>
		xdescript='velocity (u)';
	elseif choice_plot==2
		[n, xout]=hist(v*calv-gui.retr('subtr_v'),nrofbins);
		xdescript='velocity (v)';
	elseif choice_plot==3
		if isempty(w)
			[n, xout]=hist(sqrt((u*calu-gui.retr('subtr_u')).^2+(v*calv-gui.retr('subtr_v')).^2),nrofbins);
			xdescript='velocity magnitude';
		else %stereo-PIV: 3D magnitude, like 'Magnitude' in the derived parameters
			[n, xout]=hist(sqrt((u*calu-gui.retr('subtr_u')).^2+(v*calv-gui.retr('subtr_v')).^2+(w*abs(calu)).^2),nrofbins);
			xdescript='velocity magnitude (3D)';
		end
	elseif choice_plot==4 %sub-pixels
		number=[u;v];
		frac = mod(abs(number),1);
		[n, xout]=hist(frac,nrofbins);
		xdescript='sub-pixel';
	elseif choice_plot==5 %stereo-PIV: w
		[n, xout]=hist(w*abs(calu),nrofbins); %|calu|: an axis flip of x or y does not flip w
		xdescript='velocity (w)';
	end
	axh=axes(h);
	h2=bar(axh,xout,n);
	set (axh, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
	if choice_plot==4 %sub-pixel part of the displacement in the image: always pixels
		xlabel([xdescript ' [px]']);
	elseif (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
		xlabel([xdescript ' [px/frame]']);
	else %calibrated
		displacement_only=gui.retr('displacement_only');
		if ~isempty(displacement_only) && displacement_only == 1
			xlabel([xdescript ' [m/frame]']);
		else
			xlabel([xdescript ' [m/s]']);
		end
	end
	ylabel('frequency');
end
end

function [u,v]=camera_displacements(frame)
%Displacements of the 2D result of the shown camera (validated if validated), [] if there is none.
u=[]; v=[];
R=gui.retr('stereo_result');
if isempty(R) || size(R,2)<frame || isempty(R{1,frame})
	return
end
if size(R,1)>8 && numel(R{7,frame})>1 %validated
	u=R{7,frame}; v=R{8,frame}; typevector=R{9,frame};
else
	u=R{3,frame}; v=R{4,frame}; typevector=R{5,frame};
end
u(typevector==0)=nan;
v(typevector==0)=nan;
u=u(:); v=v(:);
end
