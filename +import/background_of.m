function bg_img = background_of(bg, selected)
%BACKGROUND_OF Background image of a frame: bg.A for A frames (odd), bg.B for B frames (even).
%   bg_img = import.background_of(bg, selected)
%   bg  struct with fields A and B, or [] for no background subtraction (then bg_img = [])
%   Used by import.read_frame and import.read_frame_display.
bg_img = [];
if ~isempty(bg)
    if mod(selected, 2) == 1
        bg_img = bg.A;
    else
        bg_img = bg.B;
    end
end
end
