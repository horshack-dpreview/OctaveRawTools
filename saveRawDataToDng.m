
%
%% saveRawDataToDng
%
% Ovewrites the raw CFA data inside an existing uncompressed DNG.
%
% _Parameters_
% * dngFilename - Filename of DNG whose raw data we're overwriting
% * stripOffset - Offset into DNG containing raw data (EXIF "stripOffset" value)
% * imgData     - Image data to write, in [Rows Columns] orientation
%
% _Return Values_
% * success     - true if successful, false if error
%
function success = saveRawDataToDng(dngFilename, stripOffset, imgData)

  success = false; % assume error

  % open the DNG
  file = fopen(dngFilename, "r+");
  if (file == -1)
    fprintf('Error: "%s" file open failed\n', dngFilename);
    return;
  end

  % seek to where the raw data starts in the file
  if (fseek(file, stripOffset, -1) != 0)
    fprintf('Error: "%s", seek to offset %d failed\n', dngFilename, stripOffset);
    return;
  end

  % overwrite the raw data, check to make sure we wrote the # bytes we wanted
  numElementsWritten = fwrite(file, imgData', 'uint16');
  fclose(file);
  if (numElementsWritten != numel(imgData))
    fprintf('Error: "%s", write request = %d bytes, actual bytes written = %d\n', dngFilename, sizeof(imgData), numElementsWritten*sizeof(uint16(0)));
    return;
  end

  %
  % remove DNG raw data checksum to prevent nuisance errors when ACR/LR loads
  % this DNG we've modified
  %
  removeDngChecksum(dngFilename);

  %
  % TBD: Also consider removing the preview images from the DNG, since they
  % no longer match the raw data we've modified
  %

  success = true;

end
