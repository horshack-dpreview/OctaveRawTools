%
%% convertDirToDng
%
% Converts a directory of raw images into uncompressed DNGs
%
% _Parameters_
% * sourceDir - Directory containing source DNGs to convert. Can contain an
%               optional file mask such as 'c:\mypics\*.nef". If no mask is
%               specified then all files in the specified direcotry must be valid
%               image files, otherwise the conversion will fail.
% * destDir   - Directory to store converted DNGs
%
% _Return Values_
% * success         - true if successful, false if not.
% * numDngsCreated  - number of files converted
%
function [success, numDngsCreated] = convertDirToDng(sourceDir, destDir)

  timeStart = time();

  %
  % Adobe's DNG converter is heavily optimized for parallel operation, provided
  % it's supplied multiple files to convert per invocation. I place an arbitrary
  % limit on the number of files per invocation, to keep the size of the command
  % line reasonable for situations where there are hundreds of files to process
  %
  % Note that running the DNG converter's GUI is much faster than invoking
  % from the command line, even when we pass it the full list of files on
  % the command line :(
  %
  MAX_FILES_PER_CONVERSION  = 32;

  success = false; % assume error
  numDngsCreated = 0;

  % get listing of files in specified source directory
  listing = dir(sourceDir);
  numEntriesInListing = numel(listing);

  %
  % process files in directory
  %
  firstFileThisConversion = 1;
  numFilesConverted = 0;
  while (firstFileThisConversion <= numEntriesInListing)

    %
    % build file list of up to MAX_FILES_PER_CONVERSION files to process on
    % this invocation. Note we select any file in the directory, which means
    % the directory must only containimage files, otherwise the DNG converter
    % will fail when it reaches the non-image file.
    %
    numFilesThisConversion = 0;
    fileListStr = '';
    nextFileThisConversion = firstFileThisConversion;
    while (nextFileThisConversion <= numEntriesInListing && numFilesThisConversion < MAX_FILES_PER_CONVERSION)
      if (~listing(nextFileThisConversion).isdir)
        fileListStr = [fileListStr '"' fullfile(listing(nextFileThisConversion).folder, listing(nextFileThisConversion).name) '" '];
        numFilesThisConversion = numFilesThisConversion+1;
      end
      nextFileThisConversion = nextFileThisConversion +1;
    end

    % perform the conversion
    if (numFilesThisConversion > 0)
      [exitCode, output] = runDngConverter(['-u -d "' destDir '" ' fileListStr]);
      if (exitCode ~= 0)
        return;
      end
      numFilesConverted = numFilesConverted + numFilesThisConversion;
    end

    % advance outer processing loop index to pick up after the last file we just converted
    firstFileThisConversion = nextFileThisConversion;
  end

  success = true;
  numDngsCreated = numFilesConverted;

  fprintf('Adobe DNG Converter: %d DNGs converted in %.2f seconds\n', numDngsCreated, time() - timeStart);

end
