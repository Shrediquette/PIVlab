function FetchFilterMatrices()
%Jassal, G., & Schmidt, B. E. (2024, August 12). wOFV Filter Matrices. https://doi.org/10.17605/OSF.IO/Y48MK
gui.update_progress(0)
uiwait(warndlg(['Wavelet filter matrices do not exist. They are downloaded and stored for later use now.' newline newline 'Please watch the command window for progress messages.'],'No filter matrices found','modal'));
gui.toolsavailable(1)
gui.toolsavailable(0,'Downloading filter matrices...');drawnow
FileUrl = 'https://files.osf.io/v1/resources/y48mk/providers/osfstorage/?zip=';
FileName = 'Filter Matrices.zip';
disp('Downloading Filter Matrices.')
disp('This might take a while...')
websave(FileName,FileUrl);
gui.toolsavailable(1)
gui.toolsavailable(0,'Unzipping filter matrices...');drawnow
disp('Filter Matrices downloaded, unzipping...')
[filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
unzip(FileName,fullfile(filepath,'+wOFV','Filter matrices'))
disp('Filter Matrices stored.')
delete(FileName)
gui.toolsavailable(1)
gui.toolsavailable(0,'Busy, please wait...');drawnow