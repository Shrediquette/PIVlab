function helper_gui_load_images(paths, sequencer)
%HELPER_GUI_LOAD_IMAGES Loads image files into the PIVlab window (like the file dialog would).
%   sequencer: 1 = pairwise (default), 0 = time resolved, 2 = reference image
if nargin < 2
    sequencer = 1;
end
gui.put('sequencer', sequencer);
gui.put('multitiff', 0);
gui.put('video_selection_done', 0);
selection = struct('name', paths(:), 'isdir', num2cell(false(numel(paths), 1)));
import.loadimgsbutton_Callback([], [], 0, selection);
drawnow;
end
