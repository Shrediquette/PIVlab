function roi_dispStaticROI(target_axis)
handles=gui_NameSpace.gui_gethand;
delete(findobj(target_axis,'tag', {'RegionOfInterest' 'roiplot'}));
roirect=gui_NameSpace.gui_retr('roirect');
x=[roirect(1)  roirect(1)+roirect(3) roirect(1)+roirect(3)  roirect(1)            roirect(1) ];
y=[roirect(2)  roirect(2)            roirect(2)+roirect(4)  roirect(2)+roirect(4) roirect(2) ];
rectangle('Position',roirect,'LineWidth',1,'LineStyle','-','edgecolor','b','tag','roiplot')
rectangle('Position',roirect,'LineWidth',1,'LineStyle',':','edgecolor','y','tag','roiplot')
