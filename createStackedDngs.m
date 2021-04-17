%
%% createStackedDngs
%
% Performs mean/median stacking of raw files. The images for each stack are
% automatically detected by looking at the EXIF create time of each file - images
% with creation times within 2 seconds of each other will be considered
% part of the same stack. The routine will create as many stacks as it finds.
%
% _Parameters_
% * sourceDir - Directory containing source raw files to stack. Can contain an
%               optional file mask such as 'c:\mypics\*.nef". If no mask is
%               specified then all files in the specified direcotry must be valid
%               image files, otherwise the conversion will fail.
% * varargin  - Optional paramters specified as <name>,<value> pairs.
%
% Optional paramters:
%
% 'stackmethod', 'median | mean'
%
% Algorithm to use for stacking the images. The default is mean.
%
% 'outputdir', '<path>'
%
% Output directory to hold the stacked images. The default is in the source directory
%
% 'convertraws', true | false
%
% By default the script will convert your raws into the necessary uncompressed DNG format
% the script requires `('covertraws', true)`. You can optionally perform this conversion
% yourself prior to running the script. This is useful because the command-line version
% of Adobe's DNG converter runs noticeably slower than the GUI version, so if you have many
% files to stack (hundreds or thousands) then it'll be faster to convert the files using
% the GUI and then running the script against those DNGs. When you convert the files
% yourself you must configure Adobe's DNG converter to output uncompressed DNG files.
% This can be done by clicking the "Change Preferences" button, then in the Preferences
% dialog under "Compatibility" click the drop down and select "Custom". You'll see a
% "Custom DNG Compatibility" dialog - click the "Uncompressed" checkbox.
%
% 'tempdir', '<path>'
%
% By default the script will use the system's default temporary folder
% location to create the subfolder to hold the DNGs converted when `'convertraws'` is true.
% You can specify an alternate base temporary directory with this option.
%
% 'maxtimedelta', value
%
% Sets the maximum EXIF CreateDate tag time delta in seconds between images to be
% considered part of the same sequence/stack. Default is 2.0. Specify a value of 0 to
% disable the time delta check - all files will be considered part of a single stack.
%
% Examples:
%
%   createStackedDngs('c:\pics\myraws', 'stackmethod', 'mean')
%
%   The script will convert all raws in 'c:\pics\myraws' into a system-selected temporary directory,
%   then stack related sets of files using the `mean` algorithm, storing the resulting stacked DNGs
%   into `c:\pics\myraws`.
%
%   createStackedDngs('c:\pics\mydngs', 'stackmethod', 'mean', 'convertraws', false, 'outputdir', 'c:\pics\mystackedimages')
%
%   The script will use the raws you previously converted into uncompressed DNGs, apply the `mean`
%   algorithm, and store the resulting stacked DNGs into `c:\pics\mystackedimages`.
%
% _Return Values_
% * success           - true if successful, false if not.
% * numStacksCreated  - number of stacks created
%
function [success, numStacksCreated] = createStackedDngs(sourceDir, varargin)

  SERIAL_DATE_VALUE_PER_SECOND  = double(1/(24*60*60));
  SIZE_UINT16 = 2;

  %
  % converts an EXIF CreateDate tag value into a Matab/Octave "serial date",
  % which contains the number of days in the integer portion and fractions
  % of a day in the decimal portion
  %
  function serialDate = exifDateStrToSerialDate(exifDateStr)
    serialDate = datenum(exifDateStr, "yyyy:mm:dd HH:MM:SS");
  end

  %
  % processes any optional arguments passed
  %
  function [success, argValues] = processOptionalArgs()
    argStruct = struct;
    % stack method. defaults to 'mean'
    argStruct(1).name = 'stackMethod';
    argStruct(1).class = 'char';
    argStruct(1).defaultValue = 'mean';
    argStruct(1).validValues = { 'median', 'mean' };
    % output directory. defaults to source directory
    argStruct(2).name = 'outputDir';
    argStruct(2).class = 'char';
    argStruct(2).defaultValue = sourceDir;
    % flag on whether or not we convert the raws to DNG outselves. default is true
    argStruct(3).name = 'convertRaws';
    argStruct(3).class = 'logical';
    argStruct(3).defaultValue = 'true';
    % base path to temporary directory. if not specified we'll use system temp directory
    argStruct(4).name = 'tempDir';
    argStruct(4).class = 'char';
    % max time interval between files to be considered part of the same stack
    argStruct(5).name = 'maxTimeDelta';
    argStruct(5).class = 'double';
    argStruct(5).defaultValue = 2.0;
    [success, argValues] = processNamedVariableArgs(varargin, argStruct);
  end

  %
  % Converts the raws inside the source directory, storing the resulting
  % DNGs in a temporary directory. If successful, returns the full path
  % to the created temporary directory, otherwise returns an empty string
  %
  function tempDirFullPath = convertRawsToDngs()
    tempDirFullPath = ''; % assume error
    if (isfield(config, 'tempDir'))
      tempDir = createTempDir(config.tempDir);
    else
      tempDir = createTempDir();
    end
    if (isempty(tempDir)) % empty string if temp dir creation failed
      return;
    end
    fprintf('Running Adobe DNG Converter on "%s" output to "%s"...\n', sourceDir, tempDir);
    [retSuccess, numDngsCreated] = convertDirToDng(sourceDir, tempDir);
    if (~retSuccess)
      deleteTempDir(tempDir);
      return;
    end
    if (numDngsCreated == 0)
      fprintf('No DNGs were created in temporary directory "%s"\n', tempDir);
      deleteTempDir(tempDir);
      return;
    end
    tempDirFullPath = tempDir; % success
  end

  %
  %**********************************************************************
  %
  % function entry point
  %
  %**********'************************************************************
  %

  success = false; % assume error
  numStacksCreated  = 0;

  % process arguments
  [retSuccess, config] = processOptionalArgs();
  if (~retSuccess)
    return;
  end

  timeStart = time();

  %
  % convert the raws to DNGs if user hasn't already done so
  %
  if (config.convertRaws)
    tempDirFullPath = convertRawsToDngs();
    if (isempty(tempDirFullPath))
      % DNG creation failed
      return;
    end
    dngPath = tempDirFullPath;
  else
    % user performed conversion prior to running this script
    dngPath = sourceDir;
    tempDirFullPath = '';
  end

  % get EXIF info for all the DNGs
  timeStartExifRead = time();
  fprintf('Running exiftool to retrieve EXIF data on files in "%s"...\n', dngPath);
  [filenamesWithPathList, exifMapList] = genExifMapForDir(dngPath);
  numFiles = numel(exifMapList);
  if (numFiles == 0)
    % error obtaining EXIF info
    return;
  end
  fprintf('Read EXIF data on %d files in %.2f seconds\n', numFiles, time() - timeStartExifRead);

  %
  % generate a lookup table that will let us index entires in exifMapList
  % and filenamesWithPathList in sorted order by EXIF create date. The original
  % implementation would rely on exiftool's "-fileOrder CreateDate" option
  % but unfortunately that increases exiftool's execution time by 2x, so we
  % now do the sorting ourselves
  %
  [indexToSortedIndex, sortedDates] = genSortLookupTableForExifListDateField('createdate', exifMapList);

  %
  % process files in directory, looking for collections of images to stack
  %
  indexNextFileToProcess = 1;
  fprintf('Scanning DNGs to find related images for each stack...\n');
  while (indexNextFileToProcess <= numFiles)

    %
    % select next file as the 1st file of our new prospective stack
    %
    stack = struct;
    numFilesThisStack = 1;
    indexFirstFileThisStack = indexNextFileToProcess;
    %sdPrevFile = exifDateStrToSerialDate(exifMapList{indexFirstFileThisStack}('createdate'));
    sdPrevFile = sortedDates(indexFirstFileThisStack);

    %
    % now see what other files after our candidate should be in the stame stack
    %
    if (config.maxTimeDelta != 0)
      indexNextFileInStack = indexFirstFileThisStack+1;
      maxTimeDelta =  config.maxTimeDelta + 0.01; % adding 0.01 for double-precision rounding errors
      while (indexNextFileInStack <= numFiles)

        % if creation date of next file is > 2 seconds vs previous file it's not part of this stack
        %sdThisFile = exifDateStrToSerialDate(exifMapList{indexNextFileInStack}('createdate'));
        sdThisFile = sortedDates(indexNextFileInStack);
        if ((sdThisFile - sdPrevFile) / SERIAL_DATE_VALUE_PER_SECOND  > maxTimeDelta)
          % this file is not part of the stack we're currently building
          break;
        end
        % prepare to advance to next file candiate of this stack
        indexNextFileInStack = indexNextFileInStack+1;
        numFilesThisStack = numFilesThisStack+1;
        sdPrevFile = sdThisFile;
      end
    else
      % no time delta specified - user wants every file to be considered as one stack
      numFilesThisStack = numFiles;
    end

    indexNextFileToProcess = indexNextFileToProcess+numFilesThisStack; % so main loop knows which file to start with on next iteration

    if (numFilesThisStack == 1)
      % our stack candidate turned out to be a bust. advance to next candidate
      fprintf('Not stacking "%s"\n', filenamesWithPathList{sortedIndxes(indexFirstFileThisStack)});
      continue;
    end

    %
    % perform the requested operation on the raw data
    %
    fprintf('Loading raw data for %d DNGs to stack via "%s"...\n', numFilesThisStack, config.stackMethod);
    timeStartLoadDngs = time();
    switch (config.stackMethod)
    case 'median'

      %
      % first load the raw data from all DNGs. note all the raws must be in memory
      % before we can calculate the median, which means we'll be consuming lots
      % of memory
      %

      for i=1: numFilesThisStack
        [retSuccess, stack(i).dngStruct] = loadDngRawData(filenamesWithPathList{indexToSortedIndex(indexFirstFileThisStack+i-1)},...
          exifMapList{indexToSortedIndex(indexFirstFileThisStack+i-1)});
        if (~retSuccess)
          break;
        end
        if (i == 1)
          stripOffsetFirstFile = stack(1).dngStruct.stripOffset;
        end
      end
      fprintf('Loaded %d DNGs in %.2f seconds\n', numFilesThisStack, time() - timeStartLoadDngs);

      %
      % create 3D matrix of all the raw data. we preallocate the matrix, both to
      % make sure we have enough memory and more importantly, for performance.
      % the alternate, using cat(), is much slower, to the point of being unsuable
      % for very large stacks (> 64 images)
      %
      timeStartBuildMatrix = time();
      fprintf('Building %d x %d x %d matrix of raw data (size = %s)...\n', stack(1).dngStruct.imageWidth,...
        stack(1).dngStruct.imageHeight, numFilesThisStack,...
        genHumanReadableByteCountStr(stack(1).dngStruct.imageWidth * stack(1).dngStruct.imageHeight * SIZE_UINT16 * numFilesThisStack));
      rawDataStack = zeros(stack(1).dngStruct.imageHeight, stack(1).dngStruct.imageWidth, numFilesThisStack, 'uint16');
      for i=1: numFilesThisStack
        rawDataStack(:,:,i) = stack(i).dngStruct.imgData;
        stack(i).dngStruct.imgData = []; % clear reference early so memory manager can release if possible
      end
      fprintf('Built matrix of raw data in %.2f seconds\n', time() - timeStartBuildMatrix);

      % calculate the median of all the raw data
      fprintf('Performing "median" calculation on matrix...\n');
      timeStartMedian = time();
      imgDataOut = median(rawDataStack, 3);
      fprintf('"Median" calculation done in %.2f seconds\n', time() - timeStartMedian);

    case 'mean'

      %
      % load the raw data from each DNG, creating a running sum
      %
      for i=1: numFilesThisStack
        [retSuccess, dngStruct] = loadDngRawData(filenamesWithPathList{indexToSortedIndex(indexFirstFileThisStack+i-1)},...
          exifMapList{indexToSortedIndex(indexFirstFileThisStack+i-1)});
        if (~retSuccess)
          break;
        end
        if (i == 1)
          imgDataOut = uint32(dngStruct.imgData);
          stripOffsetFirstFile = dngStruct.stripOffset;
        else
          imgDataOut = imgDataOut .+ uint32(dngStruct.imgData);
        end
      end

      imgDataOut = imgDataOut ./ numFilesThisStack;

      fprintf('Loaded %d DNGs and applied "mean" calculation in %.2f seconds\n', numFilesThisStack, time() - timeStartLoadDngs);

    end % switch (config.stackMethod)


    %
    % generate the output DNG to hold the stacked data. We do this
    % by creating a copy of the first DNG in the stack, to serve as the container
    % for the modified raw data, then write the raw data to the copy.
    %
    % The output filename is equal to the filename of the first DNG in the stack,
    % with "_x_Stacked" appended before the extension, where <x>
    % is the number of images used to create the stack
    %

    % construct filename of output
    firstImageInStackFilenameWithPath = filenamesWithPathList{indexToSortedIndex(indexFirstFileThisStack)};
    [~, filename, ext] = fileparts(firstImageInStackFilenameWithPath);
    stackMethodStr = [toupper(config.stackMethod(1)) config.stackMethod(2:end)]; % capitalize first letter
    outputFilename = [filename '_' num2str(numFilesThisStack) '_Stacked_' stackMethodStr ext];
    outputFilenameWithPath = fullfile(config.outputDir, outputFilename);
    outputFilenameWithPath = genUniqueFilenameIfExists(outputFilenameWithPath);

    % tell user about the stack we're creating
    fprintf('Creating stacked image "%s" from the following (%d) files:\n', outputFilenameWithPath, numFilesThisStack);
    for i=1: numFilesThisStack
      fprintf("   -> %s\n", filenamesWithPathList{indexToSortedIndex(indexFirstFileThisStack+i-1)});
    end

    % copy the 1st image in the stack as our output file
    retSuccess = copyfile(firstImageInStackFilenameWithPath, outputFilenameWithPath);
    if (~retSuccess)
      break;
    end

    % overwrite the raw data of the output file with the calculated data
    retSuccess = saveRawDataToDng(outputFilenameWithPath, stripOffsetFirstFile, imgDataOut);
    if (~tempDirFullPath)
      break;
    end

    numStacksCreated = numStacksCreated+1;

  end % while (indexNextFileToProcess <= numFiles)

  % delete temporary files+directory
  if (~isempty(tempDirFullPath))
    deleteTempDir(tempDirFullPath);
  end

  % success if we reached end of file list without encountering errors
  success = (indexNextFileToProcess > numFiles);

  if (success)
    fprintf("Created %d stack(s) in %.2f seconds\n", numStacksCreated, time() - timeStart);
  end

end