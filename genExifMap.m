
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
% "ISO" EXIF tag. All tag names are converted to lowercase. An empty map is
% returned if an error occurs.
%
function [map] = genExifMap(filename)

  %
  % run exiftool to get the full EXIF data. We use -s to get the condensed
  % version of the tag names (no spaces)
  %
  [exitCode, exiftoolOutput] = runExiftool(['-s "' filename '"']);
  if (exitCode ~= 0)
    map = containers.Map(); % empty map for error case
    return
  end

  map = genExifMapFromExiftoolOutput(exiftoolOutput);

end
