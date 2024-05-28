function SuggestPIVsettings(~, ~, ~)
handles=gui.gui_gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=gui.gui_retr('filepath');
ok=gui.gui_checksettings;
if ok==1
	uiwait(msgbox({'Please select a rectangle';'that encloses the area that';'you want to analyze.'},'Suggestion for PIV settings','modal'));
	roi = images.roi.Rectangle;
	%roi.EdgeAlpha=0.75;
	roi.LabelVisible = 'on';
	roi.Tag = 'suggestRect';
	roi.Color = 'r';
	roi.StripeColor = 'k';
	axes(gui.gui_retr('pivlab_axis'))
	draw(roi);
	roirect=round(roi.Position);

	if numel(roirect) == 4
		%roirect(1,3)~=0 && roirect(1,4)~=0
		if roirect(3) < 50 || roirect(4)< 50
			uiwait(msgbox({'The rectangle you selected is too small.';'Please select a larger rectangle.';'(should be larger than 50 x 50 pixels)'},'Suggestion for PIV settings','modal'));
		else
			text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
			drawnow
			[A,~] = import.import_get_img(selected);
			[B,~] = import.import_get_img(selected+1);
			A=A(roirect(2):roirect(2)+roirect(4),roirect(1):roirect(1)+roirect(3));
			B=B(roirect(2):roirect(2)+roirect(4),roirect(1):roirect(1)+roirect(3));
			clahe=get(handles.clahe_enable,'value');
			highp=get(handles.enable_highpass,'value');
			intenscap=get(handles.enable_intenscap, 'value');
			clahesize=str2double(get(handles.clahe_size, 'string'))*2; % faster...
			highpsize=str2double(get(handles.highp_size, 'string'));
			wienerwurst=get(handles.wienerwurst, 'value');
			wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
			do_correlation_matrices=gui.gui_retr('do_correlation_matrices');
			roirect=gui.gui_retr('roirect');
			if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				stretcher = stretchlim(A);
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
			A = PIVlab_preproc (A,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
			if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				stretcher = stretchlim(B);
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
			B = PIVlab_preproc (B,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

			interrogationarea=round(min(size(A))/4);
			if interrogationarea > 128
				interrogationarea = 128;
			end
			step=round(interrogationarea/4);
			if step < 6
				step=6;
			end
			[x, y, u, v, typevector,~,correlation_matrices] = piv_FFTmulti (A,B,interrogationarea, step,1,[],[],1,32,16,16,'*linear',1,0,0,do_correlation_matrices,0,0);
			u=medfilt2(u);
			v=medfilt2(v);
			u=inpaint_nans(u,4);
			v=inpaint_nans(v,4);
			maxvel=max(max(sqrt(u.^2+v.^2)));
			%minimum size recommendation based on displacement
			recommended1=ceil(4*maxvel/2)*2;
			A(A<=80)=0;
			A(A>80)=255;
			B(B<=80)=0;
			B(B>80)=255;
			[spots,numA]=bwlabeln(A,8);
			[spots,numB]=bwlabeln(B,8);
			XA=((numA+numB)/2)/(size(A,1)*size(A,2));
			YA=8/XA;
			%minimum size recommendation based on particle density
			recommended2=round(sqrt(YA)/2)*2; % 8 peaks are in Z*Z area
			%minimum size recommendation based on experience with "normal PIV images"
			recommended3= 32; %relativ allgemeingÃ¼ltiger Erfahrungswert
			recommendation = median([recommended1 recommended2 recommended3]);
			%[recommended1 recommended2 recommended3]
			uiwait(msgbox({'These are the recommendations for the size of the final interrogation area:';[''];['Based on the displacements: ' num2str(recommended1) ' pixels'];['Based on the particle count: ' num2str(recommended2) ' pixels'];['Based on practical experience: ' num2str(recommended3) ' pixels'];[''];'The settings are automatically updated with the median of the recommendation.'},'Suggestion for PIV settings','modal'));
			set(handles.fftmulti,'Value', 1)
			set(handles.ensemble,'Value', 1)

			set(handles.dcc,'Value', 0)
			set (handles.intarea, 'String', recommendation*2); %two times the minimum recommendation
			set (handles.step, 'String', recommendation);
			set(handles.checkbox26,'Value',1); %pass2
			set(handles.edit50,'String',recommendation); %pass2 size
			set(handles.checkbox27, 'Value',0); %pass3
			set(handles.edit51,'String',recommendation); %pass3 size
			set(handles.checkbox28, 'Value',0); %pass4
			set(handles.edit52,'String',recommendation); %pass4 size
			%set(handles.popupmenu16,'Value',1);
			set(handles.subpix,'value',1);
			%set(handles.Repeated_box,'value',0);
			set(handles.CorrQuality,'value',1)
			set(handles.mask_auto_box,'value',0);
			piv.piv_pass2_checkbox_Callback(handles.checkbox26)
			piv.piv_pass3_checkbox_Callback(handles.checkbox27)
			piv.piv_pass4_checkbox_Callback(handles.checkbox28)
			piv.piv_pass2_size_Callback(handles.edit50)
			piv.piv_pass3_size_Callback(handles.edit51)
			piv.piv_pass4_size_Callback(handles.edit52)
			piv.piv_fftmulti_Callback(handles.fftmulti)
			piv.piv_step_Callback(handles.step)
			piv.piv_dispinterrog
			delete(findobj('tag','hint'));
		end
	end
	delete(findobj('Tag','suggestRect'));
end

