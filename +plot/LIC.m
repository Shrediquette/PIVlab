function out=LIC(vx,vy,frame)
handles=gui.gui_gethand;
LICreso=round(get (handles.licres, 'value')*10)/10;
resultslist=gui.gui_retr('resultslist');
x=resultslist{1,frame};
y=resultslist{2,frame};
text(mean(x(1,:)/1.5),mean(y(:,1)), ['Please wait. LIC in progress...' sprintf('\n') 'If this message stays here for > 20s,' sprintf('\n') 'check MATLABs command window.' sprintf('\n') 'The function might need to be compiled first.'],'tag', 'waitplease', 'backgroundcolor', 'k', 'color', 'r','fontsize',10);
drawnow;
iterations=2;
pivlab_axis=gui.gui_retr('pivlab_axis');
old_units=get(pivlab_axis,'Units');
set(pivlab_axis,'Units','Pixels');
axessize=get(gca,'position');
set(pivlab_axis,'Units',old_units);
axessize=axessize(3:4);
%was ist grÃ¶ÃŸer, x oder y. dann entsprechend die x oder y grÃ¶ÃŸe der axes nehemn
xextend=size(vx,2);
yextend=size(vx,1);
if yextend<xextend
	scalefactor=axessize(1)/xextend;
else
	scalefactor=axessize(2)/yextend;
end

vx=inpaint_nans(vx); %otherwise LIC will make Matlab crash
vy=inpaint_nans(vy);
vx=imresize(vx,scalefactor*LICreso,'bicubic');
vy=imresize(vy,scalefactor*LICreso,'bicubic');


%{
this function is from:
Matlab VFV Toolbox 1.0
by courtesy of:
Nima Bigdely Shamlo (email: bigdelys-vfv@yahoo.com)
Computational Science Research Center
San Diego State University
%}

[width,height] = size(vx);
LIClength = round(max([width,height]) / 30);

kernel = ones(2 * LIClength);
LICImage = zeros(width, height);
intensity = ones(width, height); %#ok<*PREALL> % array containing vector intensity

% Making white noise
noiseImage=rand(width,height);

% Making LIC Image
try
	for m = 1:iterations
		[LICImage, intensity,normvx,normvy] = fastLICFunction(double(vx),double(vy),noiseImage,kernel); % External Fast LIC implemennted in C language
		LICImage = imadjust(LICImage); % Adjust the value range
		noiseImage = LICImage;
	end
	out=LICImage;
	delete(findobj('tag', 'waitplease'));
catch
	h=errordlg(['Could not run the LIC tool.' sprintf('\n') 'Probably the tool is not compiled correctly.' sprintf('\n')  'Please execute the following command in Matlab:' sprintf('\n') sprintf('\n') '     mex fastLICFunction.c     ' sprintf('\n') sprintf('\n') 'Then try again.'],'Error','on');
	uiwait(h);
	out=zeros(size(vx));
end

