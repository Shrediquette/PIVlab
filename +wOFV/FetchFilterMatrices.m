function FetchFilterMatrices()

%Jassal, G., & Schmidt, B. E. (2024, August 12). wOFV Filter Matrices. https://doi.org/10.17605/OSF.IO/Y48MK

FileUrl = 'https://files.osf.io/v1/resources/y48mk/providers/osfstorage/?zip=';
FileName = 'Filter Matrices.zip';
disp('Downloading Filter Matrices.')
disp('This might take a while...')
websave(FileName,FileUrl);
disp('Filter Matrices downloaded, unzipping...')
unzip(FileName,'+wOFV/Filter Matrices/')
disp('Filter Matrices stored.')
delete(FileName)
