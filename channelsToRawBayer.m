%
%% channelsToRawBayer
%
% Builds an interleaved bayer image from individual RGGB channels
%
% _Parameters_
% * cfaPatternStr - CFA pattern string. Must be RGGB or GBRG
% * r, g1, g2, b  - Matricies containing the red, green1, green2, and blue channels
%
% _Return Values_
% * Interleaved bayer image
%
function [imgData] = channelsToRawBayer(cfaPatternStr, r, g1, g2, b)
  redGreen1  = reshape([r'(:) g1'(:)]', [], size(r,1))';
  green2Blue  = reshape([g2'(:) b'(:)]', [], size(g2,1))';
  if (cfaPatternStr == "RGGB")
    imgData = reshape([redGreen1(:) green2Blue(:)]',2*size(redGreen1,1), []);
  elseif (cfaPatternStr == "GBRG")
    imgData = reshape([green2Blue(:) redGreen1(:)]',2*size(redGreen1,1), []);
  else
    assert(0, "Unsupported CFA pattern string");
end
