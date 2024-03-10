function misc_Lena
MainWindow=getappdata(0,'hgui');
if strncmp (char(datetime('today')),'15-Oct',6)
	yr=char(datetime('today'));
	since=str2num(yr(8:11))-2005;
	questdlg(['Loving Lena since ' num2str(since) ' years today!'],'It''s 15th of October!','Congratulations!','Congratulations!'); % #FallsNochRelevant
	set(MainWindow, 'Name','Today it''s Lena-day!!')
end
