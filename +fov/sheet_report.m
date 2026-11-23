function lines = sheet_report(calib)
%SHEET_REPORT Report of the light sheet position measured in the overlap of two combined cameras.
%   lines = fov.sheet_report(calib)
%   calib  fov.measure_sheet (calib.sheet); {} when the sheet was not measured
lines = {};
if ~isfield(calib, 'sheet') || isempty(calib.sheet)
    return
end
s = calib.sheet;
deg = char(176);
if s.offset >= 0
    side = 'behind the board';
else
    side = 'in front of the board';
end
lines{end + 1} = sprintf('Light sheet at the seam: %.2f mm %s, tilted %.2f%s along the overlap', abs(s.offset), side, s.tilt, deg);
if ~s.across_measured
    lines{end + 1} = 'Tilt across the overlap: not measurable in a narrow overlap, assumed 0';
end
lines{end + 1} = sprintf('Cameras at the seam: %.2f px rms (max %.2f) on the board, %.2f px rms (max %.2f) on the light sheet (%d image pairs)', ...
    s.history(1, 1), s.history(1, 2), s.history(end, 1), s.history(end, 2), numel(s.pairs));
if s.history(end, 1) > 0.5
    lines{end + 1} = ['Warning: the cameras still do not match well at the seam. Check the lens calibrations, the board ' ...
        'images (board moved?) and the particle images in the overlap.'];
end
end
