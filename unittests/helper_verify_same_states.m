function helper_verify_same_states(testCase, A, B, what)
%HELPER_VERIFY_SAME_STATES Two sets of Enable / Visible states (helper_states) are the same.
f = fieldnames(A);
different = {};
for k = 1:numel(f)
    if ~isfield(B, f{k}) || ~strcmp(A.(f{k}), B.(f{k}))
        b = '(missing)';
        if isfield(B, f{k})
            b = B.(f{k});
        end
        different{end+1} = sprintf('%s: %s -> %s', f{k}, A.(f{k}), b); %#ok<AGROW>
    end
end
testCase.verifyEmpty(different, sprintf('Enable/Visible differ %s:\n%s', what, strjoin(different, newline)));
end
