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

  s = cfaPatternStrToCfaPos(cfaPatternStr);

  r  = double(imgData(s.redGreen1_FirstRow:2:end, s.redGreen1Row_Red_FirstCol:2:end));
  g1 = double(imgData(s.redGreen1_FirstRow:2:end, s.redGreen1Row_Green1_FirstCol:2:end));
  g2 = double(imgData(s.green2Blue_FirstRow:2:end, s.green2BlueRow_Green2FirstCol:2:end));
  b  = double(imgData(s.green2Blue_FirstRow:2:end, s.green2BlueRow_BlueFirstCol:2:end));

end
