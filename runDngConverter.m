
%
%% runDngConverter
%
% Invokes Adobe's DNG converter
%
% _Parameters_
% * argStr - String containing command line options to pass to the DNG conveter
%
% _Return Values_
% * exitCode - Process exit code from exiftool (0 = success)
% * output - stdout from the DNG conveter (it doesn't typically generate any output)
%
function [exitCode, output] = runDngConverter(argStr)

  % set path to Adobe's DNG converter
  if (ispc)
    dngConverterPath = 'C:/Program Files/Adobe/Adobe DNG Converter/Adobe DNG Converter.exe';
  elseif (ismac)
    dngConverterPath = 'open -a "/Applications/AdobeDNGConverter.app/Contents/MacOS/AdobeDNGConverter" --args';
  else
    assert("Unsupported OS platform");
  end

  % make sure we have the right path to the DNG converter
  if (~isfile(dngConverterPath))
    fprintf('Error: DNG converter not found at "%s". Update "dngConverterPath" in runDngConverter.m\n', dngConverterPath);
    return;
  end

  % run
  fullCmdLine = ['"' dngConverterPath '" ' argStr];
  [exitCode, output] = system(fullCmdLine);

  % display error message if exiftool returned error status
  if (exitCode ~= 0)
    fprintf('runDngConverter: Error exit status (%d) for: %s\n', exitCode, fullCmdLine);
  end

end
