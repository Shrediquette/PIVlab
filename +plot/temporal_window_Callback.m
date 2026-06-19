function temporal_window_Callback(hObject, ~, ~)
% Normalize the temporal window to the value that is actually used: a positive integer.
% The value is the number of neighbouring frames averaged on EACH side of the current
% frame (half-width), so e.g. "1" averages the current frame with the previous and next
% one. The edit box is updated to show this rounded value.
h=round(str2double(get(hObject,'String')));
if isnan(h) || h<1
	h=2; %fall back to the default for empty/invalid input
end
set(hObject,'String',num2str(h));

end
