function [q, q2] = vectors(target_axis,handles, vecskip, x, typevector, y, u, vecscale, v, vectorcolor)

hold on;
vectorcolorintp=[str2double(get(handles.interpr,'string')) str2double(get(handles.interpg,'string')) str2double(get(handles.interpb,'string'))];

%normalize vector lengths so we can better see flow directions of small velocities:
if (get (handles.uniform_vector_scale,'Value'))==1
    u = u(:,:,1)./sqrt((u(:,:,1).^2+v(:,:,1).^2)); % normalized u
    v = v(:,:,1)./sqrt((u(:,:,1).^2+v(:,:,1).^2)); % normalized v
end
if (get (handles.power_vector_scale,'Value'))==1
    exponent_1=str2double(get(handles.power_vector_scale_factor,'String'));
    signs_u=sign(u);
    signs_v=sign(v);
    mean_old=mean(abs(u(:)),'omitnan')+mean(abs(v(:)),'omitnan');
    u=(abs(u).^exponent_1).*signs_u;
    v=(abs(v).^exponent_1).*signs_v;
    mean_new=mean(abs(u(:)),'omitnan')+mean(abs(v(:)),'omitnan');
    u=u*mean_old/mean_new;
    v=v*mean_old/mean_new;
end
if vecskip==1
    q=quiver(x(typevector==1),y(typevector==1),...
        (u(typevector==1)-(gui.retr('subtr_u')/gui.retr('calu')))*vecscale,...
        (v(typevector==1)-(gui.retr('subtr_v')/gui.retr('calv')))*vecscale,...
        'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis,'Clipping','on');%,'Alignment','center');
    q2=quiver(x(typevector==2),y(typevector==2),...
        (u(typevector==2)-(gui.retr('subtr_u')/gui.retr('calu')))*vecscale,...
        (v(typevector==2)-(gui.retr('subtr_v')/gui.retr('calv')))*vecscale,...
        'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis,'Clipping','on');%,'Alignment','center');
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
        (u_reduced(typevector_reduced==1)-(gui.retr('subtr_u')/gui.retr('calu')))*vecscale,...
        (v_reduced(typevector_reduced==1)-(gui.retr('subtr_v')/gui.retr('calv')))*vecscale,...
        'Color', vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis,'Clipping','on');
    q2=quiver(x_reduced(typevector_reduced==2),y_reduced(typevector_reduced==2),...
        (u_reduced(typevector_reduced==2)-(gui.retr('subtr_u')/gui.retr('calu')))*vecscale,...
        (v_reduced(typevector_reduced==2)-(gui.retr('subtr_v')/gui.retr('calv')))*vecscale,...
        'Color', vectorcolorintp,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'parent',target_axis,'Clipping','on');
    if str2num(get(handles.masktransp,'String')) < 100
        scatter(x_reduced(typevector_reduced==0),y_reduced(typevector_reduced==0),'rx','parent',target_axis) %masked
    end
end

% reference vector display
ref_choices=get(handles.ref_vect_pos,'String');
ref_choice=get(handles.ref_vect_pos,'Value');

if ref_choice ~=1
    ref_position = ref_choices(ref_choice);
    plot.reference_vector(x,y,vecscale,target_axis,ref_position);
end
hold off;
target_axis.Clipping = "on";