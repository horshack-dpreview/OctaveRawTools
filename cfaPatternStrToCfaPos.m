%
%% cfaPatternStrToCfaPos
%
% Builds a structure showing the row and column positions of a 2x2 CFA pattern
%
% _Parameters_
% * cfaPatternStr - CFA pattern string. Must be RGGB or GBRG
%
% _Return Values_
% * Structure containing fields describing which row the R/G1 and G2/B pixels
% begin on and which column the R, G1, G2, and B pixels begin on
%
function s = cfaPatternStrToCfaPos(cfaPatternStr)

  s = struct;

  s.redGreen1_FirstRow   = int32(find(cfaPatternStr == 'R'))/2;
  s.green2Blue_FirstRow  = bitxor(s.redGreen1_FirstRow, 3);

  if (bitand( int32(find(cfaPatternStr == 'R')), 1) == 1)
    s.redGreen1Row_Red_FirstCol = 1;
  else
    s.redGreen1Row_Red_FirstCol = 2;
  end
  s.redGreen1Row_Green1_FirstCol    = bitxor(s.redGreen1Row_Red_FirstCol, 3);
  s.green2BlueRow_BlueFirstCol      = s.redGreen1Row_Green1_FirstCol;
  s.green2BlueRow_Green2FirstCol    = bitxor(s.green2BlueRow_BlueFirstCol, 3);

end
