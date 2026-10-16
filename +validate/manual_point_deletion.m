function [u,v,typevector,u2,v2]=manual_point_deletion(u,v,typevector,framemanualdeletion,u2,v2)
%Removes the vectors deleted by hand (rows / columns in framemanualdeletion). Their second correlation
%peak (u2, v2, optional) is removed too: a vector deleted by hand stays deleted (only the gap is filled).
if nargin<5
	u2=[]; v2=[];
end
manualdeletion=gui.retr('manualdeletion');
if numel(manualdeletion)>0
	if numel(u)>0
		for i=1:size(framemanualdeletion,1)
			u(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
			v(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
			if isequal(size(u2),size(u))
				u2(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
				v2(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
			end
		end
		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
	end
end
