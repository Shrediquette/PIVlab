function apply_pending_popup(control)
% Call this after the list of a popup menu was filled at runtime (e.g. the frame rates of a
% camera, the video formats of this computer). If loaded settings wanted an item that was not in
% the list at that time (gui.apply_settings), it is selected now. One try: if this list does not
% contain the item either, it is forgotten (unless the list is still a placeholder).
pending = gui.retr('pending_popup_texts');
if ~isstruct(pending) || ~isfield(pending, control.Tag)
    return
end
[~, is_pending] = gui.set_setting_control(control, control.Value, pending.(control.Tag));
if ~is_pending
    pending = rmfield(pending, control.Tag);
    gui.put('pending_popup_texts', pending);
end
end
