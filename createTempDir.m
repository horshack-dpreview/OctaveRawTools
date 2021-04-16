%
%% createTempDir
%
% Creates a temporary directory. This is used by all scripts within this
% project for interim working files
%
% _Parameters_
% * baseDir     - Base directory off which to create a randomly-generated
%                 temporary directory. If this value is empty then the
%                 the system's default temp directory path is used as the base
%                 directory.
%
% _Return Values_
% * tempDirPath - Path to temporary directory created or empty string if error
%
function [tempDirPath] = createTempDir(baseDir)

  if (exist('baseDir') && ~isempty(baseDir))
    randFolderName = [ 'OctaveRawTools-Temp-' num2str(floor(time()*100)) ];
    tempDirPath = fullfile(baseDir, randFolderName);
  else
    tempDirPath = tempname;
  end
  status = mkdir(tempDirPath);
  if (status == 1)
      fprintf('Created temporary directory at "%s"\n', tempDirPath);
  else
      fprintf('Error: Unable to create temporary directory\n');
      tempDirPath = '';
  end

end
