%
%% pixelBinPgm2x2
%
% Pixel-bins every 2x2 pixel block of each color channel of a bayered PGM
% file produced by LibRaw's unprocessed_raw.exe, saving the resulting
% binned data to the specified output file. The PGM will have 1/4 the resolution
% of the original PGM (half the number of rows and columns)
%
% _Parameters_
% * cfaPatternStr     - CFA pattern string (from EXIF. for example, "RGGB")
% * pgmInputFilename  - PGM input to pixel-bin
% * pgmOutputFilename - PGM output of pixel-bin
%
% _Return Values_
% * success           - true if successful, false if error
%
%
function success = pixelBinPgm2x2(cfaPatternStr, pgmInputFilename, pgmOutputFilename)

  success = false; % assume error

  % load the PGM
  imgDataIn = imread(pgmInputFilename);

  % split the raw data into its separate RGGB channels
  [r, g1, g2, b] = rawBayerToChannels(cfaPatternStr, imgDataIn);

  % pixel bin each channel
  r   = pixelBin2x2(r);
  g1  = pixelBin2x2(g1);
  g2  = pixelBin2x2(g2);
  b   = pixelBin2x2(b);

  % put the modified channels back into a bayer pattern that's 1/4 size
  imgDataOut = channelsToRawBayer(cfaPatternStr, r, g1, g2, b);

  % write out the binned PGM
  imwrite(uint16(imgDataOut), pgmOutputFilename);

end
