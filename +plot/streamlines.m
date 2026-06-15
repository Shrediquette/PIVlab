function streamlines(target_axis,u, v, typevector, x, y, handles)
streamlinesX=gui.retr('streamlinesX');
streamlinesY=gui.retr('streamlinesY');
streamslice_active=gui.retr('streamslice_active');
delete(findobj(target_axis,'tag','streamline'));
ustream=u-(gui.retr('subtr_u')/gui.retr('calu'));
vstream=v-(gui.retr('subtr_v')/gui.retr('calv'));
ustream(typevector==0)=nan;
vstream(typevector==0)=nan;
contents = get(handles.streamlcolor,'String');
color = contents{get(handles.streamlcolor,'Value')};
lw = get(handles.streamlwidth,'value');
if numel(streamslice_active)>0 && streamslice_active
	u_sl=double(ustream); u_sl(isnan(u_sl))=0;
	v_sl=double(vstream); v_sl(isnan(v_sl))=0;
	hold(target_axis,'on');
	density=str2double(get(handles.streamslicedensity,'string'));
	if isnan(density)||density<=0; density=1; end
	h=streamslice(target_axis,double(x),double(y),u_sl,v_sl,density);
	hold(target_axis,'off');
	set(h,'tag','streamline','Color',color,'LineWidth',lw);
elseif numel(streamlinesX)>0
	h=streamline(plot.mmstream2(x,y,ustream,vstream,streamlinesX,streamlinesY,'on'),'parent',target_axis);
	set(h,'tag','streamline');
	set(h,'LineWidth',lw,'Color',color);
end