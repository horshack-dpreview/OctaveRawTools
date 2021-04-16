
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
  warning ('off'); % suppress warning from delete() for case when there are no files to delete
  delete(fullfile(tempDirPath, '*'));
  warning ('on');
  rmdir(tempDirPath);

end
