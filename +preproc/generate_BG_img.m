function generate_BG_img
handles=gui.gethand;
bg_operation=0;
if get(handles.bg_subtract,'Value')==2 %subtract mean value
    bg_operation=2;
elseif get(handles.bg_subtract,'Value')==3 %subtract minimum vlaue
    bg_operation=3;
end
if get(handles.bg_subtract,'Value')>1
    bg_img_A = gui.retr('bg_img_A');
    bg_img_B = gui.retr('bg_img_B');
    sequencer=gui.retr('sequencer');%Timeresolved or pairwise 0=timeres.; 1=pairwise
    if sequencer ~= 2 % bg subtraction only makes sense with time-resolved and pairwise sequencing style, not with reference style.
        if isempty(bg_img_A) || isempty(bg_img_B)
            if bg_operation ==2
                answer = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Background subtraction','Mean intensity background image needs to be calculated. Press ok to start.','modal',{'OK','Cancel'},'OK');
            end
            if bg_operation ==3
                answer = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Background subtraction','Minimum intensity background image needs to be calculated. Press ok to start.','modal',{'OK','Cancel'},'OK');
            end
            if strcmp(answer , 'OK')
                %% Calculate BG for all images (shared with the command-line API, pivlab.preprocess)
                src.filepath = gui.retr('filepath');
                src.framenum = gui.retr ('framenum');
                src.framepart = gui.retr ('framepart');
                if gui.retr('video_selection_done') == 0
                    src.video_reader_object = [];
                else
                    src.video_reader_object = gui.retr('video_reader_object');
                    src.video_frame_selection = gui.retr('video_frame_selection');
                end
                cam = import.cam_settings(FromGUI=true);
                gui.toolsavailable(0,'Busy, please wait...')
                [image1_bg, image2_bg, msg] = preproc.compute_background(src, sequencer, bg_operation, cam, @(p) gui.update_progress(p));
                if ~isempty(msg)
                    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',msg,'modal');
                end
                %make results accessible to the rest of the GUI:
                gui.put('bg_img_A',image1_bg);
                gui.put('bg_img_B',image2_bg);
                set(handles.preview_preprocess, 'String', 'Apply and preview current frame');drawnow;
                gui.update_progress(0)
                gui.toolsavailable(1)
            else % user has checkbox enabled, but doesn't want to calculate the background...
                set(handles.bg_subtract,'Value',1);
            end

        else
            %disp('BG exists')
        end

    else
        set(handles.bg_subtract,'Value',1);
        gui.custom_msgbox('warn',getappdata(0,'hgui'),'Not available',['Background removal is only available with the following sequencing styles:' sprintf('\n') '* Time resolved: [A+B], [B+C], [C+D], ...' sprintf('\n') '* Pairwise: [A+B], [C+D], [E+F], ...'],'modal');
    end
end
