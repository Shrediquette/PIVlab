function s = settings_from_gui(handles)
%SETTINGS_FROM_GUI Collect the pre-processing and PIV settings from the PIVlab GUI controls.
%   s = piv.settings_from_gui(handles) returns the settings struct used by piv.analyze_pair.
if nargin < 1
    handles=gui.gethand;
end
algorithms = {'fft','ensemble','dcc','ofv'};
s.algorithm = algorithms{get(handles.algorithm_selection,'Value')};
% pre-processing
s.clahe=get(handles.clahe_enable,'value');
s.clahesize=str2double(get(handles.clahe_size, 'string'));
s.highp=get(handles.highpass_enable,'value');
s.highpsize=str2double(get(handles.highpass_size, 'string'));
s.intenscap=get(handles.intenscap_enable, 'value');
s.wienerwurst=get(handles.wiener_enable, 'value');
s.wienerwurstsize=str2double(get(handles.wiener_size, 'string'));
s.autolimit=get(handles.autolimit_enable, 'value');
s.minintens=str2double(get(handles.minintens, 'string'));
s.maxintens=str2double(get(handles.maxintens, 'string'));
s.roirect=gui.retr('roirect');
% PIV
s.interrogationarea=str2double(get(handles.pass1_size, 'string'));
s.step=str2double(get(handles.pass1_step, 'string'));
s.subpixfinder=get(handles.subpixel_estimator,'value');
s.passes=1;
if get(handles.pass2_enable,'value')==1
    s.passes=2;
end
if get(handles.pass3_enable,'value')==1
    s.passes=3;
end
if get(handles.pass4_enable,'value')==1
    s.passes=4;
end
s.int2=str2num(get(handles.pass2_size,'string')); %#ok<ST2NM>
s.int3=str2num(get(handles.pass3_size,'string')); %#ok<ST2NM>
s.int4=str2num(get(handles.pass4_size,'string')); %#ok<ST2NM>
s.mask_auto = get(handles.disable_autocorrelation,'value');
s.corr_quality = get(handles.correlation_robustness,'Value');
[s.imdeform, s.repeat, s.do_pad] = piv.corr_quality_params(s.corr_quality);
s.repeat_last_pass = get(handles.repeat_last_enable,'Value');
s.delta_diff_min = str2double(get(handles.repeat_last_threshold,'String'));
s.compute_uncertainty = get(handles.uncertainty_enable,'Value');
s.do_correlation_matrices = 0;
end
