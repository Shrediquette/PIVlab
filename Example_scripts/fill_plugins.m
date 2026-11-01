function fill_plugins(item)
% This file should be placed in +plugins folder before starting PIVlab to have effect along with the file imb_rotation.m

% Print out a comment
disp('-> fill_plugins.m example: this function will populate the plugins menu with element "Images batch rotation"')

% Add the element to the menu
uimenu(item,'Label','Images batch rotation','Callback',@(~,~) plugins.imb_rotation());

end
