
%
%% deleteTempDir
%
% Deletes a temporary directory previously created by createTempDir(), including
% deleting all files in the directory.
%
% _Parameters_
% * tempDirPath - Path to temporary directory to delete.
%
% _Return Values_
% * none
%
function deleteTempDir(tempDirPath)

  fprintf('Deleting temporary files and folder at "%s"\n', tempDirPath);
  delete(fullfile(tempDirPath, '*'));
  rmdir(tempDirPath);

end
