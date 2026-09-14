function [frame_time, pin_string] = low_energy_sequence()
%LOW_ENERGY_SEQUENCE Fixed oltSync string for the low energy / alignment mode.
%   In low energy mode the laser is decoupled from the camera, so no camera
%   timing is computed or sent. The synchronizer receives a fixed sequence
%   that pulses only the laser at 100 Hz with the shortest valid pulse (1 us),
%   producing the lowest possible, non-flickering beam for beam alignment.
%
%   frame_time : 10000 us  -> 100 Hz repetition rate
%   pin_string : ':10,11'  -> pin1 (camera) EMPTY ; pin2 (laser) = 1 us pulse
%
%   The assembled command looks like: ...:sequence:10000:0,0::10,11
%   The empty camera pin is accepted by the firmware because at least one pin
%   (the laser pin) has entries. Validate with acquisition.validate_oltsync_sequence.

frame_time = 10000;      % 100 Hz (1/100 s = 10000 us)
pin_string = ':10,11';   % pin1 (camera) empty ; pin2 (laser) 1 us pulse at 10-11 us
