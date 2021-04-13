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

  s = cfaPatternStrToCfaPos(cfaPatternStr);

  if (s.redGreen1Row_Red_FirstCol == 1)
    % Octave: redGreen1 = reshape([r'(:) g1'(:)]', [], size(r,1))';
    redGreen1 = reshape([reshape(r', [], 1) reshape(g1', [], 1)]', [], size(r,1))';
    % Octave: green2Blue = reshape([g2'(:) b'(:)]', [], size(g2,1))';
    green2Blue = reshape([reshape(g2', [], 1) reshape(b', [], 1)]', [], size(g2,1))';
  else
    % Octave: redGreen1 = reshape([g1'(:) r'(:)]', [], size(r,1))';
    redGreen1 = reshape([reshape(g1', [], 1) reshape(r', [], 1)]', [], size(r,1))';
    % Octave: green2Blue = reshape([b'(:) g2'(:)]', [], size(g2,1))';
    green2Blue = reshape([reshape(b', [], 1) reshape(g2', [], 1)]', [], size(g2,1))';
  end

  if (s.redGreen1_FirstRow == 1)
    imgData = reshape([redGreen1(:) green2Blue(:)]',2*size(redGreen1,1), []);
  else
    imgData = reshape([green2Blue(:) redGreen1(:)]',2*size(redGreen1,1), []);
  end

end
