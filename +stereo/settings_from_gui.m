function st = settings_from_gui(handles)
%SETTINGS_FROM_GUI Stereo settings (stereo.defaults) with the values of the Stereo-PIV panel.
if nargin < 1
    handles = gui.gethand;
end
st = stereo.defaults();
models = stereo.disparity_models;
st.disparity.Pairs = number(handles.stereo_disp_pairs, st.disparity.Pairs);
st.disparity.Model = models(get(handles.stereo_disp_model, 'Value'));
st.disparity.Passes = max(1, round(number(handles.stereo_disp_passes, st.disparity.Passes)));
ia = number(handles.stereo_disp_ia, 0);
st.disparity.InterrogationArea = [];
if ia > 0
    st.disparity.InterrogationArea = round(ia / 2) * 2;
end
st.disparity.StdevThreshold = number(handles.stereo_disp_stdev, st.disparity.StdevThreshold);
st.disparity.LocalMedianThreshold = number(handles.stereo_disp_median, st.disparity.LocalMedianThreshold);
st.Parallel = isequal(gui.retr('parallel'), 1);
end

function v = number(control, default)
v = str2double(get(control, 'String'));
if isnan(v)
    v = default;
end
end
