function st = stereo_settings(S, given)
%STEREO_SETTINGS stereo.defaults with the values of the Stereo-PIV panel (settings group stereo) and the
%expert settings given (pivlab.stereo, pivlab.loadSession).
if nargin < 2
    given = struct();
end
st = stereo.defaults();
if isfield(S, 'stereo') && isstruct(S.stereo)
    names = fieldnames(S.stereo);
    for n = 1:numel(names)
        if isfield(st.disparity, names{n})
            st.disparity.(names{n}) = S.stereo.(names{n});
        end
    end
end
st.Parallel = false;
if isfield(S, 'analysis') && isfield(S.analysis, 'Parallel') && ~isempty(S.analysis.Parallel)
    st.Parallel = logical(S.analysis.Parallel);
end
names = fieldnames(given);
for n = 1:numel(names)
    if ~isfield(st, names{n})
        error('pivlab:stereo:settings', 'Unknown stereo setting "%s".', names{n});
    end
    if isstruct(given.(names{n}))
        fields = fieldnames(given.(names{n}));
        for f = 1:numel(fields)
            if ~isfield(st.(names{n}), fields{f})
                error('pivlab:stereo:settings', 'Unknown stereo setting "%s.%s".', names{n}, fields{f});
            end
            st.(names{n}).(fields{f}) = given.(names{n}).(fields{f});
        end
    else
        st.(names{n}) = given.(names{n});
    end
end
end
