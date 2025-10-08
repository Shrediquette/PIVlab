function calibBinning_Callback (~,~,~)
handles=gui.gethand;
camera_type=gui.retr('camera_type');
if ~strcmp(camera_type,'pco_panda')  %Binning available only for pco panda
    uiwait(msgbox('Binning is (up to now) only available for the pco.panda 26 DS.','modal'))
else
    binning=gui.retr('binning');
    if isempty(binning)
        binning=1;
    end
    definput = num2str(binning);
    prompt = {'Select pixel binning size to increase sensor sensitivity:' 'A size of 1 disables pixel binning.'};
    dlgtitle = 'Pixel binning Configuration';
    answer = questdlg(prompt, dlgtitle, '1','2','4',definput);
    if ~isempty(answer)
        gui.put('binning',str2double(answer));
        roi.clear_roi_Callback %PIV-ROI must be cleared when camera resolution is chnaged.
        set(handles.ac_realtime,'Value',0);%reset realtime roi
        gui.put('do_realtime',0);
        %reset roi too
        ac_ROI_general=[];
        gui.put('ac_ROI_general',ac_ROI_general);
        save('PIVlab_settings_default.mat','ac_ROI_general','-append');
    end
end