function misc_check_comma(who)
boxcontent=get(who,'String');% returns contents of time_inp as text
s = regexprep(boxcontent, ',', '.');
set(who,'String',s);

