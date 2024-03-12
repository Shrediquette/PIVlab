function [x, y, u, v, typevector] = plot_get_desired_u_and_v(resultslist, currentframe)
x=resultslist{1,(currentframe+1)/2};
y=resultslist{2,(currentframe+1)/2};
if size(resultslist,1)>6 %filtered exists
	if size(resultslist,1)>10 && numel(resultslist{10,(currentframe+1)/2}) > 0 %smoothed exists
		u=resultslist{10,(currentframe+1)/2};
		v=resultslist{11,(currentframe+1)/2};
		typevector=resultslist{9,(currentframe+1)/2};
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

