function vel_limit_Callback(caller, ~, ~)
disp('auch das rectangle soll gespeichert und bearbeitbar / modifizierbar sein... Wie ROI')
gui.toolsavailable(0)
%if analys existing
resultslist=gui.retr('resultslist');
handles=gui.gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
    x=resultslist{1,(currentframe+1)/2};
    if size(x,1)>1
        if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
            index=1;
            foundfirst=0;
            for i = 1:size(resultslist,2)
                x=resultslist{1,i};
                if isempty(x)==0 && foundfirst==0
                    firstsizex=size(x,1);
                    secondsizex=size(x,2);
                    foundfirst=1;
                end
                if size(x,1)>1 && size(x,1)==firstsizex && size(x,2) == secondsizex
                    u(:,:,index)=resultslist{3,i}; %#ok<AGROW>
                    v(:,:,index)=resultslist{4,i}; %#ok<AGROW>
                    index=index+1;
                end
            end
        else
            y=resultslist{2,(currentframe+1)/2};
            u=resultslist{3,(currentframe+1)/2};
            v=resultslist{4,(currentframe+1)/2};
            typevector=resultslist{5,(currentframe+1)/2};
        end
        velrect=gui.retr('velrect');
        calu=gui.retr('calu');calv=gui.retr('calv');
       

        %problem: wenn nur ein frame analysiert, dann gibts probleme wenn display all frames in scatterplot an.
        datau=reshape(u*calu,1,size(u,1)*size(u,2)*size(u,3));
        datav=reshape(v*calv,1,size(v,1)*size(v,2)*size(v,3));


        if strcmpi(caller.Tag,'vel_limit_freehand')
            datau_mod=(datau');
            datav_mod=(datav');

            datau_mod=double(datau_mod*1);
            datav_mod=double(datav_mod*1);

            %MUST be double otherwise strange effects.

            datau_mod_nonans=datau_mod;
            datav_mod_nonans=datav_mod;

            datau_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];
            datav_mod_nonans(isnan(datau_mod)|isnan(datav_mod))=[];
            scatter(datau_mod_nonans,datav_mod_nonans,0.25,'.')
        else
            if size(datau,2)>1000000 %more than one million value pairs are too slow in scatterplot.
                pos=unique(ceil(rand(1000000,1)*(size(datau,2)-1))); %select random entries...
                scatter(gca,datau(pos),datav(pos), 0.25,'.'); %.. and plot them
            else
                scatter(gca,datau,datav, 0.25,'.');
            end
        end
        set(gca,'Yaxislocation','right','layer','top');
        drawnow;%needed from R2021b on... Why...?


        disp('hier passt das mit der axis nicht. man erkennt die labels nicht.')

        disp('wenn gezoomt wurde wärend rectangle auswahl, danach ist alles kaputt')
        %oldsize=get(gca,'outerposition');
        %newsize=[oldsize(1)+10 0.15 oldsize(3)*0.87 oldsize(4)*0.87];
        %set(gca,'outerposition', newsize)
        %%{
        if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
            xlabel(gca, 'u velocity [px/frame]', 'fontsize', 12)
            ylabel(gca, 'v velocity [px/frame]', 'fontsize', 12)
        else %calibrated
            displacement_only=gui.retr('displacement_only');
            if ~isempty(displacement_only) && displacement_only == 1
                xlabel(gca, 'u velocity [m/frame]', 'fontsize', 12)
                ylabel(gca, 'v velocity [m/frame]', 'fontsize', 12)
            else
                xlabel(gca, 'u velocity [m/s]', 'fontsize', 12)
                ylabel(gca, 'v velocity [m/s]', 'fontsize', 12)
            end
        end

        grid on
        %axis equal;
        set (gca, 'tickdir', 'in');
        %rangeu=nanmax(nanmax(nanmax(u*calu)))-nanmin(nanmin(nanmin(u*calu)));
        %rangev=nanmax(nanmax(nanmax(v*calv)))-nanmin(nanmin(nanmin(v*calv)));

        %set(gca,'xlim',[nanmin(nanmin(nanmin(u*caluv)))-rangeu*0.15 nanmax(nanmax(nanmax(u*caluv)))+rangeu*0.15])
        %set(gca,'ylim',[nanmin(nanmin(nanmin(v*caluv)))-rangev*0.15 nanmax(nanmax(nanmax(v*caluv)))+rangev*0.15])
        %=range of data +- 15%
        %%}

        if strcmpi(caller.Tag,'vel_limit_freehand')
            roi = images.roi.Freehand;
            draw(roi)
            tf = inROI(roi,datau_mod_nonans,datav_mod_nonans);
            gui.toolsavailable(1)
           %das braucht eine action wo äußere punkte dann ausgegraut
           %dargestellt werden.
           %Verhalten wie bei ROI für Bildausschnitt selektion
           %Außerdem muss roi abgespeichert werden permanent.... und editierbar bleiben
           %für refine velocity limits

           % hold on;
           % scatter(gca,datau_mod_nonans(tf==0),datav_mod_nonans(tf==0), 5,'rx');
           %gui.sliderdisp(gui.retr('pivlab_axis'))
        else
            %velrect = getrect(gca);









delete(findobj('tag', 'vel_limit_ROI'));
	regionOfInterest = images.roi.Rectangle;
	%roi.EdgeAlpha=0.75;
	regionOfInterest.FaceAlpha=0.05;
	regionOfInterest.LabelVisible = 'on';
	regionOfInterest.Tag = 'vel_limit_ROI';
	regionOfInterest.Color = 'g';
	regionOfInterest.StripeColor = 'k';
	roirect = gui.retr('velrect');

	if ~isempty(roirect)
		regionOfInterest=drawrectangle(gui.retr('pivlab_axis'),'Position',roirect);
		%roi.EdgeAlpha=0.75;
		regionOfInterest.FaceAlpha=0.05;
		regionOfInterest.LabelVisible = 'off';
		regionOfInterest.Tag = 'vel_limit_ROI';
		regionOfInterest.Color = 'g';
		regionOfInterest.StripeColor = 'k';
	else
		axes(gui.retr('pivlab_axis'))
		draw(regionOfInterest);
	end
	addlistener(regionOfInterest,'MovingROI',@validate.RegionOfInterestevents);
	addlistener(regionOfInterest,'DeletingROI',@validate.RegionOfInterestevents);
	dummyevt.EventName = 'MovingROI';
	validate.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
	%put ('roirect',roi.Position);




















%{


            if velrect(1,3)~=0 && velrect(1,4)~=0
                gui.put('velrect', velrect);
                validate.update_velocity_limits_information
                gui.sliderdisp(gui.retr('pivlab_axis'))
                delete(findobj(gca,'Type','text','color','r'));
                text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',10, 'fontweight','bold', 'BackgroundColor', 'k')
            else
                gui.sliderdisp(gui.retr('pivlab_axis'))
                text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k')
            end
%}
            gui.toolsavailable(1)
  %          gui.MainWindow_ResizeFcn(gcf)

        end
    end
end


