
%
%% runExiftool
%
% Invokes exiftool executable
%
% _Parameters_
% * argStr - String containing command line options to pass to exiftool
%
% _Return Values_
% * exitCode - Process exit code from exiftool (0 = success)
% * output - stdout from exiftool
%
function [exitCode, output] = runExiftool(argStr)

  % set exiftoolPath to the full path to your exiftool, including executable name.
  % if exiftool is in your system path then you can set exiftoolPath to simply
  % 'exiftool'
  if (ismac)
    exiftoolPath = '/usr/local/bin/exiftool';
  else
    exiftoolPath = 'exiftool'
  end

  % construct full command line to invoke exiftool and its parameters
  fullCmdLine = [exiftoolPath ' ' argStr];

  % invoke exiftool
  [exitCode, output] = system(fullCmdLine);

  % display error message if exiftool returned error status
  if (exitCode ~= 0)
    fprintf('runExiftool: Error exit status (%d) for: %s\n', exitCode, fullCmdLine);
  end

end
