%
%% pixelBinDng2x2
%
% Pixel-bins every 2x2 pixel block of each color channel of a DNG, saving
% the resulting binned data back to the DNG. The DNG will have 1/4 the resolution
% of the original DNG (half the number of rows and columns)
%
% _Parameters_
% * dngFilename     - Filename of DNG to pixel-bin
%
% _Return Values_
% * success         - true if successful, false if error
%
%
function success = pixelBinDng2x2(dngFilename)

  success = false; % assume error

  % load the DNG
  [success, dngTarget] = loadDngRawData(dngFilename, {});
  if (~success) return; end

  % split the raw data into its separate RGGB channels
  [r, g1, g2, b] = rawBayerToChannels(dngTarget.cfaPatternStr, dngTarget.imgData);

  % pixel bin each channel
  r   = pixelBin2x2(r);
  g1  = pixelBin2x2(g1);
  g2  = pixelBin2x2(g2);
  b   = pixelBin2x2(b);

  % put the modified channels back into a bayer pattern that's 1/4 size
  binnedData = channelsToRawBayer(dngTarget.cfaPatternStr, r, g1, g2, b);

  %
  % build a full-sized bayer that has the binned data starting at its top-left
  % corner, with the remainder all zeros. When the resulting DNG is loaded into
  % an app like Photoshop, the area outside the binned image will be black
  %
  imgDataOut = zeros(size(dngTarget.imgData));
  imgDataOut(1:size(binnedData, 1), 1:size(binnedData, 2)) = binnedData;

  % update the DNG with the new data
  success = saveRawDataToDng(dngFilename, dngTarget.stripOffset, imgDataOut);

end
