function SuggestPIVsettings(~, ~, ~)
handles=gui.gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=gui.retr('filepath');
ok=gui.checksettings;
if ok==1
	uiwait(msgbox({'Please select a rectangle';'that encloses the area that';'you want to analyze.'},'Suggestion for PIV settings','modal'));
	regionOfInterest = images.roi.Rectangle;
	%regionOfInterest.EdgeAlpha=0.75;
	regionOfInterest.LabelVisible = 'on';
	regionOfInterest.Tag = 'suggestRect';
	regionOfInterest.Color = 'r';
	regionOfInterest.StripeColor = 'k';
	axes(gui.retr('pivlab_axis'))
	if get (handles.algorithm_selection,'Value')==4 %wOFV algorithm)
		regionOfInterest.InteractionsAllowed="translate";
		regionOfInterest.FixedAspectRatio=1;
		regionOfInterest.AspectRatio=1;
	end
	draw(regionOfInterest);
	roirect=round(regionOfInterest.Position);
	if get (handles.algorithm_selection,'Value')==4 %wOFV algorithm)
		%change selected region size to the next smaller power of two
		NearImSqSize = 2^(nextpow2(roirect(3))-1);
		if NearImSqSize < 64
			NearImSqSize=64;
		end
		deltasize=round(roirect(3) - NearImSqSize);
		regionOfInterest.Position = [roirect(1:2)+deltasize/2 NearImSqSize NearImSqSize];
		regionOfInterest.Label=['Adjusted size to ' num2str(NearImSqSize) ' x ' num2str(NearImSqSize) ' px'];
		roirect=round(regionOfInterest.Position);
	end

	if numel(roirect) == 4
		if roirect(3) < 64 || roirect(4)< 64
			uiwait(msgbox({'The rectangle you selected is too small.';'Please select a larger rectangle.';'(should be larger than 64 x 64 pixels)'},'Suggestion for PIV settings','modal'));
		else
			text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
			drawnow
			[A,~] = import.get_img(selected);
			[B,~] = import.get_img(selected+1);
			A_raw = A;
			B_raw = B;
			A=A(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
			B=B(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
			clahe=1;
			highp=0;
			intenscap=0;
			clahesize=64;
			highpsize=15;
			wienerwurst=0;
			wienerwurstsize=3;
			do_correlation_matrices=0;

			stretcher = stretchlim(A);
			minintens = stretcher(1);
			maxintens = stretcher(2);

			A = preproc.PIVlab_preproc (A,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

			stretcher = stretchlim(B);
			minintens = stretcher(1);
			maxintens = stretcher(2);

			B = preproc.PIVlab_preproc (B,[],clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

			interrogationarea=round(min(size(A))/4);
			if interrogationarea > 128
				interrogationarea = 128;
			end
			step=round(interrogationarea/4);
			if step < 6
				step=6;
			end
			[x, y, u, v, typevector,~,correlation_matrices] = piv.piv_FFTmulti (A,B,interrogationarea, step,1,[],[],1,32,16,16,'*linear',1,0,0,do_correlation_matrices,0,0);
			u=medfilt2(u);
			v=medfilt2(v);
			u=misc.inpaint_nans(u,4);
			v=misc.inpaint_nans(v,4);
			maxvel=max(max(sqrt(u.^2+v.^2)));
			%minimum size recommendation based on displacement
			recommended1=ceil(4*maxvel/2)*2;

			A_part=A;
			B_part=B;

			if strncmp (class(A),'uint8',6)
				A_part(A_part<=80)=0;
				A_part(A_part>80)=255;
				B_part(B_part<=80)=0;
				B_part(B_part>80)=255;
			elseif strncmp (class(A),'uint16',6)
				A_part(A_part<=80*255)=0;
				A_part(A_part>80*255)=255*255;
				B_part(B_part<=80*255)=0;
				B_part(B_part>80*255)=255*255;
			elseif strncmp (class(A),'double',6)
				A_part(A_part<=80/255)=0;
				A_part(A_part>80/255)=255/255;
				B_part(B_part<=80/255)=0;
				B_part(B_part>80/255)=255/255;
			end
			[~,numA]=bwlabeln(A_part,8);
			[~,numB]=bwlabeln(B_part,8);
			XA=((numA+numB)/2)/(size(A_part,1)*size(A_part,2));
			YA=8/XA;
			%minimum size recommendation based on particle density
			recommended2=round(sqrt(YA)/2)*2; % 8 peaks are in Z*Z area
			%minimum size recommendation based on experience with "normal PIV images"
			recommended3= 32; %relativ allgemeingÃ¼ltiger Erfahrungswert
			recommendation = median([recommended1 recommended2 recommended3]);
			if get (handles.algorithm_selection,'Value')==4 %wOFV algorithm)
				% use the PIV recommendation to perform another PIV analysis (with recommended settings and higher resolution) and use that to estimate wOFV settings...
				[x, y, u, v, ~,~,~] = piv.piv_FFTmulti (A,B,double(recommendation)*2, double(recommendation),1,[],[],2,double(recommendation),16,16,'*linear',0,0,0,0,0,0);
				[u,v] = postproc.PIVlab_postproc (u,v,[],[], [], 1,6,1,3); %validate results
				u=misc.inpaint_nans(u,4); %fill holes
				v=misc.inpaint_nans(v,4);
				[EtaPred,PatchSizePred] = wOFV.PredictSmoothnessCoefficient(x,y,u,v,A,B);
				gui.toolsavailable(1)
				uiwait(msgbox({'These are the recommendations for wOFV parameters:';[''];['Smoothness (eta): ' num2str(EtaPred)];['Patch size: ' num2str(PatchSizePred)];[''];'The settings are updated automatically.'},'Suggestion for wOFV settings','modal'));

				set (handles.ofv_median,'Value', 1); %revert to default?
				set(handles.ofv_pyramid_levels,'Value', 3); %revert to default?
				set (handles.ofv_eta,'String', num2str(EtaPred)); %predicted value

				if gui.retr('parallel')==0
					set (handles.text_parallelpatches,'visible','off')
					set (handles.ofv_parallelpatches,'visible','off')
					set (handles.ofv_parallelpatches,'Value',1)
				else
					set (handles.text_parallelpatches,'visible','on')
					set (handles.ofv_parallelpatches,'visible','on')
					switch PatchSizePred
						case 128
							set (handles.ofv_parallelpatches,'Value',2);
						case 256
							set (handles.ofv_parallelpatches,'Value',3);
						case 512
							set (handles.ofv_parallelpatches,'Value',4);
						case 1024
							set (handles.ofv_parallelpatches,'Value',5);
						otherwise
							set (handles.ofv_parallelpatches,'Value',6);
					end
				end
				delete(findobj('tag','hint'));
			else
				%[recommended1 recommended2 recommended3]
				uiwait(msgbox({'These are the recommendations for the size of the final interrogation area:';[''];['Based on the displacements: ' num2str(recommended1) ' pixels'];['Based on the particle count: ' num2str(recommended2) ' pixels'];['Based on practical experience: ' num2str(recommended3) ' pixels'];[''];'The settings are automatically updated with the median of the recommendation.'},'Suggestion for PIV settings','modal'));
				set(handles.algorithm_selection,'Value', 1)
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
				piv.pass2_checkbox_Callback(handles.checkbox26)
				piv.pass3_checkbox_Callback(handles.checkbox27)
				piv.pass4_checkbox_Callback(handles.checkbox28)
				piv.pass2_size_Callback(handles.edit50)
				piv.pass3_size_Callback(handles.edit51)
				piv.pass4_size_Callback(handles.edit52)
				piv.algorithm_selection_Callback(handles.algorithm_selection)
				piv.step_Callback(handles.step)
				piv.dispinterrog
				delete(findobj('tag','hint'));
			end
		end
	end
	delete(findobj('Tag','suggestRect'));
end
