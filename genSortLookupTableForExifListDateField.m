
%
%% genSortLookupTableForExifListDateField
%
% Generates a lookup table whose first column contains indexes created
% by sorting the specified EXIF date/time field and whose second column contains
% the value of that date field (converted to Matlab/Octave serial dates).
%
% For example, if called to sort by the CreateDate EXIF tag and the exifMapList
% contains the following:
%
% exifList{1}('createdate') = '2021:04:15 19:19:23' (serial date = 738261.8051273148)
% exifList{2}('createdate') = '2021:04:15 19:15:01' (serial date = 738261.8020949074)
% exifList{3}('createdate') = '2021:04:15 19:13:05' (serial date = 738261.8007523149)
%
% The returned lookup table returned will be as follows:
%
%   3
%   2
%   1
%
% This function also returns a list of the EXIF date values in the same sorted
% order:
%
%   738261.8007523149
%   738261.8020949074
%   738261.8051273148
%
% This is useful if the caller needs to access those values in sorted
% order to perform his own comparisons (like delta times between two sorted values).
% We return this list rather than requiring the caller to index it himself via
% the sorted indexes because re-accessing the containers.Map() for this value
% is very expensive in Octave.
%
% This allows the caller to index his exifMapList in sorted order. For example:
%
% sortedLookupTable = genSortLookupTableForExifListDateField('createdate', exifMapList);
% for i=1:size(sortedLookupTable,1)
%   isoOfNextAscendingImage = exifMapList{sortedLookupTable(i,1)}('iso');
%
% Note: The original implementation of this framework invoked exiftool with the
% '-fileOrder CreateDate' option in genExifMapForDir() to sort the returned EXIF
% by creation date. Unfortunately that option increases exiftool's exuection time
% by almost 2x, so this module was created to do the sorting ourselves.
%
function [sortedIndexes, sortedExifDateFieldValues] = genSortLookupTableForExifListDateField(exifFieldToSortBy, exifMapList)

  %
  % converts an EXIF CreateDate tag value into a Matab/Octave "serial date",
  % which contains the number of days in the integer portion and fractions
  % of a day in the decimal portion
  %
  function serialDate = exifDateStrToSerialDate(exifDateStr)
    serialDate = datenum(exifDateStr, "yyyy:mm:dd HH:MM:SS");
  end

  %
  % create an n x 2 matrix where the first column are indexes and the second
  % column is the value of the requested EXIF date field, converted to a
  % serial date
  %
  nElements = numel(exifMapList);
  sortedLookupMatrix = [];
  for i=1:nElements
    sortedLookupMatrix(i, 1) = i;
    sortedLookupMatrix(i, 2) = exifDateStrToSerialDate(exifMapList{i}(exifFieldToSortBy));
  end

  % now sort the matrix we created by the serial-date version of the EXIF date field
  sortedLookupMatrix = sortrows(sortedLookupMatrix, 2);

  % return vectors of the sorted indexes and serial dates
  sortedIndexes = int32(sortedLookupMatrix(:, 1));
  sortedExifDateFieldValues = sortedLookupMatrix(:, 2);

end