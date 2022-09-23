% Advertisment for PIVlab hardware (can be disabled, will only show if you didn't connect to your hardware)
function hardware_Ad(~)
fig_handle = figure('MenuBar','none', 'Toolbar','none', 'Units','characters', 'Name','Hardware for PIVlab','numbertitle','off','Visible','off','Windowstyle','modal','resize','off','dockcontrol','off');

%% Initialize
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(fig_handle,handles)
movegui(fig_handle,'center')
set(fig_handle, 'Visible','on');

margin=1;
parentitem=get(fig_handle, 'Position');
item=[0 0 0 0];


item=[0 item(2)+item(4) parentitem(3) 2];
handles.text0 = uicontrol(fig_handle,'Style','text','units', 'characters','Fontweight','bold', 'Fontunits','points','Fontsize',12,'Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Did you know?');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text05 = uicontrol(fig_handle,'Style','text','units', 'characters', 'Fontweight','bold','Fontunits','points','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','PIVlab has it''s own set of LASERs, cameras and synchronizers!');

item=[0 item(2)+item(4) parentitem(3) 7];
handles.text1 = uicontrol(fig_handle,'Style','text','units', 'characters','Fontunits','points','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String',{'This allows you to control and perform a complete PIV experiment directly in PIVlab. It makes flow research super easy and quick.' 'Learn more about William''s low-cost hardware on the website of his company:'});
handles.text1.String = textwrap(handles.text1,handles.text1.String);

colf=get(gcf,'color');
colf_1=colf(1);
colf_2=colf(2);
colf_3=colf(3);

oldun=get(gcf,'units');
set(gcf,'units','pixels')
sz=get (gcf,'Position');
set(gcf,'units',oldun)

bgim=ones(200,sz(3),3);
bgim(:,:,1)=bgim(:,:,1)*colf_1;
bgim(:,:,2)=bgim(:,:,2)*colf_2;
bgim(:,:,3)=bgim(:,:,3)*colf_3;

item=[0 item(2)+item(4) parentitem(3) 3];
handles.vidsi = uicontrol(fig_handle,'Style','pushbutton','String','Watch Youtube video','CData',bgim,'Units','characters','Fontweight','bold', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Opens William''s video on YOUTUBE','Callback',@gotovideo);

item=[0 item(2)+item(4) parentitem(3) 3];
handles.websi = uicontrol(fig_handle,'Style','pushbutton','String','Visit www.optolution.com','CData',bgim,'Units','characters','Fontweight','bold', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Opens the website of OPTOLUTION.com','Callback',@gotowebsite);

item=[0 item(2)+item(4) parentitem(3) 1];
handles.websi = uicontrol(fig_handle,'Style','checkbox','String','Never in my life show this hint again','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Disable ad forever and ever','Callback',@disableAd);

item=[0 item(2)+item(4) parentitem(3) 13];
axes_handle=axes('Parent',fig_handle,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);
axis image;
set(gca,'ActivePositionProperty','outerposition','Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');
axis off
axes (axes_handle)
imshow(imread('hardware_Ad.jpg'));drawnow


	function gotowebsite(~,~)
		web('https://www.optolution.com/en/products/particle-image-velocimetry-piv/')
		pause(1)
		close(fig_handle)
	end

	function gotovideo(~,~)
		web('https://www.youtube.com/watch?v=54lOx2s2uBU')
		pause(1)
		close(fig_handle)
	end

	function disableAd(itm,~)
		if itm.Value ==1
			setpref('PIVlab_ad','enable_ad',0)
		else
			setpref('PIVlab_ad','enable_ad',1)
		end
	end
end