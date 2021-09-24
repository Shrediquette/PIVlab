function PIVlab_capture_lensctrl (focus, aperture,lighting)
%focus and aperture are PWM servo pulse width in us. must be between 500 and 2500

hgui = getappdata(0,'hgui');
serpo=getappdata(hgui,'serpo');
try
	serpo.Port; %is there no other way to determine if serialport is working...?
	alreadyconnected=1;
catch
	alreadyconnected=0;
	delete(serpo)
end

if alreadyconnected==1
	flush(serpo)
	writeline(serpo,['FOCUS:' num2str(focus) ';APERTURE:' num2str(aperture) ';LIGHTING:' num2str(lighting)]);
	disp(['Setting focus: ' num2str(focus) ' us, aperture: ' num2str(aperture) ' us, light: ' num2str(lighting)])
else 
	disp(['No connection to serial port. Focus: ' num2str(focus) ' us, aperture: ' num2str(aperture) ' us, light: ' num2str(lighting)])
end
setappdata(hgui,'focus',focus);
setappdata(hgui,'aperture',aperture);
setappdata(hgui,'lighting',lighting);

