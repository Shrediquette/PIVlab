%% Tests of the oltSync sequence check (no GUI, no hardware)
%
% acquisition.validate_oltsync_sequence mirrors the acceptance rules of ParseSequence() in the
% PIVlab-SimpleSync firmware; acquisition.low_energy_sequence gives the fixed low energy string.
%
% Run with:
%   runtests('unittests/test_acq_oltsync_sequence.m')

function tests = test_acq_oltsync_sequence
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(helper_root());
end

% -------------------------------------------------------------------------

function test_low_energy_sequence(testCase)
[frame_time, pin_string] = acquisition.low_energy_sequence();
testCase.verifyEqual(frame_time, 10000);
testCase.verifyEqual(pin_string, ':10,11');
verify_sequence(testCase, frame_time, pin_string, true, 'low energy laser-only string');
end

function test_valid_sequences(testCase)
verify_sequence(testCase, 40000, '0,500:100,200,300,400', true, 'normal camera + laser sequence');
verify_sequence(testCase, 20000, ':10,11', true, 'empty camera pin, valid laser pin');
end

function test_invalid_sequences(testCase)
verify_sequence(testCase, 0, ':10,11', false, 'frame time zero');
verify_sequence(testCase, 40000, '0,500,700:100,200', false, 'odd number of edges on a pin');
verify_sequence(testCase, 20000, ':10,10', false, 'equal edges (pulse shorter than 1 us)');
verify_sequence(testCase, 20000, ':11,10', false, 'decreasing edges');
verify_sequence(testCase, 20000, ':0,25000', false, 'edge time exceeds frame time');
verify_sequence(testCase, 20000, ':', false, 'both pins empty');
verify_sequence(testCase, 20000, ':0,abc', false, 'non-numeric edge');
end

function test_messages_for_the_operator(testCase)
% msg = what the operator can do, detail = technical; msg never shows the internal "Pin N" wording
[ok, msg] = acquisition.validate_oltsync_sequence(20000, ':10,10');
testCase.verifyFalse(ok);
testCase.verifySubstring(lower(msg), 'laser power', 'pulse too short: hint to laser power / pulse distance');
[ok, msg] = acquisition.validate_oltsync_sequence(20000, ':0,25000');
testCase.verifyFalse(ok);
testCase.verifySubstring(lower(msg), 'frame rate', 'pulse beyond the frame: hint to the frame rate');
testCase.verifyFalse(contains(msg, 'Pin'), 'jargon in the message (overrun)');
[ok, msg] = acquisition.validate_oltsync_sequence(40000, '0,500,700:100,200');
testCase.verifyFalse(ok);
testCase.verifyFalse(contains(msg, 'Pin'), 'jargon in the message (odd number of edges)');
end

% -------------------------------------------------------------------------

function verify_sequence(testCase, frame_time, pin_string, expected_ok, what)
% a rejected sequence carries a message and a technical detail, an accepted one neither
[ok, msg, detail] = acquisition.validate_oltsync_sequence(frame_time, pin_string);
testCase.verifyEqual(logical(ok), expected_ok, what);
if ok
    testCase.verifyEmpty(msg, [what ': message of an accepted sequence']);
    testCase.verifyEmpty(detail, [what ': detail of an accepted sequence']);
else
    testCase.verifyNotEmpty(msg, [what ': no message']);
    testCase.verifyNotEmpty(detail, [what ': no detail']);
end
end
