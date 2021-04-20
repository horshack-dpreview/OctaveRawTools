
%
%% loadDngRawData
%
% Reads raw data from an uncompressed raw DNG
%
% _Parameters_
% * dngFilename - Filename of DNG to read
% * exifMap     - Optional: EXIF map if already read by caller. Pass {} if you
%                 haven't already read the EXIF (this routine will read it)
%
% _Return Values_
% * dng - Structure containing information and raw data from DNG:
% * dng.exifMap         - containers.Map of all EXIF info
% * dng.imageWidth      - Number of horizontal pixels in raw data
% * dng.imageHeight     - Number of vertical pixels in raw data
% * dng.stripOffset     - File offset to raw CFA data in DNG file
% * dng.stripByteCount  - Size of raw CFA data in DNG file_in_loadpath
% * dng.imgData         - CFA data read from file
% * dng.cfaPatternMatrix- CFA pattern as 2x2 matrix (0 = Red, 1 = Green, 2 = Blue)
% * dng.cfaPatternStr   - CFA pattern as 4-character string (ex: "RGGB")
%
function [success, dng] = loadDngRawData(dngFilename, exifMap)

  SIZE_UINT16 = 2;

  function failedMatch = exifMustMatch(tagName, expectedValue)
    if (~strcmpi(exifMap(tagName), expectedValue))
      fprintf('Error: "%s", EXIF tag "%s" expected to be "%s", actual is "%s"\n', dngFilename,...
        tagName, expectedValue, exifMap(tagName));
      failedMatch = true;
    else
      failedMatch = false;
    end
  end

  function exifShouldMatch(tagName, expectedValue)
    if (~strcmpi(exifMap(tagName), expectedValue))
      msg = sprintf('Warning: "%s", EXIF tag "%s" expected to be "%s", actual is "%s"\n',...
        dngFilename, tagName, expectedValue, exifMap(tagName));
      printMsgButSuppressIfDuplicate(['exifShouldMatch#' tagName], msg);
    end
  end

  function value = getExifScalar(tagName)
    value = str2double(exifMap(tagName));
  end

  function [imageHeight, imageWidth] = getExifActiveAreaHeightWidth()
    %
    % convert "activearea" EXIF tag to a width and height. The format of
    % the activearea tag is: "top left bottom right". Example: "0 0 4000 6000"
    %
    activeAreaStr = exifMap("activearea");
    valuesStrCell = regexp(activeAreaStr,  ['\s*([0-9]*)\s*'], 'tokens');
    top     = str2num(valuesStrCell{1}{1});
    left    = str2num(valuesStrCell{2}{1});
    bottom  = str2num(valuesStrCell{3}{1});
    right   = str2num(valuesStrCell{4}{1});
    imageHeight = bottom - top;
    imageWidth = right - left;
  end

  dng = struct;
  success = false; % assume error

  % get EXIF data
  if (~exist('exifMap') || isempty(exifMap))
    exifMap = genExifMap(dngFilename);
    if (isempty(exifMap))
      return;
    end
  end

  % get EXIF values we'll need to process the DNG
  stripOffset = getExifScalar("stripoffsets");
  stripByteCount = getExifScalar("stripbytecounts");
  imageWidth = getExifScalar("imagewidth");
  imageHeight = getExifScalar("imageheight");

  %
  % some cameras report the "correct" image dimensions via the iamgewidth
  % and imageheight EXIF tags whereas others such as the Panasonic GX85 only
  % report the correct dimensions via the activearea tag. Fortunately we can
  % determine which is correct by comparing the product of the dimensions
  % against the size of the raw data
  %
  if (imageWidth * imageHeight * SIZE_UINT16 ~= stripByteCount)
    %
    % imagewidth and imageheight tags don't match raw data size. try matching
    % using the activearea tag
    %
    [imageHeight, imageWidth] = getExifActiveAreaHeightWidth();
    if (imageWidth * imageHeight * SIZE_UINT16 ~= stripByteCount)
      fprintf("Can't find a match for EXIF image height/width vs raw data size\n");
      return;
    end
  end


  %
  % run some validity checks based on the EXIF, some of which yield warnings
  % whereas others are fatal. Here is the list:
  %
  %   Should be uncompressed
  %   Should report 16-bits per pixel
  %   Must be raw data (CFA)
  %   Must be a 2x2 CFA pattern
  %   Data must be a single strip (#rows per strip = #rows in image)
  %

  %
  % Note: Some DNG translations don't report "Uncompressed" for the
  % the compression field even though the data is uncompressed. For example,
  % the GX85 reports "Panasonic RAW 1". Assume this is ok. Note that if it's
  % not uncompressed then any modifications to the data done in these
  % scripts will completely mangle the raw data area of the DNG
  %
  exifShouldMatch('compression', 'uncompressed');

  %
  % Note: Some DNG translations show < 16 bits per sample even though the
  % data is actually encoded as 16 bits. For example, the GX85 reports 12 bits
  %
  exifShouldMatch('bitspersample', '16');

  if (exifMustMatch('photometricinterpretation', 'color filter array'))
    return;
  end
  if (exifMustMatch('cfarepeatpatterndim', '2 2'))
    return;
  end
  if (exifMustMatch('rowsperstrip', num2str(imageHeight)))
    return;
  end

  %
  % load the raw data from the DNG
  %
  file = fopen(dngFilename, "r");
  if (file == -1)
    fprintf('Error: "%s" file open failed\n', dngFilename);
    return;
  end
  if (fseek(file, stripOffset, -1) ~= 0)
    fprintf('Error: "%s", seek to offset %d failed\n', dngFilename, stripOffset);
    return;
  end
  imgData = fread(file, stripByteCount / SIZE_UINT16, 'uint16=>uint16');
  bytesRead = numel(imgData)*SIZE_UINT16;
  fclose(file);
  if (bytesRead ~= stripByteCount)
    fprintf('Error: "%s", read request = %d bytes, actual bytes read = %d\n', dngFilename, stripByteCount, bytesRead);
    return;
  end

  % reshape the data into an image Height x Width matrix
  imgData = reshape(imgData, [imageWidth imageHeight])';

  % all done. build structure that's returned to caller
  dng.exifMap = exifMap;
  dng.imageWidth = imageWidth;
  dng.imageHeight = imageHeight;
  dng.stripOffset = stripOffset;
  dng.stripByteCount = stripByteCount;
  dng.imgData = imgData;
  dng.cfaPatternMatrix = reshape(arrayfun(@str2num, regexprep(exifMap("cfapattern2"), '\s', '')), [2 2])';
  strRgb = 'RGB'; dng.cfaPatternStr = arrayfun(@(val) strRgb(str2num(val)+1), regexprep(exifMap("cfapattern2"), '\s', ''));

  success = true;
end
