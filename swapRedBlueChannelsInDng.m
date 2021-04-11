%
%% swapRedBlueChannelsInDng
%
% Simple demonstration of how to use the DNG raw functions - swaps the red
% and blue raw channels in an uncompressed DNG.
%
% _Parameters_
% * dngFilename       - Filename of DNG to swap the R/B channels of
%
% _Return Values_
% * result            - false if successful, true if error
%
function result = swapRedBlueChannelsInDng(dngFilename)

  % load the DNG
  dng = loadDngRawData(dngFilename);
  if (!dng.success)
    return;
  end

  %
  % split the raw data into its separate RGGB channels. this also converts
  % the data from its uint16 packing to double floating point
  %
  [r, g1, g2, b] = rawBayerToChannels(dng.cfaPatternStr, dng.imgData);

  % for fun, swap the R and B channels by rebayering the data but with b/r transposed
  imgDataOut = channelsToRawBayer(dng.cfaPatternStr, b, g1, g2, r);

  % update the DNG with the new data
  result = saveRawDataToDng(dngFilename, dng.stripOffset, imgDataOut);

end

