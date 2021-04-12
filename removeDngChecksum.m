
%
%% removeDngChecksum
%
% Removes the MD5 digest from a DNG. The digest is used to checksum the raw
% data in a DNG. If we alter the contents of raw data then the digest will
% mismatch, causing a nuisance warning from ACR/LR when the DNG is opened.
% Octave doesn't support MD5 digests against arbitrary data so the easiest
% solution is to simply remove the MD5 digest from the EXIF.
%
% _Parameters_
% * dngFilename - Filename of DNG to remove the MD5 digest from
%
% _Return Values_
% * success     - true if successful, false if error
%
function success = removeDngChecksum(dngFilename)

  %
  % run exiftool and specify an empty value for the NewRawImageDigest tag
  %
  [exitCode, exiftoolOutput] = runExiftool(['-NewRawImageDigest= -overwrite_original "' dngFilename '"']);
  success = (exitCode == 0);

end
