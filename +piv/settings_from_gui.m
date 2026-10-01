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
s.highp=get(handles.enable_highpass,'value');
s.highpsize=str2double(get(handles.highp_size, 'string'));
s.intenscap=get(handles.enable_intenscap, 'value');
s.wienerwurst=get(handles.wienerwurst, 'value');
s.wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
s.autolimit=get(handles.Autolimit, 'value');
s.minintens=str2double(get(handles.minintens, 'string'));
s.maxintens=str2double(get(handles.maxintens, 'string'));
s.roirect=gui.retr('roirect');
% PIV
s.interrogationarea=str2double(get(handles.intarea, 'string'));
s.step=str2double(get(handles.step, 'string'));
s.subpixfinder=get(handles.subpix,'value');
s.passes=1;
if get(handles.checkbox26,'value')==1
    s.passes=2;
end
if get(handles.checkbox27,'value')==1
    s.passes=3;
end
if get(handles.checkbox28,'value')==1
    s.passes=4;
end
s.int2=str2num(get(handles.edit50,'string')); %#ok<ST2NM>
s.int3=str2num(get(handles.edit51,'string')); %#ok<ST2NM>
s.int4=str2num(get(handles.edit52,'string')); %#ok<ST2NM>
s.mask_auto = get(handles.mask_auto_box,'value');
s.corr_quality = get(handles.CorrQuality,'Value');
[s.imdeform, s.repeat, s.do_pad] = piv.corr_quality_params(s.corr_quality);
s.repeat_last_pass = get(handles.repeat_last,'Value');
s.delta_diff_min = str2double(get(handles.edit52x,'String'));
s.compute_uncertainty = get(handles.checkbox_uncertainty,'Value');
s.do_correlation_matrices = 0;
end
