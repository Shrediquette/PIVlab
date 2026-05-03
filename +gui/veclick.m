function veclick(~,src)
target_axis=gui.retr('pivlab_axis');
if src.Button == 1
	%only active if vectors are displayed.
	handles=gui.gethand;
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
	resultslist=gui.retr('resultslist');

	%apply calibration, direction and offset to x and y coordinates
	x=resultslist{1,(currentframe+1)/2};
	y=resultslist{2,(currentframe+1)/2};

	[x_cal,y_cal]=calibrate.xy (x,y);
	pos=get(target_axis,'CurrentPoint');

	xposition=round(pos(1,1));
	yposition=round(pos(1,2));
	findx=abs(x/xposition-1);
	[trash, imagex]=find(findx==min(min(findx)));
	findy=abs(y/yposition-1);
	[imagey, trash]=find(findy==min(min(findy)));
	info(1,1)=imagey(1,1);
	info(1,2)=imagex(1,1);

	if size(resultslist,1)>6 %filtered exists
		if size(resultslist,1)>10 && numel(resultslist{10,(currentframe+1)/2}) > 0 %smoothed exists
			u=resultslist{10,(currentframe+1)/2};
			v=resultslist{11,(currentframe+1)/2};
			typevector=resultslist{9,(currentframe+1)/2};
			if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
				typevector=resultslist{5,(currentframe+1)/2};
			end
		else
			u=resultslist{7,(currentframe+1)/2};
			if size(u,1)>1
				v=resultslist{8,(currentframe+1)/2};
				typevector=resultslist{9,(currentframe+1)/2};
			else %filter was applied for other frames but not for this one
				u=resultslist{3,(currentframe+1)/2};
				v=resultslist{4,(currentframe+1)/2};
				typevector=resultslist{5,(currentframe+1)/2};
			end
		end
	else
		u=resultslist{3,(currentframe+1)/2};
		v=resultslist{4,(currentframe+1)/2};
		typevector=resultslist{5,(currentframe+1)/2};
	end

	if typevector(info(1,1),info(1,2)) ~=0
		delete(findobj(target_axis,'tag', 'infopoint'));
		%here, the calibration matters...
		if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1%not calibrated
			set(handles.u_cp, 'String', ['u:' num2str(round((u(info(1,1),info(1,2))*gui.retr('calu')-gui.retr('subtr_u'))*100000)/100000) ' px/fr']);
			set(handles.v_cp, 'String', ['v:' num2str(round((v(info(1,1),info(1,2))*gui.retr('calv')-gui.retr('subtr_v'))*100000)/100000) ' px/fr']);
			set(handles.x_cp, 'String', ['x:' num2str(round((x_cal(info(1,1),info(1,2)))*10000)/10000) ' px']);
			set(handles.y_cp, 'String', ['y:' num2str(round((y_cal(info(1,1),info(1,2)))*10000)/10000) ' px']);
		else %calibrated
			displacement_only=gui.retr('displacement_only');
			if ~isempty(displacement_only) && displacement_only == 1
				time_unit='frame';
			else
				time_unit='s';
			end
			u_cp_string_velocity=u(info(1,1),info(1,2))*gui.retr('calu')-gui.retr('subtr_u');
			v_cp_string_velocity=v(info(1,1),info(1,2))*gui.retr('calv')-gui.retr('subtr_v');
			x_cp_string = x_cal(info(1,1),info(1,2));
			y_cp_string = y_cal(info(1,1),info(1,2));

			magnitude_of_current_point = (u_cp_string_velocity^2 + v_cp_string_velocity^2)^0.5;


			if  magnitude_of_current_point > 100 || magnitude_of_current_point < 0.01
				set(handles.u_cp, 'String',  ['u:' sprintf('%0.4e',u_cp_string_velocity) ' m/' time_unit]);
				set(handles.v_cp, 'String',  ['v:' sprintf('%0.4e',v_cp_string_velocity) ' m/' time_unit]);
			else
				set(handles.u_cp, 'String',  ['u:' sprintf('%0.4f',u_cp_string_velocity) ' m/' time_unit]);
				set(handles.v_cp, 'String',  ['v:' sprintf('%0.4f',v_cp_string_velocity) ' m/' time_unit]);
			end
			if x_cp_string > 100 || x_cp_string < 0.01 || y_cp_string > 100 || y_cp_string < 0.01
				set(handles.x_cp, 'String', ['x:' sprintf('%0.4e',x_cp_string)  ' m']);
				set(handles.y_cp, 'String', ['y:' sprintf('%0.4e',y_cp_string)  ' m']);
			else
				set(handles.x_cp, 'String', ['x:' sprintf('%0.4f',x_cp_string)  ' m']);
				set(handles.y_cp, 'String', ['y:' sprintf('%0.4f',y_cp_string)  ' m']);
			end
		end
		derived=gui.retr('derived');
		displaywhat=gui.retr('displaywhat');
		if displaywhat>1
			if size (derived,2) >= (currentframe+1)/2
				if numel(derived{displaywhat-1,(currentframe+1)/2})>0
					map=derived{displaywhat-1,(currentframe+1)/2};
					name=get(handles.derivchoice,'string');
					try
						scalar_to_plot=map(info(1,1),info(1,2));
						if scalar_to_plot >100 || scalar_to_plot < 0.001
							scalar_to_plot_string = sprintf('%0.4e',scalar_to_plot);
						else
							scalar_to_plot_string = sprintf('%0.4f',scalar_to_plot);
						end
						set(handles.scalar_cp, 'String', [name{displaywhat} ': ' scalar_to_plot_string]);
					catch
						plot.derivs_Callback
						name=get(handles.derivchoice,'string');
						scalar_to_plot=map(info(1,1),info(1,2));
						if scalar_to_plot >100 || scalar_to_plot < 0.001
							scalar_to_plot_string = sprintf('%0.4e',scalar_to_plot);
						else
							scalar_to_plot_string = sprintf('%0.4f',scalar_to_plot);
						end
						set(handles.scalar_cp, 'String', [name{displaywhat} ': ' scalar_to_plot_string]);
					end
				else
					set(handles.scalar_cp, 'String','N/A');
				end
			else
				set(handles.scalar_cp, 'String','N/A');
			end
		else
			set(handles.scalar_cp, 'String','N/A');
		end

		hold(target_axis,'on');

		try
			magnitude_px=((u(info(1,1),info(1,2))).^2+(v(info(1,1),info(1,2))).^2).^0.5;
			magnitude_m=((u(info(1,1),info(1,2))*gui.retr('calu')-gui.retr('subtr_u')).^2+(v(info(1,1),info(1,2))*gui.retr('calv')-gui.retr('subtr_v')).^2).^0.5;
			magnitude_px = sprintf('%0.2g',magnitude_px);
			magnitude_m = sprintf('%0.2g',magnitude_m);
			if ~handles.multip29.Visible
				if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1%not calibrated
					text(target_axis,x(info(1,1),info(1,2)),y(info(1,1),info(1,2)),[' ' magnitude_px ' px/fr'], 'tag', 'infopoint','Color','w','HorizontalAlignment','left','VerticalAlignment','middle','Margin',0.01,'BackgroundColor','k','FontSize',10)
				else
					text(target_axis,x(info(1,1),info(1,2)),y(info(1,1),info(1,2)),[' ' magnitude_px ' px/fr\newline ' magnitude_m ' m/' time_unit], 'tag', 'infopoint','Color','w','HorizontalAlignment','left','VerticalAlignment','middle','Margin',0.01,'BackgroundColor','k')
				end
			end
		catch ME
			disp('could not plot point info')
			disp (ME.message)
		end
		plot(target_axis,x(info(1,1),info(1,2)),y(info(1,1),info(1,2)), 'y.', 'tag', 'infopoint','linewidth', 1.5, 'markersize', 20);
		hold(target_axis,'off');
		%% plot correlation matrices if the corresponding panel is visible
		if handles.multip29.Visible
			correlation_matrices_data = gui.retr('correlation_matrices_data');
			if currentframe == correlation_matrices_data.frame && size(x,1) == correlation_matrices_data.size(1) && size(x,2) == correlation_matrices_data.size(2) %% data was calculated for the currently visible frame
				fig=findobj('Tag','correlation_matrices_plot_matrix');
				if isempty(fig)
					fig=figure;
					fig.Tag = 'correlation_matrices_plot_matrix';
					fig.Name='Correlation matrices';
					fig.IntegerHandle="off";
					fig.DockControls="off";
					%fig.WindowStyle="alwaysontop";
					fig.MenuBar="figure";
				end
				figure(fig);
				switch correlation_matrices_data.passes
					case 1
						t = tiledlayout(1,1,'Parent',fig);
					case 2
						t = tiledlayout(1,2,'Parent',fig);
					case 3
						t = tiledlayout(1,3,'Parent',fig);
					case 4
						t = tiledlayout(2,2,'Parent',fig);
				end
				t.TileSpacing = 'compact';
				t.Padding = 'compact';
				% find the corresponding correlation amtrices of the first passes
				%info(1,2) %x koordinate
				for pass = 1 : correlation_matrices_data.passes
					axh=nexttile;
					x_pass=correlation_matrices_data.all_xy_tables{pass,1};
					y_pass=correlation_matrices_data.all_xy_tables{pass,2};
					findx=abs(x_pass/x(info(1,1),info(1,2))-1);
					[~, imagex]=find(findx==min(min(findx)));
					findy=abs(y_pass/y(info(1,1),info(1,2))-1);
					[imagey, ~]=find(findy==min(min(findy)));
					pass_info(1,1)=imagey(1,1);
					pass_info(1,2)=imagex(1,1);
					idx_to_plot = sub2ind(size(correlation_matrices_data.all_xy_tables{pass,1}),pass_info(1),pass_info(2));
					imagesc(correlation_matrices_data.correlation_matrices{pass}(:,:,idx_to_plot));
					%shading flat;
					%view(0, 90);
					axis tight;
					set(axh, 'DataAspectRatio', [1 1 1]);
					set(axh, 'YDir', 'reverse');
					title(['Pass nr. ' num2str(pass) ' (' num2str(size(correlation_matrices_data.correlation_matrices{pass},2)) 'x' num2str(size(correlation_matrices_data.correlation_matrices{pass},1)) ')'])
				end
				%rotate3d(fig,'on');
			else
				gui.custom_msgbox('error',getappdata(0,'hgui'),'Outdated','Correlation matrices need to be retrieved first.','modal');
			end
		end
	end
else %right or middle button
	delete(findobj(target_axis,'tag', 'infopoint'));
end