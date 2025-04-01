function PIVlab_citing
fh = findobj('tag', 'PIVlab_citing_window');

if isempty(fh)
	PIVlab_citing_window = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','How to cite PIVlab','Toolbar','none','Units','characters','Position', [5 5 70 32],'tag','PIVlab_citing_window','visible','on','KeyPressFcn', @key_press,'resize','off');
	set (PIVlab_citing_window,'Units','Characters');

	handles = guihandles; %alle handles mit tag laden und ansprechbar machen
	guidata(PIVlab_citing_window,handles)

	parentitem = get(PIVlab_citing_window, 'Position');

	margin=1.5;

	panelheight=31.8;
	handles.mainpanel = uipanel(PIVlab_citing_window, 'Units','characters', 'Position', [1 parentitem(4)-panelheight parentitem(3)-2 panelheight],'title','PIVlab papers','fontweight','bold');

	%% mainpanel
	paperstring1='Thielicke, W. (2022) Pulse-length induced motion blur in PIV particle images: To be avoided at any cost?. Proceedings of the Fachtagung Experimentelle Strömungsmechanik 2022, 6.–8. September 2022, Ilmenau, Germany, ISBN 978-3-9816764-8-8, https://www.gala-ev.org/images/Beitraege/Beitraege2022/pdf/04.pdf';
	paperstring2='Thielicke, W., Sonntag, R. (2021) Particle Image Velocimetry for MATLAB: Accuracy and enhanced algorithms in PIVlab. Journal of Open Research Software, 9: 12. DOI: https://doi.org/10.5334/jors.334';
	paperstring3='Thielicke, W. and Stamhuis, E.J. (2014): PIVlab – Towards User-friendly, Affordable and Accurate Digital Particle Image Velocimetry in MATLAB. Journal of Open Research Software 2(1):e30, DOI: http://dx.doi.org/10.5334/jors.bl';
	paperstring4='Thielicke, W. (2014): The Flapping Flight of Birds - Analysis and Application. Phd thesis, Rijksuniversiteit Groningen. https://hdl.handle.net/11370/31931f33-4aa0-4280-892e-93699af0e9b6';
	paperstring5='Schmidt, B. E., & Sutton, J. A. (2019). High-resolution velocimetry from tracer particle fields using a wavelet-based optical flow method. Experiments in Fluids, 60(3), 37 https://doi.org/10.1007/s00348-019-2685-6';
	paperstring6='Schmidt, B. E., Page, W. E., Jassal, G. R., & Sutton, J. A. (2024). Sensitivity of wavelet-based optical flow velocimetry (wOFV) to common experimental error sources. Measurement Science and Technology, 36(1), 015303. https://doi.org/10.1088/1361-6501/ad8be8';
	paperstring7='Paper tbd: PSV code by Godfrey K Gakingo from Dedan Kimathi University of Technology dkut.ac.ke';
	parentitem=get(handles.mainpanel, 'Position');
	item=[0 0 0 0];

	item=[0 item(2)+item(4) parentitem(3)/4*3 3];
	handles.paper1 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy1 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring1);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 3];
	handles.paper2 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring2,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy2 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring2);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 3];
	handles.paper3 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring3,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy3 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring3);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 3];
	handles.paper4 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring4,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy4 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring4);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 1.5];
	handles.headingwofv = uicontrol(handles.mainpanel,'Style','text','String','Wavelet-based optical flow velocimetry (wOFV)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','fontweight','bold');

	item=[0 item(2)+item(4)+margin/8 parentitem(3)/4*3 3];
	handles.paper5 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring5,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy5 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring5);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 3];
	handles.paper6 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring6,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy6 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring6);

	item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*3 1.5];
	handles.headingpsv = uicontrol(handles.mainpanel,'Style','text','String','Particle streak velocimetry (PSV)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','fontweight','bold');

	item=[0 item(2)+item(4)+margin/8 parentitem(3)/4*3 3];
	handles.paper7 = uicontrol(handles.mainpanel,'Style','edit','String',paperstring7,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'HorizontalAlignment','left','Max',50,'Min',1);
	item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 3];
	handles.copy7 = uicontrol(handles.mainpanel,'Style','pushbutton','String','Copy','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@copy_clip,'tag',paperstring7);



else %Figure handle does already exist --> bring UI to foreground.
	figure(fh)
end

function copy_clip(caller,~,~)
clipboard('copy', caller.Tag)
