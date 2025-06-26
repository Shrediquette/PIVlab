MainWindow=getappdata(0,'hgui');
objects=findobj(MainWindow,'Type','uicontrol');
objects=[objects; findobj(MainWindow,'Type','uipanel')];

scalefactor=[0.8036    0.6500    0.8036    0.6500];

margin=1.5*scalefactor(4);
panelwidth=45*scalefactor(3);
panelheighttools=13*scalefactor(4);
panelheightpanels=45*scalefactor(4);
quickheight=3.5*scalefactor(4);

gui.put('panelwidth',panelwidth);
gui.put('margin',margin);
gui.put('panelheighttools',panelheighttools);
gui.put('panelheightpanels',panelheightpanels);
gui.put('quickwidth',panelwidth);
gui.put('quickheight',quickheight);

for i=1:numel(objects)
    objects(i).Position = objects(i).Position.*scalefactor;
end
gui.MainWindow_ResizeFcn(getappdata(0,'hgui'), [])