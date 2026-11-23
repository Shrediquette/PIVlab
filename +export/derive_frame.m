function derived=derive_frame(frame, ids)
%Calculates the derived parameters ids (plot.derivative_calc numbers) of one frame and returns the
%updated derived list (parameter id is in row id-1). The first calculation smooths the velocity
%like the display does (data smoothing settings); the others reuse that smoothed field instead of
%smoothing it again for every parameter (same result, see plot.derivative_calc use_smoothed).
for k=1:numel(ids)
	plot.derivative_calc(frame, ids(k), 1, k>1);
end
derived=gui.retr('derived');
