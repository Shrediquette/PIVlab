function plot_streamlines(target_axis,u, v, typevector, x, y, handles)
%streamlines:
streamlinesX=gui_NameSpace.gui_retr('streamlinesX');
streamlinesY=gui_NameSpace.gui_retr('streamlinesY');
delete(findobj('tag','streamline'));
if numel(streamlinesX)>0
	ustream=u-(gui_NameSpace.gui_retr('subtr_u')/gui_NameSpace.gui_retr('calu'));
	vstream=v-(gui_NameSpace.gui_retr('subtr_v')/gui_NameSpace.gui_retr('calv'));
	ustream(typevector==0)=nan;
	vstream(typevector==0)=nan;
	h=streamline(mmstream2(x,y,ustream,vstream,streamlinesX,streamlinesY,'on'),'parent',target_axis);
	set (h,'tag','streamline');
	contents = get(handles.streamlcolor,'String');
	set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
end
