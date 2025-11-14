%gui.custom_msgbox('msg',getappdata(0,'hgui'),'Title','Message','modal',{'Btn1','Btn2'},'Btn1');
%gui.custom_msgbox('error',getappdata(0,'hgui'),'Title','Message','modal');
function answer=custom_msgbox(type,target,windowtitle,message,modal,options,default)
debug=0;
%% Todo: evtl uiwait einbauen wenn modal...?
if verLessThan('matlab','25') || debug == 1 %Matlab < 2025
    switch type
        case 'msg'
            answer=msgbox(message,windowtitle,modal);
        case 'warn'
            answer=warndlg(message,windowtitle,modal);
        case 'error'
            answer=errordlg(message,windowtitle,modal);
        case 'success'
            answer=msgbox(message,windowtitle,modal);
        case 'quest'
			numel(options)
			if numel (options) == 2
				answer = questdlg(message, windowtitle, options{1},options{2},default);
			elseif numel (options) == 1
				answer = questdlg(message, windowtitle, options{1},default);
			elseif numel (options) == 3
				answer = questdlg(message, windowtitle, options{1},options{2},options{3},default);
			end
		otherwise
			answer=[];
            disp('type not supported');
    end
end
if ~verLessThan('matlab','25') || debug == 1 %Matlab >=2025
    if  exist(fullfile('images','appicon.png'),'file') == 2
    else
        [filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
        cd (filepath); %if current directory is not where PIVlab_GUI.m is located, then change directory.
    end
    imgpath=fullfile('images','appicon.png');
    switch type
        case {'msg' 'quest'} %has ok + cancel as default
            answer=uiconfirm (target,message,windowtitle,'icon',imgpath,'Options',options,'DefaultOption',default);
        case 'warn' %only has 'OK'
            uialert(target,message,windowtitle,'icon','warning');
            answer=[];
        case 'error' %only has OK
            uialert(target,message,windowtitle,'icon','error');
            answer=[];
        case 'success' %only has OK
            uialert(target,message,windowtitle,'icon','success');
            answer=[];
        otherwise
            disp('type not supported');
            answer=[];
    end
end