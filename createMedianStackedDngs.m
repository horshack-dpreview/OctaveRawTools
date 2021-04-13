%
%% createMedianStackedDngs
%
% Performs median stacking of raw files. The images for each stack are
% automatically detected by looking at the EXIF create time of each file - images
% with creation times within 2 seconds of each other will be considered
% part of the same stack. The routine will create as many stacks as it finds.
%
% _Parameters_
% * sourceDir - Directory containing source raw files to stack. Can contain an
%               optional file mask such as 'c:\mypics\*.nef". If no mask is
%               specified then all files in the specified direcotry must be valid
%               image files, otherwise the conversion will fail.
% * outputDir - Directory to hold generated stacked images. The fiename for each
%               created stack will be the filename of the first image in the stack
%               with "_x_Stacked" appended to the end of the name,
%               where <x> is the number of images used to create the stack
%
% _Return Values_
% * success           - true if successful, false if not.
% * numStacksCreated  - number of median stacks created
%
function [success, numStacksCreated] = createMedianStackedDngs(sourceDir, outputDir)

  SERIAL_DATE_VALUE_PER_SECOND  = double(1/(24*60*60));

  function serialDate = exifDateStrToSerialDate(exifDateStr)
    serialDate = datenum(exifDateStr, "yyyy:mm:dd HH:MM:SS");
  end

  function indexNextFile = nextFileInListing(indexPrevFile)
    for i=indexPrevFile+1:numel(listing)
      if listing(i).isdir == false
        indexNextFile = i;
        return;
      end
    end
    indexNextFile = -1;
  end

  function [index, serialCreationDate, exifMap] = loadNextFileInfo(indexPrevFile)
    % get next file
    index = nextFileInListing(indexPrevFile);
    if (index != -1)
      % load EXIF
      exifMap = genExifMap(fullfile(listing(index).folder, listing(index).name));
      % convert creation date to serial date for use in time comparisons
      serialCreationDate = exifDateStrToSerialDate(exifMap("createdate"));
    else
      % no more files to process
      serialCreationDate = 0;
      exifMap = containers.Map();
    end
  end


  %
  %**********************************************************************
  %
  % function entry point
  %
  %**********************************************************************
  %

  success = false; % assume error
  numStacksCreated  = 0;

  %
  % convert the source files into uncompressed DNGs, storing them
  % in a temporary directory
  %
  tempDir = createTempDir();
  if (isempty(tempDir)) % empty string if temp dir creation failed
    return;
  end
  fprintf('Creating temporary DNGs from raw files in "%s"...\n', tempDir);
  [success, numDngsCreated] = convertDirToDng(sourceDir, tempDir);
  if (~success)
    deleteTempDir(tempDir);
    return;
  end
  if (numDngsCreated == 0)
    fprintf('No DNGs were created in temporary directory "%s"\n', tempDir);
    deleteTempDir(tempDir);
    return;
  end

  % get a list of DNGs we just created
  listing = dir(tempDir);

  %
  % process files in directory, looking for collections of images to stack
  %
  indexLastFileProcessed = 0;
  numStacksCreatedLastScanningPrint = -1;
  while (indexLastFileProcessed ~= -1)

    if (numStacksCreatedLastScanningPrint != numStacksCreated)
      numStacksCreatedLastScanningPrint = numStacksCreated;
      fprintf('Scanning DNGs to find related images for next stack...\n');
    end

      %
      % load EXIF info for next file that will serve as the 1st file
      % of our new prospective stack. the only EXIF info we really need is
      % the creation date since that's what we used to determine which
      % images belong in the same stack.
      %
      stack = struct;
      numFilesThisStack = 1;
      [stack(1).index, sdPrevFile, stack(1).exifMap] = loadNextFileInfo(indexLastFileProcessed);
      if (stack(1).index == -1)
        break;
      end

      %
      % load EXIF info for additional files that will be part of the same stack.
      % We assume a DNG is part of the same stack if its creation date is
      % within 2 seconds of the previous DNG
      %
      while true

        % load EXIF for next file in listing
        [stack(numFilesThisStack+1).index, sdThisFile, stack(numFilesThisStack+1).exifMap] = loadNextFileInfo( stack(numFilesThisStack).index );
        if (stack(numFilesThisStack+1).index == -1)
          break;
        end

        % if creation date of next file is > 2 seconds vs previous file it's not part of this stack
        if ((sdThisFile - sdPrevFile) / SERIAL_DATE_VALUE_PER_SECOND  > 2.0)
          % this file is not part of the stack we're currently building
          break;
        end

        % prepare to advance to next file candiate of this stack
        numFilesThisStack = numFilesThisStack+1;
        sdPrevFile = sdThisFile;
      end

      indexLastFileProcessed = stack(numFilesThisStack).index; % so main loop knows which file to start with on next iteration

      if (numFilesThisStack == 1)
        % our stack candidate turned out to be a bust. advance to next candidate
        continue;
      end

      %
      % load the raw data for each DNG in the stack
      %
      fprintf('Loading raw data for %d DNGs\n', numFilesThisStack);
      for i=1: numFilesThisStack
        [sucess, stack(i).dngStruct] = loadDngRawData(fullfile(listing(stack(i).index).folder, listing(stack(i).index).name));
        if (~success)
          break;
        end
      end

      % create 3D matrix ofthe raw data from all DNGs
      rawDataStack = [];
      for i=1: numFilesThisStack
        rawDataStack = cat(3, rawDataStack, stack(i).dngStruct.imgData);
      end

      % calculate the median of all the raw data
      imgDataMedian = median(rawDataStack, 3);

      %
      % generate the output DNG to hold the median stacked data. We do this
      % by creating a copy of the first DNG in the stack, to serve as the container
      % for the modified raw data, then write the raw data to the copy.
      %
      % The output filename is equal to the filename of the first DNG in the stack,
      % with "_x_Stacked" appended before the extension, where <x>
      % is the number of images used to create the stack
      %

      firstImageInStackFilenameWithPath = fullfile(listing(stack(1).index).folder, listing(stack(1).index).name);

      % construct filename of output
      [~, filename, ext] = fileparts(firstImageInStackFilenameWithPath);
      outputFilename = [filename '_' num2str(numFilesThisStack) '_Stacked' ext];
      outputFilenameWithPath = fullfile(outputDir, outputFilename);

      % copy the 1st image in the stack as our output file
      fprintf('Creating stacked image "%s"\n', outputFilenameWithPath);
      copyfile(firstImageInStackFilenameWithPath, outputFilenameWithPath);
      saveRawDataToDng(outputFilenameWithPath, stack(1).dngStruct.stripOffset, imgDataMedian);

      numStacksCreated = numStacksCreated+1;

  end

  % delete temporary files+directory
  deleteTempDir(tempDir);

  % success if we reached end of file list without encountering errors
  if (indexLastFileProcessed == -1)
    success = true;
  end

end