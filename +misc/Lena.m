function Lena
MainWindow=getappdata(0,'hgui');
today_dt=datetime('today');
if month(today_dt)==10 && day(today_dt)==15
	since=year(today_dt)-2005;
	gui.custom_msgbox('quest',getappdata(0,'hgui'),'It''s 15th of October!',['Loving Lena since ' num2str(since) ' years today!'],'modal',{'Congratulations!'},'Congratulations!');
	set(MainWindow, 'Name','Today it''s Lena-day!!')
end

