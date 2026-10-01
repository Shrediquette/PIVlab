function reference_vector_core(x,y,vecscale,target_axis,ref_position,reference_length,calu,calxy,displacement_only)
%REFERENCE_VECTOR_CORE Draw the reference vector of the PIVlab display (no GUI needed).
%   plot.reference_vector_core(x, y, vecscale, target_axis, ref_position, reference_length, ...
%       calu, calxy, displacement_only)
%   ref_position: 'Top left', 'Top right', 'Bottom right' or 'Bottom left'
%   reference_length: length of the reference vector in calibrated units
%   Used by plot.reference_vector (GUI) and plot.draw_vectors.
if iscell(ref_position)
    ref_position = ref_position{1};
end
delete(findobj(target_axis,'Tag','ref_vector'))
x_entries=sortrows(unique(x));
y_entries=sortrows(unique(y));

abs_calu=abs(calu);
rect_width=reference_length/abs_calu*vecscale*1.5;
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

if calxy==1 && (calu==1 || calu==-1)
    units='px/frame';
else % calibrated
    if ~isempty(displacement_only) && displacement_only == 1
        units='m';
    else
        units='m/s';
    end
end
%background(black)
rectangle(target_axis,'position',[x_rect ,ref_y-rect_height/2, rect_width,rect_height],'Tag','ref_vector','FaceColor','k','LineStyle','none')
text(target_axis,ref_x,ref_y+txt_y_offset,[num2str(reference_length) ' ' units],'BackgroundColor','k','Color','y','HorizontalAlignment',txt_align_hor,'VerticalAlignment',txt_align_vert,'Tag','ref_vector','Margin',12)
%vector
quiver(ref_x,ref_y,reference_length/abs_calu*vecscale,0,'autoscale','off','parent',target_axis,'Clipping','on','LineWidth',2,'Color','y','Tag','ref_vector','Alignment',ref_align,'MaxHeadSize',1);
end
