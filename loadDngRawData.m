
%
%% loadDngRawData
%
% Reads raw data from an uncompressed raw DNG
%
% _Parameters_
% * dngFilename - Filename of DNG to read
%
% _Return Values_
% * dng - Structure containing information and raw data from DNG:
% * dng.success         - true if raw data completed successfully, false otherwise
% * dng.exifMap         - containers.Map of all EXIF info
% * dng.imageWidth      - Number of horizontal pixels in raw data
% * dng.imageHeight     - Number of vertical pixels in raw data
% * dng.stripOffset     - File offset to raw CFA data in DNG file
% * dng.stripByteCount  - Size of raw CFA data in DNG file_in_loadpath
% * dng.imgData         - CFA data read from file
% * dng.cfaPatternMatrix- CFA pattern as 2x2 matrix (0 = Red, 1 = Green, 2 = Blue)
% * dng.cfaPatternStr   - CFA pattern as 4-character string (ex: "RGGB")
%
function dng = loadDngRawData(dngFilename)

  function failedMatch = exifMustMatch(tagName, expectedValue)
    if (!strcmpi(exifMap(tagName), expectedValue))
      fprintf('Error: "%s", EXIF tag "%s" expected to be "%s", actual is "%s"\n', dngFilename,
        tagName, expectedValue, exifMap(tagName));
      failedMatch = true;
    else
      failedMatch = false;
    end
  end

  function value = getExifScalar(tagName)
    value = str2double(exifMap(tagName));
  end

  % create struct with .success set to false as default in case we have an error
  dng = struct;
  dng.success = false;

  % get EXIF data
  exifMap = genExifMap(dngFilename);
  if (isempty(exifMap))
    return;
  end

  % get EXIF values we'll need to process the DNG
  imageWidth = getExifScalar("imagewidth");
  imageHeight = getExifScalar("imageheight");
  stripOffset = getExifScalar("stripoffsets");
  stripByteCount = getExifScalar("stripbytecounts");

  %
  % run some validity checks based on the EXIF:
  %   Must be uncompressed
  %   Must be raw data (CFA)
  %   Must be a 2x2 CFA pattern
  %   Data must be a single strip (#rows per strip = #rows in image)
  %   Expect every pixel to be 16 bits
  %
  if (exifMustMatch("compression", "uncompressed")) return; end
  if (exifMustMatch("photometricinterpretation", "color filter array")) return; end
  if (exifMustMatch("cfarepeatpatterndim", "2 2")) return; end
  if (exifMustMatch("rowsperstrip", num2str(imageHeight))) return; end
  if (exifMustMatch("bitspersample", "16")) return; end

  %
  % load the raw data from the DNG
  %
  if ((file = fopen(dngFilename, "r")) == -1)
    fprintf('Error: "%s" file open failed\n', dngFilename);
    return;
  end
  if (fseek(file, stripOffset, -1) != 0)
    fprintf('Error: "%s", seek to offset %d failed\n', dngFilename, stripOffset);
    return;
  end
  imgData = fread(file, stripByteCount / sizeof(uint16(0)), 'uint16=>uint16');
  fclose(file);
  if (sizeof(imgData) != stripByteCount)
    fprintf('Error: "%s", read request = %d bytes, actual bytes read = %d\n', dngFilename, stripByteCount, sizeof(imgData));
    return;
  end

  % reshape the data into an image Height x Width matrix
  imgData = reshape(imgData, [imageWidth imageHeight])';

  % all done. build structure that's returned to caller
  dng.success = true;
  dng.exifMap = exifMap;
  dng.imageWidth = imageWidth;
  dng.imageHeight = imageHeight;
  dng.stripOffset = stripOffset;
  dng.stripByteCount = stripByteCount;
  dng.imgData = imgData;
  dng.cfaPatternMatrix = reshape([arrayfun(@str2num, regexprep(exifMap("cfapattern2"), '\s', ''))], [2 2])';
  dng.cfaPatternStr = [arrayfun(@(val) "RGB"(val+1), dng.cfaPatternMatrix'(:))]';
end
