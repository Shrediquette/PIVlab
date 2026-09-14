function [ok, msg, detail] = validate_oltsync_sequence(frame_time, pin_string)
%VALIDATE_OLTSYNC_SEQUENCE Check an oltSync sequence against the firmware rules.
%   [ok, msg, detail] = validate_oltsync_sequence(frame_time, pin_string)
%   mirrors the PIVlab-SimpleSync firmware ParseSequence() checks so an invalid
%   sequence can be caught locally (with a clear message) instead of relying on
%   the device's round-trip 'Sequence:Error' reply.
%
%   Two messages are returned:
%     msg    - a plain-language, actionable message for the operator, phrased
%              around the three controls they actually have on the panel
%              (camera frame rate / fps, pulse distance, laser power). This is
%              what should be shown in the dialog.
%     detail - the technical reason (pin/edge details), meant for the command
%              window / debugging, not for the operator.
%
%   pin_string is colon-separated pins, each a comma-separated list of integer
%   microsecond edge times, e.g. '0,500:100,200,300,400'. pin1 = camera,
%   pin2 = laser. An empty pin (e.g. ':10,11') is allowed as long as at least
%   one pin carries edges.
%
%   A sequence is accepted iff:
%     - frame_time is non-zero
%     - at least one pin has edges
%     - each pin has an even number of edges (0 counts as even)
%     - edge times strictly increase within a pin (every pulse/gap >= 1 us)
%     - the largest edge time of each pin does not exceed frame_time
%     - the assembled sequence string is at least 15 characters long

ok = false;

% messages shown to the operator, keyed to the controls they can change
msg_no_timing   = ['No valid laser timing could be computed. ' ...
	'Check the camera frame rate (fps) and the pulse distance.'];
msg_pulse_short = ['The laser pulse would be too short to fire. ' ...
	'Increase the laser power, or increase the pulse distance.'];
msg_too_long    = ['The pulse timing does not fit within one camera frame. ' ...
	'Lower the camera frame rate (fps), or reduce the pulse distance.'];
msg_internal    = ['Unexpected timing error - the synchronizer sequence is ' ...
	'invalid. (Details in the command window.)'];

if isempty(frame_time) || frame_time == 0
	msg    = msg_no_timing;
	detail = 'Frame time is zero.';
	return
end

pins = strsplit(pin_string, ':', 'CollapseDelimiters', false);
any_entries = false;
for p = 1:numel(pins)
	pin = strtrim(pins{p});
	if isempty(pin)
		times = [];
	else
		parts = strsplit(pin, ',');
		times = zeros(1, numel(parts));
		for k = 1:numel(parts)
			v = str2double(parts{k});
			if isnan(v)
				msg    = msg_internal;
				detail = sprintf('Pin %d contains a non-numeric value.', p);
				return
			end
			times(k) = v;
		end
	end

	% each pin must have an even number of edges (0 is even)
	if mod(numel(times), 2) ~= 0
		msg    = msg_internal;
		detail = sprintf('Pin %d has an odd number of edges.', p);
		return
	end

	if ~isempty(times)
		any_entries = true;
		% edge times must strictly increase -> every pulse and gap is >= 1 us
		if any(diff(times) < 1)
			msg    = msg_pulse_short;
			detail = sprintf('Pin %d: pulse or gap shorter than 1 us (edge times must strictly increase).', p);
			return
		end
		% the largest edge time must not exceed the frame period
		if max(times) > frame_time
			msg    = msg_too_long;
			detail = sprintf('Pin %d: pulse extends beyond the frame period (%d us).', p, frame_time);
			return
		end
	end
end

if ~any_entries
	msg    = msg_no_timing;
	detail = 'No pulses defined on any pin.';
	return
end

seq = ['sequence:' int2str(frame_time) ':0,0:' pin_string];
if numel(seq) < 15
	msg    = msg_internal;
	detail = 'Sequence string is too short.';
	return
end

ok     = true;
msg    = '';
detail = '';
