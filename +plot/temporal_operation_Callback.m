function temporal_operation_Callback(~, ~, type)
handles=gui.gethand;
filepath=gui.retr('filepath');
filename=gui.retr('filename');
framenum=gui.retr('framenum');
framepart=gui.retr('framepart');
resultslist=gui.retr('resultslist');

if isempty(resultslist)==0
	if size(filepath,1)>0
		sizeerror=0;
		typevectormittel=ones(size(resultslist{1,1}));
		ismean=gui.retr('ismean');
		if isempty(ismean)==1
			ismean=zeros(size(resultslist,2),1);
		end
		if get (handles.append_replace,'Value')==2
			for i=size(ismean,1):-1:1 %remove averaged results
				if ismean(i,1)==1
					filepath(i*2,:)=[];
					filepath(i*2-1,:)=[];
					filename(i*2,:)=[];
					filename(i*2-1,:)=[];
					if gui.retr('video_selection_done') == 0
						framenum(i*2,:)=[];
						framenum(i*2-1,:)=[];
						framepart(i*2,:)=[];
						framepart(i*2-1,:)=[];
					end
					resultslist(:,i)=[];
					ismean(i,:)=[];
				end
			end
			gui.put('filepath',filepath);
			gui.put('filename',filename);
			gui.put('framenum',framenum);
			gui.put('framepart',framepart);
			gui.put('resultslist',resultslist);
			gui.put('ismean',[]);
			gui.sliderrange(1)
		end
		str = strrep(get(handles.selectedFramesMean,'string'),'-',':');
		endinside=strfind(str, 'end');
		if isempty(endinside)==0 %#ok<*STREMP>
			str = strrep(get(handles.selectedFramesMean,'string'),'end',num2str(max(find(ismean==0)))); %#ok<MXFND>
		end
		selectionok=1;

		strnum=str2num(str);
		if isempty(strnum)==1 || isempty(strfind(str,'.'))==0 || isempty(strfind(str,';'))==0
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',['Error in frame selection syntax. Please use the following syntax (examples):' sprintf('\n') '1:3' sprintf('\n') '1,3,7,9' sprintf('\n') '1:3,7,8,9,11:13' ],'modal');
			selectionok=0;
		end
		if selectionok==1
			mincount=(min(strnum));
			for count=mincount:size(resultslist,2)
				if size(resultslist,2)>=count && numel(resultslist{1,count})>0
					x=resultslist{1,count};
					y=resultslist{2,count};
					if size(resultslist,1)>6 %filtered exists
						if size(resultslist,1)>10 && numel(resultslist{10,count}) > 0 %smoothed exists
							u=resultslist{10,count};
							v=resultslist{11,count};
							typevector=resultslist{9,count};
							if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
								typevector=resultslist{5,count};
							end
						else
							u=resultslist{7,count};
							if size(u,1)>1
								v=resultslist{8,count};
								typevector=resultslist{9,count};
							else %filter was applied for other frames but not for this one
								u=resultslist{3,count};
								v=resultslist{4,count};
								typevector=resultslist{5,count};
							end
						end
					else
						u=resultslist{3,count};
						v=resultslist{4,count};
						typevector=resultslist{5,count};
					end

					%if count==mincount %besser: wenn orgsize nicht existiert
					if exist('originalsizex','var')==0
						originalsizex=size(u,2);
						originalsizey=size(u,1);
					else

						if size(u,2)~=originalsizex || size(u,1)~=originalsizey
							sizeerror=1;
						end
					end
					if ismean(count,1)==0 && sizeerror==0
						umittel(:,:,count)=u; %#ok<AGROW>
						vmittel(:,:,count)=v; %#ok<AGROW>
					end
					if sizeerror==0
						typevectormittel(:,:,count)=typevector;
					end
				end

			end
			if sizeerror==0
				for i=1:size(strnum,2)
					if size(resultslist,2)>=strnum(i) %dann ok
						x_tmp=resultslist{1,strnum(i)};
						if isempty(x_tmp)==1 %dann nicht ok
							gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Your selected range includes non-analyzed frames.','modal');
							selectionok=0;
							break
						end
					else
						gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Your selected range includes non-analyzed frames.','modal');
                        selectionok=0;
                        break
                    end
                    if size(ismean,1)>=strnum(i)
                        if ismean(strnum(i))==1
                            gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','You must not include frames in your selection that already consist of mean vectors.','modal');
    						selectionok=0;
                            break
                        end
                    else
						gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Your selected range exceeds the amount of analyzed frames.','modal');
						selectionok=0;
						break
					end
				end

				if selectionok==1

					%% calculate mean mask from all the masks that have been applied
					masks_in_frame=gui.retr('masks_in_frame');
					if ~isempty(masks_in_frame)
						expected_image_size=gui.retr('expected_image_size');
                        converted_mask=zeros(expected_image_size,'uint16');
                        amount_nonmean_images = numel(ismean(ismean==0));
                        frames_to_process= eval(['[' str ']']);
                        for i=frames_to_process
                            if numel (masks_in_frame) >= i%if size (masks_in_frame,2) >= i
                                mask_positions=masks_in_frame{i};
                                converted_mask=converted_mask + uint16(mask.convert_masks_to_binary(expected_image_size,mask_positions)); %only when all frames are masked --> apply mask also in the average.
                            end
                        end
                        converted_mask(converted_mask<numel(frames_to_process))=0;
                        converted_mask(converted_mask==numel(frames_to_process))=1;
                        converted_mask=uint8(converted_mask);
                        blocations = bwboundaries(converted_mask,'holes');
                        frame_where_to_put_the_average=size(resultslist,2)+1;
						masks_in_frame(frame_where_to_put_the_average:end)=[];%remove any pre-existing mask in the curretn frame
						masks_in_frame=mask.px_to_rois(blocations,frame_where_to_put_the_average,masks_in_frame,'on');
						gui.put('masks_in_frame',masks_in_frame);
					end
					typevectoralle=ones(size(typevector));

					%Hier erst neue matrix erstellen mit ausgewÃ¤hlten frames
					%typevectoralle ist ausgabe fÃ¼r gui
					%typevectormean ist der mittelwert aller types
					%typevectormittel ist der stapel aus allen typevectors

					eval(['typevectormittelselected=typevectormittel(:,:,[' str ']);']);

					typevectormean=mean(typevectormittelselected,3);  %#ok<USENS>
					%for i=1:size(typevectormittelselected,3)
					for i=1:size(typevectormittelselected,1)
						for j=1:size(typevectormittelselected,2)
							if mean(typevectormittelselected(i,j,:))==0 %#ok<*IDISVAR>
								typevectoralle(i,j)=0;
							end
						end
					end
					%da wo ALLE null sidn auf null setzen.
					%typevectoralle(typevectormittelselected(:,:,i)==0)=0; %maskierte vektoren sollen im Mean maskiert sein
					% end

					typevectoralle(typevectormean>1.5)=2; %if more than 50% of vectors are interpolated, then mark vector in mean as interpolated too.
					resultslist{5,size(filepath,1)/2+1}=typevectoralle;
					resultslist{1,size(filepath,1)/2+1}=x;
					resultslist{2,size(filepath,1)/2+1}=y;

					%hier neue matrix mit ausgewÃ¤hlten frames!
					eval(['umittelselected=umittel(:,:,[' str ']);']);
					eval(['vmittelselected=vmittel(:,:,[' str ']);']);
					if type==3
						%Turbulent kinetic energy TKE, based on discussion
                        %with H.E. TOUHAMI, improved by Stefano M.

                        TKE_x=0.5*var(umittelselected,0,3,'omitnan');
                        TKE_y=0.5*var(vmittelselected,0,3,'omitnan');

                        % Calculate the total TKE
                        %TKE = TKE_x + TKE_y; % currently not used. --> calculated in plot.derivative_calc.m

						%remove non-valid measurements
						TKE_x(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
						TKE_y(typevectormean>=1.75)=nan;

						resultslist{3,size(filepath,1)/2+1}=TKE_x;
						resultslist{4,size(filepath,1)/2+1}=TKE_y;
					end
					if type==2
						%standard deviation
						out_mean_u=std(umittelselected,0,3,'omitnan'); %#ok<*NANSTD,NODEF>
						out_mean_v=std(vmittelselected,0,3,'omitnan'); %#ok<NODEF>
						out_mean_u(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
						out_mean_v(typevectormean>=1.75)=nan;
						resultslist{3,size(filepath,1)/2+1}=out_mean_u;
						resultslist{4,size(filepath,1)/2+1}=out_mean_v;
					end

					if type==1
						out_mean_u=mean(umittelselected,3,'omitnan');
						out_mean_v=mean(vmittelselected,3,'omitnan');
						out_mean_u(typevectormean>=1.75)=nan; %discard everything that has less than 25% valid measurements
						out_mean_v(typevectormean>=1.75)=nan;
						resultslist{3,size(filepath,1)/2+1}=out_mean_u;
						resultslist{4,size(filepath,1)/2+1}=out_mean_v;
					end

					if type==0
						try
							resultslist{3,size(filepath,1)/2+1}=sum(umittelselected,3,'omitnan');
							resultslist{4,size(filepath,1)/2+1}=sum(vmittelselected,3,'omitnan');
						catch
							umittelselected(isnan(umittelselected))=0;
							vmittelselected(isnan(vmittelselected))=0;
							resultslist{3,size(filepath,1)/2+1}=sum(umittelselected,3);
							resultslist{4,size(filepath,1)/2+1}=sum(vmittelselected,3);
						end
					end
					filepathselected=filepath(1:2:end);
					eval(['filepathselected=filepathselected([' str '],:);']);
					filepath{size(filepath,1)+1,1}=filepathselected{1,1};
					filepath{size(filepath,1)+1,1}=filepathselected{1,1};
					if gui.retr('video_selection_done') == 0
						framenum (size(framenum,1)+1,1)=framenum(1,1);
						framenum (size(framenum,1)+1,1)=framenum(1,1);
						framepart(size(framepart,1)+1,:)=framepart(1,:);
						framepart(size(framepart,1)+1,:)=framepart(1,:);
					else
						video_frame_selection=gui.retr('video_frame_selection');
						video_frame_selection(end+1,1)=video_frame_selection(strnum(end)*2);
						video_frame_selection(end+1,1)=video_frame_selection(strnum(end)*2);
						gui.put('video_frame_selection',video_frame_selection);
					end
					filename=gui.retr('filename');
					if type == 3
						filename{size(filename,1)+1,1}=['TKE of frames ' str];
						filename{size(filename,1)+1,1}=['TKE of frames ' str];
					end
					if type == 2
						filename{size(filename,1)+1,1}=['STDEV of frames ' str];
						filename{size(filename,1)+1,1}=['STDEV of frames ' str];
					end
					if type == 1
						filename{size(filename,1)+1,1}=['MEAN of frames ' str];
						filename{size(filename,1)+1,1}=['MEAN of frames ' str];
					end
					if type == 0
						filename{size(filename,1)+1,1}=['SUM of frames ' str];
						filename{size(filename,1)+1,1}=['SUM of frames ' str];
					end
					ismean(size(resultslist,2),1)=1;
					gui.put('ismean',ismean);
					gui.put ('resultslist', resultslist);
					gui.put ('filepath', filepath);
					gui.put ('filename', filename);
					gui.put ('framenum', framenum);
					gui.put ('framepart', framepart);
					gui.put ('typevector', typevector);
					gui.sliderrange(1)
					try
						set (handles.fileselector,'value',get (handles.fileselector,'max'));
					catch
					end
					gui.sliderdisp(gui.retr('pivlab_axis'))
				end
			else %user tried to average analyses with different sizes
				gui.custom_msgbox('error',getappdata(0,'hgui'),'Averaging / summing not possible...','All analyses of one session have to be of the same size and have to be analyzed with identical PIV settings.','modal');
			end
		end
	end
end