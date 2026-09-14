function T = PIVlab_capture_OPTOcam_20_9_timing(bitmode,interframe,laser_energy)
%PIVlab_capture_OPTOcam_20_9_timing  Single source of truth for the OPTOcam 20/9 double-frame timing.
%
%   T = PIVlab_capture_OPTOcam_20_9_timing(bitmode,interframe,laser_energy)
%
%   bitmode      8 or 12 (12 = Mono12packed)
%   interframe   requested laser pulse distance (start to start) [us]
%   laser_energy laser energy in percent (defines the pulse length, PIVlab convention)
%
%   All constants below were MEASURED on the rig: Line0 = ExposureActive, Line4 = trigger.
%
%   Timing model
%   ------------
%   One trigger makes the sensor expose the complete image pair:
%
%       frame 1 = [D , D+E1]  ->  gap  ->  frame 2 = [D+E1+gap , D+E1+gap+E2]
%
%   The trigger delay D is NOT constant (it varies between D_min and D_max) and shifts BOTH
%   frames together. E1 and the gap jitter as well (E1: +E1_jitter, gap: gap..gap_max).
%   Only these windows are therefore guaranteed for every possible combination:
%
%       pulse 1 : [D_max                             , D_min + E1                ]
%       pulse 2 : [D_max + E1 + E1_jitter + gap_max  , D_min + E1 + gap + E2_min ]
%
%   Laser pulse 1 is placed at the END of its window, which gives the shortest reachable
%   pulse distance:   min pulse distance = jitter + E1_jitter + gap_max + pulse length.
%
%   The frame-1 exposure is quantised by the camera. Measured behaviour:
%       E1 = E1_floor + step * ceil((ExposureTime - thr)/step)      (E1 = E1_floor below thr)
%   To make the predicted E1 reliable, the ExposureTime is placed in the MIDDLE of the
%   plateau that produces the wanted E1, so it can never fall onto a quantisation step.

if isempty(bitmode)
	bitmode = 8;    %PIVlab default for this camera
end

%% measured constants
%gap ("blind time") between frame 1 and frame 2, n = 1000: min 1.99 / max 3.00 / mean 2.05 us
T.gap      = 2;                 %shortest gap [us]
T.gap_max  = 3;                 %longest gap [us]
%frame-1 exposure on the lowest plateau, n = 500 (8 and 12 bit): min 123 / max 124 / mean 123.1 us
T.E1_floor  = 123;              %shortest frame-1 exposure [us] (used for the earliest end of frame 1)
T.E1_jitter = 1;                %the exposure can be up to this much longer (delays the start of frame 2)
if bitmode == 8                 %Mono8
	%D: trigger rising edge -> ExposureActive rising edge, n = 1000 pairs, full frame:
	%min 9.06 / max 19.65 / mean 14.71 / std 2.89 us -> uniform over one sensor row (~10.3 us).
	%E2 (frame-2 exposure) measured 4740..4940 us -> the shortest value limits the pulse distance.
	T.D_min = 9;    T.D_max = 19.7;   T.E2_min = 4740;   T.expo_step = 41.2;   T.expo_thr = 113.5;
else                            %Mono12packed
	%D, n = 1000 pairs, full frame: min 9.02 / max 22.7 / mean 15.88 / std 3.55 us (longer row period than Mono8).
	%E2 measured 5670..5870 us.
	T.D_min = 9;    T.D_max = 22.7;   T.E2_min = 5670;   T.expo_step = 49.2;   T.expo_thr = 110.5;
end
T.expo_set_min = 7;             %smallest settable ExposureTime [us]
T.expo_set_max = 2522;          %largest settable ExposureTime [us]
T.jitter = T.D_max - T.D_min;   %uncertainty of the trigger delay [us]
T.margin = 3;                   %safety margin for the frame-1 exposure choice [us]
T.tolerance = 0;                %how far a laser pulse edge may poke out of its guaranteed window [us].
                                %0 = strict (every pulse fits for every possible trigger delay). The
                                %edges are whole microseconds, so a fraction of a us is lost to the grid;
                                %a tolerance of e.g. 0.5 gives that fraction back (a pulse may then overlap
                                %the frame edge by up to 0.5 us in the rare extreme-delay cases).

%% laser pulse length (PIVlab convention: a percentage of the pulse distance)
%The synchronizer works in whole microseconds, so the pulse length and all pulse edges below
%are integers: what the GUI displays is exactly what is sent to the synchronizer.
interframe = round(interframe);
T.laser_period_requested = interframe*laser_energy/100;
%Both pulses must sit completely inside their own frame, so the off-time between pulse 1 and
%pulse 2 can never be shorter than jitter + E1_jitter + gap_max. Limit the pulse length accordingly
%(continuous value here, used to choose the frame-1 exposure; the integer value follows below).
T.min_off_time = T.jitter + T.E1_jitter + T.gap_max;
laser_period_cont = max(0, min(T.laser_period_requested, interframe - T.min_off_time));
%Pulse 1 must also fit into the LONGEST frame-1 exposure the camera can be set to
%(ExposureTime <= expo_set_max, i.e. the highest quantisation plateau that is still reachable).
n_max = ceil((T.expo_set_max - T.expo_thr)/T.expo_step);
T.E1_max = T.E1_floor + n_max*T.expo_step;
laser_period_cont = min(laser_period_cont, T.E1_max - T.jitter - T.margin);

%% allowed pulse distance range
%Physically, pulse 2 must still fit into the shortest frame 2 (E2_min - margin = 4737 us Mono8 /
%5667 us Mono12p). The data sheet states a "clean" 4500 us for both bit modes, so that is the limit.
T.max_interframe = min(T.E2_min - T.margin, 4500);

%% lower bound offered in the GUI (informational only, NOT used by the calculations here)
%"clean" data-sheet numbers above the physical floor jitter+E1_jitter+gap_max (14.7 us Mono8 / 17.7 us Mono12p)
if bitmode == 8
	T.min_interframe_gui = 20;
else
	T.min_interframe_gui = 30;
end

%% frame-1 exposure: long enough that laser pulse 1 fits into it
E1_required = T.jitter + laser_period_cont + T.margin;
n = max(0, ceil((E1_required - T.E1_floor)/T.expo_step));  %quantisation step index
T.E1 = T.E1_floor + n*T.expo_step;                         %resulting frame-1 exposure [us]
if n == 0
	T.exposure_set = 60;                                   %safely inside the floor plateau
else
	T.exposure_set = T.expo_thr + (n-0.5)*T.expo_step;     %middle of the plateau giving this E1
end
T.exposure_set = max(T.expo_set_min, min(T.expo_set_max, T.exposure_set));

%% pulse placement, t = 0 is the rising edge of the camera trigger (Line4); whole microseconds
%pulse 1 ends at (or, with tolerance, just after) the earliest possible end of frame 1
T.pulse1_off = floor(T.D_min + T.E1 + T.tolerance);
%pulse 2 = pulse 1 + interframe must not start before the latest possible start of frame 2
%(latest trigger delay, longest frame-1 exposure, longest gap): this caps the integer pulse
%length (the fraction lost to the us grid is included here)
T.frame2_start_max = T.D_max + T.E1 + T.E1_jitter + T.gap_max;
laser_period_max = T.pulse1_off + interframe - T.frame2_start_max + T.tolerance;
laser_period_max = min(laser_period_max, T.pulse1_off - T.D_max + T.tolerance); %pulse 1 must not start before the latest frame-1 start
T.laser_period = max(0, min(round(T.laser_period_requested), floor(laser_period_max)));
T.pulse1_on  = T.pulse1_off - T.laser_period;
T.pulse2_on  = T.pulse1_on + interframe;    %pulse 2 one pulse distance later
T.pulse2_off = T.pulse2_on + T.laser_period;
%true when the requested pulse had to be shortened (-> less laser energy than requested)
T.pulse_was_limited = T.laser_period < T.laser_period_requested - 0.5;
T.min_interframe = T.min_off_time + T.laser_period;   %shortest pulse distance for this pulse length
