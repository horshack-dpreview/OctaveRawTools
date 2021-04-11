%
%% rawBayerToChannels
%
% Splits an interleaved bayer image into individual RGGB channels, converting
% the elements to double floats in the process.
%
% _Parameters_
% * cfaPatternStr  - CFA pattern. Must be RGGB or GBRG
% * imgData        - Interleaved bayer image
%
% _Return Values_
% * [r, g1, g2, b] - Four separated color channels from bayer data
%
function [r, g1, g2, b] = rawBayerToChannels(cfaPatternStr, imgData)

  switch (cfaPatternStr)
    case "RGGB"
      redGreen1_FirstRow = 1;
      green2Blue_FirstRow = 2;
    case "GBRG"
      redGreen1_FirstRow = 2;
      green2Blue_FirstRow = 1;
    otherwise
      assert(0, "Unsupported CFA pattern string");
  end

  r  = double(imgData(redGreen1_FirstRow:2:end, 1:2:end));
  g1 = double(imgData(redGreen1_FirstRow:2:end, 2:2:end));
  g2 = double(imgData(green2Blue_FirstRow:2:end, 1:2:end));
  b  = double(imgData(green2Blue_FirstRow:2:end, 2:2:end));

end
