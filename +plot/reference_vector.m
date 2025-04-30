function reference_vector(x,y,vecscale,target_axis,ref_position)
handles=gui.gethand;
% Reference vector
reference_length = str2double(get(handles.ref_vect_scl,'String'));
delete(findobj('Tag','ref_vector'))
x_entries=sortrows(unique(x));
y_entries=sortrows(unique(y));

rect_width=reference_length/gui.retr('calu')*vecscale*1.5;
rect_height=rect_width / 2;

if strcmpi (ref_position,'top right')
    ref_align='head';
    txt_align_hor='right';
    txt_align_vert='top';
    ref_x=x_entries(end-1);
    ref_y=y_entries(2);
    txt_y_offset=+30;
    x_rect=ref_x-rect_width*  2/(1.5+1);
elseif strcmpi (ref_position,'bottom right')
    ref_align='head';
    txt_align_hor='right';
    txt_align_vert='bottom';
    ref_x=x_entries(end-1);
    ref_y=y_entries(end-1);
    txt_y_offset=-30;
    x_rect=ref_x-rect_width*  2/(1.5+1);
elseif strcmpi (ref_position,'bottom left')
    ref_align='tail';
    txt_align_hor='left';
    txt_align_vert='bottom';
    ref_x=x_entries(2);
    ref_y=y_entries(end-1);
    txt_y_offset=-30;
    x_rect=ref_x  -rect_width/6;
elseif strcmpi (ref_position,'top left')
    ref_align='tail';
    txt_align_hor='left';
    txt_align_vert='top';
    ref_x=x_entries(2);
    ref_y=y_entries(2);
    txt_y_offset=+30;
    x_rect=ref_x  -rect_width/6;
end

if gui.retr('calxy')==1 && (gui.retr('calu')==1 ||gui.retr('calu'==-1))
    units='px/frame';
else % calibrated
    displacement_only=gui.retr('displacement_only');
    if ~isempty(displacement_only) && displacement_only == 1
        units='m';
    else
        units='m/s';
    end
end
%background(black)
rectangle('position',[x_rect ,ref_y-rect_height/2, rect_width,rect_height],'Tag','ref_vector','FaceColor','k','LineStyle','none')
text(ref_x,ref_y+txt_y_offset,[num2str(reference_length) ' ' units],'BackgroundColor','k','Color','y','HorizontalAlignment',txt_align_hor,'VerticalAlignment',txt_align_vert,'Tag','ref_vector','Margin',12)
%vector
quiver(ref_x,ref_y,reference_length/gui.retr('calu')*vecscale,0,'autoscale','off','parent',target_axis,'Clipping','on','LineWidth',2,'Color','y','Tag','ref_vector','Alignment',ref_align,'MaxHeadSize',1);