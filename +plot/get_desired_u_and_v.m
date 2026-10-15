function [x, y, u, v, typevector, w] = get_desired_u_and_v(resultslist, currentframe)
% The velocities of the frame that the display uses: smoothed if present, else filtered, else raw.
% currentframe is the image number (frame = (currentframe+1)/2). Stereo-PIV: w = out-of-plane
% component of the same kind (smoothed W with smoothed u, v; stereo.w_of_frame), [] in 2D.
smoothed=false;
x=resultslist{1,(currentframe+1)/2};
y=resultslist{2,(currentframe+1)/2};
if size(resultslist,1)>6 %filtered exists
	if size(resultslist,1)>10 && numel(resultslist{10,(currentframe+1)/2}) > 0 %smoothed exists
		u=resultslist{10,(currentframe+1)/2};
		v=resultslist{11,(currentframe+1)/2};
		typevector=resultslist{9,(currentframe+1)/2};
		smoothed=true;
		%text(3,size(currentimage,1)-4, 'Smoothed dataset','tag', 'smoothhint', 'backgroundcolor', 'k', 'color', 'y','fontsize',6);
		if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
			typevector=resultslist{5,(currentframe+1)/2};
		end
	else
		u=resultslist{7,(currentframe+1)/2};
		if size(u,1)>1
			v=resultslist{8,(currentframe+1)/2};
			typevector=resultslist{9,(currentframe+1)/2};
		else %filter was applied for other frames but not for this one
			u=resultslist{3,(currentframe+1)/2};
			v=resultslist{4,(currentframe+1)/2};
			typevector=resultslist{5,(currentframe+1)/2};
		end
	end
else
	u=resultslist{3,(currentframe+1)/2};
	v=resultslist{4,(currentframe+1)/2};
	typevector=resultslist{5,(currentframe+1)/2};
end
if nargout>5
	w=stereo.w_of_frame((currentframe+1)/2,smoothed);
end
