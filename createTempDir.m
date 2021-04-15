%
%% createTempDir
%
% Creates a temporary directory. This is used by all scripts within this
% project for interim working files
%
% _Parameters_
%
% _Return Values_
% * tempDirPath - Path to temporary directory created or empty string if error
%
function [tempDirPath] = createTempDir(argStr)

  t = tempname;
  status = mkdir(t);
  if (status == 1)
      fprintf('Created temporary directory at "%s"\n', t);
      tempDirPath = t;
  else
      fprintf('Error: Unable to create temporary directory\n');
      tempDirPath = '';
  end

end
