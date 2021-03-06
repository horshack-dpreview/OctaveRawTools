
%
%% genExifMapForDir
%
% Builds a containers.Map containing all EXIF tags and values for all images
% files in a directory.
%
% When working with multiple files it's much faster to read the EXIF from all
% files via a single invocation of exiftool rather than individually via
% genExifMap.m. This is particularly true on Windows 10 because Windows Defender
% appears to sandbox exiftool, triggering an intensive virus check every time
% it executes - this takes about 0.8 seconds per invocation, even on a very fast
% system.
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
  % remove any trailing backslash since we enclose the directory in double
  % quotes when building the command line, which will cause the trailing
  % backslash to be treated as a literal quote character
  %
  if (directorySpec(end) == '\')
    directorySpec = directorySpec(1:end-1);
  end

  %
  % run exiftool to get the full EXIF data. We use -s to get the condensed
  % version of the tag names (no spaces)
  %
  % FYI: This runs 3x slower on Matlab vs Octave due to some issue with
  % Matlab handling stdout flow very slowly - the run time gets progressively
  % worse the more output the pogram launched by system() performs. See
  % this post:
  %
  % https://www.mathworks.com/matlabcentral/answers/338553-performance-of-system-dos-function#comment_1471942
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
  exiftoolOutputPerFile = regexp(exiftoolOutput, ['====.*?\n(.*?)(?:====|image files read)'], 'tokens');
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
