%
%% cfaPatternStrToCfaPos
%
% Builds a structure with the row and column positions of a 2x2 CFA pattern.
% All bayer sensors use a pattern with alternating Red / Green#1 pixels on
% one row and Green#2 / Blue pixels on the next row. However some sensors
% start this pattern on the alternate pixel for the row and/or column. This
% routine uses the CFA pattern description in the passed string to determine
% the the first row and column number for each of the 4 pixel color types.
%
% RGGB - Most common layout, with first column and row aligned to CFA pattern
% GBRG - Layout with the alternate row starting first. (ex: Leica Q2)
% GRBG - Layout with alternate column starting first
% BGGR - Layout with alternate row and column starting first. (ex: Panasonic GX85)
%
% _Parameters_
% * cfaPatternStr - CFA pattern string.
%
% _Return Values_
% * Structure containing fields describing which row the R/G1 and G2/B pixels
% begin on and which column the R, G1, G2, and B pixels begin on.
%
function s = cfaPatternStrToCfaPos(cfaPatternStr)

  s = struct;

  assert(cfaPatternStr == "RGGB" || cfaPatternStr == "GBRG" || cfaPatternStr == "GRBG" || cfaPatternStr == "BGGR");

  % determine row layout, ie whether R/G1 or G2/B is the first row
  s.redGreen1_FirstRow   = int32(find(cfaPatternStr == 'R'))/2;
  s.green2Blue_FirstRow  = bitxor(s.redGreen1_FirstRow, 3);

  % determine column layout, whether R/G2 or G1/B is the first column
  if (bitand(int32(find(cfaPatternStr == 'R')), 1) == 1)
    s.redGreen1Row_Red_FirstCol = 1;
  else
    s.redGreen1Row_Red_FirstCol = 2;
  end
  s.green2BlueRow_Green2FirstCol = s.redGreen1Row_Red_FirstCol; % R/G2 always share same column

  s.redGreen1Row_Green1_FirstCol = bitxor(s.redGreen1Row_Red_FirstCol, 3);
  s.green2BlueRow_BlueFirstCol   = s.redGreen1Row_Green1_FirstCol; % G1/B always share same column

end
