function PIVlab_capture_lensctrl (focus, aperture,lighting)
%focus and aperture are PWM servo pulse width in us. must be between 500 and 2500

hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
[focus, aperture] = validate_pulselenghts(focus, aperture);
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	configureTerminator(serpo,'CR/LF');
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end

if alreadyconnected==1
	flush(serpo)
	line_to_write=['FOCUS:' num2str(focus) ';APERTURE:' num2str(aperture) ';LIGHTING:' num2str(lighting)];
	writeline(serpo,line_to_write);
	%disp(['Setting focus: ' num2str(focus) ' us, aperture: ' num2str(aperture) ' us, light: ' num2str(lighting)])
else 
	%disp(['Not connected. Focus: ' num2str(focus) ' us, aperture: ' num2str(aperture) ' us, light: ' num2str(lighting)])
end
setappdata(hgui,'focus',focus);
setappdata(hgui,'aperture',aperture);
setappdata(hgui,'lighting',lighting);

function [focus_out, aperture_out] = validate_pulselenghts(focus_in, aperture_in)
focus_out=focus_in;
aperture_out=aperture_in;
if focus_out > retr('focus_servo_upper_limit')
	focus_out =retr('focus_servo_upper_limit');
end
if focus_out < retr('focus_servo_lower_limit')
	focus_out =retr('focus_servo_lower_limit');
end

if aperture_out > retr('aperture_servo_upper_limit')
	aperture_out =retr('aperture_servo_upper_limit');
end
if aperture_out < retr('aperture_servo_lower_limit')
	aperture_out =retr('aperture_servo_lower_limit');
end

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);