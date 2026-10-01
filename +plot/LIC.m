function out=LIC(vx,vy,frame)
handles=gui.gethand;
LICreso=round(get (handles.licres, 'value')*10)/10;
resultslist=gui.retr('resultslist');
x=resultslist{1,frame};
y=resultslist{2,frame};
text(mean(x(1,:)/1.5),mean(y(:,1)), ['Please wait. LIC in progress...' sprintf('\n') 'If this message stays here for > 20s,' sprintf('\n') 'check MATLABs command window.' sprintf('\n') 'The function might need to be compiled first.'],'tag', 'waitplease', 'backgroundcolor', 'k', 'color', 'r','fontsize',10);
drawnow;
iterations=2;
pivlab_axis=gui.retr('pivlab_axis');
old_units=get(pivlab_axis,'Units');
set(pivlab_axis,'Units','Pixels');
axessize=get(pivlab_axis,'position');
set(pivlab_axis,'Units',old_units);
axessize=axessize(3:4);
%was ist größer, x oder y. dann entsprechend die x oder y größe der axes nehemn
xextend=size(vx,2);
yextend=size(vx,1);
if yextend<xextend
	scalefactor=axessize(1)/xextend;
else
	scalefactor=axessize(2)/yextend;
end

% Making LIC Image (shared with the command-line API, plot.LIC_core)
try
	out=plot.LIC_core(vx,vy,scalefactor*LICreso,iterations);
	delete(findobj('tag', 'waitplease'));
catch
gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',['Could not run the LIC tool.' sprintf('\n') 'Probably the tool is not compiled correctly.' sprintf('\n')  'Please execute the following command in Matlab:' sprintf('\n') sprintf('\n') '     mex +plot\fastLICFunction.c     ' sprintf('\n') sprintf('\n') 'Then try again.'],'modal');
	out=zeros(size(vx));
end
