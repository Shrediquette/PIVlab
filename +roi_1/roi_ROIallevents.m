function roi_ROIallevents(src,evt)
%src.Position = round(evt.CurrentPosition ,-1);
src.Position = floor(evt.CurrentPosition/8)*8;

if src.Position(1)<0.5
	src.Position(1) = 0.5;
end
if src.Position(2)<0.5
	src.Position(2) = 0.5;
end
evname = evt.EventName;
switch(evname)
	case{'MovingROI'}
		src.Label =([int2str(ceil(evt.PreviousPosition(1))) ' ' int2str(ceil(evt.PreviousPosition(2))) ' ' int2str(ceil(evt.PreviousPosition(3))) ' ' int2str(ceil(evt.PreviousPosition(4)))]);
	case{'ROIMoved'}
		src.Label =([int2str(ceil(evt.CurrentPosition(1))) ' ' int2str(ceil(evt.CurrentPosition(2))) ' ' int2str(ceil(evt.CurrentPosition(3))) ' ' int2str(ceil(evt.CurrentPosition(4)))]);
end

