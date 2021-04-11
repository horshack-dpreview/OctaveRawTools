%
%% applyFlatFrameToDng
%
% Applies a raw flat frame to a raw image using zero blur, which allows the
% removal of sensor dust spots (and also vignetting correction) at the expense
% of introducing some noise from the flat frame
%
% _Parameters_
% * dngTargetFilename     - Filename of DNG to correct (must be uncompressed)
% * dngFlatFieldFilename  - Filename of DNG flat-field image (must be uncompressed)
%
% _Return Values_
% * result                - false if successful, true if error
%
%
function result = applyFlatFrameToDng(dngTargetFilename, dngFlatFieldFilename)

  function avg = calcChannelCenterAverage(channelData)
    avg = mean(channelData(floor(end/2-128):floor(end/2+128), floor(end/2-128):floor(end/2+128))(:));
  end

  result = true; % assume error

  % load the DNGs
  dngTarget = loadDngRawData(dngTargetFilename);
  if (!dngTarget.success) return; end
  dngFlatField = loadDngRawData(dngFlatFieldFilename);
  if (!dngFlatField.success) return; end

  % do some validity checks
  if (dngTarget.imageWidth != dngFlatField.imageWidth || dngTarget.imageHeight != dngFlatField.imageHeight)
    fprintf('Target and Flat field DNGs have different image dimensions\n');
    return;
  end

  % split the raw data into its separate RGGB channels
  [r, g1, g2, b] = rawBayerToChannels(dngTarget.cfaPatternStr, dngTarget.imgData);
  [rFlat, g1Flat, g2Flat, bFlat] = rawBayerToChannels(dngFlatField.cfaPatternStr, dngFlatField.imgData);

  % generate flat-field divisor tables for each color channel
  rDivisors  = rFlat  ./ calcChannelCenterAverage(r);
  g1Divisors = g1Flat ./ calcChannelCenterAverage(g1);
  g2Divisors = g2Flat ./ calcChannelCenterAverage(g2);
  bDivisors  = bFlat  ./ calcChannelCenterAverage(b);

  % apply flat-field divisors to image data
  r  = r  ./ rDivisors;
  g1 = g1 ./ g1Divisors;
  g2 = g2 ./ g2Divisors;
  b  = b  ./ bDivisors;

  % put the modified channels back into a bayer pattern
  imgDataOut = channelsToRawBayer(dngTarget.cfaPatternStr, r, g1, g2, b);

  % update the DNG with the new data
  result = saveRawDataToDng(dngTargetFilename, dngTarget.stripOffset, imgDataOut);

end
