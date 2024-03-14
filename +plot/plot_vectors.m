function [q, q2] = plot_vectors(target_axis,handles, vecskip, x, typevector, y, u, vecscale, v, vectorcolor)
hold on;
vectorcolorintp=[str2double(get(handles.interpr,'string')) str2double(get(handles.interpg,'string')) str2double(get(handles.interpb,'string'))];

%normalize vector lengths so we can better see flow directions of small velocities:
if (get (handles.uniform_vector_scale,'Value'))==1
	u = u(:,:,1)./sqrt((u(:,:,1).^2+v(:,:,1).^2)); % normalized u
	v = v(:,:,1)./sqrt((u(:,:,1).^2+v(:,:,1).^2)); % normalized v
end

if vecskip==1
	q=quiver(x(typevector==1),y(typevector==1),...
		(u(typevector==1)-(gui.gui_retr('subtr_u')/gui.gui_retr('calu')))*vecscale,...
		(v(typevector==1)-(gui.gui_retr('subtr_v')/gui.gui_retr('calv')))*vecscale,...
		'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis);
	q2=quiver(x(typevector==2),y(typevector==2),...
		(u(typevector==2)-(gui.gui_retr('subtr_u')/gui.gui_retr('calu')))*vecscale,...
		(v(typevector==2)-(gui.gui_retr('subtr_v')/gui.gui_retr('calv')))*vecscale,...
		'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis);
	if str2num(get(handles.masktransp,'String')) < 100
		scatter(x(typevector==0),y(typevector==0),'rx','parent',target_axis) %masked
	end
else
	typevector_reduced=typevector(1:vecskip:end,1:vecskip:end);
	x_reduced=x(1:vecskip:end,1:vecskip:end);
	y_reduced=y(1:vecskip:end,1:vecskip:end);
	u_reduced=u(1:vecskip:end,1:vecskip:end);
	v_reduced=v(1:vecskip:end,1:vecskip:end);
	q=quiver(x_reduced(typevector_reduced==1),y_reduced(typevector_reduced==1),...
		(u_reduced(typevector_reduced==1)-(gui.gui_retr('subtr_u')/gui.gui_retr('calu')))*vecscale,...
		(v_reduced(typevector_reduced==1)-(gui.gui_retr('subtr_v')/gui.gui_retr('calv')))*vecscale,...
		'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis);
	q2=quiver(x_reduced(typevector_reduced==2),y_reduced(typevector_reduced==2),...
		(u_reduced(typevector_reduced==2)-(gui.gui_retr('subtr_u')/gui.gui_retr('calu')))*vecscale,...
		(v_reduced(typevector_reduced==2)-(gui.gui_retr('subtr_v')/gui.gui_retr('calv')))*vecscale,...
		'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis);
	if str2num(get(handles.masktransp,'String')) < 100
		scatter(x_reduced(typevector_reduced==0),y_reduced(typevector_reduced==0),'rx','parent',target_axis) %masked
	end
end
hold off;

