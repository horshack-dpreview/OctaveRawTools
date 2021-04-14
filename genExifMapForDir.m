
%
%% genExifMapForDir
%
% Builds a containers.Map containing all EXIF tags and values for all images
% files in a directory
%
% _Parameters_
% * directorySpec - Directory to get EXIF info from. This can optimally include
%                   a filespec suffix, for example c:\mypics\*.nef
%
% _Return Values_
% * filenamesWithPathList - Cell array list of filenames
% * exifMapList - Cell array of containers.Map objects, one per file. Each map
% is structured so that the key is the EXIF tag name (lowercase) and each value
% is the value for that tag. The map can then be used like an assocative array
% to look up tag values. For example: map("iso") will return the value of the
% "ISO" EXIF tag. All tag names are converted to lowercase. An empty map is
% returned if an error occurs.
%
function [filenamesWithPathList, exifMapList] = genExifMapForDir(directorySpec)

  filenamesWithPathList = {};  % declared early in case of error exit
  exifMapList = {};            % declared early in case of error exit

  %
  % run exiftool to get the full EXIF data. We use -s to get the condensed
  % version of the tag names (no spaces)
  %
  [exitCode, exiftoolOutput] = runExiftool(['-s "' directorySpec '"']);
  if (exitCode ~= 0)
    return
  end

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
  % since we're running exiftool against a directory, the output contains
  % results for multiple files. use a regular expression to split the output
  % by creating a cell array, one element per file.
  %
  fileNames = regexp(exiftoolOutput, ['========\s*(.*?)[\r|\n]'], 'tokens');
  exiftoolOutputPerFile = regexp(exiftoolOutput, ['====.*?\n(.*?)(?:====|directories scanned)'], 'tokens');
  assert(numel(exiftoolOutputPerFile) == numel(fileNames), "oops: Number of files parsed not equal to number of file sections parsed");

  %
  % now build the file list and a containers.Map() for the EXIF tags/values per file
  %
  numFiles = numel(exiftoolOutputPerFile);
  for nFile=1:numFiles

    filenamesWithPathList{nFile} = fileNames{nFile}{1};

    map = genExifMapFromExiftoolOutput(exiftoolOutputPerFile{nFile}{1});
    exifMapList{nFile} = map;

  end

end
