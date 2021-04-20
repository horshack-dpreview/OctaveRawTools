%
%% pixelBin2x2
%
% Pixel-bins every 2x2 pixel block into a single pixel
%
% _Parameters_
% * dataIn        - Data to bin. This is typically a CFA channel
%
% _Return Values_
% * dataOut       - Pixel-binned data, which will be 1/4 the size (half the
%                   number of columns and rows
%
function dataOut = pixelBin2x2(dataIn)

  numRows = uint32(size(dataIn, 1));
  numColumns = uint32(size(dataIn, 2));

  assert(mod(numRows, 2)==0, '#rows must be multiple of 2');
  assert(mod(numColumns, 2)==0, '#columns must be multiple of 2');

  % split pixels in each 2x2 block into a separate matrix
  r1c1 = dataIn(1:2:end, 1:2:end);
  r1c2 = dataIn(1:2:end, 2:2:end);
  r2c1 = dataIn(2:2:end, 1:2:end);
  r2c2 = dataIn(2:2:end, 2:2:end);

  % build 3D matrix to stack separated data on 3rd dimension
  dataStacked = zeros(numRows/2, numColumns/2, 4);
  dataStacked(:, :, 1) = r1c1;
  dataStacked(:, :, 2) = r1c2;
  dataStacked(:, :, 3) = r2c1;
  dataStacked(:, :, 4) = r2c2;

  % calcualte mean of stacked data to get final result
  dataOut = mean(dataStacked, 3);

end