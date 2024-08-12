function wdisplaymatlabcode(mcode_str,option)
%WDISPLAYMATLABCODE Display Matlab code in the editor.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Mar-2011.
%   Last Revision: 16-Mar-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

switch option
    case 'editor'
        % Throw to command window if java is not available
        if (matlab.desktop.editor.isEditorAvailable)
            % Convert to char array, add line endings
            editorDoc = matlab.desktop.editor.newDocument(mcode_str);
            editorDoc.smartIndentContents();

            % Scroll document to line 1
            editorDoc.goToLine(1);
        else
            wdisplaymatlabcode(mcode_str,'cmdwindow');
        end
        
        
    case 'cmdwindow'  
        disp(mcode_str);
end
