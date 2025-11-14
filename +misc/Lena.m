function Lena
MainWindow=getappdata(0,'hgui');
if strncmp (char(datetime('today')),'15-Oct',6)
	yr=char(datetime('today'));
	since=str2num(yr(8:11))-2005;
	gui.custom_msgbox('quest',getappdata(0,'hgui'),'It''s 15th of October!',['Loving Lena since ' num2str(since) ' years today!'],'modal',{'Congratulations!'},'Congratulations!');
	set(MainWindow, 'Name','Today it''s Lena-day!!')
end

