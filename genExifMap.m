
%
%% genExifMap
%
% Builds a containers.Map containing all EXIF tags and values for an image file
%
% _Parameters_
% * filename - Filename of image to obtain EXIF tags and values
%
% _Return Values_
% * map - containers.Map where each key is an EXIF tag name and each value
% is the value for that tag. The map can then be used like an assocative array
% to look up tag values. For example: map("iso") will return the value of the
% "ISO" EXIF tag. All tag names are converted to lowercase.
%
function [map] = genExifMap(filename)

  map = containers.Map();

  %
  % run exiftool to get the full EXIF data. We use -s to get the condensed
  % version of the tag names (no spaces)
  %
  [exitCode, exiftoolOutput] = runExiftool(['-s "' filename '"']);
  if (exitCode != 0)
    return
  end

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
  numTagValuePairs = size(exifToolTagValuePairs, 2);

  %
  % create a map using the tag nameand value cell entries generated above. All
  % tag names are converted to lowercase.
  %
  for i = 1:numTagValuePairs
    map(lower(exifToolTagValuePairs{i}{1})) = exifToolTagValuePairs{i}{2};
  end

end
