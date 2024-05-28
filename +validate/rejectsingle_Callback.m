function rejectsingle_Callback(~, ~, ~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame %2nd dimesnion = frame
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	typevector_original=resultslist{5,frame};
	typevector=typevector_original;
	manualdeletion=gui.retr('manualdeletion');
	framemanualdeletion=[];
	if numel(manualdeletion)>0
		if size(manualdeletion,2)>=frame
			if isempty(manualdeletion{1,frame}) ==0
				framemanualdeletion=manualdeletion{frame};
			end
		end
	end

	if numel(u)>0
		delete(findobj(gca,'tag','manualdot'));
		text(50,10,'Right mouse button exits manual validation mode.','color','g','fontsize',8, 'BackgroundColor', 'k', 'tag', 'hint')
		gui.toolsavailable(0);
		button = 1;
		while button == 1
			[xposition,yposition,button] = ginput(1);
			if button~=1
				break
			end
			if numel (xposition)>0 %will be 0 if user presses enter
				xposition=round(xposition);
				yposition=round(yposition);
				%manualdeletion=zeros(size(xposition,1),2);
				findx=abs(x/xposition-1);
				[trash, imagex]=find(findx==min(min(findx)));
				findy=abs(y/yposition-1);
				[imagey, trash]=find(findy==min(min(findy)));
				idx=size(framemanualdeletion,1);
				%manualdeletion(idx+1,1)=imagey(1,1);
				%manualdeletion(idx+1,2)=imagex(1,1);

				framemanualdeletion(idx+1,1)=imagey(1,1); %#ok<AGROW>
				framemanualdeletion(idx+1,2)=imagex(1,1); %#ok<AGROW>

				hold on;
				plot (x(framemanualdeletion(idx+1,1),framemanualdeletion(idx+1,2)),y(framemanualdeletion(idx+1,1),framemanualdeletion(idx+1,2)), 'yo', 'markerfacecolor', 'r', 'markersize', 10,'tag','manualdot')
				hold off;
			end
		end
		manualdeletion{frame}=framemanualdeletion;
		gui.put('manualdeletion',manualdeletion);

		delete(findobj(gca,'Type','text','color','r'));
		delete(findobj(gca,'tag','hint'));
		text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',10, 'fontweight','bold', 'BackgroundColor', 'k')
	end
end
gui.toolsavailable(1);

