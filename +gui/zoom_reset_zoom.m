function zoom_reset_zoom(~,~)
handles=gui.gethand;
setappdata(getappdata(0,'hgui'),'xzoomlimit',[]);
setappdata(getappdata(0,'hgui'),'yzoomlimit',[]);
%zoom reset
zoom out
set(handles.zoomon,'Value',0);
set(handles.panon,'Value',0);
zoom(gca,'off')
pan(gca,'off')
expected_image_size=gui.retr('expected_image_size');
pcopanda_dbl_image=gui.retr('pcopanda_dbl_image');
if isempty(pcopanda_dbl_image)
    pcopanda_dbl_image=0;
end

if isempty(expected_image_size) %happens when no images are yet loaded
    current_ax=gui.retr('pivlab_axis');
    current_img=findall(current_ax,'Type','Image');
    if ~isempty(current_img)
        current_img=current_img(1);
        expected_image_size=[size(current_img.CData,1) size(current_img.CData,2)];
    else
        return
    end
end

set(gui.retr('pivlab_axis'),'xlim',[0.5 expected_image_size(2)+0.5])
set(gui.retr('pivlab_axis'),'ylim',[0.5 expected_image_size(1)+0.5])