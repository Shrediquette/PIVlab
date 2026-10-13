function busy_hint(busy_msg,stopped)
%BUSY_HINT Status strip at the bottom of the image display while the PIVlab controls are locked.
%   gui.busy_hint(busy_msg) shows busy_msg in the strip (an existing strip is replaced). Called by
%   gui.toolsavailable(0,busy_msg), can also be called afterwards to change the text. While PIVlab
%   works, the strip shows the time since gui.toolsavailable(0) (updated by gui.busy_watchdog).
%   gui.busy_hint(busy_msg,true) shows that the task ended without unlocking the controls (usually
%   after an error) and adds the button "Unlock controls" (from gui.busy_watchdog).
%   gui.toolsavailable(1) removes the strip.
%   The strip is shown in the PIVlab window and on the second monitor display (gui.busy_figures).
if nargin<2
	stopped=false;
end
[figs,axs]=gui.busy_figures;
for k=1:numel(figs)
	delete(findobj(figs(k),'Tag','busyhint'));
	if isgraphics(axs(k))
		draw_strip(figs(k),axs(k),busy_msg,stopped);
	end
end
end

function draw_strip(fig,ax,busy_msg,stopped)
strip_color=[0.13 0.14 0.17];
if stopped
	accent_color=[1 0.6 0.2];
else
	accent_color=[0.4 0.65 1];
end
strip_height=50;
accent_height=3;
right_width=150; % elapsed time or button
font_size=16;
% the strip is a panel on top of the axes: not affected by zoom, axis limits or redrawing of the image
ax_pos=getpixelposition(ax,true);
strip=uipanel(fig,'Units','pixels','Position',[ax_pos(1) ax_pos(2) ax_pos(3) strip_height], ...
	'BorderType','none','BackgroundColor',strip_color,'Tag','busyhint');
uipanel(strip,'Units','pixels','Position',[0 strip_height-accent_height ax_pos(3) accent_height],'BorderType','none','BackgroundColor',accent_color);
inner_height=strip_height-accent_height;
if stopped
	uicontrol(strip,'Style','pushbutton','String','Unlock controls','Units','pixels', ...
		'Position',[ax_pos(3)-right_width-10 (inner_height-30)/2 right_width 30],'FontSize',11,'FontWeight','bold', ...
		'Tooltip','Enables the controls of PIVlab again. PIVlab is not working on anything anymore.', ...
		'Callback',@gui.busy_unlock_Callback);
	icon=char(9888); % warning sign
else
	busy_since=gui.retr('busy_since');
	if ~isempty(busy_since)
		elapsed=uicontrol(strip,'Style','text','String',gui.busy_elapsed_string(toc(busy_since)),'Units','pixels', ...
			'HorizontalAlignment','right','FontSize',font_size,'ForegroundColor',[0.85 0.9 1], ...
			'BackgroundColor',strip_color,'Tag','busy_elapsed');
		ext=get(elapsed,'Extent');
		set(elapsed,'Position',[ax_pos(3)-right_width-14 (inner_height-ext(4))/2 right_width ext(4)]);
	end
	icon=char(9203); % hourglass
end
txt=uicontrol(strip,'Style','text','String',[icon '  ' busy_msg],'Units','pixels','HorizontalAlignment','left', ...
	'FontSize',font_size,'FontWeight','bold','ForegroundColor',[1 1 1],'BackgroundColor',strip_color);
text_width=max(ax_pos(3)-right_width-40,10);
ext=get(txt,'Extent');
% long text or small window: smaller font (Extent is up to ~15 % smaller than the drawn text)
while ext(3)*1.2>text_width && get(txt,'FontSize')>10
	set(txt,'FontSize',get(txt,'FontSize')-1);
	ext=get(txt,'Extent');
end
set(txt,'Position',[14 (inner_height-ext(4))/2 text_width ext(4)]);
% follows the window when it is resized
set(strip,'Units','normalized');
end
