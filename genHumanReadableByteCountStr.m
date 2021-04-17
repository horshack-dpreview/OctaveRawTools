%
%% genHumanReadableByteCountStr
%
% Converts a byte count into a human-readable count by adding
% a Bytes / KiB / MiB, GiB suffix.
%
% _Parameters_
% * butes   - Value in bytes to convert to a string
%
% _Return Values_
% * str     - Value in bytes, represented as a humand-readable string
%
function str = genHumanReadableByteCountStr(bytes)
  if (bytes < 1024)
    str = sprintf('%d Bytes', bytes);
  elseif (bytes < 1024*1024)
    str = sprintf('%.2f KiB', fix(bytes/1024*100)/100);
  elseif (bytes < 1024*1024*1024)
    str = sprintf('%.2f MiB', fix(bytes/(1024*1024)*100)/100);
  else
    str = sprintf('%.2f GiB', fix(bytes/(1024*1024*1024)*100)/100);
  end
end
