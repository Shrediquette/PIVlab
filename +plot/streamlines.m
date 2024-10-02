function streamlines(target_axis,u, v, typevector, x, y, handles)
%streamlines:
streamlinesX=gui.retr('streamlinesX');
streamlinesY=gui.retr('streamlinesY');
delete(findobj('tag','streamline'));
if numel(streamlinesX)>0
	ustream=u-(gui.retr('subtr_u')/gui.retr('calu'));
	vstream=v-(gui.retr('subtr_v')/gui.retr('calv'));
	ustream(typevector==0)=nan;
	vstream(typevector==0)=nan;
	h=streamline(plot.mmstream2(x,y,ustream,vstream,streamlinesX,streamlinesY,'on'),'parent',target_axis);
	set (h,'tag','streamline');
	contents = get(handles.streamlcolor,'String');
	set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
end

