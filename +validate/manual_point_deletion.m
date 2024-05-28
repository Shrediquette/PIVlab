function [u,v,typevector]=manual_point_deletion(u,v,typevector,framemanualdeletion)
manualdeletion=gui.gui_retr('manualdeletion');
if numel(manualdeletion)>0
	if numel(u)>0
		for i=1:size(framemanualdeletion,1)
			u(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
			v(framemanualdeletion(i,1),framemanualdeletion(i,2))=NaN;
		end
		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
	end
end

