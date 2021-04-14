
%
%% genExifMapFromExiftoolOutput
%
% Builds a containers.Map containing all EXIF tags and values from the
% output of exiftool -s
%
% _Parameters_
% * exiftoolOutput - Output from an invocation of exiftool with -s
%
% _Return Values_
% * map - containers.Map where each key is an EXIF tag name and each value
% is the value for that tag. The map can then be used like an assocative array
% to look up tag values. For example: map("iso") will return the value of the
% "ISO" EXIF tag. All tag names are converted to lowercase. An empty map is
% returned if an error occurs.
%
function [map] = genExifMapFromExiftoolOutput(exiftoolOutput)

  %
  % Workaround: Some DNG translations cause certain EXIF tags to become corrupted
  % with invalid UTF-8 encoding, at least as decided by exiftool. For example,
  % the "NoiseReductionParams" tag in Panasonic GX85 files converted to DNG. If we
  % pass regexp() a UTF-8 string with any invalid characters it will fail. To avoid
  % this I convert exiftool's output from UTF-8 to US-ASCII, which serves to convert
  % the invalid UTF-8 values into ASCII gibberish. By converting from UTF-8
  % to ASCII we'll likely be screwing up localization in non-english speaking locales.
  %
  exiftoolOutput = char(unicode2native(exiftoolOutput, 'US-ASCII'));

  %
  % perform a regular expression against the exiftool output to capture
  % each EXIF tag and value. The output will be stored in a cell array. Ex:
  %
  %  {
  %    [1,1] =
  %    {
  %      [1,1] = ExifToolVersion
  %      [1,2] = 12.17
  %    }
  %    [1,2] =
  %    {
  %      [1,1] = FileName
  %      [1,2] = test.dng
  %    }
  %    [1,3] =
  %    {
  %      [1,1] = ISO
  %      [1,2] = 100
  %    }
  %    ...
  %   }
  %
  exifToolTagValuePairs = regexp(exiftoolOutput, ['(\S*)\s*:\s*(.*?)[\r|\n]'], 'tokens');
  numTagValuePairs = numel(exifToolTagValuePairs);

  %
  % create a map using the tag names (converted to lowercase) and tag values,
  % both generated from the regular expression above. Octave is extremely slow
  % when adding keys to map one at a time - it takes approx 300ms to add ~300
  % keys even on a very fast system. To work around this we first create cell
  % arrays with the list of keys and values, then create the map from those
  % cell arrays
  %
  keys = {};
  values = {};
  for i = 1:numTagValuePairs
    keys{i} = lower(exifToolTagValuePairs{i}{1});
    values{i} = exifToolTagValuePairs{i}{2};
  end

  %
  % create the map
  %
  map = containers.Map(keys, values);

end
