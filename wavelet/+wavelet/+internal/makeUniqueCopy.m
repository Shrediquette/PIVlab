function newlabel = makeUniqueCopy(existlabels,copiedlabel)
% This function is for internal use only. It may change in a future
% release.
% newlabel = makeUniqueCopy(existlabels,copiedlabel);
%copynum = 1;
%pattern = strcat('Copy',num2str(copynum));

%   Copyright 2017-2020 The MathWorks, Inc.

pattern = 'Copy';
newlabel = strcat(copiedlabel,pattern);

tf = strcmp(newlabel,existlabels);
copynum = 1;
while any(tf)
    pattern = strcat('Copy',num2str(copynum));
    newlabel = strcat(copiedlabel,pattern);
    tf = strcmp(newlabel,existlabels);
    copynum = copynum+1;
    
end

