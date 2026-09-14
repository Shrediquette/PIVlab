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
%       frame 1 = [D , D+E1]  ->  gap (2 us)  ->  frame 2 = [D+E1+gap , D+E1+gap+E2]
%
%   The trigger delay D is NOT constant (it varies between D_min and D_max) and shifts BOTH
%   frames together. Only these windows are therefore guaranteed for every possible D:
%
%       pulse 1 : [D_max            , D_min + E1            ]
%       pulse 2 : [D_max + E1 + gap , D_min + E1 + gap + E2 ]
%
%   Laser pulse 1 is placed at the END of its window, which gives the shortest reachable
%   pulse distance:   min pulse distance = jitter + gap + pulse length.
%
%   The frame-1 exposure is quantised by the camera. Measured behaviour:
%       E1 = E1_floor + step * ceil((ExposureTime - thr)/step)      (E1 = E1_floor below thr)
%   To make the predicted E1 reliable, the ExposureTime is placed in the MIDDLE of the
%   plateau that produces the wanted E1, so it can never fall onto a quantisation step.

if isempty(bitmode)
	bitmode = 12;
end

%% measured constants
T.gap      = 2;                 %gap ("blind time") between frame 1 and frame 2 [us], constant
T.E1_floor = 123.5;             %smallest achievable frame-1 exposure [us]
if bitmode == 8                 %Mono8
	T.D_min = 9;    T.D_max = 20.7;   T.E2 = 4840;   T.expo_step = 41.2;   T.expo_thr = 113.5;
else                            %Mono12packed
	T.D_min = 9;    T.D_max = 22.7;   T.E2 = 5770;   T.expo_step = 49.2;   T.expo_thr = 110.5;
end
T.expo_set_min = 7;             %smallest settable ExposureTime [us]
T.expo_set_max = 2522;          %largest settable ExposureTime [us]
T.jitter = T.D_max - T.D_min;   %uncertainty of the trigger delay [us]
T.margin = 3;                   %small safety margin [us]

%% laser pulse length (PIVlab convention: a percentage of the pulse distance)
T.laser_period_requested = interframe*laser_energy/100;
T.laser_period = T.laser_period_requested;
%Both pulses must sit completely inside their own frame, so the off-time between pulse 1 and
%pulse 2 can never be shorter than jitter+gap. Limit the pulse length accordingly.
T.min_off_time = T.jitter + T.gap;
if T.laser_period > interframe - T.min_off_time
	T.laser_period = max(0, interframe - T.min_off_time);
end
%true when the requested pulse had to be shortened (-> less laser energy than requested)
T.pulse_was_limited = T.laser_period < T.laser_period_requested - 1e-9;

%% allowed pulse distance range
T.min_interframe = T.min_off_time + T.laser_period;   %shortest possible pulse distance
T.max_interframe = T.E2 - T.margin;                   %pulse 2 must still fit into frame 2

%% frame-1 exposure: long enough that laser pulse 1 fits into it
E1_required = T.jitter + T.laser_period + T.margin;
n = max(0, ceil((E1_required - T.E1_floor)/T.expo_step));  %quantisation step index
T.E1 = T.E1_floor + n*T.expo_step;                         %resulting frame-1 exposure [us]
if n == 0
	T.exposure_set = 60;                                   %safely inside the floor plateau
else
	T.exposure_set = T.expo_thr + (n-0.5)*T.expo_step;     %middle of the plateau giving this E1
end
T.exposure_set = max(T.expo_set_min, min(T.expo_set_max, T.exposure_set));

%% pulse placement, t = 0 is the rising edge of the camera trigger (Line4)
T.pulse1_off = T.D_min + T.E1;              %pulse 1 ends at the (earliest) end of frame 1
T.pulse1_on  = T.pulse1_off - T.laser_period;
T.pulse2_on  = T.pulse1_on + interframe;    %pulse 2 one pulse distance later
T.pulse2_off = T.pulse2_on + T.laser_period;
